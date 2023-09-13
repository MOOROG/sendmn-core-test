<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ComplianceRelease.aspx.cs" Inherits="Swift.web.Remit.Compliance.ComplianceReleaseRpt.ComplianceRelease" %>

<!DOCTYPE html>
<link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
<link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
<link href="/ui/css/style.css" rel="stylesheet" />

<script src="/js/functions.js"></script>
<script type="text/javascript" src="/ui/js/jquery.min.js"></script>
<link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

<link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
<script src="/js/swift_calendar.js"></script>
<script src="/ui/js/pickers-init.js"></script>
<script src="/ui/js/jquery-ui.min.js"></script>
<script language="javascript" type="text/javascript">
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
        }
        LoadCalendars();
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remit')">Remit</a></li>
                            <li><a href="#" onclick="return LoadModule('remit_compliance')">Compliance</a></li>
                            <li class="active"><a href="ComplianceRelease.aspx">Compliance Release Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-8">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Compliance Release Report
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                                    <ContentTemplate>
                                        <table class="table table-responsive">
                                            <tr>
                                                <td style="width: 30%;">Form Date:
                                                </td>
                                                <td>
                                                    <div class="input-group m-b">
                                                        <span class="input-group-addon">
                                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                                        </span>
                                                        <asp:TextBox ID="fromDate" runat="server" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                                    </div>
                                                    <asp:RequiredFieldValidator runat="server" ID="rd_1" ControlToValidate="fromDate"
                                                        ErrorMessage="Required!" ForeColor="red" ValidationGroup="rpt"></asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>To Date:
                                                </td>
                                                <td>
                                                    <div class="input-group m-b">
                                                        <span class="input-group-addon">
                                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                                        </span>
                                                        <asp:TextBox ID="toDate" runat="server" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                                    </div>
                                                    <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator1" ControlToValidate="toDate"
                                                        ErrorMessage="Required!" ForeColor="red" ValidationGroup="rpt"></asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Released By:
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="releasedBy" CssClass="form-control" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Include System Release:
                                                </td>
                                                <td>
                                                    <asp:CheckBox runat="server" ID="includeSystemRelease" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Report Type:
                                                </td>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="reportType" CssClass="form-control" AutoPostBack="true"
                                                        OnSelectedIndexChanged="reportType_SelectedIndexChanged">
                                                        <asp:ListItem Value="Detail-Report">Detail-Report</asp:ListItem>
                                                        <asp:ListItem Value="Summary-User">Summary-User</asp:ListItem>
                                                        <asp:ListItem Value="Summary-Date">Summary-Date</asp:ListItem>
                                                        <asp:ListItem Value="Summary-Reason">Summary-Reason</asp:ListItem>
                                                    </asp:DropDownList>
                                                    <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator2" ControlToValidate="reportType"
                                                        ErrorMessage="Required!" ForeColor="red" ValidationGroup="rpt"></asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                            <tr id="optBlock_id" runat="server">
                                                <td>ID Number:
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="idNumber" CssClass="form-control"></asp:TextBox>
                                                </td>
                                            </tr>

                                            <tr id="optBlock_name" runat="server">
                                                <td>Customer Name:
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="customerName" CssClass="form-control"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="optBlock_reason" runat="server">
                                                <td>Hold Reason
                                                </td>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="holdReaseon" CssClass="form-control" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>&nbsp;
                                                </td>
                                                <td>
                                                    <input type="button" class="btn btn-primary m-t-25" value="Show Report" onclick="showReport();" />
                                                </td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:PostBackTrigger ControlID="reportType" />
                                    </Triggers>
                                </asp:UpdatePanel>
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
    function showReport() {
        if (!window.Page_ClientValidate('rpt'))
            return false;
        var fromDate = GetValue("<% =fromDate.ClientID%>");
        var toDate = GetValue("<% =toDate.ClientID%>");
        var releasedBy = GetValue("<% =releasedBy.ClientID%>");
        var includeSystemRelease = $("#<% =includeSystemRelease.ClientID%>").is(":checked") ? "Y" : "N";
        var idNumber = GetValue("<% =idNumber.ClientID%>");
        var customerName = GetValue("<% =customerName.ClientID%>");
        var reportType = GetValue("<% =reportType.ClientID%>");
        var holdReason = GetValue("<% =holdReaseon.ClientID%>");
        var urlRoot = "<%=Swift.web.Library.GetStatic.GetUrlRoot() %>";
        var user = "<%= Swift.web.Library.GetStatic.GetUser() %>";

        var url = urlRoot + "/SwiftSystem/Reports/Reports.aspx?reportName=comprlzreport" +
            "&fromDate=" + fromDate +
            "&toDate=" + toDate +
            "&releasedBy=" + releasedBy +
            "&includeSystemRelease=" + includeSystemRelease +
            "&idNumber=" + idNumber +
            "&customerName=" + customerName +
            "&holdReason=" + holdReason +
            "&reportType=" + reportType +
            "&user=" + user;
        OpenInNewWindow(url);
        return false;

    }
</script>