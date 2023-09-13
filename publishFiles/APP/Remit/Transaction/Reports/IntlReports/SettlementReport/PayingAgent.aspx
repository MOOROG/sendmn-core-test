<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayingAgent.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.IntlReports.SettlementReport.PayingAgent" %>

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
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
			ShowCalFromToUpToToday("#<% =from.ClientID %>", "#<% =to.ClientID %>");
			$('#from').mask('0000-00-00');
			$('#to').mask('0000-00-00');
        });
        function SettlementReport() {
            var reqField = "sCountry,";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            var country = document.getElementById("sCountry").value;

            if (country =="" || country ==null)
            {
                alert("Please Choose Country");
                return false;
            }
            var agent = document.getElementById("sAgent").value;
            //if (agent == "" || agent == null) {
            //    alert("Please Choose agent");
            //    return false;
            //}

            var scountry = $('#sCountry option:selected').text();
            var sagent = GetValue("<% =sAgent.ClientID %>");
            var from = GetValue("<% =from.ClientID %>");
            var to = GetValue("<% =to.ClientID %>");

            var url = "../../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=settlementint&pCountry=" + scountry +
                "&sAgent=" + sagent +
                "&from=" + from +
                "&type=paying" +
                "&to=" + to;

            OpenInNewWindow(url);
            return false;
        }
        function Button1_onclick() {

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
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation">
                        <a href="Manage.aspx">Sending Agent</a></li>
                    <li class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">Receiving Agent </a></li>
                </ul>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Receiving Agent Settlement Report</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                              <div class="form-group">
                                <label class="control-label col-md-4">Country: </label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="sCountry" runat="server" AutoPostBack="true" CssClass="form-control" OnSelectedIndexChanged="sCountry_SelectedIndexChanged">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Agent :</label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                         <%--   <div class="form-group">
                                <label class="control-label col-md-4">Partner :<span class="errormsg">*</span></label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="payoutPartner" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>--%>
                            <div class="form-group">
                                <label class="control-label col-md-4">From Date :  </label>
                                <div class="col-md-8">

                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="from" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
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
                                        <asp:TextBox ID="to" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4"></label>
                                <div class="col-md-8">
                                    <asp:Button runat="server" ID="Button1" Text="Settlement Report" class="btn btn-primary m-t-25" OnClientClick="return SettlementReport('SettlementReport');" />
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
