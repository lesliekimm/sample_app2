class UsersController < ApplicationController
    before_action :logged_in_user, only: [:edit, :update, :index, :destroy, :followers, :following]
    before_action :correct_user, only: [:edit, :update]
    before_action :admin_user, only: :destroy
    # before_action :set_user, only: [:bio, :show]

  	def new
  		@user = User.new					# signup route calls this action
  	end

  	def create
  		@user = User.new(user_params)		# use aux method defined in private to require user and permit only name, email & pws
  		if @user.save
        @user.send_activation_email
        flash[:info] = "Please check your email to activate your account."
        redirect_to root_url
  		else
  			render 'new'					# if save is unsuccessful, we render 'new' with errors
  		end
  	end

    def bio
      # @user = User.find(params[:id])
    end

  	def show
  		@user = User.find(params[:id])		# technically, params[:id] returns a string but find knows to convert to int
      @microposts = @user.microposts.paginate(page: params[:page])
  	end

    def edit
        @user = User.find(params[:id])      # get user we want to edit
    end

    def update
        @user = User.find(params[:id])
        if @user.update_attributes(user_params)
            flash[:success] = "Profile updated"
            redirect_to @user
        else
            render 'edit'
        end
    end

    def destroy
        User.find(params[:id]).destroy
        flash[:succes] = "User deleted"
        redirect_to users_url
    end

    def index
        @users = User.paginate(page: params[:page])
    end

    def following
        @title = "Following"
        @user  = User.find(params[:id])
        @users = @user.following.paginate(page: params[:page])
        render 'show_follow'
    end

    def followers
        @title = "Followers"
        @user  = User.find(params[:id])
        @users = @user.followers.paginate(page: params[:page])
        render 'show_follow'
    end

  	private
  		def user_params
  			params.require(:user).permit(:name, :email, :password, :password_confirmation)
  		end

        # Before filters

        # Confirms the correct user
        def correct_user
            @user = User.find(params[:id])
            redirect_to(root_url) unless @user == current_user
        end

        def set_user
          @user = User.find(params[:id])
        end

        # Confirms admin user
        def admin_user
            redirect_to(root_url) unless current_user.admin?
        end
end
