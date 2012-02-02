class Admin::UsersController < AdminController
  def load_models
    @user = User.find params[:id] if params[:id]
  end

  def index
    @users = User.order('created_at desc')
  end

  def update
    @user.attributes = params[:user]
    changed = @user.changed
    if @user.save
      flash[:notice] = changed.any? ? "Updated #{changed.join ', '}" : "No changes."
      redirect_to [:admin, @user]
    else
      render :edit
    end
  end

  def destroy
    logger.info "deleting user #{@user.name} (#{@user.id})"
    @user.destroy
    flash[:notice] = "#{@user.name} deleted."
    redirect_to action: :index
  end
end
