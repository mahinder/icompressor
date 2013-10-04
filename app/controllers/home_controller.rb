class HomeController < ApplicationController
  
  def index
    
  end
  
  def upload
    User.create(:name => params[:name], :avtar => params[:avtar])
    redirect_to show_path
  end
  
  def show
    @user = User.last
  end
  
end
