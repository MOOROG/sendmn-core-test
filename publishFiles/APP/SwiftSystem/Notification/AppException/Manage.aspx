<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.Notification.AppException.Manage" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />     

<style>
    .label-data
    {
     font-family:Verdana;
     font-size:14px;
     background-color:Yellow;   
    }
    .label-head
    {
     font-family:Verdana;
     font-size:14px;
     font-weight:bold;
    }

</style>
</head>
<body>
    <table>
        <tr>
            <td class="label-head">IP Address:</td>
            <td><asp:Label ID="ipAddress" runat="server" CssClass="label-data"></asp:Label></td>            
        </tr>
        <tr>
            <td class="label-head">DC ID No:</td>
            <td><asp:Label ID="dcIdNo" runat="server" CssClass="label-data"></asp:Label></td>            
        </tr>
        <tr>
            <td class="label-head">DC User Name:</td>
            <td><asp:Label ID="dcUserName" runat="server" CssClass="label-data"></asp:Label></td>            
        </tr>
        <tr>
            <td class="label-head">Referer:</td>
            <td><asp:Label ID="referer" runat="server" CssClass="label-data"></asp:Label></td>            
        </tr>
        <tr>
            <td colspan="2">  
                <span class="label-head">Error Details:</span><br />
                <div runat = "server" id = "errMsg" enableviewstate="false"></div>
            </td>            
        </tr>
    </table>
</body>
</html>