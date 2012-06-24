class Admin::EventsController < AdminController
  def parse_params
    @testimonials = params[:testimonials].to_bool
  end

  def index
    @events = Event.reverse_order
    @events = @events.testimonials if @testimonials
    @events = limit_and_offset @events
  end
end
