<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CopySetup.aspx.cs" Inherits="Swift.web.Remit.ServiceCharge.Special.CopySetup" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register assembly="AjaxControlToolkit" namespace="AjaxControlToolkit" tagprefix="cc1" %>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head id="Head1" runat="server">
        <title></title>
        <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
        <script src="../../../js/functions.js" type="text/javascript"> </script>
        <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
        <script type="text/javascript">
            function CallBack(mes) {
                var resultList = ParseMessageToArray(mes);
                alert(resultList[1]);

                if (resultList[0] != 0) {
                    return;
                }

                window.returnValue = resultList[0];
                window.close();
            }

            function CheckAmt() {
                GetElement("<%=btnOnBlur.ClientID%>").click();
            }
    </script>
    </head>
    <body>
        <form id="form1" runat="server">
            <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true">
            </asp:ScriptManager>
            <asp:UpdatePanel ID="upnl1" runat="server">
                <ContentTemplate>
                    <div>
                        <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
                            <tr>
                                <td height="10" class="shadowBG"></td>
                            </tr>
                            <tr>
                                <td valign="top">
   
                                    <table border="0" cellspacing="0" cellpadding="0" class="formTable" align="left">
                                        <tr>
                                            <td ></td>
                                            <td>
                                                <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""> </asp:Label>
                                            </td>
                                        </tr>
                                        <tr >
                                            <td class="frmLable" nowrap="nowrap">Amount From:</td>
                                            <td>
                                                <asp:TextBox ID="fromAmt" runat="server" CssClass="input"></asp:TextBox>
                                                <span class="errormsg">*</span><asp:RequiredFieldValidator ID="RequiredFieldValidator1" 
                                                                                                           runat="server" ControlToValidate="fromAmt" ValidationGroup="admin" Display="Dynamic"  ErrorMessage="Required!" ForeColor="Red">
                                                                               </asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="frmLable" nowrap="nowrap">Amount To:</td>
                                            <td>
                                                <asp:TextBox ID="toAmt" runat="server" CssClass="input"></asp:TextBox>
                                                <span class="errormsg">*</span><asp:RequiredFieldValidator ID="RequiredFieldValidator2" 
                                                                                                           runat="server" ControlToValidate="toAmt" ValidationGroup="admin" Display="Dynamic"  ErrorMessage="Required!" ForeColor="Red">
                                                                               </asp:RequiredFieldValidator>
                                            </td>   
                                        </tr>
                                        <tr>
                                            <td class="frmLable" nowrap="nowrap">Percent:</td>
                                            <td>
                                                <asp:TextBox ID="pcnt" runat="server" CssClass="input" 
                                                             ToolTip="Enter 0 for Flat"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="frmLable" nowrap="nowrap">Min Amount:</td>
                                            <td >
                                                <asp:TextBox ID="minAmt" runat="server" CssClass="input"></asp:TextBox>
                                            </td>       
                                        </tr>
                                        <tr>
                                            <td class="frmLable" nowrap="nowrap">Max Amount:</td>
                                            <td>
                                                <asp:TextBox ID="maxAmt" runat="server" CssClass="input"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>&nbsp;</td>
                                            <td>
                                                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="button" 
                                                            ValidationGroup="admin" Display="Dynamic"  TabIndex="18" 
                                                            onclick="btnSave_Click" />
                                                <cc1:ConfirmButtonExtender ID="btnSavecc" runat="server" 
                                                                           ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                </cc1:ConfirmButtonExtender>  &nbsp; 
                                                <asp:Button ID="btnOnBlur" runat="server" style = "display: none;" onclick="btnOnBlur_Click"  />

                                                <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="button" 
                                                            Display="Dynamic"  TabIndex="19" 
                                                            onclick="btnDelete_Click" />
                                                <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" 
                                                                           ConfirmText="Confirm To Delete ?" Enabled="True" TargetControlID="btnDelete">
                                                </cc1:ConfirmButtonExtender>  &nbsp; 


                                            </td>
                                        </tr>
                                    </table>
                                </td></tr>
                        </table>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </form>
    </body>
</html>