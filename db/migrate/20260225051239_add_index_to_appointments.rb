class AddIndexToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_index :appointments, [ :start_time, :end_time ]
    add_index :appointments, :status
  end
end
