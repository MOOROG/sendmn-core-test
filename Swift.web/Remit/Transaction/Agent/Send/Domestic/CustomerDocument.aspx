<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerDocument.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.Send.Domestic.CustomerDocument" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
   <link href="../../../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../../../js/functions.js" type="text/javascript"></script>    
</head>
<body>
    <form id="form1" runat="server">
   <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
    <tr> 
            <td>
                 <fieldset>
                        <legend class="legendCss">Document</legend>
                        <table>
                            <tr>
                                <td class="frmLable">Document:</td>
                                <td>
                                    <input id="fileUpload" runat="server" name="fileUpload" type="file" size="20" class="input" />
                                </td>
                                <td class="frmLable">File Type:<span class="ErrMsg">*</span></td>
                                <td class="style1">
                                    <asp:DropDownList ID="docType" runat="server">                                 
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator  ID="rqdocType" runat="server" ControlToValidate="docType" 
                                            Display="Dynamic" ErrorMessage="Required!" ForeColor="Red"
                                            SetFocusOnError="True"></asp:RequiredFieldValidator>

                                  
                                </td>
                            </tr>                                    
                            <tr>
                                <td class="frmLable">&nbsp;</td>
                                <td>
                                     &nbsp;<asp:Button ID="btnUpload" runat="server" Text="Upload" CssClass="button" 
                                                        onclick="btnUpload_Click" /></td>
                                <td class="frmLable">&nbsp;</td>
                                <td>
                                     </td>
                            </tr>                                    
                            <tr>
                                <td></td>
                                <td class="style2" colspan="3">
                                    <asp:Label ID="lblMsg" Font-Bold="true" ForeColor="Red" runat="server" Text=""></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4">
                                    <asp:Table ID="tblResult" runat="server" Width="100%"></asp:Table><br />
                                </td>
                                
                            </tr>    
                        </table>
                    </fieldset>
                </td>
            </tr>
   </table>
    </form>
</body>
</html>
