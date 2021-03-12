# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  expires                :string
#  expires_at             :string
#  google_auth            :jsonb
#  provider               :string
#  refresh_token          :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  token                  :string
#  uid                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  has_many :calendar_sync_definitions
  has_many :calendar_id_maps

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :omniauthable,
         :omniauth_providers => [:google_oauth2]

  def self.from_omniauth(auth)
    # Either create a User record or update it based on the provider (Google) and the UID
    # TODO(JR): This should update
    user = where(provider: auth.provider, uid: auth.uid).first_or_create
    user.update!(
      token: auth.credentials.token,
      expires: auth.credentials.expires,
      expires_at: auth.credentials.expires_at,
      refresh_token: auth.credentials.refresh_token,
      google_auth: auth,
    )
    user
  end

  def name
    google_auth.dig('info', 'name')
  end

  def email
    google_auth.dig('info', 'email')
  end
end
