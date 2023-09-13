<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AdminUserSetup.ResetPassword" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
</head>
<body>

<form id="form1" runat="server">
<div class="breadCrumb">User Management » Admin User Setup » Reset Password</div>
    <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <asp:Panel ID="pnlBreadCrumb" runat="server">
                    <table style="width: 100%">
                        <tr>
                            <td height="20" class="welcome">Username : <%=GetUserName() %></td>
                        </tr>
                        <tr>
                            <td height="10"> 
                                <div class="tabs"> 
                                    <ul> 
                                        <li> <a href="list.aspx">Admin User List </a></li>
                                        <li> <a href="#" class="selected">Reset Password </a></li>
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
                <table border="0" cellspacing="0" cellpadding="0" align="left" class="formTable">
                    <tr>
                        <th colspan="4" class="frmTitle">Reset Password</th>
                    </tr>
                    <tr>
                        <td class="fromHeadMessage" colspan="4"><span class="ErrMsg">*</span>Fields are mandatory and use the own idea to input this for</td>
                    </tr> 
                    <tr>
                        <td class="frmLable">User Name:</td>
                        <td>
                            <asp:TextBox ID="userName" runat="server" CssClass="input"  Width="270px" />
                        </td>
                    </tr>    
                    <tr>
                        <td class="frmLable">New Password:</td>
                        <td>
                            <asp:TextBox ID="pwd" runat="server" CssClass="input" TextMode="Password" Width="270px" />
                            <span class="errormsg">*</span>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" 
                                                        ErrorMessage="Required!" ControlToValidate="pwd" ForeColor="Red" ValidationGroup="user" 
                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                        </td>
                    </tr>                                 
                    <tr>
                        <td class="frmLable">Confirm Password:</td>
                        <td>
                            <asp:TextBox ID="confirmPwd" runat="server" CssClass="input" TextMode="Password" Width="270px" />
                            <asp:CompareValidator ID="CompareValidator1" runat="server" ValidationGroup="user" 
                                                  ErrorMessage="Password Doesn't Match" ControlToCompare="pwd" 
                                                  ControlToValidate="confirmPwd" ForeColor="Red" SetFocusOnError="True"></asp:CompareValidator>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td>
                            <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="button" ValidationGroup="user" 
                                        onclick="btnReset_Click" /> &nbsp;
                            <asp:Button ID="btnBack" runat="server" Text="Back" CssClass="button" 
                                        onclick="btnBack_Click" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    </form>
</body>
</html>
