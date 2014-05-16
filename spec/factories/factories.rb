#coding: utf-8

# TODO Take a look Advertiser?
Factory.define :user_advertiser, :class => "User" do |f|
  f.password "foobar"
  f.password_confirmation "foobar"
  f.enabled true
  f.role User::ADVERTISER
  f.sequence(:email) { |n| "foo_user_advertiser#{random_discriminator}@example.com" }
end

Factory.define :user_advertiser_disabled, :class => "User" do |f|
  f.password "foobar"
  f.password_confirmation "foobar"
  f.enabled false
  f.role User::ADVERTISER
  f.sequence(:email) { |n| "foo_user_advertiser#{random_discriminator}@example.com" }
end

def random_discriminator
  "#{rand(10000)}#{Time.now.utc.to_i}"
end

Factory.define :user_publisher, :class => "User" do |f|
  f.password "foobar"
  f.password_confirmation "foobar"
  f.enabled true
  f.role User::PUBLISHER
  f.sequence(:email) { |n| "foo_user_publisher#{random_discriminator}@example.com" }
end

Factory.define :user_young_publisher, :class => "User" do |f|
  f.password "foobar"
  f.password_confirmation "foobar"
  f.enabled true
  f.role User::PUBLISHER
  f.sequence(:email) { |n| "foo_user_young_publisher#{n}@example.com" }
end

Factory.define :user_old_publisher, :class => "User" do |f|
  f.password "foobar"
  f.password_confirmation "foobar"
  f.enabled true
  f.role User::PUBLISHER
  f.sequence(:email) { |n| "foo_user_old_publisher#{n}@example.com" }
end

Factory.define :user do |f|
  f.password "foobar"
  f.password_confirmation "foobar"
  f.enabled true
  f.role User::ADMIN
  f.sequence(:email) { |n| "foo_user#{n}@example.com" }
end

Factory.define :advertiser_without_user, :class => "Advertiser" do |f|
  f.sequence(:company_name) { |n| "Coca Cola#{n}" }
  f.address "Av. Paulista"
  f.city "São Paulo"
  f.country "Brazil"
  f.zip_code "00000-000"
  f.phone "00 0000-0000"
  f.fax "11 1111-1111"
  f.site "http://www.cocacola.com.br"
end

Factory.define :advertiser do |f|
  f.sequence(:company_name) { |n| "Coca Cola#{n}" }
  f.address "Av. Paulista"
  f.city "São Paulo"
  f.country "Brazil"
  f.zip_code "00000-000"
  f.phone "00 0000-0000"
  f.fax "11 1111-1111"
  f.site "http://www.cocacola.com.br"
  f.association :user, :factory => :user_advertiser
end

Factory.define :advertiser_disabled, :class => "Advertiser" do |f|
  f.sequence(:company_name) { |n| "Coca Cola#{n}" }
  f.address "Av. Paulista"
  f.city "São Paulo"
  f.country "Brazil"
  f.zip_code "00000-000"
  f.phone "00 0000-0000"
  f.fax "11 1111-1111"
  f.site "http://www.cocacola.com.br"
  f.association :user, :factory => :user_advertiser_disabled
end

Factory.define :market do |f|
  f.name "Brazil"
  f.iso_code "iso-code"
  f.description "Not the best, but not the last..."
end

Factory.define :language_pt_br, :class => "Language" do |f|
  f.sequence(:code) {|n| "pt-BR#{random_discriminator}"}
  f.sequence(:name) {|n| "Brazilian Portuguese#{random_discriminator}"}
end

Factory.define :post_time do |f|
	f.post_time 12
end

Factory.define :category do |f|
  f.name_en "Technology"
  f.name_it "Technologia"
  f.name_pt_BR "Technologia"
  f.active true
end

Factory.define :publisher_type do |f|
  f.name 'publisher type'
  f.commission 40
  f.minimal_payment 20.0
  f.payment_delay 30
  f.is_default true
end

Factory.define :publisher_type_basic, :class => "PublisherType" do |f|
  f.name 'basic'
  f.commission 40
  f.minimal_payment 10.0
  f.payment_delay 40
  f.is_default true
end

language_pt_br = Factory(:language_pt_br)
market_pt_br = Factory(:market)
publisher_type_basic = Factory(:publisher_type_basic) if PublisherType.where(:name => 'basic').count == 0

Factory.define :publisher do |f|
  f.first_name "Pablo"
  f.last_name "Cantero"
  f.address "Av. Paulista"
  f.zip_code "00000-000"
  f.city "São Paulo"
  f.state "SP"
  f.country "Brazil"
  f.sequence(:email) { |n| "foo_publisher#{random_discriminator}@example.com" }
  f.phone "11 1111-1111"
  f.time_zone "UTC"
  f.language language_pt_br
  f.market market_pt_br
  f.publisher_type publisher_type_basic
  f.admin_id nil
  f.association :user, :factory => :user_publisher
end

Factory.define :publisher_facebook do |f|
  f.sequence(:uid) { |n| "100002895129455-#{n}" }
  f.sequence(:token) { |n| "#{n}-225993920780183|18d7b9af62079a79eb90abf9.1-100002895129455|8kneCtGSBQaSWFwX4LdHChZBn3Q" }
  f.nickname ""
  f.sequence(:email) { |n| "foo_publisher_facebook#{n}@example.com" }
  f.first_name "Pablo"
  f.last_name "Cantero"
  f.name "Pablo Cantero"
  f.image "http://graph.facebook.com/100002895129455/picture?type=square"
  f.link "http://www.facebook.com/profile.php?id=100002895129455"
  f.association :publisher
end

Factory.define :scheduled_campaign, :class => "Campaign" do |f|
  f.sequence(:name) { |n| "Scheduled Nike Campaign #{n}" }
  f.description "Just do it."
  f.association :advertiser
  f.click_value 0.25
  f.start_date Time.now.utc + 1.day
  f.end_date Time.now.utc + 30.days
  f.status Campaign::SCHEDULED
  f.budget 10000
  f.market_id market_pt_br
  f.post_times [Factory(:post_time)]  
end

Factory.define :active_campaign, :class => "Campaign" do |f|
  f.sequence(:name) { |n| "Active Nike Campaign #{n} - #{random_discriminator}" }
  f.description "Just do it."
  f.association :advertiser
  f.click_value 0.25
  f.start_date Time.now.utc
  f.end_date Time.now.utc + 30.days
  f.status Campaign::ACTIVE
  f.budget 10000
  f.market_id market_pt_br
  f.post_times [Factory(:post_time)]  
end

Factory.define :finished_campaign, :class => "Campaign" do |f|
  f.sequence(:name) { |n| "Fininshed Nike Campaign #{n}" }
  f.sequence(:description) { |n| "Just do it #{n}." }
  f.association :advertiser
  f.click_value 0.25
  f.start_date Time.now.utc - 29.days
  f.end_date Time.now.utc - 1.days
  f.status Campaign::FINISHED_BY_DATE
  f.budget 10000
  f.market_id market_pt_br
  f.post_times [Factory(:post_time)]  
end

Factory.define :post_with_finished_by_budget_campaign, :class => "Post" do |f|
  f.association :ad, :factory => :ad_with_finished_by_budget_campaign
  f.source Post::MANUAL
  f.association :place
  f.sequence(:tracking_code) { |n| "#{n}ty" }
  f.target_url "http://www.google.com"
end

Factory.define :ad_with_finished_by_budget_campaign, :class => "Ad" do |f|
  f.sequence(:message) { |n| "Don't be evil#{n}" }
  f.association :campaign, :factory => :finished_campaign_by_budget
  f.link "http://www.google.com.br/"
  f.link_description "Google homepage"
  f.link_name "http://www.google.com.br/"
  f.link_caption "Google"
  f.picture_link "http://www.google.com.br/images/srpr/logo3w.png"
  f.visibilityrating Ad::G
  f.start_date Time.now.utc - 26.day
  f.end_date Time.now.utc + 1.day
  f.categories { |c| [c.association(:category)] }
end

Factory.define :finished_campaign_by_budget, :class => "Campaign" do |f|
  f.sequence(:name) { |n| "Fininshed Nike Campaign #{n}" }
  f.sequence(:description) { |n| "Just do it #{n}." }
  f.association :advertiser
  f.click_value 0.25
  f.start_date Time.now.utc - 29.days
  f.end_date Time.now.utc + 2.days
  f.status Campaign::FINISHED_BY_BUDGET
  f.budget 1
  f.market_id market_pt_br
  f.post_times [Factory(:post_time)]
end

Factory.define :ad do |f|
  f.sequence(:message) { |n| "Don't be evil#{n}" }
  f.association :campaign, :factory => :active_campaign
  f.link "http://www.google.com.br/"
  f.link_description "Google homepage"
  f.link_name "http://www.google.com.br/"
  f.link_caption "Google"
  f.picture_link "http://www.google.com.br/images/srpr/logo3w.png"
  f.visibilityrating Ad::G
  f.start_date Time.now.utc + 1.day + 1.hours
  f.end_date Time.now.utc + 1.day + 10.hours
  f.categories { |c| [c.association(:category)] }
end

Factory.define :ad_adult, :class => Ad do |f|
  f.sequence(:message) { |n| "Don't be evil#{n}" }
  f.campaign do | c |
    c.association :active_campaign
  end
  f.link "http://www.google.com.br/"
  f.link_description "Google homepage"  
  f.link_name "http://www.google.com.br/"
  f.link_caption "Google"
  f.picture_link "http://www.google.com.br/images/srpr/logo3w.png"
  f.visibilityrating Ad::PG
  f.start_date Time.now.utc + 1.day + 1.hours
  f.end_date Time.now.utc + 1.day + 10.hours  
  f.categories { |c| [c.association(:category)] }
end

Factory.define :post do |f| 
  f.association :ad
  f.source Post::MANUAL
  f.association :place
  f.sequence(:tracking_code) { |n| "#{n}ty" }
  f.target_url "http://www.google.com"
end

Factory.define :place do |f|
  f.place_type 'Account'
  f.name "Pablo Canyero"
  f.friends 2
  f.fans 0
  f.enabled true
  f.access_token "225993920780183|18d7b9af62079a79eb90abf9.1-100002895129455|#{random_discriminator}"
  f.post_limit 2
  f.association :publisher_facebook
end

Factory.define :tracking_request do |f|
  f.association :post
  f.status TrackingRequest::PAYABLE
  f.sequence(:ip) { |n| "192.168.0.#{n}" }
end

Factory.define :root_account, :class => "Account" do |f|
  f.sequence(:name) { |n| "Root Account#{n}" }
  f.nature Account::ROOT_NATURE
end

Factory.define :account do |f|
  f.sequence(:name) { |n| "An account#{n}" }
  f.nature Account::MIXED_NATURE
end

Factory.define :prepaid_package do |f|
  f.sequence(:package_code) { |n| "Super Package #{n}" }
  f.start_date Time.now.utc
  f.end_date Time.now.utc + 3.days
  f.price 10000
  f.discount 10
  f.budget 11000
end

Factory.define :term_enabled, :class => "Term" do |f|
  f.title "Don't read it, just accept it.."
  f.eng "We are evil (6)"
  f.ita "We are evil (6)"
  f.por "We are evil (6)"
  f.enabled true
end

Factory.define :term_disabled, :class => "Term" do |f|
  f.title "Don't read it, just accept it.."
  f.ita "We are evil (6)"
  f.eng "We are evil (6)"
  f.por "We are evil (6)"
  f.enabled false
end
