class Group < Base

  establish_connection "xmo_production".to_sym 
  
  belongs_to :sales_manager, inverse_of: :groups

  include Extract

  include Condition

  serialize :childrengroups

  #serialize :except_groups

  serialize :select_users

  #serialize :except_users
  
  has_and_belongs_to_many :users, join_table: "xmo.users_groups"

  has_and_belongs_to_many :clients, join_table: "#{SendMenu::DbConnection}.client_groups"
  has_and_belongs_to_many :events, join_table: "#{SendMenu::DbConnection}.event_groups"
  validates :name, presence: true, uniqueness: true
  has_many :approval_flows,:foreign_key=>"user_group"
  has_many :approval_flows,:foreign_key=>"approval_group"
  def is_super_admin?
    group_type == "Super Administrators"
  end

  def is_admin?
    group_type == "Administrators"
  end

  def is_mamager?
    group_type == "Managers"
  end
  
  # 某个 client 所在的group
  add_search_scope :with_client do |client|
    joins(:clients).where(client_conditions(client)).preload(:clients)
  end

  # 某个 user 所在的group
  add_search_scope :with_user do |sale|

    joins(:users).where(user_conditions(sale)).preload(:users)
  end

  # 某个 user 所在的group,
  add_search_scope :with_groups do |user|

    joins(:users).where(user_conditions(user))
  end

  # 多个区域经理的拥有组并集
  add_search_scope :with_managers_groups do |*managers|
    User.where(User.user_conditions(managers)).map{|user| user.user_group_ids }.flatten.uniq
  end

  # 组中组找人
  def self.round_group_users(*groups)
    #round_group_users = Group.where("id in (?)",groups.join(',')).map{|group| group.users.pluck(:id) }.flatten.uniq
    groups = groups.flatten if groups.class == Array

    round_group_users = User.with_groups(groups)
    if round_group_users.size>0
      round_group_users
    else
      []
    end
  end

  def self.update_sales_group_type(direct_sales_group,channel_sales_group)
    ActiveRecord::Base.transaction do
      sales_group_types = Group.where("sales_group_type = ? or sales_group_type = ?","direct_sales","channel_sales")
      if sales_group_types.size >0
        sales_group_types.update_all(sales_group_type:nil)
      end
      Group.where({"id"=> direct_sales_group}).update_all(sales_group_type: "direct_sales" )
      Group.where({"id"=> channel_sales_group}).update_all(sales_group_type: "channel_sales" )
  end

  end

end
