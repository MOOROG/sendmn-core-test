<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PendingIntl.aspx.cs" Inherits="Swift.web.Remit.Transaction.PayAcDepositV3.PostTransaction.PendingIntl" %>

<%@ Register TagPrefix="cc1" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit, Version=3.0.20820.16598, Culture=neutral, PublicKeyToken=28f01b0e84b6d53e" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <asp:UpdateProgress ID="updProgress" AssociatedUpdatePanelID="upd1" runat="server">
            <ProgressTemplate>
                <div style="position: fixed; left: 450px; top: 0px; background-color: white; border: 1px solid black;">
                    <img alt="progress" src="../../../../Images/Loading_small.gif" />
                    Processing...
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
        <asp:UpdatePanel ID="upd1" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:HiddenField ID="hdnPAgent" runat="server" />
                <asp:HiddenField ID="hdnPAgentName" runat="server" />
                <div class="page-wrapper">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="page-title">
                                <h1></h1>
                                <ol class="breadcrumb">
                                    <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li><a href="#" onclick="return LoadModule('account')">Transaction</a></li>
                                    <li><a href="#" onclick="return LoadModule('account')">POST A/C Deposit</a></li>
                                    <li><a href="#" onclick="return LoadModule('account')">Unpaid List- International </a></li>
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
                                    <div class="form-group" id="result" runat="server" visible="false">
                                        <div class="form-group">
                                            <div id="rpt_grid" runat="server" class="table table-responsive"></div>
                                        </div>
                                        <div class="form-group">
                                            <asp:Button ID="btnPaidTxn" runat="server" Text="Post Transaction" CssClass="btn btn-primary"
                                                OnClick="btnPaidTxn_Click" />
                                            <cc1:ConfirmButtonExtender ID="btnPaycc" runat="server"
                                                ConfirmText="Confirm To POST Transaction?" Enabled="True" TargetControlID="btnPaidTxn">
                                            </cc1:ConfirmButtonExtender>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
<script type="text/javascript">
    function CheckAll(obj) {
        var cBoxes = document.getElementsByName("chkId");
        for (var i = 0; i < cBoxes.length; i++) {
            if (cBoxes[i].checked == true) {
                cBoxes[i].checked = false;
            }
            else {
                cBoxes[i].checked = true;
            }
        }
    }
</script>
