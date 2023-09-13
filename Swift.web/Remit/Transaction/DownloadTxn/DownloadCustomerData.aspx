<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DownloadCustomerData.aspx.cs" Inherits="Swift.web.Remit.Transaction.DownloadTxn.DownloadCustomerData" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromTo("#fromDate", "#toDate");
            $('#fromDate').mask('0000-00-00');
            $('#toDate').mask('0000-00-00');
        });
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
                            <li><a href="#">OtherServices </a></li>
                            <li><a href="#">Download Inficare Data</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <%--    <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation"><a href="List.aspx">Customer List</a></li>
                        <li role="presentation" class="active"><a href="#">Customer KYC Operation</a></li>
                    </ul>
                </div>--%>

                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="row">
                            <div class="col-sm-12 col-md-12">
                                <div class="register-form">
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">Download Inficare Data</div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-md-2 form-group">
                                                    <label>From Date:</label>
                                                    <asp:TextBox ID="fromDate" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="col-md-2 form-group">
                                                    <label>To Date:</label>
                                                    <asp:TextBox ID="toDate" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="col-md-12 form-group">
                                                    <asp:Button ID="downloadbtn" runat="server" CssClass="btn btn-primary m-t-25" Text="Import Sender" OnClick="downloadbtn_Click" />
                                                    <asp:Button ID="downloadBtnReceiver" runat="server" CssClass="btn btn-primary m-t-25" Text="Import Receiver" OnClick="downloadBtnReceiver_Click" />
                                                    <label style="color: red">Note: Data for today's date can only be downloaded</label>&nbsp;&nbsp;
                                                    <label id="numberOfTxns" runat="server"></label>
                                                </div>
                                                <div class="col-md-12 form-group">
                                                    <asp:Button ID="btnExecuteSelected" runat="server" CssClass="btn btn-primary m-t-25" Text="Run Wallet Create Job" OnClick="btnExecuteSelected_Click1" />
                                                    <label style="color: red">Note: Create Customer wallet and Membership ID can take more time.</label>
                                                    &nbsp;&nbsp;<label id="txnNeedToBeApproved" runat="server"></label>
                                                    <%--<asp:Button ID="btnSyncCancel" runat="server" CssClass="btn btn-primary m-t-25" Text="Sync Cancel" OnClick="btnSyncCancel_Click" />--%>
                                                    <%--<asp:Button ID="btnSyncPaid" runat="server" CssClass="btn btn-primary m-t-25" Text="Sync Paid" OnClick="btnSyncPaid_Click" />--%>
                                                </div>
                                                <div class="col-md-12 form-group">
                                                    <table class="table table-responsive table-bordered table-condensed">
                                                        <thead>
                                                            <tr>
                                                                <th style="width: 10%;">Download Type</th>
                                                                <th style="width: 10%;">Total Downloaded</th>
                                                                <th style="width: 10%;">Duplicate Downloaded</th>
                                                                <th style="width: 50%;">Detail Message</th>
                                                                <th style="width: 10%;">Download Date</th>
                                                                <th style="width: 10%;">Download By</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody id="tranTable" runat="server">
                                                            <tr>
                                                                <td colspan="6" align="center">No data to display!</td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                        </div>
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
