test:
	cutest test/**/*.rb

deploy:
	cd /srv/redis-doc
	git pull
	cd /srv/redis-io
	git pull
	service redis-io-app restart

.PHONY: deploy test
