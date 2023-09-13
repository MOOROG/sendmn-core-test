<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Swift.Master" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.CreditSecurity.CashSecurity.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainPlaceHolder" runat="server">
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
                <li role="presentation"><a href="../ListAgent.aspx" aria-controls="home" role="tab" data-toggle="tab">List Agent</a></li>
                <li role="presentation"><a href="../BankGuarantee/List.aspx?agentId=<%=GetAgentId()%>" aria-controls="home" role="tab" data-toggle="tab">Bank Guarantee</a></li>
                <li role="presentation"><a href="../Mortgage/List.aspx?agentId=<%=GetAgentId()%>" aria-controls="home" role="tab" data-toggle="tab">Mortgage</a></li>
                <li role="presentation"><a href="List.aspx?agentId=<%=GetAgentId()%>" aria-controls="home" role="tab" data-toggle="tab">Cash Security</a></li>
                <li role="presentation"><a href="../FixedDeposit/List.aspx?agentId=<%=GetAgentId()%>" aria-controls="home" role="tab" data-toggle="tab">Fixed Deposit</a></li>
                <li role="presentation" class="active"><a href="#" class="selected" aria-controls="home" role="tab" data-toggle="tab">Manage</a></li>
            </ul>
        </div>
        <div class="tab-content">
            <div role="tabpanel" class="tab-pane active" id="list">
                <div class="row">
                    <div class="col-md-6">
                        <div class="panel panel-default ">
                            <div class="panel-heading">
                                <h4 class="panel-title">Cash Security</h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>

                            <div class="panel-body">
                                <div class="form-group">
                                    <label class="col-md-4 control-label">
                                        Bank Name :
                                    </label>
                                    <div class="col-md-8">
                                        <asp:TextBox ID="bankName" runat="server" CssClass="form-control"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="bankName" ForeColor="Red"
                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                        </asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-4 control-label">
                                        Deposit A/C No :
                                    </label>
                                    <div class="col-md-8">
                                        <asp:TextBox ID="depositAcNo" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-4 control-label">
                                        Cash Deposit :
                                    </label>
                                    <div class="col-md-8">
                                        <asp:TextBox ID="cashDeposit" runat="server" CssClass="form-control"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="cashDeposit" ForeColor="Red"
                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                        </asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-4 control-label">
                                        Currency  :
                                    </label>
                                    <div class="col-md-8">
                                        <asp:DropDownList ID="currency" runat="server" CssClass="form-control"></asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                        </asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-md-4 control-label">
                                        Date :
                                    </label>
                                    <div class="col-md-8">
                                        <asp:TextBox ID="depositedDate" runat="server" CssClass="form-control"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="depositedDate" ForeColor="Red"
                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                        </asp:RequiredFieldValidator>
                                        <cc1:CalendarExtender ID="ce1" runat="server" CssClass="cal_Theme1" TargetControlID="depositedDate"></cc1:CalendarExtender>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-md-6 col-md-offset-4">
                                        <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country"
                                            CssClass="btn btn-primary m-t-25" TabIndex="5" OnClick="btnSave_Click" />
                                        <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                            ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                        </cc1:ConfirmButtonExtender>
                                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-primary m-t-25"
                                            TabIndex="6" OnClick="btnDelete_Click" />
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

    <%--   <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td width="100%">
                <asp:Panel ID="pnl1" runat="server">
                    <table width="100%">
                        <tr>
                            <td height="26" class="bredCrom">
                                <div>Credit Risk Management » Credit Security » Cash Security » Manage </div>
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
                                        <li><a href="../BankGuarantee/List.aspx?agentId=<%=GetAgentId()%>">Bank Guarantee</a></li>
                                        <li><a href="../Mortgage/List.aspx?agentId=<%=GetAgentId()%>">Mortgage</a></li>
                                        <li><a href="List.aspx?agentId=<%=GetAgentId()%>">Cash Security</a></li>
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
        <tr>--%>
    <%-- <td height="524" valign="top">
                <table border="0" cellspacing="0" cellpadding="0" class="formTable" align="left">
                    <tr>
                        <th colspan="2" class="frmTitle">Cash Security</th>
                    </tr>
                    <tr>
                        <td colspan="2" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                    </tr>
                    <tr>
                        <td>
                            <fieldset>
                                <table>
                                    <tr>
                                        <td class="frmLable">Bank Name</td>
                                        <td>
                                            <asp:TextBox ID="bankName" runat="server" CssClass="input"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="bankName" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>--%>
    <%--<td class="frmLable">Deposit A/C No</td>
                                        <td>
                                            <asp:TextBox ID="depositAcNo" runat="server" CssClass="input"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Cash Deposit</td>
                                        <td>
                                            <asp:TextBox ID="cashDeposit" runat="server" CssClass="input"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="cashDeposit" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>--%>
    <%--    <td class="frmLable">Currency</td>
                                        <td>
                                            <asp:DropDownList ID="currency" runat="server" Width="135px"></asp:DropDownList>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>--%>
    <%--  <td class="frmLable">Date</td>
                                        <td>
                                            <asp:TextBox ID="depositedDate" runat="server" CssClass="input"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="depositedDate" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                            <cc1:CalendarExtender ID="ce1" runat="server" CssClass="cal_Theme1" TargetControlID="depositedDate"></cc1:CalendarExtender>
                                        </td>
                                    </tr>
                                    <tr>--%>
    <%--          <td></td>
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
                            </fieldset>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>--%>
</asp:Content>