class AddEncryptedApiKeyJive < ActiveRecord::Migration
  def change
    change_table :leagues do |t|
      t.string :encrypted_stripe_test_secret_key
      t.string :encrypted_stripe_production_secret_key
    end
  end
end
