require 'rake'
require 'date'
require 'yaml'
require 'jekyll'


############################################################################
# site variables
############################################################################
source_dir = "site"
stash_dir_name = "_stash"

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
      sh "git clone https://github.com/vaibhavb/wisevoter.git gh-pages"
      sh "cd gh-pages"
      sh "git checkout gh-pages`"
      sh "cd .."
    end

    # Generate the site
    puts "Generating the site..."
    Jekyll::Site.new(Jekyll.configuration({
        "source"      => "./site",
        "destination" => "./site/_site"
    })).process

    # Copy to gh-pages dir.
    puts "Copying site to gh-pages branch..."
    Dir.glob("site/_site/*") do |path|
      sh "rsync -a #{path} gh-pages/"
    end

    # Commit and push.
    puts "Committing and pushing to GitHub Pages..."
    sha = `git log`.match(/[a-z0-9]{40}/)[0]
    Dir.chdir('gh-pages') do
      status = `git status`
      if status == "nothing to commit (working directory clean)"
        puts "nothing to commit"
      else
        sh "git add -A ."
        sh "git commit -m 'Updating to #{sha}.'"
        sh "git push origin gh-pages"
      end
    end
    puts 'Done!'
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
    #TODO: Figure out a way to reduce site regeneration time
    puts "Running the jekyll script"
    Dir.chdir('site') do
      sh "jekyll server -P 3000 -w"
    end
  end
end


#############################################################################
#
# Dev tasks - http://www.wisevoter.org
#
#############################################################################
 # adapted from https://github.com/imathis/octopress/blob/master/Rakefile   
  # usage rake author:new_post['My New Post'] or rake author:new_post (defaults to "My New Post")
namespace :author do
  desc "Start a new post"
  task :new_post, :title do |t, args|
   args.with_defaults(:title => 'My New Post')
   title = args.title
   filename = "#{source_dir}/articles/_posts/#{Time.now.strftime('%Y-%m-%d')}-#{title.downcase.gsub(/&/,'and').gsub(/[,'":\?!\(\)\[\]]/,'').gsub(/[\W\.]/, '-').gsub(/-+$/,'')}.md"
   puts "Creating new post: #{filename}"
   open(filename, 'w') do |post|
     post.puts "---"
     post.puts "layout: article"
     post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
     post.puts "description: """
     post.puts "headline: """
     post.puts "modified: #{Time.now.strftime('%Y-%m-%d')}"
     post.puts "category: articles"
     post.puts "tags: []"
     post.puts "image: "
     post.puts "  feature: "
     post.puts "  location: "
     post.puts "  locationlink: "
     post.puts "  credit: "
     post.puts "  creditlink: "
     post.puts "comments: true"
     post.puts "readtime: 5"
     post.puts "---"
   end
  end

  # usage rake isolate[my-post]
  desc "Move all other posts than the one currently being worked on to a temporary stash location (stash) so regenerating the site happens much more quickly."
  task :isolate, :filename do |t, args|
    args.with_defaults(:filename => ' ')
    content_dirs = ["articles/_posts", "politicians/_posts", "parties/_posts", "constituencies/_posts"]
    content_dirs.each do |content_dir|
      stash_content_dir = "#{source_dir}/#{stash_dir_name}/#{content_dir}"
      source_content_dir = "#{source_dir}/#{content_dir}"
      puts "stash_dir: #{stash_content_dir}"
      puts "content_dir: #{source_content_dir}"
      FileUtils.mkpath(stash_content_dir) unless File.exist?(stash_content_dir)
      Dir.glob("#{source_content_dir}/*") { |file|  
        puts file
        FileUtils.mv file, "#{stash_content_dir}/" unless file.include?(args.filename)
      }
    end
  end

  desc "Move all stashed posts back into the posts directory, ready for site generation."
  task :integrate do
    #stash_dir = "#{source_dir}/#{stash_dir_name}"
    #FileUtils.mv Dir.glob("#{stash_dir}/articles/_posts/*.*"), "#{source_dir}/articles/_posts/"
    #FileUtils.mv Dir.glob("#{stash_dir}/politicians/_posts/*.*"), "#{source_dir}/politicians/_posts/"
    content_dirs = ["articles/_posts", "politicians/_posts", "parties/_posts", "constituencies/_posts"]
    content_dirs.each do |content_dir|
      stash_content_dir = "#{source_dir}/#{stash_dir_name}/#{content_dir}"
      source_content_dir = "#{source_dir}/#{content_dir}"
      puts "stash_dir: #{stash_content_dir}"
      puts "content_dir: #{source_content_dir}"
      FileUtils.mv Dir.glob("#{stash_content_dir}/*"), "#{source_content_dir}/"
    end
  end

end