//(require 'jquery)

/* table-of-contents */
window.ego_toc = $('#text-table-of-contents ul li');
if(0 != window.ego_toc.length){
    window.ego_toc_h = $('#table-of-contents h2');
    window.ego_toc_h_text = $('#table-of-contents h2').text();
    window.ego_n = 0;
    window.ego_tmp = ego_n;
    window.ego_head = $(':header').filter('[id*=org]');
    $(window).scroll(function () {
        var startPoint=0;
        var endPoint=ego_head.length-1;
        var offsetValue=window.pageYOffset+60;
        if(ego_head.eq(ego_tmp).offset().top>offsetValue || offsetValue>ego_head.eq((ego_tmp+1)>(ego_head.length-1)?(ego_head.length-1):(ego_tmp+1)).offset().top){
            while((startPoint+1) < endPoint){
                if(ego_head.eq(Math.floor((startPoint+endPoint)/2)).offset().top > offsetValue){
                    endPoint = Math.floor((startPoint+endPoint)/2);
                }
                else if(ego_head.eq(Math.floor((startPoint+endPoint)/2)).offset().top < offsetValue){
                    startPoint = Math.floor((startPoint+endPoint)/2);
                }
                else{
                    break;
                }
            }
            if(offsetValue>ego_head.eq(ego_head.length-1).offset().top){
                ego_n=ego_head.length-1;
            }
            else{
                ego_n = startPoint;
            }

            ego_toc.eq(ego_tmp).children('a').css('color', '#ffff00');
            ego_tmp = ego_n;
            ego_toc.eq(ego_tmp).children('a').css('color', '#22ff22');
            if(window.pageYOffset < 10){
                ego_toc_h[0].textContent = ego_toc_h_text;
            }
            else{
                ego_toc_h[0].textContent = ego_toc.eq(ego_tmp)[0].children.item(0).textContent;
            }
            //ego_n = parseInt(ego_str.slice(-1));
        }
    });}

/* floating card */
function popupActivate (evt) {
    var boundBox = evt.target.getBoundingClientRect();
    var coordX = boundBox.left;
    var coordY = boundBox.top;
    balloon.style.position="fixed";
    balloon.style.left= coordX.toString() + "px";
    balloon.style.top= (coordY + 30).toString() + "px";

    if(evt.target.firstChild.parentNode.nextSibling.tagName == "SUP"){
        var footRef = evt.target.nextSibling.childNodes[0].id;
        var docNode = document.getElementById("fn."+footRef.slice(4));
        var nodeNew = docNode.parentNode.parentNode.cloneNode(true);
        balloon.replaceChild(nodeNew,balloon.lastChild);
        balloon.style.visibility="visible";
    }
    if(balloon.getBoundingClientRect().right > window.innerWidth){
        balloon.style.width=(window.innerWidth-coordX-5).toString()+"px";
    }
}

function popupOff(evt) {
    balloon.style.visibility="hidden";
}

function ls_init () {

    // create balloon element, insert as first child of refNode
    function createBalloon (refNode) {
        // create balloon element to display info
        balloon = document.createElement("div");
        balloon.style.visibility="hidden";
        balloon.style.position="fixed";
        balloon.style.top=".5ex";
        balloon.style.left=".5ex";
        balloon.style.padding=".5ex";
        balloon.style.textAlign="left";
        balloon.style.border="solid thin green";
        balloon.style.borderRadius="1ex";
        balloon.style.backgroundColor="hsla(182, 80%, 20%, 0.8)";
        balloon.style.boxShadow="3px 3px 8px black";
        balloon.style.zIndex="341";
        balloon.innerHTML="<p>tips</p>";
        // insert into DOM
        refNode.insertBefore(balloon, refNode.firstChild);
    }

    var myList = document.querySelectorAll(".underline");

    // assign handler to hot hoover elements
    if ( myList.length > 0 ) {
        for (var ii = 0; ii < myList.length; ii++) {
            var myNode = myList[ii];
            myNode.addEventListener("mouseover", popupActivate , false);
            myNode.addEventListener("mouseout", popupOff , false);
        }
    }

    createBalloon(document.body);
}

var balloon;

ls_init();

/* change style*/

$('.post-meta').insertAfter('.title').css('margin-bottom','15px').css('text-align','center');
