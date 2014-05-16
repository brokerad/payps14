class AddLanguagesToTerms < ActiveRecord::Migration
  def self.up
    add_column :terms, :ita, :text
    add_column :terms, :eng, :text
    add_column :terms, :por, :text
    execute "UPDATE terms SET eng = content"
    remove_column :terms, :content
  end

  def self.down
    add_column :terms, :content, :text
    execute "UPDATE terms SET content = eng"
    remove_column :terms, :ita
    remove_column :terms, :eng
    remove_column :terms, :por
  end
end
