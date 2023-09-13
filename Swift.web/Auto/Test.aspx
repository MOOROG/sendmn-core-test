<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Test.aspx.cs" Inherits="Swift.web.Test" %>

<%@ Register Src="../Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <script src="../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../js/swift_autocomplete.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div>

            <uc1:SwiftTextBox ID="agentId" runat="server" Category="agent" Width="200px" />
            <br />

            <asp:Button ID="btnClick" runat="server" Text="Click"
                OnClick="btnClick_Click" />
        </div>
        <input type="button" value="Get" onclick="GetData();" />
        <input type="button" value="Set" onclick="SetData();" />
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    var id = "<% =agentId.ClientID %>";
    function GetData() {
        var d = GetItem(id);
        alert(d[0]);
        alert(d[1]);
    }
    function SetData() {
        var d = ["1234", "Bibash"];
        SetItem(id, d);
    }
</script>