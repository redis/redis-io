ROOT_PATH = File.expand_path(File.dirname(__FILE__))

require "cuba"
require "haml"
require "rdiscount"
require "json"
require "compass"
require "open-uri"
require "digest/md5"
require "redis"
require "rack/openid"
require "ohm"
require "rack/static"

require File.expand_path("lib/reference", ROOT_PATH)
require File.expand_path("lib/template", ROOT_PATH)

Cuba.use Rack::Session::Cookie
Cuba.use Rack::OpenID
Cuba.use Rack::Static, urls: ["/images"], root: File.join(ROOT_PATH, "public")

Encoding.default_external = Encoding::UTF_8

module Kernel
private

  def commands
    @commands ||= Reference.new(JSON.parse(File.read("redis-doc/commands.json")))
  end

  def redis
    @redis ||= Redis.connect(url: ENV["REDISTOGO_URL"])
  end

  def user
    @user ||= User[session[:user]]
  end
end

Ohm.redis = redis

Cuba.define do
  def render(path, locals = {})
    return unless File.expand_path(path).start_with?(ROOT_PATH)
    super(path, locals)
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
    # TODO: Relying on ivars for this is ugly.

    @body = render(template)
    @title = @body[%r{<h1>(.+?)</h1>}, 1] # Nokogiri may be overkill

    haml("topics/name")
  end

  def gravatar_hash(email)
    Digest::MD5.hexdigest(email)
  end

  on get, path("") do
    json = redis.get("commits")

    @commits = json ? JSON.parse(json)["commits"] : []

    res.write haml("home")
  end

  on get, path("download") do
    res.write topic("views/download.md")
  end

  on get, path("community") do
    res.write topic("views/community.md")
  end

  on get, path("documentation") do
    res.write topic("views/documentation.md")
  end

  on get, path("commands") do
    on segment do |name|
      @name = @title = name.upcase.gsub("-", " ")
      @command = commands[@name]

      res.write haml("commands/name")
    end

    on default do
      @commands = commands
      @title = "Command reference"

      res.write haml("commands")
    end
  end

  on get, path("clients") do
    @clients = JSON.parse(File.read("redis-doc/clients.json"))

    @clients_by_language = @clients.group_by { |name, info| info["language"] }.sort_by { |name, _| name.downcase }

    res.write haml("clients")
  end

  on get, path("topics"), segment do |_, _, name|
    @body = render("redis-doc/topics/#{name}.md")
    @title = @body[%r{<h1>(.+?)</h1>}, 1] # Nokogiri may be overkill

    res.write haml("topics/name")
  end

  on post do
    on path("commits"), param(:payload) do
      if redis.setnx("commits:refresh", 1)
        redis.pipelined do
          redis.set("commits", open("https://github.com/api/v2/json/commits/list/antirez/redis/master").read)
          redis.expire("commits:refresh", 90)
        end
      end
    end
  end

  on get, path("styles.css") do
    res.headers["Cache-Control"] = "public, max-age=29030400" if req.query_string =~ /[0-9]{10}/
    res.headers["Content-Type"] = "text/css; charset=utf-8"
    res.write render("views/styles.sass")
  end

  on get, path("app.js") do |_, file|
    res.headers["Cache-Control"] = "public, max-age=29030400" if req.query_string =~ /[0-9]{10}/
    res.headers["Content-Type"] = "text/javascript; charset=utf-8"
    res.write File.read("views/app.js")
  end
end
