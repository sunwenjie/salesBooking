require 'rails_helper'

RSpec.describe "events/new", :type => :view do
  before(:each) do
    assign(:event, Event.new(
      :name => "MyString",
      :notify_method => "MyString",
      :event_type => "MyString"
    ))
  end

  it "renders new event form" do
    render

    assert_select "form[action=?][method=?]", events_path, "post" do

      assert_select "input#event_name[name=?]", "event[name]"

      assert_select "input#event_notify_method[name=?]", "event[notify_method]"

      assert_select "input#event_event_type[name=?]", "event[event_type]"
    end
  end
end
