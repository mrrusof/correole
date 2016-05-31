require 'sinatra'

class Correole < Sinatra::Base

  set :server, :thin
  enable :logging
  disable :show_exceptions

  before do
    content_type 'text/plain'
  end

  after do
    ActiveRecord::Base.clear_active_connections!
  end

  put '/subscribers/:email' do
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
