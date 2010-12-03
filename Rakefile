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

task :deploy do
  current_branch = `git branch`[/^\* (.*)$/, 1]

  sh "git checkout deploy || git checkout -b deploy"

  begin
    sh "git rebase master"

    Task[:update].invoke

    sh "git add redis-doc"
    sh "git commit -m 'Add redis-doc.' || true"
    sh "git push heroku deploy:master -f"
  ensure
    sh "git checkout #{current_branch}"
  end
end
