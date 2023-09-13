<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Edit.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.ApplicationMenuSetup.Edit" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta charset="utf-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="description" content="" />
  <meta name="author" content="" />

  <link href="/ui/css/style.css" rel="stylesheet" />
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script src="/ui/js/jquery.min.js"></script>
  <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
  <script src="/js/Swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js" type="text/javascript"></script>
  <script src="/ui/js/jquery-ui.min.js"></script>
  <script src="/js/swift_autocomplete.js"></script>
  <script src="/js/swift_calendar.js"></script>
  <script src="/ui/js/pickers-init.js"></script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script type="text/javascript">
</script>
</head>
<body>
  <form id="form1" runat="server" class="col-md-12" enctype="multipart/form-data">
    <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="up" runat="server">
      <ContentTemplate>
        <div class="page-wrapper">
          <div class="row">
            <div class="col-sm-12">
              <div class="page-title">
                <ol class="breadcrumb">
                  <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                  <li><a onclick="return LoadModule('adminstration')">Administration</a></li>
                  <li><a href="List.aspx">Application Menu List</a></li>
                  <li class="active"><a href="#">Add/Edit</a></li>
                </ol>
              </div>
            </div>
          </div>
          <div class="row">
            <div class="col-md-12">
              <div class="panel panel-default recent-activites">
                <div class="panel-heading">
                  <h4 class="panel-title">Application Menu</h4>
                </div>
                <div class="panel-body">
                  <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                    <Triggers>
                      <asp:PostBackTrigger ControlID="btnRegister" />
                    </Triggers>
                    <ContentTemplate>
                      <div class="row">
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="functionId">
                            Function ID:
                          </label>
                          <asp:TextBox ID="functionId" runat="server" CssClass="form-control" disabled="disabled"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="module">
                            Module:
                          </label>
                          <asp:DropDownList ID="module" runat="server" CssClass="form-control">
                          </asp:DropDownList>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="menuGroup">
                            Menu Group:
                          </label>
                          <asp:DropDownList ID="menuGroup" runat="server" CssClass="form-control">
                          </asp:DropDownList>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="menuName">
                            Menu Name:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="menuName" runat="server" CssClass="form-control"></asp:TextBox>
                          <asp:RequiredFieldValidator ID="menunameValidator" runat="server" ControlToValidate="menuname" ErrorMessage="Менюны нэрээ оруулна уу!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="menuDesc">
                            Menu Description:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="menuDesc" runat="server" disabled="disabled" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="link">
                            Link:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="link" runat="server" CssClass="form-control"></asp:TextBox>
                          <asp:RequiredFieldValidator ID="linkValidator" runat="server" ControlToValidate="link" ErrorMessage="Замаа оруулна уу!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="agentGroup">
                            Agent MenuGroup:
                          </label>
                          <asp:TextBox ID="agentGroup" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                      </div>
                    </ContentTemplate>
                  </asp:UpdatePanel>
                  <div class="row">
                    <div class="col-lg-12 form-group">
                      <asp:Button ID="btnRegister" runat="server" Text="Register Menu" CssClass="btn btn-primary m-t-25" OnClick="btnRegister_Click" />
                    </div>
                    <triggers>
                      <asp:PostBackTrigger ControlID="btnRegister" />
                    </triggers>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        </div>
      </ContentTemplate>
    </asp:UpdatePanel>
  </form>
</body>
</html>
