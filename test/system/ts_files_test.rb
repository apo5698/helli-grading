require "application_system_test_case"

class TsFilesTest < ApplicationSystemTestCase
  setup do
    @ts_file = ts_files(:one)
  end

  test "visiting the index" do
    visit ts_files_url
    assert_selector "h1", text: "Ts Files"
  end

  test "creating a Ts file" do
    visit ts_files_url
    click_on "New Ts File"

    click_on "Create Ts file"

    assert_text "Ts file was successfully created"
    click_on "Back"
  end

  test "updating a Ts file" do
    visit ts_files_url
    click_on "Edit", match: :first

    click_on "Update Ts file"

    assert_text "Ts file was successfully updated"
    click_on "Back"
  end

  test "destroying a Ts file" do
    visit ts_files_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Ts file was successfully destroyed"
  end
end
