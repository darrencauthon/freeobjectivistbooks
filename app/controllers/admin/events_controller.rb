class Admin::EventsController < AdminController
  def index
    @event_count = Event.count
    @events = Event.order('created_at desc')
  end
end
