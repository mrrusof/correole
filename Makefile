test: test.db
	bundle exec rake test

%.db:
	RACK_ENV=$* bundle exec rake db:schema:load

clean:
	rm -rf *.gem *.db
	find . -name '*~' -delete

.PHONY: exec test clean
