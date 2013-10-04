class AddAttachmentAvtarToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.has_attached_file :avtar
    end
  end

  def self.down
    drop_attached_file :users, :avtar
  end
end
