class Asset < Base
  def division_type
      self.update_columns :attachment_type => self.class,
                          :attachment_file_size => attachment.size,
                          :attachment_content_type => attachment.content_type
  end
end
