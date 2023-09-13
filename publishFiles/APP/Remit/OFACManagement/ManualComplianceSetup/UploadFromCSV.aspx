<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UploadFromCSV.aspx.cs" Inherits="Swift.web.Remit.OFACManagement.ManualComplianceSetup.UploadFromCSV" %>

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
        function CheckRequiredField() {
            reqField = "ofacSourceDdl,fileUpload";
            if ( ValidRequiredField(reqField) === false)
            {
                return false;
            }
            return true;

        }
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
                            <li><a href="#">Import OFAC List</a></li>
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
                <div class="listtabs">
                    <ul class="nav nav-tabs">
                        <li><a href="List.aspx" class="selected" target="_self">List</a></li>
                        <li><a href="Manage.aspx" target="_self">Manage </a></li>
                        <li class="active"><a href="UploadFromCSV.aspx" target="_self">Upload from CSV file </a></li>
                    </ul>
                </div>
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="row">
                            <div class="col-sm-12 col-md-12">
                                <div class="register-form">
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">Import OFAC List</div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-md-2 form-group">
                                                    <label class="control-label" for="">OFAC Source</label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <asp:DropDownList ID="ofacSourceDdl" CssClass="form-control" runat="server"></asp:DropDownList>
                                                </div>

                                            </div>
                                            <div class="row">
                                                <div class="col-md-2 form-group" id="step1a" runat="server">
                                                    <label class="control-label" for="">
                                                        Import OFAC List:
                                                    </label>
                                                </div>
                                                <div class="col-md-4 form-group">
                                                    <asp:FileUpload ID="fileUpload" CssClass="form-control" runat="server" />
                                                    <a href="/SampleFile/VoucherEntry.csv"></a>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-12 form-group" id="step1" runat="server">
                                                    <asp:Button ID="import" runat="server" OnClientClick=" return CheckRequiredField()" CssClass="btn btn-primary m-t-25" Text="Import" OnClick="import_Click" />
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
