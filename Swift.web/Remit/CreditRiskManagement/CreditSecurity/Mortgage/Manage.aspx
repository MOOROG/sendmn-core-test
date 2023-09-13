﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.CreditSecurity.Mortgage.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script src="../../../../ui/js/jquery.min.js" type="text/javascript"></script>
    <script src="../../../../ui/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="../../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../../ui/js/pickers-init.js"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../../ui/js/metisMenu.min.js"></script>
    <script src="../../../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <script type="text/javascript">
        function checkAll(me) {
            var checkBoxes = document.forms[0].chkTran;
            var boolChecked = me.checked;

            for (i = 0; i < checkBoxes.length; i++) {
                checkBoxes[i].checked = boolChecked;
            }
        }
    </script>
    <%-- <style type="text/css">
        legend {
            font-size: 1.2em;
            padding: 5px;
            margin-left: 1em;
            color: #3A4F63;
            background: #CCCCCC;
            font-weight: bold;
        }
    </style>--%>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <asp:UpdatePanel ID="up1" runat="server">
            <ContentTemplate>
                <div class="page-wrapper">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="page-title">
                                <ol class="breadcrumb">
                                    <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                                    <li><a href="#" onclick="return LoadModule('creditrisk_management')">Credit Risk Management </a></li>
                                    <li class="active"><a href="Manage.aspx">Credit Security</a></li>
                                </ol>
                            </div>
                        </div>
                    </div>
                    <div class="listtabs">
                        <ul class="nav nav-tabs" role="tablist">
                            <li role="presentation"><a href="../ListAgent.aspx" target="_self">List Agent</a></li>
                            <li role="presentation"><a href="../BankGuarantee/List.aspx?agentId=<%=GetAgentId()%>" target="_self">Bank Guarantee</a></li>
                            <li role="presentation"><a href="List.aspx?agentId=<%=GetAgentId()%>" target="_self">Mortgage</a></li>
                            <li role="presentation"><a href="../CashSecurity/List.aspx?agentId=<%=GetAgentId()%>" target="_self">Cash Security</a></li>
                            <li role="presentation"><a href="../FixedDeposit/List.aspx?agentId=<%=GetAgentId()%>" target="_self">Fixed Deposit</a></li>
                            <li role="presentation" class="active"><a href="#" target="_self" class="selected">Manage</a></li>
                        </ul>
                    </div>
                    <div class="tab-content">
                        <div role="tabpanel" class="tab-pane active" id="list">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="panel panel-default ">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Mortgage Details</h4>
                                            <div class="panel-actions">
                                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                            </div>
                                        </div>

                                        <div class="panel-body">
                                            <fieldset>
                                                <legend>Mortgage</legend>
                                                <div class="form-group form-inline">
                                                    <label class="col-md-2 control-label">
                                                        Mortgage Office :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="regOffice" ForeColor="Red"
                                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                        <asp:TextBox ID="regOffice" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                    <label class="col-md-2 control-label">
                                                        Mortgage Reg. No. :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="mortgageRegNo" ForeColor="Red"
                                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                        <asp:TextBox ID="mortgageRegNo" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="form-group form-inline">
                                                    <label class="col-md-2 control-label">
                                                        Valuation Amount :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:TextBox ID="valuationAmount" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                    <label class="col-md-2 control-label">
                                                        Currency :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                        <asp:DropDownList ID="currency" runat="server" CssClass="form-control" Width="85%"></asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group form-inline">
                                                    <label class="col-md-2 control-label">
                                                        Valuator :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:TextBox ID="valuator" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                    <label class="col-md-2 control-label">
                                                        Mortgage Date :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="valuationDate" ForeColor="Red"
                                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                        <div class="input-group m-b">
                                                            <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                            <asp:TextBox ID="valuationDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                        </div>
                                                        <cc1:CalendarExtender ID="CalendarExtender1" runat="server" CssClass="cal_Theme1" TargetControlID="valuationDate"></cc1:CalendarExtender>
                                                        <asp:RangeValidator ID="RangeValidator1" runat="server"
                                                            ControlToValidate="valuationDate"
                                                            MaximumValue="12/31/2100"
                                                            MinimumValue="01/01/1900"
                                                            Type="Date"
                                                            ErrorMessage="* Invalid date"
                                                            ValidationGroup="country"
                                                            CssClass="errormsg"
                                                            SetFocusOnError="true"
                                                            Display="Dynamic"> </asp:RangeValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group form-inline">
                                                    <label class="col-md-2 control-label">
                                                        Property Type :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:TextBox ID="propertyType" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                    <label class="col-md-2 control-label">
                                                        Plot(Kitta) No :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:TextBox ID="plotNo" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </fieldset>
                                        </div>

                                        <!-- second fieldset -->
                                        <div class="panel-body">
                                            <fieldset>
                                                <legend>Owner Information</legend>

                                                <div class="form-group form-inline">
                                                    <label class="col-md-2 control-label">
                                                        Owner :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:TextBox ID="owner" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                    <label class="col-md-2 control-label">
                                                        Country :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:DropDownList ID="country" runat="server" CssClass="form-control" Width="85%" AutoPostBack="true"
                                                            OnSelectedIndexChanged="country_SelectedIndexChanged">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group form-inline">
                                                    <label class="col-md-2 control-label">
                                                        State :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:DropDownList ID="state" runat="server" CssClass="form-control" Width="85%"></asp:DropDownList>
                                                    </div>
                                                    <label class="col-md-2 control-label">
                                                        City :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:TextBox ID="city" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="form-group form-inline">
                                                    <label class="col-md-2 control-label">
                                                        Zip :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:TextBox ID="zip" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                    <label class="col-md-2 control-label">
                                                        Address :
                                                    </label>
                                                    <div class="col-md-3">
                                                        <asp:TextBox ID="address" runat="server" CssClass="form-control" TextMode="MultiLine"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </fieldset>
                                        </div>

                                        <!-- fieldset third start  -->
                                        <div class="panel-body">
                                            <fieldset>
                                                <legend>Document</legend>
                                                <div class="form-group form-inline">
                                                    <label class="col-md-2 control-label">
                                                        Document :
                                                    </label>
                                                    <div class="col-md-10">
                                                        <div class="col-md-3">
                                                            <input id="fileUpload" runat="server" name="fileUpload" type="file" class="file-upload" />
                                                        </div>
                                                        <div class="col-md-5">
                                                            <asp:Button ID="btnDeleteFile" runat="server" Text="Delete Selected" CssClass="btn btn-primary m-t-25" OnClick="btnDeleteFile_Click" />
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="form-group form-inline">
                                                    <label class="col-md-2 control-label">
                                                        File Description :
                                                    </label>
                                                    <div class="col-md-8">
                                                        <asp:TextBox ID="fileDescription" runat="server" CssClass="form-control"></asp:TextBox>
                                                        <asp:Button ID="btnUpload" runat="server" Text="Upload" CssClass="btn btn-primary m-t-25" OnClick="btnUpload_Click" />
                                                    </div>
                                                </div>
                                                <div class="form-group form-inline">
                                                    <label class="col-md-2 control-label">
                                                    </label>
                                                    <div class="col-md-9">
                                                        <asp:Label ID="lblMsg" Font-Bold="true" ForeColor="Red" runat="server" Text=""></asp:Label>
                                                        <div class="table-responsive">
                                                            <asp:Table ID="tblResult" runat="server" class="table table-striped table-bordered"></asp:Table>
                                                        </div>
                                                    </div>
                                                </div>
                                            </fieldset>
                                        </div>
                                        <div class="panel-body">
                                            <legend></legend>
                                            <div class="form-group ">
                                                <div class="col-md-8 col-md-offset-2">
                                                    <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country" CssClass="btn btn-primary m-t-25" TabIndex="5" OnClick="btnSave_Click" />
                                                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                    </cc1:ConfirmButtonExtender>
                                                    <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-primary m-t-25" TabIndex="6" OnClick="btnDelete_Click" />
                                                    <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
                                                        ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                                    </cc1:ConfirmButtonExtender>
                                                    <input id="btnBack" type="button" value="Back" class="btn btn-primary m-t-25" onclick=" Javascript: history.back(); " />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="country" EventName="SelectedIndexChanged" />
                <asp:PostBackTrigger ControlID="btnUpload" />
            </Triggers>
        </asp:UpdatePanel>

        <%--<table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td width="100%">
                    <asp:Panel ID="pnl1" runat="server">
                        <table width="100%">
                            <tr>
                                <td height="26" class="bredCrom">
                                    <div>Credit Risk Management » Credit Security » Mortgage » Manage </div>
                                </td>
                            </tr>
                            <tr>
                                <td height="20" class="welcome"><span id="spnCname" runat="server"><%=GetAgentName()%></span></td>
                            </tr>
                            <tr>
                                <td height="10" width="100%">
                                    <div class="tabs">
                                        <ul>
                                            <li><a href="../ListAgent.aspx">List Agent</a></li>
                                            <li><a href="../BankGuarantee/List.aspx?agentId=<%=GetAgentId()%>">Bank Guarantee</a></li>
                                            <li><a href="List.aspx?agentId=<%=GetAgentId()%>">Mortgage</a></li>
                                            <li><a href="#">Cash Security</a></li>
                                            <li><a href="../FixedDeposit/List.aspx?agentId=<%=GetAgentId()%>">Fixed Deposit</a></li>
                                            <li><a href="../CashSecurity/List.aspx?agentId=<%=GetAgentId()%>" class="selected">Manage</a></li>
                                        </ul>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </asp:Panel>
                </td>
            </tr>
            <tr>
                <td height="524" valign="top">
                    <asp:UpdatePanel ID="upnl1" runat="server">
                        <ContentTemplate>
                            <table border="0" cellspacing="0" cellpadding="0" class="formTable" align="left">
                                <tr>
                                    <th class="frmTitle">Mortgage Details</th>
                                </tr>
                                <tr>
                                    <td class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                                </tr>
                                <tr>
                                    <td>--%>
        <%--<fieldset>
                                            <legend>Mortgage</legend>
                                            <table>
                                                <tr>
                                                    <td colspan="2">Mortgage Office
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="regOffice" ForeColor="Red"
                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                        <br />
                                                        <asp:TextBox ID="regOffice" runat="server" Width="313px" CssClass="input"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>--%>
        <%--       <td>Mortgage Reg. No.
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="mortgageRegNo" ForeColor="Red"
                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                        <br />
                                                        <asp:TextBox ID="mortgageRegNo" runat="server" CssClass="input" Width="150px"></asp:TextBox>
                                                    </td>--%>
        <%--<td>Valuation Amount<br />
                                                        <asp:TextBox ID="valuationAmount" runat="server" CssClass="input" Width="150px"></asp:TextBox>
                                                    </td>
                                                    <td>--%>
        <%--Currency--%>
        <%--   <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                        <br />
                                                        <asp:DropDownList ID="currency" runat="server" Width="135px"></asp:DropDownList>
                                                    </td>
                                                </tr>
                                                <tr>--%>
        <%--   <td valign="top">Valuator<br />
                                                        <asp:TextBox ID="valuator" runat="server" CssClass="input" Width="150px"></asp:TextBox>
                                                    </td>
                                                    <td>Mortgage Date
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="valuationDate" ForeColor="Red"
                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                        <br />
                                                        <asp:TextBox ID="valuationDate" runat="server" CssClass="input" Width="100px"></asp:TextBox>
                                                        <cc1:CalendarExtender ID="CalendarExtender1" runat="server" CssClass="cal_Theme1" TargetControlID="valuationDate"></cc1:CalendarExtender>
                                                        <asp:RangeValidator ID="RangeValidator1" runat="server"
                                                            ControlToValidate="valuationDate"
                                                            MaximumValue="12/31/2100"
                                                            MinimumValue="01/01/1900"
                                                            Type="Date"
                                                            ErrorMessage="* Invalid date"
                                                            ValidationGroup="country"
                                                            CssClass="errormsg"
                                                            SetFocusOnError="true"
                                                            Display="Dynamic"> </asp:RangeValidator>
                                                    </td>
                                                    <td valign="top">Property Type<br />
                                                        <asp:TextBox ID="propertyType" runat="server" Width="135px" CssClass="input"></asp:TextBox>
                                                    </td>
                                                    <td valign="top">Plot(Kitta) No<br />
                                                        <asp:TextBox ID="plotNo" runat="server" CssClass="input" Width="150px"></asp:TextBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>--%>
        <%--   </td>
                                </tr>
                                <tr>

                                    <td>
                                        <fieldset>
                                            <legend>Owner Information</legend>
                                            <table>
                                                <tr>
                                                    <td colspan="2">Owner<br />
                                                        <asp:TextBox ID="owner" runat="server" CssClass="input" Width="300px"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>Country<br />
                                                        <asp:DropDownList ID="country" runat="server" Width="153px" CssClass="input" AutoPostBack="true"
                                                            OnSelectedIndexChanged="country_SelectedIndexChanged">
                                                       </asp:DropDownList>
                                                    </td>
                                                    <td>State<br />
                                                        <asp:DropDownList ID="state" runat="server" Width="153px" CssClass="input"></asp:DropDownList>
                                                    </td>
                                                    <td>City<br />
                                                        <asp:TextBox ID="city" runat="server" CssClass="input" Width="153px"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top">Zip<br />
                                                        <asp:TextBox ID="zip" runat="server" CssClass="input" Width="153px"></asp:TextBox>
                                                    </td>
                                                    <td colspan="2">Address<br />
                                                        <asp:TextBox ID="address" runat="server" Width="313px" Height="30px" TextMode="MultiLine" CssClass="input"></asp:TextBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>
                                    </td>
                                </tr>
                                <tr>
                                    <td> --%>

        <%--  <fieldset>
                                            <legend>Document</legend>
                                            <table>
                                                <tr>
                                                    <td class="frmLable">Document:</td>
                                                    <td>
                                                        <input id="fileUpload" runat="server" name="fileUpload" type="file" size="20" class="input" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="frmLable">File Description:</td>
                                                    <td>
                                                        <asp:TextBox ID="fileDescription" runat="server" Width="270px" CssClass="input"></asp:TextBox>
                                                        &nbsp;<asp:Button ID="btnUpload" runat="server" Text="Upload" CssClass="button"
                                                            OnClick="btnUpload_Click" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td></td>
                                                    <td>
                                                        <asp:Label ID="lblMsg" Font-Bold="true" ForeColor="Red" runat="server" Text=""></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="2">
                                                        <asp:Table ID="tblResult" runat="server" Width="100%"></asp:Table>
                                                        <br />
                                                        <asp:Button ID="btnDeleteFile" runat="server" Text="Delete Selected"
                                                            CssClass="button" OnClick="btnDeleteFile_Click" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>--%>
        <%-- </ContentTemplate>
                        <triggers>
                            <asp:AsyncPostBackTrigger ControlID="country" EventName="SelectedIndexChanged" />
                        </triggers>
        </asp:UpdatePanel>
                </td>
            </tr>
        </table>--%>
    </form>
</body>
</html>