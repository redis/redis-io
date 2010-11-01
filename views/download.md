Download
===

Stable versions
---

* [Version 2.0.3](http://code.google.com/p/redis/downloads/detail?name=redis-2.0.3.tar.gz)
* [Version 1.2.6](http://code.google.com/p/redis/downloads/detail?name=redis-1.2.6.tar.gz)

Development versions
---

* [Version 2.2 alpha 2](http://github.com/antirez/redis/tarball/2.2-alpha2)

Other downloads are available on [GitHub](http://github.com/antirez/redis/downloads)
and [Google Code](http://code.google.com/p/redis/downloads/list?can=1).

Installation
===

Download, extract and compile Redis with:

    $ wget http://redis.googlecode.com/files/redis-2.0.3.tar.gz
    $ tar xf redis-2.0.3.tar.gz
    $ cd redis-2.0.3
    $ make

Redis is now compiled. Run it with:

    $ ./redis-server

You can interact with Redis using the built-in client:

    $ ./redis-cli
    redis> set foo bar
    OK
    redis> get foo
    "bar"

Are you new to Redis? Try our [online, interactive tutorial](http://try.redis-db.com).
