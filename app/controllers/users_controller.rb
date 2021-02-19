class UsersController < ApplicationController
  before_action :authenticate, only: [:show, :update]

  def spotify_redirect
    query_params = {
      client_id: ENV["SPOTIFY_CLIENT_ID"],
      response_type: "code",
      redirect_uri: ENV["SPOTIFY_REDIRECT_URI"],
      scopes: "user-read-email user-read-private"
    }.to_query

    redirect_to "https://accounts.spotify.com/authorize?#{query_params}"
  end

  def spotify_callback
    # ?code=asdasdas89798ausjkdnasdas7687678
    code = params[:code]
    # exchange the code with Spotify for an Access Token
    body = {
      grant_type: "authorization_code",
      code: code,
      redirect_uri: ENV["SPOTIFY_REDIRECT_URI"],
      client_id: ENV["SPOTIFY_CLIENT_ID"],
      client_secret: ENV["SPOTIFY_CLIENT_SECRET"]
    }
    token_response = RestClient.post("https://accounts.spotify.com/api/token", body)
    token_data = JSON.parse(token_response)
    # token_data has the access token in it

    # now we can use that token to interact with the API on behalf of the user
    user_response = RestClient.get("https://api.spotify.com/v1/me", {
      Authorization: "Bearer #{token_data["access_token"]}"
    })
    user_data = JSON.parse(user_response)

    # create (or find) a user and save their credentials/user info
    user = User.find_by(spotify_id: user_data["id"])
    if user.nil?
      user = User.create(
        spotify_id: user_data["id"],
        password: SecureRandom.hex(15),
        username: user_data["display_name"]
      )
    end

    user.update(
      access_token: token_data["access_token"],
      scope: token_data["scope"],
      refresh_token: token_data["refresh_token"],
      # exires_at: current time + how ever many seconds the token expires in
      expires_at: DateTime.now + token_data["expires_in"].seconds
    )

    # OUR JWT token to authenticate the user next time, and look their data up in the database
    token = JWT.encode({ user_id: user.id }, ENV['JWT_SECRET_KEY'], 'HS256')

    # render json: { user: UserSerializer.new(user), token: token }
    redirect_to "#{ENV["CLIENT_BASE_URL"]}/spotify/#{token}"
  end

  # POST /login
  def login
    # lookup a user with their username and password
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      # if they gave the right info, return that user object
      token = JWT.encode({ user_id: user.id }, ENV['JWT_SECRET_KEY'], 'HS256')
      render json: { user: UserSerializer.new(user), token: token }
    else
      # otherwise, return some error message
      render json: { errors: ["Invalid username or password"] }, status: :unauthorized
    end
  end

  # POST /signup
  def signup
    # create a user in the backend
    user = User.create(user_params)
    if user.valid?
      # if the user is created successfully, send back the user
      token = JWT.encode({ user_id: user.id }, ENV['JWT_SECRET_KEY'], 'HS256')
      render json: { user: UserSerializer.new(user), token: token }
    else
      # otherwise, send back an error
      render json: { errors: user.errors.full_messages }, status: :unauthorized
    end
  end

  # GET /me
  # authenticate
  def show
    render json: @current_user
  end

  # PATCH /me
  # authenticate
  def update
    @current_user.update(bio: params[:bio], image: params[:image])

    render json: @current_user
  end

  private
  
  def user_params
    params.permit(:username, :bio, :password, :image)
  end

end
