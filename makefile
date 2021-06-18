TEST_FILES=$(shell find test -name '*.rb')

test:
	test -x redis-doc || git clone https://github.com/redis/redis-doc
	cutest $(TEST_FILES)

deploy:
	cd /srv/redis-doc && git stash && git pull
	cd /srv/redis-io  && git stash && git pull
	bash --login -c "cd /srv/redis-io && rvm use 2.7.0 && REDIS_DOC=/srv/redis-doc /srv/redis-io/scripts/generate_interactive_commands.rb > /srv/redis-io/lib/interactive/commands.rb"
	service redis-io-app restart

.PHONY: deploy test
