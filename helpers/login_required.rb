helpers do
  private
    def login_required
      redirect '/' unless current_user
    end
end
