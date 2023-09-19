
  function toggNav() {
    if (document.getElementById("mySidebar").style.width == "450px"){
      document.getElementById("mySidebar").style.width = "0";
      document.getElementById("main").style.marginLeft= "0";
    }
    else{
      document.getElementById("mySidebar").style.width = "450px";
      document.getElementById("main").style.marginLeft = "450px";
    }
    
  }

    var popup = document.getElementById('mySidebar');
      document.onclick = function(e){
          if((e.target.id != 'mySidebar')&&(e.target.id != 'togglebutton')){
              document.getElementById("mySidebar").style.width = "0px";
              document.getElementById("main").style.marginLeft = "0px";
          }
      };
