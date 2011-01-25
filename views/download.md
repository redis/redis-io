Download
===

Redis uses a standard practice for its versioning:
**major.minor.patchlevel**.
An even **minor** marks a **stable**
release: 1.2, 2.0, 2.2.  Odd minors are used for **unstable**
releases: 1.3.x were the unstable versions that became 2.0 once stable.

<table class="versions">
  <tr class="current">
    <td>2.0</td>
    <td>Stable</td>
    <td>2.0 is better than 1.2 in every aspect: more features, better
    replication, better persistence. The internals of Redis are more
    mature too. <strong>This is what you should use</strong>, unless you
    need features that are only available in the unstable release.</td>
    <td>
      <a href="http://redis.googlecode.com/files/redis-2.0.4.tar.gz">Download</a>
    </td>
  </tr>

  <tr>
    <td>2.2</td>
    <td>Release Candidate</td>
    <td>This is what will become Redis 2.2 stable soon (a few weeks)
    Release Candidates for 2.2 are also tagged into git if you prefer.
    We think that 2.2 is mature enough to be used in production with some
    monitoring, given the big benefits it has compared to 2.0 both in terms
    of performances and memory usage. In the latest months we received a single
    critical bug report that was fixed after 29 minutes the issue was
    submitted.
    <br>
    <td>
      <a href="http://redis.googlecode.com/files/redis-2.2.0-rc4.tar.gz">Download</a>
    </td>
  </tr>

  <tr>
    <td>2.3</td>
    <td>Master</td>
    <td>The master branch merges the unstable branch at specific points in time:
    every time the new code passes all tests for
    a couple of weeks and no bugs are reported, the unstable branch is
    tagged with an -alpha&lt;number&gt; and is merged into master. <br>
    <td>
      <a href="https://github.com/antirez/redis/tarball/<%= redis_versions["development"] %>">Download</a>
    </td>
  </tr>

  <tr>
    <td>2.3</td>
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

    $ curl -O http://redis.googlecode.com/files/redis-<%= clean_version redis_versions["stable"] %>.tar.gz
    $ tar xzf redis-<%= clean_version redis_versions["stable"] %>.tar.gz
    $ cd redis-<%= clean_version redis_versions["stable"] %>
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

Where's Redis Cluster?
---

Salvatore is already hacking on Redis Cluster. By March 2011 we should
have some kind of experimental version, while a Release Candidate is not
expected until June 2011.

Probably the first stable version of Redis with clustering support will
be called 3.0, but Salvatore will try to merge to 2.2 as an experimental
feature if the stability of the system is not affected when the cluster
is not used.
