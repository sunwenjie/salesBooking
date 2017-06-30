log = Logger.new("/opt/sales_booking/current/log/email.log")

Mail.defaults do
  if Rails.env == "production"
      retriever_method :imap, :address    => "imap.i-click.com",
                              :port       => 143,
                              :user_name  => 'sales_notification@i-click.com',
                              :password   => 'sales1208',
                              :enable_ssl => false
  else
      retriever_method :imap, :address    => "imap.i-click.com",
                              :port       => 143,
                              :user_name  => 'sales_notification_staging@i-click.com',
                              :password   => 'sales1208',
                              :enable_ssl => false
  end
end



EM.run {
  EM.add_periodic_timer(5) do
    EM.defer do   
      unread_mails =  Mail.find(keys: ['NOT','SEEN'])
      unless unread_mails.empty?
        unread_mails.each do |mail|
          begin
            approved = 'pending'
            examination_id = nil
            lock_approved_status = false
            message_id = mail.in_reply_to.to_s
            body = (mail.text_part.decode_body rescue mail.decode_body)
            body.lines.each_with_index do |line,index|
              if line.to_s.downcase.include?('yes')
                approved = true
                lock_approved_status = true
                break if message_id != ""
              elsif line.to_s.downcase.include?('no') && lock_approved_status == false
                approved = false
                break if message_id != ""
              elsif line.to_s.strip.to_s.match(/examination_id=(\d+)/)
                examination_id = line.strip.match(/examination_id=(\d+)/)[0].split("=")[1]
                break
              end
            end

            examination_by_message = message_id != "" ? Examination.find_by_message_id(message_id) : Examination.find_by_id(examination_id)
            client = Client.by_message(examination_by_message.message_id).first
            order = Order.by_message(examination_by_message.message_id).first
            node_id =  (examination_by_message.node_id == 6 && examination_by_message.status == "2" ) ? 9 : examination_by_message.node_id

            language = examination_by_message.language.present? ? examination_by_message.language : ""

            if approved == 'pending'
              if order
                #ApproverWorker.perform_async(order.id, mail.from,node_id,language, "Order")
                ApproverWorker.perform_async(order.id,['chloe.tong@i-click.com,jay.liu@i-click.com,wenjie.sun@i-click.com'], node_id,language,"Order", "")
              elsif client
                #ApproverWorker.perform_async(client.id, mail.from, node_id,language,"Client")
                ApproverWorker.perform_async(client.id,['chloe.tong@i-click.com,jay.liu@i-click.com,wenjie.sun@i-click.com'],node_id,language, "Client", "")
              end
              next
            end
           
            user = User.find_by(useremail:mail.from)

            order.approver = user if order

            client.approver = user if client

            process = false
            exce = ""
            begin
              if approved
                 order.deal_order_mail_approval(true,node_id,language) if order

                 client.deal_client_mail_approval(true,node_id,language) if client

              else
                order.deal_order_mail_approval(false,node_id,language) if order

                client.deal_client_mail_approval(false,node_id,language) if client
              end
            rescue => e
              process = true
              exce = e.to_s
            end
            log.info("From:#{mail.from},Reply:#{approved},Process:#{process},Node_id:#{node_id},exce:#{exce}")

            if process
              if order
                #ApproverWorker.perform_async(order.id, mail.from,node_id,language, "Order")
                ApproverWorker.perform_async(order.id,['jay.liu@i-click.com,wenjie.sun@i-click.com'], node_id,language,"Order", "")
              elsif client
                #ApproverWorker.perform_async(client.id, mail.from,node_id,language, "Client")
                ApproverWorker.perform_async(client.id,['jay.liu@i-click.com,wenjie.sun@i-click.com'],node_id,language, "Client", "")
              end
            end
          rescue => e
            ApproverWorker.perform_async(17,['jay.liu@i-click.com,wenjie.sun@i-click.com'], 2,"en","Order","Approve Failed:#{e.inspect}") if examination_by_message != nil
            log.fatal("Caught exception; message_id:#{message_id} examination_id:#{examination_id} approved:#{approved}")
          end
        end
      end
      ActiveRecord::Base.clear_active_connections!
    end
  end
}