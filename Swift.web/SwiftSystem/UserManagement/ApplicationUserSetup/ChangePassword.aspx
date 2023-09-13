<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs"
    Inherits="Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup.ChangePassword" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <link href="../../../css/style1.css" rel="stylesheet" />
    <!-- Bootstrap Core CSS -->
    <link href="../../../Bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- MetisMenu CSS -->
    <link href="../../../Bootstrap/css/metisMenu.min.css" rel="stylesheet" type="text/css" />
    <!-- timeline CSS -->
    <link href="../../../Bootstrap/css/timeline.css" rel="stylesheet" type="text/css" />
    <!-- Custom CSS -->
    <link href="../../../Bootstrap/css/style.css" rel="stylesheet" type="text/css" />
    <!-- Custom Fonts -->
    <link href="../../../Bootstrap/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <%--<link href="../../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <link href="../../../css/formStyle.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        function RedirectUrl(url) {
            window.parent.location.href = url;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server" autocomplete="off">
    <div id="main-page-wrapper">
        <div class="col-md-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Change Password
                </div>
                <div class="panel-body">
                    <p>
                        <b>You are requested to change your password for the following reason(s).</b><br />
                        1. You logged on to this system for the first time.<br />
                        2. Your password has been reset by administrator.<br />
                        3. Your password is expired as per password policy.<br />
                        4. You have chosen to change your password.
                    </p>
                    <div class="row">
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>
                                    User Name:</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <asp:Label ID="userName" runat="server" />
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>
                                    Current Password:</label><span class="errormsg">*</span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <asp:TextBox ID="oldPwd" runat="server" CssClass="form-control" Width="100%" TextMode="Password" />
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Required!"
                                    ControlToValidate="oldPwd" ForeColor="Red" ValidationGroup="user" SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>
                                    New Password:</label><span class="errormsg">*</span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <asp:TextBox ID="pwd" runat="server" CssClass="form-control" Width="100%" TextMode="Password" />
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Required!"
                                    ControlToValidate="pwd" ForeColor="Red" ValidationGroup="user" SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>
                                    Confirm Password:</label>
                                <span class="errormsg">*</span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <asp:TextBox ID="confirmPwd" runat="server" CssClass="form-control" Width="100%"
                                    TextMode="Password" />
                                <asp:CompareValidator ID="CompareValidator1" runat="server" ValidationGroup="user"
                                    ErrorMessage="Confirm Password Doesn't Match" ControlToCompare="pwd" ControlToValidate="confirmPwd"
                                    ForeColor="Red" SetFocusOnError="True"></asp:CompareValidator>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <asp:Button ID="btnOk" runat="server" Text="Save Changes" CssClass="btn btn-primary m-t-25"
                                ValidationGroup="user" OnClick="btnOk_Click" />
                            <%-- <button class="btn btn-primary m-t-25" type="submit">Save Change</button>--%>
                        </div>
                        <!-- /.col-lg-6 (nested) -->
                    </div>
                    <%-- <div class="col-md-12 col-xs-12 col-sm-6">--%>
                    <div class="col-md-6">
                        <asp:Label ID="msg" runat="server" ForeColor="Red" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    </form>
    <%--  Scripts for this page--%>
    <script src="../../../Bootstrap/js/jquery.min.js" type="text/javascript"></script>
    <!-- Bootstrap Core JavaScript -->
    <script src="../../../Bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <!-- Metis Menu Plugin JavaScript -->
    <script src="../../../Bootstrap/js/metisMenu.js" type="text/javascript"></script>
    <!-- Custom Theme JavaScript -->
    <script src="../../../Bootstrap/js/custom.js" type="text/javascript"></script>
</body>
</html>
