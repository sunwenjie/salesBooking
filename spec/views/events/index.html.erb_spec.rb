require 'rails_helper'

RSpec.describe "events/index", :type => :view do
  before(:each) do
    assign(:events, [
      Event.create!(
        :name => "Name",
        :notify_method => "Notify Method",
        :event_type => "Event Type"
      ),
      Event.create!(
        :name => "Name",
        :notify_method => "Notify Method",
        :event_type => "Event Type"
      )
    ])
  end

  it "renders a list of events" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Notify Method".to_s, :count => 2
    assert_select "tr>td", :text => "Event Type".to_s, :count => 2
  end
end
