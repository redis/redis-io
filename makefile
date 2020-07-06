TEST_FILES=$(shell find test -name '*.rb')

test:
	test -x redis-doc || git clone https://github.com/redis/redis-doc
	cutest $(TEST_FILES)

deploy:
	cd /srv/redis-doc && git pull
	cd /srv/redis-io  && git pull
	service redis-io-app restart

.PHONY: deploy test
