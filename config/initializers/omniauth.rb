require "omniauth-facebook"

class FacebookPost < OmniAuth::Strategies::Facebook
  option :name, 'facebook_post'
end

if Rails.env.production?
  app_id = "326914134088169"
  app_secret = "b00e8df56fdb99390de02110b8bec2f6"
  ENV["FACEBOOK_APP_URL"] = "http://apps.facebook.com/paypersocial-new"
  
  app_id_post = "292180144234212"
  app_secret_post = "6e33f62544dfb7986ed49f0bb6016e04"
elsif Rails.env.qa?
  app_id = "242262269176125"
  app_secret = "637a14ff4d1a6cb7b659c27a1f423fcc"
  ENV["FACEBOOK_APP_URL"] = "http://apps.facebook.com/paypersocial_qa"
  
  app_id_post = "121329104687964"
  app_secret_post = "ea2ea79d202ed8129bd19341f845241c"
else
  app_id = "210811618973036"
  app_secret = "ffb9c2a7dd1309f2677eaafb3b56d668"
  ENV["FACEBOOK_APP_URL"] = "http://apps.facebook.com/paypersocial_devel"
  
  app_id_post = "495260607158576"
  app_secret_post = "f5e647336950e585230787c5c5d64bf6"
end

Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, app_id, app_secret
    provider :facebook_post, app_id_post, app_secret_post,
      :scope => 'publish_stream, offline_access, email, manage_pages, user_status, user_birthday, read_stream, read_insights'
end
