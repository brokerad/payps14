require 'json'

class Admin::PublishersController < Admin::ApplicationController
  def index
    unless params[:filter_partner] && params[:filter_status] && params[:filter_date]
      @publishers = Publisher.publishers_details(params[:search]).page params[:page]
      @number_of_publishers = Publisher.publishers_details_count(params[:search])
    end

    if params[:filter_partner]
      @publishers = Publisher.all_publishers_from_partner(params[:filter_partner]).page params[:page]
      @number_of_publishers = Publisher.all_publishers_from_partner_count(params[:filter_partner])
    end

    if params[:filter_status]
      if params[:filter_status] == 'accepted_terms'
        @publishers = Publisher.all_publishers_accepted_terms.page params[:page]
        @number_of_publishers = Publisher.total_publishers_accepted_terms
      end
      if params[:filter_status] == 'fb_engaged'
        @publishers = Publisher.all_publishers_engaged.page params[:page]
        @number_of_publishers = Publisher.total_publishers_engaged
      end
      if params[:filter_status] == 'not_accepted_terms'
        @publishers = Publisher.all_publishers_not_accepted_terms.page params[:page]
        @number_of_publishers = Publisher.total_publishers_not_accepted_terms
      end
    end

    if params[:filter_account_type]
      @publishers = Publisher.all_publishers_type(params[:filter_account_type]).page params[:page]
      @number_of_publishers = Publisher.all_publishers_type_count(params[:filter_account_type])
    end

    if params[:filter_traffic_manager]
      @current_traffic_manager = User.find(params[:filter_traffic_manager])
      @publishers = Publisher.all_publishers_for_traffic_manager(params[:filter_traffic_manager]).page params[:page]
      @number_of_publishers = Publisher.all_publishers_for_traffic_manager_count(params[:filter_traffic_manager])
    end

    if (params[:filter_date_from] && params[:filter_date_to])
      start_date = Date.new(params[:filter_date_from][:year].to_i, params[:filter_date_from][:month].to_i, params[:filter_date_from][:day].to_i)
      end_date = Date.new(params[:filter_date_to][:year].to_i, params[:filter_date_to][:month].to_i, params[:filter_date_to][:day].to_i)
      @publishers = Publisher.all_publishers_registered(start_date, end_date).page params[:page]
      @number_of_publishers = Publisher.all_publishers_registered_count(start_date, end_date)
    end

    if params[:filter_rs]
      @publishers = RevenueShare.find(params[:filter_rs]).publishers.page params[:page]
      @number_of_publishers = @publishers.count
    end

    @fb_publishers = {}
    Publisher.get_fb_account(@publishers).map{ |_pub| @fb_publishers[_pub.publisher_id] = _pub }
    @publishers.instance_eval <<-EVAL
      def total_pages
        #{(@number_of_publishers/Kaminari.config.default_per_page).to_i + 1}
      end
    EVAL
    @partner = Partner.all
    @traffic_manager = User.where("role LIKE '%admin%'")
    @account_type = PublisherType.all
    respond_to do |format|
      format.html #publishers.html
      format.csv do
        csv_string = FasterCSV.generate do |csv|
          csv << ["id", "name", "facebook link", "t&c", "fb-e", "email", "partner", "connections", "friends", "created at"]
          @publishers.each do |publisher|
            accepted_terms = "yes" if publisher["accepted_last_term"] == 't'
            publisher_engaged = "yes" if publisher.engaged?
            facebook_link = get_facebook_link @fb_publishers[publisher.id]
            csv << [publisher["id"],
                    publisher.name,
                    facebook_link,
                    accepted_terms,
                    publisher_engaged,
                    publisher["email"],
                    publisher["partner_name"],
                    publisher["total_connections"],
                    publisher["friends"],
                    l(publisher["created_at"])]
          end
        end
        send_data csv_string,
          :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=Publishers.csv"
      end
    end
  end

  def edit
    @publisher = Publisher.find(params[:id])
  end

  def update
    @publisher = Publisher.find(params[:id])
    if @publisher.update_attributes(params[:publisher])
      redirect_to(admin_publishers_path, :notice => I18n.t("publisher.updated.success"))
    else
      render :action => "edit"
    end
  end

  def show
    @publisher = Publisher.find(params[:id])
  end


  def login_as_publisher
    publisher = Publisher.find(params[:publisher_id])
    result = UserSession.create(publisher.user)
    if result.errors.blank?
      flash[:success] = I18n.t("login.successful")
    else
      flash[:error] = I18n.t("login.failed") << result.errors.full_messages[0] unless result.errors.empty?
      logger.debug("ERROR: admin tries to login as publisher; message: #{result.errors.inspect}")
    end
    redirect_to publisher_root_path
  end

  # DELETE FROM users WHERE email = '#{self.email}';
  # DELETE FROM publishers WHERE user_id NOT in (SELECT id FROM users);
  # DELETE FROM places WHERE publisher_id NOT in (SELECT id FROM publishers);
  # DELETE FROM posts WHERE place_id NOT in (SELECT id FROM places);
  # DELETE FROM tracking_requests WHERE post_id NOT in (SELECT id FROM posts);

  #TODO: commented publisher destroy before we decide how it should behave
  # !!! it is very important to not loose information

  def destroy
    # @publisher = Publisher.find(params[:id])
    # if @publisher.user.role?(User::ADMIN)
      # @publisher.user.remove_role User::PUBLISHER
      # Publisher.delete "user_id = #{@publisher.user.id}"
    # else
      # User.delete_all "email = '#{@publisher.email}'"
      # Publisher.delete_all "user_id NOT IN (SELECT id FROM users)"
    # end
    # Place.delete_all "publisher_id NOT IN (SELECT id FROM publishers)"
    # Post.delete_all "place_id NOT IN (SELECT id FROM places)"
    # TrackingRequest.delete_all "post_id NOT IN (SELECT id FROM posts)"
    # ActiveRecord::Base.connection.execute "
      # DELETE FROM accounts
        # WHERE parent_id IN (13, 14, 19)
        # AND NOT EXISTS (SELECT 1
          # FROM publishers
          # WHERE CAST(accounts.name AS INTEGER) = publishers.id)"
		# redirect_to(admin_publishers_path, :notice => I18n.t("publisher.deleted.success"))
		redirect_to(admin_publishers_path, :notice => "Publisher deletion is NOT implemented!!!")
  end
end

def get_facebook_link fb_publisher
  user_hash = fb_publisher.account_raw_info if fb_publisher
  if user_hash && user_hash["link"]
    user_hash["link"]
  else
    "No link"
  end
end

