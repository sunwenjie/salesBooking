class Examination < Base


  belongs_to :examinable, polymorphic: true

  belongs_to :order, inverse_of: :examinations, touch: true

  belongs_to :client, inverse_of: :examinations, touch: true

  validates :created_user, presence: true

  validates :approval, presence: true

  serialize :comment

  after_save :update_order_last_user

  def update_order_last_user
    if self.examinable_type == 'Order' && self.examinable_id.present?
      Order.find(self.examinable_id).update_last_user_and_last_time(self.created_user) if Order.find_by_id(self.examinable_id).present?
    end
  end

  def self.all_gp_submit
    Examination.find_by_sql("select e.examinable_id from examinations e , (select examinable_id,max(id) as id
                             from examinations where examinable_type = 'Order' and node_id = 7 group by examinable_id ) t
                              where e.id = t.id and status = '1' ").map(&:examinable_id)
  end

  def self.examination_create(node_id,user,examinable_id,examinable_type,language,status = '1',approval = '1',comment = nil,from_state = nil,to_state = nil)
    self.create :node_id => node_id,
                :created_user => user ? user.name : '',
                :approval => approval,
                :examinable_id => examinable_id,
                :examinable_type => examinable_type,
                :status => status,
                :language => language,
                :comment => comment,
                :from_state => from_state,
                :to_state => to_state
  end

  #复制examination
  def examination_dup(current_user)
    examination_new = self.dup
    examination_new.created_user = current_user.nil? ? "" : current_user.name
    examination_new.status = '0'
    examination_new.created_at = DateTime.now
    examination_new.message_id = ''
    examination_new.save
  end

  #订单客户某一节点操作记录
  # def examinations_by_node(examinable_id,examinable_type,)
  #   where({})
  # end



end
