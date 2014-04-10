var _ = require('lodash'),
    fs = require('fs'),
    swig = require('swig'),
    yaml = require('js-yaml');

var batch1 = [];
var batch2 = [];

function readBatches(data_dir, batch, ignoreContent, addFile, year) {
  fs.readdirSync(data_dir).forEach(function(file) {
    var file_path = data_dir + "/" + file
    var re = /^(-{3}(?:\n|\r)([\w\W]+?)-{3})?([\w\W]*)*/
    var info = fs.readFileSync(file_path)
    var result = re.exec(info)
    var fm = yaml.load("---\n"+result[2])
    if (! ignoreContent) {
      fm.content = result[3]
    }
    if (addFile) {
      fm.file = file
    }
    _.each(fm['crime-record'], function(item) {item.year = year})
    fm.crimerecord = fm['crime-record']
    batch.push(fm)
  })
}

function writeFile(path, info){
  var tmpl = fs.readFileSync('../adr/politician-2014.md.tmpl')
  swig.setDefaults({ autoescape: false, loader: swig.loaders.fs('../adr/') })
  var fm = swig.renderFile('politician-2014.md.tmpl', info) 
  fs.writeFileSync(path, fm)
}

readBatches('../../site/politicians/_posts/', batch1, false, true, "2009")
readBatches('../adr/politicians2/', batch2, true, true, "2014")

console.log("Batch Old: " + batch1.length)
console.log("Batch New: " + batch2.length)

var index1 = _.groupBy(batch1, function(o){return o.title})

_.each(batch2, function(item){
  var roughMatch = index1[item.title]
  if (roughMatch) {
    var merge = false
    //console.log("Rough Match " + roughMatch.length + "for: " + item.title)
    if (roughMatch.length > 1) { console.log ("Two or more profiles in batch1")}
    if (roughMatch[0].profile['date-of-birth'] === item.profile['date-of-birth']){
      console.log("Exact DOB Match for: " + item.title)
      merge = true;
    }
    if (roughMatch[0].profile.constituency === item.profile.constituency) {
      console.log("Exact constituency Match for: " + item.title)
      merge = true;
    }
    if (merge){
      var fileToDelete = roughMatch[0].file
      var info = _.merge(roughMatch[0],item, function(a,b){
                        if(_.isArray(a)){
                          return (! _.isEmpty(b)) ? a.concat(b) : a
                        }
                        else if(_.isArray(b)){
                          return a ? b.concat(a) : b
                        }
                        else if (a === null && b === null) { return "" }
                        return undefined;
                      })
      var filename = "2014-04-10-" + item.title.toLowerCase().replace(/ /g,'-');
      var filePath = '../adr/politicians/' + filename + ".md"
      writeFile(filePath, info)
      console.log("Deleting " + fileToDelete)
      fs.unlinkSync('../../site/politicians/_posts/' + fileToDelete)
      fs.renameSync('../adr/politicians2/' + item.file, '../adr/dups/' + item.file)
    }
  }
})
