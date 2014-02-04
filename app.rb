ROOT_PATH = File.expand_path(File.dirname(__FILE__))

require "cuba"
require "haml"
require "redcarpet"
require "htmlentities"
require "json"
require "compass"
require "open-uri"
require "digest/md5"
require "redis"
require "ohm"
require "rack/static"
require "nokogiri"

require File.expand_path("lib/reference", ROOT_PATH)
require File.expand_path("lib/template", ROOT_PATH)

require File.expand_path("lib/interactive/namespace", ROOT_PATH)
require File.expand_path("lib/interactive/session", ROOT_PATH)

Encoding.default_external = Encoding::UTF_8

module Kernel
private

  def documentation_path
    $documentation_path ||= File.expand_path(ENV["REDIS_DOC"] || "redis-doc")
  end

  def commands
    $commands ||= Reference.new(JSON.parse(File.read(documentation_path + "/commands.json")))
  end

  def new_redis_connection
    Redis.connect(url: ENV["REDISTOGO_URL"])
  end

  def redis
    $redis ||= new_redis_connection
  end

  def redis_versions
    $redis_versions ||= redis.hgetall("versions")
  end

  def related_topics_for(command)
    # For now this is a quick and dirty way of figuring out related topics.

    path = "#{documentation_path}/topics/#{command.group}.md"

    return [] unless File.exist?(path)

    _, title = topic(path)

    [[title, "/topics/#{command.group}"]]
  end

  def related_commands_for(group)
    commands.select do |command|
      command.group == group
    end.sort_by(&:name)
  end

  def update_redis_versions
    tags = `git ls-remote -t https://github.com/antirez/redis.git`

    versions = tags.scan(%r{refs/tags/(v?(?:\d\.?)*\-(?:stable|rc\w+|alpha\w+))}).flatten.uniq

    stable, development = versions.partition { |v| v =~ /^v/ }

    redis.hmset(
      "versions",
      "stable", stable.sort.last,
      "development", development.sort.last
    )
  end

  def clean_version(version)
    version[/((?:\d\.?)+)/, 1]
  end

  def version_name(tag)
    tag[/v?(.*)/, 1].sub(/\-stable$/, "")
  end
end

Ohm.redis = redis

Cuba.use Rack::Static, urls: ["/images", "/presentation", "/opensearch.xml"], root: File.join(ROOT_PATH, "public")

Cuba.define do
  def render(path, locals = {})
    options = {
      :fenced_code_blocks => true,
      :superscript => true,
    }

    expanded = File.expand_path(path)
    if expanded.start_with?(documentation_path)
      data = super(path, locals, options)
      filter_interactive_examples(data)
    elsif expanded.start_with?(ROOT_PATH)
      super(path, locals, options)
    end
  end

  # Setup a new interactive session for every <pre><code> with @cli
  def filter_interactive_examples(data)
    namespace = Digest::MD5.hexdigest([rand(2**32), Time.now.usec, Process.pid].join("-"))
    session = ::Interactive::Session.create(namespace)

    data.gsub %r{<pre>\s*<code class="cli">\s*(.*?)\s*</code>\s*</pre>}m do |match|
      lines = $1.split(/\n+/m).map(&:strip)
      render("views/interactive.haml", session: session, lines: lines)
    end
  end

  def haml(template, locals = {})
    layout(partial(template, locals))
  end

  def partial(template, locals = {})
    render("views/#{template}.haml", locals)
  end

  def layout(content)
    partial("layout", content: content)
  end

  def topic(template)
    body = render(template)
    title = body[%r{<h1>(.+?)</h1>}, 1] # Nokogiri may be overkill

    return body, title
  end

  def gravatar_hash(email)
    Digest::MD5.hexdigest(email)
  end

  def not_found(locals = {path: nil})
    res.status = 404
    res.write haml("404", locals)
  end

  on get, "" do
    res.write haml("home")
  end

  on get, "buzz" do
    res.write haml("buzz")
  end

  on get, /(download|community|documentation|support)/ do |topic|
    @body, @title = topic("views/#{topic}.md")
    res.write haml("topics/name")
  end

  on get, "commands" do
    on :name do |name|
      @name = @title = name.upcase.gsub("-", " ")
      @command = commands[@name]

      if @command.nil?
        res.redirect "https://www.google.com/search?q=#{CGI.escape(name)}+site%3Aredis.io", 307
        halt res.finish
      end

      @related_commands = related_commands_for(@command.group)
      @related_topics = related_topics_for(@command)

      res.write haml("commands/name")
    end

    on default do
      @commands = commands
      @title = "Command reference"

      res.write haml("commands")
    end
  end

  on post, "session", /([0-9a-f]{32})/i do |id|
    if session = ::Interactive::Session.find(id)
      res.write session.run(req.params["command"].to_s)
    else
      res.status = 404
      res.write "ERR Session does not exist or has timed out."
    end
  end

  on get, "clients" do
    @clients = JSON.parse(File.read(documentation_path + "/clients.json"))
    @redis_tools = JSON.parse(File.read(documentation_path + "/tools.json"))

    @clients_by_language = @clients.group_by { |info| info["language"] }.sort_by { |name, _| name.downcase }

    res.write haml("clients")
  end

  on get, "topics/:name" do |name|
    path = "/topics/#{name}.md"

    break not_found(path: path) unless File.exist?(File.join(documentation_path, path))

    @css = [:topics, name]
    @body, @title = topic(File.join(documentation_path, path))
    @related_commands = related_commands_for(name)

    res.write haml("topics/name")
  end

  on get, extension("json") do |file|
    res.headers["Cache-Control"] = "public, max-age=29030400" if req.query_string =~ /[0-9]{10}/
    res.headers["Content-Type"] = "application/json;charset=UTF-8"
    res.write File.read(documentation_path + "/#{file}.json")
  end

  on get, extension("css") do |file|
    res.headers["Cache-Control"] = "public, max-age=29030400" if req.query_string =~ /[0-9]{10}/
    res.headers["Content-Type"] = "text/css; charset=utf-8"
    res.write render("views/#{file}.sass")
  end

  on get, extension("js") do |file|
    res.headers["Cache-Control"] = "public, max-age=29030400" if req.query_string =~ /[0-9]{10}/
    res.headers["Content-Type"] = "text/javascript; charset=utf-8"
    res.write File.read("views/#{file}.js")
  end

  on post, "commits/payload" do
    update_redis_versions
  end
end
