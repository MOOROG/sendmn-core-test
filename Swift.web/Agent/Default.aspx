<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Swift.web.Agent.Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <title><%=Swift.web.Library.GetStatic.ReadWebConfig("companyName","") %> - Agent Login</title>
    <link href="../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../ui/css/style.css" rel="stylesheet" />
    <link href="../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
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

                                    <div class="form-group">
                                        <label for="exampleInputAgentId1">Agent ID <span class="notifyRequired">*</span></label>
                                        <asp:TextBox class="form-control" ID="agentCode" placeholder="Enter Agent ID" runat="server" Text="" required="true" autocomplete="off"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label for="exampleInputPassword1">Employee ID <span class="notifyRequired">*</span></label>
                                        <asp:TextBox class="form-control" ID="employeeId" runat="server" placeholder="Enter Employee ID" Text="" required="true" autocomplete="off"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label for="exampleInputEmail1">User Name <span class="notifyRequired">*</span></label>
                                        <asp:TextBox class="form-control" ID="username" placeholder="Enter Username" TextMode="Password" runat="server" required="true" autocomplete="off"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label for="exampleInputPassword1">Password <span class="notifyRequired">*</span></label>
                                        <asp:TextBox class="form-control" ID="pwd" runat="server" TextMode="Password" placeholder="Enter Password" required="true" autocomplete="off"></asp:TextBox>
                                    </div>

                                    <%--<button type="button" class="btn btn-default" id="btnLogin">Submit</button>--%>
                                    <asp:Button ID="btnLogin" class="btn btn-default" runat="server" Text="Submit" OnClick="btnLogin_Click" />
                                </form>
                            </div>
                            <div class="login-logo">
                                <i class="fa fa-user" aria-hidden="true"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript">

        function ShowErrorMsg(msg) {
            $("#msg").html('<div class="alert alert-danger">' + msg + '</div>');
        }

        function AjaxAuthenticate() {
            var name = $("#username").val();
            var pwd = $("#pwd").val();
            var code = $("#employeeId").val();
            var agentcode = $("#agentCode").val();
            $.ajax({
                url: '<%= ResolveUrl("Default.aspx") %>',
                type: 'POST',
                data: { methodName: "GetLogin", username: name, password: pwd, companycode: code },
                success: function (result) {
                    var strng = JSON.stringify(result);
                    obj = JSON.parse(strng);
                    if (obj["ErrorCode"] == "1" || obj["ErrorCode"] == "9999") {
                        $("#msg").html('<div class="alert alert-danger">' + obj["Msg"] + '</div>');
                    }
                    else if (obj["isForcePwdChanged"] == "Y") {
                        window.location.href = "SwiftSystem/UserManagement/ApplicationUserSetup/ChangePassword.aspx";
                    }
                    else {
                        window.location.href = "Dashboard.aspx";
                    }
                },
                error: function (result) {
                    alert("Sorry! Due to unexpected errors operation terminates !");
                }
            });
        }
          function checkSubmit(e) {
              if (e && e.keyCode == 13) {
                  document.getElementById("<%=btnLogin.ClientID%>").click();
              }
          }
    </script>
</body>
</html>