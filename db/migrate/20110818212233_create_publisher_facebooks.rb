class CreatePublisherFacebooks < ActiveRecord::Migration
  def self.up
    create_table :publisher_facebooks do |t|
      t.string :uid # uid
      t.string :token # credentials:token
      t.string :nickname # user_info:nickname
      t.string :email # user_info:email
      t.string :first_name # user_info:first_name
      t.string :last_name # user_info:last_name
      t.string :name # user_info:name
      t.string :image # user_info:image
      t.string :link # extra:user_hash:link
      t.references :publisher
      t.timestamps
    end
  end

  def self.down
    drop_table :publisher_facebooks
  end
end