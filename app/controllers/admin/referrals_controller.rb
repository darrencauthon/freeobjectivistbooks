class Admin::ReferralsController < AdminController
  def index
    @metrics = Metrics.new
  end
end
