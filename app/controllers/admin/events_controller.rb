class Admin::EventsController < AdminController
  def index
    @events = Event.all
    @event_count = @events.count
  end
end
