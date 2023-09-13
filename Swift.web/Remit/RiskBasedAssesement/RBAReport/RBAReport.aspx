<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RBAReport.aspx.cs" Inherits="Swift.web.Remit.RiskBasedAssesement.RBAReport.RBAReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"></script>

    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../../js/swift_autocomplete.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery.min.js" type="text/javascript"></script>
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
                            <li class="active"><a href="RBAReport.aspx">RBA  Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Remittance</a></li>
                    <li><a href="RBAReportMex.aspx" target="_self">Money Exchange </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-10">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Risk Base Analysis Report </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle"></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <asp:UpdatePanel ID="updatePanel1" runat="server">
                                            <ContentTemplate>
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <td>
                                                            <label>Report For:</label>
                                                        </td>
                                                        <td>
                                                            <asp:RadioButtonList ID="reportFor" runat="server" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="reportFor_SelectedIndexChanged">
                                                                <asp:ListItem Value="Txn RBA">Txn RBA</asp:ListItem>
                                                                <asp:ListItem Value="Txn Average RBA">Txn Average RBA</asp:ListItem>
                                                                <asp:ListItem Value="Periodic RBA">Periodic RBA</asp:ListItem>
                                                                <asp:ListItem Value="Final RBA" Selected="true">Final RBA</asp:ListItem>
                                                            </asp:RadioButtonList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label>Sending Country: <span class="errormsg">*</span></label>
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control" AutoPostBack="True" OnSelectedIndexChanged="sCountry_SelectedIndexChanged">
                                                            </asp:DropDownList>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="sCountry" ForeColor="Red"
                                                                ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                            </asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr id="trSendingAgent" runat="server" visible="false">
                                                        <td>
                                                            <label>Sending Agent:</label>
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control" AutoPostBack="True" OnSelectedIndexChanged="sAgent_SelectedIndexChanged">
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <tr id="trSendingBranch" runat="server" visible="false">
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
                                                            <label>Sender's Native Country:</label>
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="sNativeCountry" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label>Sender's ID Number:</label>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="sIdNumber" runat="server" CssClass="form-control"></asp:TextBox>

                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label>Date:</label>
                                                        </td>
                                                        <td>
                                                            <div class="row">
                                                                <div class="col-md-6">
                                                                    From  <span class="errormsg">*</span>
                                                                    <div class="input-group m-b">
                                                                        <span class="input-group-addon">
                                                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                                                        </span>
                                                                        <asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t')" MaxLength="10" runat="server" CssClass="form-control-inline input-medium form-control " size="12"></asp:TextBox>

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
                                                                        <asp:TextBox ID="toDate" onchange="return DateValidation('toDate','t')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium " size="12"></asp:TextBox>
                                                                    </div>

                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>
                                                                </div>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label>RBA Range:</label>
                                                        </td>
                                                        <td>
                                                            <div class="row">
                                                                <div class="col-md-6">
                                                                    <asp:TextBox ID="rbaRangeFrom" runat="server" Text="" CssClass="form-control" size="12"></asp:TextBox>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <asp:TextBox ID="rbaRangeTo" runat="server" Text="" CssClass="form-control" size="12"></asp:TextBox>

                                                                </div>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label>Report Type:<span class="errormsg">*</span></label>
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="rptType" runat="server" CssClass="form-control">
                                                                <asp:ListItem Value="">Select</asp:ListItem>
                                                                <asp:ListItem Value="Detail Report">Detail Report</asp:ListItem>
                                                                <asp:ListItem Value="Summary Report-Monthly">Summary Report-Monthly</asp:ListItem>
                                                            </asp:DropDownList>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="rptType" ForeColor="Red"
                                                                ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                            </asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr id="trReceiverCountry" runat="server" visible="false">
                                                        <td>
                                                            <label>Receiver&#39;s Country:</label>
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="rCountry" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label>Txn to Non Native Country:</label>
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList ID="txnToNonNativeCountry" runat="server" CssClass="form-control">
                                                                <asp:ListItem Value="">All</asp:ListItem>
                                                                <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                                <asp:ListItem Value="N">No</asp:ListItem>
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td><b><u>Additional Filter</u></b></td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <label>TXN Amount:</label>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="txnAmountFrom" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="txnAmountTo" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr id="trTxnCount" runat="server">
                                                        <td>
                                                            <label>TXN Count:</label>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="txnCountFrom" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="txnCountTo" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr id="trBenCountryCount" runat="server">
                                                        <td>
                                                            <label>Beneficiary Country Count:</label>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="pCountryCountFrom" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="pCountryCountTo" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr id="trBenCount" runat="server">
                                                        <td>
                                                            <label>Beneficiary Count:</label>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="beneficiaryCountFrom" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="beneficiaryCountTo" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr id="trOutletCount" runat="server">
                                                        <td>
                                                            <label>Outlet Count:</label>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="outletCountFrom" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="outletCountTo" runat="server" CssClass="form-control" size="12"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                        <td>
                                                            <asp:Button ID="BtnSave1" runat="server" CssClass="btn btn-primary m-t-25" Text=" Search " ValidationGroup="rpt" OnClientClick="return showReport();" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="sCountry" EventName="SelectedIndexChanged" />
                                                <asp:AsyncPostBackTrigger ControlID="rCountry" EventName="SelectedIndexChanged" />
                                                <asp:AsyncPostBackTrigger ControlID="sAgent" EventName="SelectedIndexChanged" />
                                                <asp:AsyncPostBackTrigger ControlID="reportFor" EventName="SelectedIndexChanged" />
                                            </Triggers>
                                        </asp:UpdatePanel>
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

        var reportFor = getRadioCheckedValue("<%=reportFor.ClientID %>");
        var sCountry = GetValue("<% =sCountry.ClientID%>") == "" ? "" : $("#sCountry option:selected").text();
        var sAgent = GetValue("<% =sAgent.ClientID%>");
        var sBranch = GetValue("<% =sBranch.ClientID%>");
        var sNativeCountry = GetValue("<% =sNativeCountry.ClientID%>");
        var rCountry = GetValue("<% =rCountry.ClientID%>");

        var sIdNumber = GetValue("<% =sIdNumber.ClientID%>");
        var fromDate = GetValue("<% =fromDate.ClientID%>");
        var toDate = GetValue("<% =toDate.ClientID%>");
        var rbaRangeFrom = GetValue("<% =rbaRangeFrom.ClientID%>");
        var rbaRangeTo = GetValue("<% =rbaRangeTo.ClientID%>");
        var txnToNonNativeCountry = GetValue("<% =txnToNonNativeCountry.ClientID%>");
        var rptType = GetValue("<% =rptType.ClientID%>");

        var txnAmountFrom = GetValue("<% =txnAmountFrom.ClientID%>");
        var txnAmountTo = GetValue("<%=txnAmountTo.ClientID %>");
        var txnCountFrom = GetValue("<%=txnCountFrom.ClientID %>");
        var txnCountTo = GetValue("<%=txnCountTo.ClientID %>");
        var pCountryCountFrom = GetValue("<%=pCountryCountFrom.ClientID %>");
        var pCountryCountTo = GetValue("<%=pCountryCountTo.ClientID %>");
        var beneficiaryCountFrom = GetValue("<%=beneficiaryCountFrom.ClientID %>");
        var beneficiaryCountTo = GetValue("<%=beneficiaryCountTo.ClientID %>");
        var outletCountFrom = GetValue("<%=outletCountFrom.ClientID %>");
        var outletCountTo = GetValue("<%=outletCountTo.ClientID %>");

        var url = "../../../SwiftSystem/Reports/Reports.aspx?reportName=rbareport" +
         "&reportFor=" + reportFor +
         "&sCountry=" + sCountry +
         "&sAgent=" + sAgent +
         "&sBranch=" + sBranch +
         "&sNativeCountry=" + sNativeCountry +
         "&rCountry=" + rCountry +
         "&sIdNumber=" + sIdNumber +
         "&fromDate=" + fromDate +
         "&toDate=" + toDate +
         "&rbaRangeFrom=" + rbaRangeFrom +
         "&rbaRangeTo=" + rbaRangeTo +
         "&txnToNonNativeCountry=" + txnToNonNativeCountry +
         "&rptType=" + rptType +
         "&txnAmountFrom=" + txnAmountFrom +
         "&txnAmountTo=" + txnAmountTo +
         "&txnCountFrom=" + txnCountFrom +
         "&txnCountTo=" + txnCountTo +
         "&pCountryCountFrom=" + pCountryCountFrom +
         "&pCountryCountTo=" + pCountryCountTo +
         "&beneficiaryCountFrom=" + beneficiaryCountFrom +
         "&beneficiaryCountTo=" + beneficiaryCountTo +
         "&outletCountFrom=" + outletCountFrom +
         "&outletCountTo=" + outletCountTo;

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
