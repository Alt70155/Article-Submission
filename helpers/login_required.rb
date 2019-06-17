helpers do
  private
    def login_required
      redirect '/login' unless current_user
    end
end
