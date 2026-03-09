class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :work_date, null: false
      t.datetime :check_in_at, null: false
      t.datetime :check_out_at, null: false

      t.timestamps
    end

    add_index :attendances, [ :employee_id, :work_date ], unique: true
  end
end
