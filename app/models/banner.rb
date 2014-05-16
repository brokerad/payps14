class Banner < ActiveRecord::Base
  SIGN_UP = 0
  SIGN_IN = 1
  ENGAGE_LEFT = 2
  ENGAGE_RIGHT = 3
  PUBLISHER_FACEBOOK_SIDEBAR = 4
  PUBLISHER_DASHBOARD_TOP = 5
  PUBLISHER_FACEBOOK_CANVAS_TOP = 6
  PAGES = { SIGN_UP => "Sign Up",  
            SIGN_IN => "Sign In", 
            ENGAGE_LEFT => "Engage left", 
            ENGAGE_RIGHT => "Engage right", 
            PUBLISHER_FACEBOOK_SIDEBAR => "Publisher Facebook canvas sidebar", 
            PUBLISHER_DASHBOARD_TOP => "Publisher dashboard top",
            PUBLISHER_FACEBOOK_CANVAS_TOP => "Publisher Facebook canvas top" }
  belongs_to :language
  attr_accessible :page, :name, :active, :language_id, :target_url, :image
  mount_uploader :image, BannerUploader
  validates :name, :page, :image, :language_id, :presence => true
  validates :language_id, :uniqueness => {:scope => :page}  # this will validate the uniqueness of page/lang combination
  validates :target_url, :allow_blank => true, :format => {:with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix} if :target_url?
  
  def self.get_banner page, lang
    Banner.joins(:language).where('page = ? AND languages.code = ? AND active = TRUE', page, lang).first
  end
end
