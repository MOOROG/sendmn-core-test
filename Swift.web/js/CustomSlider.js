var imgList = [];
var DescList = [];
var index = 0;
function MakeImageSlider(controlName, images, imgDesc) {
    imgList = images;
    DescList = imgDesc;
    //alert(DescList[0]);
    var sb = "";
    sb = sb.concat("<div style=\"margin:auto;height:200px;background-color:#DBEAF9\" >");
    sb = sb.concat("<div style=\"width:60%;float:right\">");
    sb = sb.concat("<div id=\"bannerDesc\" style=\"width:60%;float:right\"></div>");
    sb = sb.concat("</div>");
    //banner Image
    sb = sb.concat("<div style=\"width:40%;margin-right:5px;\">");
    sb = sb.concat("<img id=\"loadImage\"  src=\"Images/Slider/" + imgList[0] + "\" Height=\"183\" Width=\"333\" />");
    sb = sb.concat("</div>");
    sb = sb.concat("</div>");
    //bubble image position
    sb = sb.concat("<div style=\"width:50%;height:10px;float:right;\">");
    for (var i = 0; i < imgList.length; i++) {
        var id = "s" + i;
        sb = sb.concat("<span id=\"" + id + "\" onclick=\"LoadImage(" + i + ");\" class=\"Default\" ><img src=\"Images/default1.png\" alt='' /></span> &nbsp;");
    }
    sb = sb.concat("</div>");

    document.getElementById(controlName).innerHTML = sb;
}
function LoadImage(id) {
    var img = imgList[index];
    //alert(DescList[index]);
    document.getElementById("loadImage").setAttribute("src", "Images/Slider/" + img);

    for (var i = 0; i < imgList.length; i++) {
        document.getElementById("s" + i).innerHTML = "<img src='Images/default1.png' alt='' />";
    }
    document.getElementById("s" + index).innerHTML = "<img src='Images/active1.png' alt='' />";
    document.getElementById("bannerDesc").innerHTML = DescList[index];
}
setInterval(function () {
    //alert("Hello");

    LoadImage(index)
    index = index + 1;
    if (index == imgList.length)
        index = 0;
}, 1000);