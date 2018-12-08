require "rails_helper"

RSpec.feature "Creating Survey" do
  scenario "A user creates a new survey" do
    visit "/"

    click_link "New Survey"
    fill_in "Title", with: "What is your fave Pokemon?"
    fill_in "Field 1", with: "Bulbasaur"
    fill_in "Field 2", with: "Squirtle"
    fill_in "Field 3", with: "Charmander"
    click_button "Create Survey"

    expect(page).to have_content("Survey has been created")
    expect(page.current_path).to eq(surveys_path)
  end
end
