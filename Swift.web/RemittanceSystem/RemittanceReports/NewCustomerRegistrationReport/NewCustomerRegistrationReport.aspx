<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NewCustomerRegistrationReport.aspx.cs" Inherits="Swift.web.RemittanceSystem.RemittanceReports.NewCustomerRegistrationReport.NewCustomerRegistrationReport" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>


    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="../../../../../js/swift_calendar.js"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            //ShowCalFromToUpToToday("#from", "#to");
            From("#from");
            To("#to");
            $('#from').mask('0000-00-00');
            $('#to').mask('0000-00-00');
        });
        function NewCustomerRegistrationReport(withAgent) {

            var fromDate = $("#from");
            var toDate = $("#to");
            if (fromDate > toDate) {
                alert("From date cannot be greater than to date");
                return;
            }
            var sBranch = GetValue("<% =sBranch.ClientID %>").split('|')[0];
            var from = GetValue("<% =from.ClientID %>");
            var to = GetValue("<% =to.ClientID %>");

               var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=customerregistration" +
                "&from=" + from +
                "&to=" + to +
                "&sAgent=" + sBranch +
                "&withAgent=" + withAgent;

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
                            <li class="active"><a href="NewCustomerRegistrationReport.aspx">New Customer Registration Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">New Customer Registration Report</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="control-label col-md-4">Branch :</label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="sBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">From Date :  </label>
                                <div class="col-md-8">

                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <%--<asp:TextBox ID="from" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>--%>
                                        <asp:TextBox ID="from" AutoComplete="off" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
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
                                        <%--<asp:TextBox ID="to" runat="server" onchange="return DateValidation('from','t','to')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>--%>
                                        <asp:TextBox ID="to" AutoComplete="off" runat="server" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4"></label>
                                <div class="col-md-8">
                                    <asp:Button runat="server" ID="newCustomerRegistrationReport" Text="View Report" class="btn btn-primary m-t-25" OnClientClick="return NewCustomerRegistrationReport('NewCustomerRegistrationReport');" />
                                    <asp:Button runat="server" ID="newCustomerWithAgent" Text="View Report With Agent" class="btn btn-primary m-t-25" OnClientClick="return NewCustomerRegistrationReport('withAgent');" />
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
