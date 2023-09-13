<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TxnList.aspx.cs" Inherits="Swift.web.Remit.Transaction.SuspiciousTxn.TxnList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../js/Swift_grid.js"></script>
    <script src="../../../js/functions.js"></script>
    <script type="text/javascript">
        function SyncTxn(controlno, payStatus, tranStatus) {
            var alertMsg = '';
            if (controlno == '' || controlno == undefined) {
                alert('Invalid transaction selected');
                return false;
            }
            if (tranStatus.toLowerCase() == 'paid' || payStatus.toLowerCase() == 'paid') {
                alertMsg = 'Are you sure you would like to change the status of txn to Paid?'
            }
            else if (tranStatus.toLowerCase() == 'cancel' || tranStatus.toLowerCase() == 'cancelhold') {
                alertMsg = 'Are you sure you would like to change the status of txn to Cancel?'
            }

            if (!confirm(alertMsg)) {
                return false;
            }
            $('#hddControlno').val(controlno);
            $('#btnSync').click();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hddControlno" runat="server" />
        <asp:Button ID="btnSync" runat="server" OnClick="btnSync_Click" style="display:none;" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Transaction</a></li>
                            <li class="active"><a href="List.aspx">Suspicious Status Sync List</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab">
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="list">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default ">
                                    <div class="panel-heading">
                                        <h4 class="panel-title">Suspicious Status Sync List</h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <div id="rpt_grid" runat="server" class="gridDiv">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div role="tabpanel" class="tab-pane" id="Manage">
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
