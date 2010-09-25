class Comment < Ohm::Model
  attribute :url
  attribute :user_id
  attribute :body
  attribute :last_modified

  index :url

  def create
    self.last_modified = Time.now.utc.to_i
    super
  end

  def user
    User[user_id]
  end
end
