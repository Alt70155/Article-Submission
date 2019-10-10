helpers do
  def login?
    !current_user.nil?
  end
end
