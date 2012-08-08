class TestimonialsController < ApplicationController
  def load_models
    super
    @students = Testimonial.students.display_order
    @donors = Testimonial.donors.display_order
  end

  def index
    @students = @students.limit 5
    @donors = @donors.limit 5
  end
end
