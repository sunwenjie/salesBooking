class PvWorker
  include Sidekiq::Worker

  def perform(email,file_path,flag)
    begin
      if flag
        PvDetail.import(file_path)
      else
      	PvDistribution.import(file_path)
      end
    rescue => e
      ErrorMailer.send_import_pv_error_message(email.to_s).deliver
    end
  end
  
end