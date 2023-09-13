<%@ Page Language="C#" ValidateRequest="false" AutoEventWireup="true"  CodeBehind="ManageMessage3.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.MessageSetting.ManageMessage3" %>
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <head id="Head1" runat="server">
    <script src="scripts/wysiwyg.js" type="text/javascript"> </script>
    <script src="scripts/wysiwyg-settings.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
        <script src="../../../js/swift_grid.js" type="text/javascript"> </script>

    <script type="text/javascript">
        WYSIWYG.attach("<%=textarea1.ClientID%>", full);
    </script>
</head>

<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td width="100%"> 
                <asp:Panel ID="pnl1" runat="server">
                    <table width="100%">
                        <tr>
                            <td height="26" class="bredCrom"> <div > General Settings » Receipt Message Setting » Promotional Message » Manage </div> </td>
                        </tr>
                        <tr>
                            <td height="10" width="100%"> 
                                <div class="tabs" > 
                                    <ul> 
                                        <li> <a href="ListMessage2.aspx"> Country Specific </a></li>
                                        <li> <a href="ListMessage3.aspx" class="selected"> Promotional  </a></li>
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
            <td>
                <div class="tabs" width="100%" > 
                    <ul> 
                    </ul> 
                </div>
            </td>
        </tr>
        <tr>
            <td height="524" valign="top" >       
                <table border="0" cellspacing="0" cellpadding="0" class="formTable" align="left" style="width: 850px;">
                    <tr>
                        <th colspan="2" class="frmTitle">Message Details</th>
                    </tr>
                    <tr>
                        <td colspan="2" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                    </tr>
                    <tr>
                        <td>
                            <fieldset>
                                <legend>Promotional Message[Agent Wise]</legend>
                                <table>
                                    <tr>
                                        <td class="frmLable">Message Type:</td>
                                        <td>
                                            <asp:DropDownList ID="msgType" runat="server" CssClass="input" 
                                                onselectedindexchanged="msgType_SelectedIndexChanged" AutoPostBack="True">
                                                <asp:ListItem Value="">All</asp:ListItem>
                                                <asp:ListItem Value="S">Send</asp:ListItem>
                                                <asp:ListItem Value="R">Receive</asp:ListItem>
                                                <asp:ListItem Value="B">Both</asp:ListItem>
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Agent:</td>
                                        <td>
                                            <asp:DropDownList ID="agent" runat="server" CssClass="input"></asp:DropDownList>
                                            
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Country:</td>
                                        <td>
                                            <asp:DropDownList ID="country" runat="server" CssClass="input"></asp:DropDownList>
                                            <span class="ErrMsg">*</span>
                                             <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="country" ForeColor="Red" 
                                                                    ValidationGroup="count" Display="Dynamic"   ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                     <tr>
                                        <td class="frmLable">Transaction:</td>
                                        <td>
                                            <asp:DropDownList ID="trasactionType" runat="server" CssClass="input"></asp:DropDownList>
                                               
                                             
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Is Active:</td>
                                        <td>
                                            <asp:DropDownList ID="ddlIsActive" runat="server" CssClass="input">
                                                <asp:ListItem Value="Active">Active</asp:ListItem>
                                                <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
                                            </asp:DropDownList>                                                    
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Message</td>
                                        <td>
                                            <textarea id="textarea1" name="textarea1" runat="server" style="width: 600px; height: 200px;">
                                            </textarea>    
                                        </td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td><asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="static" 
                                                        CssClass="button" TabIndex="5" onclick="btnSave_Click" />
                                            <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" 
                                                                       ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                            </cc1:ConfirmButtonExtender>&nbsp;
                                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="button" TabIndex="6" />
                                            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" 
                                                                       ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                            </cc1:ConfirmButtonExtender> &nbsp; 
                                            <input id="btnBack" type="button" value="Back" class="button" onclick=" Javascript:history.back(); " />
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