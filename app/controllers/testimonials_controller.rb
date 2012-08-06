class TestimonialsController < ApplicationController
  def index
    @testimonials = Testimonial.order('created_at desc')
  end

  def show
  end
end
