var fs = require('fs')

var data_dir = '../../site/assets/images/politicians/'
fs.readdirSync(data_dir).forEach(function(file) {
  var newfile = file.toLowerCase().replace(/ /g,'-')
  fs.rename(data_dir+file, data_dir+newfile, function(err){
    console.log('rename callback', err)
    console.log(newfile)
  })
}); 