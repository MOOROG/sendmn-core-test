<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AccountReport.RemmitanceVoucher.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <!-- Bootstrap Core CSS -->
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../ui/js/pickers-init.js"></script>
    <script src="../../ui/js/jquery-ui.min.js"></script>
    <script src="../../ui/js/metisMenu.min.js"></script>
    <script src="../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="../../ui/js/custom.js"></script>
    <!--page plugins-->
    <script src="../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <script>
        function LoadCalendars() {
            ShowCalFromTo("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
            ShowCalDefault("#<% =voucherDate.ClientID%>");
        }
        LoadCalendars();
    </script>
</head>
<body>
    <form id="Form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li class="active"><a href="List.aspx">Remittance Voucher</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6" id="uploadFunction" runat="server">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Upload Remittance Data
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body" style="min-height: 185px;">
                            <div class="form-group alert alert-danger" id="divuploadMsg" runat="server" visible="false">
                            </div>
                            <div class="form-group alert alert-success" id="divUploadSuccess" runat="server" visible="false">
                            </div>
                            <div id="uploadDiv" runat="server">
                                <div class="form-group">
                                    <label class="col-lg-4 col-md-5 control-label" for="">
                                        Browse Remittance Data:</label>
                                    <div class="col-lg-4 col-md-4">
                                        <asp:FileUpload ID="fileUpload" runat="server" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-3 col-md-offset-5">
                                        <asp:Button ID="btnUpload" class="btn btn-primary start" runat="server" Text="Upload File" OnClick="btnUpload_Click" />
                                    </div>
                                    <div class="col-md-4">
                                        <a href="../../SampleFile/InternationRemittance.csv">Download Sample File</a>
                                    </div>
                                </div>
                            </div>
                            <div id="showLog" runat="server" visible="false">
                                <div class="form-group">
                                    <div class="col-lg-12 table-responsive">
                                        <table class="table table-striped table-bordered">
                                            <thead>
                                                <tr>
                                                    <th>Tran Count
                                                    </th>
                                                    <th>Send Amount
                                                    </th>
                                                    <th>Paid Amount
                                                    </th>
                                                </tr>
                                            </thead>
                                            <tbody id="logTbl" runat="server">
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-12">
                                        <asp:Button ID="confirm" class="btn btn-primary start" runat="server" Text="Confirm" OnClick="confirm_Click" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6" id="intFunction" runat="server">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">International transaction
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-2 control-label" for="">
                                    Date:
                                </label>
                                <div class="col-lg-9 col-md-10">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="intDate" placeholder="Choose Date" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-2 control-label" for="">
                                    Rate:
                                </label>
                                <div class="col-lg-9 col-md-10">
                                    <div class="input-group m-b">

                                        <span class="input-group-addon">
                                            <i class="fa fa-cart-plus" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="rate" runat="server" placeholder="Enter Rate" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-10 col-md-offset-2">
                                <p style="color: Red;">(* Please input the rate before run the voucher creation process)</p>
                                <asp:Button ID="btnsend" runat="server" Text="Send Voucher" class="btn btn-primary m-t-25" OnClick="btnsend_Click" />

                                <asp:Button ID="btnpaid" runat="server" Text="Paid Voucher" class="btn btn-primary m-t-25" OnClick="btnpaid_Click" />

                                <asp:Button ID="btncancel" runat="server" Text="Cancel Voucher" class="btn btn-primary m-t-25" OnClick="btncancel_Click" />

                                <div class="col-md-7 alert alert-danger" id="sqlMsg" runat="server" visible="false">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row" id="domFunction" runat="server">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Domestic transaction
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-2 control-label" for="">
                                    Date:
                                </label>
                                <div class="col-lg-10 col-md-10">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <div class="col-lg-8 col-md-8">
                                            <asp:TextBox ID="domesticdate" placeholder="Choose Date" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                        </div>
                                        <div class="col-lg-4 col-md-4">
                                            <asp:DropDownList ID="ddlTime" runat="server" CssClass="form-control form-control-inline">
                                                <asp:ListItem Value="14">2 PM</asp:ListItem>
                                                <asp:ListItem Value="17">5 PM</asp:ListItem>
                                                <asp:ListItem Value="24">EOD of Yeaterday</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-12">
                                <div class="form-group">
                                    <p><a href="">Check Remittance Report</a></p>
                                    <asp:Button ID="sendvoucher" runat="server" Text=" Send Voucher " class="btn btn-primary m-t-25" OnClick="sendvoucher_Click" />
                                    <asp:Button ID="sendtpt" runat="server" Text="Send T P Today" class="btn btn-primary m-t-25" OnClick="sendtpt_Click" />
                                    <asp:Button ID="sendtct" runat="server" Text="Send T C Today" class="btn btn-primary m-t-25" OnClick="sendtct_Click" />
                                </div>
                            </div>
                            <div class="col-md-12">
                                <div class="form-group">
                                    <asp:Button ID="sendtnpt" runat="server" Text="Send T Not P Today " class="btn btn-primary m-t-25" OnClick="sendtnpt_Click" />

                                    <asp:Button ID="sendbpt" runat="server" Text="  Send B P Today " class="btn btn-primary m-t-25" OnClick="sendbpt_Click" />

                                    <asp:Button ID="sendbct" runat="server" Text="  Send B C Today" class="btn btn-primary m-t-25" OnClick="sendbct_Click" />

                                    <div class="col-md-6 alert alert-danger" id="domesticSqlMsg" runat="server" visible="false" style="width: 100%; margin-top: 25px;"></div>
                                    <div class="col-md-6 alert alert-success" id="domesticSqlSuccessMsg" runat="server" visible="false" style="width: 100%; margin-top: 25px;">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6" style="display: none">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">CALCULATE TDS FOR AGENT</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="form-group">
                            <div class="row">
                                <label class="col-md-2 control-label" for="">From:</label>
                                <div class="col-md-4">
                                    <asp:TextBox ID="fromDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                </div>
                                <label class="col-md-2 control-label" for="">To :</label>
                                <div class="col-md-4">
                                    <asp:TextBox ID="toDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                </div>
                            </div>
                            <br />
                            <div class="row">
                                <label class="col-md-2 control-label" for="">Voucher Date: </label>
                                <div class="col-md-4">
                                    <asp:TextBox ID="voucherDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                </div>
                            </div>
                            &nbsp;&nbsp;<asp:Button ID="tdsCal" OnClick="btnTds_Click" CssClass="btn btn-primary col-md-offset-2" Text="Start Process" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>