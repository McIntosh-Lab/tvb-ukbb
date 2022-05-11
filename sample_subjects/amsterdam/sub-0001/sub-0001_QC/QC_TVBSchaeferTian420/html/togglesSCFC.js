  
document.addEventListener('keydown', logKey);
//document.addEventListener('keyup', logKey);


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
  if(e.code=="KeyI"){
    view.pan(0,75);
  }
  if(e.code=="KeyK"){
    view.pan(0,-75);
  }
  if(e.code=="KeyJ"){
    view.pan(75,0);
  }
  if(e.code=="KeyL"){
    view.pan(-75,0);
  }
  if(e.code=="KeyQ"){
    view.scale(0.85);
  }
  if(e.code=="KeyW"){
    initDraw();
  }
  if(e.code=="KeyE"){
    view.scale(1.15);
  }
  if(e.code=="KeyA"){
    var select = document.getElementById('Analysis');
    if(select.selectedIndex==0){
      select.selectedIndex=select.length - 1
    }
    else{
      if (select[select.selectedIndex - 1].value == "../../../EDDY_SQUAD/group_qc.pdf"){
        select.selectedIndex = select.selectedIndex - 3;
      }
      else{
        select.selectedIndex--;
      }

      


    }
    updateTitle();updateImage();update_links();
  }
  if(e.code=="KeyS"){
    var select = document.getElementById('Overlay check');
    
    if (select.checked==true){
      select.checked = false;
    }
    else{
      select.checked = true;
    }

    var select1 = document.getElementById('Order 1');
    var select2 = document.getElementById('Order 2');
    
    if (select1.checked==true){
      select2.checked = true;
    }
    else{
      select1.checked = true;
    }

    updateTitle();updateImage();update_links();
  }


  if(e.code=="KeyD"){
    var select = document.getElementById('Analysis');
    console.log(select.value)
    if(select.selectedIndex==select.length - 1){
      select.selectedIndex=0
      console.log(1)
    }
    else{
      if (select[select.selectedIndex + 1].value == "../eddyQUAD/data.qc/qc.pdf"){
        select.selectedIndex = select.selectedIndex + 3;
        console.log(2)
      }
      else{
        select.selectedIndex++;
        console.log(3)
      }
    }
    updateTitle();updateImage();update_links();
  }

  if(e.code=="KeyZ"){
    var select = document.getElementById('Orientation');
    select.selectedIndex="0";

    var select = document.getElementById('b-value');
    select.selectedIndex="0";
    updateTitle();updateImage();update_links();
  }
  if(e.code=="KeyX"){
    var select = document.getElementById('Orientation');
    select.selectedIndex="1";

    var select = document.getElementById('b-value');
    select.selectedIndex="1";
    updateTitle();updateImage();update_links();
  }
  if(e.code=="KeyC"){
    var select = document.getElementById('Orientation');
    select.selectedIndex="2";

    var select = document.getElementById('b-value');
    select.selectedIndex="2";
    updateTitle();updateImage();update_links();
  }
  if(e.code=="KeyR"){

    var select = document.getElementById('zoom_keep');
    
    if (select.checked==true){
      select.checked = false;
    }
    else{
      select.checked = true;
    }
    
  }
}

  function updateTitle(){

    document.getElementById("analysis_title").innerHTML = document.getElementById("Analysis").options[document.getElementById("Analysis").selectedIndex].text.toUpperCase();

  }

  function updateImage(){

    var ana = document.getElementById("Analysis").value;
    var anaid = document.getElementById("Analysis")[document.getElementById("Analysis").selectedIndex].id;
    
    var del = document.querySelectorAll('div[class^="group_"]')
    for (var i = 0; i < del.length; i++) {
      del[i].style.display = "none";
    } 

    var sel = document.getElementsByClassName(ana);  
    for (var i = 0; i < sel.length; i++) {
      sel[i].style.display = "inline";
    
    } 

    document.getElementById('im1').innerHTML="N/A"
    document.getElementById('im2').innerHTML="N/A"
    document.getElementById('im3').innerHTML="N/A"
    document.getElementById('im1').src="N/A"
    document.getElementById('im2').src="N/A"
    document.getElementById('im3').src="N/A"

    var images_to_link = document.getElementsByClassName(anaid);
    for (var i = 0; i < images_to_link.length; i++) {
      var name = 'im'.concat(i+1);
      console.log(name)
      
      document.getElementById(name).innerHTML=images_to_link[i].src
      document.getElementById(name).href=images_to_link[i].src.substring(0,images_to_link[i].src.lastIndexOf("/")+1);
    } 
    
    
  }


  window.addEventListener("error", function(e) {              // when an error happens
    if(e.target.tagName.toLowerCase() === "img") {          // if the target is an image
        e.target.src = "images/missingw.png";                       // then change its src to whatever you want
    }
}, true);





