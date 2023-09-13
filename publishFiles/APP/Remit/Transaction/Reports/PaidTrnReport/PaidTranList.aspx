<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PaidTranList.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.PaidTrnReport.PaidTranList" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../../js/jQuery/jquery.min.js"></script>
    <script src="../../../../js/swift_calendar.js"></script>
    <script type="text/javascript" src="../../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../../js/functions.js" type="text/javascript"></script>
    <link href="../../../../Css/swift_component.css" rel="stylesheet" type="text/css" />


    <script type="text/javascript" language="javascript">
        //             $(function () {
        //                 $(".calendar2").datepicker({
        //                     changeMonth: true,
        //                     changeYear: true,
        //                     buttonImage: "/images/calendar.gif",
        //                     buttonImageOnly: true
        //                 });
        //             });


        //             $(function () {
        //                 $(".calendar1").datepicker({
        //                     changeMonth: true,
        //                     changeYear: true,
        //                     showOn: "button",
        //                     buttonImage: "/images/calendar.gif",
        //                     buttonImageOnly: true
        //                 });
        //             });

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
            <asp:ScriptManager ID="ScriptManager1" runat="server">
            </asp:ScriptManager>
             <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
                            <li class="active"><a href="PaidTranList.aspx">Paid Transaction List (Domestic)</a></li>
                        </ol>
                    </div>
                </div>
            </div>

           <div class="panel panel-default col-md-8">
               <div class="panel-heading">PAID TRANSACTION LIST</div>
               <div class="panel-body">
                        <table  class="table">                           
                            <tr>
                                <td nowrap="nowrap" valign="top">
                                    <div  class="formLabel">From Date:<span class="errormsg">*</span></div>
                                </td>
                                <td nowrap="nowrap">
                                    <asp:TextBox ID="fromDate" runat="server" class="fromDatePicker form-control" ReadOnly="true" Width="47.5%"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </td>
                                </tr>
                            <tr>
                                <td nowrap="nowrap" valign="top">
                                    <div class="formLabel">To Date: <span class="errormsg">*</span></div>
                                </td>
                                <td nowrap="nowrap">
                                    <asp:TextBox ID="toDate" runat="server" class="toDatePicker form-control" ReadOnly="true" Width="47.5%"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>

                                <td nowrap="nowrap" valign="top">
                                    <div  class="formLabel">Sending  Agent:</div>
                                </td>
                                <td colspan="3">
                                    <asp:DropDownList ID="sendAgent" runat="server" CssClass="form-control"
                                        Width="200px">
                                    </asp:DropDownList></td>

                            </tr>

                            <tr>

                                <td nowrap="nowrap" valign="top">
                                    <div  class="formLabel">Beneficeary Country:</div>
                                </td>
                                <td colspan="3"><b>Nepal</b></td>

                            </tr>
                            <tr>
                                <td nowrap="nowrap" valign="top">
                                    <div  class="formLabel">Payout  Agent:</div>
                                </td>
                                <td colspan="3">
                                    <asp:DropDownList ID="recAgent" runat="server" CssClass="form-control"
                                        AutoPostBack="true" OnSelectedIndexChanged="recAgent_SelectedIndexChanged" Width="200px">
                                    </asp:DropDownList></td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap" valign="top">
                                    <div  class="formLabel">Payout  Branch:</div>
                                </td>
                                <td colspan="3">
                                    <asp:DropDownList ID="recBranch" runat="server" CssClass="form-control" Width="200px"></asp:DropDownList></td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td colspan="2">
                                    <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-primary"
                                        Text=" Detail " ValidationGroup="rpt"
                                        OnClientClick="return showReport();" />
                                    &nbsp;&nbsp;
                                 <asp:Button ID="btnSearch1" runat="server" CssClass="btn btn-primary"
                                     Text=" Summary " ValidationGroup="rpt"
                                     OnClientClick="return showReportSummary();"  />
                                    &nbsp;&nbsp;
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

        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
           var toDate = GetDateValue("<% =toDate.ClientID%>");
           var sAgent = GetValue("<% = sendAgent.ClientID %>");

           var rAgent = GetValue("<% = recAgent.ClientID %>");
           var rBranch = GetValue("<% = recBranch.ClientID %>");

           var url = "ShowReport.aspx?reportName=paiddetlist" +
                "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&sAgent=" + sAgent +
                "&rCountry=Nepal&rAgent=" + rAgent +
                "&rBranch=" + rBranch;

           OpenInNewWindow(url);
           return false;
       }
       function showReportSummary() {
           if (!Page_ClientValidate('rpt'))
               return false;

           var fromDate = GetDateValue("<% =fromDate.ClientID%>");
           var toDate = GetDateValue("<% =toDate.ClientID%>");

           var sAgent = GetValue("<% = sendAgent.ClientID %>");

           var rAgent = GetValue("<% = recAgent.ClientID %>");
           var rBranch = GetValue("<% = recBranch.ClientID %>");

           var url = "ShowReport.aspx?reportName=paidsumlist" +
                "&fromDate=" + fromDate +
                "&toDate=" + toDate +
                "&sAgent=" + sAgent +
                "&rCountry=Nepal&rAgent=" + rAgent +
                "&rBranch=" + rBranch;

           OpenInNewWindow(url);
           return false;
       }

</script>
