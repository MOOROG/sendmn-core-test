<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CancelList.aspx.cs" Inherits="Swift.web.Remit.ThirdPartyTXN.ACDeposit.Ria.CancelList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="/js/functions.js"></script>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="/js/jQuery/jquery-1.4.1.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>

    <script type="text/javascript">
        function CallBackSave(errorCode, msg, url) {
            if (msg != '')
                alert(msg);
            if (errorCode == '0') {
                RedirectToIframe(url);
            }
        }
        function RedirectToIframe(url) {
            window.open(url, "_self");
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Transaction</a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Third Party TXN</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Third Party CANCEL Transactions</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab">
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation" class="active"><a href="/Remit/ThirdPartyTXN/ACDeposit/Ria/List.aspx">Third Party</a></li>
                        <li><a href="/Remit/ThirdPartyTXN/ACDeposit/Ria/CancelList.aspx">Third Party-Cancel List</a></li>
                    </ul>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default recent-activites">
                            <div class="panel-heading">
                                <h4 class="panel-title">Cancel Txn In Third Party
                                </h4>
                                <div class="panel-actions">
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="form-group">
                                    <div class="col-md-2">
                                        ControlNo :
                                    </div>
                                    <div class="col-md-4">
                                        <asp:TextBox ID="controlNo" required="required" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="form-group">

                                    <div class="col-md-2">
                                        Cancel Reason :
                                    </div>
                                    <div class="col-md-4">
                                        <asp:TextBox ID="cancelReason" required="required" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-2">
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Button ID="btnRiaCancel" runat="server" CssClass="btn btn-primary" Text="Cancel Transaction" OnClick="btnRiaCancel_Click" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div id="rptGrid" runat="server" class="col-sm-12"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<script type="text/javascript">
    function CheckAll(obj) {
        var cboxes = document.getElementsByName("chkId");
        for (var i = 0; i < cboxes.length; i++) {
            if (cboxes[i].checked == true) {
                cboxes[i].checked = false;
            }
            else {
                cboxes[i].checked = true;
            }
        }
    }
</script>