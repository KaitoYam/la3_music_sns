require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
require 'dotenv/load'
require 'logger'
require 'net/http'
enable :sessions

helpers do 
    def current_user
        User.find_by(id: session[:user])
    end
end


get '/' do
    @posts = Post.all
    erb :index
end

get '/signin' do 
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect '/'
end


get '/signup' do
    erb :sign_up
end



post '/signup' do
    Dotenv.load
    Cloudinary.config do |config|
        config.cloud_name = ENV['CLOUD_NAME']
        config.api_key = ENV['CLOUDINARY_API_KEY']
        config.api_secret = ENV['CLOUDINARY_API_SECRET']
    end 
    session[:user] = nil;
    img_url = ""
    if params[:file]
        img = params[:file]
        tempfile = img[:tempfile]
        logger.info(tempfile)
        upload = Cloudinary::Uploader.upload(tempfile.path)
        img_url = upload['url']
    else
        img_url = "https://1.bp.blogspot.com/-l4fWuSze_MI/YHDkJRsVYzI/AAAAAAABdlM/4lid3iHq_aMFybNb9PYCOpNIEtOwgwRFwCNcBGAsYHQ/s755/hengao_mabuta_uragaesu.png"
    end
    user = User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        user_image_url: img_url
    )
    if user.persisted?
        session[:user] = user.id
    end
    logger.info(user.id)
    redirect '/'
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end

get '/search' do
    if(params[:keyword])
        uri = URI("https://itunes.apple.com/search")
        uri.query = URI.encode_www_form({term: params[:keyword], country: "jp", media:"music"})
        
        res = Net::HTTP.get_response(uri)
        json = JSON.parse(res.body)
        @music = json
        logger.info(json["resultCount"])
    
    end
    erb :search
end

get '/mypage' do
    # @allpost = Post.all
    if current_user.nil?
        @posts = Post.none
    else
        @posts = current_user.posts
    end
    erb :home
end

post '/mypost/add' do
    post = Post.create(
        music: params[:music],
        artist: params[:artist],
        album: params[:album],
        image_url: params[:image_url],
        sample: params[:sample],
        user_id: current_user.id,
        comment: params[:comment]
    )
    if post.persisted?
        logger.info(post)
    end
    redirect '/mypage'
end

post '/mypost/:id/delete' do
    post = Post.find(params[:id])
    post.destroy
    redirect '/mypage'
end

get '/mypost/:id/edit' do
    @post = Post.find(params[:id])
    erb :edit
end

post '/mypost/:id/edit' do
    post = Post.find(params[:id])
    post.comment = params[:comment]
    post.save
    redirect '/mypage'
end