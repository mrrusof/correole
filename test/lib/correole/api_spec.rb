require File.expand_path '../../../test_helper.rb', __FILE__

def app
  Api
end

describe 'subscribers' do

  [ ['/subscribers', 'PUT, DELETE, OPTIONS'],
    [Api::UNSUBSCRIBE_PATH, 'GET, OPTIONS']
  ].each do |c|

    describe "options '#{c.first}/:email'" do

      it 'allows invocation from other domains' do
        email = "allow_other_domains_#{Time.now.to_i}@gmail.com"
        options "#{c.first}/#{email}"
        last_response.status.must_equal 200, 'response is not ok'
        last_response.headers['Access-Control-Allow-Origin'].must_equal '*'
      end

      it "allows methods #{c.second}" do
        email = "allow_other_domains_#{Time.now.to_i}@gmail.com"
        options "#{c.first}/#{email}"
        last_response.status.must_equal 200, 'response is not ok'
        last_response.headers['Allow'].must_equal c.second
        last_response.headers['Access-Control-Allow-Methods'].must_equal c.second
      end

    end

  end

  describe 'subscribe' do

    it 'returns the subscriber email and responds ok' do
      email = "return_created_subscriber_email_#{Time.now.to_i}@gmail.com"
      put "/subscribers/#{email}"
      last_response.status.must_equal 200, 'response is not ok'
      assert_equal 'text/plain;charset=utf-8', last_response.content_type, "content type is not plain text, utf-8"
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
      email = "subscribe_invalidemail_#{Time.now.to_i}.com"
      put "/subscribers/#{email}"
      assert last_response.bad_request?, 'response is not 400'
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
      email = "subscribe_allow_other_domains_#{Time.now.to_i}@gmail.com"
      put "/subscribers/#{email}"
      last_response.headers['Access-Control-Allow-Origin'].must_equal '*'
    end

  end

  describe 'delete' do

    [ [:delete, '/subscribers'],
      [:get, Api::UNSUBSCRIBE_PATH]
    ].each do |c|

      describe "by `#{c.first} '#{c.second}/:email'`" do

        it 'returns the subscriber email' do
          email = "return_deleted_subscriber_email_#{Time.now.to_i}@gmail.com"
          s = Subscriber.new(email: email)
          s.save
          send c.first, "#{c.second}/#{email}"
          assert_equal 'text/plain;charset=utf-8', last_response.content_type, "content type is not plain text, utf-8"
          assert_equal "#{email}\n", last_response.body
        end

        it 'deletes the subscriber from the database' do
          email = "delete_subscriber_email_#{Time.now.to_i}@gmail.com"
          s = Subscriber.new(email: email)
          s.save
          send c.first, "#{c.second}/#{email}"
          s = Subscriber.find_by_email(email)
          s.must_be_nil
        end

        it 'returns 400 if the email is not valid' do
          email = "delete_invalidemail_#{Time.now.to_i}.com"
          send c.first, "#{c.second}/#{email}"
          assert last_response.bad_request?, 'response is not 400'
        end

        it 'is idempotent' do
          email = "idempotent_delete_#{Time.now.to_i}@gmail.com"
          s = Subscriber.new(email: email)
          s.save
          send c.first, "#{c.second}/#{email}"
          s = Subscriber.find_by_email(email)
          s.must_be_nil
          send c.first, "#{c.second}/#{email}"
          s = Subscriber.find_by_email(email)
          s.must_be_nil
        end

        it 'allows deletion from other domains' do
          email = "delete_allow_other_domains_#{Time.now.to_i}@gmail.com"
          send c.first, "#{c.second}/#{email}"
          last_response.headers['Access-Control-Allow-Origin'].must_equal '*'
        end

        if c.first == :delete

          it 'responds ok' do
            email = "delete_response_ok_#{Time.now.to_i}@gmail.com"
            send c.first, "#{c.second}/#{email}"
            last_response.status.must_equal 200, 'response is not ok'
          end

        else

          it 'redirects to confirmation page' do
            email = "delete_redirect_confirmation_#{Time.now.to_i}@gmail.com"
            send c.first, "#{c.second}/#{email}"
            last_response.status.must_equal 302, "response is not a redirect"
            last_response.headers['Location'].must_equal Configuration.confirmation_uri
          end

        end

      end

    end

  end

  [ [ '/subscribers',
      'PUT, DELETE, OPTIONS',
      [:get, :post, :patch] ],
    [ Api::UNSUBSCRIBE_PATH,
      'GET, OPTIONS',
      [:put, :delete, :post, :patch] ]
  ].each do |c|

    describe "methods not allowed for `#{c.first}/some@mail.com`" do

      c.third.each do |m|

        it "does not allow #{m.to_s.upcase}" do
          send m, "#{c.first}/some@mail.com"
          assert last_response.method_not_allowed?, "does allow `#{m.to_s.upcase} '#{c.first}/some@mail.com'`"
        end

        it "returns plain text message for #{m.to_s.upcase}" do
          send m, "#{c.first}/some@mail.com"
          assert_equal 'text/plain;charset=utf-8', last_response.content_type, "content type is not plain text, utf-8"
          assert_equal "Method not allowed\n", last_response.body
        end

        it "indicates allowed methods for #{m.to_s.upcase}" do
          send m, "#{c.first}/some@mail.com"
          assert_equal c.second, last_response.headers['Allow'], 'wrong header `Allow`'
          assert_equal c.second, last_response.headers['Access-Control-Allow-Methods'], 'wrong header `Access-Control-Allow-Methods`'
        end

      end

    end

  end

end

class Api
  get '/internal-server-error' do
    500
  end
end

describe 'error responses' do

  it 'returns "Not found" for 404' do
    get "/hola_#{Time.now.to_i}"
    assert last_response.not_found?, 'response is not "not found"'
    assert_equal "Not found\n", last_response.body
  end

  it 'returns "Bad request" for 400' do
    put '/subscribers/invalidemail'
    assert last_response.bad_request?, 'request is not bad'
    assert_equal "Bad request\n", last_response.body
  end

  it 'returns "Method not allowed" for 405' do
    post '/subscribers/some@mail.com'
    assert last_response.method_not_allowed?, 'request does executes a method that is allowed'
    assert_equal "Method not allowed\n", last_response.body
  end

  it 'returns "Internal server error" for 500' do
    get '/internal-server-error' # additional endpoint created before this describe block
    assert last_response.server_error?, 'request is not an internal server error'
    assert_equal "Internal server error\n", last_response.body
  end

end
