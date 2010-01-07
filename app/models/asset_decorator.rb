Asset.class_eval do
  before_create :set_author

  def set_author
    user_id = UserSession.activated? &&
      (current_user_session = UserSession.find) &&
      current_user_session.user.id
    if !user_id && viewable
      if viewable.respond_to?(:user)
        user_id = viewable.user && viewable.user.id
      elsif viewable.respond_to?(:user_id)
        user_id = viewable.user_id
      end
    end

    self.author_id ||= user_id

    true   # don't stop the filters
  end
end