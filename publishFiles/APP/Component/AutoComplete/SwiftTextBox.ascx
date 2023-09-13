<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SwiftTextBox.ascx.cs" Inherits="Swift.web.Component.AutoComplete.SwiftTextBox" %>
<%--<link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />--%>
<asp:HiddenField ID="aValue" runat="server" />
<asp:TextBox ID="aText" placeholder="Type to Search.." runat="server" CssClass="form-control"></asp:TextBox>
<asp:TextBox ID="aSearch" runat="server" CssClass="form-control" Style="background-color: #fff; display: none; position: relative; z-index: 999;"></asp:TextBox>

<script language="javascript" type="text/javascript">
    <% =InitFunction() %>
</script>