var fs = require('fs')
  , path = require('path')
  , yaml = require('js-yaml')
  , marked = require('marked')
  , swig = require('swig')
  , git = require('gift');

var content_root = "../site"

/** Swig Filters **/
swig.setFilter('isnull', function (input) {
  return input === null ? '' : input;
});


function exists(file, isDir) {
  try { return fs.statSync(file)[isDir ? "isDirectory" : "isFile"](); }
  catch(e) { return false; }
}

function copyFileSync(input, output) {
  var buff = new Buffer(65536), pos = 0;
  var infd = fs.openSync(input, "r"), outfd = fs.openSync(output, "w");
  do {
    var read = fs.readSync(infd, buff, 0, 65536, pos);
    pos += read;
    fs.writeSync(outfd, buff, 0, read);
  } while (read);
  fs.closeSync(infd); fs.closeSync(outfd);
};

function readConfig() {
  var config_file = content_root + "/" + "_config.yml"
  var config = (exists(config_file) && yaml.load(fs.readFileSync(config_file, "utf8"))) || {};
  return config;
}

function getURL(config, post) {
  var link = config.permalink;
  /*TODO: remove hardcoding */
  link = link.replace(":category", post.category)
  link = link.replace(":title", post.title)
  return link;
}

function hasFrontMatter(file) {
  var fd = fs.openSync(file, "r");
  var b = new Buffer(4);
  var ret = fs.readSync(fd, b, 0, 4, 0) == 4 && (b.toString() == "---\n" || b.toString() == "---\r");
  fs.closeSync(fd);
  return ret;
}

function getYAML(file_path)
{
 re = /^(-{3}(?:\n|\r))([\w\W]*)*/
 info = fs.readFileSync(file_path)
 result = re.exec(info)
 fm = yaml.load("---\n"+result[2])
 return fm;
}

function readAndWriteData(config)
{
    data_dir = config.site_root + "/" + config.data_dir;
    out_dir = config.publish_root + "/" + config.data_dir.replace("_","")
    fs.readdirSync(data_dir).forEach(function(file) {
      re = /^(.*)\.(yml)$/
      var d = re.exec(file)
      if (!d) return;
      var file_path = data_dir + "/" + file;
      try {
        var split = getYAML(file_path);
      }
      catch(err) {
        console.log("Fix file: " + file_path + " - error " + err)
        return;
      }
      data_file = out_dir + "/" + d[1] + ".json"
      console.log(data_file)
      console.log(split)
      ensureDirectories(data_file)
      fs.writeFileSync(data_file, JSON.stringify(split))
    })
}

function getcontent(file_path)
{
  re = /^(-{3}(?:\n|\r)([\w\W]+?)-{3})?([\w\W]*)*/
  info = fs.readFileSync(file_path)
  result = re.exec(info)
  fm = yaml.load("---\n"+result[2])
  content = result[3]
  return {fm: fm, content: content};
}

function readPosts(config) {
  var posts = [];
  var categories = config.category
  categories.forEach(function(category) {
    posts_dir = config.site_root + "/" + category + "/" + config.posts_dir;
    fs.readdirSync(posts_dir).forEach(function(file) {
      var d = file.match(/^(\d{4})-(\d\d?)-(\d\d?)-(.+)\.(md)$/);
      if (!d) return;
      var file_path = posts_dir + "/" + file;
      try {
        var split = getcontent(file_path);
      }
      catch(err) {
        console.log("Fix file: " + file_path + " - error " + err)
        return;
      }
      var post = {};
      post.date = new Date(d[1], d[2] - 1, d[3]);
      post.title = d[4];
      post.page = split.fm;
      if (post.page.date) post.date = post.page.date;
      if (d[5] == "md") {
        //HACK: markdown parsing hack to let swig do its thing
        c = split.content.replace(/\"/g, "$")
        post.content = marked(c).replace(/\$/g,"\"")
        post.category = category;
        post.page.category = category;
        post.url = getURL(config, post);
        post.page.url = post.url;
      }
      posts.push(post);
    })
  })
  posts.sort(function(a, b){return b.date - a.date;});
  return posts;
}

function ensureDirectories(path) {
  var parts = path.split("/"), cur = "";
  for (var i = 0; i < parts.length - 1; ++i) {
    cur += parts[i] + "/";
    if (!exists(cur, true)) fs.mkdirSync(cur);
  }
}

function prepareIncludes(ctx) {
  includes_dir = ctx.site.site_root + "/" + ctx.site.includes_dir
  includes_dir_full_path = path.resolve(includes_dir)
  if (!exists(includes_dir, true)) return;
  fs.readdirSync(includes_dir_full_path).forEach(function(file) {
    swig.setDefaults({loader: swig.loaders.fs(includes_dir_full_path)})
    swig.compileFile(file)
  })
}

var layouts = {};
function getLayout(name, ctx) {
  if (name.indexOf(".") == -1) name = name + ".html";
  if (layouts.hasOwnProperty(name)) return layouts[name];
  layouts_dir = ctx.site.site_root + "/" + ctx.site.layouts_dir + "/"
  name_full_path = path.resolve(layouts_dir, name)
  var tmpl = swig.compileFile(name_full_path);
  tmpl.filename = name;
  layouts[name] = tmpl;
  return tmpl;
}

exports.generate_post = function(article_file_path, article_url) {
  console.log("Generate Post: " + article_url)
  try {
    var split = getcontent(article_file_path);
    post = {}
    post.page = split.fm;
    post.page.url = article_url;
    out_file_path = post.page.url;
    if (article_file_path.indexOf(".md") != -1)
    {
      c = split.content.replace(/\"/g, "$")
      post.content = marked(c).replace(/\$/g,"\"")
      out_file_path = out_file_path + "/" + "index.html"
    }
    else {
      post.page.content = split.content;
    }
    var config = readConfig(), ctx = {}; 
    ctx.site = config;
    ctx.page = post.page;
    swig.setDefaults({loader: swig.loaders.fs(path.resolve(ctx.site.site_root + "/" + ctx.site.includes_dir))});
    ctx.content = swig.render(post.content, {locals: ctx});
    var render = getLayout(post.page.layout, ctx)
    var render_output = render(ctx)
    var out_path = config.publish_root + out_file_path
    fs.writeFileSync(out_path, render_output)
  }
  catch(err) {
    console.log("Fix file: " + article_file_path + " - error " + err)
    return "/index.html";
  }
  return article_url
}

/* TODO: Consolidate the generation logic from page, post, pages and posts */
exports.generate = function() {
  var config = readConfig()
  var posts = readPosts(config)
  var data = {}
  site = config
  site.posts = posts
  site.time = new Date()
  site.data = data
  var ctx = {site: site}
  
  prepareIncludes(ctx)
  
  posts.forEach(function(post) {
    var render = getLayout(post.page.layout, ctx)
    swig.setDefaults({loader: swig.loaders.fs(path.resolve(ctx.site.site_root + "/" + ctx.site.includes_dir))});
    post.content = swig.render(post.content, {locals: post});
    post.site = config
    var render_output = render(post)
    /* TODO: Hack of index.html */
    var post_path = config.publish_root + post.url + "/"+ "index.html"
    ensureDirectories(post_path)
    fs.writeFileSync(post_path, render_output)
  })
  

  categories = {}
  posts.forEach(function(post) {
    if (post.category) {
      var category = post.category
      var c = categories.hasOwnProperty(category) ? categories[category] : (categories[category] = [])
      c.push(post)
    }
  })
  site.categories = categories

  function walkDir(dir) {
    fs.readdirSync(dir).forEach(function(fname) {
      if (/^[_\.]/.test(fname)) return
      var file = dir + fname
      if (fs.statSync(file).isDirectory()) {
        walkDir(file + "/")
      } else {
        var out_path = dir.replace(site.site_root, site.publish_root) + fname
        if (hasFrontMatter(file)) {
          console.log("---Front Matter---" + file)
          var file_path = file
          var split = getcontent(file_path)
          var doc = {}
          doc.page = split.fm;
          if (/\.md$/.test(fname)) {
            //HACK: markdown parsing hack to let swig do its thing
            c = split.content.replace(/\"/g, "$")
            doc.content = marked(c).replace(/\$/g,"\"")
            link_name = fname.match(/^(.*?)\.[^\.]+$/)[1]
            out_path = site.publish_root + "/" + link_name + "/" + "index.html"
          }
          else {
            doc.content = split.content
          }
          if (!doc.page) {doc.page = {}; doc.page.layout = "none"}
          doc.url = out_path.replace(site.publish_root,"");
          doc.page.url = doc.url
          doc.site = site;

          var render = getLayout(doc.page.layout, doc)
          var render_output = render(doc)
          var re_render_output = swig.render(render_output, doc)
          ensureDirectories(out_path)
          fs.writeFileSync(out_path, re_render_output)
        } else {
          ensureDirectories(out_path)
          copyFileSync(file, out_path)
        }
      }
    })
  }
  walkDir(site.site_root + "/" )
}

/* TODO: move mailer to a separate module */
var nodemailer = require("nodemailer");
// create reusable transport method (opens pool of SMTP connections)
var smtpTransport = nodemailer.createTransport("direct", {debug: true});

// setup e-mail data with unicode symbols
var mailOptions = {
    from: "WiseVoter Mailer <mailer@wisevoter.org>", // sender address
    to: "vaibhavb@lib13.com", // list of receivers
    subject: "Task Complete", // Subject line
    text: "The git repository was installed.", // plaintext body
    html: "<b>The git repository was installed.</b>" // html body
}

exports.gitcommit = function(gitrepo){
  var gitdir = "./_git/", gitbranch = "gh-pages", repo;
  var outdir = gitdir , sitedir = "./_site/";
  function copyDirToGitDir(dir)
  {
    fs.readdirSync(dir).forEach(function(fname){
    var file = dir + fname
    if (fs.statSync(file).isDirectory()) {
        copyDirToGitDir(file + "/")
      } else {
        var out_path = dir.replace(sitedir, outdir) + fname
        ensureDirectories(out_path)
        copyFileSync(file, out_path)
      }
    })
  }
  function doCommit(){
    copyDirToGitDir(sitedir)
    repo = git(gitdir)
    repo.add(".",{A: true}, function(error){
      if (error) {console.log("Git Add: " + error); return;}
      repo.commit("Node bot commit", function(err){
        if (err) {console.log("Git Commit: " + err); return;}
        console.log(repo.path + ": Commit Completed.")    
        repo.sync("origin", gitbranch, function(e){
            if (e) {console.log("Sync: " + e); return;}
            console.log(repo.path + ": Sync Completed.")
        })
      })
    })
  }
  if (exists(gitdir, true) == false) {
    git.clone(gitrepo, gitdir, function(err, _repo){
      if (err) throw err
      repo = _repo
      repo.checkout(gitbranch, function(err, i){
        if (err) throw err;
        // send mail with defined transport object
        smtpTransport.sendMail(mailOptions, function(error, response){
            if(error) {
                console.log(error);
            } else {
                console.log("Message sent: " + response.message);
            }
        });
        doCommit();  
      })
    })
  } else {
    doCommit();
  }
}

//TODO: Fix code duplication, too long of a file here
exports.sitecommit = function(gitrepo){
  var gitdir = "../site/", gitbranch = "master", repo;
  // checkin site
  if (exists(gitdir, true) == true){
    repo = git(gitdir)
      repo.add(".",{A: true}, function(error){
      if (error) {console.log("Git Add: " + error); return;}
      repo.commit("Node bot commit", function(err){
        if (err) {console.log("Git Site Commit: " + err); return;}
        console.log(repo.path + ": Site Commit Completed.")    
        repo.sync("origin", gitbranch, function(e){
            if (e) {console.log("Site Master Sync: " + e); return;}
            console.log(repo.path + ": Site Master Sync Completed.")
        })
      })
    })
  }
  else {
    console.log("Site Error: Site was not configured properly.")
  }
}

exports.generate_data = function(){
  var config = readConfig()
  readAndWriteData(config)
}