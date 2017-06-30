require 'rails_helper'

RSpec.describe Client, :type => :model do
 
  #测试方法：
  #每一个it相对独立，在跑测试前都需要注释掉其它it,必使用rake db:clear清空数据库

  # let(:sale){User.find_by :role=>"sale"}
  # let(:sales_manager){User.find_by :role=>"sales_manager"}

  # FactoryGirl.create :sale_with_client
  # FactoryGirl.create :sales_manager
  # it "initialize state and sales_manager examine" do

  #     expect(Client.with_state("unapproved").count).to eq(5)

  #     c1 = Client.find 1
  #     c2 = Client.find 2
  #     c3 = Client.find 3
  #     c4 = Client.find 4
  #     c5 = Client.find 5

  #     c1.approver = sale

  #     expect(c1.submit).to eq(false)

  #     c1.approver = sales_manager

  #     expect(c1.submit).to eq(true)

  #     expect(Client.with_state("approved").count).to eq(1)

  #     c2.approver = sales_manager

  #     expect(c2.reject).to eq(true)

  #     expect(Client.with_state("cli_rejected").count).to eq(1)

  #     expect(c1.submit).to eq(false)
  #     expect(c1.reject).to eq(false)
  #     expect(c2.submit).to eq(false)
  #     expect(c2.reject).to eq(false)

  # end

  # FactoryGirl.create :sale_with_client
  # FactoryGirl.create :sales_manager
  # it "testing in_all(query_string)" do
  #     c1 = Client.find 1
  #     c2 = Client.find 2
  #     c3 = Client.find 3
  #     c4 = Client.find 4
  #     c5 = Client.find 5
  #     query_string = "#{c1.license},#{c2.name.split(',')[0]},#{c3.linkman_name},#{c4.linkman_tel}"
  #     expect(Client.in_all(query_string).count).to eq(4)
  # end


  # FactoryGirl.create :sales_manager_and_groups_users_clients
  # it "testing with_group" do
  #     c1 = Client.find 1
  #     g1 = c1.groups.first
  #     expect(Client.with_group(g1)).to eq(g1.clients)
  # end
  
  # FactoryGirl.create :sale_with_client_in_every_state
  # FactoryGirl.create :sale_with_client_in_every_state
  # FactoryGirl.create :sale_with_client_in_every_state
  # FactoryGirl.create :group
  # it "testing with_sale" do
  #     u1 = User.find 1
  #     u2 = User.find 2
  #     u3 = User.find 3
  #     g = Group.first
  #     g.user_ids = [u1.id,u2.id]
  #     c1 = u3.clients.find_by(state: "approved")
  #     g.clients << c1
  #     # 逻辑一
  #     expect(Client.with_sale(u1.username).pluck(:id).sort).to eq( u1.clients.pluck(:id).concat([c1.id]).sort )
  #     # 逻辑二
  #     # expect(Client.with_sale(u1.username).pluck(:id).sort).to eq( u1.clients.pluck(:id).concat([c1.id]).concat(u2.clients.where("state = ?","approved").pluck(:id) ).sort )
  # end

  # FactoryGirl.create :sale_with_client
  # FactoryGirl.create :sale_with_client
  # it "testing with_created_by_sale" do
  #     u1 = User.find 1
  #     u2 = User.find 2
  #     expect(Client.with_created_by_sale(u1)).to eq(u1.clients)
  # end


  
  # FactoryGirl.create :sales_manager_and_groups_users_clients
  # it "testing with_sale_in_same_groups" do
  #     u = User.find 2
  #     ecids =  u.groups.map {|group| group.clients.pluck(:id)}.flatten.uniq.sort
  #     gcids =  Client.with_sale_in_same_groups(2).pluck(:id).sort
  #     expect(ecids).to eq(gcids)
  # end










end
