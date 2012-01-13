class Admin::UsersController < AdminController
  def load_models
    @user = User.find_by_id params[:id]
  end

  def destroy
    logger.info "deleting user #{@user.name} (#{@user.id})"
    @user.destroy
    flash[:notice] = "#{@user.name} deleted."
    redirect_to admin_url
  end
end
