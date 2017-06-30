require "rails_helper"

RSpec.describe OrderMailer, :type => :mailer do

  let(:sale){User.find_by :role_id => "sale"}
  let(:sales_managers){User.where :role_id => "sales_manager"}
  let(:media_assessing_officers){User.where :role_id => "media_assessing_officer"}
  let(:product_assessing_officers) {User.where :role_id => "product_assessing_officer"}



  # FactoryGirl.create :sales_manager
  # FactoryGirl.create :media_assessing_officer
  # FactoryGirl.create :product_assessing_officer
  # FactoryGirl.create :sale_with_client_orders
  it "testing notify_wait_order_examine" do

    emails = {}

    # Order.all.each do |order|
    #   order.approver = sale
    #   order.sale_submit
    # end


    # Order.all.each do |order|
    #   order.approver = sales_manager  
    #   order.sales_manager_submit
    # end


    Order.all.each do |order|
      emails[order.code] = OrderMailer.notify_wait_order_examine(order).to
    end

    Order.all.each do |order|
      expect(emails[order.code]).to eq(media_assessing_officers.pluck(:email))  if  order.state == "media_assessing_officer_unapproved"
      expect(emails[order.code]).to eq(product_assessing_officers.pluck(:email))  if  order.state == "product_assessing_officer_unapproved"
      expect(emails[order.code]).to eq(nil)  if  order.state == "proof_ready"
    end



  end

end
