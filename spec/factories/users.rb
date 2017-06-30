FactoryGirl.define do
  factory :user, :class => "User" do
    username {Faker::Internet.user_name}
    real_name {Faker::Name.name}
    email {Faker::Internet.safe_email}
    password "iclick888"
  end

  factory :sale, parent: :user do
    role_id Role.find_by(name:"sale").id

    factory :sale_with_client, :class => 'User' do
      after(:create) do | sale |
        create_list(:client, 5, created_user: sale.username )
      end
    end

    factory :sale_with_client_in_every_state, :class => 'User' do
      after(:create) do | sale |
        FactoryGirl.create :client, created_user: sale.username,state: 'unapproved'
        FactoryGirl.create :client, created_user: sale.username,state: 'approved'
        FactoryGirl.create :client, created_user: sale.username,state: 'cli_rejected'
      end
    end


    factory :sale_with_client_orders, :class=>'User' do
      after(:create) do | sale |

        sale.groups << FactoryGirl.create(:group)

        client = FactoryGirl.create :client,created_user: sale.username

        FactoryGirl.create :order_include_cpm_cpc,client_id:client.id,user_id: sale.id,industry_id: 1

        FactoryGirl.create :order_include_nonstandard,client_id:client.id,user_id: sale.id,industry_id: 1

      end
    end



    # factory :sale_with_client_under_underpraise_orders, :class=>'User' do
    #   after(:create) do | sale |

    #     sale.groups << FactoryGirl.create(:group)

    #     client = FactoryGirl.create :client,created_user: sale.username

    #     FactoryGirl.create :order,:cpc,client_id:client.id,cost: 0.1,user_id: sale.id,industry_id: 1

    #     FactoryGirl.create :order,:cpc,:additional,client_id: client.id,cost: 0.1,user_id: sale.id,industry_id: 1

    #     FactoryGirl.create :order,:cpm,:media_buying,client_id: client.id,cost: 0.1,user_id: sale.id,industry_id: 1

    #     FactoryGirl.create :order,:cpm,:media_buying,:additional,client_id: client.id,cost: 0.1,user_id: sale.id,industry_id: 1


    #   end
    # end



    # factory :sale_with_client_unapproved_media_orders, :class=>'User' do
    #   after(:create) do | sale |

    #     sale.groups << FactoryGirl.create(:group)

    #     client = FactoryGirl.create :client,created_user: sale.username

    #     FactoryGirl.create :order,:cpc,:media_buying,client_id: client.id,user_id: sale.id,state: "media_assessing_officer_unapproved" ,industry_id: 1

    #     FactoryGirl.create :order,:cpm,:media_buying,:additional,client_id: client.id,user_id: sale.id,state: "media_assessing_officer_unapproved" ,industry_id: 3
    #   end
    # end

    # factory :sale_with_client_unapproved_product_orders, :class=>'User' do
    #   after(:create) do | sale |

    #     sale.groups << FactoryGirl.create(:group)

    #     client = FactoryGirl.create :client,created_user: sale.username

    #     FactoryGirl.create :order,:cpc,:additional,client_id: client.id,user_id: sale.id,state: "product_assessing_officer_unapproved",industry_id: 2

    #     FactoryGirl.create :order,:cpm,:additional,client_id: client.id,user_id: sale.id,state: "product_assessing_officer_unapproved",industry_id: 4

    #   end

    # end

    # factory :sale_with_client_proof_ready_orders, :class=>'User' do
    #   after(:create) do | sale |

    #     sale.groups << FactoryGirl.create(:group)

    #     client = FactoryGirl.create :client,created_user: sale.username

    #     FactoryGirl.create :order,:cpc,client_id: client.id,user_id: sale.id,state: "proof_ready",industry_id: 2

    #   end
    # end

    # factory :sale_with_client_proof_unapproved_orders, :class=>'User' do
    #     after(:create) do | sale |

    #         sale.groups << FactoryGirl.create(:group)

    #         client = FactoryGirl.create :client,created_user: sale.username

    #         FactoryGirl.create :order,:cpc,client_id: client.id,user_id: sale.id,state: "proof_unapproved",industry_id: 2

    #     end
    # end

    # factory :sale_with_client_every_state_orders, :class=>'User' do
    #     after(:create) do | sale |

    #         sale.groups << FactoryGirl.create(:group)

    #         client = FactoryGirl.create :client,created_user: sale.username

    #         # state = sales_manager_unapproved
    #         FactoryGirl.create :order,:cpm,client_id: client.id,user_id: sale.id,state:"sales_manager_unapproved",industry_id: 4

    #         # state = media_assessing_officer_unapproved
    #         FactoryGirl.create :order,:cpc,:media_buying,client_id: client.id,user_id: sale.id,state: "media_assessing_officer_unapproved",industry_id: 2

    #         # state = product_assessing_officer_unapproved
    #         FactoryGirl.create :order,:cpc,:additional,client_id: client.id,user_id: sale.id,state: "product_assessing_officer_unapproved",industry_id: 2

    #         # state = proof_unapproved
    #         FactoryGirl.create :order,:cpc,client_id: client.id,user_id: sale.id,state: "proof_unapproved",industry_id: 2

    #     end
    # end

  end

  factory :sales_manager, parent: :user do
    role_id Role.find_by(name:"sales_manager").id
    factory :sales_manager_and_groups_users_clients , :class => 'User' do
      after(:create) do |sales_manager|
        create_list(:group_includes_sales_and_client,3)
        user_ids,client_ids = User.all.ids.reject{|i| i == sales_manager.id}, Client.all.ids
        ids,cids = [],[]
        number = 3
        number.times do
          ids << user_ids.shuffle.each_slice(number).to_a
          cids << client_ids.shuffle.each_slice(number).to_a
        end
        us,cs = ids[0].zip(*(ids.shift)),cids[0].zip(*(cids.shift))
        Group.first(number).each_with_index  do |group,index|
          group.user_ids = us[index].flatten.uniq
          group.client_ids = cs[index].flatten.uniq
        end

        team_heads = create_list(:team_head,3)

        Group.find(1).users << team_heads[0]
        Group.find(2).users << team_heads[1]
        Group.find(3).users << team_heads[2]


      end
    end
  end

  factory :team_head, parent: :user do
    role_id Role.find_by(name:"team_head").id


    factory :team_head_with_client, :class => 'User' do
      after(:create) do | team_head |
        create_list(:client, 5, created_user: team_head.username )
      end
    end

    factory :team_head_with_client_in_every_state, :class => 'User' do
      after(:create) do | team_head |
        FactoryGirl.create :client, created_user: team_head.username,state: 'unapproved'
        FactoryGirl.create :client, created_user: team_head.username,state: 'approved'
        FactoryGirl.create :client, created_user: team_head.username,state: 'cli_rejected'
      end
    end


    factory :team_head_with_client_orders, :class=>'User' do
      after(:create) do | team_head |

        team_head.groups << FactoryGirl.create(:group)

        client = FactoryGirl.create :client,created_user: team_head.username

        FactoryGirl.create :order_include_cpm_cpc,client_id:client.id,user_id: team_head.id,industry_id: 1

        FactoryGirl.create :order_include_nonstandard,client_id:client.id,user_id: team_head.id,industry_id: 1

      end
    end

  end

  factory :planner, parent: :user do
    role_id Role.find_by(name:"planner").id
  end

  factory :sales_president, parent: :user do
    role_id Role.find_by(name:"sales_president").id
  end

  factory :media_assessing_officer, parent: :user do
    role_id Role.find_by(name:"media_assessing_officer").id
  end

  factory :product_assessing_officer, parent: :user do
    role_id Role.find_by(name:"product_assessing_officer").id
  end

  factory :operater, parent: :user do
    role_id Role.find_by(name:"operater").id
  end

  factory :operaters_manager, parent: :user do
    role_id Role.find_by(name:"operaters_manager").id
  end

  factory :admin, parent: :user do
    role_id Role.find_by(name:"admin").id
  end

  # 创建销售人员
  # FactoryGirl.create :sale
  # 创建销售人员的同时生成5个客户
  # FactoryGirl.create :sale_with_client
  # 创建销售人员的同时生成1个客户和8个不同种类的订单
  # FactoryGirl.create :sale_with_client_orders

  # 创建销售人员的同时，创建需该媒体审批人员审批的记录
  # FactoryGirl.create :sale_with_client_unapproved_media_orders
  # 创建销售人员的同时，创建需该产品审批人员审批的记录
  # FactoryGirl.create :sale_with_client_unapproved_product_orders
  # 创建销售人员的同时，创建需要上传签名排期表的订单
  # FactoryGirl.create :sale_with_client_proof_ready_orders
  # 创建销售人员的同时，创建需要审批的上传签名排期表的订单
  # FactoryGirl.create :sale_with_client_proof_unapproved_orders

  # 创建销售总监
  # FactoryGirl.create :sales_manager
  # 创建销售总裁
  # FactoryGirl.create :sales_president
  # 创建销售总监,创建3个组9个销售和45个客户,并随机分好组
  # FactoryGirl.create :sales_manager_and_groups_users_clients
  # 创建媒体部门审批人员
  # FactoryGirl.create :media_assessing_officer
  # 创建产品部门审批人员
  # FactoryGirl.create :product_assessing_officer
  # 创建运营人员
  # FactoryGirl.create :operater
  # 创建运营总监
  # FactoryGirl.create :operaters_manager
  # 创建系统管理员
  # FactoryGirl.create :admin
  # 创建策划
  # FactoryGirl.create :planner

end
