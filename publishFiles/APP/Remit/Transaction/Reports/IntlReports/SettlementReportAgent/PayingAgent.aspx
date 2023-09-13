<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayingAgent.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.IntlReports.SettlementReportAgent.PayingAgent" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/js/Reports/AccountStatementAgent.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#<% =startDate.ClientID %>", "#<% =endDate.ClientID %>");
            ShowCalFromToUpToToday("#startDateAfterSearch", "#endDateAfterSearch");
            $('#startDate').mask('0000-00-00');
            $('#endDate').mask('0000-00-00');
        });
        function SettlementReport(rpt) {
            var from = GetValue("<% =startDate.ClientID %>");
            var to = GetValue("<% =endDate.ClientID %>");

            var url = "/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=settlementint_pAgent" +
                "&from=" + from +
                "&type=paying" +
                "&flag=" + rpt +
                "&to=" + to;

            OpenInNewWindow(url);
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
                        <ol class="breadcrumb">
                            <li><a href="../../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li class="active"><a href="Manage.aspx">Settlement Report - International </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row" id="searchDiv">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Receiving Agent Settlement Report</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <%--<div class="form-group">
                                <label class="control-label col-md-4">Country: </label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="sCountry" runat="server" AutoPostBack="true" CssClass="form-control" OnSelectedIndexChanged="sCountry_SelectedIndexChanged">
                                    </asp:DropDownList>
                                </div>
                            </div>--%>
                            <div class="form-group">
                                <label class="control-label col-md-4">From Date :  </label>
                                <div class="col-md-8">

                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="startDate" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">To Date :  </label>
                                <div class="col-md-8">

                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="endDate" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4"></label>
                                <div class="col-md-8">
                                    <asp:Button runat="server" ID="Button1" Text="Settlement Report" class="btn btn-primary m-t-25" OnClientClick="return SettlementReport('s_pAgent');" />
                                    <asp:Button runat="server" ID="Button2" Text="Settlement Report Date Wise" class="btn btn-primary m-t-25" OnClientClick="return SettlementReport('s_pAgent_new');" />
                                    <input type="button" value="Statement" id="Search" onclick="ViewStatementReport()" class="btn btn-primary m-t-25" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row" id="statementResult" style="display: none;">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Statement Search Result
                            </h4>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-12 col-lg-12 form-group">
                                    <label id="accDetails"></label>
                                </div>
                            </div>
                            <div class="row">
                                <label class="col-lg-1 col-md-1 control-label form-group" for="">
                                    Start Date:</label>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="startDateAfterSearch" onchange="return DateValidation('startDate','t','endDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <label class="col-lg-1 col-md-1 control-label form-group" for="">
                                    End Date:</label>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="endDateAfterSearch" onchange="return DateValidation('startDate','t','endDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-12 col-md-12 col-md-offset-1 form-group">
                                    <input type="button" id="SearchAgain" value="Search" class="btn btn-primary" onclick="ViewStatementReport('re')" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <div class="table table-responsive" id="main">
                                            <table id="statementReportTbl" class="table table-responsive table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th>S. No.</th>
                                                        <th>Tran Date</th>
                                                        <th>Particulars</th>
                                                        <th>FCY</th>
                                                        <th>FCY Amount</th>
                                                        <th>FCY Closing</th>
                                                        <th>DR/CR</th>
                                                        <th>JPY Amount</th>
                                                        <th>JPY Closing</th>
                                                        <th>DR/CR</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <div class="col-md-8 form-group">
                                        </div>
                                        <div class="col-md-4 form-group">
                                            <div class="table-responsive">
                                                <table class="table table-striped dt-responsive nowrap">
                                                    <tr>
                                                        <td><b>Opening Balance:</b></td>
                                                        <td><b>
                                                            <label id="openingBalance"></label>
                                                        </b></td>
                                                    </tr>
                                                    <tr>
                                                        <td><b>Total DR:(<label id="totalDrCount"></label>)</b></td>
                                                        <td><b>
                                                            <label id="totalDR"></label>
                                                        </b></td>
                                                    </tr>
                                                    <tr>
                                                        <td><b>Total CR:(<label id="totalCrCount"></label>)</b></td>
                                                        <td><b>
                                                            <label id="totalCR"></label>
                                                        </b></td>
                                                    </tr>
                                                    <tr>
                                                        <td><b>Closing Balance:(<label id="DrOrCr"></label>)</b></td>
                                                        <td><b>
                                                            <label id="closingBalance"></label>
                                                        </b></td>
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
            </div>
        </div>
    </form>
</body>
</html>