<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="txnMsgList.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.MessageSetting.txnMsgList" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
</head>
<body>
    <form id="form1" runat="server">
    <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
        
            <td width="100%"> 
                <asp:Panel ID="pnl1" runat="server">
                    <table width="100%">
                        <tr>
                            <td height="26" class="bredCrom"> <div > Application Setting » Transaction Message Setting » List </div> </td>
                        </tr>
                        <tr>
                            <td height="20" class="welcome"></td>
                        </tr>
                        <tr>
                            <td height="10" width="100%"> 
                                <div class="tabs" > 
                                    <ul> 
                                        <li> <a href="Javascript:void(0)" class="selected">List</a></li>
                                    </ul> 
                                </div>		
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td height="524" valign="top">
                <div id = "rpt_grid" runat = "server" class = "gridDiv"></div>
            </td>
        </tr>
    </table>
</form>
</body>
</html>