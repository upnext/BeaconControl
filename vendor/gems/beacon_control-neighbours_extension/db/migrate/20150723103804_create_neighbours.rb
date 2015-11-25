class CreateNeighbours < ActiveRecord::Migration
  def change
    create_table :ext_neighbours_zone_neighbours do |t|
      t.belongs_to :source
      t.belongs_to :target

      t.timestamps
    end
  end
end
