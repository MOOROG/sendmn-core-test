<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserRole.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AdminUserSetup.UserRole" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
  
    <head id="Head1" runat="server">
        <!-- Bootstrap -->
        <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
        <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
        <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
        <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
        <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
        <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
        <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
        <!--[if lt IE 9]>
            <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
            <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->
        <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
        <script src="../../../js/functions.js" type="text/javascript"> </script>
    </head>
    <body>

<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Admin User Setup</a></li>
                            <li class="active"><a href="UserRole.aspx">User Roles</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            Username : <%=GetUserName() %>
            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="deactive"><a href="/SwiftSystem/UserManagement/ApplicationUserSetup/List.aspx">Admin User List </a></li>
                    <li role="presentation" class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">User Roles</a></li>
                </ul>
            </div>
            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Role Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><%--<a href="#"
                                            class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                                        <ContentTemplate>
                                            <div class="form-group">
                                                <div id = "rpt_grid" runat = "server" style = "width: 700px"></div>
                                            </div>
                                            <div class="form-group">
                                                <asp:Label ID="mes" runat="server" ></asp:Label>
                                            </div>
                                            <div class="form-group">
                                                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary" ValidationGroup="user" 
                                                            onclick="btnSave_Click" /> &nbsp;
                                                <asp:Button ID="btnBack" runat="server" Text="Back" CssClass="btn btn-primary" 
                                                            onclick="btnBack_Click" />
                                            </div>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                            </div>
                            <!-- End .panel -->
                        </div>
                        <!--end .col-->
                    </div>
                    <!--end .row-->
                </div>
            </div>
        </div>
    </form>
    </body>
    </html>
