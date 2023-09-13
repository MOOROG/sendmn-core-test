<%@ Page Language="C#" ValidateRequest="false"  AutoEventWireup="true" CodeBehind="txnMsgManage.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.MessageSetting.txnMsgManage" %>

<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="scripts/wysiwyg.js" type="text/javascript"> </script>
    <script src="scripts/wysiwyg-settings.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>

    <script type="text/javascript">
        WYSIWYG.attach("<%=country.ClientID%>", full);
        WYSIWYG.attach("<%=service.ClientID%>", full);
        WYSIWYG.attach("<%=codeDesc.ClientID%>", full);
        WYSIWYG.attach("<%=paymentMethodDesc.ClientID%>", full);
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>

            <table  border="0" align="left" cellpadding="0" cellspacing="0">
                <tr>
                    <td> 
                        <asp:Panel ID="pnl1" runat="server">
                            <table width="100%">
                                <tr>
                                    <td height="26" class="bredCrom"> <div > Application Setting » Transaction Message Setting » Manage  </div> </td>
                                </tr>
                                <tr>
                                    <td height="10" width="100%"> 
                                        <div class="tabs" > 
                                            <ul> 
                                                <li> <a href="txnMsgList.aspx">List</a></li>
                                                <li> <a href="Javascript:void(0)" class="selected">Manage</a></li>
                                            </ul> 
                                        </div>		
                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                    </td>
                </tr>
                <tr>
                    <td valign="top" >       
                        <table  border="0" cellspacing="0" cellpadding="0" class="formTable" align="left" style="width: 850px;">
                            <tr>
                                <th class="frmTitle" colspan="2">Transaction Message Setting</th>
                            </tr>
                            <tr>
                                <td>
                                <fieldset>
                                <legend>Transaction Message Setup</legend>
                                <table>
                                    <tr>
                                        <td nowrap="nowrap" valign="top">Country</td>
                                        <td><asp:TextBox ID="country" CssClass="unicodeFont" runat="server" TextMode="MultiLine" Width="350px" Height="50px"></asp:TextBox></td>                                                                                           
                                    </tr>
                                    <tr>
                                        <td nowrap="nowrap" valign="top">Service</td>
                                        <td><asp:TextBox ID="service" CssClass="unicodeFont" runat="server" TextMode="MultiLine" Width="350px" Height="50px"></asp:TextBox></td>     
                                    </tr>
                                    <tr>
                                        <td  nowrap="nowrap" valign="top">Code<br /> Description</td>
                                        <td><asp:TextBox ID="codeDesc" CssClass="unicodeFont" runat="server" TextMode="MultiLine" Width="350px" Height="50px"></asp:TextBox></td>     
                                    </tr>
                                    <tr>
                                        <td nowrap="nowrap" valign="top">Payment <br />Method Desc</td>
                                        <td><asp:TextBox ID="paymentMethodDesc" CssClass="unicodeFont" runat="server" TextMode="MultiLine" Width="350px" Height="50px"></asp:TextBox></td>     
                                    </tr>
                                    <tr>
                                        <td nowrap="nowrap">Messaage Type</td>
                                        <td><asp:DropDownList ID="messageType" runat="server">
                                            <asp:ListItem Value="Pay">Pay</asp:ListItem>
                                            <asp:ListItem Value="Send">Send</asp:ListItem>
                                            <asp:ListItem Value="Cancel">Cancel</asp:ListItem>
                                            </asp:DropDownList>
                                        </td>     
                                    </tr>
                                    <tr>
                                        <td  nowrap="nowrap">Is Active</td>
                                        <td><asp:DropDownList ID="isActive" runat="server">
                                            <asp:ListItem Value="Active">Active</asp:ListItem>
                                            <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
                                            </asp:DropDownList>
                                        </td>     
                                    </tr>
                                    <tr>
                                        <td>&nbsp;</td>
                                        <td>
                                                <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country" 
                                                    CssClass="button" onclick="btnSave_Click" />
                                                <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" 
                                                                    ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                </cc1:ConfirmButtonExtender>&nbsp; 
                                                <input id="btnBack" type="button" value="Back" class="button" onClick="Javascript:history.back(); " />
                                        </td>
                                    </tr>   
                                </table>
                                </fieldset>
                                </td>
                            </tr>                                                                                                                          
                                                   
                        </table>
                    </td>
                </tr>
            </table>

</form>
</body>
</html>