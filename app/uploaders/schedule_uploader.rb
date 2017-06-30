# encoding: utf-8

class ScheduleUploader < CarrierWave::Uploader::Base

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.order.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png pdf xls xlsx)
  end

  def filename
    if super.present?
      model.uploader_secure_token ||= SecureRandom.uuid.gsub("-", "")
      "#{model.uploader_secure_token}.#{file.extension.downcase}"
    end
  end

end
