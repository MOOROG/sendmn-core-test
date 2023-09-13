<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DoLuckyDraw.aspx.cs" Inherits="Swift.web.OtherServices.LuckyDraw.DoLuckyDraw" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../../Images/luckydraw/spin.min.js"></script>
    <script src="../../../Images/luckydraw/jquery.animateNumber.min.js" type="text/javascript"></script>
    <%--<script src="../../../js/jquery.min.js" type="text/javascript"></script>--%>
    <script src="../../../Images/luckydraw/jquery.color.min.js"></script>
    <script src="../../../Images/luckydraw/jquery.animateNumber.min.js"></script>

    <style>
        * {
            margin: 0;
            padding: 0;
        }

        table {
            border-spacing: 0;
            padding: 0;
            width: 100%;
        }

        .bg-panel-img {
            background: rgba(0, 0, 0, 0) url("../../../Images/luckydraw/daily-start.jpg") no-repeat scroll 0 0;
            height: auto;
            position: fixed;
            top: 20px;
            width: 100%;
            z-index: -1;
        }

        .btn-start {
            background-image: url("../../../Images/luckydraw/btn_red.jpg");
            border: medium none;
            top: 50%;
            cursor: pointer;
            height: 150px;
            position: absolute;
            width: 150px;
            right: 50px;
        }

        .panel-details {
            color: Black;
            display: none;
            font-family: Calibri;
            font-size: 20px;
            font-weight: bold;
            position: absolute;
            right: 0;
            top: 48%;
            width: 550px;
        }

        .panel-congratulations {
            background: url(../../../Images/luckydraw/congrats.jpg) no-repeat;
            width: 250px;
            height: 69px;
            position: absolute;
            right: 15%;
            top: 70%;
            display: none;
            position: absolute;
            z-index: 999;
        }

        .loading {
            position: absolute;
            width: 150px;
            height: 150px;
            margin: -77px;
            position: absolute;
            bottom: 0;
            right: 40%;
            border: none;
            top: 55%;
        }

        .textColor {
            color: Red;
            font-family: Calibri;
            font-size: 24px;
            font-weight: 900;
        }
    </style>

    <script type="text/javascript">

         var numcount = 0;
         $(document).ajaxStart(function () {
             $("#trProcessing").show();
             document.getElementById("btnStart").style.display = "none";
         });

         $(document).ajaxComplete(function (event, request, settings) {
             $("#trProcessing").hide();
         });

         function StartLuckydraw() {
             numcount++;
             $("#btnStart").hide();
             document.getElementById("onClickShowDetails").style.display = "none";
             GetElement("lblName").innerHTML = "";
             GetElement("lblDate").innerHTML = "";
             GetElement("lblPrize").innerHTML = "";
             GetElement("lblCountry").innerHTML = "";
             GetElement("lblIcn").innerHTML = "";
             GetElement("lines").innerHTML = "";
             var flag = "";

             var dataToSend = { MethodName: "StartLuckydraw", flag: flag };
             var options =
                            {
                                url: '<%=ResolveUrl("DoLuckyDraw.aspx") %>?x=' + new Date().getTime(),
                                data: dataToSend,
                                dataType: 'JSON',
                                type: 'POST',
                                success: function (response) {
                                    //alert(response);
                                    var data = response;
                                    ShowResponseData(data);
                                }
                            };
             $.ajax(options);
         }
         function ShowResponseData(data) {
             data = JSON.parse(data);
             for (var i = 0; i < data.length; i++) {
                 if (data[i].ErrorCode == "0") {
                     if (i==0) {
                         $("#span1").show();
                         $("#span1").html("<u>First Winner </u><br /> " + data[i].Name + " , JME No : " + data[i].Pin);
                         $("#divDetails").attr("style","height:600px !important;");
                     }
                     else if (i == 1) {
                         $("#span2").show();
                         $("#span2").html("<br /><u>Second Winner </u><br /> " + data[i].Name + " , JME No : " + data[i].Pin);
                         $("#divDetails").attr("style", "height:530px !important;");
                     }
                     else if (i == 2) {
                         $("#span3").show();
                         $("#span3").html("<br /><u>Third Winner </u><br /> " + data[i].Name + " , JME No : " + data[i].Pin);
                         document.getElementById("onClickShowCongrats").style.display = "inline-block";
                         document.getElementById("btnStart").style.display = "none";
                     }

                 }
                 else if (data[i].ErrorCode == "1") {
                     $("#tddetail").show();
                     var iccn = data[i].Pin;
                     ShowDetail(iccn);
                     GetElement("lblIcn").innerHTML = iccn;
                     Animation(iccn, data[i]);
                 }
             }

             //if (data["ErrorCode"] == "1") {
             //    $("#tddetail").show();
             //    ShowDetail(data.Pin);
             //    GetElement("lblIcn").innerHTML = data.Pin;
             //    var iccn = data.Pin;
             //    //$('#lines').animateNumber({ number: iccn }, 5000);

             //}
             if (data.length == 0) {

                 alert("No record found.");
             }
         }
        function Animation(icn,data) {
            var decimal_places = 2;
            var decimal_factor = 9831232;

            $('#lines').animateNumber(
                {
                    number: 100 * decimal_factor,
                    numberStep: function (now, tween) {

                        var floored_number = Math.floor(now) / decimal_factor,
                            target = $(tween.elem);
                        floored_number = floored_number.toFixed(11);
                        var split = floored_number.split('.');
                        target.text(split[1]);
                        if (split[0] == 100) {
                            target.text(icn);
                            GetElement("lblName").innerHTML = data.Name;
                             GetElement("lblDate").innerHTML = data.Date;
                             GetElement("lblPrize").innerHTML = data.Prize;
                             GetElement("lblCountry").innerHTML = data.Country;
                             document.getElementById("onClickShowCongrats").style.display = "inline-block";
                             document.getElementById("btnStart").style.display = "block";
                        }
                    }
                },
                15000
  );
            if (numcount==3) {
                document.getElementById("btnStart").style.display = "none";
            }
        }
</script>
</head>
<body>
    <form id="form1" runat="server">
        <div style="position: relative; overflow: hidden; width: 40%; left: 765px; top: 160px" id="divWinner">
            <table>
                <tr>
                    <th id="span1" width="67" align="center" style="font-size: 25px; color: #d81e27; display: none"></th>
                </tr>
                <tr>
                    <th id="span2" width="67" align="center" style="font-size: 25px; color: #199d9e; display: none"></th>
                </tr>
                <tr>
                    <th id="span3" width="67" align="center" style="font-size: 25px; color: #ffb419; display: none"></th>
                </tr>
            </table>
        </div>

        <div style="position: relative; overflow: hidden; height: 640px; width: 100%;" id="divDetails" runat="server">
            <asp:Image ID="mainImage" class="bg-panel-img" runat="server" ImageUrl="../../../Images/luckydraw/daily-start.jpg" />

            <input type="button" onclick="StartLuckydraw();" class="btn-start" id="btnStart" />
            <img id="trProcessing" src="../../../Images/luckydraw/Processing.png" class="loading" style="display: none" alt="" />
            <br />

            <div class="panel-details" id="onClickShowDetails">
                <table>
                    <tr>
                        <th width="67" align="left" class="textColor">JME No :</th>
                        <td width="249">&nbsp;&nbsp;<span id="lines" class="textColor"></span><asp:Label ID="lblIcn" runat="server" Text="" Style="display: none;" /></td>
                    </tr>
                    <tr>
                        <th align="left" class="textColor">Name :</th>
                        <td id="hiddenName">&nbsp;&nbsp;<asp:Label ID="lblName" runat="server" Text="" class="textColor"></asp:Label></td>
                    </tr>
                    <tr>
                        <th align="left" class="textColor">Date :</th>
                        <td nowrap>&nbsp;&nbsp;<asp:Label ID="lblDate" runat="server" Text="" class="textColor"></asp:Label></td>
                    </tr>
                    <tr>
                        <th align="left" class="textColor">Prize :</th>
                        <td>&nbsp;&nbsp;<asp:Label ID="lblPrize" runat="server" Text="" class="textColor"></asp:Label></td>
                    </tr>
                    <tr style="display: none;">
                        <th align="left" class="textColor">Country :</th>
                        <td id="hiddenCountry">&nbsp;&nbsp;<asp:Label ID="lblCountry" runat="server" Text="" class="textColor"></asp:Label></td>
                    </tr>
                </table>
            </div>

            <div class="panel-congratulations" id="onClickShowCongrats"></div>
        </div>

        <div id="main" runat="server" visible="false"></div>
        <asp:HiddenField ID="hdnType" runat="server"></asp:HiddenField>
    </form>
</body>
</html>
<script type="text/javascript">

function ShowDetail(pin){
	document.getElementById("onClickShowDetails").style.display="inline-block";

	}
</script>

<script type="text/javascript">
        var opts = {
            lines: 13, // The number of lines to draw
            length: 20, // The length of each line
            width: 9, // The line thickness
            radius: 37, // The radius of the inner circle
            corners: 1, // Corner roundness (0..1)
            rotate: 90, // The rotation offset
            direction: 1, // 1: clockwise, -1: counterclockwise
            color: '#F00', // #rgb or #rrggbb or array of colors
            speed: 0.9, // Rounds per second
            trail: 20, // Afterglow percentage
            shadow: true, // Whether to render a shadow
            hwaccel: false, // Whether to use hardware acceleration
            className: 'spinner', // The CSS class to assign to the spinner
            zIndex: 2e9, // The z-index (defaults to 2000000000)
            top: '0', // Top position relative to parent in px
            left: '320' // Left position relative to parent in px
        };
        var target = document.getElementById('divSpinner');
        var spinner = new Spinner(opts).spin(target);
</script>