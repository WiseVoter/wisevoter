var fs = require('fs');

var data_dir = '../../site/politicians/_posts/'
fs.readdirSync(data_dir).forEach(function(file) {
  if (! /^(.*).md$/.test(file)) {
    console.log(file)
    fs.renameSync(data_dir + file, data_dir + file + ".md")
  }
})
