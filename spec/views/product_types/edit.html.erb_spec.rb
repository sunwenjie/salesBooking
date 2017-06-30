require 'rails_helper'

RSpec.describe "product_types/edit", :type => :view do
  before(:each) do
    @product_type = assign(:product_type, ProductType.create!(
      :name => "MyString",
      :ad_platform => "MyString",
      :ad_type => "MyString"
    ))
  end

  it "renders the edit product_type form" do
    render

    assert_select "form[action=?][method=?]", product_type_path(@product_type), "post" do

      assert_select "input#product_type_name[name=?]", "product_type[name]"

      assert_select "input#product_type_ad_platform[name=?]", "product_type[ad_platform]"

      assert_select "input#product_type_ad_type[name=?]", "product_type[ad_type]"
    end
  end
end
