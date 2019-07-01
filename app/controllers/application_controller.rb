class ApplicationController < ActionController::Base
  def hello
    render html: "hello, world!"
  end
  protect_from_forgery with: :exception
  include SessionsHelper

  def check_login
    return unless logged_in?
    redirect_to root_path
  end
end
