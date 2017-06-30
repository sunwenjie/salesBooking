FactoryGirl.define do
  factory :group do
    name {Faker::Lorem.word}
    factory :group_includes_sales_and_client, :class=>'Group' do
      after(:create) do | group | 
        sales = create_list(:sale_with_client, 3)
      end
    end

  end

  # 创建销售组
  # FactoryGirl.create :group
  # 创建销售组并同时创建3个sales及15个客户
  # FactoryGirl.create :group_includes_sales_and_client



end
