<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DomesticTxn.aspx.cs" Inherits="Swift.web.AccountReport.TxnReport.DomesticTxn" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<%@ Import Namespace="Swift.web.Library" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />

    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script type="text/javascript" src="../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../js/jQuery/jquery-ui.min.js"></script>
    <script type="text/javascript" src="../../js/functions.js"></script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../js/swift_calendar.js"></script>

    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
            ShowCalFromTo("#<% =rFromDate.ClientID%>", "#<% =rToDate.ClientID%>", 1);
        }
        LoadCalendars();
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
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('remittance_report')">RemittanceReports </a></li>
                            <li class="active"><a href="DomesticTxn.aspx">Domestic Transaction</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">REMIT TRANSACTION SEARCH - DOMESTIC - SENDING AGENT</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="form-group ">
                                    <div class="col-md-6">
                                        Agent :
                                    <uc1:SwiftTextBox ID="SendingAgent" runat="server" Category="sendingAgentRpt" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-3">
                                        From Date :
                                         <div class="input-group m-b">
                                             <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                             <asp:TextBox ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                         </div>
                                    </div>
                                    <div class="col-md-3">
                                        To Date :
                                         <div class="input-group m-b">
                                             <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                             <asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                         </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-3">
                                        Date Type:
                                             <%--<span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>--%>
                                        <select id="DateType" name="DateType" class="form-control">
                                            <option value="s" selected="selected">CONFIRM DATE</option>
                                            <option value="p">PAID DATE</option>
                                            <option value="c">CANCEL DATE</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        Payment Status:
                                            <%--<span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>--%>
                                        <select id="payment_status" name="payment_status" class="form-control">
                                            <option value="" selected="selected">All</option>
                                            <option value="Paid">PAID</option>
                                            <option value="Un-Paid">UN-PAID</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-2">
                                        <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary m-t-25" Text="Show" OnClientClick="return showReport();" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">REMIT TRANSACTION SEARCH - DOMESTIC- RECEIVING AGENT</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="form-group ">
                                    <div class="col-md-6">
                                        Agent :
                                    <uc1:SwiftTextBox ID="rAgent" runat="server" Category="sendingAgentRpt" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-3">
                                        From Date :
                                         <div class="input-group m-b">
                                             <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                             <asp:TextBox ID="rFromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                         </div>
                                    </div>
                                    <div class="col-md-3">
                                        To Date :
                                         <div class="input-group m-b">
                                             <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                             <asp:TextBox ID="rToDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                         </div>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-3">
                                        Date Type:
                                             <%--<span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>--%>
                                        <select id="rDateType" name="rDateType" class="form-control">
                                            <option value="s" selected="selected">CONFIRM DATE</option>
                                            <option value="p">PAID DATE</option>
                                            <option value="c">CANCEL DATE</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        Payment Status:
                                        <%--<span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>--%>
                                        <select id="rpayment_status" name="rpayment_status" class="form-control">
                                            <option value="" selected="selected">All</option>
                                            <option value="Paid">PAID</option>
                                            <option value="Un-Paid">UN-PAID</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-2">
                                        <asp:Button ID="Button1" runat="server" CssClass="btn btn-primary m-t-25" Text="Show" OnClientClick="return showReceivingReport();" />
                                    </div>
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
    function showReport() {
        var agentId = GetItem("SendingAgent")[0];
        if (agentId == "") {
            alert("Please pick agent..");
            return false;
        }
        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");
        var DateType = $("#DateType").val();
        var payment_status = $("#payment_status").val();
        var url = "../../AccountReport/Reports.aspx?reportName=domestictxn" + "&agentId=" + agentId +
                 "&fromDate=" + fromDate +
                 "&DateType=" + DateType +
                 "&payment_status=" + payment_status +
                     "&toDate=" + toDate;

        OpenInNewWindow(url);
        return false;

    }
    function showReceivingReport() {
        var agentId = GetItem("rAgent")[0];
        if (agentId == "") {
            alert("Please pick agent..");
            return false;
        }
        var fromDate = GetDateValue("<% =rFromDate.ClientID%>");
        var toDate = GetDateValue("<% =rToDate.ClientID%>");
        var DateType = $("#rDateType").val();
        var payment_status = $("#rpayment_status").val();

        var url = "../../AccountReport/Reports.aspx?reportName=domestictxnreceiving" +
             "&agentId=" + agentId +
                 "&fromDate=" + fromDate +
                 "&DateType=" + DateType +
                 "&payment_status=" + payment_status +
                     "&toDate=" + toDate;

        OpenInNewWindow(url);
        return false;

    }
</script>