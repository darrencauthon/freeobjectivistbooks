module RequestsHelper
  def current_is_donor?
    @current_user == @request.donor
  end

  def current_is_student?
    @current_user == @request.user
  end

  def other_user
    current_is_student? ? @request.donor : @request.user
  end
end
