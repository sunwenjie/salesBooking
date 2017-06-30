FactoryGirl.define do
  factory :order do
    start_date DateTime.now
    ending_date {DateTime.now + (Faker::Number.number(2)).to_i.days}
    budget {Faker::Number.number(5)}
    country {Faker::Address.country}
    city {%w{BJ SH TJ CQ TW  HK MO}.sample(2)}
    regional {Order::REGIONAL.sample}
    linkman {Faker::Name.name}
    linkman_tel {Faker::Company.duns_number}
    convert_goal {Faker::Lorem.paragraph}
    interest_crowd {Faker::Lorem.words(4)}

    whether_monitor true
    third_monitor_code {Faker::Lorem.paragraph}

    blacklist_website {Faker::Internet.url}

    exclude_date []

    # trait :media_buying do
    #   extra_website {Faker::Internet.url}
    # end

    trait :additional do
      description {Faker::Lorem.paragraph}
    end

    factory :order_include_cpm_cpc, :class=>'Order' do
        after(:create) do | order |
            FactoryGirl.create :advertisement, :cpc, budget_ratio:0.5,order_id:order.id
            FactoryGirl.create :advertisement, :cpm, budget_ratio:0.5,order_id:order.id
        end
    end

    factory :order_include_nonstandard, :class=>'Order' do
        after(:create) do | order |
            FactoryGirl.create :advertisement, :cpc, budget_ratio:0.5,order_id:order.id
            FactoryGirl.create :advertisement, :cpm, :nonstandard ,budget_ratio:0.5,order_id:order.id
        end
    end



    # 创建包括CPC和CPM广告的order
    # FactoryGirl.create :order_include_cpm_cpc
    # 创建包括有非标准KPI广告的order
    # FactoryGirl.create :order_include_nonstandard


    # 创建媒体采购CPC的order
    # FactoryGirl.create :order,:cpc,:media_buying
    # 创建媒体采购CPC的order,有其它需求
    # FactoryGirl.create :order,:cpc,:media_buying,:additional
    # 创建CPC的order,有其它需求
    # FactoryGirl.create :order,:cpc,:additional
    # 创建媒体采购CPM的order
    # FactoryGirl.create :order,:cpm,:media_buying
    # 创建媒体采购CPM的order,有其它需求
    # FactoryGirl.create :order,:cpm,:media_buying,:additional
    # 创建CPM的order,有其它需求
    # FactoryGirl.create :order,:cpm,:additional
    # 创建非标准订单
    # FactoryGirl.create :order,:cpm,:nonstandard
  end

end
