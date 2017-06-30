require 'rails_helper'

RSpec.describe "events/show", :type => :view do
  before(:each) do
    @event = assign(:event, Event.create!(
      :name => "Name",
      :notify_method => "Notify Method",
      :event_type => "Event Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Notify Method/)
    expect(rendered).to match(/Event Type/)
  end
end
