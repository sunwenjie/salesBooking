class Channel < ActiveRecord::Base

has_and_belongs_to_many :users, join_table: "#{SendMenu::DbConnection}.user_channels"
has_many :client,:class=>Client
has_many :channel_attribute_values, inverse_of: :channel
has_many :order , inverse_of: :channel
has_many :channels_contact, inverse_of: :channel
has_many :channel_rebates, inverse_of: :channel,dependent: :destroy

validates_uniqueness_of :channel_name,conditions: -> { where("is_delete is null") }
validates :channel_name, presence: true
validates :user_ids, presence: true
validates :qualification_name, presence: true
validates :company_adress, presence: true
# validate :valid_rebate
validates :contact_person, presence: true
validates :phone, presence: true
  VALID_EMAIL_REGEX = /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
validates :email, presence: true, format:{ with: VALID_EMAIL_REGEX }
validates :position, presence: true

  attr_accessor :all_nonuniforms_date_range, :all_nonuniform_rebate

  def item_present?(value)
    value.present? ? value : '-'
  end

#代理返点验证
  def valid_rebate
    errors.add(:nonuniform_date_range,I18n.t("order.rebate_date_validate")) if  all_nonuniforms_date_range["nonuniform_date_range"].blank?
    errors.add(:nonuniform_rebate,I18n.t("order.rebate_value_validate")) if all_nonuniform_rebate["nonuniform_rebate"].blank?
    # p '-----errors------------'
    # p errors.messages
  end

  def self.with_sale_agencies(current_user)
    if current_user.administrator?
      sql = "select channels.*,
       group_concat(users.name) salesperson,currencies.name currency_name,
       GROUP_CONCAT(DATE_FORMAT(channel_rebates.start_date,'%Y/%m/%d'),' ~ ',DATE_FORMAT(channel_rebates.end_date,'%Y/%m/%d')) rebate_date,
       GROUP_CONCAT(DATE_FORMAT(channel_rebates.start_date,'%Y/%m/%d'),' ~ ',DATE_FORMAT(channel_rebates.end_date,'%Y/%m/%d'), '  ' ,channel_rebates.rebate, '%') rebate_date_totip,
       GROUP_CONCAT(channel_rebates.rebate) ch_rebate
          from channels
          left join xmo.currencies on channels.currency_id = currencies.id
          left join channel_rebates on channels.id = channel_rebates.channel_id
          left join user_channels on user_channels.channel_id = channels.id
          left join xmo.users on users.id = user_channels.user_id
          where is_delete is null or is_delete = ''
          group by channels.id order by channels.updated_at desc"
    else
      #@user_ids = Permission.where("approval_user = #{current_user.id} and node_id = 12").map(&:create_user)
      #create_user 取不到值，所以修改
      user_ids = Permission.find_by_sql("SELECT permissions.approval_flow_id,permissions.create_user agency_user_ids,permissions.approval_user,node_id FROM permissions WHERE (approval_user = #{current_user.id} and node_id = 12)")
      users = user_ids.present? ? user_ids.map(&:agency_user_ids) : []

      sql = "select channels.*,
       group_concat(users.name) salesperson,currencies.name currency_name,
       GROUP_CONCAT(DATE_FORMAT(channel_rebates.start_date,'%Y/%m/%d'),' ~ ',DATE_FORMAT(channel_rebates.end_date,'%Y/%m/%d')) rebate_date,
       GROUP_CONCAT(DATE_FORMAT(channel_rebates.start_date,'%Y/%m/%d'),' ~ ',DATE_FORMAT(channel_rebates.end_date,'%Y/%m/%d'), '  ' ,channel_rebates.rebate, '%') rebate_date_totip,
       GROUP_CONCAT(channel_rebates.rebate) ch_rebate
          from channels
          left join user_channels on channels.id = user_channels.channel_id
          left join xmo.users on users.id = user_channels.user_id
          left join xmo.currencies on channels.currency_id = currencies.id
          left join channel_rebates on channels.id = channel_rebates.channel_id
          where (is_delete is null or is_delete = '') and (user_channels.user_id in (#{users.join(',')}) or user_channels.channel_id is null)
          group by channels.id order by channels.updated_at desc
          "
    end
    return Channel.find_by_sql(sql)
  end

end

