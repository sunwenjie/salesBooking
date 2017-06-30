Rails.application.routes.draw do

root :to => 'orders#index'
scope "/:locale" do
  get 'channel/index'
  resources :approval_flows do 
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
         get 'scheduling'
         get 'executering'
         get 'download'
         get 'download_page'
         get 'import_order'
         get 'unapproved'
         get 'approved'
         get 'unproof'
         get 'proof'
         get 'download_proof'
         get 'download_executer'
         get 'download_draft'
         get 'undistribute'
         get 'distribute'
         get 'allocate'
         post 'allocate_create'
         get 'preview'
         get 'preview_interest'
         get 'preview_website'
         post 'get_medias'
         post 'get_sub_interests'
         post 'interest_preview'
         post 'export_image'
         get 'interest_preview'
         get 'download_image'
         get 'allocate_show'
         get 'check_city'
         get 'get_city_max_pv'
         get 'get_pv_config_data'
         get 'check_country'
         get 'check_license'
         get 'check_ad_platform'
         get 'download_orders'
         post 'check_type_message'
         post 'exchange_rate'
         post 'add_ad_form'
         post 'send_share_emails'
         post 'bshare_cities'
         post 'check_download_attr'
         get 'sync_attributes_services'
         get 'ajax_save_sync_flag'
         get 'check_ad_product'
         get 'check_share_order_group'
         post 'send_approve'
         post 'ajax_node_message'
         post 'ajax_order_state'
         post 'ajax_order_message'
         post 'ajax_download_proof'
         get 'get_locations_info'
         get 'new_advertisement'
         get 'edit_advertisement'
         post 'create_advertisement'
         patch 'update_advertisement'
         get 'delete_advertisement'
         get 'ajax_render_gp_config'
         get 'ajax_get_campaign_code'
         get 'order_examine'
         get 'history_list'
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
  end

  resources :gps do
    collection do
         post 'ajax_gp_save'
         post 'ajax_input_save'
         post 'audo_pv_distribution'
         get  'ajax_remove_pv_config'
         get  'download_gps_list'
    end
  end       

  resources :clients do
    collection do
         get 'check_client'
         get 'unapproved'
         get 'approved'
         get 'auto_complete_for_client_name'
         get 'res_message'
         get 'master_message'
         get 'download'
         post 'setup_client_cancel_examine'
         get 'sync_attributes_services'
         get 'ajax_save_sync_flag_client'
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

  resources :channels do
    collection do
         get 'download'
         get 'is_cancel_examine'
         get 'deleted'
         get 'sync_attributes_services'
         get 'ajax_save_sync_flag_channel'
         get 'loading_all'
    end
  end

  resources :schedules do
    collection do
         get 'show_schedule'
    end
  end

  get 'groups/index'

  get 'groups/new'

  get 'groups/edit'

  get 'admins/index'

  get 'book_pv' => 'book_pvs#pv_list'
  get 'booking' => 'book_pvs#booking'
  get 'pv_query' => 'book_pvs#pv_query'

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

   resources :admins do
    collection do 
      get 'get_user_group'
      get 'get_managers_list'
      get 'update_role_id'
      get 'is_cancel_examine'
      # get 'xmo_login'
      get 'login'
      post 'login'
      get 'logout'
      # get 'get_channels_list'
      post 'create_user'
      post 'update_user'
      get 'forget_password'
      post 'forget_password'
      get 'reset_mail'
      get 'error_mail'
      get 'get_roles'
      get 'update_role_id'
    end
   end

   match "/auth/login" => "admins#login", via: [:get, :post]
   #map.connect 'login', :controller => 'admins', :action => 'login'


   resources :groups


   resources :events do
     member do
       get 'delete_event'
     end
   end

   resources :offers do
     member do
       get 'delete_offer'
     end
   end

  resources :product_types
  resources :products do
    collection do
      post 'add_offer_form'
      get 'download'
      get 'delete_product'
    end
  end


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  get '*unmatched_route', :to => 'application#raise_not_found!'
end
end
