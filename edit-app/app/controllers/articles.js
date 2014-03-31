var fs = require('fs')
var wv = require("./base")

exports.show = function(req, res){

}

exports.add = function(req, res){
  console.log("Add function")
  res.render('articles/add', {
    title: 'Adding New Content',
    info: req.flash("info"),
    frontmatter: "",
    content: ""
  })
}

exports.update = function(req, res){
  var content, fm, article_file, article_name, article_url_path;
  var path = req.params.content;
  /* TODO: Need to refactor repeating code below */
  if (path.indexOf(".html") != -1) {
    article_name = path
    article_file = "../site/" + article_name
    article_url_path = path
    info = fs.readFileSync(article_file)
    re = /^(-{3}(?:\n|\r)([\w\W]+?)-{3})?([\w\W]*)*/
    result = re.exec(info)
    fm = result[2]
    content = result[3]
  }
  else {
    articles_path_read = '../site/'+path+"/_posts/"
    articles_path_write = '../site/'+path+"/_posts/"
    console.log(articles_path_read);
    article_name = req.params.item;

    fs.readdirSync(articles_path_read).forEach(function (file) {
      filere = /^(\d{4}-\d{2}-\d{2})-(.*).md$/
      match = filere.exec(file)
      if (match && match[2] === article_name) {
        re = /^(-{3}(?:\n|\r)([\w\W]+?)-{3})?([\w\W]*)*/
        info = fs.readFileSync(articles_path_read + '/' + file)
        article_file = articles_path_write + file
        article_url_path = path + "/" + article_name
        result = re.exec(info)
        fm = result[2]
        content = result[3] 
      }
    });
  }

  res.render('articles/edit',{
    title: 'Edit: ' + article_name,
    info: req.flash("info"),
    article: article_url_path,
    article_file: article_file,
    frontmatter: fm,
    content: content
  })
}

exports.save = function(req, res){
  var content = req.body.content;
  var frontmatter = req.body.frontmatter;
  var article_file = req.body.article_file;
  var back_to = req.body.backto_url;
  file_contents = "---\n" + frontmatter + "---" + content;
  fs.writeFileSync(article_file, file_contents)
  console.log("Wrote: " + article_file)
  checkurl = wv.generate_post(article_file, back_to.replace("edit",""))
  req.flash("info", article_file + " saved! Review it at " + checkurl)
  res.redirect(back_to)
}