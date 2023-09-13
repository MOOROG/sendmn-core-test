<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Domestic.aspx.cs" Inherits="Swift.web.AgentPanel.Pay.PayAcDeposit.Domestic" %>

<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransaction.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="/css/style.css" rel="stylesheet" type="text/css" />
    <link href="/css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_calendar.js" type="text/javascript"> </script>
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#grdPendingDom_approvedDate", "#grdPendingDom_approvedDateTo");
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <asp:HiddenField ID="hdnTranId" runat="server" />
        <div class="bredCrom" style="width: 90%">PAY MONEY » Pay A/C Deposit- Domestic </div>
        <div>
            <table>
                <tr>
                    <td>
                        <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="true" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Button ID="btnPay" runat="server" CssClass="button" Text="Pay Transaction" OnClick="btnPay_Click" />
                        &nbsp;
                <cc1:ConfirmButtonExtender ID="cbe" runat="server"
                    ConfirmText="Confirm To Pay Transaction?" Enabled="True" TargetControlID="btnPay">
                </cc1:ConfirmButtonExtender>

                        <asp:Button ID="btnDontPay" runat="server" CssClass="button"
                            Text="Do Not Pay" OnClick="btnDontPay_Click" /></td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>