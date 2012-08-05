class Admin::TestimonialsController < AdminController
  def index
    @testimonials = Testimonial.order('created_at desc')
  end

  def new
    @testimonial = Testimonial.new
    render :edit
  end

  def create
    @testimonial = Testimonial.new params[:testimonial]
    if @testimonial.save
      flash[:notice] = "Created \"#{@testimonial.title}\""
      redirect_to admin_testimonials_url
    else
      render :edit
    end
  end

  def edit
  end

  def update
    @testimonial.update_attributes params[:testimonial]
    if @testimonial.save
      flash[:notice] = "Updated \"#{@testimonial.title}\""
      redirect_to admin_testimonials_url
    else
      render :edit
    end
  end

  def destroy
    @testimonial.destroy
    flash[:notice] = "Deleted \"#{@testimonial.title}\""
    redirect_to admin_testimonials_url
  end
end
