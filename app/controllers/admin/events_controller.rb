class Admin::EventsController < AdminController
  def parse_params
    @public_thanks = params[:public_thanks].to_bool
  end

  def index
    @events = Event.reverse_order
    @events = @events.public_thanks if @public_thanks
    @events = limit_and_offset @events
  end
end
