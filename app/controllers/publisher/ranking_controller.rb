class Publisher::RankingController < Publisher::ApplicationController
  
  #TODO: refactor it as soon as possible
  def index
    @publishers_by_clicks = ActiveRecord::Base.connection.execute("
     SELECT publishers.id, publishers.first_name, COUNT(*) AS clicks
      FROM tracking_requests
        JOIN posts ON (tracking_requests.post_id = posts.id)
        JOIN places ON (posts.place_id = places.id)
        JOIN publisher_facebooks ON (publisher_facebooks.id = places.publisher_facebook_id)
        JOIN publishers ON (publishers.id = publisher_facebooks.publisher_id)
      WHERE tracking_requests.status = 'PAYABLE'
      GROUP BY publishers.id
      ORDER BY clicks DESC
      LIMIT 10
    ").entries
    @publishers_by_posts = ActiveRecord::Base.connection.execute("
      SELECT publishers.id, publishers.first_name, COUNT(*) AS posts_qty
      FROM posts
        JOIN places ON (posts.place_id = places.id)
        JOIN publisher_facebooks ON (publisher_facebooks.id = places.publisher_facebook_id)
        JOIN publishers ON (publishers.id = publisher_facebooks.publisher_id)
      GROUP BY publishers.id
      ORDER BY posts_qty DESC
      LIMIT 10
    ").entries
    @publishers_by_ctr = ActiveRecord::Base.connection.execute("
      SELECT q.publisher_id, q.first_name, q.tracking_request_qty / q.post_qty AS ctr
      FROM (SELECT publishers.id AS publisher_id,
                   publishers.first_name, 
                   COUNT(*) AS tracking_request_qty,
                   COUNT(DISTINCT posts.id) AS post_qty
            FROM tracking_requests
              JOIN posts ON (tracking_requests.post_id = posts.id)
              JOIN places ON (posts.place_id = places.id)
              JOIN publisher_facebooks ON (publisher_facebooks.id = places.publisher_facebook_id)
              JOIN publishers ON (publishers.id = publisher_facebooks.publisher_id)
              WHERE tracking_requests.status = 'PAYABLE'
              GROUP BY publishers.id) AS q
              ORDER BY ctr DESC
      LIMIT 10
    ").entries
    @current_data = ActiveRecord::Base.connection.execute("
          SELECT q.publisher_id, q.first_name, q.tracking_request_qty as clicks, q.post_qty, q.tracking_request_qty / q.post_qty AS ctr
          FROM (SELECT publishers.id AS publisher_id,
                   publishers.first_name, 
                   COUNT(*) AS tracking_request_qty,
                   COUNT(DISTINCT posts.id) AS post_qty
            FROM tracking_requests
              JOIN posts ON (tracking_requests.post_id = posts.id)
              JOIN places ON (posts.place_id = places.id)
              JOIN publisher_facebooks ON (publisher_facebooks.id = places.publisher_facebook_id)
              JOIN publishers ON (publishers.id = publisher_facebooks.publisher_id)
            WHERE tracking_requests.status = 'PAYABLE'
            AND publishers.id = #{current_publisher.id}
            GROUP BY publishers.id) AS q 
      ORDER BY ctr DESC").entries 
    @current_data = @current_data.first
    @current_data ||= {}
  end
end
