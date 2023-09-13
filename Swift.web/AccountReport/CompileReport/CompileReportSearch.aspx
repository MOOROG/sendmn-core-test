<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CompileReportSearch.aspx.cs" Inherits="Swift.web.AccountReport.CompileReport.CompileReportSearch" %>

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
            ShowCalFromToUpToToday("#<% =asOnDate.ClientID %>");
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
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('remittance_report')">RemittanceReports </a></li>
                            <li class="active"><a href="CompileReportSearch.aspx">Compile Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Compile Report
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">As On Date: <span class="errormsg">*</span></label>
                                <div class="col-lg-10 col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="asOnDate" runat="server" class="form-control" ReadOnly="true" Width="100%"></asp:TextBox>
                                    </div>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="asOnDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Agent Code:</label>
                                <div class="col-lg-10 col-md-9">
                                    <uc1:SwiftTextBox ID="agent" Category="sendingAgent" runat="server" Width="385px" />
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Include Zero Value:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <select id="includeZeroValue" name="includeZeroValue" class="form-control">
                                        <option value="Y">Yes</option>
                                        <option value="N">No</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Bank Code:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <uc1:SwiftTextBox ID="bank" Category="bankCode" runat="server" Width="385px" />
                                </div>
                            </div>

                            <div class="form-group">
                                <div class="row">
                                    <label class="col-lg-2 col-md-3 control-label" for="">
                                        From DR Amt:
                                    </label>
                                    <div class="col-lg-2  col-md-3">
                                        <asp:TextBox ID="fromDrAmt" runat="server" CssClass="form-control" Style="margin-left: 6px;" />
                                    </div>
                                    <label class="col-lg-2 col-md-3 control-label" for="">
                                        To DR Amt:
                                    </label>
                                    <div class="col-lg-2 col-md-3">
                                        <asp:TextBox ID="toDrAmt" runat="server" CssClass="form-control" Style="margin-left: -15px;" />
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="row">
                                    <label class="col-lg-2 col-md-3 control-label" for="">
                                        From CR Amt:
                                    </label>
                                    <div class="col-lg-2 col-md-3">
                                        <asp:TextBox ID="fromCrAmt" runat="server" CssClass="form-control" Style="margin-left: 6px;" />
                                    </div>
                                    <label class="col-lg-2 col-md-3 control-label" for="">
                                        To CR Amt:
                                    </label>
                                    <div class="col-lg-2 col-md-3">
                                        <asp:TextBox ID="toCrAmt" runat="server" CssClass="form-control" Style="margin-left: -15px;" />
                                    </div>
                                </div>
                            </div>
                            <%--<div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    View Type:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <select id="viewType" name="viewType">
                                        <option value="W">Web </option>
                                        <option value="E">Export To Excel</option>
                                    </select>
                                </div>
                            </div>--%>
                            <div class="form-group">
                                <div class="col-lg-2 col-md-3 control-label" for=""></div>
                                <label class="col-lg-2 col-md-2 control-label col-md-4" for="">
                                    <input id="compile1" type="submit" name="Submit" value="Search " class="btn btn-primary" style="display: none" onclick="return showcompileReport(this.id);">&nbsp;
                                </label>
                                <label class="col-lg-2 col-md-2 control-label" for="">
                                    <input id="compile2" type="submit" name="Submit2" value="Search To Web " class="btn btn-primary" onclick="return showcompileReport(this.id);">&nbsp;
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="form-group col-md-8 ">
                    <div align="center">
                        <%--<div class="form-group">
                                <div runat="server" id="exportDiv" class="noprint">
                                    <div style="float: left; margin-left: 10px; vertical-align: top">
                                        <img alt="Print" title="Print" style="cursor: pointer; width: 14px; height: 14px" onclick=" javascript:ReportPrint(); " src="../../images/printer.png" border="0" />
                                    </div>
                                    <div style="float: left; margin-left: 10px; vertical-align: top" id="export" runat="server">
                                        <img alt="Export to Excel" title="Export to Excel" style="cursor: pointer" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');" src="../../images/excel.gif" border="0" />
                                    </div>
                                </div>
                            </div>--%>
                        <div class="table-responsive" id="tblRpt" runat="server">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    function showcompileReport(id) {
        var agentcode = GetItem("agent")[0];
        //if (agentcode == "") {
        //    alert("Please pick agent..");
        //    return false;
        //}
        var includeZeroValue = $("#includeZeroValue").val();
        var asOnDate = GetValue("<% =asOnDate.ClientID%>");
        var bankCode = GetItem("bank")[0];
        var fromDrAmt = GetValue("<%=fromDrAmt.ClientID %>");

        var toDrAmt = GetValue("<%=toDrAmt.ClientID %>");
        var fromCrAmt = GetValue("<%=fromCrAmt.ClientID %>");
        var toCrAmt = GetValue("<%=toCrAmt.ClientID %>");

        // var viewType = $("#viewType").val();
        var url = "";

        if (id == "compile1") {
            url = "CompileReportSearch.aspx?createJOb=y" +
           "&agentCode=" + agentcode +
           "&asOnDate=" + asOnDate +
           "&includeZeroValue=" + includeZeroValue +
           "&fromDrAmt=" + fromDrAmt +
           "&toDrAmt=" + toDrAmt +
           "&fromCrAmt=" + fromCrAmt +
           "&toCrAmt=" + toCrAmt +
           "&bankCode=" + bankCode;
            RedirectLocal(url);
        }
        else if (id == "compile2") {
            url = "../Reports.aspx?reportName=compiletoweb" +
           "&agentCode=" + agentcode +
           "&asOnDate=" + asOnDate +
           "&includeZeroValue=" + includeZeroValue +
           "&fromDrAmt=" + fromDrAmt +
           "&toDrAmt=" + toDrAmt +
           "&fromCrAmt=" + fromCrAmt +
           "&toCrAmt=" + toCrAmt +
           "&bankCode=" + bankCode;
            OpenInNewWindow(url);
        }

        return false;

    }

    function showcompileReportSearch() {

    }
</script>