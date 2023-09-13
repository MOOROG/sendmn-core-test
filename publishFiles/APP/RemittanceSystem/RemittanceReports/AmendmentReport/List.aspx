<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.RemittanceSystem.RemittanceReports.AmendmentReport.List" %>
<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
   <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
        ShowCalFromToUpToToday("#grid_Beneficiarylist_fromDate", "#grid_Beneficiarylist_toDate");
        $('#grid_Beneficiarylist_fromDate').mask('0000-00-00');
        $('#grid_Beneficiarylist_toDate').mask('0000-00-00');
    </script>
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
    <script src="/js/swift_calendar.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="/AgentNew/js/swift_calender.js"></script>
    <script type="text/javascript">
        function test() {
            url = "AmendmentReportPage.aspx"
            OpenInNewWindow(url);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
 <div class="hidden">
        <asp:Button ID="clickBtnForGetCustomerDetails" runat="server" Text="click"  />
        <asp:HiddenField ID="hideCustomerId" runat="server" />
    </div>
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li>Remittance</li>
                        <li>Reports</li>
                        <li>Amendment Report</li>
                    </ol>
                </div>
            </div>
        </div>

    </div>
    </form>
</body>
</html>
