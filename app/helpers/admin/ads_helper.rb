module Admin::AdsHelper

  # This helper makes the columns sortable
  def sortable(column, title=nil)
    title ||= column.tileize
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
    link_to title, :sort => column, :direction => direction
  end

  def get_qty_if_exists(hash, id, index)
    hash[id] ? hash[id][index].to_i : 0
  end
#   # This helper hides or show the select to change category for campaign
#   def hide_edit_category_if(condition, ad, &block)
#     # If campaign is not active I can edit assigned category
#     if condition
#       content_tag("div", :class => 'ad_'.concat(ad.id.to_s) ,&block)
#
#     # If campaign is active I show assigned category
#     else
#       unless ad.category_id.nil?
#         content_tag "p", ad.category.name_en
#       else
#         content_tag "p", "Not assigned"
#       end
#     end
#   end
end
