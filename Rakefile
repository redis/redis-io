task :default => :test

task :test do
  require "cutest"

  Cutest.run(Dir["test/*.rb"])
end

task :formatting do
  require "cutest"

  Cutest.run(Dir["test/formatting.rb"])
end

task :update do
  sh "rm -rf redis-doc"
  sh "git clone -q --depth 1 git://github.com/antirez/redis-doc.git"
  sh "rm -rf redis-doc/.git"
end

