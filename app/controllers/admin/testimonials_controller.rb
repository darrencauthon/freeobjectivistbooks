class Admin::TestimonialsController < AdminController
  def load_models
    super
    if params[:source_type] && params[:source_id]
      klass = params[:source_type].constantize
      @source = klass.find params[:source_id]
    end
  end

  def index
    @testimonials = Testimonial.order('created_at desc')
  end

  def new
    @testimonial = if @source
      @source.to_testimonial
    else
      Testimonial.new
    end
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
