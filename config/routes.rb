Rails.application.routes.draw do
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
    
  root to: 'tournaments#index', constraints: -> (r) { r.env["warden"].authenticate? && r.env['warden'].user.is_any_league_admin? }, as: :league_admin_root
  root to: 'play/dashboard#index'
  
  #this is for playing tournaments
  namespace :play do
    resources :tournaments, only: [:show] do
      get 'signup'
      put 'complete_signup'
      delete 'remove_signup'
    end
    
    resource :user_account, only: [:edit, :update], controller: "user_account" do
      get 'password'
      patch 'change_password'
    end
    
    resources :scorecards, only: [:show, :update] do
      patch 'finalize_scorecard'
      patch 'become_designated_scorer'
      patch 'update_game_type_metadata'
    end
    
    resources :dashboard, only: [:index] do
      put 'switch_leagues'
    end
  end
  
  #this is for admin
  resources :leagues do
    resources :league_memberships
    resources :tournaments do #this is for setting them up
      get 'signups'
      delete 'delete_signup'
      
      get 'manage_holes'
      patch 'update_holes'
      
      get 'finalize'
      patch 'confirm_finalization'
      
      patch 'update_course_handicaps'
      
      resource :game_types
      
      resources :golfer_teams
      
      resources :flights do
        resources :payouts
      end
      
      resources :contests do
        resources :contest_results
      end
      
      resources :tournament_groups do
        post 'batch_create', on: :collection
      end
    end
    
    get 'write_member_email'
    post 'send_member_email'
  end
  
  resources :scorecards, :except => [:delete]

  resources :courses do
    resources :course_tee_boxes
    
    resources :course_holes do
      resources :course_hole_tee_boxes
    end
  end

  resources :user_accounts do
    get 'edit_current', on: :collection
    
    get 'setup_league_admin_invite', on: :collection
    post 'send_league_admin_invite', on: :collection
    
    
    get 'setup_golfer_invite', on: :collection
    post 'send_golfer_invite', on: :collection
  end
  
  resources :crontab do
    get 'send_tournament_registration_emails', on: :collection
    get 'send_tournament_registration_reminder_emails', on: :collection
  end
  
end
