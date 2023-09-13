<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LiquidityReportSearch.aspx.cs" Inherits="Swift.web.AccountReport.LiquidityReport.LiquidityReportSearch" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagPrefix="uc1" TagName="SwiftTextBox" %>

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
    <script src="../../js/functions.js"></script>
    <script src="../../js/swift_calendar.js"></script>
    <script src="../../js/swift_autocomplete.js"></script>
    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalDefault("#<% =fromDate.ClientID%>");
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
                            <li>Liquidity Report</li>
                            <li class="active">Liquidity Report Search</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Liquidity Reports
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">

                            <div class="form-group">

                                <label class="col-lg-2 col-md-3 control-label" for="">As On Date: <span class="errormsg">*</span></label>

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
                                <div class="col-lg-2 col-md-3 "></div>
                                <div class="col-lg-10 col-md-9">
                                    <asp:Button ID="liqRpt" OnClientClick="return showliquidityRpt(); " runat="server" Text="Process" CssClass="btn btn-primary" />
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
    function showliquidityRpt() {
        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var url = "LiquidityReportDetail.aspx?reportName=liqRpt" +
                 "&fromDate=" + fromDate;
        OpenInNewWindow(url);
        return false;

    }
</script>