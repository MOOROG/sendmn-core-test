<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="History.aspx.cs" Inherits="Swift.web.Remit.DomesticOperation.UserWiseTxnLimit.History" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
</head>
<body>
    <form id="form1" runat="server">
        <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>

                <td width="100%">
                    <asp:Panel ID="pnl1" runat="server">
                        <table width="100%">
                            <tr>
                                <td height="26" class="bredCrom">
                                    <div>Domestic Operation » User Wise Txn Limit » History </div>
                                </td>
                            </tr>
                            <tr>
                                <td height="20" class="welcome"></td>
                            </tr>
                            <tr>
                                <td>&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;  <span class="welcome">User Name :
                                    <asp:Label ID="userName" runat="server"></asp:Label></span></td>
                            </tr>
                        </table>
                    </asp:Panel>
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