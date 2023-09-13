<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="VerifyTxn.aspx.cs" Inherits="Swift.web.Remit.Transaction.TxnVerify.VerifyTxn" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="/ui/js/jquery.min.js"></script>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/functions.js" type="text/javascript"> </script>

    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript">

        function Approve(id) {
            var amt = parseFloat($("#amt_" + id).val());
            if (amt <= 0) {
                window.parent.SetMessageBox("Invalid Amount", "1");
                return;
            }
            SetValueById("<% = hddTranNo.ClientID %>", id, false);
            GetElement("<% =btnApprove.ClientID %>").click();
        }

        function Reject(id) {
            var amt = parseFloat($("#amt_" + id).val());
            if (amt <= 0) {
                window.parent.SetMessageBox("Invalid Amount", "1");
                return;
            }
            SetValueById("<% = hddTranNo.ClientID %>", id, false);
            GetElement("<% =btnReject.ClientID %>").click();
        }

        function ViewDetails(id) {
            var url = "/Remit/Transaction/TxnVerify/Manage.aspx?id=" + id;
            PopUpWindow(url);
        }
    </script>
</head>
<body>

    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a>
                            </li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="VerifyTxn.aspx">Txn Verify List </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div id="approveList" runat="server">
                        <div id="rptGrid" runat="server" enableviewstate="false"></div>
                        <br />
                    </div>
                </div>
            </div>
        </div>
        <asp:Button ID="btnApprove" runat="server" Text="Approve" CssClass="btn btn-primary" Style="display: none" OnClick="btnApprove_Click" />
        <asp:Button ID="btnReject" runat="server" CssClass='btn btn-primary m-t-25' OnClick="btnReject_Click" Style="display: none" />
        <asp:HiddenField ID="hddTranNo" runat="server" />
        <asp:HiddenField ID="hdntabType" runat="server" />
    </form>
</body>
</html>