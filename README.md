# Correole

[![Build Status](https://travis-ci.org/mrrusof/correole.svg?branch=master)](https://travis-ci.org/mrrusof/correole)

Correole is a minimum feature newsletter in Ruby.
Correole subscribes/unsubscribes readers and sends the newsletter.

Correole accepts subscribes/unsubscribes by way of its web API.
Readers subscribe by means of a form in your website that makes an Ajax request to the API.
Readers unsubscribe by means of an unsubscribe link in the newsletter.
The unsubscribe endpoint redirects readers to a given confirmation page in your website.

Correole sends out the newsletter by means of command `correole send`.
Correole tries to send the newsletter to each reader and does not retry or record failures.
Correole composes a multipart email for each reader from given templates and RSS feed.
Correole includes only new RSS items in the email.
Correole determines the RSS items that are new by remembering the items it sent in previous runs.
You tell Correole to skip new items (remember items and not send email) by means of command `correole purge`.

# Get it

```
git clone git@github.com:mrrusof/correole.git
cd correole
bundle install
bundle exec rake test
```

# Deploy it

Deploy to Heroku.

```
git clone git@github.com:mrrusof/correole.git
cd correole
heroku create
git push heroku master
```

Configure environment variables. For example:

```
heroku config:set BASE_URI=https://application-name.herokuapp.com/
heroku config:set CONFIRMATION_URI=http://yourdomain.com/unsubscribed/
heroku config:set FEED=http://yourdomain.com/feed.xml
heroku config:set SUBJECT='<%= title %>: newsletter for <%= date %>'
heroku config:set FROM='<%= title %> <newsletter@yourdomain.com>'
heroku config:set HTML_TEMPLATE=production.html.erb
heroku config:set PLAIN_TEMPLATE=production.txt.erb
heroku config:set SMTP_HOST=smtp.server
heroku config:set SMTP_PORT=25
heroku config:set SMTP_USER=your-username
heroku config:set SMTP_PASS=your-password
heroku config:set SMTP_AUTH=plain
heroku config:set SMTP_TTLS=true
```

Create database.

```
heroku addons:create heroku-postgresql:hobby-dev
heroku run migrate
```

# Usage

Correole provides three commands.
- `correole`, from repo root `bundle exec ruby -I config -I lib bin/correole`. Runs API for subscribe / unsubscribe.
  - Subscribe: `curl -X PUT http://application-name.herokuapp.com/subscribers/subscriber@mail.com`
  - Unsubscribe:
    - `curl -X DELETE http://application-name.herokuapp.com/subscribers/subscriber@mail.com`
    - `curl -X GET http://application-name.herokuapp.com/unsubscribe/subscriber@mail.com`
- `correole send [-q]`, from repo root `bundle exec ruby -I config -I lib bin/correole send [-q]`. Composes and sends newsletter.
- `correole purge [-q]`, from repo root `bundle exec ruby -I config -I lib bin/correole purge [-q]`. Skips current RSS items.

# License

The MIT License (MIT)

Copyright (c) 2016 Ruslán Ledesma Garza

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

