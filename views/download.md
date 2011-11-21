Download
===

Redis uses a standard practice for its versioning:
**major.minor.patchlevel**.
An even **minor** marks a **stable**
release: 1.2, 2.0, 2.2, 2.4. Odd minors are used for **unstable**
releases: 1.3.x were the unstable versions that became 2.0 once stable.

<table class="versions">
  <tr class="current">
    <td>2.4.3</td>
    <td>Stable</td>
    <td>This is the newest Redis version replacing Redis 2.2.
    Redis 2.4 offers a number of significant advantages over Redis 2.2, you can
    read about all the changes <a href="http://antirez.com/post/everything-about-redis-24">in this detailed article</a>. For a list of fixes contained in each 2.4 release candidate please check the <a href="https://github.com/antirez/redis/raw/2.4/00-RELEASENOTES">Release Notes</a>.
    <br>
    <td>
      <a href="http://redis.googlecode.com/files/redis-2.4.3.tar.gz">Download</a>
    </td>
  </tr>

  <tr>
    <td>2.2.15</td>
    <td>Legacy</td>
    <td>This is the previous (now legacy) Redis stable release.
    We suggest using 2.4 stable instead.
    Redis 2.2 is production ready and provides big benefits compared to
    2.0 both in terms of performances, memory usage and functionality.
    To check what is new in version 2.2 please read the
    <a href="https://github.com/antirez/redis/raw/2.2/00-RELEASENOTES">Release Notes</a>.
    <br>
    <td>
      <a href="http://redis.googlecode.com/files/redis-2.2.15.tar.gz">Download</a>
    </td>
  </tr>

  <tr>
    <td>Unstable</td>
    <td>unstable</td>
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

    $ wget http://redis.googlecode.com/files/redis-2.4.3.tar.gz
    $ tar xzf redis-2.4.3.tar.gz
    $ cd redis-2.4.3
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

The Redis core team is already hacking on Redis Cluster. We already have
have some kind of experimental version in the unstable branch,
while a Release Candidate or at least a fully working beta is expected
for the end of 2011.
