<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="Swift.web.SwiftSystem.Notification.LoginLogs.ResetPassword" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
</head>
<body>

    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>User Management</li>
                            <li>User Setup</li>
                            <li class="active">Reset Password</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-7">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Reset Password</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-3">User Name :</label>
                                <div class="col-md-5 ">
                                    <asp:TextBox ID="userName" runat="server" CssClass="form-control" /></div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3">New Password : <span class="errormsg">*</span></label>
                                <div class="col-md-5">
                                    <asp:TextBox ID="pwd" runat="server" CssClass="form-control" TextMode="Password"  />
                                </div>
                                <div class="col-md-4">
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Required!" ControlToValidate="pwd" ForeColor="Red" ValidationGroup="user"
                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3">Confirm Password :</label>
                                <div class="col-md-5">
                                    <asp:TextBox ID="confirmPwd" runat="server" CssClass="form-control" TextMode="Password"  />
                                </div>
                                <div class="col-md-4">
                                    <asp:CompareValidator ID="CompareValidator2" runat="server" ValidationGroup="user" ErrorMessage="Password Doesn't Match" ControlToCompare="pwd"
                                        ControlToValidate="confirmPwd" ForeColor="Red" SetFocusOnError="True"></asp:CompareValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-6 col-md-offset-3">
                                    <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-primary m-t-25" ValidationGroup="user" OnClick="btnReset_Click" />
                                    <input id="btnBack" type="button" class="btn btn-primary m-t-25" value="Back" onclick=" Javascript: history.back(); " />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%--        <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    <asp:Panel ID="pnlBreadCrumb" runat="server">
                        <table style="width: 100%">
                            <tr>
                                <td height="26" class="bredCrom">
                                    <div>User Management » User Setup » Reset Password</div>
                                </td>
                            </tr>
                            <tr>
                                <td height="20" class="welcome">Username : <%=GetUserName() %></td>
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
                                <asp:TextBox ID="userName" runat="server" CssClass="input" Width="270px" />
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
                            <td>--%>
        <%-- <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="button" ValidationGroup="user"
                                    OnClick="btnReset_Click" />
                                &nbsp;
                            <input id="btnBack" type="button" class="button" value="Back" onclick=" Javascript: history.back(); " />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>--%>
    </form>
</body>
</html>
