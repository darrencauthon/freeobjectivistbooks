class Admin::EventsController < AdminController
  def index
    @events = Event.reverse_order
    @event_count = @events.count
  end
end
