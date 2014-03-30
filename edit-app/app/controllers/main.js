var fs = require('fs')
var swig = require('swig')
var wv = require("./base")

function getcontent(file_path)
{
  re = /^(-{3}(?:\n|\r)([\w\W]+?)-{3})?([\w\W]*)*/
  info = fs.readFileSync(file_path)
  result = re.exec(info)
  fm = result[2]
  content = result[3]
  return fm, content;
}

exports.index = function(req, res){
  index_file_path = '../site/index.html';
  var fm, content;
  fm, content = getcontent(index_file_path)

  res.render('main/index',{
    title: 'home',
    content: content
  })
}

exports.notAuthorized = function(req, res){
  content = "Not Authorized!"

  res.render('main/index',{
    title: 'home',
    content: content
  })
}

exports.generate = function(req, res){
  wv.generate();
  res.redirect('/index.html')
}

exports.generatepage = function(req, res){
  url = wv.generate_post();
  res.redirect(url)
}

exports.generatedata = function(req, res){
  wv.generate_data()
  res.redirect('/')
}

exports.gitcommit = function(req, res){
  var repo = process.env.GIT_REPO
  wv.gitcommit(repo)
  res.redirect('/')
}

exports.sitecommit = function(req, res){
  var repo = process.env.GIT_REPO
  wv.sitecommit(repo)
  console.log("Site Commit Finished")
  res.redirect('/')  
}

exports.updatesoftware = function(req, res){
  var repo = process.env.GIT_REPO
  wv.sitecommit(repo)
  console.log("Software Update Finished")
  res.redirect('/')  
}

exports.articles = function(req, res){
  var fm, content;
  articles_file_path = '../site/articles.html';
  fm, content = getcontent(articles_file_path);
  var tmpl = swig.compile(content);
  console.log(tmpl({}));

  res.render('main/index', {
    title: 'articles',
    content: content
  })
}