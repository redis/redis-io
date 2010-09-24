class User < Ohm::Model
  attribute :identity_url
  attribute :email

  index :identity_url

  def validate
    assert_present :identity_url
    assert_present :email
  end

  def self.from_openid(response)
    find(identity_url: response.identity_url).first || create(
      identity_url: response.identity_url, 
      email: response.extension_response("http://openid.net/srv/ax/1.0", false)["value.ext0"]
    )
  end
end
