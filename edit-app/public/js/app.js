console.log("App.js file");

function doContentCopy(){
  console.log("Content copy");
  document.getElementById("contenttextarea").value = 
    document.getElementById("editcontent").innerText;
  document.getElementById("frontmattertextarea").value = 
    document.getElementById("editfrontmatter").innerText;  
  return true;
}