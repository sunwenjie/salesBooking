FactoryGirl.define do
  factory :advertisement do
    discount 0.8
    price_presentation {Faker::Lorem.paragraph}
    # ad_platform {Advertisement::ADCOMBO.keys.sample}
    # ad_type { Advertisement::ADCOMBO[ad_platform].sample}
    cost_currency "RMB"
    cost {Faker::Number.number(2)}

    association :order

    trait :cpc do
      cost_type "CPC"
    end

    trait :cpm do
      cost_type "CPM"
    end

    trait :nonstandard do
      nonstandard_kpi {Faker::Lorem.paragraph}
    end

  end

end
