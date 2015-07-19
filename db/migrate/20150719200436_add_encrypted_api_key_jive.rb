class AddEncryptedApiKeyJive < ActiveRecord::Migration
  def change
    change_table :leagues do |t|
      t.string :encrypted_stripe_test_secret_key
      t.string :encrypted_stripe_production_secret_key
      t.string :encrypted_stripe_test_publishable_key
      t.string :encrypted_stripe_production_publishable_key
      
      t.boolean :stripe_test_mode, :default => true
    end
  end
end
