<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="Swift.web.AgentPanel.ResetPassword.ResetPassword" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../ui/js/jquery.min.js"></script>
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../ui/js/jquery-ui.min.js"></script>
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script>
        function CheckFormValidation() {
            var reqField = "txtEmail_aText,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            return true;
        }
        function ShowMsg(type) {
            //var invalidPwd = "Password must meet the following requirements:\n At least one symbol \n At least one capital letter \n At least one number \n Be at least 9 characters";

            alert(type)
            window.open("/AgentPanel/resetpassword/ResetPassword.aspx", "mainFrame");

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
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Email:</label>
                                <div class="col-lg-10 col-md-9">
                                    <uc1:SwiftTextBox ID="txtEmail" runat="server" Category="remit-CustomerEmail" CssClass="form-control" Title="Enter Customer Email" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-12 col-md-13 control-label" for="">
                                    Note : <strong>Password will be sent to customer's Mobile number as shown above.</strong>
                                </label>
                            </div>
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-2">
                                    <asp:Button ID="changePass" runat="server" ValidationGroup="reqEmail" CssClass="btn btn-primary" OnClientClick="return CheckFormValidation();" OnClick="changePass_Click" Text="Reset Password" />
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