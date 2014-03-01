var mainsite = "www.wisevoter.org"
  , editsite = "edit.wisevoter.org";

function setEditorLink(){
  var editorLink = document.getElementById("editorLink")
  if (document.location.hostname === mainsite)
    editorLink.href = document.location.replace(mainsite, editsite) + editorLink.href;
  return false;
}

window.onload = setEditorLink;