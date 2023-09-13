<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Swift.web.Admin.Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <title><%=Swift.web.Library.GetStatic.ReadWebConfig("companyName","") %> - login</title>
    <link rel="icon" type="image/ico" sizes="32x32" href="../ui/index/images/favicon.ico">
    <link href="../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body>
    <div onkeypress="return checkSubmit(event)">
        <div class="login-bg">
            <div class="over-bg">
                <div class="container">
                    <div class="row">
                        <div class="account-col">
                            <div class="login-head">
                                <h1>Admin Login</h1>
                            </div>
                            <div id="msg" runat="server" class="error">
                                <div class="alert alert-danger" runat="server" id="errMsg" visible="false"></div>
                            </div>
                            <div class="login-body">
                                <form role="form" id="loginForm" runat="server">
                                    <div id="login" runat="server">
                                        <div class="form-group">
                                            <label for="exampleInputEmail1">User Name</label>
                                            <asp:TextBox class="form-control required" ID="txtUsername" Text="" placeholder="Enter Username" runat="server"></asp:TextBox>
                                        </div>
                                        <div class="form-group">
                                            <label for="exampleInputPassword1">Password</label>
                                            <asp:TextBox class="form-control required" ID="txtPwd" runat="server" autocomplete="off" TextMode="Password" placeholder="Enter password"></asp:TextBox>
                                        </div>
                                        <div class="form-group" id="Google2FAuthDivCode" runat="server">
                                            <label for="exampleInputPassword1">User Code</label>
                                            <asp:TextBox class="form-control required" ID="txtCompcode" runat="server" Text="" placeholder="Enter code"></asp:TextBox>
                                        </div>
                                        <div class="form-group" id="Google2FAuthDiv" runat="server">
                                            <label for="verificationCode">Google Auth Code</label>
                                            <asp:TextBox class="form-control required" ID="verificationCode" Text="" placeholder="Enter Google Auth Code" runat="server"></asp:TextBox>
                                        </div>
                                        <%--<button type="button" class="btn btn-default" id="btnLogin">Submit</button>--%>
                                        <asp:Button ID="btnLogin" class="btn btn-default" runat="server" Text="Submit" OnClientClick="return CheckValidaion();" OnClick="btnLogin_Click" />
                                    </div>
                                </form>
                            </div>
                            <p style="color:#FFF;text-align:center;background-color:#00c864"><%=DateTime.Today.ToString("yyyy") %> © <%= Swift.web.Library.GetStatic.ReadWebConfig("copyRightName","") %>. All rights Reserved. Version: <b><span id="spnVerion" runat="server"></span></b></p>
                            <div class="login-logo">
                                <i class="fa fa-user" aria-hidden="true"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery -->
    <script src="/ui/js/jquery.min.js" type="text/javascript"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"></script>

    <script src="http://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.2.8/jquery.form-validator.min.js" type="text/javascript"></script>

    <script type="text/javascript">
        
        function checkSubmit(e) {
            if (e && e.keyCode == 13) {
                // document.forms[0].submit();
                document.getElementById("<%=btnLogin.ClientID%>").click();
                // AjaxAuthenticate();
            }
        }

        function CheckValidaion() {
            var reqField = '';
            if ('<%=use2FA%>' == 'Y') {
                reqField = "<%=txtUsername.ClientID%>,<%=txtPwd.ClientID%>,<%=verificationCode.ClientID%>,";
            }
            else {
                reqField = "<%=txtUsername.ClientID%>,<%=txtPwd.ClientID%>,<%=txtCompcode.ClientID%>,";
            }

            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
        };
    </script>
</body>
</html>
