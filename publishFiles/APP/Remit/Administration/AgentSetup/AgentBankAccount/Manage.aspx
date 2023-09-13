<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.AgentBankAccount.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <style>
        .formTable {
            background-color: #f5f5f5 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sc" runat="server"></asp:ScriptManager>
        <asp:UpdatePanel ID="up" runat="server">
            <ContentTemplate>
                <div class="container">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="page-title">
                                <h1>Administration<small></small>
                                </h1>
                                <ol class="breadcrumb">
                                    <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li><a href="#">Agent Setup</a></li>
                                    <li class="active"><a href="#">Bank Account</a></li>
                                    <li class="active"><a href="#">Manage</a></li>
                                </ol>
                            </div>
                        </div>
                    </div>
                    <table class="table table-condensed">
                        <tr>
                            <td>
                                <asp:Panel ID="pnl2" runat="server">
                                    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">

                                        <tr>
                                            <td height="20" class="welcome"><span id="spnCname" runat="server"><%=GetAgentName()%></span></td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Panel ID="pnl1" runat="server">
                                    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td height="10">
                                                <div class="tabs">
                                                    <ul>
                                                        <li><a href="../Functions/ListAgent.aspx">Agent List </a></li>
                                                        <li><a href="#" class="selected">Edit Agent </a></li>
                                                    </ul>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                                <table class="table table-condensed">
                                    <tr>
                                        <td height="10">
                                            <div class="listtabs row">
                                                <ul class="nav nav-tabs" role="tablist">
                                                    <li><a href="../../../../SwiftSystem/UserManagement/AgentSetup/Manage.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Agent Information </a></li>
                                                    <li><a href="../AgentCurrency.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Allowed Currency </a></li>
                                                    <li><a href="../AgentBusinessHistory.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Business History </a></li>
                                                    <li><a href="../Document/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Owners</a></li>
                                                    <li><a href="../Document/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Required Document</a></li>
                                                    <li><a href="../AgentContactPerson/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Contact Person</a></li>
                                                    <li><a href="List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Bank Account</a></li>
                                                    <li class="active"><a href="#" class="selected">Manage</a></li>
                                                </ul>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <td height="524" valign="top">
                                            <div class="panel panel-default">
                                                <div class="panel-heading">
                                                    <h4>Bank Account Details</h4>
                                                </div>
                                                <div class="panel-body">
                                                    <table class="formTable table table-condensed">

                                                        <tr>
                                                            <td></td>
                                                            <td>
                                                                <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;</td>
                                                            <td><span class="welcome"><u>Intermediate Bank </u></span></td>
                                                            <td><span class="welcome"><u>Beneficiary Bank </u></span></td>
                                                        </tr>
                                                        <tr>
                                                            <td class="frmLable">Bank Name:<span class="errormsg">*</span></td>
                                                            <td nowrap="nowrap">
                                                                <asp:TextBox ID="bankName" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                <asp:RequiredFieldValidator ID="Rfd1" runat="server" ControlToValidate="bankName"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            </td>
                                                            <td nowrap="nowrap">
                                                                <asp:TextBox ID="bankNameB" runat="server" Width="270px" CssClass="input form-control"></asp:TextBox>
                                                                <asp:RequiredFieldValidator
                                                                    ID="RequiredFieldValidator1" runat="server"
                                                                    ControlToValidate="bankNameB"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="frmLable">Branch:<span class="errormsg">*</span></td>
                                                            <td nowrap="nowrap">
                                                                <asp:TextBox ID="bankBranch" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                <asp:RequiredFieldValidator ID="Rfd3" runat="server" ControlToValidate="bankBranch"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            </td>
                                                            <td nowrap="nowrap">
                                                                <asp:TextBox ID="bankBranchB" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="bankBranchB"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="frmLable">Account No.:<span class="errormsg">*</span></td>
                                                            <td nowrap="nowrap">
                                                                <asp:TextBox ID="accountNo" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                <asp:RequiredFieldValidator ID="Rfd6" runat="server" ControlToValidate="accountNo"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            </td>
                                                            <td nowrap="nowrap">
                                                                <asp:TextBox ID="accountNoB" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="accountNoB"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="frmLable">Account Name:<span class="errormsg">*</span></td>
                                                            <td nowrap="nowrap">
                                                                <asp:TextBox ID="accountName" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="accountName"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            </td>
                                                            <td nowrap="nowrap">
                                                                <asp:TextBox ID="accountNameB" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="accountNameB"
                                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="frmLable">Swift Code: </td>
                                                            <td nowrap="nowrap">
                                                                <asp:TextBox ID="swiftCode" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                <%--<span class="errormsg">*</span><asp:RequiredFieldValidator  ID="rfd10" runat="server" ControlToValidate="swiftCode"
                                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>  --%>
                                                            </td>
                                                            <td nowrap="nowrap">
                                                                <asp:TextBox ID="swiftCodeB" runat="server" CssClass="input form-control"></asp:TextBox>
                                                                <%--<span class="errormsg">*</span><asp:RequiredFieldValidator  ID="rfd10" runat="server" ControlToValidate="swiftCode"
                                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>  --%>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="frmLable" nowrap="nowrap">Routing No/CHIPS Id: </td>
                                                            <td nowrap="nowrap">
                                                                <asp:TextBox ID="routingNo" runat="server" CssClass="input form-control" TabIndex="17"></asp:TextBox>
                                                                <%-- <span class="errormsg">*</span><asp:RequiredFieldValidator  ID="rfd7" runat="server" ControlToValidate="routingNo"
                                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>--%>
                                                            </td>
                                                            <td nowrap="nowrap">
                                                                <asp:TextBox ID="routingNoB" runat="server" CssClass="input form-control" TabIndex="17"></asp:TextBox>
                                                                <%-- <span class="errormsg">*</span><asp:RequiredFieldValidator  ID="rfd7" runat="server" ControlToValidate="routingNo"
                                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>--%>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="frmLable" nowrap="nowrap">Is Default A/C: </td>
                                                            <td colspan="2">
                                                                <asp:DropDownList ID="isDefault" runat="server" CssClass="input form-control">
                                                                    <asp:ListItem Value="">Select</asp:ListItem>
                                                                    <asp:ListItem Value="Yes">Yes</asp:ListItem>
                                                                    <asp:ListItem Value="Yes">No</asp:ListItem>
                                                                </asp:DropDownList></td>
                                                        </tr>
                                                        <tr>
                                                            <td>&nbsp;</td>
                                                            <td colspan="5">
                                                                <asp:Button ID="bntSubmit" runat="server" Text="Submit" CssClass="bnt btn-primary" ValidationGroup="agent"
                                                                    TabIndex="48" OnClick="bntSubmit_Click" />
                                                                <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender2" runat="server"
                                                                    ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="bntSubmit">
                                                                </cc1:ConfirmButtonExtender>
                                                                &nbsp;<input id="btnBack" type="button" value="Back" class="bnt btn-primary" onclick=" Javascript: history.back(); ">
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>