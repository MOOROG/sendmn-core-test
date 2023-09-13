<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RBAStatistics.aspx.cs" Inherits="Swift.web.Remit.RiskBasedAssesement.RBATxnReport.RBAStatistics" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>

    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
        }
        LoadCalendars();
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnIsAdvaceSearch" runat="server" Value="N" />
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Risk Based Assessement</a></li>
                            <li class="active"><a href="RBAStatistic.aspx">RBA Transaction Report </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="RBATxnRpt.aspx" target="_self">RBA TXN Report</a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">RBA Statistics</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-10">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">RBA Statistics </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle"></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <asp:UpdatePanel ID="updatePanel1" runat="server">
                                        <ContentTemplate>
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td>
                                                        <label>Sending Country:<span class="errormsg">*</span></label>
                                                    </td>
                                                    <td>
                                                        <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control" AutoPostBack="True" OnSelectedIndexChanged="sCountry_SelectedIndexChanged">
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="sCountry" ForeColor="Red"
                                                            ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label>Sending Agent:</label>
                                                    </td>
                                                    <td>
                                                        <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control" AutoPostBack="True" OnSelectedIndexChanged="sAgent_SelectedIndexChanged">
                                                        </asp:DropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label>Sending Branch:</label>
                                                    </td>
                                                    <td>
                                                        <asp:DropDownList ID="sBranch" runat="server" CssClass="form-control">
                                                        </asp:DropDownList>

                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <label>Date:</label>
                                                    </td>
                                                    <td>
                                                        <div class="row">
                                                            <div class="col-md-6">
                                                                From<span class="errormsg">*</span>
                                                                <div class="input-group m-b">
                                                                    <span class="input-group-addon">
                                                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                                                    </span>
                                                                    <asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t')" MaxLength="10" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                                                </div>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                                </asp:RequiredFieldValidator>
                                                            </div>
                                                            <div class="col-md-6">
                                                                To<span class="errormsg">*</span>
                                                                 <div class="input-group m-b">
                                                                  <span class="input-group-addon">
                                                                 <i class="fa fa-calendar" aria-hidden="true"></i>
                                                                  </span>
                                                                <asp:TextBox ID="toDate" onchange="return DateValidation('toDate','t')" MaxLength="10" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                                             </div>
                                                              <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                            </asp:RequiredFieldValidator>
                                                        </div>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td></td>
                                                    <td>
                                                        <asp:Button ID="BtnSave1" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search " ValidationGroup="rpt" OnClientClick="return showReport();" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
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
<script language="javascript" type="text/javascript">
    function getRadioCheckedValue(radioName) {
        var oRadio = document.forms[0].elements[radioName];

        for (var i = 0; i < oRadio.length; i++) {
            if (oRadio[i].checked) {
                return oRadio[i].value;
            }
        }
        return '';
    }

    function showReport() {
        if (!Page_ClientValidate('rpt'))
            return false;
        var reportFor = "STAT-RBA-V2";
        var sCountry = $("#sCountry option:selected").text();
        var sAgent = GetValue("<% =sAgent.ClientID%>");
        var sBranch = GetValue("<% =sBranch.ClientID%>");
        var fromDate = GetValue("<% =fromDate.ClientID%>");
        var toDate = GetValue("<% =toDate.ClientID%>");
        var url = "../../../SwiftSystem/Reports/Reports.aspx?reportName=rbareport" +
               "&sCountry=" + sCountry +
                "&reportFor=" + reportFor +
                   "&sAgent=" + sAgent +
                       "&sBranch=" + sBranch +
							"&fromDate=" + fromDate +
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

