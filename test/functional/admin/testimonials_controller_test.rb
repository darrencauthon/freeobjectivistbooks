require 'test_helper'

class Admin::TestimonialsControllerTest < ActionController::TestCase
  def setup
    super
    @testimonial = testimonials :testimonial_1
    @new_testimonial = {title: "Title", text: "Some text here", attribution: "John Galt, Patrick Henry U."}
    admin_auth
  end

  # Index

  test "index" do
    get :index
    assert_response :success
    assert_select 'a', /add new/i
    assert_select '.testimonial', count: Testimonial.count
  end

  # New

  test "new" do
    get :new
    assert_response :success
    assert_select 'input[type="submit"]'
  end

  # Create

  test "create" do
    assert_difference "Testimonial.count" do
      post :create, testimonial: @new_testimonial
    end
    assert_redirected_to admin_testimonials_url
    assert_match /Created/, flash[:notice]
  end

  # Edit

  test "edit" do
    get :edit, id: @testimonial.id
    assert_response :success
    assert_select 'input#testimonial_title[value="Work of genius"]'
    assert_select 'input[type="submit"]'
  end

  # Update

  test "update" do
    put :update, id: @testimonial.id, testimonial: {title: "New Title", text: "New text", attribution: "New attribution"}
    assert_redirected_to admin_testimonials_url
    assert_match /Updated/, flash[:notice]

    @testimonial.reload
    assert_equal "New Title", @testimonial.title
  end

  # Destroy

  test "destroy" do
    assert_difference "Testimonial.count", -1 do
      delete :destroy, id: @testimonial.id
    end
    assert_redirected_to admin_testimonials_url
    assert !Testimonial.exists?(@testimonial)
  end
end
