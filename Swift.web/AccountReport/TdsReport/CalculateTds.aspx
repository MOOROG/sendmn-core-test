<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CalculateTds.aspx.cs" Inherits="Swift.web.AccountReport.TdsReport.CalculateTds" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="../../ui/js/jquery.min.js"></script>
    <script src="../../ui/js/jquery-ui.min.js"></script>
    <script src="../../js/swift_autocomplete.js"></script>
    <script src="../../js/swift_calendar.js"></script>
    <script src="../../js/functions.js"></script>
    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
            CalUpToToday("#<% =voucherDate.ClientID%>");
        }
        LoadCalendars();
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>TDS Report</li>
                            <li class="active">CALCULATE TDS FOR AGENT</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
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
                                <div class="col-md-12 alert alert-danger" id="sqlMsg" runat="server" visible="false">
                                </div>
                            </div>
                            <div class="row">
                                <label class="col-md-2 control-label" for="">From:</label>
                                <div class="col-md-4">
                                    <asp:TextBox ID="fromDate" runat="server" class="form-control" Width="100%"></asp:TextBox>
                                </div>
                                <label class="col-md-2 control-label" for="">To :</label>
                                <div class="col-md-4">
                                    <asp:TextBox ID="toDate" runat="server" class="form-control" Width="100%"></asp:TextBox>
                                </div>
                            </div>
                            <br />
                            <div class="row">
                                <label class="col-md-2 control-label" for="">Voucher Date: </label>
                                <div class="col-md-4">
                                    <asp:TextBox ID="voucherDate" runat="server" class="form-control" Width="100%"></asp:TextBox>
                                </div>
                            </div>
                            <br />
                            &nbsp;&nbsp;<asp:Button ID="tdsCal" OnClick="btnTds_Click" CssClass="btn btn-primary col-md-offset-2" Text="Start Process" runat="server" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>