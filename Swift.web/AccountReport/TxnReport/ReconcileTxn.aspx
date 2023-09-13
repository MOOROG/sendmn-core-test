<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReconcileTxn.aspx.cs" Inherits="Swift.web.AccountReport.TxnReport.ReconcileTxn" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="../../ui/js/jquery.min.js"></script>
    <script src="../../ui/js/jquery-ui.min.js"></script>
    <script src="../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../js/swift_calendar.js"></script>
    <script src="../../js/functions.js"></script>
    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
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
                            <li>Txn Report</li>
                            <li class="active">Reconcile Report Search</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Reconcile Report
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">From Date: <span class="errormsg">*</span></label>
                                <div class="col-lg-10 col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="fromDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">To Date: <span class="errormsg">*</span></label>
                                <div class="col-lg-10 col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="toDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-lg-2 col-md-3 "></div>
                                <div class="col-lg-10 col-md-9">
                                    <asp:Button ID="reconcileTxn" OnClientClick="return showReconcilationTxnReport(); " runat="server" Text="Process" CssClass="btn btn-primary" />
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
<script language="javascript" type="text/javascript">
    function showReconcilationTxnReport() {
        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");
        var url = "ReconcileTxnReport.aspx?reportName=reconciletxnrpt" +
                 "&fromDate=" + fromDate +
                 "&toDate=" + toDate;
        OpenInNewWindow(url);
        return false;
    }
</script>