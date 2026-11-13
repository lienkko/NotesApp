class RequireNoteBody < ActiveRecord::Migration[8.1]
  def change
    change_column_null :notes, :body, false
  end
end
