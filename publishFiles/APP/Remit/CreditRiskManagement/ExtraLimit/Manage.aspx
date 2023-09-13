<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.ExtraLimit.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        function CallBack(mes) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] != 0) {
                return;
            }

            window.returnValue = resultList[2];
            window.close();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:ScriptManager ID="SM" runat="server"></asp:ScriptManager>
            <asp:HiddenField ID="hdnAgentId" runat="server" />
            <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
                <tr>
                    <td width="100%">
                        <asp:Panel ID="pnl1" runat="server">
                            <table width="100%">

                                <tr>
                                    <td height="26" class="bredCrom">
                                        <div>Credit Risk Management » Balance Top Up » Add Extra Limit </div>
                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                    </td>
                </tr>
                <tr>
                    <td valign="top" style="margin-left: 20px;">
                        <table border="0" cellspacing="0" cellpadding="0" class="formTable" align="left">
                            <tr>
                                <th colspan="3" class="frmTitle">Add Extra Limit</th>
                            </tr>
                            <tr>
                                <td colspan="3" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                            </tr>
                            <tr>
                                <td colspan="3">
                                    <fieldset>
                                        <table>
                                            <tr>
                                                <td class="frmLable">Agent Name</td>
                                                <td colspan="3">
                                                    <asp:Label ID="Label1" runat="server"><%=GetAgentName()%></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="frmLable">Currency</td>
                                                <td colspan="3">
                                                    <asp:Label ID="currency" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="frmLable">Max Limit</td>
                                                <td>
                                                    <asp:Label ID="maxLimitAmt" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td class="frmLable">Todays Added Extra Limit</td>
                                                <td nowrap="nowrap">
                                                    <asp:TextBox ID="todaysAddedMaxLimit" runat="server" Width="130px"></asp:TextBox>&nbsp;<span class="ErrMsg">*</span>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="todaysAddedMaxLimit" ForeColor="Red"
                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td colspan="3" nowrap="nowrap">
                                                    <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country"
                                                        CssClass="button" OnClick="btnSave_Click" />
                                                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                        ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                    </cc1:ConfirmButtonExtender>
                                                    &nbsp;

                                            <asp:Button ID="Button1" runat="server" CssClass="button"
                                                Text=" View History " OnClientClick="return showHistory();" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4">
                                                    <div id="rptPendingList" runat="server"></div>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <div id="rpt_grid" runat="server" class="gridDiv"></div>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>

<script language="javascript" type="text/javascript">
       function showHistory() {
               var agentId = GetValue("<% =hdnAgentId.ClientID%>");
               var url = "History.aspx?agentId=" + agentId;

               OpenInNewWindow(url);
               return false;
           }
</script>