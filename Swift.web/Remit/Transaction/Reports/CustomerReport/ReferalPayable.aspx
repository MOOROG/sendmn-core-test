<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReferalPayable.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.CustomerReport.ReferalPayable" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script>
        function PayAmount(referelCode) {
            if (confirm("Are you sure to pay to " + referelCode + " ?")) {
                $("#referelCode").val(referelCode);
                $("#btnPay").click;
            }
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
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Reports </a></li>
                            <li class="active"><a href="ReferralReport.aspx">Referral Transaction Payable Detail </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-10">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Payable Detail
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <asp:HiddenField ID="endDate" runat="server" />
                            <asp:HiddenField ID="referelCode" runat="server" />
                            <asp:HiddenField ID="startDate" runat="server" />
                            <asp:Button ID="btnPay" runat="server" Text=" Pay " OnClick="btnPay_Click" Style="display: none" />
                            <div id="main">
                                <div id="tableBody" runat="server" class="col-md-12">
                                    <div class="table-responsive">
                                        <table class="table table-striped table-bordered" width="100%" cellspacing="0" class="TBLReport">
                                            <tr>
                                                <th nowrap="nowrap">S.N.</th>
                                                <th nowrap="nowrap">Referral Name</th>
                                                <th nowrap="nowrap">Referral Code</th>
                                                <th nowrap="nowrap">No of First Txn.</th>
                                                <th nowrap="nowrap">No of Other Txn.</th>
                                                <th nowrap="nowrap">Net Payable</th>
                                                <th nowrap="nowrap">Action</th>
                                            </tr>
                                        </table>
                                    </div>
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
