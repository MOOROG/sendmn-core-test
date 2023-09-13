<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AgentBalReport.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.AgentBalReport" %>

<%@ Import Namespace="Swift.web.Library" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagPrefix="uc1" TagName="SwiftTextBox" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_autocomplete.js"></script>
    <script type="text/javascript" src="../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script type="text/javascript" src="../../../js/functions.js"></script>
    <script src="../../../js/swift_calendar.js"></script>
    <%-- <script type="text/javascript" language="javascript">
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

    </script>--%>
    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
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
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
                            <li class="active"><a href="AgentBalReport.aspx">Agent Balance Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="panel panel-default col-md-8">
                <div class="panel-heading">Agent Balance Report</div>
                <div class="panel-body">
                    <table border="0" cellspacing="0" cellpadding="0" class="table">
                      
                        <tr>
                            <td>Agent:
                                <uc1:SwiftTextBox ID="agentBal" runat="server" Category="remit-sAgent" />
                            </td>
                            <td>                               
                                <input type="hidden" id="agentId" />
                            </td>
                        </tr>
                        <tr>
                            <td nowrap="nowrap" valign="top">
                                <div align="left" class="formLabel">From Date:<span class="errormsg">*</span> </div>
                                <asp:TextBox ID="fromDate" runat="server" class="fromDatePicker form-control" ReadOnly="true" Width="100%"></asp:TextBox>

                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>

                            </td>
                            <td nowrap="nowrap" valign="top">
                                <div>To Date: <span class="errormsg">*</span></div>

                                <asp:TextBox ID="toDate" runat="server" class="toDatePicker form-control pull-left" ReadOnly="true" Width="100%"></asp:TextBox>

                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>


                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <br />
                                <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary"
                                    Text="Show" ValidationGroup="rpt" OnClientClick="return showReport();" />
                            </td>
                        </tr>
                    </table>
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
        var agentId = GetItem("agentBal")[0];
        if (agentId == "") {
            alert("Please pick agent..");
            return false;
        }
        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");

        var url = "../../../SwiftSystem/Reports/Reports.aspx?reportName=agentBal" +
                "&agentId=" + agentId +
                    "&fromDate=" + fromDate +
                        "&toDate=" + toDate;

        OpenInNewWindow(url);
        return false;

    }

    function PickAgent() {
        var urlRoot = "<%=GetStatic.GetUrlRoot() %>";
        var url = urlRoot + "/Remit/Administration/AgentSetup/PickBranch.aspx";
        var param = "dialogHeight:400px;dialogWidth:940px;dialogLeft:200;dialogTop:100;center:yes";
        var res = PopUpWindow(url, param);
        if (res == "undefined" || res == null || res == "") {

        }
        else {
            alert("call");

            var result = res.split('|');

            document.getElementById("agentId").value = result[1];
            document.getElementById("sendBy").value = result[0];
        }
    }

</script>
