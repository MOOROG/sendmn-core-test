<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.Functions.ReceivingCountry.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" />
    <link href="../../../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../../../js/Jsfunc.js" type="text/javascript"> </script>
    <script src="../../../../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
</head>
<body>
    <form id="form1" runat="server">

        <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td height="26" class="bredCrom">
                    <div>Administration » Agent Function » Receiving Country List </div>
                </td>
            </tr>
            <tr>
                <td class="welcome"><%=GetAgentPageTab()%></td>
            </tr>
            <tr>
                <td height="10" width="100%">
                    <div class="tabs">
                        <ul>
                            <li id="businessFunctionTab" runat="server"></li>
                            <li id="depositBankListTab" runat="server"></li>
                            <%--<li id="sendingList" runat="server"> </li>
                        <li id="receivingListTab" runat="server"></li>--%>
                            <li id="RegionalBranchAccessSetup" runat="server"></li>
                            <li id="AgentGroupMaping" runat="server"></li>
                            <li id="SendingCountryList" runat="server"></li>
                            <li><a href="#" class="selected">Receiving Country List</a></li>
                        </ul>
                    </div>
                </td>
            </tr>
            <tr>
                <td height="10" width="100%">
                    <div class="tabs" id="listDiv" runat="server">
                    </div>
                </td>
            </tr>
            <tr>
                <td height="524" valign="top">
                    <%-- <h2>Inclusive</h2> --%>
                    <table border="0" cellspacing="0" cellpadding="0" width="50%" align="left">
                        <tr>
                            <td height="524" valign="top" style="overflow: scroll;">

                                <div id="rpt_inGrid" runat="server" class="gridDiv"></div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <%-- <tr>
            <td height="524" valign="top">
                <h2>Exclusive</h2>
                <table border="0" cellspacing="0" cellpadding="0" width="50%" align="left">
                    <tr>
                        <td height="524" valign="top" style="overflow: scroll;">

                            <div id = "rpt_exGrid" runat = "server" class = "gridDiv"></div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>--%>
        </table>
    </form>
</body>
</html>