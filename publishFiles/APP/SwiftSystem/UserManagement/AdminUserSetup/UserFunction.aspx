<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserFunction.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AdminUserSetup.UserFunction" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />

    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />

</head>
<body >

<form id="form1" runat="server">
<div class="breadCrumb">User Management » Admin User Setup » User Functions</div>
    <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <asp:Panel ID="pnlBreadCrumb" runat="server">
                    <table style="width: 100%">
                       
                        <tr>
                            <td height="20"><span class="welcome"> Username : <%=GetUserName() %></span></td>
                        </tr>
                        <tr>
                            <td height="10"> 
                                <div class="tabs">
                                    <ul> 
                                        <li> <a href="list.aspx">Admin User List </a></li>
                                        <li> <a href="#" class="selected">User Functions</a></li>
                                    </ul> 
                                </div>		
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td>
                <div class = "gridDiv">
                    <div id = "rpt_grid" runat = "server" style = "width: 700px"></div>
                    <asp:Label ID="mes" runat="server" ></asp:Label>
                    <br style = "clear: both" />
                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="button" ValidationGroup="user" 
                                onclick="btnSave_Click" /> &nbsp;
                    <asp:Button ID="btnBack" runat="server" Text="Back" CssClass="button" 
                                onclick="btnBack_Click" />
                </div>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>


