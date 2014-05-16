require 'spec_helper'

describe Admin::CategoriesController do
  login_admin

  describe "POST create" do
    describe "with valid params" do
      it "should create a new instance" do
        category = Category.new(  :name_it => 'NomeCategoria',
                                  :name_en => 'CategoryName',
                                  :name_pt_BR => 'NomeCategoria',
                                  :active => true )

        category.should be_an_instance_of Category
        category.save.should be_true
      end
    end

    describe "with NOT valid params" do
      it "should NOT create a new instance" do
        category = Category.new(:name_it => 'NomeCategoria')
        category.save.should be_false
      end
    end
  end

  describe "GET activate" do
    it "should activate a category" do
      category = Category.new(  :name_it => 'NomeCategoria',
                                :name_en => 'CategoryName',
                                :name_pt_BR => 'NomeCategoria',
                                :active => false )
      category.save
      get :activate, :id => category.id
      category.reload
      category.active.should be_true
    end
  end

end
