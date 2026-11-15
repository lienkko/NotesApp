require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @workspace = workspaces(:one)
    @category = categories(:one)
    sign_in_as(@user)
  end

  test "creates a note with a category and multiple tags" do
    assert_difference "Note.count", 1 do
      assert_difference "Tag.count", 2 do
        assert_difference "NoteTag.count", 2 do
          post notes_path(workspace_id: @workspace.id), params: {
            note: {
              title: "Новая заметка",
              body: "Текст заметки",
              category_id: @category.id,
              tag_names: "ruby, rails"
            }
          }
        end
      end
    end

    note = Note.order(:id).last
    assert_redirected_to note_path(note)
    assert_equal @workspace, note.workspace
    assert_equal ["rails", "ruby"], note.tags.order(:name).pluck(:name)
  end

  test "does not create an invalid note" do
    assert_no_difference "Note.count" do
      post notes_path(workspace_id: @workspace.id), params: {
        note: { title: "", body: "", category_id: "", tag_names: "" }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".note-form"
  end

  test "updates a note and replaces its tags" do
    note = notes(:one)

    patch note_path(note), params: {
      note: {
        title: "Обновлённая заметка",
        body: "Обновлённый текст",
        category_id: "",
        tag_names: "updated, important"
      }
    }

    assert_redirected_to note_path(note)
    note.reload
    assert_equal "Обновлённая заметка", note.title
    assert_equal ["important", "updated"], note.tags.order(:name).pluck(:name)
    assert_nil note.category
  end

  test "filters notes by category" do
    get notes_path(workspace_id: @workspace.id, category_id: @category.id)

    assert_response :success
    assert_select ".note-title", count: 1, text: notes(:one).title
  end

  test "cannot open another user's workspace" do
    get workspace_path(workspaces(:two))

    assert_redirected_to workspaces_path
  end

  test "destroys a note and returns to its workspace" do
    note = notes(:one)

    assert_difference "Note.count", -1 do
      delete note_path(note)
    end

    assert_redirected_to notes_path(workspace_id: @workspace.id)
  end
end
