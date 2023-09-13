<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.Functions.TransactionTypeLimit.List" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
</head>
<body>
    <form id="form1" runat="server">
        <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td align="left" valign="top" class="bredCrom">Administration » Agent Function » Transaction Type Limit » List</td>
            </tr>
            <tr>
                <td class="welcome"><%=GetAgentPageTab()%></td>
            </tr>
            <tr>
                <td height="10">
                    <div class="tabs">
                        <ul>
                            <li><a href="../ListAgent.aspx">Agent List </a></li>
                            <li><a href="../BusinessFunction.aspx?agentId=<% Response.Write(GetAgent());%>&aType=<% Response.Write(GetAgentType());%>">Business Function</a></li>
                            <li id="tranTypeLimitTab" runat="server"></li>
                            <li id="depositBankListTab" runat="server"></li>
                            <li id="sendingListTab" runat="server"></li>
                            <li id="receivingListTab" runat="server"></li>
                            <li><a href="../RegionalBranchAccessSetup.aspx?agentId=<% Response.Write(GetAgent());%>&aType=<% Response.Write(GetAgentType());%>">Regional Access Setup</a></li>
                        </ul>
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