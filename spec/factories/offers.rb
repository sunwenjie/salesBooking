FactoryGirl.define do
  factory :offer do
    ad_platform "MyString"
    ad_type "MyString"
    regional "MyString"
    public_price "9.99"
    general_discount 1.5
    floor_discount 1.5
    ctr_prediction 1.5
    cost_prediction "9.99"
  end

end
