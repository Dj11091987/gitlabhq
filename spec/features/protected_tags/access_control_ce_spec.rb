RSpec.shared_examples "protected tags > access control > CE" do
  ProtectedTag::PushAccessLevel.human_access_levels.each do |(access_type_id, access_type_name)|
    it "allows creating protected tags that #{access_type_name} can push to" do
      visit namespace_project_protected_tags_path(project.namespace, project)
      set_protected_tag_name('master')
      within('.new_protected_tag') do
        allowed_to_push_button = find(".js-allowed-to-push")

        unless allowed_to_push_button.text == access_type_name
          allowed_to_push_button.click
          within(".dropdown.open .dropdown-menu") { click_on access_type_name }
        end
      end
      click_on "Protect"

      expect(ProtectedTag.count).to eq(1)
      expect(ProtectedTag.last.push_access_levels.map(&:access_level)).to eq([access_type_id])
    end

    it "allows updating protected tags so that #{access_type_name} can push to them" do
      visit namespace_project_protected_tags_path(project.namespace, project)
      set_protected_tag_name('master')
      click_on "Protect"

      expect(ProtectedTag.count).to eq(1)

      within(".protected-tags-list") do
        find(".js-allowed-to-push").click
        
        within('.js-allowed-to-push-container') do
          expect(first("li")).to have_content("Roles")
          click_on access_type_name
        end
      end

      wait_for_ajax
      expect(ProtectedTag.last.push_access_levels.map(&:access_level)).to include(access_type_id)
    end
  end
end
