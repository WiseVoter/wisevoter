require 'rake'
require 'date'
require 'yaml'


#############################################################################
#
# Site tasks - http://www.wisevoter.org
#
#############################################################################

namespace :site do 
  desc "Commit the local site to the gh-pages branch and publish to GitHub Pages"
  task :publish do
    # Ensure the gh-pages dir exists so we can generate into it.
    puts "Checking for gh-pages dir..."
    unless File.exist?("./gh-pages")
      puts "No gh-pages directory found. Run the following commands first:"
      puts "  `git clone git@github.com:vaibhavb/wisevoter gh-pages"
      puts "  `cd gh-pages"
      puts "  `git checkout gh-pages`"
      exit(1)
    end

    # Copy to gh-pages dir.
    puts "Copying site to gh-pages branch..."
    Dir.glob("site/_site/*") do |path|
      sh "rsync -a #{path} gh-pages/"
    end

    # Commit and push.
    puts "Committing and pushing to GitHub Pages..."
    sha = `git log`.match(/[a-z0-9]{40}/)[0]
    Dir.chdir('gh-pages') do
      sh "rm -R _site/" if File.exist?("./_site")
      sh "git add -A ."
      sh "git commit -m 'Updating to #{sha}.'"
      sh "git push origin gh-pages"
    end
    puts 'Done.'
  end
end

#############################################################################
#
# Data tasks - http://www.wisevoter.org
#
#############################################################################

namespace :data do
  desc "generate masterfile and .md profile pages from govcheck, nocriminals and mpslist"
  task :refresh do
    puts "Running the data script with python"
    Dir.chdir('data') do
      sh "python wikioutput.py"
    end
  end

end

#############################################################################
#
# Dev tasks - http://www.wisevoter.org
#
#############################################################################
namespace :dev do
  desc "Commit the main portion of the site"
  task :commit, [:msg] do |t, args|
    # Ensure master is up to date
    Dir.chdir('.') do
      sh 'git pull origin master'
    end
    # Commit and push
    sh "git add -A ."
    sh "git commit -m '#{args.msg}'"
    sh "git push origin master"
    puts 'Done.'
  end

  desc "run jekyll"
  task :run do
    puts "Running the jekyll script"
    Dir.chdir('site') do
      sh "jekyll server -P 3000 -w"
    end
  end
end
