task :default => [:update, :test]

task :test do
  require "cutest"

  Cutest.run(Dir["test/*.rb"])
end

directory "tmp"

task :update => "tmp" do
  if File.directory?("tmp/redis-doc")
    Dir.chdir("tmp/redis-doc") { `git pull -q` }
  else
    Dir.chdir("tmp") { `git clone -q git://github.com/antirez/redis-doc.git` }
  end
end


