class AutoCancelOldRequests < Spinach::FeatureSteps

  Spinach.hooks.before_scenario do |s|
    Request.delete_all
  end

  Spinach.hooks.after_scenario do |s|
    Timecop.return
  end

  Given 'a request for a book was made' do
    @request = Request.create!(reason: 'I want to read it.',
                               pledge: "1")
  end

  And 'three months passed' do
    Timecop.travel(Date.today + 30)
  end

  When 'requests are checked' do
    pending 'step not implemented'
  end

  Then 'the request should be canceled' do
    pending 'step not implemented'
  end

  And 'a notification should be sent to the user' do
    pending 'step not implemented'
  end
end
