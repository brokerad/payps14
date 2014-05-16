class Publisher::AdsSearchController < Publisher::ApplicationController

  # Implementing a very simple Search functionality
  # HINT: a more powerfull search could be performed through Sphinx (http://sphinxsearch.com/) and the relative gem Thinking Sphinx (http://freelancing-god.github.com/ts/en/installing_thinking_sphinx.html)
  def index
    # Getting search terms
     @search_term = params[:keywords]
     @current_category = session[:filter_category]

    # Simple search for search_term in: link_description, message, link_name, link_caption,
    if @search_term
      @ads_available = Ad.filter_ads(current_publisher, @current_category, @search_term)
    else
      @ads_available = Ad.filter_ads(current_publisher, @current_category)
    end

    @results_count = @ads_available.count
    @categories = Category.where("active = ? ", true)
  end
end
