class Admin::PartnerReportsController < Admin::ApplicationController

  before_filter :init

  def index
    @partners = Partner.all
  end

  def index_publishers
    @publisher_criteria = Publisher.new(params[:publisher])
    @partner = Partner.find(params[:partner_id])
    criteria = []
    if !@publisher_criteria.created_at.nil? and !@publisher_criteria.updated_at.nil?
      criteria = ["created_at >= ? and created_at <= ?", @publisher_criteria.created_at, @publisher_criteria.updated_at]
    end
    @publishers = @partner.publishers.

    includes(:accepted_term, :publisher_facebooks => [:places]).
    includes(:tracking_url => :partner).where(criteria)

    respond_to do |format|
      format.html #publishers.html
      format.csv do
        csv_string = FasterCSV.generate do |csv|
          csv << ["id", "name", "email", "t&c", "type", "partner", "connections", "facebook engaged"]
          @publishers.each do |publisher|
            accepted_terms = "yes" if publisher.accepted_term == Term.current_enabled_term
            partner = publisher.partner_name if publisher.partner
            publisher_engaged = "yes" if publisher.engaged?
            csv << [publisher.id,
                    publisher.name,
                    publisher.email,
                    accepted_terms,
                    publisher.publisher_type.name,
                    partner,
                    publisher.connections,
                    publisher_engaged]
          end
        end
        send_data csv_string,
          :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=Publishers.csv"
      end
    end
  end

  def index_publishers_incomplete
    @publisher_criteria = Publisher.new(params[:publisher])
    @partner = Partner.find(params[:partner_id])
    criteria = []
    if !@publisher_criteria.created_at.nil? and !@publisher_criteria.updated_at.nil?
      criteria = ["created_at >= ? and created_at <= ?", @publisher_criteria.created_at, @publisher_criteria.updated_at]
    end
    @publishers = @partner.publishers.

    includes(:accepted_term, :publisher_facebooks => [:places]).
    includes(:tracking_url => :partner).where(criteria)

    respond_to do |format|
      format.html #publishers_incomplete.html
      format.csv do
        csv_string = FasterCSV.generate do |csv|
          csv << ["id", "name", "email", "t&c", "type", "partner", "connections", "facebook engaged"]
          @publishers.each do |publisher|
            accepted_terms = "yes" if publisher.accepted_term == Term.current_enabled_term
            partner = publisher.partner_name if publisher.partner
            publisher_engaged = "yes" if publisher.engaged?
            csv << [publisher.id,
                    publisher.name,
                    publisher.email,
                    accepted_terms,
                    publisher.publisher_type.name,
                    partner,
                    publisher.connections,
                    publisher_engaged]
          end
        end
        send_data csv_string,
          :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=Publishers_incomplete.csv"
      end
    end
  end

  def index_publishers_complete
    @publisher_criteria = Publisher.new(params[:publisher])
    @partner = Partner.find(params[:partner_id])
    criteria = []
    if !@publisher_criteria.created_at.nil? and !@publisher_criteria.updated_at.nil?
      criteria = ["created_at >= ? and created_at <= ?", @publisher_criteria.created_at, @publisher_criteria.updated_at]
    end
    # @publishers = @partner.publishers_complete.where(criteria).all
    @publishers = @partner.publishers.

    includes(:accepted_term, :publisher_facebooks => [:places]).
    includes(:tracking_url => :partner).where(criteria)

    respond_to do |format|
      format.html #publishers_complete.html
      format.csv do
        csv_string = FasterCSV.generate do |csv|
          csv << ["id", "name", "email", "t&c", "type", "partner", "connections", "facebook engaged"]
          @publishers.each do |publisher|
            accepted_terms = "yes" if publisher.accepted_term == Term.current_enabled_term
            partner = publisher.partner_name if publisher.partner
            publisher_engaged = "yes" if publisher.engaged?
            csv << [publisher.id,
                    publisher.name,
                    publisher.email,
                    accepted_terms,
                    publisher.publisher_type.name,
                    partner,
                    publisher.connections,
                    publisher_engaged]
          end
        end
        send_data csv_string,
          :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=Publishers_complete.csv"
      end
    end
  end

  private

  def init
    @current_enabled_term = Term.current_enabled_term
    @publisher_types = {}
    PublisherType.all.each { |pt| @publisher_types[pt.id] = pt }
  end
end
