 namespace :releast_client do
   desc "released_client three month oldder"
   task :generate => :environment do
     select_sql = <<-eos
        select s.id from xmo.clients as s where  s.id not in
        (
        select
        DISTINCT(clients.id) from orders
        inner join
        xmo.clients
        on clients.id = orders.client_id
        where orders.client_id is not null
        )
        and created_at < "#{Time.now - 90.day }" and state = "approved" and whether_channel = 0
     eos

     reseta_client_ids = Order.connection.select_all(select_sql)

     clients = Client.find(reseta_client_ids.rows.flatten)

     user = User.where("role_id = ?",10).first

     clients.each do |client|
        client.approver = user.id
        client.release
     end

   end
 end
