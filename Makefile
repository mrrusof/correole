exec:
	bundle exec ruby -I lib -I config bin/correole

test: test.db
	@for f in test/*_spec.rb; do \
	  bundle exec ruby -I lib -I config $$f || exit 1; \
	done

%.db:
	RACK_ENV=$* ruby db/migrate.rb

clean:
	rm -rf *.gem *.db *~

.PHONY: exec test clean
