<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.Functions.SendingCountry.ManageSendingList" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>

        <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td height="26" class="bredCrom">
                    <div>Administration » Agent Function » Manage Sending Country </div>
                </td>
            </tr>
            <tr>
                <td class="welcome"><%=GetAgentPageTab()%></td>
            </tr>
            <%--<tr>
            <td height="10">
                <div class="tabs">
                    <ul>
                        <li> <a href="../list.aspx" >Country List </a></li>
                        <li> <a href="#" class="selected"> Manage Country </a></li>
                    </ul>
                </div>
            </td>
        </tr>--%>
            <tr>
                <td width="100%">
                    <asp:Panel ID="pnl1" runat="server">
                        <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
                            <tr>
                                <td width="100%">
                                    <div class="tabs">
                                        <ul>
                                            <li id="businessFunctionTab" runat="server"></li>
                                            <li id="depositBankListTab" runat="server"></li>
                                            <%--<li id="SendingList" runat="server"></li>
                                        <li id="receivingListTab" runat="server"></li>--%>
                                            <li id="RegionalBranchAccessSetup" runat="server"></li>
                                            <li id="AgentGroupMaping" runat="server"></li>
                                            <li id="SendingCountryList" runat="server"></li>
                                            <li id="ReceivingCountryList" runat="server"></li>
                                            <li><a href="#" class="selected">Manage Sending Country </a></li>
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
                    <table border="0" cellspacing="0" cellpadding="0" class="formTable" style="margin-left: 50px;">
                        <tr>
                            <th colspan="2" class="frmTitle">Sending Agent Country&nbsp; Setup</th>
                        </tr>
                        <tr>
                            <td colspan="2" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                        </tr>
                        <tr>
                            <td></td>
                            <td>
                                <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label></td>
                        </tr>
                        <tr>
                            <td class="frmLable">Sending Country:</td>
                            <td>
                                <asp:DropDownList ID="sendingCountry" runat="server" Width="200" AutoPostBack="true"
                                    OnSelectedIndexChanged="sendingCountry_SelectedIndexChanged">
                                </asp:DropDownList>&nbsp;<span class="errormsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="sendingCountry" ForeColor="Red"
                                    ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>
                            <td class="frmLable">Sending Agent:</td>
                            <td>
                                <asp:DropDownList ID="sendingAgent" runat="server" Width="200">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td class="frmLable">Tran Type:</td>
                            <td>
                                <asp:DropDownList ID="tranType" runat="server" Width="200">
                                </asp:DropDownList>
                            </td>
                        </tr>

                        <tr>
                            <td></td>
                            <td nowrap="nowrap">
                                <asp:Button ID="btnSumit" runat="server" Text="Submit" CssClass="button"
                                    Display="Dynamic" TabIndex="16" OnClick="btnSumit_Click" ValidationGroup="country" />
                                <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                    ConfirmText="Confirm To Save ?" Enabled="True"
                                    TargetControlID="btnSumit">
                                </cc1:ConfirmButtonExtender>

                                <input id="btnBack" type="button" class="button" value="Back" onclick=" Javascript:history.back(); " />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>