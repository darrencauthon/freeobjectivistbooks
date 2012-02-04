class TestController < ApplicationController
  def noop
    render nothing: true
  end

  def exception
    raise "Barf!"
  end
end
