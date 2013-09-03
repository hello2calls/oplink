require 'test_helper'

class OpusControllerTest < ActionController::TestCase
  setup do
    @opu = opus(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:opus)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create opu" do
    assert_difference('Opu.count') do
      post :create, opu: { activation_date: @opu.activation_date, customer_id: @opu.customer_id, expiration_date: @opu.expiration_date, sn: @opu.sn }
    end

    assert_redirected_to opu_path(assigns(:opu))
  end

  test "should show opu" do
    get :show, id: @opu
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @opu
    assert_response :success
  end

  test "should update opu" do
    put :update, id: @opu, opu: { activation_date: @opu.activation_date, customer_id: @opu.customer_id, expiration_date: @opu.expiration_date, sn: @opu.sn }
    assert_redirected_to opu_path(assigns(:opu))
  end

  test "should destroy opu" do
    assert_difference('Opu.count', -1) do
      delete :destroy, id: @opu
    end

    assert_redirected_to opus_path
  end
end
