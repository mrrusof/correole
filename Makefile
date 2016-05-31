exec:
	ruby -I lib bin/correole

test:
	@for f in test/*_spec.rb; do \
	  ruby $$f || exit 1; \
	done

migrate:
	ruby db/migrate.rb

build:
	gem build correole.gemspec

install:
	gem install ./correole*.gem

clean:
	rm -rf *.gem *.db *~

.PHONY: exec test build install clean
