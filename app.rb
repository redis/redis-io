# encoding: utf-8

ROOT_PATH = File.expand_path(File.dirname(__FILE__))

require "cuba"
require "cuba/render"
require "date"
require "digest/md5"
require "haml"
require "htmlentities"
require "json"
require "oga"
require "ohm"
require "open-uri"
require "rack/static"
require "redcarpet"
require "redis"
require "fileutils"

require File.expand_path("lib/reference", ROOT_PATH)
require File.expand_path("lib/template", ROOT_PATH)

require File.expand_path("lib/interactive/namespace", ROOT_PATH)
require File.expand_path("lib/interactive/session", ROOT_PATH)

Encoding.default_external = Encoding::UTF_8

DOWNLOADS = JSON.parse(File.read("downloads.json"), symbolize_names: true)

STABLE_VERSION = DOWNLOADS.fetch(:channels).fetch(:stable).fetch(:version)

module Kernel
private

  def documentation_path
    $documentation_path ||= File.expand_path(ENV["REDIS_DOC"] || "redis-doc")
  end

  def commands
    $commands ||= Reference.new(JSON.parse(File.read(documentation_path + "/commands.json")))
  end

  def new_redis_connection
    Redis.new(url: ENV["REDISCLOUD_URL"])
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
      command.group == group && command.is_listed?
    end.sort_by(&:name)
  end

  def update_redis_versions
    tags = `git ls-remote -t https://github.com/redis/redis.git`

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

class App < Cuba
  plugin Cuba::Render

  settings[:render][:template_engine] = "haml"

  use Rack::Static,
    urls: ["/images", "/presentation", "/opensearch.xml", "/styles.css", "/app.js"],
    root: File.join(ROOT_PATH, "public")

  def custom_render(path, locals = {}, options = {})
    res.headers["Content-Type"] ||= "text/html; charset=utf-8"
    res.write(custom_view(path, locals, options))
  end

  def custom_view(path, locals = {}, options = {})
    options = {
      fenced_code_blocks: true,
      superscript:        true,
      layout:             true
    }.merge(options)

    path_with_extension = File.extname(path).empty? ?
                            "#{path}.#{settings[:render][:template_engine]}" :
                            path

    if path_with_extension.start_with?("/")
      expanded_path = path_with_extension
    else
      expanded_path = File.expand_path(path_with_extension, File.join(settings[:render][:views]))
    end

    layout_path   = File.expand_path("#{settings[:render][:layout]}.#{settings[:render][:template_engine]}", File.join(settings[:render][:views]))

    data = _render(expanded_path, locals, options)

    unless options[:layout] == false
      data = _render(layout_path, locals.merge(content: data), options)
    end

    if expanded_path.start_with?(documentation_path)
      filter_interactive_examples(data)
    elsif expanded_path.start_with?(ROOT_PATH) && options[:anchors] != false
      add_header_ids(data)
    else
      data
    end
  end

  # Setup a new interactive session for every <pre><code> with @cli
  def filter_interactive_examples(data)
    namespace = Digest::MD5.hexdigest([rand(2**32), Time.now.usec, Process.pid].join("-"))
    session = ::Interactive::Session.create(namespace)

    data.gsub %r{<pre>\s*<code class="cli">\s*(.*?)\s*</code>\s*</pre>}m do |match|
      lines = $1.split(/\n+/m).map(&:strip)
      _render("views/interactive.haml", session: session, lines: lines)
    end
  end

  def add_header_ids(data)
    data.gsub %r{(<(?<hdr>h.)>(?<section>.*?)</h.>)} do |match|
      found = $~
      hdr = found[:hdr]
      section = found[:section]
      # convert spaces to underscores
      id = anchorize(section)
      %Q[<span id="#{id}" class=anchor></span><#{hdr} ><a href="##{id}" class=anchor-link>*</a>#{section}</#{hdr}>]
    end
  end

  def anchorize(str)
    str.downcase.gsub(/[\s+]/, '-').gsub(/[^[:alnum:]-]/, "")
  end

  def anchorize_language(str)
    # Addresses languages such as C++ and C#
    anchorize(str.gsub(/\+/, '-plus').gsub(/#/, '-sharp'))
  end

  def topic(template)
    body = custom_view(template, {}, layout: false)
    title = body[%r{<h1>(.+?)</h1>}, 1] # Nokogiri may be overkill

    return body, title
  end

  def gravatar_hash(email)
    Digest::MD5.hexdigest(email)
  end

  def not_found(locals = {path: nil})
    res.status = 404
    res.write(custom_view("404", locals))
  end

  define do
    on get, "" do
      custom_render("home", {}, anchors: false)
    end

    on get, "buzz" do
      custom_render("buzz", {}, anchors: false)
    end

    on get, "download" do
      custom_render("download")
    end

    on get, /(download|community|documentation|support)/ do |topic|
      @body, @title = topic("#{topic}.md")
      custom_render("topics/name")
    end

    on get, "commands" do
      on :name do |name|
        @name = name
        @title = @name.upcase.sub("-", " ")
        @command = commands[@title]

        if @command.nil?
          res.redirect "https://www.google.com/search?q=#{CGI.escape(name)}+site%3Aredis.io", 307
          halt res.finish
        end

        @related_commands = related_commands_for(@command.group)
        @related_topics = related_topics_for(@command)

        custom_render("commands/name")
      end

      on default do
        @commands = commands
        @title = "Command reference"

        custom_render("commands")
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

      custom_render("clients")
    end

    on get, "modules" do
      @modules = JSON.parse(File.read(documentation_path + "/modules.json"))
      @modules = @modules.sort_by {|m| -m["stars"]}
      custom_render("modules")
    end

    on get, "topics/:name" do |name|
      path = "/topics/#{name}.md"

      if File.exist?(File.join(documentation_path, path))
        @css = [:topics, name]
        @body, @title = topic(File.join(documentation_path, path))
        @related_commands = related_commands_for(name)

        custom_render("topics/name")
      else
        not_found(path: path)
      end
    end

    on get, "deploy" do
      if ENV["DEPLOY_TOKEN"] && req.GET["token"] == ENV["DEPLOY_TOKEN"]
        FileUtils.touch("deploy.txt")
      else
        res.status = 401
      end
    end

    on get, extension("json") do |file|
      res.headers["Cache-Control"] = "public, max-age=29030400" if req.query_string =~ /[0-9]{10}/
      res.headers["Content-Type"] = "application/json;charset=UTF-8"
      res.write File.read(documentation_path + "/#{file}.json")
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
end

Cuba.define { 
  begin
    run App
  rescue Exception => e
    res.status = 500
    res.write "I'm sorry, Dave. I'm afraid I can't do that."
  end
}
