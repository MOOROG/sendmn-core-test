<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AgentCurrency.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.AgentCurrency" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script type="text/javascript">
        var gridName = "<% =GridName%>";

        function GridCallBack() {
            var id = GetRowId(gridName);

            if (id != "") {
                GetElement("<% =btnEdit.ClientID%>").click();
                GetElement("<% =btnSave.ClientID%>").disabled = false;
            } else {
                GetElement("<% =btnSave.ClientID%>").disabled = true;
                ResetForm();
                ClearAll(gridName);
            }
        }

        function ResetForm() {
            SetValueById("<% =currency.ClientID%>", "");
            SetValueById("<% =spFlag.ClientID%>", "");
        }

        function NewRecord() {
            ResetForm();
            GetElement("<% =btnSave.ClientID%>").disabled = false;
            SetValueById("<% =agentCurrencyId.ClientID%>", "0");
            ClearAll(gridName);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <div class="page-title">
                        <h1>Administration<small></small>
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Agent Setup</a></li>
                            <li class="active"><a href="#">Allowed Currency</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
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
                                        <div class="listtabs">
                                            <ul>
                                                <li><a href="Functions/ListAgent.aspx">Agent List </a></li>
                                                <li><a href="#" class="selected">Edit Agent </a></li>
                                            </ul>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                        <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0" style="clear: both">
                            <tr>
                                <td height="10">
                                    <div class="listtabs row">
                                        <ul class="nav nav-tabs" role="tablist">
                                            <li><a href="../../../SwiftSystem/UserManagement/AgentSetup/Manage.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Agent Information </a></li>
                                            <li class="active"><a href="Javascript:void(0)" class="selected">Allowed Currency </a></li>
                                            <li><a href="AgentBusinessHistory.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Business History </a></li>
                                            <li><a href="OwnerInf/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Owners</a></li>
                                            <li><a href="Document/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Required Document</a></li>
                                            <li><a href="AgentContactPerson/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Contact Person</a></li>
                                            <li><a href="AgentBankAccount/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Bank Account</a></li>
                                        </ul>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        <asp:UpdatePanel ID="upnl1" runat="server">
                            <ContentTemplate>
                                <div class="panel panel-default">
                                    <div class="panel-heading">Agent Currency Setup</div>
                                    <div class="panel-body">
                                        <table class="table table-condensed">

                                            <tr>
                                                <td></td>
                                                <td colspan="3">
                                                    <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label></td>
                                            </tr>
                                            <tr>
                                                <td align="left" nowrap="nowrap">Currency
                                    <span class="errormsg">*</span>
                                                    <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="currency"
                                                        ForeColor="Red" Display="Dynamic" ErrorMessage="Required" ValidationGroup="agent"
                                                        SetFocusOnError="True">
                                                    </asp:RequiredFieldValidator>
                                                    <br />
                                                    <asp:DropDownList ID="currency" runat="server" CssClass="input form-control"></asp:DropDownList>
                                                </td>
                                                <td align="left" nowrap="nowrap">Applies For
                                    <br />
                                                    <asp:DropDownList ID="spFlag" runat="server" CssClass="input form-control">
                                                        <asp:ListItem Value="B">Both</asp:ListItem>
                                                        <asp:ListItem Value="S">Send</asp:ListItem>
                                                        <asp:ListItem Value="P">Pay</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td align="left" nowrap="nowrap">Is Default
                                    <br />
                                                    <asp:DropDownList ID="isDefault" runat="server" CssClass="input form-control">
                                                        <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                        <asp:ListItem Value="N">No</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td nowrap="nowrap">
                                                    <br />
                                                    <input type="button" value="New" onclick=" NewRecord(); " class="btn btn-primary" />

                                                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="bnt btn-primary" ValidationGroup="agent"
                                                        OnClick="btnSave_Click" />
                                                    <asp:Button ID="btnEdit" runat="server" Text="Edit" CssClass="bnt btn-primary" Style="display: none;"
                                                        OnClick="btnEdit_Click" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4">
                                                    <div id="rpt_grid" runat="server" style="margin-left: -11px; overflow: scroll;"></div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td colspan="3" nowrap="nowrap">
                                                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                        ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                    </cc1:ConfirmButtonExtender>
                                                    &nbsp;
                                    <input id="btnBack" type="button" class="button" value="Back" onclick=" Javascript: history.back(); " />
                                                    <asp:HiddenField ID="agentCurrencyId" runat="server" />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </ContentTemplate>
                            <Triggers>
                            </Triggers>
                        </asp:UpdatePanel>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>