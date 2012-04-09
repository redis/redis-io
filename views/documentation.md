Documentation
===

Note: the Redis documentation is also available in raw (programming friendly) format in the [redis-doc github repository](http://github.com/antirez/redis-doc).

Command reference
---

See [the full list of commands](/commands) implemented by Redis, along
with thorough documentation for each of them.

Topics
---

* [Data types](/topics/data-types): a summary of the different types of values
  that Redis supports.
* [Replication](/topics/replication): what you need to know in order to
set up master-slave replication.
* [Persistence](/topics/persistence): know your options when configuring
Redis' durability.
* [Pipelining](/topics/pipelining): learn how to send multiple commands
at once, saving on round trip time.
* [Redis Pub/Sub](topics/pubsub): Redis is a fast and stable Publish/Subscribe messaging system! Check it out.
* [Redis Lua scripting](/commands/eval): Redis 2.6 Lua scripting feature documentation.
* [Memory optimization](/topics/memory-optimization): understand how
Redis uses RAM and learn some tricks to use less of it.
* [Redis problems?](/topics/problems): Bugs? High latency? Other issues? Use [our problems troubleshooting page](/topics/problems) as a starting point to find more information.
* [Redis Security](/topics/security): an overview of Redis security.
* [Redis Administration](/topics/admin): selected administration topics.
* [Benchmarks](/topics/benchmarks): see how fast Redis is in different
platforms.
* [FAQ](/topics/faq): some common questions about Redis.
* [Protocol specification](/topics/protocol): if you're implementing a
client, or out of curiosity, learn how to communicate with Redis at a
low level.
* [Internals](/topics/internals): learn details about how Redis is
implemented under the hood.
* [Who's using Redis?](/topics/whos-using-redis)
* [Virtual memory (DEPRECATED)](/topics/virtual-memory): when your dataset doesn't
fit in RAM, you can use VM.

Tutorials
---

* [15 minutes introduction to Redis data types](/topics/data-types-intro)
* [Writing a simple Twitter clone with PHP and Redis](/topics/twitter-clone)
* [Auto complete with Redis](http://antirez.com/post/autocomplete-with-redis.html)

Presentations
-------------

* Salvatore Sanfilippo: [Redis cluster overview](/presentation/Redis_Cluster.pdf)
* Pieter Noordhuis: [What's new in Redis 2.2](/presentation/Pnoordhuis_whats_new_in_2_2.pdf)

If you would like to include the logo in a presentation, please use the
[high-res version](/images/redis-300dpi.png). The [svg version is also available](/images/redis-logo.svg).

Books
---

The two core team developers Pieter Noordhuis and Salvatore Sanfilippo are writing the book "Redis: the Definitive Guide" for O'Reilly Media that will be available in a few months.

The following is a list of books covering Redis that are already published:

* [The Little Redis Book](http://openmymind.net/2012/1/23/The-Little-Redis-Book/) by [Karl Seguin](http://twitter.com/karlseguin) is a great *free* and coincise book that will get you started with Redis.
* [Redis in Action](http://www.manning.com/carlson/) by [Josiah L. Carlson](http://twitter.com/dr_josiah) (early access edition).
* [Redis Cookbook (O'Reilly Media, 2011)](http://shop.oreilly.com/product/0636920020127.do)

The following books have Redis related content but are not specifically about Redis:

* [Seven databases in seven weeks](http://pragprog.com/book/rwdata/seven-databases-in-seven-weeks) (Note: Redis chapter still coming soon).
* [Mining the Social Web (O'Reilly Media, 2011)](http://shop.oreilly.com/product/0636920010203.do)
* [Professional NoSQL (Wrox, 2011)](http://www.wrox.com/WileyCDA/WroxTitle/Professional-NoSQL.productCd-047094224X.html)

Sponsors
---

All the work [Salvatore Sanfilippo](http://twitter.com/antirez) and [Pieter Noordhuis](http://twitter.com/pnoordhuis) do in order to develop Redis is sponsored by [VMware](http://vmware.com). In the past Redis accepted donations from other companies that are listed in the [Sponsors page](/topics/sponsors).
