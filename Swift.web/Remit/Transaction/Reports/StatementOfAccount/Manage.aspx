<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.StatementOfAccount.Manage" %>

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
    <script src="/js/swift_calendar.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            ShowCalFromToUpToToday("#fromDate", "#toDate");
            $('#fromDate').mask('0000-00-00');
            $('#toDate').mask('0000-00-00');
        });
        function StatementOfAccount() {
            var reqField = "sCountry,sAgent,";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }

            var country = document.getElementById("sCountry").value;

            if (country == "" || country == null) {
                alert("Please Choose Country");
                return false;
            }
            var agent = document.getElementById("sAgent").value;
            //var branch = document.getElementById("sBranch").value;
            var reportFor = document.getElementById("reportFor").text;
            //if (agent == "" || agent == null) {
            //    alert("Please Choose agent");
            //    return false;
            //}

            var scountry = $('#sCountry option:selected').text();
            var sagent = GetValue("<% =sAgent.ClientID %>");
		<%--	var sBranch = GetValue("<% =sBranch.ClientID %>");--%>
            var userId = $('#<%=branchUser.ClientID %>').val();
            var reportFor = GetValue("<% =reportFor.ClientID %>");
            var from = GetValue("<% =fromDate.ClientID %>");
            var to = GetValue("<% =toDate.ClientID %>");

            var url = "statementOfAccount.aspx?reportName=StatementOfAccount&pCountry=" + scountry +
                "&sAgent=" + sagent +
                //"&sBranch=" + sBranch +
                "&user=" + userId +
                "&reportFor=" + reportFor +
                "&fromDate=" + from +
                "&toDate=" + to;

            OpenInNewWindow(url);
            return false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>

        <div class="page-wrapper">
            <div class="row">

                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
                            <li class="active"><a href="Manage.aspx">Statement of Account</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active">
                        <a href="#list" aria-controls="home" role="tab" data-toggle="tab">Sending Agent</a></li>
                    <li><a href="PayingAgent.aspx">Receiving Agent </a></li>
                </ul>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Sending Agent Settlement Report</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <asp:UpdatePanel ID="upnl1" runat="server">
                                <ContentTemplate>
                                    <div class="form-group">
                                        <label class="control-label col-md-4">Sending Country: </label>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="sCountry" runat="server" AutoPostBack="true" CssClass="form-control" OnSelectedIndexChanged="sCountry_SelectedIndexChanged">
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label col-md-4">Sending Agent/Branch :</label>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="sAgent_SelectedIndexChanged"></asp:DropDownList>
                                        </div>
                                    </div>

                                    <%--<div class="form-group">
										<label class="control-label col-md-4">Sending Branch :</label>
										<div class="col-md-8">
											<asp:DropDownList ID="sBranch" runat="server" CssClass="form-control"></asp:DropDownList>
										</div>
									</div>--%>

                                    <div class="form-group">
                                        <label class="control-label col-md-4">Agent/Branch Users :</label>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="branchUser" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label col-md-4" for="">
                                            Report For:</label>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="reportFor" runat="server" CssClass="form-control">
                                                <asp:ListItem Value="">All</asp:ListItem>
                                                <asp:ListItem Value="P">Principle</asp:ListItem>
                                                <asp:ListItem Value="COMM">Commission</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                            <div class="form-group">
                                <label class="control-label col-md-4">From Date :  </label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="fromDate" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
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
                                        <asp:TextBox ID="toDate" runat="server" onchange="return DateValidation('from','t','to')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4"></label>
                                <div class="col-md-8">
                                    <asp:Button runat="server" ID="Button1" Text="Statement Of Account" class="btn btn-primary m-t-25" OnClientClick="return StatementOfAccount('StatementOfAccount');" />
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