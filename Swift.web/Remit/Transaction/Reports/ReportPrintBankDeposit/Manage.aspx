<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.ReportPrintBankDeposit.Manage" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Src="../../../../Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../../../Css/style.css" rel="Stylesheet" type="text/css" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../Css/swift_compnent.css" rel="stylesheet" type="text/css" />
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../js/jQuery/jquery-ui.min.js"></script>
    <script type="text/javascript" src="../../../../js/functions.js"></script>
    <script src="../../../../js/swift_autocomplete.js" type="text/javascript"></script>
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
                showOn: "both",
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
                showOn: "both",
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
                showOn: "both",
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true,
                onSelect: function (selectedDate) {
                    $(".fromDatePicker").datepicker("option", "maxDate", selectedDate);
                }
            });
        });

        function CheckRedownload() {
            GetElement("trDate").style.display = "none";
            if (GetElement("redownload").checked) {
                GetElement("trDate").style.display = "block";
            }
        }
    </script>
    <style type="text/css">
        .table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
            border-top : none !important;
        }
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
            <div class="page-wrapper">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="page-title">
                            <ol class="breadcrumb">
                                <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                              <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
                            <li class="active"><a href="Manage.aspx">A/C Deposit Report</a></li>
                            </ol>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-8">
                        <div class="panel panel-default recent-activites">
                            <div class="panel-heading">
                                <h4 class="panel-title">A/C Deposit Report - Print
                                </h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="form-group table table-responsive">
                                    <table border="0" cellspacing="0" cellpadding="0" class="table table-responsive">
                                        <tr>
                                            <td valign="bottom"><b>Bank Name :<span class="errormsg">*</span></b></td>
                                            <td colspan="3">
                                                <asp:DropDownList ID="bankName" runat="server" CssClass="form-control"></asp:DropDownList>
                                                
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="bankName" ForeColor="Red"
                                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="bottom"><b>Tran Type :</b></td>
                                            <td colspan="3">
                                                <asp:DropDownList ID="tranType" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="">All</asp:ListItem>
                                                    <asp:ListItem Value="D">Domestic</asp:ListItem>
                                                    <asp:ListItem Value="I">International</asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td><strong>Date :</strong></td>
                                            <td nowrap="nowrap" valign="top">
                                                <asp:DropDownList ID="dateType" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="paidDate">By Paid Date</asp:ListItem>
                                                    <asp:ListItem Value="postedDate">By Post Date</asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                            
                                        </tr>
                                        <tr>
                                            <td></td>
                                            <td nowrap="nowrap" valign="top"><strong>From :<span class="errormsg">*</span></strong>
                                                <asp:TextBox ID="fromDate" runat="server" ReadOnly="true" CssClass="form-control fromDatePicker"></asp:TextBox><br />
                                                <asp:TextBox ID="fromTime1" runat="server" Text="00:00:00" CssClass="form-control"></asp:TextBox>

                                                <cc1:MaskedEditExtender ID="qwedq" runat="server" TargetControlID="fromTime1"
                                                    Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                    ErrorTooltipEnabled="True" />

                                                <cc1:MaskedEditValidator ID="MaskedEditValidator3" runat="server" ControlExtender="MaskedEditExtender2"
                                                    ControlToValidate="fromTime1" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                    EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                    MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                    SetFocusOnError="true" ForeColor="Red" ValidationGroup="report"
                                                    ToolTip="Enter time between 00:00:00 to 23:59:59">
                                                </cc1:MaskedEditValidator>
                                                
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ControlToValidate="fromTime1" ForeColor="Red"
                                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>


                                            </td>
                                            <td nowrap="nowrap" valign="top"><strong>To :<span class="errormsg">*</span></strong>

                                                <asp:TextBox ID="toDate" runat="server" ReadOnly="true" CssClass="form-control toDatePicker"></asp:TextBox><br />
                                                <asp:TextBox ID="toTime1" runat="server" Text="23:59:59" CssClass="form-control"></asp:TextBox>

                                                <cc1:MaskedEditExtender ID="MaskedEditExtender3" runat="server" TargetControlID="toTime1"
                                                    Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                    ErrorTooltipEnabled="True" />

                                                <cc1:MaskedEditValidator ID="MaskedEditValidator4" runat="server" ControlExtender="MaskedEditExtender2"
                                                    ControlToValidate="toTime1" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                    EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                    MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                    SetFocusOnError="true" ForeColor="Red" ValidationGroup="report"
                                                    ToolTip="Enter time between 00:00:00 to 23:59:59">
                                                </cc1:MaskedEditValidator>
                                                
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator9" runat="server" ControlToValidate="toTime1" ForeColor="Red"
                                                    ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>


                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td>
                                                <asp:CheckBox ID="chkSender" runat="server" value="sender" />
                                                Show Sender Details </td>
                                            <td colspan="2">
                                                <asp:CheckBox ID="chkBankComm" runat="server" value="bankComm" />
                                                Show Bank Commission </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td>
                                                <asp:CheckBox ID="chkGenerator" runat="server" value="generator" />
                                                Show Generator Details </td>
                                            <td colspan="2">
                                                <asp:CheckBox ID="chkIMERef" runat="server" value="imeref" />Show <%=GetStatic.GetTranNoName() %></td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td colspan="3">

                                                <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary"
                                                    Text=" Search " ValidationGroup="rpt"
                                                    OnClientClick="return showReport();" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-8">
                        <div class="panel panel-default recent-activites">
                            <div class="panel-heading">
                                <h4 class="panel-title">Reports » A/C Deposit Report
                                </h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="form-group table table-responsive">
                                    <table border="0" cellspacing="0" cellpadding="0" class="table table-responsive">
                                        <tr>
                                            <td valign="bottom" style="width: 150px;"><b>Sending Agent :</b></td>
                                            <td colspan="3">
                                                <asp:DropDownList ID="sendingAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="bottom"><b>Payout Country :</b></td>
                                            <td colspan="3">
                                                <asp:Label ID="beneficiaryCountry" runat="server" Text="Nepal" Width="300px"
                                                    Style="font-weight: 700"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="bottom"><b>Payout Agent (Bank) :</b></td>
                                            <td colspan="3">
                                                <asp:DropDownList ID="payoutBankName" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="bottom"><b>Tran Type :</b></td>
                                            <td colspan="3">
                                                <asp:DropDownList ID="tranType1" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="">All</asp:ListItem>
                                                    <asp:ListItem Value="D">Domestic</asp:ListItem>
                                                    <asp:ListItem Value="I">International</asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="bottom"><b>Post User :</b></td>
                                            <td colspan="3">
                                                <uc1:SwiftTextBox ID="postUser" Category="adminUser" runat="server" CssClass="form-control"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="bottom"><b>Redownload :</b></td>
                                            <td colspan="3">
                                                <asp:CheckBox ID="redownload" runat="server" value="r" onclick="CheckRedownload(this);" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="4">
                                                <table id="trDate" style="display: none;" class="table table-responsive">
                                                    <tr>
                                                        <td><strong>Date :</strong></td>
                                                        <td nowrap="nowrap" valign="top">
                                                            <asp:DropDownList ID="dateType1" runat="server" CssClass="form-control">
                                                                <asp:ListItem Value="postDate">By Post Date</asp:ListItem>
                                                                <asp:ListItem Value="paidDate">By Paid Date</asp:ListItem>
                                                                <asp:ListItem Value="confirmDate">By Confirm Date</asp:ListItem>
                                                            </asp:DropDownList>
                                                        </td>
                                                        
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td nowrap="nowrap" valign="top"><strong>From :<span class="errormsg">*</span></strong> 
                                                            <asp:TextBox ID="fromDate1" runat="server" ReadOnly="true" CssClass="form-control fromDatePicker"></asp:TextBox><br />
                                                            <asp:TextBox ID="fromTime" runat="server" Text="00:00:00" CssClass="form-control"></asp:TextBox>

                                                            <cc1:MaskedEditExtender ID="MaskedEditExtender2" runat="server" TargetControlID="fromTime"
                                                                Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                                ErrorTooltipEnabled="True" />

                                                            <cc1:MaskedEditValidator ID="MaskedEditValidator2" runat="server" ControlExtender="MaskedEditExtender2"
                                                                ControlToValidate="fromTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                                EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                                MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                                SetFocusOnError="true" ForeColor="Red" ValidationGroup="report"
                                                                ToolTip="Enter time between 00:00:00 to 23:59:59">
                                                            </cc1:MaskedEditValidator>

                                                            
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="fromDate1" ForeColor="Red"
                                                                ValidationGroup="report" Display="Dynamic" ErrorMessage="Required!">
                                                            </asp:RequiredFieldValidator>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="fromTime" ForeColor="Red"
                                                                ValidationGroup="report" Display="Dynamic" ErrorMessage="Required!">
                                                            </asp:RequiredFieldValidator>
                                                        </td>
                                                        <td nowrap="nowrap" valign="top"><strong>To :<span class="errormsg">*</span></strong>

                                                            <asp:TextBox ID="toDate1" runat="server" ReadOnly="true" CssClass="form-control toDatePicker"></asp:TextBox><br />
                                                            <asp:TextBox ID="toTime" runat="server" Text="23:59:59" CssClass="form-control"></asp:TextBox>

                                                            <cc1:MaskedEditExtender ID="MaskedEditExtender1" runat="server" TargetControlID="toTime"
                                                                Mask="99:99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft"
                                                                ErrorTooltipEnabled="True" />

                                                            <cc1:MaskedEditValidator ID="MaskedEditValidator1" runat="server" ControlExtender="MaskedEditExtender2"
                                                                ControlToValidate="toTime" IsValidEmpty="false" MaximumValue="23:59:59" MinimumValue="00:00:00"
                                                                EmptyValueMessage="Enter Time" MaximumValueMessage="23:59:59" InvalidValueBlurredMessage="Time is Invalid"
                                                                MinimumValueMessage="Time must be grater than 00:00:00" EmptyValueBlurredText="*"
                                                                SetFocusOnError="true" ForeColor="Red" ValidationGroup="report"
                                                                ToolTip="Enter time between 00:00:00 to 23:59:59">
                                                            </cc1:MaskedEditValidator>
                                                            
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="toDate1" ForeColor="Red"
                                                                ValidationGroup="report" Display="Dynamic" ErrorMessage="Required!">
                                                            </asp:RequiredFieldValidator>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="toTime" ForeColor="Red"
                                                                ValidationGroup="report" Display="Dynamic" ErrorMessage="Required!">
                                                            </asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td colspan="3">
                                                <asp:Button ID="Button1" runat="server" CssClass="btn btn-primary"
                                                    Text=" Download -Detail " ValidationGroup="report"
                                                    OnClientClick="return showAcDepositDetail();" />
                                                &nbsp;
                                <asp:Button ID="Button2" runat="server" CssClass="btn btn-primary"
                                    Text=" Summary " ValidationGroup="report"
                                    OnClientClick="return showAcDepositSummary();" />
                                            </td>
                                        </tr>
                                    </table>
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
        if (!Page_ClientValidate('rpt'))
            return false;

        var bankId = GetValue("<% =bankName.ClientID%>");
        var bankObj = GetElement("<% =bankName.ClientID%>");
        var bankName = bankObj.options[bankObj.selectedIndex].text;
        var dateType = GetValue("<% =dateType.ClientID%>");
        var fromDate = GetDateValue("<% =fromDate.ClientID%>");
        var toDate = GetDateValue("<% =toDate.ClientID%>");
        var fromTime1 = GetValue("<%=fromTime1.ClientID %>");
        var toTime1 = GetValue("<%=toTime1.ClientID %>");
        var tranType = GetValue("<%=tranType.ClientID %>");
        var chkSender = document.getElementById('<%= chkSender.ClientID %>').checked;
        var chkBankComm = document.getElementById('<%= chkBankComm.ClientID %>').checked;
        var chkGenerator = document.getElementById('<%= chkGenerator.ClientID %>').checked;
        var chkImeRef = document.getElementById('<%= chkIMERef.ClientID %>').checked;

        var url = "List.aspx?bankId=" + bankId +
                 "&dateType=" + dateType +
                 "&fromDate=" + fromDate +
                 "&bankName=" + bankName +
                 "&toDate=" + toDate +
                 "&tranType=" + tranType +
                 "&chkSender=" + chkSender +
                 "&chkBankComm=" + chkBankComm +
                 "&chkGenerator=" + chkGenerator +
                 "&chkIMERef=" + chkImeRef +
                 "&fromTime1=" + fromTime1 +
                 "&toTime1=" + toTime1;
        OpenInNewWindow(url);
        return false;
    }
    function showAcDepositDetail() {
        if (!Page_ClientValidate('report'))
            return false;

        var sendingAgent = GetValue("<% =sendingAgent.ClientID%>");
        var bankId = GetValue("<% =payoutBankName.ClientID%>");
        var fromDate1 = GetDateValue("<% =fromDate1.ClientID%>");
        var toDate1 = GetDateValue("<% =toDate1.ClientID%>");
        var tranType = GetValue("<%=tranType1.ClientID %>");
        var dateType1 = GetValue("<%=dateType1.ClientID %>");
        var fromTime = GetValue("<%=fromTime.ClientID %>");
        var toTime = GetValue("<%=toTime.ClientID %>");
        var redownload = document.getElementById('<%= redownload.ClientID %>').checked;
        var paidUser = GetItem("<% =postUser.ClientID %>")[1];
        var url = "../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=acdepositdetail" +
                 "&sendingAgent=" + sendingAgent +
                 "&bankId=" + bankId +
                 "&tranType=" + tranType +
                 "&fromDate=" + fromDate1 +
                 "&toDate=" + toDate1 +
                 "&dateType=" + dateType1 +
                 "&fromTime=" + fromTime +
                 "&toTime=" + toTime +
                 "&paidUser=" + paidUser +
                 "&redownload=" + redownload;

        OpenInNewWindow(url);
        return false;
    }
    function showAcDepositSummary() {
        if (!Page_ClientValidate('report'))
            return false;

        var sendingAgent = GetValue("<% =sendingAgent.ClientID%>");
        var bankId = GetValue("<% =payoutBankName.ClientID%>");
        var fromDate1 = GetDateValue("<% =fromDate1.ClientID%>");
        var toDate1 = GetDateValue("<% =toDate1.ClientID%>");
        var tranType = GetValue("<%=tranType1.ClientID %>");
        var dateType1 = GetValue("<%=dateType1.ClientID %>");
        var fromTime = GetValue("<%=fromTime.ClientID %>");
        var toTime = GetValue("<%=toTime.ClientID %>");
        var redownload = document.getElementById('<%= redownload.ClientID %>').checked;
        var paidUser = GetItem("<% =postUser.ClientID %>")[1];
        var url = "../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=acdepositsummary" +
                 "&sendingAgent=" + sendingAgent +
                 "&bankId=" + bankId +
                 "&tranType=" + tranType +
                 "&fromDate=" + fromDate1 +
                 "&toDate=" + toDate1 +
                 "&dateType=" + dateType1 +
                 "&fromTime=" + fromTime +
                 "&toTime=" + toTime +
                 "&paidUser=" + paidUser +
                 "&redownload=" + redownload;

        OpenInNewWindow(url);
        return false;
    }
</script>
