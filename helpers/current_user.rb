helpers do
  private
    def current_user
      @current_user ||= User.find_by(user_id: session[:user_id]) if session[:user_id]
    end
end
