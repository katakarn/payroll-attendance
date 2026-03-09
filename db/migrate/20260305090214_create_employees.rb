class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :name, null: false
      t.string :position, null: false
      t.decimal :base_salary, precision: 12, scale: 2, null: false

      t.timestamps
    end
  end
end
