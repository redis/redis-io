Download
===

Stable versions
---

* [Version <%= version_name redis_versions["stable"] %>](https://github.com/antirez/redis/tarball/<%= redis_versions["stable"] %>)
* [Version 1.2.6](http://code.google.com/p/redis/downloads/detail?name=redis-1.2.6.tar.gz)

Development versions
---

* [Version <%= version_name redis_versions["development"] %>](https://github.com/antirez/redis/tarball/<%= redis_versions["development"] %>)

Other downloads are available on [GitHub](https://github.com/antirez/redis/downloads)
and [Google Code](http://code.google.com/p/redis/downloads/list?can=1).

Installation
===

Download, extract and compile Redis with:

    $ mkdir redis
    $ cd redis
    $ curl https://github.com/antirez/redis/tarball/<%= redis_versions["stable"] %> -L | tar -x --strip-components 1
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
