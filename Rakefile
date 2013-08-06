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
  task :publish => [:history] do
    # Ensure the gh-pages dir exists so we can generate into it.
    puts "Checking for gh-pages dir..."
    unless File.exist?("./gh-pages")
      puts "No gh-pages directory found. Run the following commands first:"
      puts "  `git clone git@github.com:mojombo/jekyll gh-pages"
      puts "  `cd gh-pages"
      puts "  `git checkout gh-pages`"
      exit(1)
    end

    # Ensure gh-pages branch is up to date.
    Dir.chdir('gh-pages') do
      sh "git pull origin gh-pages"
    end

    # Copy to gh-pages dir.
    puts "Copying site to gh-pages branch..."
    Dir.glob("site/*") do |path|
      next if path == "_site"
      sh "cp -R #{path} gh-pages/"
    end

    # Commit and push.
    puts "Committing and pushing to GitHub Pages..."
    sha = `git log`.match(/[a-z0-9]{40}/)[0]
    Dir.chdir('gh-pages') do
      sh "git add ."
      sh "git commit -m 'Updating to #{sha}.'"
      sh "git push origin gh-pages"
    end
    puts 'Done.'
  end

  desc "Create a nicely formatted history page for the jekyll site based on 
  		the repo history."
  task :history do
    if File.exist?("History.md")
      history_file = File.read("History.md")
      front_matter = {
        "layout" => "docs",
        "title" => "History",
        "permalink" => "/docs/history/",
        "prev_section" => "contributing"
      }
      Dir.chdir('site/docs/') do
        File.open("history.md", "w") do |file|
          file.write("#{front_matter.to_yaml}---\n\n")
          file.write(converted_history(history_file))
        end
      end
    else
      abort "You seem to have misplaced your History.markdown file. 
      		 I can haz?"
    end
  end

end