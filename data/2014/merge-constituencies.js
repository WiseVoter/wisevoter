var _ = require('lodash'),
    fs = require('fs'),
    swig = require('swig'),
    yaml = require('js-yaml');

var batch1 = [];
var batch2 = [];

function readBatches(data_dir, batch, ignoreContent, addFile) {
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
    batch.push(fm)
  })
}

function writeFile(path, info){
  var tmpl = fs.readFileSync('../adr/constituencies-2014.md.tmpl')
  swig.setDefaults({ autoescape: false, loader: swig.loaders.fs('../adr/') })
  var fm = swig.renderFile('constituencies-2014.md.tmpl', info) 
  fs.writeFileSync(path, fm)
}

readBatches('../../site/constituencies/_posts/', batch1, false, true)
readBatches('../adr/constituencies/', batch2, true, true)

console.log("Batch Old: " + batch1.length)
console.log("Batch New: " + batch2.length)

var index1 = _.groupBy(batch1, function(o){return o.title})

_.each(batch2, function(item){
  var roughMatch = index1[item.title]
  if (roughMatch) {
    var merge = false
    //console.log("Rough Match " + roughMatch.length + "for: " + item.title)
    if (roughMatch.length > 1) { console.log ("Two or more profiles in batch1")}
    if (roughMatch[0].state === item.state){
      console.log("Exact STATE Match for: " + item.title)
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
                        else if (a && b == null) {return a}
                        else if (b && a == null) {return b}
                        else if (a === null && b === null) { return "" }
                        return undefined;
                      })
      var filename = "2014-04-10-" + item.title.toLowerCase().replace(/ /g,'-');
      var filePath = '../adr/constituencies2/' + filename + ".md"
      writeFile(filePath, info)
      console.log("Deleting " + fileToDelete)
      fs.unlinkSync('../../site/constituencies/_posts/' + fileToDelete)
      fs.renameSync('../adr/constituencies2/' + item.file, '../adr/dups/' + item.file)
    }
  }
})
