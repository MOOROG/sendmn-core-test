<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AgentUserSetup.ResetPassword" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
   
</head>
<body>

<form id="form1" runat="server">
     <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1>
                        User Management<small></small>
                    </h1>
                    <ol class="breadcrumb">
                        <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li ><a href="#">Agent Setup</a></li>
                        <li class="active"><a href="#">Reset Password</a></li>
                    </ol>
                </div>
            </div>
        </div>
    <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0" style="margin-left:20px;" class="table"
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
                                        <li> <a href="list.aspx?agentId=<%=GetAgent()%>&mode=<%=GetMode()%>">User List </a></li>
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
                <div class="panel panel-default">
                    <div class="panel-heading panel-title">Reset Password</div>
                    <div class="panel-body">
                <table border="0" cellspacing="0" cellpadding="0" align="left" class="formTable" width="70%">
                   
                   
                    <tr>
                        <td class="frmLable">User Name:</td>
                        <td>
                            <asp:TextBox ID="userName" runat="server" CssClass="input form-control" width="70%" />
                        </td>
                    </tr>    
                    <tr>
                        <td class="frmLable">New Password:<span class="errormsg">*</span></td>
                        <td>
                            <asp:TextBox ID="pwd" runat="server" CssClass="input form-control" TextMode="Password" width="70%"  />
                            
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" 
                                                        ErrorMessage="Required!" ControlToValidate="pwd" ForeColor="Red" ValidationGroup="user" 
                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                        </td>
                    </tr>                                 
                    <tr>
                        <td class="frmLable">Confirm Password:</td>
                        <td>
                            <asp:TextBox ID="confirmPwd" runat="server" CssClass="input form-control" TextMode="Password" width="70%" />
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

                    </div>
                </div>
            </td>
        </tr>
    </table>
         </div>
    </form>
</body>
</html>

