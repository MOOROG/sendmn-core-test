<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="Swift.web.Remit.AgentOperation.UserManagement.ResetPassword" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <style>
        table tr td {
            background-color: #f5f5f5;
        }
    </style>
</head>
<body>

    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                            <li class="active"><a href="ResetPassword.aspx">User Management</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="panel panel-default">
                <div class="panel-heading">RESET PASSWORD</div>
                <div class="panel-body">
                    <table class="table table-condensed">
                        <tr>
                            <td>
                                <asp:Panel ID="pnlBreadCrumb" runat="server">
                                    <table style="width: 100%">

                                        <tr>
                                            <td height="20" class="welcome">
                                                <h3>Username : <%=GetUserName() %></h3>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="10">
                                                <div class="listtabs">
                                                    <ul class="nav nav-tabs" role="tablist">
                                                        <li><a href="list.aspx?agentId=<%=GetAgent()%>&mode=<%=GetMode()%>">User List </a></li>
                                                        <li class="active"><a href="#" class="selected">Reset Password </a></li>
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
                                <table class="table table-condensed">
                                    <%--<tr>
                                        <th colspan="4" class="frmTitle">Reset Password</th>
                                    </tr>--%>
                                    <tr>
                                        <td class="frmLable">User Name:</td>
                                        <td>
                                            <asp:TextBox ID="userName" runat="server" CssClass="form-control" Width="270px" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">New Password: <span class="errormsg">*</span></td>
                                        <td>
                                            <asp:TextBox ID="pwd" runat="server" CssClass="form-control" TextMode="Password" Width="270px" />

                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
                                                ErrorMessage="Required!" ControlToValidate="pwd" ForeColor="Red" ValidationGroup="user"
                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Confirm Password:</td>
                                        <td>
                                            <asp:TextBox ID="confirmPwd" runat="server" CssClass="form-control" TextMode="Password" Width="270px" />
                                            <asp:CompareValidator ID="CompareValidator1" runat="server" ValidationGroup="user"
                                                ErrorMessage="Password Doesn't Match" ControlToCompare="pwd"
                                                ControlToValidate="confirmPwd" ForeColor="Red" SetFocusOnError="True"></asp:CompareValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td>
                                            <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-primary" ValidationGroup="user"
                                                OnClick="btnReset_Click" />
                                            &nbsp;
                            <asp:Button ID="btnBack" runat="server" Text="Back" CssClass="btn btn-primary"
                                OnClick="btnBack_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </form>
</body>
</html>