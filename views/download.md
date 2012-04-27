Download
===

Redis uses a standard practice for its versioning:
**major.minor.patchlevel**.
An even **minor** marks a **stable**
release: 1.2, 2.0, 2.2, 2.4. Odd minors are used for **unstable**
releases: 1.3.x were the unstable versions that became 2.0 once stable.

<table class="versions">
  <tr class="current">
    <td>2.4.11</td>
    <td>Stable</td>
    <td>This is the newest Redis version replacing Redis 2.2.
    Redis 2.4 offers a number of significant advantages over Redis 2.2, you can
    read about all the changes <a href="http://antirez.com/post/everything-about-redis-24">in this detailed article</a>. For a list of fixes contained in each 2.4 release candidate please check the <a href="https://github.com/antirez/redis/raw/2.4/00-RELEASENOTES">Release Notes</a>.
    <br>
    <td>
      <a href="http://redis.googlecode.com/files/redis-2.4.11.tar.gz">Download</a>
    </td>
  </tr>

  <tr">
    <td>2.6.0-RC1</td>
    <td>Release Candidate</td>
    <td>This is the newest Redis version replacing Redis 2.4.
    Redis 2.6 features support for <a href="/commands/eval">Lua scripting</a>, milliseconds precision expires, improved memory usage, unlimited number of clients, improved AOF generation, better performance, a number of new commands and features. For the complete list of new features, and the list of fixes contained in each 2.6 release, please check the <a href="https://github.com/antirez/redis/raw/2.6/00-RELEASENOTES">Release Notes</a>.
    <br>
    <strong>Note: we are not aware of bugs in 2.6.0-RC1, but it's new code, so handle it with care if you plan to use it in production environments.</strong>
    <br>
    <td>
      <a href="http://redis.googlecode.com/files/redis-2.6.0-rc1.tar.gz">Download</a>
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
    <td>Unstable</td>
    <td>This is where all the development happens. Only for hard core hackers.
    <td>
      <a href="https://github.com/antirez/redis/tree/unstable">Clone</a>
    </td>
  </tr>

  <tr>
    <td>Win32/64</td>
    <td>Unofficial</td>
    <td>The Redis project does not directly support win32/win64, however we look at interest to projects trying to make a win32/win64 port that is separated from the main project. Two such efforts already exists:
    <ul>
        <li><a href="https://github.com/dmajkic/redis/">A Native win32/win64 port</a> created by Dušan Majkić.</li>
        <li><a href="https://gist.github.com/1439660">A patch released by Microsoft</a> based on <a href="https://github.com/joyent/libuv">libuv</a>.
    </ul>
    Currently both ports are not production quality but can be used for development purposes on Windows environments. We look forward for collaborating with the authors of this efforts but currently <a href="http://antirez.com/post/redis-win32-msft-patch.html">we will not merge the win32 port</a> to the main code base.
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

    $ wget http://redis.googlecode.com/files/redis-2.4.11.tar.gz
    $ tar xzf redis-2.4.11.tar.gz
    $ cd redis-2.4.11
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

Redis development is currently focused on Redis 2.6 that will bring you support for Lua scripting and many other improvements. This is our current priority, however the unstable branch already contains most of the fundamental parts of Redis Cluster. After the 2.6 release we'll focus our energies on turning the current Redis Cluster alpha in a beta product that users can start to seriously test.

It is hard to make forecasts since we'll release Redis Cluster as stable only when we feel it is rock solid and useful for our customers, but we hope to have a reasonable beta for summer 2012, and to ship the first stable release before the end of 2012.
