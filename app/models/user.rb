class User < Base

  establish_connection :xmo_production

  serialize :bu

  include Concerns::Extract

  include Concerns::Condition

  has_many :clients, inverse_of: :user

  has_many :permissions, inverse_of: :user, foreign_key: 'approval_user'

  has_and_belongs_to_many :groups, join_table: 'xmo.users_groups'

  belongs_to :group

  belongs_to :agency

  has_and_belongs_to_many :channels, join_table: "#{SendMenu::DbConnection}.user_channels"

  has_many :orders, -> { order(:position) }, inverse_of: :user

  def deleted?
    !!deleted_at
  end

  validates :username, presence: true

  validates_format_of :useremail, :with => Devise.email_regexp, :message => "不符合邮箱格式"

  def role_name
    group_id > 0 ? group.group_type : ""
  end

  def email
    self.useremail
  end

  def tel
    self.usercontact
  end

  def user_state
    self.user_status
  end

  def is_admin?
    group and group.is_admin?
  end

  def administrator?
    group and (group.is_admin? || group.is_super_admin?)
  end

  # def account_manager?
  #   group and group.is_mamager?
  # end

  def can_manage_product?
    Permission.where("approval_user = #{self.id} and node_id = 11").present?
  end

  def can_manage_channel?
    Permission.where("approval_user = #{self.id} and node_id = 12").present?
  end

  # validates :groups, presence: true, :if => :need_groups?

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :lockable
  # :recoverable, :rememberable, :trackable, :validatable, :lockable
  devise :timeoutable

  validates :useremail, presence: true
  #validates_uniqueness_of :useremail,:allow_blank => true,conditions: -> { where.not(user_status: 'remove') }
  validates_format_of :useremail, :with => Devise.email_regexp, :message => "不符合邮箱格式"

  attr_accessor :login

  #after_create :send_user_mail
  AGENCY_ID = 1

  def self.authenticate(username, password)
    c_user = nil
    User.where(:useremail => username).order("user_status asc, agency_id asc").each do |user|
      if user["password"] == encrypted_password(password, user.salt)
        c_user = user
        c_user.last_logged_in_at = Time.now
        c_user.save(:validate => false)
        break
      end
    end
    c_user
  end

  # def agency_name
  #
  # end

  def real_name
    self.name
  end

  def self.encrypted_password(password, salt)
    Digest::SHA1.hexdigest("#{password}wibble#{salt}")
  end


  def manageable_clients
    if self.administrator?
      Client.all.with_state("approved").preload(:client_channel)
    else
      Client.with_sale_clients(self, nil, 'all').select { |x| x.state == "approved" }
    end
  end

  def send_user_mail
    raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
    self.reset_password_token = hashed_token
    self.reset_password_sent_at = Time.now.utc
    self.save
    UserWorker.perform_async(self.id, raw_token)
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(useremail) = :value", {:value => login.downcase}]).first
    else
      where(conditions).first
    end
  end

  add_search_scope :in_username_or_email do |words|
    like_any([:username, :useremail], prepare_words(words))
  end

  def self.simple_scopes
    [
        :ascend_by_real_name,
        :descend_by_real_name,
        :ascend_by_email,
        :descend_by_email,
        :ascend_by_username,
        :descend_by_username
    ]
  end

  add_simple_scopes simple_scopes

  add_search_scope :active_users do
    where("user_status = ? ", "Active")
  end

  # add_search_scope :with_bu do |bu|
  #   joins("INNER JOIN xmo.users_groups on xmo.users_groups.user_id = xmo.users.id").
  #   joins("INNER JOIN xmo.groups ON xmo.users_groups.group_id =  xmo.groups.id")
  #   .active_users.where("bu like '%#{bu.first}%' and  xmo.groups.`group_type` = 'Managers' ").order("binary trim(username)")
  # end

  add_search_scope :with_groups do |groups|
    groups ? Group.where(Group.group_conditions(groups)).map { |group| group.users.pluck(:id) }.flatten.uniq : ["no"]
  end

  add_search_scope :with_groups_name do |groups|
    groups ? Group.where(Group.group_conditions(groups)).where("group_type = 'Managers'").map { |group| group.users.eager_load(:agency).active_users.order("binary trim(users.name)") }.flatten.uniq : [""]
  end

  add_search_scope :with_emails do |groups|
    groups ? Group.where(Group.group_conditions(groups)).map { |group| group.users.pluck(:useremail) }.flatten.uniq : ["no"]
  end

  add_search_scope :with_client_same_channel do |channel|
    User.joins(:channels).where("#{SendMenu::DbConnection}.user_channels.channel_id = ?", channel)
  end

  def active_for_authentication?
    super && self.is_active?
  end

  #个人BU产品new
  def self_bu_adcombo_new(product_type)
    if self.bu
      Product.where("product_type = ? and is_delete = ?", product_type, false).order("name").select { |product| ((product.bu? ? product.bu : []) & self.bu).size>0 }.collect { |product| [I18n.locale.to_s == "en" ? product.en_name+ " ("+product.sale_model+")" : product.name + " ("+product.sale_model+")", product.id] }
    else
      Product.where("product_type = ? and is_delete = ?", product_type, false).order("name").collect { |product| [I18n.locale.to_s == "en" ? product.en_name + " ("+product.sale_model+")" : product.name + " ("+product.sale_model+")", product.id] }
    end
  end

  #个人BU产品show
  def self_bu_adcombo_show(product_id)
    Product.where("id = ?", product_id).collect { |product| [(I18n.locale.to_s == "en" && product.en_name?) ? product.en_name + " ("+product.sale_model+")" : product.name + " ("+product.sale_model+")", product.id] }
  end

  #个人BU产品类别
  def self_bu_adtype_new
    if self.bu
      Product.where("is_delete = ?", false).order("ad_platform", "product_type").select { |product| ((product.bu? ? product.bu : []) & self.bu).size>0 }.collect { |product| [I18n.locale.to_s == "en" ? product.product_type_en : product.product_type_cn, product.product_type] }.uniq << [I18n.locale.to_s == "en" ? "Others" : "其他", "OTHERTYPE"]
    else
      Product.where("is_delete = ?", false).order("ad_platform", "product_type").collect { |product| [I18n.locale.to_s == "en" ? product.product_type_en : product.product_type_cn, product.product_type] }.uniq << [I18n.locale.to_s == "en" ? "Others" : "其他", "OTHERTYPE"]
    end
  end

  #用户是否是直客

  def direct_sale?
    Group.with_user(self).map(&:sales_group_type).compact.include? "direct_sales"
  end

  #当前用户所属的非标特批审批流
  def special_approval_flows
    specialApFlows = ApprovalFlow.where({"node_id" => 3})
    user_groups = self.groups.map(&:id)
    return specialApFlows.select { |sf| user_groups.include? sf.approval_group }.map(&:id)
  end

  def group_active?
    groups and groups.exists? ({status: 'Active'})
  end

  def active?
    user_status == "Active"
  end

  def paused?
    user_status == "Paused"
  end

  def stopped?
    user_status == "Stopped"
  end

  def support_email
    agency and agency.try(:contact_email)
  end

end
