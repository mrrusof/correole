class Api < Sinatra::Base

  SUBSCRIBERS_ALLOWED_METHODS = 'PUT, DELETE, OPTIONS'
  SUBSCRIBERS_ALLOWED_ORIGIN = '*'
  UNSUBSCRIBE_ALLOWED_METHODS = 'GET, OPTIONS'
  UNSUBSCRIBE_ALLOWED_ORIGIN = '*'

  set :server, :thin
  enable :logging
  disable :show_exceptions
  use ActiveRecord::ConnectionAdapters::ConnectionManagement

  before do
    content_type 'text/plain'
  end

  def subscribe(params)
    response.headers['Access-Control-Allow-Origin'] = SUBSCRIBERS_ALLOWED_ORIGIN
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

  def unsubscribe(params)
    response.headers['Access-Control-Allow-Origin'] = UNSUBSCRIBE_ALLOWED_ORIGIN
    s = Subscriber.new(email: params[:email])
    return 400 if not s.valid?
    s = Subscriber.find_by_email(params[:email])
    if s != nil
      s.delete
      logger.info("Unsubscribed #{params[:email]}")
    else
      logger.info("Already unsubscribed #{params[:email]}")
    end
    "#{params[:email]}\n"
  end

  def subscribers_method_not_allowed
    response.headers['Access-Control-Allow-Methods'] = SUBSCRIBERS_ALLOWED_METHODS
    405
  end

  def unsubscribe_method_not_allowed
    response.headers['Access-Control-Allow-Methods'] = UNSUBSCRIBE_ALLOWED_METHODS
    405
  end

  options '/subscribers/:email' do
    response.headers['Access-Control-Allow-Methods'] = SUBSCRIBERS_ALLOWED_METHODS
    response.headers['Access-Control-Allow-Origin'] = SUBSCRIBERS_ALLOWED_ORIGIN
    200
  end

  put '/subscribers/:email' do
    subscribe(params)
  end

  delete '/subscribers/:email' do
    unsubscribe(params)
  end

  [ :get,
    :post,
    :patch
  ].each do |verb|
    send verb, '/subscribers/:email' do
      subscribers_method_not_allowed
    end
  end

  options '/unsubscribe/:email' do
    response.headers['Access-Control-Allow-Methods'] = UNSUBSCRIBE_ALLOWED_METHODS
    response.headers['Access-Control-Allow-Origin'] = UNSUBSCRIBE_ALLOWED_ORIGIN
    200
  end

  get '/unsubscribe/:email' do
    unsubscribe(params)
  end

  [ :put,
    :delete,
    :post,
    :patch
  ].each do |verb|
    send verb, '/unsubscribe/:email' do
      unsubscribe_method_not_allowed
    end
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
