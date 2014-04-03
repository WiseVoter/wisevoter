var mainsite = "www.wisevoter.org"
  , editsite = "edit.wisevoter.org";

function setEditorLink(){
  var editorLink = document.getElementById("editorLink")
  if (document.location.hostname === mainsite) {
    editorLink.href = editorLink.href.replace(mainsite,editsite);
  }
  return false;
}

window.onload = function(){
  setEditorLink();
}

// instantiate the bloodhound suggestion engine
var search = new Bloodhound({   
  datumTokenizer: function(d) {
      return Bloodhound.tokenizers.whitespace(d.text); 
    },
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '../../search.json'
});
 
// initialize the bloodhound suggestion engine
search.initialize();

// instantiate the typeahead UI
$('.search-input').typeahead(null, {
  displayKey: 'href',
  source: search.ttAdapter(),
  templates: {
    suggestion: Handlebars.compile([
        '<div class="search-elem">',
        '<p class="search-text">{{text}}</p>',
        '<p class="search-category">{{category}}</p>',
        '<p class="search-href">{{href}}</p>',
        '</div>'
    ].join(''))
  }
});

function searchSubmit(){
  var datum = $('.tt-input').val();
  if (datum.indexOf('/') != -1)
  {
    var redirect_to = window.location.protocol + "//" + window.location.host + datum + "/";
    window.location = redirect_to;
    return false;
  }
  return true;
}

$('.search-input').bind('typeahead:selected', function(obj, datum, name){
  console.log(datum)
  if (datum.href.indexOf('/') != -1)
  {
    var redirect_to = window.location.protocol + "//" + window.location.host + datum.href + "/";
    window.location = redirect_to;
    return false;
  }
  return true;  
})