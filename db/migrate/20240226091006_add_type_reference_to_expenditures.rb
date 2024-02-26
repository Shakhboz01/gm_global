class AddTypeReferenceToExpenditures < ActiveRecord::Migration[7.0]
  def change
    add_reference :expenditures, :expenditure_type, null: true, foreign_key: true
  end
end
