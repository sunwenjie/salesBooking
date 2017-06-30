require 'rails_helper'

RSpec.describe Order, :type => :model do

  #测试方法：
  #每一个it相对独立，在跑测试前都需要注释掉其它it,必使用rake db:clear清空数据库


  let(:sale){User.find_by :role=>"sale"}
  let(:team_head){User.find_by :role=>"team_head"}
  let(:sales_manager){User.find_by :role=>"sales_manager"}
  let(:planner){User.find_by :role=>"planner"}
  let(:sales_president){User.find_by :role=>"sales_president"}
  let(:media_assessing_officer){User.find_by :role=>"media_assessing_officer"}
  let(:product_assessing_officer) {User.find_by :role=>"product_assessing_officer"}
  let(:operater){User.find_by :role=>"operater"} 
  let(:operaters_manager) {User.find_by :role=>"operaters_manager"}
  let(:admin){User.find_by :role=>"admin"}


  

  

  # 非标准订单提交策划
  # FactoryGirl.create :sale_with_client_nonstandard_orders
  # FactoryGirl.create :sales_manager
  # FactoryGirl.create :planner
  # it "initialize state and planner check" do

  #     Order.all.each do |order|
  #       expect(order.actions).to eq([:sale_appeal])
  #     end

  #     Order.all.each do |order|
  #       order.approver = sale
  #       order.sale_appeal      
  #     end


  #     Order.all.each do |order|
  #       expect(order.actions).to eq([:planner_submit])
  #     end

  #     Order.all.each do |order|
  #       order.approver = planner
  #       order.planner_submit      
  #     end

  #     Order.all.each do |order|
  #       expect(order.actions).to eq([:sale_submit])
  #     end

  # end


  #销售总监审批合同
  # FactoryGirl.create :sale_with_client_orders
  # FactoryGirl.create :sales_manager
  # FactoryGirl.create :media_assessing_officer
  # FactoryGirl.create :product_assessing_officer


  # it "initialize state and sales_manager examine" do

  #     Order.all.each do |order|
  #       expect(order.actions).to eq([:sale_submit])
  #     end

  #     Order.all.each do |order|
  #       order.approver = sale
  #       order.sale_submit      
  #     end

  #     Order.all.each do |order|
  #       unless order.underpraise?
  #         order.approver = sales_manager
  #         expect(order.actions).to eq([:sales_manager_submit,:reject])    
  #       end
  #     end

  #     Order.all.each do |order|
  #       unless order.underpraise?
  #         order.approver = sales_manager
  #         order.sales_manager_submit     
  #       end
  #     end


  #     expect(Order.with_state("sales_manager_unapproved").count).to eq(0)  

  #     expect(Order.with_state("media_assessing_officer_unapproved").count).to eq(4)

  #     expect(Order.with_state("product_assessing_officer_unapproved").count).to eq(2)

  #     expect(Order.with_state("proof_ready").count).to eq(2)  


  #     Order.all.each do |order|
  #         if order.media_buying? && order.additional?
  #           order.approver = media_assessing_officer
  #           expect(order.actions).to eq([:media_assessing_officer_submit,:reject])     
  #         end
  #         if !order.media_buying? && order.additional?
  #           order.approver = product_assessing_officer
  #           expect(order.actions).to eq([:product_assessing_officer_submit,:reject])
           
  #         end
  #         if !order.media_buying? && !order.additional?
  #            order.approver = sale
  #            expect(order.actions).to eq([:proof_uploaded])
  #         end
  #     end
  # end

  # 销售总裁审批合同
  # FactoryGirl.create :sales_president
  # FactoryGirl.create :sale_with_client_under_underpraise_orders
  # it "initialize state and sales_president examine" do
  #     Order.all.each do |order|
  #       expect(order.actions).to eq([:sale_submit])
  #     end


  #     Order.all.each do |order|
  #       order.approver = sale
  #       order.sale_submit      
  #     end

  #     Order.all.each do |order|
  #       order.approver = sales_president
  #       expect(order.actions).to eq([:sales_president_submit,:reject])    
  #     end

  #     Order.all.each do |order|
  #       order.approver = sales_president
  #       order.sales_president_submit    
  #     end

  #     expect(Order.with_state("media_assessing_officer_unapproved").count).to eq(2)
  #     expect(Order.with_state("product_assessing_officer_unapproved").count).to eq(1) 
  #     expect(Order.with_state("proof_ready").count).to eq(1)

  # end




  # 媒体部门审批人员审批合同
  # FactoryGirl.create :media_assessing_officer
  # FactoryGirl.create :sale_with_client_unapproved_media_orders
  # it "order state is media_assessing_officer_unapproved and media_assessing_officer examine" do
  #     expect(Order.first.actions).to eq([:media_assessing_officer_submit,:reject])

  #     Order.all.each do |order|
  #       order.approver = media_assessing_officer.username
  #       order.media_assessing_officer_submit
  #     end

  #     expect(Order.with_state("media_assessing_officer_unapproved").count).to eq(0)  

  #     expect(Order.with_state("product_assessing_officer_unapproved").count).to eq(1)

  #     expect(Order.with_state("proof_ready").count).to eq(1)

  #     Order.all.each do |order|
  #       if order.additional?
  #         expect(order.actions).to eq([:product_assessing_officer_submit,:reject])
  #       end
  #       if !order.additional?
  #         expect(order.actions).to eq([:proof_uploaded])
  #       end
  #     end
  # end


  # 产品部门审批人员
  # FactoryGirl.create :product_assessing_officer
  # FactoryGirl.create :sale_with_client_unapproved_product_orders
 
  # it "order state is product_assessing_officer_unapproved and product_assessing_officer examine" do

  #     Order.all.each do |order|
  #       expect(order.actions).to eq([:product_assessing_officer_submit,:reject])
  #     end

  #     Order.all.each do |order|
  #       order.approver = product_assessing_officer.username
  #       order.product_assessing_officer_submit
  #     end

  #     expect(Order.with_state("product_assessing_officer_unapproved").count).to eq(0)  

  #     expect(Order.with_state("proof_ready").count).to eq(2)


  #     Order.all.each do |order|
  #        expect(order.actions).to eq([:proof_uploaded])
  #     end

  # end


  # 销售上传签过名的排期表
  # FactoryGirl.create :sale_with_client_proof_ready_orders
  # it "order state is shedule_ready and sale upload proof" do

  #     expect(Order.first.actions).to eq([:proof_uploaded])

  #     order = Order.first

  #     order.approver = sale.username

  #     order.proof_uploaded

  #     expect(Order.with_state("proof_ready").count).to eq(0)  

  #     expect(Order.with_state("proof_unapproved").count).to eq(1) 

  #     expect(Order.first.actions).to eq([:proof_submit, :reject])

  # end


  # 销售总监审批排期表
  # FactoryGirl.create :sale_with_client_proof_unapproved_orders
  # FactoryGirl.create :sales_manager
  # it "order state is proof_unapproved and sales_manager examine" do

  #     expect(Order.first.actions).to eq([:proof_submit, :reject])

  #     order = Order.first

  #     order.approver = sales_manager.username

  #     order.proof_submit

  #     expect(Order.with_state("proof_unapproved").count).to eq(0)  

  #     expect(Order.with_state("examine_completed").count).to eq(1) 

  #     expect(Order.first.actions).to eq([])

  # end

  # 销售总监审批拒绝，媒体部门审批人员审批拒绝，产品部门审批人员审批拒绝，销售总监审批排期表拒绝
  # FactoryGirl.create :sales_manager
  # FactoryGirl.create :media_assessing_officer
  # FactoryGirl.create :product_assessing_officer
  # FactoryGirl.create :sale_with_client_every_state_orders
  # it "order state is every state need to reject" do

  #     sm1 = Order.with_state("sales_manager_unapproved").first

  #     sm1.approver = sales_manager

  #     sm1.reject

  #     ma  = Order.with_state("media_assessing_officer_unapproved").first

  #     ma.approver = media_assessing_officer

  #     ma.reject

  #     pa = Order.with_state("product_assessing_officer_unapproved").first
      
  #     pa.approver = product_assessing_officer

  #     pa.reject

  #     sm2 = Order.with_state("proof_unapproved").first

  #     sm2.approver = sales_manager

  #     sm2.reject

  #     expect(Order.with_state("rejected").count).to eq(4)

  #     expect(Order.first.actions).to eq([])

  # end


  # FactoryGirl.create :sales_manager
  # FactoryGirl.create :sales_manager
  # FactoryGirl.create :media_assessing_officer
  # FactoryGirl.create :media_assessing_officer
  # FactoryGirl.create :product_assessing_officer
  # FactoryGirl.create :product_assessing_officer
  # FactoryGirl.create :sale_with_client_every_state_orders
  # it "sales_manager 1 approved , sales_manager 2 not changed" do
    
  #     sales_manager1 = User.where(role:"sales_manager").first
  #     sales_manager2 = User.where(role:"sales_manager").last

  #     media_assessing_officer1 = User.where(role:"media_assessing_officer").first
  #     media_assessing_officer2 = User.where(role:"media_assessing_officer").last
      
  #     product_assessing_officer1 = User.where(role:"product_assessing_officer").first
  #     product_assessing_officer2 = User.where(role:"product_assessing_officer").last 

  #     sm1 = Order.with_state("sales_manager_unapproved").first
  #     sm1.approver = sales_manager1
  #     sm1.sales_manager_submit
  #     sm1.approver = sales_manager2
  #     sm1.reject

  #     ma  = Order.with_state("media_assessing_officer_unapproved").first
  #     ma.approver = media_assessing_officer1
  #     ma.media_assessing_officer_submit
  #     ma.approver = media_assessing_officer2
  #     ma.reject

  #     pa = Order.with_state("product_assessing_officer_unapproved").first
  #     pa.approver = product_assessing_officer1
  #     pa.product_assessing_officer_submit
  #     pa.approver = product_assessing_officer2
  #     pa.reject

  #     sm2 = Order.with_state("proof_unapproved").first
  #     sm2.approver = sales_manager2
  #     sm2.proof_submit
  #     sm2.approver = sales_manager1
  #     sm2.reject


  #     expect(Order.with_state("rejected").count).to eq(0)
  # end



  # 各种审批，如果角色不对，是不可以审批。也不可以跨状态审批
  # FactoryGirl.create :sales_manager
  # FactoryGirl.create :media_assessing_officer
  # FactoryGirl.create :product_assessing_officer
  # FactoryGirl.create :sale_with_client_every_state_orders
  # it "order state is every state" do

  #     sm1 = Order.with_state("sales_manager_unapproved").first

  #     ma  = Order.with_state("media_assessing_officer_unapproved").first

  #     pa = Order.with_state("product_assessing_officer_unapproved").first

  #     sm2 = Order.with_state("proof_unapproved").first

  #     sm1.approver = media_assessing_officer.username

  #     expect(sm1.sales_manager_submit).to eq(false)

  #     ma.approver = sales_manager.username

  #     expect(ma.media_assessing_officer_submit).to eq(false)

  #     pa.approver = media_assessing_officer.username

  #     expect(ma.product_assessing_officer_submit).to eq(false)

  #     sm2.approver = product_assessing_officer.username

  #     expect(ma.proof_submit).to eq(false)

  #     expect(sm1.state).to eq("sales_manager_unapproved")

  #     expect(ma.state).to eq("media_assessing_officer_unapproved")

  #     expect(pa.state).to eq("product_assessing_officer_unapproved")

  #     expect(sm2.state).to eq("proof_unapproved")

  # end



  # FactoryGirl.create :sales_manager_and_groups_users_clients
  # # 创建订单
  # User.where("id > 1").all.each do |user|
  #   clients = Client.with_sale(user.username)
  #   clients.each do |client|
  #     FactoryGirl.create :order,client_id: client.id,user_id: user.id,industry_id: 1 
  #   end
  # end
  # it "testing with_sale" do

  #   user = User.find 2

  #   gcids = Order.with_sale(user).pluck(:id).sort

  #   ecids = (Order.with_created_by_sale(user).pluck(:id).concat Client.eager_load(:groups).where("#{Group.table_name}.id in (?)",user.groups.map(&:id)).map{ |client| client.orders.pluck(:id)  }.flatten.uniq).uniq.sort

  #   expect(gcids).to eq(ecids)

  # end


  # FactoryGirl.create :sales_manager
  # FactoryGirl.create :media_assessing_officer
  # FactoryGirl.create :product_assessing_officer
  # FactoryGirl.create :sale_with_client_every_state_orders
  # it "testing with_unapproved" do

  #  expect(Order.with_unapproved(sales_manager).count).to eq(2)

  #  expect(Order.with_unapproved(media_assessing_officer).count).to eq(1)

  #  expect(Order.with_unapproved(product_assessing_officer).count).to eq(1)

  #  expect(Order.with_unapproved(sale)).to eq(nil)
  # end


  # FactoryGirl.create :sales_manager
  # FactoryGirl.create :media_assessing_officer
  # FactoryGirl.create :product_assessing_officer
  # FactoryGirl.create :sale_with_client_orders
  # it "testing with_approved" do
  #   expect(Order.with_approved(sale).count).to eq(0)
  #   expect(Order.with_approved(sales_manager).count).to eq(0)
  #   expect(Order.with_approved(media_assessing_officer).count).to eq(0)
  #   expect(Order.with_approved(product_assessing_officer).count).to eq(0)

  #   Order.all.each do |order|
  #     order.approver = sale
  #     order.sale_submit
  #   end

  #   expect(Order.with_approved(sales_manager).count).to eq(0)

  #   Order.all.each do |order|
  #     order.approver = sales_manager  
  #     order.sales_manager_submit
  #   end

  #   expect(Order.with_approved(sales_manager).count).to eq(8)
  #   expect(Order.with_approved(media_assessing_officer).count).to eq(0)
  #   expect(Order.with_approved(product_assessing_officer).count).to eq(0)


  #   Order.all.each do |order|
  #     if order.media_buying?
  #        order.approver = media_assessing_officer
  #        order.media_assessing_officer_submit
  #     end

  #     if order.andience_buying?
  #        order.approver = product_assessing_officer
  #        order.product_assessing_officer_submit
  #     end    
  #   end

  #   expect(Order.with_approved(sales_manager).count).to eq(8)
  #   expect(Order.with_approved(media_assessing_officer).count).to eq(4)
  #   expect(Order.with_approved(product_assessing_officer).count).to eq(2)

  #   Order.all.each do |order|
  #     if order.media_buying?
  #        order.approver = product_assessing_officer
  #        order.product_assessing_officer_submit
  #     end  
  #   end

  #   expect(Order.with_approved(sales_manager).count).to eq(8)
  #   expect(Order.with_approved(media_assessing_officer).count).to eq(4)
  #   expect(Order.with_approved(product_assessing_officer).count).to eq(4)

  #   Order.all.each do |order|
  #     order.approver = sale
  #     order.proof_uploaded
  #     order.approver = sales_manager
  #     order.proof_submit
  #   end

  #   expect(Order.with_approved(sales_manager).count).to eq(8)
  #   expect(Order.with_approved(media_assessing_officer).count).to eq(4)
  #   expect(Order.with_approved(product_assessing_officer).count).to eq(4)

  # end







end
