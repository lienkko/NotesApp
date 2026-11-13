require "test_helper"

class NoteTest < ActiveSupport::TestCase
  test "belongs to a user" do
    note = notes(:one)

    assert_equal users(:one), note.user
  end

  test "requires a user, title, and body" do
    note = Note.new

    assert_not note.valid?
    assert_includes note.errors[:user], "must exist"
    assert_includes note.errors[:title], "can't be blank"
    assert_includes note.errors[:body], "can't be blank"
  end

  test "limits title and category lengths" do
    note = Note.new(
      user: users(:one),
      title: "a" * 256,
      body: "Text",
      category: "a" * 101
    )

    assert_not note.valid?
    assert_includes note.errors[:title], "is too long (maximum is 255 characters)"
    assert_includes note.errors[:category], "is too long (maximum is 100 characters)"
  end
end
