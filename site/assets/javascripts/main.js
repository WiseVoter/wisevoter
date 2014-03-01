var mainsite = "www.wisevoter.org"
  , editsite = "edit.wisevoter.org";

function setEditorLink(){
  var editorLink = document.getElementById("editorLink")
  if (document.location.hostname === mainsite)
    editorLink.href = editorLink.href.replace(mainsite,editsite);
  return false;
}

window.onload = function(){
  setEditorLink();
}