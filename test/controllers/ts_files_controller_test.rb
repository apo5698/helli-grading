require 'test_helper'

class TsFilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ts_file = ts_files(:one)
  end

  test "should get index" do
    get ts_files_url
    assert_response :success
  end

  test "should get new" do
    get new_ts_file_url
    assert_response :success
  end

  test "should create ts_file" do
    assert_difference('TsFile.count') do
      post ts_files_url, params: {ts_file: {}}
    end

    assert_redirected_to ts_file_url(TsFile.last)
  end

  test "should show ts_file" do
    get ts_file_url(@ts_file)
    assert_response :success
  end

  test "should get edit" do
    get edit_ts_file_url(@ts_file)
    assert_response :success
  end

  test "should update ts_file" do
    patch ts_file_url(@ts_file), params: {ts_file: {}}
    assert_redirected_to ts_file_url(@ts_file)
  end

  test "should destroy ts_file" do
    assert_difference('TsFile.count', -1) do
      delete ts_file_url(@ts_file)
    end

    assert_redirected_to ts_files_url
  end
end
