<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LoginSession.aspx.cs" Inherits="Swift.web.LoginSession" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>User session</title>
    <link href="css/style.css" rel="stylesheet" type="text/css" />
    <style>
        .messageBoard {
            background: url("images/error-icon.png") no-repeat scroll 3% 35% transparent;
            border: 1px solid #E00024;
            border-radius: 5px 5px 5px 5px;
            height: 105px;
            margin: 35px auto;
            padding: 10px 20px;
            width: 560px;
        }

        .messageBlock {
            clear: both;
            color: Red;
            margin: 15px 10px 15px 60px;
            font-size: 14px;
        }

        #mes {
        }

        .optionDiv {
            clear: both;
            margin: 25px auto;
            text-align: center;
            width: auto;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="messageBoard">
            <div class="messageBlock">
                <div id="mes" runat="server" style="font-size: 18px;" align="center"></div>
            </div>
            <div class="optionDiv" style="width: auto; clear: both; margin: 0 auto;">
                <asp:Button ID="btnClearSession" runat="server" Text="Clear Session"
                    CssClass="button" OnClick="btnClearSession_Click" />
                <asp:Button ID="btnContinue" runat="server" Text="Continue To Login"
                    CssClass="button" Visible="false" OnClick="btnContinue_Click" />
            </div>
        </div>
    </form>
</body>
</html>