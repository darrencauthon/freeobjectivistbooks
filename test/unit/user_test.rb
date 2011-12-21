require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @howard = users :howard
    @john = User.new name: "John Galt", email: "galt@gulch.com", location: "Atlantis, CO", password: "dagny",
      password_confirmation: "dagny"
  end

  test "howard is valid" do
    assert @howard.valid?
  end

  test "name is required" do
    @howard.name = nil
    assert @howard.invalid?
  end

  test "email is required" do
    @howard.email = nil
    assert @howard.invalid?
  end

  test "location is required" do
    @howard.location = nil
    assert @howard.invalid?
  end

  test "student fields are not required" do
    @howard.school = nil
    @howard.studying = nil
    assert @howard.valid?
  end

  test "password" do
    assert !@howard.authenticate("wrong")
    assert_equal @howard, @howard.authenticate("roark")
  end

  test "create" do
    assert @john.save
    assert User.exists? @john
  end

  test "password confirmation required on create" do
    @john.password_confirmation = "oops"
    assert !@john.save
  end
end
