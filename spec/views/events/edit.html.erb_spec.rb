require 'rails_helper'

RSpec.describe "events/edit", :type => :view do
  before(:each) do
    @event = assign(:event, Event.create!(
      :name => "MyString",
      :notify_method => "MyString",
      :event_type => "MyString"
    ))
  end

  it "renders the edit event form" do
    render

    assert_select "form[action=?][method=?]", event_path(@event), "post" do

      assert_select "input#event_name[name=?]", "event[name]"

      assert_select "input#event_notify_method[name=?]", "event[notify_method]"

      assert_select "input#event_event_type[name=?]", "event[event_type]"
    end
  end
end
