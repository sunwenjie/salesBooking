FactoryGirl.define do
  factory :client do
    name {Faker::Company.name}
    linkman_name {Faker::Name.name}
    linkman_tel {Faker::Company.duns_number}
    email {Faker::Internet.email}
    # created_user
  end
end
