require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get airportSelect" do
    get :airportSelect
    assert_response :success
  end

  test "should get weatherDisplay" do
    get :weatherDisplay
    assert_response :success
  end

end
