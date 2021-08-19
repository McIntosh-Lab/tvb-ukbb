
  let view
  let canvas


document.addEventListener('keydown', logKey);


function IgnoreAlpha(e) {
  if (!e) {
    e = window.event;
  }
  if (e.keyCode >= 65 && e.keyCode <= 90) // A to Z
  {
    e.returnValue = false;
    e.cancel = true;
  }
}


function logKey(e) {

  var component_type=document.getElementById("IDPs").options[document.getElementById("IDPs").selectedIndex].text;

  if(e.code=="KeyQ"){
    var select = document.getElementById('IDPs');
    if(select.selectedIndex==0){
      select.selectedIndex=select.length - 1
    }
    else{
        select.selectedIndex--;
    }
    updateTitle();updateImage();
  }


  if(e.code=="KeyE"){
    var select = document.getElementById('IDPs');
    if(select.selectedIndex==select.length - 1){
      select.selectedIndex=0
    }
    else{
      select.selectedIndex++;
    }
    updateTitle();updateImage();
  }


}
/*
q zoom out
w reset
e zoom in
a prev an
s toggle overlay (if not hidden) 
d next an
z 1st ori or b=0 (if not hidden)  
x 2ndr ori or b=1000  (if not hidden) 
c 3rd ori or b=2000  (if not hidden) 

*/

  function initDraw() {
  }

  function resetDraw() {
  }

  function reDraw() {
  }


  function start(image) {
  }


  function updateTitle(){
   
  }

  function updateImage(){
    var e = document.getElementById("IDPs").value;

    for (var x of ["High-priority IDPs","Low-priority IDPs","New TVB IDPs"]){
      if (x == e){
        a = document.getElementsByName(x)
        for (var y of a){
          y.style.display = "";

        }

      }
      else{
        a = document.getElementsByName(x)
        for (var y of a){
          y.style.display = "none";

        }
      }
    }

    if (e == "All IDPs"){
      for (var x of ["High-priority IDPs","Low-priority IDPs","New TVB IDPs"]){
        a = document.getElementsByName(x)
        for (var y of a){
          y.style.display = "";
        }

        
      }
    }


  }


  window.addEventListener("error", function(e) {              // when an error happens
    if(e.target.tagName.toLowerCase() === "img") {          // if the target is an image
        e.target.src = "images/missing.png";                       // then change its src to whatever you want
    }
}, true);





