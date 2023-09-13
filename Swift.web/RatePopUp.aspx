<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RatePopUp.aspx.cs" Inherits="Swift.web.Exchange.RatePopUp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Today's Rate</title>
    <style>
        .trcolor{
            background-color:#FFFF00 !important;
        }
        .evenStl{
            background:#CC9966;
        }
        .oddStl{
            background:#FFFFCC;
            color:Red !important;
        }

        body{
	        margin:0 auto;
	        padding:0;
	        font-family:Verdana, Geneva, sans-serif;	
        }
        *{margin:0px;}
        .container
        {
	        margin:0 auto;
	        padding:0;
	        background:#b8b8b8;
	        border:1px solid #666;
	        display:block;
	        clear:both;
	        border-radius:0 0 10px 10px;
	        box-shadow:0px 0px 12px 0px;
	        border-top:none;
        }

        .topPanel
        {
	        clear:both;
	        display:block;
	        background:#ed1b24;
	        color:#fff;
	        height:80px;
	        margin-bottom:0px;
        }

        .topPanel .topTitle
        {
	        display:block; 
	        font-size:27px; 
	        font-weight:550; 
	        float:right;
	        padding: 4px 30px 0px 0px;
	        text-align: right;
            width: 50%;
	
        }
        .topPanel .topDate
        {
		        width:35%;
		        display:block;
		        height:inherit;
		        float:left;
		        font-size: 20px;
		        font-weight:600;
		        vertical-align:bottom;
        }
        .bannerDiv
        {
	        clear:both; 
	        display:block; 
	        /*margin-bottom:10px; */
	        padding:-10px 20px; 
	        background:#4fab8f;
        }
        .bannerDiv table
        {
	        width:100%; 
	        padding-left:10px;
	        padding-bottom:5px;
	        color:#fff; 
	        font-size:30px; 
	        font-weight:600;
	        margin-top:-20px;
        }

        .tableDiv
        {
	        /*padding:0 20px 15px;*/
	        clear:both;
	        border-radius:10px;
        }

        .mainTable
        {
	        width:100%;
	        font-family:Verdana, Geneva, sans-serif; 
	        border-radius:10px;
	        margin-top:-10px;
        }

        .mainTable .trHeader td{
	        background:#ed1b24;
	        color:#FFFFFF;
	        font-size:25px;
	        font-weight:600;
	        /*padding:5px 12px;*/
	        text-align:center;
	        }

        .mainTable .trRecord td
        {
	        font-size:18px;
	        padding:3px 12px;
	        text-align:center;
        }
        .endDiv
        {
	        background:#E00024;
	        height:20px;
	        width:100%;
	        display:block;
	        clear:both;
        }

        .clearfix{
	        clear:both;
        }

        .amtField
        {
	        text-align:right; 
	        padding-right:20px;
        }
    </style>
   
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="topPanel" id="AgentInfoDiv" runat="server"></div> 
            <div class="clearfix"></div>
            <div class="bannerDiv" id="AgentBannerDiv" runat="server"></div>
            <div class="tableDiv" id="MainTableDiv" runat="server"></div>
            <input id="rowid" name="rowid" value="" type="hidden"/>
            <asp:HiddenField  id="hdnrowid" runat="server" />
            <asp:HiddenField  id="NoOfData" runat="server" />
         </div>
    </form>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
        <script>
            var table = $(".mainTable tbody");
            var length = table.find('tr').length;
            table.find('tr').each(function (i) {
                var el = $(this);
                if (i == 1) {
                    el.addClass('trcolor');
                }   
                else if (i > 1) {
                    setTimeout(function () {
                        table.find('tr').removeClass('trcolor');
                        el.addClass('trcolor');
                        var $tds = $(el).find('td');
                        var path = '../Images/countryflag/' + $tds.eq(1).text() + ".png";
                        var buy = $tds.eq(2).text() + ' USD = ' + $tds.eq(3).text() + ' KRW';
                        var sell = $tds.eq(2).text() + ' USD = ' + $tds.eq(4).text() + ' ' + $tds.eq(1).text();
                        $("#buying").html(buy);
                        $("#selling").html(sell);
                        $("#customerRate").html($tds.eq(5).text());
                        $("#ImageDesc").html($tds.eq(0).text());
                        $("#CurrImag").attr('src', path);
                        if (i == length-1) {
                            setTimeout(reload, 5000);
                        }
                        
                    }, i * 5000);
                }
            });

            function reload()
            {
                location.reload();
            }
    </script>
</body>
</html>
