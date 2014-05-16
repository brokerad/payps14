require "koala"

class PublisherFacebook < ActiveRecord::Base
  validates_presence_of :uid
  validates_presence_of :token
  validates_presence_of :email

  validates_uniqueness_of :token
  validates_uniqueness_of :uid

  belongs_to :publisher

  has_many :places, :dependent => :destroy
  has_many :places_enabled, :class_name => "Place", :conditions => ["enabled = ?", true], :order => "name"

  has_one :place_account, :class_name => "Place", :conditions => ["place_type = ?", Place::TYPE_ACCOUNT]

  def self.create_from_facebook_data(facebook_data)
    account_fb_token = facebook_data["credentials"]["token"]
    publisher_facebook = PublisherFacebook.find_or_initialize_by_uid facebook_data["uid"]
    publisher_facebook.token = account_fb_token if facebook_data["provider"] == 'facebook'
    publisher_facebook.token = account_fb_token if publisher_facebook.token.blank?
    publisher_facebook.facebook_data = facebook_data.to_json.to_s

    publisher_facebook.nickname   = facebook_data["info"]["nickname"]
    publisher_facebook.email      = facebook_data["info"]["email"]
    publisher_facebook.first_name = facebook_data["info"]["first_name"]
    publisher_facebook.last_name  = facebook_data["info"]["last_name"]
    publisher_facebook.name       = facebook_data["info"]["name"]
    publisher_facebook.image      = facebook_data["info"]["image"]
    publisher_facebook.birthday   = publisher_facebook.parse_fb_date(facebook_data["extra"])
    publisher_facebook.friends    = publisher_facebook.get_account_friends(publisher_facebook.token)
    publisher_facebook.providers  ||= ''
    unless publisher_facebook.providers.split(';').include?(facebook_data["provider"])
      publisher_facebook.providers = publisher_facebook.providers.split(';').push(facebook_data["provider"]).join(';')
    end
    publisher_facebook.save
    publisher_facebook.create_or_update_account_places(account_fb_token, facebook_data["provider"])
    publisher_facebook
  end

  def engaged?
    providers && providers.split(';').include?('facebook_post')
  end

  def publish(ad, post_source, place_param=nil, post_msg=nil)
    places = place_param ? [place_param] : self.places_enabled
    places.each do | place |
      graph = Koala::Facebook::API.new place.access_token

      post = Post.new
      post.likes = 0
      post.comments = 0
      post.link = ""
      post.place = place
      post.ad = ad
      post.source = post_source
      post.target_url = ad.link
      unless post.save
        raise post.errors.inspect
      end

      msg = post_msg.blank? ? ad.message : post_msg
      # In dev mode the address is stucked to www.paypersocial.com
      begin
        if Rails.env == 'development'
          post_data = graph.put_object("me", "feed",
                          :message => "--> #{post.url}\n--> #{post.image_url}\n--> #{msg}",
                          :link => 'http://www.payps.co',
                          :picture => ad.picture_link,
                          :name => ad.link_name,
                          :caption => ad.link_caption,
                          :description => ad.link_description)
        else
          post_data = graph.put_object("me", "feed",
                          :message => msg,
                          :link => post.url,
                          :picture => post.image_url,
                          :name => ad.link_name,
                          :caption => ad.link_caption,
                          :description => ad.link_description)
        end
      rescue
        # destroy post if share have not succeed
        post.destroy
        raise
      end

      post.reference_id = post_data["id"]
      unless post.save
        raise post.errors.inspect
      end

    end
  end

  def create_or_update_account_places(token, provider)
    create_or_update_account_place(token, provider == 'facebook_post')
    create_or_update_account_pages(token, provider == 'facebook_post')
  end

  def get_account_friends(access_token)
    graph = Koala::Facebook::API.new(access_token)
    graph.get_connections("me", "friends").size
  end

  def parse_fb_date(extra)
    if extra["user_hash"] && !extra["user_hash"]["birthday"].blank?
      Date.parse(extra["user_hash"]["birthday"])
    elsif extra["raw_info"] && !extra["raw_info"]["birthday"].blank?
      Date.parse(extra["raw_info"]["birthday"])
    end
  end

  def account_raw_info
    # new FB api use 'raw_info'; the old one 'user_hash'
    JSON.parse(facebook_data)["extra"]["user_hash"] || JSON.parse(facebook_data)["extra"]["raw_info"]
  end

  def create_or_update_account_pages(token, fb_post_provider)
    graph = Koala::Facebook::API.new(token)
    accounts = graph.get_connections("me", "accounts")
    accounts.each do | account |
      next if account["category"].to_s.downcase == "application"
      place = places.where(:uid => account["id"]).first || places.where(:name => account["name"], :uid => nil).first || Place.new
      access_token = account["access_token"]
      update_place(place, "Page", account["name"], 0, get_page_likes(access_token), access_token, fb_post_provider, account["id"])
    end


    remove_duplicate_places(accounts) if fb_post_provider
  end

  def facebook_email
    account_raw_info["username"].to_s + "@facebook.com"
  end

  private

  def get_page_likes(access_token)
    graph = Koala::Facebook::API.new(access_token)
    page_profile = graph.get_object("me")
    page_profile["likes"]
  end

  def create_or_update_account_place(token, fb_post_provider)
    place = places.where(:place_type => "Account").first
    unless place
      place = Place.new
      place.enabled = true
    end
    update_place(place, "Account", self.name, get_account_friends(token), 0, token, fb_post_provider, self.uid)
  end


  def update_place(place, type, name, friends, fans, access_token, fb_post_provider, uid)
    place.uid = uid
    place.place_type = type
    place.name = name
    place.friends = friends
    place.fans = fans
    place.access_token = access_token if fb_post_provider
    # place.publisher = self.publisher
    place.publisher_facebook = self
    place.save
  end

  def remove_duplicate_places(accounts)
    only_pages = places.reject{|p| p.place_type == "Account"}
    accs = accounts.map{|account| account["id"].to_s}

    puts "rrrrr #{accs.inspect}"
    only_pages.each do |page|
      unless accs.include?(page.uid.to_s)
        puts "rrrrr #{page.uid}"
        page.destroy if page.posts.count == 0
      end
    end
  end


  # def upadate_place_friends(place)
    # graph = Koala::Facebook::API.new place.access_token
    # if place.place_type == "Page"
      # page_profile = graph.get_object("me")
      # place.friends = page_profile["likes"]
    # elsif place.place_type == "Account"
      # user_friends = graph.get_connections("me", "friends")
      # place.friends = user_friends.size
    # end
    # place.save
  # end

  # def lookup_account graph
    # place = find_from_token self.token
    # return place if place
    # self.places << Place.create(:place_type => "Account",
    # :name => self.name,
    # :friends => 0,
    # :fans => 0,
    # :publisher_facebook => self,
    # :publisher => self.publisher,
    # :access_token => self.token)
  # end

  # def self.update_account_token publisher_facebook
    # # Have a look at http://stackoverflow.com/questions/7628952/omniauth-facebook-expired-token-error
    # account = publisher_facebook.place_account
    # if account
      # account.update_attributes :access_token => publisher_facebook.token
    # end
  # end
end
