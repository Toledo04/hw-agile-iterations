# frozen_string_literal: true

class AddUniqueIndexToBills < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL.squish
      DELETE FROM bills
      WHERE congress IS NOT NULL
        AND bill_type IS NOT NULL
        AND number IS NOT NULL
        AND id NOT IN (
          SELECT MIN(id)
          FROM bills
          WHERE congress IS NOT NULL
            AND bill_type IS NOT NULL
            AND number IS NOT NULL
          GROUP BY congress, bill_type, number
        )
    SQL

    add_index :bills, %i[congress bill_type number], unique: true
  end

  def down
    remove_index :bills, column: %i[congress bill_type number]
  end
end
