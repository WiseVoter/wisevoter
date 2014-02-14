var fs = require('fs')


exports.update = function(req, res){
  path = req.params.content;
  articles_path_read = '../site/'+path+"/_posts/"
  articles_path_write = '../site/'+path+"/_posts/"
  console.log(articles_path_read);
  article_name = req.params.item;

  var content, fm, article_file;

  fs.readdirSync(articles_path_read).forEach(function (file) {
    filere = /^(\d{4}-\d{2}-\d{2})-(.*).md$/
    match = filere.exec(file)
    if (match && match[2] === article_name) {
      re = /^(-{3}(?:\n|\r)([\w\W]+?)-{3})?([\w\W]*)*/
      info = fs.readFileSync(articles_path_read + '/' + file)
      article_file = articles_path_write + file
      result = re.exec(info)
      fm = result[2]
      content = result[3] 
    }
  });

  res.render('articles/edit',{
    title: 'Edit: ' + article_name,
    article: path + '/' + article_name,
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
  file_contents = "---\n" + frontmatter + "---\n" + content;
  fs.writeFileSync(article_file, file_contents)
  console.log("Wrote: " + article_file)
  res.redirect(back_to)
}