<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup.ResetPassword" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <style>
         .table .table {
    background-color: #F5F5F5 !important;
        }

    </style>
</head>
<body>

    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration  </a></li>
                            <li class="active"><a href="ResetPassword.aspx">User Management</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <asp:Panel ID="pnlBreadCrumb" runat="server">
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li><a href="list.aspx?agentId=<%=GetAgent()%>&mode=<%=GetMode()%>" target="_self">User List </a></li>
                        <li class="active"><a href="#" class="selected" target="_self">Reset Password </a></li>
                    </ul>
                </div>
            </asp:Panel>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">

                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Reset Password</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <table class="table table-responsive">
                                        <tr>
                                            <td>
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <td style="width:12%"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="frmLable">User Name:</td>
                                                        <td>
                                                            <asp:TextBox ID="userName" runat="server" CssClass="form-control"  />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="frmLable">New Password:</td>
                                                        <td>
                                                            <asp:TextBox ID="pwd" runat="server" CssClass="form-control" TextMode="Password"  />
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
                                                            ErrorMessage="Required!" ControlToValidate="pwd" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="frmLable">Confirm Password:</td>
                                                        <td>
                                                            <asp:TextBox ID="confirmPwd" runat="server" CssClass="form-control" TextMode="Password"  />
                                                             <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server"
                                                            ErrorMessage="Required!" ControlToValidate="confirmPwd" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            <asp:CompareValidator ID="CompareValidator1" runat="server" ErrorMessage="Password Doesn't Match" ControlToCompare="pwd"
                                                            ControlToValidate="confirmPwd" ForeColor="Red" SetFocusOnError="True"></asp:CompareValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td>
                                                            <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-primary m-t-25" 
                                                             OnClick="btnReset_Click" />
                                                             &nbsp;
                                                            <asp:Button ID="btnBack" runat="server" Text="Back" CssClass="btn btn-primary m-t-25"
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
                    </div>
                </div>
    </form>
</body>
</html>

