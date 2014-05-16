module Publisher::ApplicationHelper

  # Load categories if needed
  def load_categories_if (condition)
    if condition
      if session[:current_category]
        current_category = session[:current_category]
      else
        current_category = :all
      end
      @categories = Category.find(current_category)
    end
  end

  # Set the categy active when showing a filtered ads results
  def set_link_active (category_active, category, current_publisher)

    # Get the name label for the publisher's language
    lable = category.get_category_name_for_publisher current_publisher

    if category.id.to_i == category_active.to_i
      link_to lable, publisher_filter_category_path(category.id), :class => 'active'
    else
      link_to lable, publisher_filter_category_path(category.id)
    end
  end
  
  def markets_hash
    @markets_hash ||= Market.all.collect {|m| [m.name, m.id]}
  end
end
