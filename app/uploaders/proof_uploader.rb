# encoding: utf-8

class ProofUploader < CarrierWave::Uploader::Base

  storage :file
  
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.id}"
  end

  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  


  def extension_white_list
    %w(jpg jpeg gif png pdf xls xlsx)
  end

  def filename
    if super.present?
      model.uploader_secure_token ||= SecureRandom.uuid.gsub("-","")
      "#{model.uploader_secure_token}.#{file.extension.downcase}"
    end
  end

end
