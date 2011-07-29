Download
===

Redis uses a standard practice for its versioning:
**major.minor.patchlevel**.
An even **minor** marks a **stable**
release: 1.2, 2.0, 2.2.  Odd minors are used for **unstable**
releases: 1.3.x were the unstable versions that became 2.0 once stable.

<table class="versions">
  <tr class="current">
    <td>2.2.12</td>
    <td>Stable</td>
    <td>This is the Redis stable release.
    Redis 2.2 is production ready and provides big benefits compared to
    2.0 both in terms of performances, memory usage and functionality.
    To check what is new in version 2.2 please read the
    <a href="https://github.com/antirez/redis/raw/2.2/00-RELEASENOTES">Release Notes</a>.
    <br>
    <td>
      <a href="http://redis.googlecode.com/files/redis-2.2.12.tar.gz">Download</a>
    </td>
  </tr>

  <tr class>
    <td>2.4.0</td>
    <td>Release Candidate 5</td>
    <td>This is the newest Redis version that will replace Redis 2.2 in a few weeks.
    Redis 2.4 offers a number of significant advantages over Redis 2.2, you can
    read about all the changes <a href="http://antirez.com/post/everything-about-redis-24">in this detailed article</a>.
    <br>
    <td>
      <a href="http://redis.googlecode.com/files/redis-2.4.0-rc5.tar.gz">Download</a>
    </td>
  </tr>

  <tr>
    <td>Unstable</td>
    <td>This is where all the development happens. Only for hard core hackers.
    <td>
      <a href="https://github.com/antirez/redis/tree/unstable">Clone</a>
    </td>
  </tr>
</table>

Other downloads are available on [GitHub](https://github.com/antirez/redis/downloads)
and [Google Code](http://code.google.com/p/redis/downloads/list?can=1).

Installation
===

Download, extract and compile Redis with:

    $ wget http://redis.googlecode.com/files/redis-2.2.12.tar.gz
    $ tar xzf redis-2.2.12.tar.gz
    $ cd redis-2.2.12
    $ make

The binaries that are now compiled are available in the `src` directory. Run Redis with:

    $ src/redis-server

You can interact with Redis using the built-in client:

    $ src/redis-cli
    redis> set foo bar
    OK
    redis> get foo
    "bar"

Are you new to Redis? Try our [online, interactive tutorial](http://try.redis-db.com).

Where's Redis Cluster?
---

Salvatore is already hacking on Redis Cluster. By March 2011 we should
have some kind of experimental version, while a Release Candidate is not
expected until end of summer 2011.
