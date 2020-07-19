class CreateDatabase < ActiveRecord::Migration[6.0]
  def change
    create_table :subscribers do |t|
      t.string :email, null: false
      t.index :email, unique: true
      t.timestamps null: false
    end
  end
end
