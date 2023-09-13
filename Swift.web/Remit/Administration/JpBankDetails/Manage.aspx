<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.JpBankDetails.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <style type="text/css">
        .modal-body .table th {
            color: #888888;
        }

        .modal-body .table td {
            color: #000;
            font-weight: 600;
        }
    </style>
    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
            ShowCalFromToUpToToday("#<% =txnDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
            $('#<%=fromDate.ClientID%>').mask('0000-00-00');
            $('#<%=toDate.ClientID%>').mask('0000-00-00');
        }
        LoadCalendars();
    </script>
    <style>
        .panels {
            padding: 7px;
            margin-bottom: 5px;
            margin-left: 20px;
            width: 100%;
        }
    </style>
    <script language="javascript" type="text/javascript">
        function showReport(flag) {
            if (!Page_ClientValidate('rpt'))
                return false;
            if (flag == 'L') {
                var particulars = GetValue("<% =particulars.ClientID%>");
                var txnDate = GetValue("<% =txnDate.ClientID%>");
                var amount = GetValue("<% =amount.ClientID%>");
                var url = "/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=jpDepositList" +
                    "&particulars=" + particulars +
                    "&txnDate=" + txnDate +
                    "&amount=" + amount;

                OpenInNewWindow(url);
                return false;

            } else {
                var fromDate = GetValue("<% =fromDate.ClientID%>");
                var toDate = GetValue("<% =toDate.ClientID%>");
                var status = GetValue("<% =depositStatus.ClientID%>")
                var url = "List.aspx?" +
                    "from=" + fromDate +
                    "&to=" + toDate +
                    "&status=" + status;

                OpenInNewWindow(url);
                return false;
            }

        }
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
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Other Services</a></li>
                            <li class="active"><a href="Manage.aspx">JP Deposit Details</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div id="DivFrm" class="col-md-6" runat="server">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <i class="fa fa-file-text"></i>
                        <label>JP Deposit Details</label>
                    </div>
                    <div class="panel-body">
                        <div class="form-group">
                            <div class="col-md-3">
                                <label>
                                    From Date:
                            <span class="errormsg">*</span>
                                </label>
                            </div>
                            <div class="col-md-9">
                                <div class="input-group m-b10 ">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t','toDate')" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                </div>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-3">
                                <label>
                                    To Date:
                            <span class="errormsg">*</span>
                                </label>
                            </div>
                            <div class="col-md-9">
                                <div class="input-group m-b10">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox autocomplete="off" ID="toDate" runat="server" class="dateField form-control"></asp:TextBox>
                                </div>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-3">
                                <label>
                                    Deposit Status:
                            <span class="errormsg">*</span>
                                </label>
                            </div>
                            <div class="col-md-9">
                                <asp:DropDownList ID="depositStatus" runat="server" CssClass="form-control form-control-inline input-medium">
                                    <asp:ListItem Value="all">All</asp:ListItem>
                                    <asp:ListItem Value="mapped">Mapped</asp:ListItem>
                                    <asp:ListItem Value="unmapped">UnMapped</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-3 ">
                                <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary btn-sm"
                                    Text="Search" ValidationGroup="rpt" OnClientClick="return showReport();" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="listDiv" class="col-md-6" runat="server">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <i class="fa fa-file-text"></i>
                        <label>JP Deposit List</label>
                    </div>
                    <div class="panel-body">
                        <div class="form-group">
                            <div class="col-md-3">
                                <label>
                                    Particulars:
                            <span class="errormsg">*</span>
                                </label>
                            </div>
                            <div class="col-md-9">
                                <asp:TextBox runat="server" CssClass="form-control" ID="particulars"></asp:TextBox>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-3">
                                <label>
                                    Transaction Date:
                            <span class="errormsg">*</span>
                                </label>
                            </div>
                            <div class="col-md-9">
                                <div class="input-group m-b10 ">
                                    <span class="input-group-addon">
                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                    </span>
                                    <asp:TextBox ID="txnDate" onchange="return DateValidation('txnDate','t','toDate')" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                </div>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-md-3">
                                <label>
                                    Amount:
                            <span class="errormsg">*</span>
                                </label>
                            </div>
                            <div class="col-md-9">
                                <asp:TextBox runat="server" CssClass="form-control" ID="amount"></asp:TextBox>
                            </div>
                        </div>


                        <div class="form-group">
                            <div class="col-md-offset-3 col-md-3 ">
                                <asp:Button ID="depositList" runat="server" CssClass="btn btn-primary btn-sm"
                                    Text="Search" ValidationGroup="rpt" OnClientClick="return showReport('L');" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
