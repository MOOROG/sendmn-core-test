<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="View.aspx.cs" Inherits="Swift.web.AccountReport.InternationalTranReport.ReconciliationReport.View" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />

    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../js/functions.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('remittance_report')">RemittanceReports </a></li>
                            <li class="active"><a href="View.aspx">Txn Reconsile Search</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Reconcile Report Search
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <label class="control-label col-md-4">From Date : </label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="start_date" ReadOnly="true" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">To Date : </label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="end_date" runat="server" ReadOnly="true" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4"></label>
                                <div class="col-md-8">
                                    <asp:Button Text="Process" OnClientClick="return ReconcilationTxnReport(); " ID="btnProcess" runat="server" CssClass="btn btn-primary m-t-25" />
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
    function ReconcilationTxnReport() {
        var fromDate = GetDateValue("<% =start_date.ClientID%>");
        var toDate = GetDateValue("<% =end_date.ClientID%>");
        var url = "../../../../AccountReport/Reports.aspx?reportName=IntlReconcileRpt" +
                 "&fromDate=" + fromDate +
                 "&toDate=" + toDate;
        OpenInNewWindow(url);
        return false;
    }
</script>