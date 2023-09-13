<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayIntl.aspx.cs" Inherits="Swift.web.Remit.Transaction.PostAcDeposit.PaidTransaction.PayIntl" %>

<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransaction.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <asp:HiddenField ID="hdnPAgent" runat="server" />
        <asp:HiddenField ID="hdnPAgentName" runat="server" />
        <asp:HiddenField ID="hdnTranId" runat="server" />
        <asp:HiddenField ID="hdnIsApi" runat="server" />
        <asp:HiddenField ID="hdnRowId" runat="server" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Transaction</a></li>
                            <li><a href="#" onclick="return LoadModule('account')">PAY A/C Deposit</a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Unpaid List- International</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">
                                <asp:Label ID="lblBankName" runat="server"></asp:Label></a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search Transaction
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="true" />
                            </div>
                            <div class="form-group">
                                <asp:Button ID="btnPay" runat="server" CssClass="btn btn-primary" Text="Post Transaction" OnClick="btnPay_Click" />
                                &nbsp;
                                        <cc1:ConfirmButtonExtender ID="cbe" runat="server"
                                            ConfirmText="Confirm To POST Transaction?" Enabled="True" TargetControlID="btnPay">
                                        </cc1:ConfirmButtonExtender>
                                <asp:Button ID="btnDontPay" runat="server" CssClass="btn btn-danger"
                                    Text="Do Not POST" OnClick="btnDontPay_Click" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

