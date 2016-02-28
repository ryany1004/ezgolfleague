class ApplePayKey < ActiveRecord::Migration
  def change
    add_column :leagues, :apple_pay_merchant_id, :string
    add_column :leagues, :supports_apple_pay, :boolean, :default => false
  end
end