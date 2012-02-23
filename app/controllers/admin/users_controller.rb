class Admin::UsersController < AdminController
  def index
    @users = User.all
  end

  def update
    @user.attributes = params[:user]
    changed = @user.changed
    if save @user
      flash[:notice] = changed.any? ? "Updated #{changed.join ', '}" : "No changes."
      redirect_to [:admin, @user]
    else
      render :edit
    end
  end

  def spoof
    set_current_user @user
    redirect_to profile_url
  end

  def destroy
    logger.info "deleting user #{@user.name} (#{@user.id})"
    @user.destroy
    flash[:notice] = "#{@user.name} deleted."
    redirect_to action: :index
  end
end
