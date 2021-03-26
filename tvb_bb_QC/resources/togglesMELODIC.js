
  let view
  let canvas


document.addEventListener('keyup', logKey);


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

  var component_type=document.getElementById("ICA").options[document.getElementById("ICA").selectedIndex].text;

  if(e.code=="KeyQ"){
    var select = document.getElementById('ICA');
    if(select.selectedIndex==0){
      select.selectedIndex=select.length - 1
    }
    else{
        select.selectedIndex--;
    }
    updateTitle();updateImage();update_links();
  }


  if(e.code=="KeyE"){
    var select = document.getElementById('ICA');
    if(select.selectedIndex==select.length - 1){
      select.selectedIndex=0
    }
    else{
      select.selectedIndex++;
    }
    updateTitle();updateImage();update_links();
  }
  if(e.code=="KeyA"){
    var select = document.getElementsByName(component_type)[0];
    if(select.selectedIndex==0){
      select.selectedIndex=select.length - 1
    }
    else{
        select.selectedIndex--;
    }
    updateTitle();updateImage();update_links();
  }


  if(e.code=="KeyD"){
    var select = document.getElementsByName(component_type)[0];
    if(select.selectedIndex==select.length - 1){
      select.selectedIndex=0
    }
    else{
      select.selectedIndex++;
    }
    updateTitle();updateImage();update_links();
  }

  if(e.code=="KeyZ"){
    var select = document.getElementById('Analysis');
    if(select.selectedIndex==0){
      select.selectedIndex=select.length - 1
    }
    else{
        select.selectedIndex--;
    }
    updateTitle();updateImage();update_links();
  }


  if(e.code=="KeyC"){
    var select = document.getElementById('Analysis');
    if(select.selectedIndex==select.length - 1){
      select.selectedIndex=0
    }
    else{
      select.selectedIndex++;
    }
    updateTitle();updateImage();update_links();
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
    view.init()
    view.draw()
  }

  function resetDraw() {
    view.reset()
    view.draw()
  }

  function reDraw() {
    if(document.getElementById('zoom_keep').checked==true){
      resetDraw()
    }
    else{
      initDraw()
    }
  }


  function start(image) {
    canvas = document.getElementById('canvas')
    let img = document.getElementById(image);
    view = new Viewer(canvas, img)
    view.draw()
  }


  function updateTitle(){
    var color="red";
    var component_type=document.getElementById("ICA").options[document.getElementById("ICA").selectedIndex].text;

    for(var i=0;i<document.getElementById("ICA").length;i++){
      var j = document.getElementById("ICA")[i].value;
      document.getElementById(j+"_label").style.display = "none";
    }
    document.getElementById(component_type+"_label").style.display = "inline";



    if (document.getElementsByName(component_type)[0].options[document.getElementsByName(component_type)[0].selectedIndex].text.toUpperCase().startsWith("SIGNAL") ){
      color="green"
    }
    //document.getElementById("analysis_title").innerHTML = document.getElementById("Analysis").options[document.getElementById("Analysis").selectedIndex].text.toUpperCase();

    document.getElementById("analysis_title_0").innerHTML = document.getElementById("ICA").options[document.getElementById("ICA").selectedIndex].text;

    document.getElementById("analysis_title_1").innerHTML = "<div style='color: "+color+"'>"+document.getElementsByName(component_type)[0].options[document.getElementsByName(component_type)[0].selectedIndex].text.toUpperCase()+"</div>";

  }

  function updateImage(){
    var component_type=document.getElementById("ICA").options[document.getElementById("ICA").selectedIndex].text;
    var com = document.getElementById(component_type+"_select").value;
    var ica = document.getElementById("ICA").value;
    var ana = document.getElementById("Analysis").value;

    var del = document.querySelectorAll('div[class^="c_"]')
    for (var i = 0; i < del.length; i++) {
      del[i].style.display = "none";
    } 
    var sel = document.getElementsByClassName("c_"+com+"_"+ica);  
    for (var i = 0; i < sel.length; i++) {
      sel[i].style.display = "inline";
    
    }

    for (var i = 0;i<document.getElementById("Analysis").length; i++) {
      var j = document.getElementById("Analysis")[i].value;
      for (var k=0; k<document.getElementsByName(ica+"_"+com+"_"+j).length; k++){
        document.getElementsByName(ica+"_"+com+"_"+j)[k].style.display = "none";
      }
    }

    for (var k=0; k<3; k++){
      document.getElementById("image_link_"+k).innerHTML = "N/A";
      document.getElementById("image_link_"+k).href = "N/A";
    }

    var new_img = ica+"_"+com+"_"+ana;
    for (var k=0; k<document.getElementsByName(ica+"_"+com+"_"+ana).length; k++){
      document.getElementsByName(new_img)[k].style.display="inline";

      document.getElementById("image_link_"+k).innerHTML = document.getElementsByName(new_img)[k].src;
      document.getElementById("image_link_"+k).href = document.getElementsByName(new_img)[k].src.substring(0,document.getElementsByName(new_img)[k].src.lastIndexOf("/")+1);

      if (document.getElementById("image_link_"+k).innerHTML == ""){
        document.getElementById("image_link_"+k).innerHTML="N/A"
      }

      if(document.getElementById("image_link_"+k).href == ""){
        document.getElementById("image_link_"+k).href="N/A"
      }
    }  

  }


  window.addEventListener("error", function(e) {              // when an error happens
    if(e.target.tagName.toLowerCase() === "img") {          // if the target is an image
        e.target.src = "images/missing.png";                       // then change its src to whatever you want
    }
}, true);





