Factory.define :user_partner, :class => "User" do |f|
  f.password "password"
  f.password_confirmation "password"
  f.enabled true
  f.role User::PARTNER
  f.sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
end

Factory.define :partner do |f|
  f.sequence(:name) { |n| "Faker::Name.name - #{n}" }
  f.address Faker::Address.street_name
  f.zip Faker::Address.zip
  f.city Faker::Address.city
  f.country Faker::Address.country
  f.contact_im Faker::Lorem.word
  f.tax_code 'TAXCODE123QBC456'
  f.sequence(:paypal_account) { |n| "#{n}-PAYPAL123"}
  f.association :user, :factory => :user_partner
  f.active true
end

Factory.define :tracking_url do |f|
  f.sequence(:name) { |n| "Tracking url - #{n}" }
  f.sequence(:lead_url) { |n| "lead-url-#{n}" }
  f.sequence(:tracking_code) { |n| "tr-code-123-#{n}" }
  f.active true
  f.association :partner
end

Factory.define :revenue_share do |f|
  f.revenue 10
  f.duration 10
  f.start_date Time.now.utc + 2.days
  f.end_date Time.now.utc + 11.days
  f.active true
  f.association :tracking_url
end

Factory.define :coupon do |f|
  f.name Faker::Name.name
  f.sequence(:code) { |n| "TST0123456-#{n}" }
  f.total 10
  f.start_date Time.now.utc + 1.hours
  f.end_date Time.now.utc + 11.days
  f.amount 100.00
  f.active true
  f.association :partner
  f.tracking_urls []
end

Factory.define :publisher_engaged, :class => 'Publisher' do |f|
  f.first_name Faker::Name.first_name
  f.last_name Faker::Name.last_name
  f.address Faker::Address.street_name
  f.zip_code Faker::Address.zip
  f.city Faker::Address.city
  f.state Faker::Address.state
  f.country Faker::Address.country
  f.sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
  f.phone Faker::PhoneNumber.phone_number
  f.time_zone "UTC"
  f.engage_date Time.now.utc + 5.days
  f.association :language, :factory => :language_pt_br
  f.association :market
  f.association :user, :factory => :user_publisher
  f.association :tracking_url
end

Factory.define :publisher_facebook_engaged, :class => 'PublisherFacebook' do |f|
  f.sequence(:uid) { |n| "#{random_number}-#{n}" }
  f.sequence(:token) { |n| "#{random_number}|#{random_number}|#{random_number}-#{n}" }
  f.nickname ""
  f.sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
  f.first_name Faker::Name.first_name
  f.last_name Faker::Name.last_name
  f.association :publisher, :factory => :publisher_engaged
end

def random_number
  rand(Time.now.utc.to_i)
end