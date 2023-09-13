﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.CreditSecurity.BankGuarantee.Manage" %>

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
                            <li><a href="#" onclick="return LoadModule('creditrisk_management')">Credit Risk Management </a></li>
                            <li class="active"><a href="Manage.aspx">Credit Security</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="../ListAgent.aspx" target="_self">List Agent</a></li>
                    <li><a href="List.aspx?agentId=<%=GetAgentId()%>" target="_self">Bank Guarantee</a></li>
                    <li><a href="../Mortgage/List.aspx?agentId=<%=GetAgentId()%>" target="_self">Mortgage</a></li>
                    <li><a href="../CashSecurity/List.aspx?agentId=<%=GetAgentId()%>">Cash Security</a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected">Fixed Deposit</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-8">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Bank Guarantee Details</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>

                                <div class="panel-body">

                                    <div class="form-group">
                                        <label class="col-md-8 control-label">
                                            <span id="spnCname" runat="server"><%=GetAgentName()%></span>
                                        </label>
                                    </div>
                                    <!-- filedset first start -->
                                    <fieldset>
                                        <legend>Bank Guarantee Details</legend>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">
                                                Guarantee No. :
                                            </label>
                                            <div class="col-md-6">
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="guaranteeNo" ForeColor="Red"
                                                    ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                                <asp:TextBox ID="guaranteeNo" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">
                                                Amount of Guarantee :
                                            </label>
                                            <div class="col-md-6">
                                                <asp:TextBox ID="amount" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">
                                                Currency :
                                            </label>
                                            <div class="col-md-6">
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                                    ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                                <asp:DropDownList ID="currency" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">
                                                Bank Name :
                                            </label>
                                            <div class="col-md-6">
                                                <asp:TextBox ID="bankName" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">
                                                Issued Date :
                                            </label>
                                            <div class="col-md-6">
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="issuedDate" ForeColor="Red"
                                                    ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                                <div class="input-group m-b">
                                                    <span class="input-group-addon">
                                                        <i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                    <asp:TextBox ID="issuedDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                </div>
                                                <cc1:CalendarExtender ID="CalendarExtender1" runat="server" CssClass="cal_Theme1"
                                                    TargetControlID="issuedDate">
                                                </cc1:CalendarExtender>
                                                <asp:RangeValidator ID="RangeValidator1" runat="server" ControlToValidate="issuedDate" MaximumValue="12/31/2100"
                                                    MinimumValue="01/01/1900" Type="Date" ErrorMessage="* Invalid date" ValidationGroup="country"
                                                    CssClass="errormsg" SetFocusOnError="true" Display="Dynamic"> </asp:RangeValidator>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">
                                                Expiry Date:
                                            </label>
                                            <div class="col-md-6">
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="expiryDate" ForeColor="Red"
                                                    ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                                <div class="input-group m-b">
                                                    <span class="input-group-addon">
                                                        <i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                    <asp:TextBox ID="expiryDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                </div>
                                                <cc1:CalendarExtender ID="ce1" runat="server" CssClass="cal_Theme1" TargetControlID="expiryDate"></cc1:CalendarExtender>
                                                <asp:RangeValidator ID="RangeValidator2" runat="server" ControlToValidate="expiryDate"
                                                    MaximumValue="12/31/2100" MinimumValue="01/01/1900" Type="Date" ErrorMessage="* Invalid date"
                                                    ValidationGroup="country" CssClass="errormsg" SetFocusOnError="true" Display="Dynamic"> </asp:RangeValidator>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">
                                                Follow Up Date :
                                            </label>
                                            <div class="col-md-6">

                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="followUpDate" ForeColor="Red"
                                                    ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                                <div class="input-group m-b">
                                                    <span class="input-group-addon">
                                                        <i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                    <asp:TextBox ID="followUpDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                </div>
                                                <cc1:CalendarExtender ID="CalendarExtender2" runat="server" CssClass="cal_Theme1" TargetControlID="followUpDate"></cc1:CalendarExtender>
                                                <asp:RangeValidator ID="RangeValidator3" runat="server" ControlToValidate="followUpDate"
                                                    MaximumValue="12/31/2100" MinimumValue="01/01/1900" Type="Date"
                                                    ErrorMessage="* Invalid date" ValidationGroup="country" CssClass="errormsg"
                                                    SetFocusOnError="true" Display="Dynamic"> </asp:RangeValidator>
                                            </div>
                                        </div>
                                    </fieldset>
                                </div>
                                <!-- fieldset second start -->
                                <div class="panel-body">
                                    <fieldset>
                                        <legend>Document</legend>
                                        <div class="form-group form-inline">
                                            <label class="col-md-3 control-label">
                                                Document :
                                            </label>
                                            <div class="col-md-8">
                                                <input id="fileUpload" runat="server" name="fileUpload" type="file" class="file-upload" />
                                                <asp:Button ID="btnDeleteFile" runat="server" Text="Delete Selected" CssClass="btn btn-primary m-t-25" OnClick="btnDeleteFile_Click" />
                                            </div>
                                        </div>
                                        <div class=" form-group form-inline">
                                            <label class="col-md-3 control-label">
                                                File Description :
                                            </label>
                                            <div class="col-md-8">
                                                <asp:TextBox ID="fileDescription" runat="server" CssClass="form-control"></asp:TextBox>
                                                <asp:Button ID="btnUpload" runat="server" Text="Upload" CssClass="btn btn-primary m-t-25" OnClick="btnUpload_Click" />
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <div class="col-md-8 col-md-offset-3">

                                                <asp:Label ID="lblMsg" Font-Bold="true" ForeColor="Red" runat="server" Text=""></asp:Label>
                                                <div class="table-responsive">
                                                    <asp:Table ID="tblResult" runat="server" CssClass="table table-bordered table-striped"></asp:Table>
                                                </div>
                                            </div>
                                        </div>
                                    </fieldset>
                                </div>
                                <div class="panel-body">
                                    <legend></legend>
                                    <div class="form-group">
                                        <div class="col-md-6 col-md-offset-3">
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
    </form>
</body>
</html>

<%-- <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td width="100%">
                    <asp:Panel ID="pnl1" runat="server">
                        <table width="100%">
                            <tr>
                                <td height="26" class="bredCrom">
                                    <div>Credit Risk Management » Credit Security » Bank Guarantee » Manage </div>
                                </td>
                            </tr>
                            <tr>
                                <td height="20" class="welcome"><span id="spnCname" runat="server"><%=GetAgentName()%></span></td>
                            </tr>
                            <tr>
                                <td height="10" width="100%">
                                    <div class="tabs">
                                        <ul>
                                            <li><a href="../ListAgent.aspx">List</a></li>
                                            <li><a href="List.aspx?agentId=<%=GetAgentId()%>">Bank Guarantee</a></li>
                                            <li><a href="../Mortgage/List.aspx?agentId=<%=GetAgentId()%>">Mortgage</a></li>
                                            <li><a href="../CashSecurity/List.aspx?agentId=<%=GetAgentId()%>">Cash Security</a></li>
                                            <li><a href="../FixedDeposit/List.aspx?agentId=<%=GetAgentId()%>">Fixed Deposit</a></li>
                                            <li><a href="Javascript:void(0)" class="selected">Manage</a></li>
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
                    <table border="0" cellspacing="0" cellpadding="0" class="formTable" align="left">
                        <tr>
                            <th colspan="2" class="frmTitle">Bank Guarantee Details</th>
                        </tr>
                        <tr>
                            <td colspan="2" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                        </tr>
                        <tr>
                            <td>--%>
<%--  <fieldset>
                                    <legend>Bank Guarantee Details</legend>
                                    <table>
                                        <tr>
                                            <td>Guarantee No.
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="guaranteeNo" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                                <br />
                                                <asp:TextBox ID="guaranteeNo" runat="server" CssClass="input" Width="150px"></asp:TextBox>
                                            </td>--%>

<%--   <td>Amount of Guarantee<br />
                                                <asp:TextBox ID="amount" runat="server" CssClass="input" Width="150px"></asp:TextBox>
                                            </td>

                                            <td>Currency
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                                <br />
                                                <asp:DropDownList ID="currency" runat="server" Width="135px"></asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>--%>
<%--  <td valign="top">Bank Name<br />
                                                <asp:TextBox ID="bankName" runat="server" CssClass="input" Width="200px"></asp:TextBox>
                                            </td>
                                            <td>Issued Date
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="issuedDate" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                                <br />
                                                <asp:TextBox ID="issuedDate" runat="server" CssClass="input" Width="100px"></asp:TextBox>
                                                <cc1:CalendarExtender ID="CalendarExtender1" runat="server" CssClass="cal_Theme1"
                                                    TargetControlID="issuedDate">
                                                </cc1:CalendarExtender>
                                                <asp:RangeValidator ID="RangeValidator1" runat="server"
                                                    ControlToValidate="issuedDate"
                                                    MaximumValue="12/31/2100"
                                                    MinimumValue="01/01/1900"
                                                    Type="Date"
                                                    ErrorMessage="* Invalid date"
                                                    ValidationGroup="country"
                                                    CssClass="errormsg"
                                                    SetFocusOnError="true"
                                                    Display="Dynamic"> </asp:RangeValidator>
                                            </td>--%>
<%--  <td valign="top">Expiry Date
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="expiryDate" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
            <br />
            <asp:TextBox ID="expiryDate" runat="server" CssClass="input" Width="100px"></asp:TextBox>
            <cc1:CalendarExtender ID="ce1" runat="server" CssClass="cal_Theme1" TargetControlID="expiryDate"></cc1:CalendarExtender>
            <asp:RangeValidator ID="RangeValidator2" runat="server"
                ControlToValidate="expiryDate"
                MaximumValue="12/31/2100"
                MinimumValue="01/01/1900"
                Type="Date"
                ErrorMessage="* Invalid date"
                ValidationGroup="country"
                CssClass="errormsg"
                SetFocusOnError="true"
                Display="Dynamic"> </asp:RangeValidator>
        </td>--%>

<%--  <td valign="top">Follow Up Date
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="followUpDate" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
            <br />
            <asp:TextBox ID="followUpDate" runat="server" CssClass="input" Width="100px"></asp:TextBox>
            <cc1:CalendarExtender ID="CalendarExtender2" runat="server" CssClass="cal_Theme1" TargetControlID="followUpDate"></cc1:CalendarExtender>
            <asp:RangeValidator ID="RangeValidator3" runat="server"
                ControlToValidate="followUpDate"
                MaximumValue="12/31/2100"
                MinimumValue="01/01/1900"
                Type="Date"
                ErrorMessage="* Invalid date"
                ValidationGroup="country"
                CssClass="errormsg"
                SetFocusOnError="true"
                Display="Dynamic"> </asp:RangeValidator>
        </td>
        </tr>
                                    </table>--%>
<%--       </fieldset>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <fieldset>
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
                                </fieldset>
                            </td>
                        </tr>
        <tr>
            <td>
                <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country"
                    CssClass="button" TabIndex="5" OnClick="btnSave_Click" />
                <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                    ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                </cc1:ConfirmButtonExtender>
                &nbsp;
                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="button"
                                TabIndex="6" OnClick="btnDelete_Click" />
                <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
                    ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                </cc1:ConfirmButtonExtender>
                &nbsp;
                            <input id="btnBack" type="button" value="Back" class="button" onclick=" Javascript: history.back(); " />
            </td>
        </tr>
        </table>
                </td>
            </tr>
        </table>--%>