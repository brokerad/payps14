class Admin::PublisherPendingAmountController < Admin::ApplicationController
  def index
    #@publishers = Publisher.last_publishers_with_posts.page params[:page]
    @publishers = Publisher.where('id < 1').page params[:page] # This query will force to have an empty initial @publishers
    respond_to do |format| 
      format.html do
        render :index
      end
      format.csv do 
        redirect_to admin_publisher_pending_amount_path
      end
    end
  end

  def search
    search_keyword = params[:search]
    @publishers = Publisher.publishers_with_posts.search_by_keyword(search_keyword).page params[:page]
    respond_to do |format| 
      format.html do
        render :index
      end
      format.csv do 
        csv_string = generate_csv_for @publishers
        send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', 
          :disposition => "attachment; filename=Publishers_pending_amount.csv" 
      end
    end
  end

  def filter    
    case params[:filter]
      when "greater_than"
        @publishers = Publisher.publishers_with_posts_amount_greater_than(params[:amount].to_f).page params[:page]
      when "less_than"
        @publishers = Publisher.publishers_with_posts_amount_less_than(params[:amount].to_f).page params[:page]        
      when "equal_to"
        @publishers = Publisher.publishers_with_posts_amount_equal_to(params[:amount].to_f).page params[:page]        
    end
    respond_to do |format| 
      format.html do
        render :index
      end
      format.csv do 
        csv_string = generate_csv_for @publishers
        send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', 
          :disposition => "attachment; filename=Publishers_pending_amount.csv" 
      end
    end
  end
  
  def show
    @publishers = Publisher.all
  end
  
  def generate_csv_for publishers
    csv_string = FasterCSV.generate do |csv| 
      csv << ["id", "name", "amount", "ad published", "clicks", "posts"] 
      publishers.each do |publisher|  
        csv << [publisher.id, 
                publisher["first_name"] + " " + publisher["last_name"], 
                currency_format(publisher.pending_amount),
                publisher.ads_published_count,
                publisher.clicks_count,
                publisher.posts_count]
      end 
    end
    csv_string
  end
end
