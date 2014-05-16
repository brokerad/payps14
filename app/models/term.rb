class Term < ActiveRecord::Base

  validates :title, :presence => true

  before_update :check_enabled

  #before_validation :check_acceptance, :on => :update

  scope :enabled, lambda { where(:enabled => true) }

  default_scope :order => "enabled DESC"

  def default_language
    self.eng
  end

  def content
    default_language
  end

  def content_ita
    self.ita.blank? ? default_language : self.ita
  end

  def content_eng
    default_language
  end

  def content_por
    self.por.blank? ? default_language : self.por
  end

  private

  def self.current_enabled_term
    Term.enabled.first
  end

  def check_enabled
    if self.enabled && self.enabled_changed?
      # Get all to prevent concurrency
      terms = Term.where(:enabled => true).all
      terms.each do | term |
        term.enabled = false
        term.save
      end
    end
    true
  end

  def check_acceptance
    if (self.eng_changed? or self.ita_changed? or self.por_changed?) and Publisher.where(:accepted_term_id => self.id).first
      errors.add(:content, "This term was already accepted by a Publisher. You can't update an accepted term.")
    end
  end
end
