<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="History.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.BalanceTopUp.History" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../../css/TranStyle.css" rel="stylesheet" type="text/css" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../calendar/calendar_us.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td height="26" class="bredCrom">
                    <div>Domestic Operation » Balance Top Up » History List </div>
                </td>
            </tr>
            <tr>
                <td height="20" class="welcome"></td>
            </tr>
            <tr>
                <td height="26" class="subHeading">
                    <div>
                        <asp:Label ID="lblAgentName" runat="server"></asp:Label>
                    </div>
                </td>
            </tr>
            <tr>
                <td height="524" valign="top">
                    <div id="rpt_grid" runat="server" class="gridDiv"></div>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>