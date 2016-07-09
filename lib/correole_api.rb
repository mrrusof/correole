class CorreoleAPI < Sinatra::Base

  ALLOWED_METHODS = 'PUT, DELETE, OPTIONS'
  ALLOWED_ORIGIN = '*'

  set :server, :thin
  enable :logging
  disable :show_exceptions
  use ActiveRecord::ConnectionAdapters::ConnectionManagement

  before do
    content_type 'text/plain'
  end

  options '/subscribers/:email' do
    response.headers['Access-Control-Allow-Methods'] = ALLOWED_METHODS
    response.headers['Access-Control-Allow-Origin'] = ALLOWED_ORIGIN
    200
  end

  put '/subscribers/:email' do
    response.headers['Access-Control-Allow-Origin'] = ALLOWED_ORIGIN
    s = Subscriber.new(email: params[:email])
    return 400 if not s.valid?
    begin
      s.save
      logger.info("Subscribed #{params[:email]}")
    rescue ActiveRecord::RecordNotUnique
      logger.info("Already subscribed #{params[:email]}")
      Subscriber.find_by_email(params[:email]).touch
    end
    "#{params[:email]}\n"
  end

  delete '/subscribers/:email' do
    s = Subscriber.find_by_email(params[:email])
    if s != nil
      s.delete
      logger.info("Unsubscribed #{params[:email]}")
    else
      logger.info("Already unsubscribed #{params[:email]}")
    end
    "#{params[:email]}\n"
  end

  get '/subscribers/:email' do
    405
  end

  post '/subscribers/:email' do
    405
  end

  not_found do
    [404, "Not found\n"]
  end

  error 400 do
    [400, "Bad request\n"]
  end

  error 405 do
    [405, "Method not allowed\n"]
  end

  error 500 do
    [500, "Internal server error\n"]
  end

end
