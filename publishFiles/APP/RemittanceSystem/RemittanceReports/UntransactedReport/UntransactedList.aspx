<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UntransactedList.aspx.cs" Inherits="Swift.web.RemittanceSystem.RemittanceReports.UntransactedReport.UntransactedList" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/functions.js"></script>

    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalFromTo("#fromDate", "#toDate");
            //$('#fromDate').mask('0000-00-00');
            //$('#toDate').mask('0000-00-00');
        });
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
                            <li><a href="#" onclick="return LoadModule('account')">Account </a></li>
                            <li class="active"><a href="UntransactedList.aspx">Untransacted Report </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Untransacted Report List</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-10">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label class="col-md-5 control-label">From Date:  <span class="errormsg">*</span> </label>
                                            <div class="col-md-7">
                                                <div class="input-group m-b">
                                                    <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                    <asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium" autocomplete="off"></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label class="col-md-4 control-label">To Date:  <span class="errormsg">*</span> </label>
                                            <div class="col-md-7">
                                                <div class="input-group m-b">
                                                    <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                    <asp:TextBox ID="toDate" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium" autocomplete="off"></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label class="col-md-4 control-label">Report Type:  <span class="errormsg">*</span> </label>
                                            <div class="col-md-7">
                                                <asp:DropDownList ID="dataFor" runat="server" CssClass="form-control">
                                                    <asp:ListItem Text="All" Value="a"></asp:ListItem>
                                                    <asp:ListItem Text="Untransacted Only" Value="u"></asp:ListItem>
                                                    <asp:ListItem Text="Wallet Balance Only" Value="w"></asp:ListItem>
                                                    <asp:ListItem Text="Refund Only" Value="r"></asp:ListItem>
                                                    <asp:ListItem Text="Remittance Sent Only" Value="rs"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <asp:Button ID="loadReports" runat="server" CssClass="btn btn-primary" Text="View" OnClientClick="return LoadReports();" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script type="text/javascript">
        function CheckFormValidation() {
            reqField = "fromDate,toDate,";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
        }
        function LoadReports() {
            if (!CheckFormValidation())
                return false;
            var fromDate = $("#<% =fromDate.ClientID%>").val();
            var toDate = $("#<% =toDate.ClientID%>").val();
            var rptType = $("#<%=dataFor.ClientID%>").val();
            var url = "ViewReport.aspx?" +
                "from=" + fromDate +
                "&to=" + toDate +
                "&dataFor=" + rptType;

            OpenInNewWindow(url);
            return false;
        }
    </script>
</body>
</html>
