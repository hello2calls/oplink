OplinkManagement::Application.routes.draw do
  get "csn_customers/addOpu"
  get "csn_customers/addPayment" 
  get "csn_customers/addCustomer" 
  get "csn_customers/getCustomer"
  resources :opus

  post "payments/index"
  resources :payments

  post "customers/payment_history"
  get "customers/payment_history"
  get "customers/index"
  resources :customers


  devise_for :users#, :controllers => {:registrations => "registrations"}
  get "home/reports"
  post "home/showCustomer"
  get "home/showCustomer"
  post "home/displayOpuInfo"
  get "home/displayOpuInfo"
  get "home/getOpuInfo"
  post "home/after_activate"
  get "home/after_activate"
  get "home/activate_disable"
  get "home/index"
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
