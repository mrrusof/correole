class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.string :link, null: false
      t.timestamp :pub_date, null: true
      t.index :link, unique: true
      t.timestamps null: false
    end
  end
end
