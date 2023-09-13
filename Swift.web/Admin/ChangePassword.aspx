<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="Swift.web.Admin.ChangePassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script>
        function CheckFormValidation() {
            var reqField = "oldPassword,newPassword,confirmPassword,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }

            var pass = $('#<%=newPassword.ClientID%>').val();
            var confirmPass = $('#<%=confirmPassword.ClientID%>').val();
            if (pass != confirmPass) {
                $('#<%=confirmPassword.ClientID%>').val('');
                $('#<%=confirmPassword.ClientID%>').focus();
                alert('Password and confirm password are not same!!');
                return false;
            }
            $('#<%=changePass.ClientID%>').click();
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
                                    User Name:</label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:Label ID="userName" runat="server" Text="Test User"></asp:Label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Old Password:</label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="oldPassword" TextMode="Password" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    New Password:</label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="newPassword" TextMode="Password" runat="server" CssClass="form-control"></asp:TextBox>
                                  <asp:RegularExpressionValidator ID="Regex2" runat="server" ControlToValidate="newPassword"
                                    ValidationExpression="^(?=.*?[A-Z])(?=(.*[a-z]){1,})(?=(.*[\d]){1,})(?=(.*[\W]){1,})(?!.*\s).{8,}$"
                                    ErrorMessage="Minimum 8 characters atleast 1 Alphabet, 1 Number and 1 Special Character" ForeColor="Red" />
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Confirm Password:</label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="confirmPassword" TextMode="Password" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-2">
                                    <input type="button" value="Change Password" onclick="CheckFormValidation();" class="btn btn-primary m-t-25" />
                                    <asp:Button ID="changePass" runat="server" OnClick="changePass_Click" Style="display: none;" />
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