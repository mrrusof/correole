require File.expand_path '../../test_helper.rb', __FILE__

def app
  Correole
end

describe 'subscribers' do

  describe 'options' do

    it 'allows subscriptions from other domains' do
      email = "allow_other_domains_#{Time.now.to_i}@gmail.com"
      options "/subscribers/#{email}"
      assert last_response.ok?
      last_response.headers['Access-Control-Allow-Origin'].must_equal '*'
    end

    it 'allows methods PUT, DELETE, and OPTIONS' do
      email = "allow_other_domains_#{Time.now.to_i}@gmail.com"
      options "/subscribers/#{email}"
      assert last_response.ok?
      last_response.headers['Access-Control-Allow-Methods'].must_equal 'PUT, DELETE, OPTIONS'
    end

  end

  describe 'create' do

    it 'returns the subscriber email' do
      email = "return_created_subscriber_email_#{Time.now.to_i}@gmail.com"
      put "/subscribers/#{email}"
      assert last_response.ok?
      assert_equal 'text/plain;charset=utf-8', last_response.content_type
      assert_equal "#{email}\n", last_response.body
    end

    it 'records the subscriber in the database' do
      email = "record_subscriber_#{Time.now.to_i}@gmail.com"
      s = Subscriber.find_by_email(email)
      s.must_be_nil
      put "/subscribers/#{email}"
      s = Subscriber.find_by_email(email)
      s.wont_be_nil
      s.email.must_equal email
    end

    it 'returns 400 if the email is not valid' do
      email = "invalidemail_#{Time.now.to_i}.com"
      put "/subscribers/#{email}"
      assert last_response.bad_request?
    end

    it 'is idempotent' do
      email = "idempotent_subscribe_#{Time.now.to_i}@gmail.com"
      s = Subscriber.find_by_email(email)
      s.must_be_nil
      put "/subscribers/#{email}"
      s = Subscriber.find_by_email(email)
      s.wont_be_nil
      s.email.must_equal email
      put "/subscribers/#{email}"
      s = Subscriber.find_by_email(email)
      s.wont_be_nil
      s.email.must_equal email
    end

    it 'touches the subscriber when already subscribed' do
      email = "touch_#{Time.now.to_i}@gmail.com"
      s = Subscriber.find_by_email(email)
      s.must_be_nil
      put "/subscribers/#{email}"
      s = Subscriber.find_by_email(email)
      s.wont_be_nil
      s.email.must_equal email
      updated_at = s.updated_at
      s.updated_at = updated_at - 1
      s.save
      put "/subscribers/#{email}"
      s = Subscriber.find_by_email(email)
      s.wont_be_nil
      s.email.must_equal email
      assert s.updated_at >= updated_at, 'does not touch updated_at'
    end

    it 'allows subscriptions from other domains' do
      email = "allow_other_domains_#{Time.now.to_i}@gmail.com"
      put "/subscribers/#{email}"
      assert last_response.ok?
      last_response.headers['Access-Control-Allow-Origin'].must_equal '*'
    end

  end

  describe 'delete' do

    it 'returns the subscriber email' do
      email = "return_deleted_subscriber_email_#{Time.now.to_i}@gmail.com"
      s = Subscriber.new(email: email)
      s.save
      delete "/subscribers/#{email}"
      assert last_response.ok?
      assert_equal 'text/plain;charset=utf-8', last_response.content_type
      assert_equal "#{email}\n", last_response.body
    end

    it 'deletes the subscriber from the database' do
      email = "delete_subscriber_email_#{Time.now.to_i}@gmail.com"
      s = Subscriber.new(email: email)
      s.save
      delete "/subscribers/#{email}"
      s = Subscriber.find_by_email(email)
      s.must_be_nil
    end

    it 'is idempotent' do
      email = "idempotent_delete_#{Time.now.to_i}@gmail.com"
      s = Subscriber.new(email: email)
      s.save
      delete "/subscribers/#{email}"
      s = Subscriber.find_by_email(email)
      s.must_be_nil
      delete "/subscribers/#{email}"
      s = Subscriber.find_by_email(email)
      s.must_be_nil
    end

  end

  it 'does not allow getting a subscriber' do
    get '/subscribers/some@mail.com'
    assert last_response.method_not_allowed?, 'is getting a subscriber allowed?'
    assert_equal "Method not allowed\n", last_response.body
  end

  it 'does not allow posting a subscriber' do
    post '/subscribers/some@mail.com'
    assert last_response.method_not_allowed?, 'is posting a subscriber allowed?'
    assert_equal "Method not allowed\n", last_response.body
  end

end

class Correole
  get '/internal-server-error' do
    500
  end
end

describe 'error messages' do

  it 'returns "Not found" for 404' do
    get '/hola'
    assert last_response.not_found?, 'request is not "not found"'
    assert_equal "Not found\n", last_response.body
  end

  it 'returns "Bad request" for 400' do
    put '/subscribers/invalidemail'
    assert last_response.bad_request?, 'request is not bad'
    assert_equal "Bad request\n", last_response.body
  end

  it 'returns "Method not allowed" for 405' do
    post '/subscribers/some@mail.com'
    assert last_response.method_not_allowed?, 'request does not execute a method not allowed'
    assert_equal "Method not allowed\n", last_response.body
  end

  it 'returns "Internal server error" for 500' do
    get '/internal-server-error' # additional endpoint created before this describe block
    assert last_response.server_error?, 'request is not an internal server error'
    assert_equal "Internal server error\n", last_response.body
  end

end
