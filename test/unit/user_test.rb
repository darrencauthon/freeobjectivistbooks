require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @howard = users :howard
    @hugh = users :hugh
    @quentin = users :quentin
    @john = User.new name: "John Galt", email: "galt@gulch.com", location: "Atlantis, CO", password: "dagny",
      password_confirmation: "dagny"
  end

  # Validations

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

  # Signup

  test "create" do
    assert @john.save
    assert User.exists? @john
  end

  test "password required on create" do
    @john.password = nil
    @john.password_confirmation = nil
    assert !@john.save
  end

  test "password confirmation required on create" do
    @john.password_confirmation = "oops"
    assert !@john.save
  end

  # Login

  test "password" do
    assert !@howard.authenticate("wrong")
    assert @howard.authenticate("roark")
  end

  test "login" do
    assert_equal @howard, User.login("roark@stanton.edu", "roark")
  end

  test "wrong password" do
    assert_nil User.login("roark@stanton.edu", "wrong")
  end

  test "wrong email" do
    assert_nil User.login("nobody@nowhere.com", "whatever")
  end

  # Associations

  test "requests" do
    assert_equal [requests(:howard_wants_atlas)], @howard.requests
  end

  test "pledges" do
    assert_equal [pledges(:hugh_5)], @hugh.pledges
  end

  test "donations" do
    assert_equal [requests(:quentin_wants_vos)], @hugh.donations
  end

  # Association dependencies

  test "dependent requests are destroyed" do
    request = @howard.requests.first
    @howard.destroy
    assert !Request.exists?(request)
  end

  test "dependent pledges are destroyed" do
    pledge = @hugh.pledges.first
    @hugh.destroy
    assert !Pledge.exists?(pledge)
  end

  test "dependent donations are nullified" do
    request = @hugh.donations.first
    @hugh.destroy
    assert Request.exists?(request)
    request.reload
    assert_nil request.donor
  end

  # Duplicates

  test "possible dupe?" do
    assert !@howard.possible_dupe?
    user = User.create! name: @howard.name, email: "something@else.com", location: "Somewhere", password: "asdf",
      password_confirmation: "asdf"
    assert user.possible_dupe?

    assert !@quentin.possible_dupe?
    user = User.create! name: "Something Else", email: @quentin.email, location: "Somewhere", password: "asdf",
      password_confirmation: "asdf"
    assert user.possible_dupe?
  end
end
