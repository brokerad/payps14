module Publisher::PostsHelper
  def find_or_initialize_post ad, place
    Post.find_or_initialize_by_ad_id_and_place_id :ad_id => ad.id, :place_id => place.id
  end
end
