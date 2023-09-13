<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.Functions.TransactionTypeLimit.Manage" %>

<%@ Import Namespace="Swift.web.Library" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../../../css/swift_component.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td height="26" class="bredCrom">
                    <div>Administration » Agent Function » Transaction Type Limit » Manage </div>
                </td>
            </tr>
            <tr>
                <td class="welcome"><%=GetAgentPageTab()%></td>
            </tr>
            <tr>
                <td height="10">
                    <div class="tabs">
                        <ul>
                            <li><a href="../ListAgent.aspx">Agent List </a></li>
                            <li><a href="../BusinessFunction.aspx?agentId=<% Response.Write(GetAgent());%>&aType=<% Response.Write(GetAgentType());%>">Business Function</a></li>
                            <li><a href="List.aspx?agentId=<% Response.Write(GetAgent());%>&aType=<% Response.Write(GetAgentType());%>">Transaction Type Limit</a></li>
                            <li id="depositBankListTab" runat="server"></li>
                            <li id="sendingListTab" runat="server"></li>
                            <li id="receivingListTab" runat="server"></li>
                            <li><a href="../RegionalBranchAccessSetup.aspx?agentId=<% Response.Write(GetAgent());%>&aType=<% Response.Write(GetAgentType());%>">Regional Access Setup</a></li>
                            <li><a href="#" class="selected">Manage</a></li>
                        </ul>
                    </div>
                </td>
            </tr>
            <tr>
                <td height="524" valign="top">

                    <table border="0" cellspacing="0" cellpadding="0" class="formTable" align="left">
                        <tr>
                            <th colspan="2" class="frmTitle">Transaction Type Details</th>
                        </tr>
                        <tr>
                            <td></td>
                            <td>
                                <asp:Label ID="lblMsg" Font-Bold="true" runat="server" Text=""></asp:Label></td>
                        </tr>
                        <tr>
                            <td class="frmLable" nowrap="nowrap">Service Type:</td>
                            <td nowrap="nowrap">
                                <asp:DropDownList ID="serviceType" runat="server" CssClass="input" TabIndex="1"></asp:DropDownList>
                                <span class="errormsg">*</span><asp:RequiredFieldValidator
                                    ID="RequiredFieldValidator1" runat="server" ControlToValidate="serviceType" ForeColor="Red"
                                    Display="Dynamic" ErrorMessage="Required!" SetFocusOnError="True" ValidationGroup="servicetype">
                                </asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td class="frmLable" nowrap="nowrap">Transaction Limit Min:</td>
                            <td nowrap="nowrap">
                                <asp:TextBox ID="tranLimitMin" runat="server" Width="200px" CssClass="input" TabIndex="3"></asp:TextBox>
                                <span class="errormsg">*</span><asp:RequiredFieldValidator
                                    ID="RequiredFieldValidator2" runat="server" ControlToValidate="tranLimitMin" ForeColor="Red"
                                    Display="Dynamic" ErrorMessage="Required!" SetFocusOnError="True" ValidationGroup="servicetype">
                                </asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td class="frmLable" nowrap="nowrap">Transaction Limit Max:</td>
                            <td nowrap="nowrap">
                                <asp:TextBox ID="tranLimitMax" runat="server" Width="200px" CssClass="input" TabIndex="2">
                                </asp:TextBox>
                                <span class="errormsg">*</span><asp:RequiredFieldValidator
                                    ID="RequiredFieldValidator14" runat="server" ControlToValidate="tranLimitMax" ForeColor="Red"
                                    Display="Dynamic" ErrorMessage="Required!" SetFocusOnError="True" ValidationGroup="servicetype">
                                </asp:RequiredFieldValidator>
                            </td>
                        </tr>

                        <tr>
                            <td class="frmLable" nowrap="nowrap">isDefaultDepositMode: </td>
                            <td nowrap="nowrap">
                                <asp:DropDownList ID="isDefaultDepositMode" runat="server" CssClass="input" TabIndex="4">
                                    <asp:ListItem Value="Y">Yes</asp:ListItem>
                                    <asp:ListItem Value="N">No</asp:ListItem>
                                </asp:DropDownList>
                                <span class="errormsg">*</span><asp:RequiredFieldValidator
                                    ID="RequiredFieldValidator3" runat="server" ControlToValidate="isDefaultDepositMode" ForeColor="Red"
                                    Display="Dynamic" ErrorMessage="Required!" SetFocusOnError="True" ValidationGroup="servicetype">
                                </asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td>
                                <asp:Button ID="bntSubmit" runat="server" Text="Submit" CssClass="button" ValidationGroup="servicetype" TabIndex="5" OnClick="bntSubmit_Click" />
                                <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender2" runat="server"
                                    ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="bntSubmit">
                                </cc1:ConfirmButtonExtender>
                                &nbsp;
                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="button" TabIndex="6" OnClick="btnDelete_Click" />
                                <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
                                    ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                </cc1:ConfirmButtonExtender>
                                &nbsp;
                            <% Misc.SwiftBackButton();%>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </form>
</body>
<html>