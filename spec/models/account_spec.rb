require 'spec_helper'

describe Account do
  it "should create new account with empty parent" do
    acc = Factory(:root_account)
    acc.parent.should be_nil
  end

  it "should create new account with no children" do
    acc = Factory(:root_account)
    acc.children.should be_empty
  end

  it "should accept valid nature" do
    nature = Account.valid_natures.shuffle[0]
    acc = Factory(:root_account, :nature => nature)
    acc.nature.should be_equal(nature)
  end

  it "should raise error on invalid nature" do
    lambda {
      Factory(:root_account, :nature => "invalid nature")
    }.should raise_error
  end

  it "should not allow accounts with the same name in the same parent" do
    root = Factory(:root_account)
    name = "account name"
    acc1 = Factory(:account, :name => name, :parent => root)

    lambda {
      acc2 = Factory(:account, :name => name, :parent => root)
    }.should raise_error
  end

  it "should allow accounts with the same name in different parents" do
    root = Factory(:root_account)
    name = "account name"
    acc1 = Factory(:account, :name => name, :parent => root)

    lambda {
      acc2 = Factory(:account, :name => name, :parent => acc1)
    }.should_not raise_error
  end

  it "should have access the to children accounts" do
    root = Factory(:root_account)
    acc1 = Factory(:account, :parent => root)
    root.children.should eq [acc1]
  end

  it "should return nil if it doesn't find a account in the children list" do
    child_name = "child"
    wrong_child_name = "child2"
    root = Factory(:root_account)
    acc1 = Factory(:account, :name => child_name, :parent => root)
    root.child(wrong_child_name).should be_nil
  end

  it "should not allow delete when account has a child account" do
    root = Factory(:root_account, :name => "root_to_delete")
    acc1 = Factory(:account, :name => "child_to_delete", :parent => root)
    Account.where(:id => root.id).count.should eq 1
    Account.where(:id => acc1.id).count.should eq 1
    lambda {
      root.destroy
    }.should raise_error
  end
end
