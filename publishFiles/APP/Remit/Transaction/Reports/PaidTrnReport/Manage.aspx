<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.PaidTrnReport.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />

    <link href="../../../../Css/style.css" rel="Stylesheet" type="text/css" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css"/>
    <script type="text/javascript" src="../../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../../js/functions.js" type="text/javascript"></script>
    <link href="../../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/swift_calendar.js"></script>

    <script type="text/javascript" language="javascript">
        $(function () {
            $(".calendar2").datepicker({
                changeMonth: true,
                changeYear: true,
                //buttonImage: "/images/calendar.gif",
                //buttonImageOnly: true
            });
        });


        $(function () {
            $(".calendar1").datepicker({
                changeMonth: true,
                changeYear: true,
                showOn: "both",
                //buttonImage: "/images/calendar.gif",
                //buttonImageOnly: true
            });
        });

        $(function () {
            $(".fromDatePicker").datepicker({
                defaultDate: "+1w",
                changeMonth: true,
                changeYear: true,
                numberOfMonths: 1,
                showOn: "both",
                //buttonImage: "/images/calendar.gif",
                //buttonImageOnly: true,
                onSelect: function (selectedDate) {
                    $(".toDatePicker").datepicker("option", "minDate", selectedDate);
                }
            });

            $(".toDatePicker").datepicker({
                defaultDate: "+1w",
                changeMonth: true,
                changeYear: true,
                numberOfMonths: 1,
                showOn: "both",
                //buttonImage: "/images/calendar.gif",
                //buttonImageOnly: true,
                onSelect: function (selectedDate) {
                    $(".fromDatePicker").datepicker("option", "maxDate", selectedDate);
                }
            });
        });

    </script>
    <style type="text/css">
         .table .table {
    background-color: #F5F5F5 !important;
        }
    </style>
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
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
                            <li class="active"><a href="Manage.aspx">Paid Transaction Report (Domestic)</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-8">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">PAID TRANSACTION REPORT (DOMESTIC)
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group table table-responsive">
                                <table class="table table-responsive">
                                    <tr>
                                        <td>
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td nowrap="nowrap" valign="top">
                                                        <span class="subHeading">From Date:</span><span class="errormsg">*</span>
                                                    </td>
                                                    <td nowrap="nowrap">
                                                        <asp:TextBox ID="fromDate" runat="server" class="form-control fromDatePicker" ReadOnly="true"></asp:TextBox>
                                                        
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                                            ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </td>
                                                    <td nowrap="nowrap" valign="top">
                                                        <span class="subHeading">To Date:</span><span class="errormsg">*</span>
                                                    </td>
                                                    <td nowrap="nowrap" colspan="3">
                                                        <asp:TextBox ID="toDate" runat="server" class="form-control toDatePicker" ReadOnly="true"></asp:TextBox>
                                                        
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                                            ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:UpdatePanel ID="upd1" runat="server">
                                                <ContentTemplate>
                                                    <table class="table table-responsive">
                                                        <tr>
                                                            <td>&nbsp;</td>
                                                            <td><span class="subHeading">SENDING INFORMATION</span></td>
                                                            <td>&nbsp;</td>
                                                            <td><span class="subHeading">RECEIVING INFORMATION</span></td>
                                                        </tr>
                                                        <tr>
                                                            <td nowrap="nowrap" valign="top">
                                                                <div align="right" class="formLabel">Country:</div>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="sendCountry" runat="server" CssClass="form-control"></asp:DropDownList></td>
                                                            <td nowrap="nowrap" valign="top">
                                                                <div align="right" class="formLabel">Country:</div>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="recCountry" runat="server" CssClass="form-control"></asp:DropDownList></td>
                                                        </tr>
                                                        <tr>
                                                            <td nowrap="nowrap" valign="top">
                                                                <div align="right" class="formLabel">
                                                                    <asp:Label ID="lblRegionType1" runat="server" Text="Zone"></asp:Label>:
                                                                </div>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="sendZone"  runat="server"
                                                                    CssClass="form-control" AutoPostBack="True"
                                                                    OnSelectedIndexChanged="sendZone_SelectedIndexChanged">
                                                                </asp:DropDownList></td>

                                                            <td nowrap="nowrap" valign="top">
                                                                <div align="right" class="formLabel">
                                                                    <asp:Label ID="lblRegionType" runat="server" Text="Zone"></asp:Label>:</div>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="recZone" runat="server"
                                                                    CssClass="form-control" AutoPostBack="True"
                                                                    OnSelectedIndexChanged="recZone_SelectedIndexChanged">
                                                                </asp:DropDownList></td>
                                                        </tr>
                                                        <tr>
                                                            <td nowrap="nowrap" valign="top">
                                                                <div align="right" class="formLabel">District:</div>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="sendDistrict" runat="server"
                                                                    CssClass="form-control" AutoPostBack="True"
                                                                    OnSelectedIndexChanged="sendDistrict_SelectedIndexChanged">
                                                                </asp:DropDownList></td>

                                                            <td nowrap="nowrap" valign="top">
                                                                <div align="right" class="formLabel">District:</div>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="recDistrict" runat="server"
                                                                    CssClass="form-control" AutoPostBack="True"
                                                                    OnSelectedIndexChanged="recDistrict_SelectedIndexChanged">
                                                                </asp:DropDownList></td>
                                                        </tr>
                                                        <tr>
                                                            <td nowrap="nowrap" valign="top">
                                                                <div align="right" class="formLabel">Location:</div>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="sendLocation" runat="server"
                                                                    CssClass="form-control" AutoPostBack="True"
                                                                    OnSelectedIndexChanged="sendLocation_SelectedIndexChanged">
                                                                </asp:DropDownList></td>

                                                            <td nowrap="nowrap" valign="top">
                                                                <div align="right" class="formLabel">Location:</div>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="recLocation" runat="server"
                                                                    CssClass="form-control" AutoPostBack="True"
                                                                    OnSelectedIndexChanged="recLocation_SelectedIndexChanged">
                                                                </asp:DropDownList></td>
                                                        </tr>
                                                        <tr>

                                                            <td nowrap="nowrap" valign="top">
                                                                <div align="right" class="formLabel">Agent:</div>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="sendAgent" runat="server" CssClass="form-control"
                                                                    AutoPostBack="True" OnSelectedIndexChanged="sendAgent_SelectedIndexChanged" >
                                                                </asp:DropDownList></td>

                                                            <td nowrap="nowrap" valign="top">
                                                                <div align="right" class="formLabel">Agent:</div>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="recAgent" runat="server" CssClass="form-control"
                                                                    AutoPostBack="True" OnSelectedIndexChanged="recAgent_SelectedIndexChanged" >
                                                                </asp:DropDownList></td>

                                                        </tr>
                                                        <tr>
                                                            <td nowrap="nowrap" valign="top">
                                                                <div align="right" class="formLabel">Branch:</div>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="sendBranch" runat="server" CssClass="form-control" >
                                                                </asp:DropDownList></td>

                                                            <td nowrap="nowrap" valign="top">
                                                                <div align="right" class="formLabel">Branch:</div>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="recBranch" runat="server" CssClass="form-control" ></asp:DropDownList></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;</td>
                                                            <td colspan="3">
                                                                <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-primary"
                                                                    Text=" Detail " ValidationGroup="rpt"
                                                                    OnClientClick="return showReport();" />
                                                                &nbsp;&nbsp;
                                                <asp:Button ID="btnSearch1" runat="server" CssClass="btn btn-primary"
                                                    Text=" Summary " ValidationGroup="rpt"
                                                    OnClientClick="return showReportSummary();"/>
                                                                &nbsp;&nbsp;
                                            <asp:Button ID="Button1" runat="server" CssClass="btn btn-primary"
                                                Text=" Summary With Commission " ValidationGroup="rpt"
                                                OnClientClick="return showReportSummary1();" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="sendZone" EventName="SelectedIndexChanged" />
                                                    <asp:AsyncPostBackTrigger ControlID="sendDistrict" EventName="SelectedIndexChanged" />
                                                    <asp:AsyncPostBackTrigger ControlID="sendLocation" EventName="SelectedIndexChanged" />
                                                    <asp:AsyncPostBackTrigger ControlID="sendAgent" EventName="SelectedIndexChanged" />
                                                    <asp:AsyncPostBackTrigger ControlID="recZone" EventName="SelectedIndexChanged" />
                                                    <asp:AsyncPostBackTrigger ControlID="recDistrict" EventName="SelectedIndexChanged" />
                                                    <asp:AsyncPostBackTrigger ControlID="recLocation" EventName="SelectedIndexChanged" />
                                                    <asp:AsyncPostBackTrigger ControlID="recAgent" EventName="SelectedIndexChanged" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                </table>
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
        if (!Page_ClientValidate('rpt'))
            return false;

        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
           var toDate = GetDateValue("<% =toDate.ClientID%>");
           var sCountry = GetValue("<% = sendCountry.ClientID %>");

           var sendZone = GetElement("<%=sendZone.ClientID %>");
           var sZone = sendZone.options[sendZone.selectedIndex].text;

           var sendDistrict = GetElement("<%=sendDistrict.ClientID %>");
           var sDistrict = sendDistrict.options[sendDistrict.selectedIndex].text;

           var sLocation = GetValue("<% = sendLocation.ClientID %>");
           var sAgent = GetValue("<% = sendAgent.ClientID %>");
           var sBranch = GetValue("<% = sendBranch.ClientID %>");
           var rCountry = GetValue("<% = recCountry.ClientID %>");

           var recZone = GetElement("<%=recZone.ClientID %>");
           var rZone = recZone.options[recZone.selectedIndex].text;

           var recDistrict = GetElement("<%=recDistrict.ClientID %>");
           var rDistrict = recDistrict.options[recDistrict.selectedIndex].text;

           var rLocation = GetValue("<% = recLocation.ClientID %>");
           var rAgent = GetValue("<% = recAgent.ClientID %>");
           var rBranch = GetValue("<% = recBranch.ClientID %>");

           var url = "ShowReport.aspx?reportName=paidtran" +
                "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&sCountry=" + sCountry +
                "&sZone=" + sZone +
                "&sDistrict=" + sDistrict +
                "&sLocation=" + sLocation +
                "&sAgent=" + sAgent +
                "&sBranch=" + sBranch +
                "&rCountry=" + rCountry +
                "&rZone=" + rZone +
                "&rDistrict=" + rDistrict +
                "&rLocation=" + rLocation +
                "&rAgent=" + rAgent +
                "&rBranch=" + rBranch;

           OpenInNewWindow(url);
           return false;
       }
       function showReportSummary() {
           if (!Page_ClientValidate('rpt'))
               return false;

           var fromDate = GetDateValue("<% =fromDate.ClientID%>");
           var toDate = GetDateValue("<% =toDate.ClientID%>");
           var sCountry = GetValue("<% = sendCountry.ClientID %>");

           var sendZone = GetElement("<%=sendZone.ClientID %>");
           var sZone = sendZone.options[sendZone.selectedIndex].text;

           var sendDistrict = GetElement("<%=sendDistrict.ClientID %>");
           var sDistrict = sendDistrict.options[sendDistrict.selectedIndex].text;

           var sLocation = GetValue("<% = sendLocation.ClientID %>");
           var sAgent = GetValue("<% = sendAgent.ClientID %>");
           var sBranch = GetValue("<% = sendBranch.ClientID %>");
           var rCountry = GetValue("<% = recCountry.ClientID %>");

           var recZone = GetElement("<%=recZone.ClientID %>");
           var rZone = recZone.options[recZone.selectedIndex].text;

           var recDistrict = GetElement("<%=recDistrict.ClientID %>");
           var rDistrict = recDistrict.options[recDistrict.selectedIndex].text;

           var rLocation = GetValue("<% = recLocation.ClientID %>");
           var rAgent = GetValue("<% = recAgent.ClientID %>");
           var rBranch = GetValue("<% = recBranch.ClientID %>");

           var url = "ShowReport.aspx?reportName=paidtransummary" +
                "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&sCountry=" + sCountry +
                "&sZone=" + sZone +
                "&sDistrict=" + sDistrict +
                "&sLocation=" + sLocation +
                "&sAgent=" + sAgent +
                "&sBranch=" + sBranch +
                "&rCountry=" + rCountry +
                "&rZone=" + rZone +
                "&rDistrict=" + rDistrict +
                "&rLocation=" + rLocation +
                "&rAgent=" + rAgent +
                "&rBranch=" + rBranch;

           OpenInNewWindow(url);
           return false;
       }
       function showReportSummary1() {
           if (!Page_ClientValidate('rpt'))
               return false;

           var fromDate = GetDateValue("<% =fromDate.ClientID%>");
           var toDate = GetDateValue("<% =toDate.ClientID%>");
           var sCountry = GetValue("<% = sendCountry.ClientID %>");

           var sendZone = GetElement("<%=sendZone.ClientID %>");
           var sZone = sendZone.options[sendZone.selectedIndex].text;

           var sendDistrict = GetElement("<%=sendDistrict.ClientID %>");
           var sDistrict = sendDistrict.options[sendDistrict.selectedIndex].text;

           var sLocation = GetValue("<% = sendLocation.ClientID %>");
           var sAgent = GetValue("<% = sendAgent.ClientID %>");
           var sBranch = GetValue("<% = sendBranch.ClientID %>");
           var rCountry = GetValue("<% = recCountry.ClientID %>");

           var recZone = GetElement("<%=recZone.ClientID %>");
           var rZone = recZone.options[recZone.selectedIndex].text;

           var recDistrict = GetElement("<%=recDistrict.ClientID %>");
           var rDistrict = recDistrict.options[recDistrict.selectedIndex].text;

           var rLocation = GetValue("<% = recLocation.ClientID %>");
           var rAgent = GetValue("<% = recAgent.ClientID %>");
           var rBranch = GetValue("<% = recBranch.ClientID %>");

           var url = "ShowReport.aspx?reportName=paidtransummary1" +
                "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&sCountry=" + sCountry +
                "&sZone=" + sZone +
                "&sDistrict=" + sDistrict +
                "&sLocation=" + sLocation +
                "&sAgent=" + sAgent +
                "&sBranch=" + sBranch +
                "&rCountry=" + rCountry +
                "&rZone=" + rZone +
                "&rDistrict=" + rDistrict +
                "&rLocation=" + rLocation +
                "&rAgent=" + rAgent +
                "&rBranch=" + rBranch;

           OpenInNewWindow(url);

           return false;

       }
</script>
