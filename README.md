# redis-io

This repository holds the source code for the website that runs [redis.io](http://redis.io).

## Getting started

The required gems are listed in the .gems file. To get up and running,
preferably using a gemset, run:

    gem install dep
    dep install

Now you need to clone the [redis-doc](https://github.com/antirez/redis-doc)
project, and set its path in the `REDIS_DOC` environment variable before starting
the server or running the tests.

Finally, you need to have a `redis-server` running on port 6379.

To start the website:

    REDIS_DOC=/path/to/redis-doc rackup

To run the tests, you also need to install `cutest` and `capybara`:

    gem install cutest capybara

Now, just run:

    REDIS_DOC=/path/to/redis-doc rake

Or to run the tests in a particular file:

    REDIS_DOC=/path/to/redis-doc cutest test/some_file.rb
