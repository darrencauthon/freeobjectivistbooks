require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    super
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

  test "name must be two words" do
    @john.name = "John"
    assert @john.invalid?
    assert_match /first and last/, @john.errors[:name].first
  end

  test "name can't be all caps" do
    @john.name = "JOHN GALT"
    assert @john.invalid?
    assert_match /ALL CAPS/, @john.errors[:name].first
    assert_equal "John Galt", @john.name
  end

  test "name can't be all lowercase" do
    @john.name = "john galt"
    assert @john.invalid?
    assert_match /capitalization/, @john.errors[:name].first
    assert_equal "John Galt", @john.name
  end

  # Callbacks

  test "email is normalized on save" do
    @john.email = "john@galt.com "
    @john.save!
    assert_equal "john@galt.com", @john.email
  end

  test "name is normalized on save" do
    @john.name = " John  Galt   "
    @john.save!
    assert_equal "John Galt", @john.name
  end

  # Finders

  test "find by email" do
    assert_equal @howard, User.find_by_email(@howard.email)
    assert_equal @howard, User.find_by_email(@howard.email.upcase)
    assert_equal @howard, User.find_by_email(@howard.email.downcase)
    assert_nil User.find_by_email("nobody@nowhere.com")
  end

  test "donors with unsent books" do
    verify_scope User, :donors_with_unsent_books do |user|
      user.donations.active.any? {|donation| donation.can_send?}
    end
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

  # Update detail

  test "update detail: added name" do
    @dagny.name = "Dagny Taggart"
    assert_equal "added their full name", @dagny.update_detail
  end

  test "update detail: added address" do
    @dagny.address = "123 Somewhere"
    assert_equal "added a shipping address", @dagny.update_detail
  end

  test "update detail: updated info" do
    @quentin.address = "New Address"
    assert_equal "updated shipping info", @quentin.update_detail
  end

  # Reset password

  test "reset password" do
    assert @howard.reset_password(password: "newpw", password_confirmation: "newpw")
    assert User.find(@howard).authenticate("newpw")
  end

  test "reset password can't be blank" do
    assert !@howard.reset_password(password: "", password_confirmation: "")
    assert @howard.errors[:password].any?
    assert !User.find(@howard).authenticate("")
  end

  test "reset password confirmation must match" do
    assert !@howard.reset_password(password: "newpw", password_confirmation: "oops")
    assert @howard.errors[:password].any?
    assert !User.find(@howard).authenticate("newpw")
  end

  # Associations

  test "requests" do
    assert_equal [requests(:howard_wants_atlas)], @howard.requests
  end

  test "pledges" do
    assert_equal [pledges(:hugh_pledge)], @hugh.pledges
  end

  test "donations" do
    assert @hugh.donations.any?
    @hugh.donations.each {|donation| assert_equal @hugh, donation.user}
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

  # Letmein

  test "letmein" do
    params = @howard.letmein_params
    assert_equal @howard.id, params[:id]
    assert_equal :valid, @howard.letmein?(params)
  end

  test "letmein invalid" do
    params = @howard.invalid_letmein_params
    assert_equal :invalid, @howard.letmein?(params)
  end

  test "letmein expired" do
    params = @howard.expired_letmein_params
    assert_equal :expired, @howard.letmein?(params)
  end
end
