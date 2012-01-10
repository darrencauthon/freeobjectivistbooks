class Admin::UsersController < AdminController
  def load_models
    @user = User.find_by_id params[:id]
  end

  def destroy
    @user.destroy
    flash[:message] = "#{@user.name} deleted."
    redirect_to admin_url
  end
end
