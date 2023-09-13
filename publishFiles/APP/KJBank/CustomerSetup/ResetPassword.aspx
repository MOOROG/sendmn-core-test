<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="Swift.web.KJBank.CustomerSetup.ResetPassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../ui/js/jquery.min.js"></script>
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script>
        function CheckFormValidation() {
            var reqField = "newPassword,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            return true;
        }
        function ShowMsg(type) {
            //var invalidPwd = "Password must meet the following requirements:\n At least one symbol \n At least one capital letter \n At least one number \n Be at least 9 characters";
            if (type == 's') {
                if (confirm("Password changed successfully!")) {
                    //window.frames["myFrame"].location = "http://..."
                    window.open("/KJBank/CustomerSetup/ModifyCustomer.aspx", "mainFrame");
                }
                else {
                    window.open("/KJBank/CustomerSetup/ModifyCustomer.aspx", "mainFrame");
                }
            }
            else {
                alert(type)
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="/Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="List.aspx">Change Password</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Change Password
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Email:</label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:Label ID="txtEmail" runat="server"></asp:Label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    New Password:</label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="newPassword" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-2">
                                    <asp:Button ID="changePass" runat="server" CssClass="btn btn-primary" OnClientClick="return CheckFormValidation();" OnClick="changePass_Click" Text="Reset Password" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>