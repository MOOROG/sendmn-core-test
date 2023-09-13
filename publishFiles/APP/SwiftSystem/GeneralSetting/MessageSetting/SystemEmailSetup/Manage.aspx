<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.MessageSetting.SystemEmailSetup.Manage" %>

<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <head id="Head1" runat="server">
        <base id="Base1" target = "_self" runat = "server" />
        <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
        <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
        <script src="../../../../js/functions.js" type="text/javascript"> </script>
     </head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <asp:HiddenField ID="hdnBranchId" runat="server" />
    <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td align="left" valign="top" class="bredCrom">General Settings » Message Setting » System Email Setup » Manage </td>
        </tr>
        <tr>
            <td height="10" class="shadowBG"></td>
        </tr>
        <div id="agentNameDiv" runat="server" visible="false">
        <tr>
            <td  class="welcome">&nbsp;&nbsp;&nbsp;&nbsp;<img src="/Images/agents.png"/><asp:Label ID="lblAgentName" runat="server"></asp:Label> </td>
        </tr>
        </div>
        <tr>
            <td height="10"> 
                <div class="tabs" > 
                    <ul> 
                        <li> <a href="List.aspx" >List </a></li>
                        <li> <a href="Manage.aspx" class="selected"> Manage </a></li>
			
                    </ul> 
                </div> 
            </td>
        </tr>
        <tr>
            <td height="524" valign="top">
                <table border="0" cellspacing="0" cellpadding="0" class="formTable" style="margin-left: 50px;" >
                    <tr>
                        <th colspan="2" class="frmTitle">System Email Setup</th>
                    </tr>
                    <tr>
                        <td colspan="2" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                    </tr>
                    <tr>
                        <td></td>
                        <td><asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label></td>
                    </tr>

                    
                   <tr>
                        <td class="frmLable">Name:</td>
                        <td>                                   
                                <asp:TextBox ID="name" runat="server" Width="250px"></asp:TextBox>
                                <span class="ErrMsg">*</span>
                                 <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="name" ForeColor="Red" 
                                                        ValidationGroup="bank" Display="Dynamic"   ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                          
                        </td>
                    </tr>
                    <tr>
                        <td class="frmLable">Email:</td>
                        <td>                                   
                                <asp:TextBox ID="email" runat="server" Width="250px"></asp:TextBox>
                                <span class="ErrMsg">*</span>
                                 <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="email" ForeColor="Red" 
                                                        ValidationGroup="bank" Display="Dynamic"   ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                          
                        </td>
                    </tr>
                    <tr>
                        <td class="frmLable">Mobile:</td>
                        <td>                                   
                                <asp:TextBox ID="mobile" runat="server" Width="135px"></asp:TextBox>
                                <span class="ErrMsg">*</span>
                                 <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ControlToValidate="mobile" ForeColor="Red" 
                                                        ValidationGroup="bank" Display="Dynamic"   ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                          
                        </td>
                    </tr>
                    <tr>
                        <td class="frmLable">Country:</td>
                        <td>
                            <asp:DropDownList ID="country" runat="server" Width="255px">                    
                            </asp:DropDownList>
                            <span class="ErrMsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="country" ForeColor="Red" 
                                                    ValidationGroup="bank" Display="Dynamic"   ErrorMessage="Required!">
                            </asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td class="frmLable">Agent:</td>
                        <td>                                   
                            <asp:DropDownList ID="agent" runat="server" Width="255px">                    
                            </asp:DropDownList>
                            <span class="ErrMsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="agent" ForeColor="Red" 
                                                    ValidationGroup="bank" Display="Dynamic"   ErrorMessage="Required!">
                            </asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                         <td class="frmLable">Notify Type:</td>
                         <td nowrap="nowrap">
                                <asp:CheckBox ID="cancel" runat="server" Text="Cancel Process"></asp:CheckBox> &nbsp; &nbsp; 
                                 <asp:CheckBox ID="trouble" runat="server" Text="Trouble/Modification"></asp:CheckBox>   &nbsp; &nbsp; 
                                 <asp:CheckBox ID="account" runat="server" Text="Account"></asp:CheckBox>  &nbsp; &nbsp; 
                                 <asp:CheckBox ID="xRate" runat="server" Text="XRate"></asp:CheckBox>  &nbsp; &nbsp; 
                                 <asp:CheckBox ID="summary" runat="server" Text="Summary"></asp:CheckBox>  &nbsp; &nbsp; 
                                 <asp:CheckBox ID="Bonus" runat="server" Text="Bonus Request"></asp:CheckBox>  &nbsp; &nbsp; 
                                 <asp:CheckBox ID="eodCash" runat="server" Text="EOD - Cash"></asp:CheckBox>  &nbsp; &nbsp;
                             <br/>
                                 <asp:CheckBox ID="bankGuaranteeExpiry" runat="server" Text="Bank Guarantee Expire"></asp:CheckBox>  &nbsp; &nbsp;
                         </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td nowrap="nowrap"> 
                            <asp:Button ID="btnSumit" runat="server" Text="Submit"  CssClass="button" 
                            ValidationGroup="bank" Display="Dynamic"  onclick="btnSumit_Click"  />
                            <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" 
                                                       ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSumit">
                            </cc1:ConfirmButtonExtender>   &nbsp;
                            
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