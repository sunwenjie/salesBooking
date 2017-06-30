require 'rails_helper'

RSpec.describe "product_types/show", :type => :view do
  before(:each) do
    @product_type = assign(:product_type, ProductType.create!(
      :name => "Name",
      :ad_platform => "Ad Platform",
      :ad_type => "Ad Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Ad Platform/)
    expect(rendered).to match(/Ad Type/)
  end
end
