<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ImportSettlementRate.aspx.cs" Inherits="Swift.web.Remit.ImportSettlementRate.ImportSettlementRate" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            $(".check").click(function () {
                $("input[name*='chkRateUpload']").attr("checked", true);
                $('.check').hide();
                $('.uncheck').show();
            });
            $(".uncheck").click(function () {
                $("input[name*='chkRateUpload']").attr("checked", false);
                $('.check').show();
                $('.uncheck').hide();
            });
        });
        function ConfirmSave() {
            if (confirm('Do you want to continue with save?')) {
                return true;
            }
            return false;
        }
        function ConfirmClear() {
            if (confirm('Do you want to clear data?')) {
                return true;
            }
            return false;
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
                            <li><a href="#">OtherServices </a></li>
                            <li><a href="#">Import Settlemet Rate</a></li>
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
                                        <div class="panel-heading">Import Settlement Rate</div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-md-12 form-group" id="step1a" runat="server">
                                                    <label class="control-label" for="">
                                                        Import Settlement Rate:
                                                    </label>
                                                    <asp:FileUpload ID="fileUpload" runat="server" />
                                                    <a href="/SampleFile/VoucherEntry.csv"></a>
                                                </div>
                                                <div class="col-md-12 form-group" id="step1" runat="server">
                                                    <asp:Button ID="import" runat="server" CssClass="btn btn-primary m-t-25" Text="Import" OnClick="import_Click" />
                                                </div>
                                                <div class="col-md-6 form-group" id="step2" runat="server">
                                                    <table class="table table-responsive table-bordered table-condensed">
                                                        <thead>
                                                            <tr>
                                                                <th><i class="fa fa-check check" style="display:none;"></i><i class="fa fa-times uncheck"></i></th>
                                                                <th>Country</th>
                                                                <th>Currency</th>
                                                                <th>Old Rate</th>
                                                                <th>New Rate</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody id="rateTable" runat="server">
                                                            <tr>
                                                                <td colspan="5" align="center">No data to display!</td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </div>
                                                <div class="col-md-12 form-group" id="step2a" runat="server">
                                                    <asp:Button ID="btnConfirmSave" runat="server" OnClientClick="return ConfirmSave();" CssClass="btn btn-primary" Text="Confirm Save" OnClick="btnConfirmSave_Click" />
                                                    <asp:Button ID="btnClear" runat="server" CssClass="btn btn-danger" OnClientClick="return ConfirmClear();" OnClick="btnClear_Click" Text="Clear Data" />
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
