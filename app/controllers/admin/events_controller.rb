class Admin::EventsController < AdminController
  def index
    @events = limit_and_offset Event.reverse_order
  end
end
