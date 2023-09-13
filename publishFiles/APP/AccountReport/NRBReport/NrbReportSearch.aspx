<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NrbReportSearch.aspx.cs" Inherits="Swift.web.AccountReport.NRBReport.NrbReportSearch" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagPrefix="uc1" TagName="SwiftTextBox" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="../../ui/js/jquery.min.js"></script>
    <script src="../../ui/js/jquery-ui.min.js"></script>
    <script src="../../js/functions.js"></script>
    <script src="../../js/swift_calendar.js"></script>
    <script src="../../js/swift_autocomplete.js"></script>
    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
        }
        LoadCalendars();
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>NRB Report</li>
                            <li class="active">NRB Report Search</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Sales Report
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Sending Agent:</label>
                                <div class="col-lg-10 col-md-9">
                                    <uc1:SwiftTextBox ID="agent" Category="sendingAgentRpt" runat="server" Width="385px" />
                                </div>
                            </div>

                            <div class="form-group">

                                <label class="col-lg-2 col-md-3 control-label" for="">From Date: <span class="errormsg">*</span></label>

                                <div class="col-lg-10 col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="fromDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">

                                <label class="col-lg-2 col-md-3 control-label" for="">To Date: <span class="errormsg">*</span></label>

                                <div class="col-lg-10 col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="toDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-lg-2 col-md-3"></div>
                                <div class="col-lg-10 col-md-9" style="left: 10px;">
                                    <asp:Button ID="process" runat="server" Text="Process" CssClass="btn btn-primary m-t-25" OnClientClick="return showNRBProcessReport();" />
                                    <asp:Button ID="nrbReport1" runat="server" Text="NRB Report1" CssClass="btn btn-primary m-t-25" OnClientClick="return showNRBReport(this.id);" />
                                    <asp:Button ID="nrbReport2" runat="server" Text="NRB Report2" CssClass="btn btn-primary m-t-25" OnClientClick="return showNRBReport(this.id);" />
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
    function showNRBReport(id) {
        var agentId = GetItem("agent")[0];
        if (agentId == "") {
            alert("Please pick agent..");
            return false;
        }
        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");
        if (id == "nrbReport1") {
            var flag = 'd';
        }
        else if(id=="nrbReport2") {
            flag = 's';
        }

        var url = "NrbReportDetail.aspx?reportName=nrbreport" +
             "&agentId=" + agentId +
                 "&fromDate=" + fromDate +
                 "&flag="  + flag +
                 "&toDate=" + toDate;

        OpenInNewWindow(url);
        return false;

    }

    function showNRBProcessReport(id) {
        var agentId = GetItem("agent")[0];
        if (agentId == "") {
            alert("Please pick agent..");
            return false;
        }
        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");

        var url = "../../AccountReport/Reports.aspx?reportName=nrbprocessrpt" +
             "&agentId=" + agentId +
                 "&fromDate=" + fromDate +
                 "&toDate=" + toDate;

        OpenInNewWindow(url);
        return false;

    }
</script>