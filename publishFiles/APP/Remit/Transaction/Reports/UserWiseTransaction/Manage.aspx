<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.UserWiseTran.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script type="text/javascript" src="../../../../ui/js/jquery.min.js"></script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

    <link href="../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="../../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../../ui/js/pickers-init.js"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>
    <script type="text/javascript" src="../../../../js/functions.js"></script>
    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalDefault("#<% =fromDate.ClientID%>");
            ShowCalDefault("#<% =toDate.ClientID%>");
        }
        LoadCalendars();
    </script>

    <script type="text/javascript" language="javascript">
        $(function () {
            $(".calendar2").datepicker({
                changeMonth: true,
                changeYear: true,
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true
            });
        });


        $(function () {
            $(".calendar1").datepicker({
                changeMonth: true,
                changeYear: true,
                showOn: "button",
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true
            });
        });

        $(function () {
            $(".fromDatePicker").datepicker({
                defaultDate: "+1w",
                changeMonth: true,
                changeYear: true,
                numberOfMonths: 1,
                showOn: "button",
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true,
                onSelect: function (selectedDate) {
                    $(".toDatePicker").datepicker("option", "minDate", selectedDate);
                }
            });

            $(".toDatePicker").datepicker({
                defaultDate: "+1w",
                changeMonth: true,
                changeYear: true,
                numberOfMonths: 1,
                showOn: "button",
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true,
                onSelect: function (selectedDate) {
                    $(".fromDatePicker").datepicker("option", "maxDate", selectedDate);
                }
            });
        });

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('reports')">Reports</a></li>
                            <li class="active"><a href="Manage.aspx">User Wise Transaction Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <!-- First Panel -->

                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">User Wise Transaction Report</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <asp:UpdatePanel ID="up" runat="server">
                                <ContentTemplate>
                                    <table class="table table-responsive">
                                        <tr>
                                            <td style="width: 12%"></td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap">
                                                <div align="left" class="formLabel">Country:</div>
                                            </td>
                                            <td nowrap="nowrap" colspan="3">
                                                <asp:DropDownList ID="country" runat="server" CssClass="form-control" Width="350px" AutoPostBack="True" OnSelectedIndexChanged="country_SelectedIndexChanged">
                                                </asp:DropDownList>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="country" ForeColor="Red"
                                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap">
                                                <div align="left" class="formLabel">Agent:</div>
                                            </td>
                                            <td nowrap="nowrap" colspan="3">
                                                <asp:DropDownList ID="agent" runat="server" CssClass="form-control" Width="350px" AutoPostBack="True"
                                                    OnSelectedIndexChanged="agent_SelectedIndexChanged">
                                                </asp:DropDownList>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="agent" ForeColor="Red"
                                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap">
                                                <div align="left" class="formLabel">Branch:</div>
                                            </td>
                                            <td nowrap="nowrap" colspan="3">
                                                <asp:DropDownList ID="branch" CssClass="form-control" runat="server" Width="350px"
                                                    AutoPostBack="True" OnSelectedIndexChanged="branch_SelectedIndexChanged">
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap">
                                                <div align="left" class="formLabel">User Name:</div>
                                            </td>
                                            <td nowrap="nowrap" colspan="3">
                                                <asp:DropDownList ID="userName" runat="server" CssClass="form-control" Width="350px"></asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap">
                                                <div align="left" class="formLabel">From Date:</div>
                                            </td>
                                            <td nowrap="nowrap">
                                                <div class="input-group m-b">
                                                    <span class="input-group-addon">
                                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                                    </span>
                                                    <asp:TextBox ID="fromDate" runat="server" ReadOnly="true" Width="350px" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap" valign="top">
                                                <div align="left" class="formLabel">To Date:</div>
                                                <td nowrap="nowrap">
                                                    <div class="input-group m-b">
                                                        <span class="input-group-addon">
                                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                                        </span>
                                                        <asp:TextBox ID="toDate" runat="server" ReadOnly="true" Width="350px" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                    </div>
                                                </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap">
                                                <div align="left" class="formLabel">Rec. Country:</div>
                                            </td>
                                            <td nowrap="nowrap" colspan="3">
                                                <asp:DropDownList ID="recCountry" CssClass="form-control" runat="server" Width="350px">
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td colspan="3">
                                                <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary m-t-25"
                                                    Text=" Search Detail " ValidationGroup="rpt"
                                                    OnClientClick="return showReport();" />
                                                &nbsp;&nbsp;
                                        <asp:Button ID="BtnSave2" runat="server" CssClass="btn btn-primary m-t-25"
                                            Text=" Search Summary " ValidationGroup="rpt"
                                            OnClientClick="return showReportSummary();" />
                                                &nbsp;&nbsp;
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="country" EventName="SelectedIndexChanged" />
                                    <asp:AsyncPostBackTrigger ControlID="agent" EventName="SelectedIndexChanged" />
                                    <asp:AsyncPostBackTrigger ControlID="branch" EventName="SelectedIndexChanged" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </div>
                    </div>
                </div>

                <!-- second panel -->

                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">User Wise Transaction Report (Old)</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <table class="table table-responsive">
                                <tr>
                                    <td style="width: 12%"></td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="left" class="formLabel">User Type:</div>
                                    </td>
                                    <td nowrap="nowrap" colspan="3">
                                        <asp:DropDownList ID="userType" CssClass="form-control" runat="server" Width="350px"
                                            AutoPostBack="True" OnSelectedIndexChanged="userType_SelectedIndexChanged">
                                            <asp:ListItem Value="">All</asp:ListItem>
                                            <asp:ListItem Value="HO">Ho/Admin</asp:ListItem>
                                            <asp:ListItem Value="Agent">Agent</asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="left" class="formLabel">User Name:</div>
                                    </td>
                                    <td nowrap="nowrap" colspan="3">
                                        <asp:DropDownList CssClass="form-control" ID="userName1" runat="server" Width="350px"></asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap">
                                        <div align="left" class="formLabel">From Date:</div>
                                    </td>
                                    <td nowrap="nowrap">
                                        <div class="input-group m-b">
                                            <span class="input-group-addon">
                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                            </span>
                                            <asp:TextBox ID="fromDate1" runat="server" ReadOnly="true" Width="350px" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap" valign="top">
                                        <div align="left" class="formLabel">To Date:</div>
                                        <td nowrap="nowrap">
                                            <div class="input-group m-b">
                                                <span class="input-group-addon">
                                                    <i class="fa fa-calendar" aria-hidden="true"></i>
                                                </span>
                                                <asp:TextBox ID="toDate1" runat="server" ReadOnly="true" Width="350px" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                            </div>
                                        </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td colspan="3">
                                        <asp:Button ID="Button1" runat="server" CssClass="btn btn-primary m-t-25"
                                            Text=" Search Detail " ValidationGroup="rpt1"
                                            OnClientClick="return showReport_1();" />
                                        &nbsp;&nbsp;
                                <asp:Button ID="Button2" runat="server" CssClass="btn btn-primary m-t-25"
                                    Text=" Search Summary " ValidationGroup="rpt1"
                                    OnClientClick="return showReportSummary_1();" />
                                        &nbsp;&nbsp;
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    function showReport() {
        if (!Page_ClientValidate('rpt'))
            return false;

        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");
        var country = GetValue("<% =country.ClientID%>");
        var agent = GetValue("<% =agent.ClientID%>");
        var branch = GetValue("<% =branch.ClientID%>");
        var userName = GetValue("<% =userName.ClientID%>");
        var rCountry = GetValue("<% =recCountry.ClientID%>");

        var url = "SearchUserWise.aspx?reportName=uwdetail" +
            "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                    "&country=" + country +
                        "&agent=" + agent +
                            "&branch=" + branch +
                                "&userName=" + userName +
                                    "&rCountry=" + rCountry;

        OpenInNewWindow(url);

        return false;

    }

    function showReportSummary() {
        if (!Page_ClientValidate('rpt'))
            return false;

        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");
        var country = GetValue("<% =country.ClientID%>");
        var agent = GetValue("<% =agent.ClientID%>");
        var branch = GetValue("<% =branch.ClientID%>");
        var userName = GetValue("<% =userName.ClientID%>");
        var rCountry = GetValue("<% =recCountry.ClientID%>");

        var url = "SearchUserWise.aspx?reportName=uwsummary" +
         "&fromDate=" + fromDate +
         "&toDate=" + toDate +
         "&country=" + country +
         "&agent=" + agent +
         "&branch=" + branch +
         "&userName=" + userName +
         "&rCountry=" + rCountry;

        OpenInNewWindow(url);

        return false;

    }
    function showReport_1() {
        if (!Page_ClientValidate('rpt1'))
            return false;

        var fromDate = GetDateValue("<% =fromDate1.ClientID%>");
        var toDate = GetDateValue("<% =toDate1.ClientID%>");
        var userName = document.getElementById("userName1").value;
        var userType = document.getElementById("userType").value;

        var url = "SearchUserWise.aspx?reportName=detail_1" +
         "&fromDate=" + fromDate +
         "&userName=" + userName +
         "&userType=" + userType +
         "&toDate=" + toDate;

        OpenInNewWindow(url);

        return false;

    }

    function showReportSummary_1() {
        if (!Page_ClientValidate('rpt1'))
            return false;

        var fromDate = GetDateValue("<% =fromDate1.ClientID%>");
        var toDate = GetDateValue("<% =toDate1.ClientID%>");
        var userName = document.getElementById("userName1").value;
        var userType = document.getElementById("userType").value;

        var url = "SearchUserWise.aspx?reportName=summary_1" +
         "&fromDate=" + fromDate +
         "&userName=" + userName +
         "&userType=" + userType +
         "&toDate=" + toDate;

        OpenInNewWindow(url);

        return false;

    }
</script>

<script type='text/javascript' language='javascript'>
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
    function EndRequest(sender, args) {
        if (args.get_error() == undefined) {
            LoadCalendars();
        }
    }
</script>
