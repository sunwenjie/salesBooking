class Executer < Asset
  belongs_to :order,inverse_of: :executer,touch:true

  attr_accessor :uploader_secure_token

  after_save :division_type

  mount_uploader :attachment, ScheduleUploader
end