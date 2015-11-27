class AddEmailConfirmationForReceipts < ActiveRecord::Migration
  def change
    add_column :leagues, :dues_payment_receipt_email_addresses, :string
  end
end
