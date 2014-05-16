def create_account name, parent, nature
  account = Account.new :name => name, :parent => parent, :nature => nature
  account.save!
  account
end

User.create :email => "admin@slytrade.com",
            :password => "slytrade",
            :password_confirmation => "slytrade",
            :role => User::ADMIN,
            :enabled => true

root = create_account BillingService::ROOT, nil, Account::ROOT_NATURE
  assets = create_account BillingService::ASSETS, root, Account::DEBIT_NATURE
    banks = create_account BillingService::BANKS, assets, Account::DEBIT_NATURE
      checking_account = create_account BillingService::CHECKING_ACCOUNT, banks, Account::DEBIT_NATURE
    receivables = create_account BillingService::RECEIVABLES, assets, Account::DEBIT_NATURE
      advertisers_receivables = create_account BillingService::ADVERTISERS_RECEIVABLES, receivables, Account::DEBIT_NATURE
    provisions = create_account BillingService::PROVISIONS, assets, Account::CREDIT_NATURE
      advertisers_provision = create_account BillingService::ADVERTISERS_PROVISION, provisions, Account::CREDIT_NATURE
      package_discount_provision = create_account BillingService::PACKAGE_DISCOUNT_PROVISION, provisions, Account::CREDIT_NATURE
  liabilities = create_account BillingService::LIABILITIES, root, Account::CREDIT_NATURE
    advertisers_liabilities = create_account BillingService::ADVERTISERS_CHECKING_ACCOUNTS, liabilities, Account::CREDIT_NATURE
    campaigns_checking_account_parent = create_account BillingService::CAMPAIGNS_CHECKING_ACCOUNTS, liabilities, Account::CREDIT_NATURE
    publishers_checking_account_parent = create_account BillingService::PUBLISHERS_CHECKING_ACCOUNTS, liabilities, Account::CREDIT_NATURE
    publishers_withdrawals = create_account BillingService::PUBLISHERS_WITHDRAWALS, liabilities, Account::CREDIT_NATURE
  expenses = create_account BillingService::EXPENSES, root, Account::DEBIT_NATURE
    discounts = create_account BillingService::DISCOUNTS, expenses, Account::DEBIT_NATURE
      advertisers_packages_discounts = create_account BillingService::ADVERTISERS_PACKAGES_DISCOUNTS, discounts, Account::DEBIT_NATURE
  income = create_account BillingService::INCOME, root, Account::CREDIT_NATURE
    publishers_income_parent = create_account BillingService::PUBLISHERS_INCOME, income, Account::CREDIT_NATURE


package = PrepaidPackage.new :package_code => "BigPromotion",
                             :start_date => Time.now,
                             :end_date => Time.now + 90.days,
                             :price => 10000,
                             :discount => 20,
                             :budget => 12000
package.save!

publisher_type = PublisherType.new :name => PublisherType::BASIC
publisher_type.save!

it = Market.create :name => "Italy"
br = Market.create :name => "Brasil"
us = Market.create :name => "USA"
uk = Market.create :name => "UK"

PostTime.create!([
  (0..23).collect { |i| { :post_time => i } }
])

morning = PostTime.find(8)
evening = PostTime.find(18)

BotUserAgent.create!(
	:user_agent => "facebookexternalhit",
	:active => true
)

PublisherBillingConfig.create :commission => 10,
                              :minimal_payment => 5,
                              :payment_delay => 30,
                              :publisher_type => publisher_type

user = User.new :email => "advertiser@slytrade.com",
                :password => "slytrade",
                :password_confirmation => "slytrade",
                :enabled => true
user.add_role User::ADVERTISER
user.add_role User::ADMIN
user.save!
advertiser = Advertiser.new :company_name => "Test Advertiser",
                            :address => "Av. Paulista, 2202",
                            :city => "São Paulo",
                            :country => "Brazil",
                            :zip_code => "00000-000",
                            :phone => "+00(00)0000-0000",
                            :fax => "+00(00)0000-0000",
                            :site => "http://google.com",
                            :user => user
advertiser.save!

service = BillingService.new
service.create_advertiser_accounts advertiser

service.buy_package advertiser, package
service.confirm_advertiser_payment Transaction.all.last

category1 = Category.new :name_it => "Categoria 1",
                        :name_en => "Category 1",
                        :name_pt_BR => "Categoria 1",
                        :active => true

category2 = Category.new :name_it => "Categoria 2",
                        :name_en => "Category 2",
                        :name_pt_BR => "Categoria 2",
                        :active => true

campaign = Campaign.new :description => "Just do it.",
                        :name => "Sample Campaign",
                        :advertiser => advertiser,
                        :click_value => 0.25,
                        :start_date => Time.now + 1.second,
                        :end_date => Time.now + 1.year,
                        :markets => [it, br, us],
                        :post_times => [morning, evening],
                        :status => Campaign::SCHEDULED,
                        :budget => 1000

CampaignService.save campaign

Ad.create! :message => "Ad message1", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::G, :categories => [category1], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message2", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::G, :categories => [category1], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message3", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::G, :categories => [category1], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message4", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::G, :categories => [category2], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message5", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::G, :categories => [category2], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message6", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::G, :categories => [category2], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message7", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::G, :categories => [category1, category2], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message8", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::G, :categories => [category1, category2], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message9", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::G, :categories => [category1, category2], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message10", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::G, :categories => [category1, category2], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message11", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::G, :categories => [category1, category2], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message12", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::G, :categories => [category1, category2], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message13", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::PG, :categories => [category1], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message14", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::PG, :categories => [category2], :start_date => campaign.start_date, :end_date => campaign.end_date 
Ad.create! :message => "Ad message15", :link => "http://google.com", :picture_link => "http://paypersocial.com/images/home-slides/home-gb-slide2.png",:link_name => "slytrade",:link_caption => "Slytrade logo",:link_description => "link description text", :campaign => campaign, :visibilityrating => Ad::PG, :categories => [category1, category2], :start_date => campaign.start_date, :end_date => campaign.end_date 

Language.create :code => Language::EN, :name => "English"
Language.create :code => Language::IT, :name => "Italian"
Language.create :code => Language::PT_BR, :name => "Brazilian Portuguese"

Payment.create :payment_type => Payment::BANK_ACCOUNT,
               :description => "Bank NONONO, Branch 0000 Checking Account 12345678"

Term.create :title => "Super Terms",
            :ita => "",
            :eng => "You are allowed to be happy, no nagging is accept in any circumstances",
            :por => "",
            :enabled => true

Partner.create :lead_url => "http://google.com",
               :name => "Super Partner",
               :partner_tracking_code => "super"

Category.create :name_it => "Tecnologia",
                :name_en => "Technology",
                :name_pt_BR => "Tecnologia",
                :active => true

Coupon.create :name => "TestCoupon",
              :code => "TST0123456",
              :total => 100,
              :start_date => Time.now,
              :end_date => Time.now + 3.months,
              :amount => 5.00,
              :partner_id => 1
