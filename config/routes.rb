Rails.application.routes.draw do

root :to => 'orders#index'
scope "/:locale" do

  resources :approval_flows,except: [:show,:destroy]  do
    collection do
      get 'get_bu_products'
      get 'new_sales_group_type'
      post 'set_sales_group_type'
      get 'download'
    end
    member do
      get 'delete_approval_flow'
    end
  end

  resources :orders do
    collection do
         get 'welcome'
         get 'download'
         get 'download_proof'
         get 'download_executer'
         get 'download_draft'
         get 'history_list'
         get 'download_orders'
         post 'check_type_message'
         post 'exchange_rate'
         post 'check_download_attr'
         get 'check_ad_product'
         get 'check_share_order_group'
         post 'send_approve'
         post 'ajax_node_message'
         post 'ajax_order_state'
         post 'ajax_order_message'
         get 'get_locations_info'
         get 'delete_advertisement'
         get 'ajax_render_gp_config'
         get 'ajax_get_campaign_code'
         get 'order_examine'
         get 'loading_all'
         get 'ajax_get_operate_authority'
         post 'create_order_by_business_opportunity'
         post 'change_product_gp'
         post 'resend_approval_email'
    end
    member do
         patch 'import_proof'
         get 'proceed_deleted_at'
         get 'clone'
    end
    resources :advertisements,except: [:index,:destroy]
  end

  resources :clients,except: [:destroy] do
    collection do
         get 'check_client'
         get 'download'
         get 'loading_all'
         post 'send_client_approval'
         post 'ajax_client_node_message'
         post 'client_approval_from_pms'
    end
    member do
         patch 'client_examine'
         get 'delete_client'
    end
  end

  resources :channels,except: [:destroy] do
    collection do
         get 'download'
         get 'is_cancel_examine'
         get 'deleted'
         get 'loading_all'
    end
  end

  get 'admins/index'



  # devise_for :users, controllers: { sessions: "users/sessions" }
  #devise_for :users, path: "auth", path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', registration: 'register', sign_up: 'cmon_let_me_in' }, controllers: { sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords"}
  devise_scope :users do

    # get "sign_in", to: "users/sessions#new"
    # get "sign_up", to: "users/registrations#new"
    # delete "sign_out", to: "users/sessions#destroy"
    
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  # You can have the root of your site routed with "root"
   # root :to => 'users/sessions#new'

   resources :admins,only: [:edit,:index] do
    collection do
      get 'login'
      post 'login'
      get 'forget_password'
      post 'forget_password'
      get 'logout'
      get 'reset_mail'
      get 'error_mail'
      get 'update_user'
      post 'create_user'
    end

   end

   match "/auth/login" => "admins#login", via: [:get, :post]
   #map.connect 'login', :controller => 'admins', :action => 'login'


  resources :products,except: [:destroy] do
    collection do
      get 'download'
      get 'delete_product'
    end
  end

  get '*unmatched_route', :to => 'application#raise_not_found!'
end
end
