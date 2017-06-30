class Proof < Asset
  belongs_to :order,inverse_of: :proof,touch:true

  attr_accessor :uploader_secure_token

  after_save :division_type

  mount_uploader :attachment, ProofUploader

end