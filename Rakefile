task :default => [:update, :test]

task :test do
  require "cutest"

  Cutest.run(Dir["test/*.rb"])
end

task :update do
  if File.directory?("redis-doc")
    Dir.chdir("redis-doc") { `git pull -q` }
  else
    `git clone -q git://github.com/antirez/redis-doc.git`
    `rm -rf redis-doc/.git`
  end
end

