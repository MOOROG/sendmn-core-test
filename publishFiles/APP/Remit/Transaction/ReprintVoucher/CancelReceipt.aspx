<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CancelReceipt.aspx.cs" Inherits="Swift.web.Remit.Transaction.ReprintVoucher.CancelReceipt" %>
<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
</head>
<body>

<form id="form1" runat="server">
<asp:ScriptManager ID="ScriptManager1" runat="server">
</asp:ScriptManager>
    <div class="bredCrom" style="width: 90%">Cancel Receipt [Duplicate]</div>
    <h3><span style="margin-left: 20px;"></span></h3>
    <span style="margin-left: 2px; background: red; font-size: 1.5em; font-weight: bold; color: White;">
        <%=GetStatic.GetTranNoName() %>:
        <asp:Label ID="controlNo" runat="server"></asp:Label>
    </span>
    <table class="panels2 tableForm" style="width: 500px;">
        <tr>
            <td class="label">Posted By:</td>
            <td>
                <asp:Label ID="postedBy" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>Sender:</td>
            <td>
                <asp:Label ID="sender" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>Receiver:</td>
            <td>
                <asp:Label ID="receiver" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>Contact No:</td>
            <td>
                <asp:Label ID="rContactNo" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>Collected Amount:</td>
            <td>
                <asp:Label ID="cAmt" runat="server"></asp:Label>
                [<asp:Label ID="collCurr" runat="server"></asp:Label>]
            </td>
        </tr>
        <tr>
            <td>Service Charge:</td>
            <td>
                <asp:Label ID="serviceCharge" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>Payout Amount:</td>
            <td>
                <asp:Label ID="pAmt" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>Cancellation Charge:</td>
            <td>
                <asp:Label ID="cancelCharge" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td class="DisFond">Return Amount:</td>
            <td class="DisFond">
                <asp:Label ID="returnAmt" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>Send Date:</td>
            <td>
                <asp:Label ID="sendDate" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>Cancelled Date:</td>
            <td>
                <asp:Label ID="cancelDate" runat="server"></asp:Label>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>
