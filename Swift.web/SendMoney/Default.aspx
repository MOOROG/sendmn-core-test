<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Swift.web.SendMoney.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <title><%=Swift.web.Library.GetStatic.ReadWebConfig("companyName","") %> - Agent Login</title>
    <link href="../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link rel="icon" type="image/ico" sizes="32x32" href="../ui/index/images/favicon.ico">
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
                                <h1>Agent Login</h1>
                            </div>
                            <div id="msg" runat="server" class="error">
                                <div class="alert alert-danger" runat="server" id="errMsg" visible="false"></div>
                            </div>
                            <div class="login-body">
                                <form role="form" id="loginForm" runat="server">
                                    <%--  <div class="form-group">
                                        <label for="exampleInputPassword1">Login Branch <span class="notifyRequired">*</span></label>
                                        <asp:DropDownList ID="ddlBranch" runat="server" CssClass="form-control" required="true"></asp:DropDownList>
                                    </div>--%>
                                    <div class="form-group">
                                        <label for="exampleInputAgentId1">Agent ID <span class="notifyRequired">*</span></label>
                                        <asp:TextBox class="form-control" ID="agentCode" placeholder="Enter Agent ID" runat="server" Text="" required="true" autocomplete="off"></asp:TextBox>
                                    </div>
                                    <div class="form-group" id="Google2FAuthDivCode" runat="server">
                                        <label for="exampleInputPassword1">Employee ID <span class="notifyRequired">*</span></label>
                                        <asp:TextBox class="form-control" ID="employeeId" runat="server" placeholder="Enter Employee ID" required="true" autocomplete="off"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label for="exampleInputEmail1">User Name <span class="notifyRequired">*</span></label>
                                        <asp:TextBox class="form-control" ID="username" placeholder="Enter Username" runat="server" required="true" autocomplete="off"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label for="exampleInputPassword1">Password <span class="notifyRequired">*</span></label>
                                        <asp:TextBox class="form-control" ID="pwd" runat="server" placeholder="Enter Password" TextMode="Password" required="true" autocomplete="off"></asp:TextBox>
                                    </div>
                                    <div class="form-group" id="Google2FAuthDiv" runat="server">
                                        <label for="verificationCode">Google Auth Code<span class="notifyRequired">*</span></label>
                                        <asp:TextBox class="form-control" ID="verificationCode" Text="" placeholder="Enter Google Auth Code" runat="server"></asp:TextBox>
                                    </div>
                                    <%--<button type="button" class="btn btn-default" id="btnLogin">Submit</button>--%>
                                    <asp:Button ID="btnLogin" class="btn btn-default" runat="server" Text="Submit" OnClientClick="return CheckValidaion();" OnClick="btnLogin_Click" />
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
    <script src="../ui/js/jquery.min.js" type="text/javascript"></script>
    <script src="../ui/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="../js/functions.js"></script>

    <script type="text/javascript">
        history.pushState(null, null, location.href);
        window.onpopstate = function () {
            history.go(1);
        };
        function checkSubmit(e) {
            if (e && e.keyCode == 13) {

            }
        }

        function CheckValidaion() {
            var reqField = '';
            if ('<%=use2FA%>' == 'Y') {
                reqField = "<%=username.ClientID%>,<%=pwd.ClientID%>,<%=verificationCode.ClientID%>,";
            }
            else {
                reqField = "<%=username.ClientID%>,<%=pwd.ClientID%>,<%=employeeId.ClientID%>,";
            }


            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
        };
    </script>
</body>
</html>
