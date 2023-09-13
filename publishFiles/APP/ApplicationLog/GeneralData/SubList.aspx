<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SubList.aspx.cs" Inherits="Swift.web.GeneralSetting.GeneralData.SubList" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="breadCrumb">
            Application Log » General Data Settings » List »
        <asp:Label ID="Title" runat="server"></asp:Label>
        </div>
        <div class="tabs">
            <ul>
                <li><a href="#" class="selected">List </a></li>
                <li><a href="manage.aspx?id=<%=GetID() %>&title=<%=GetTitle() %>">Manage </a></li>
            </ul>
        </div>
        <div id="subgds_grid" runat="server" class="gridDiv">
        </div>
    </form>
</body>
</html>