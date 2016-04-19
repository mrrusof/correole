class Correole < Sinatra::Base

  set :server, :thin
  set :logging, true
  set :show_exceptions, false

  before do
    content_type 'text/plain'
  end

   after do
     ActiveRecord::Base.clear_active_connections!
   end

  get '/subscribers/:email' do
    s = Subscriber.find_by_email(params[:email])
    raise Sinatra::NotFound.new if s == nil
    content_type 'application/json'
    s.to_json
  end

  put '/subscribers/:email' do
    s = Subscriber.new(email: params[:email])
    return 400 if not s.valid?
    begin
      s.save
    rescue ActiveRecord::RecordNotUnique
      logger.info("Already subscribed #{s}")
      Subscriber.find_by_email(params[:email]).touch
    end
    [201, "Subscribed #{params[:email]}\n"]
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

  error do
    [500, "Internal server error\n"]
  end
end
