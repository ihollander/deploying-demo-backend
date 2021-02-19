class AddSpotifyCredentialsToUser < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.string :access_token
      t.string :scope
      t.datetime :expires_at
      t.string :refresh_token
      t.string :spotify_id
    end
  end
end
