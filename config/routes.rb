Slytrade::Application.routes.draw do

scope "(:locale)", :locale => /en|it/ do

  root :to => "application#index"
  match "/" => "application#index"

  namespace :admin do
    resources :variables, :only => [:index, :edit, :update]
    resources :users, :except => [:show]
    resources :user_sessions
    resources :advertisers do
      get "login_as_advertiser", :to => "advertisers#login_as_advertiser", :as => :login_as_advertiser
      get "remove_advertiser", :to => "advertisers#remove_advertiser", :as => :remove_advertiser
    end
    resources :publishers do
      get "login_as_publisher", :to => "publishers#login_as_publisher", :as => :login_as_publisher
    end
    resources :prepaid_packages
    resources :publisher_types
    resources :publisher_pending_withdrawals, :only => [:index, :show]

    get "publisher_pending_withdrawals/transactions/:id",
      :to => "publisher_pending_withdrawals#transactions",
      :as => :publisher_pending_withdrawals_transactions

    resources :revenue_shares, :except => [:show]

	get "new_condition_for_partner/:partner_id", :to => "revenue_shares#new", :as => :new_condition_for_partner

    get "confirm_publisher_withdrawal/:publisher_id/withdrawal/:transaction_id",
        :to => "confirm_publisher_pending_withdrawal#index",
        :as => :confirm_publisher_withdrawal

    resources :publisher_withdrawals, :only => [:index, :show]
    resources :payments
    resources :transactions, :only => [:index]
    resources :terms

    resources :campaigns do
      resources :ads
    end

    resources :ads

#     resources :campaigns, :only => [:index] do
#       resources :ads, :only => [:index]
#     end

    resources :partners, :except => [:show] do
      get "login_as_partner", :to => "partners#login_as_partner", :as => :login_as_partner
    end
    resources :places, :only => [:update]

    get "reports/advertisers",
        :to => "advertiser_reports#index",
        :as => :advertiser_reports

    get "reports/advertisers/:advertiser_id/campaigns",
        :to => "advertiser_campaign_reports#index",
        :as => :advertiser_campaign_reports

    get "reports/advertisers/:advertiser_id/campaigns/:campaign_id/ads",
        :to => "advertiser_campaign_ad_reports#index",
        :as => :advertiser_campaign_ad_reports

    get "reports/advertisers/:advertiser_id/campaigns/:campaign_id/ads/:ad_id/publishers",
        :to => "advertiser_campaign_post_reports#index",
        :as => :advertiser_campaign_post_reports

    post "tranctions/confirm/:id", :to => "transactions#confirm_transaction", :as => :confirm_transaction
    post "tranctions/reject/:id", :to => "transactions#reject_transaction", :as => :reject_transaction

    resources :campaigns do
      resources :ads
    end

    resources :ads do
        member do
            post :approve
            post :reject
        end
    end

    get "resports/campaigns/:campaign_id/detailed-clicks",
        :to => "campaign_detailed_clicks#index",
        :as => :campaign_detailed_clicks

#     get "resports/campaigns/:campaign_id/detailed-clicks",
#         :to => " campaign_detailed_clicks_controller#index",
#         :as => :campaign_detailed_clicks

    post "resports/campaigns/detailed-clicks-update",
        :to => "campaign_detailed_clicks#update",
        :as => :campaign_detailed_clicks_update

    get "reports/campaigns/clicks",
        :to => "campaign_clicks#index",
        :as => :campaign_clicks

    get "campaigns/:campaign_id/process",
        :to => "campaign_process#index",
        :as => :campaign_process
    get "campaigns/:campaign_id/reprocess",
        :to => "campaign_process#reprocess",
        :as => :campaign_reprocess
    get "campaigns/:campaign_id/finish",
        :to => "campaign_finish#index",
        :as => :campaign_finish
    get "campaigns/:campaign_id/activate",
        :to => "campaign_activate#index",
        :as => :campaign_activate

    resources :partners, :except => [:show]
    get "partner-reports", :to => "partner_reports#index", :as => :partner_reports
    get "partner-reports/:partner_id/publishers", :to => "partner_reports#index_publishers", :as => :partner_reports_publishers
    get "partner-reports/:partner_id/publishers_complete", :to => "partner_reports#index_publishers_complete", :as => :partner_reports_publishers_complete
    get "partner-reports/:partner_id/publishers_incomplete", :to => "partner_reports#index_publishers_incomplete", :as => :partner_reports_publishers_incomplete

    get "ads-reports", :to => "ads_reports#index", :as => :ads_reports
    get "ads-reports", :to => "ads_reports#index", :as => :ads_reports_filter_manager
    get "ads-reports/:ad_id/publishers", :to => "ads_publishers_reports#index", :as => :ads_publishers_reports

    get "publishers_pending_amount", :to => "publisher_pending_amount#index", :as => :publisher_pending_amount

    resources :languages
    resources :markets

    # Categories
    resources :categories

    # admin_category_activate_path
    get "categories/:id/activate",
        :to => "categories#activate",
        :as => :category_activate

    # AJAX call to change_category mthod in ads_controller.rb
    get "ads/:ad_id/change_category/:category_id",
        :to => "ads#change_category"

    # AP
    get "ap/campaigns",
        :to => "ap_campaigns#index",
        :as => :ap_campaigns
    get "ap/ads",
        :to => "ap_ads#index",
        :as => :ap_ads
    get "ap/publishers",
        :to => "ap_publishers#index",
        :as => :ap_publishers
    get "ap/search_publishers",
        :to => "ap_publishers#search",
        :as => :ap_publishers_search

    resources :coupons, :except => :show
    resources :bot_user_agents

    get "admin/search_publishers", :to => "publishers#index",:as => :publishers_search
    get "admin/filter_publishers", :to => "publishers#index",:as => :publishers_filter
    get "admin/tracking_search_partners", :to => "tracking_urls#index",:as => :tracking_search_partners

    get "publisher_pending_amount/search", :to => "publisher_pending_amount#search", :as => :publisher_pending_amount_search
    get "publisher_pending_amount/filter", :to => "publisher_pending_amount#filter", :as => :publisher_pending_amount_filter

    resources :tracking_urls, :except => :show

    # Revenueshare reports
    get "revenueshare_reports", :to => "revenueshare_reports#index", :as => :revenueshare_reports # reports
    get "revenueshare_traffic", :to => "revenueshare_traffic#index", :as => :revenueshare_traffic # traffic
    get "revenueshare_billing", :to => "revenueshare_billing#index", :as => :revenueshare_billing # billing
    get "pay_withdrawal/:id", :to => "revenueshare_billing#pay_withdrawal", :as => :pay_withdrawal
    get "transactions" , :to => "transactions#index", :as => :transaction_advertiser_filter
    get "transactions" , :to => "transactions#index", :as => :transaction_state_filter

    resources :banners
    resources :publisher_notifications, :only => [:index, :new, :create]

    get "traffic_managers/index", :to => "traffic_managers#index", :as => :traffic_managers
    get "traffic_reports/index", :to => "traffic_reports#index", :as => :traffic_reports
  end

  get "/admin", :to => "admin/application#index", :as => :admin_root

  namespace :advertiser do

    get "campaigns/:campaign_id/dashboard",
        :to => "campaign_dashboard#index",
        :as => :campaign_dashboard

    get "reports/campaigns",
        :to => "campaign_reports#index",
        :as => :campaign_reports

    get "reports/campaigns/:campaign_id/dashboard",
        :to => "campaign_dashboard_reports#index",
        :as => :campaign_dashboard_reports

    get "reports/campaigns/:campaign_id/dashboard/:ad_id/publishers",
        :to => "campaign_post_reports#index",
        :as => :campaign_post_reports

    resources :user_sessions
    resources :prepaid_packages, :only => [:index]
    resources :transactions, :only => [:index]
    resources :pending_payment, :only => [:index]
    resources :checking_account, :only => [:index]
    resources :ads
    resources :campaigns do
      resources :ads
    end

    get "prepaid_packages/confirm_buy/:id", :to => "prepaid_packages#confirm_buy", :as => :confirm_buy_prepaid_package
    post "prepaid_packages/buy/:id", :to => "prepaid_packages#buy", :as => :buy_prepaid_package
  end

  get "/advertiser", :to => "advertiser/application#index", :as => :advertiser_root
  get "/t/:tracking_code", :to => "tracking_codes#show", :as => :tracking_code
  get "/i/:tracking_code", :to => "impression#track_impression", :as => :track_impression

  namespace :publisher do
    resources :user_sessions
    resources :publishers, :only => [:edit, :update, :show]
    resources :info, :only => [:index]
    resources :billing, :only => [:index]
    resources :ads_search, :only => [:index]
    resources :campaigns, :only => [:index] do
      resources :ads, :only => [:index]
    end
    # resources :sessions, :only => [:create, :destroy]
    get "campaign/:campaign_id/reports", :to => "campaign_reports#index", :as => :campaign_reports
    get "ranking", :to => "ranking#index", :as => :ranking

    get "prereqs" => "prereqs#edit"
    put "prereqs/update" => "prereqs#update"

    get "billing/request-payments", :to => "request_payments#index", :as => :billing_request_payment
    put "billing/request-payments", :to => "request_payments#update", :as => :billing_request_payment
    get "billing/checking-account", :to => "checking_account#index",:as => :billing_checking_account
    get "billing/withdrawal", :to => "withdrawal#index", :as => :billing_withdrawal

    match "posts/:ad_id", :to => "posts#create", :via => [:post, :get], :as => "posts_path"

    match "signup" => "register_paypersocial#new", :via => :get, :as => :new
    match "create" => "register_paypersocial#create", :via => :post, :as => :create_new


    match "email_confirmation" => "register_paypersocial#email_confirmation", :via => :get, :as => :email_confirmation

    match "resend_email" => "register_paypersocial#resend_confirmation_email", :via => :get, :as => :resend_confirmation_email
    match "resend_email_send" => "register_paypersocial#resend_confirmation_email_send", :via => :post, :as => :resend_confirmation_email_send

    match "password_reset" => "register_paypersocial#password_reset", :via => :get, :as => :password_reset
    match "password_reset_send" => "register_paypersocial#password_reset_send", :via => :post, :as => :password_reset_send

    match "password_reset_handler" => "register_paypersocial#password_reset_handler", :via => :get, :as => :password_reset_handler
    match "password_reset_submit" => "register_paypersocial#password_reset_submit", :via => :post, :as => :password_reset_submit


    match "paypersocial_terms" => "register_paypersocial_terms#edit", :via => :get, :as => :paypersocial_terms
    match "paypersocial_terms_update" => "register_paypersocial_terms#update", :via => [:put, :post], :as => :paypersocial_terms_update

    match "dashboard" => "dashboards#index", :via => :get, :as => :publisher_dashboard

    match "index" => "user_sessions#new", :via => :get, :as => :publisher_login
    match "signout" => "user_sessions#destroy", :via => :get, :as => :publisher_signout

    match "facebook/dashboards/index" => "facebook_dashboards#index", :via => [:get, :post], :as => :facebook_dashboard
    match "facebook/paypersocial_terms" => "register_facebook_terms#edit", :via => :get, :as => :facebook_terms
    match "facebook/paypersocial_terms_update" => "register_facebook_terms#update", :via => [:put, :post], :as => :facebook_terms_update

    match "dashboards/my_ad"  => "dashboards#my_ad", :via => :get, :as => :my_ad
    match "dashboards/newest_ad" => "dashboards#newest_ad", :via => :get, :as => :newest_ad
    match "dashboards/category/:category" => "dashboards#categoryfilter", :via => :get, :as => :filter_category

    match "information" => "user_sessions#information", :via => :get, :as => :info_page

  end

  namespace :partner do
    resources :user_sessions

    match "index" => "user_sessions#new", :via => :get, :as => :login

    match "dashboard/index", :to => "dashboards#index", :via => :get, :as => :dashboard
    match "reports/tracking_urls", :to => "reports#tracking_urls", :via => :get, :as => :tracking_urls
    match "reports/conditions", :to => "reports#rs_conditions", :via => :get, :as => :conditions
    match "reports/traffic", :to => "reports#rs_traffic", :via => :get, :as => :rs_traffic
    match "reports/publishers", :to => "reports#publishers", :via => :get, :as => :publishers

    match "revenue_share", :to => "billings#revenue_share", :via => :get, :as => :revenue_share
    match "request_payment", :to => "billings#request_payment", :via => :get, :as => :request_payment

    match "signup", :to => "register#new", :via => :get, :as => :new
    match "create", :to => "register#create", :via => :post, :as => :create

    match "edit", :to => "edit#edit", :via => :get, :as => :edit
    match "update", :to => "edit#update", :via => :put, :as => :update
	end

  match "/partner", :to => "partner/dashboards#index", :via => :get, :as => :partner_root
  match "/publisher", :to => "publisher/dashboards#index", :via => :get, :as => :publisher_root

  match "/facebook/signup" => "publisher/register_facebook#new", :via => :get, :as => :new_facebook
  match "/auth/facebook_post/callback/" => "publisher/dashboards#auth_posts"
  match "/auth/:provider/callback/" => "publisher/register_facebook#create"

  match "auth/failure" => "publisher/register_facebook#fail"


  match "signout" => "publisher/sessions#destroy", :as => :signout

  match "email_confirmation" => "user_recoveries#email_confirmation", :via => :get, :as => :email_confirmation

  match "resend_email" => "user_recoveries#resend_confirmation_email", :via => :get, :as => :resend_confirmation_email
  match "resend_email_send" => "user_recoveries#resend_confirmation_email_send", :via => :post, :as => :resend_confirmation_email_send

  match "password_reset" => "user_recoveries#password_reset", :via => :get, :as => :password_reset
  match "password_reset_send" => "user_recoveries#password_reset_send", :via => :post, :as => :password_reset_send

  match "password_reset_handler" => "user_recoveries#password_reset_handler", :via => :get, :as => :password_reset_handler
  match "password_reset_submit" => "user_recoveries#password_reset_submit", :via => :post, :as => :password_reset_submit


  # Tools
  get "/status" => "tools/status#index"

  namespace :tasks do
    get "/publisher_fb_update_friends_count" => "publisher_facebook#update_friends_count"
    get "/posts_count" => "posts#update_posts_count"
    # Auto Publishing disabled
    #get "/auto_publishing" => "auto_publishing#index"
  end

end

match "*path" => "application#redirect_to_404"

end
