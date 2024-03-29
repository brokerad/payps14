module Paypersocial
  module Constants
    ALL_KEYWORD = 'ALL'
    DOMAIN_NAME =
      if Rails.env.production?
        'payps.co'
      elsif Rails.env.qa?
        'qa.slytrade.com'
      else
        'localhost:3000'
      end
    DOMAIN_URL = "https://#{DOMAIN_NAME}/"
    EMAIL_FROM = 'notify@payps.co'
    TRACKING_URL_WEB = "https://#{DOMAIN_NAME}/[LANGUAGE]/publisher/signup?ptc=[PARTNERCODE]"
    TRACKING_URL_FB = "https://#{DOMAIN_NAME}/[LANGUAGE]/facebook/signup?ptc=[PARTNERCODE]"
    SITE_TITLE = 'Paypersocial'
    URL_PATTERN = /(^((http|https):\/\/)?[a-z0-9]+([-.]{1}[a-z0-9]*)+.[a-z]{1,5}(([0-9]{1,5})?\/.*)?$)/ix
    FACEBOOK_BOT_USER_AGENT = ['facebookexternalhit/1.0', 'facebookexternalhit/1.1']
    FACEBOOK_BOT_IP = "204.15.20.0/22 69.63.176.0/20 66.220.144.0/20 66.220.144.0/21 69.63.184.0/21 69.63.176.0/21 74.119.76.0/22 69.171.255.0/24 173.252.64.0/18 69.171.224.0/19 69.171.224.0/20 103.4.96.0/22 69.63.176.0/24 173.252.64.0/19 173.252.70.0/24 31.13.64.0/18 31.13.24.0/21 66.220.152.0/21 66.220.159.0/24 69.171.239.0/24 69.171.240.0/20 31.13.64.0/19 31.13.64.0/24 31.13.65.0/24 31.13.67.0/24 31.13.68.0/24 31.13.69.0/24 31.13.70.0/24 31.13.71.0/24 31.13.72.0/24 31.13.73.0/24 31.13.74.0/24 31.13.75.0/24 31.13.76.0/24 31.13.77.0/24 31.13.96.0/19 31.13.66.0/24 173.252.96.0/19 69.63.178.0/24 31.13.78.0/24 31.13.79.0/24 31.13.80.0/24 31.13.82.0/24 31.13.83.0/24 31.13.84.0/24 31.13.85.0/24 31.13.86.0/24 31.13.87.0/24 31.13.88.0/24 31.13.89.0/24 31.13.90.0/24 31.13.91.0/24 31.13.92.0/24 31.13.93.0/24 31.13.94.0/24 31.13.95.0/24 69.171.253.0/24 69.63.186.0/24 204.15.20.0/22 69.63.176.0/20 69.63.176.0/21 69.63.184.0/21 66.220.144.0/20 69.63.176.0/20"        
    FACEBOOK_PATERN = /^(http|https)\:\/\/(www\.)?(([^.]+)\.)?(facebook.com|fb.me)((\/|\?)+.*)?$/ix
    TWITTER_PATERN = /^(http|https)\:\/\/(www\.)?(([^.]+)\.)?t.co((\/|\?)+.*)?$/ix
    THIRD_PARTY_PATERN = /^(s)?\:\/\/(www\.)?(([^.]+)\.)?(flipboard.com|topsy.com|tweetdeck.com)(\/)?([^.]+)*$/ix
  end
end
