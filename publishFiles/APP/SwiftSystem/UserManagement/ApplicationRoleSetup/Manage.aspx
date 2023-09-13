<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs"
    Inherits="Swift.web.SwiftSystem.UserManagement.ApplicationRoleSetup.Manage" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
   <%-- <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>--%>
    <script src="../../../ui/js/metisMenu.min.js"></script>
    <%--<script src="../../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../../ui/js/jquery-jvectormap-world-mill-en.js"></script>--%>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="../../../ui/js/custom.js"></script>
    <!--page plugins-->
 
   
    <script type="text/javascript">
        $(document).ready(function () {
            document.body.scrollTop = document.documentElement.scrollTop = 0;
        });
        function goBack() {
            window.history.back();
        }
        function CheckFormValidation() {
            var reqField = "roleName,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
        }
    </script>
</head>
<body>

    <form id="form1" runat="server" onsubmit="return CheckFormValidation();">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                            <li><a href="Manage.aspx">Role Management</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="report-tab">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li><a href="List.aspx">Role List </a></li>
                        <li class="active" role="presentation">
                            <a href="#Manage" aria-controls="profile" role="tab" data-toggle="tab">Manage Role</a></li>
                    </ul>
                </div>
                <!-- Tab panes -->
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="Manage">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="panel panel-default ">
                                    <!-- Start .panel -->
                                    <div class="panel-heading">
                                        <h4 class="panel-title">
                                            <asp:Label ID="header" > Add New Role</asp:Label>
                                        </h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                            <%--<a href="#" class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <div class="row">
                                            <div class="form-group">
                                                <label class="control-label col-lg-2 col-md-3" for="">
                                                    Name:<span class="errormsg">*</span>
                                                </label>
                                                <div class="col-md-9">
                                                    <asp:TextBox ID="roleName" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                                 </div>
                                            </div>
                                        </div>

                                        <div class="row">
                                                <div class="form-group">
                                                    <label class="control-label col-lg-2 col-md-3" for="">
                                                        Type:
                                                     </label>
                                                <div class="col-md-9">
                                                    <asp:DropDownList ID="type" runat="server" Width="100%" CssClass="form-control"> 
                                                        <asp:ListItem Text="Head Office" Value="H"></asp:ListItem>
                                                        <asp:ListItem Text="Agent" Value="A"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="row">
                                                <div class="form-group">
                                                    <label class="control-label col-lg-2 col-md-3" for="">
                                                        Is Active:
                                                        </label>
                                                 <div class="col-md-9">
                                                    <asp:DropDownList ID="isActive" runat="server" Width="100%" CssClass="form-control">
                                                        <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                        <asp:ListItem Value="N">No</asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="row">
                                            <div class="col-md-4 col-md-offset-3 ">
                                                    <asp:Button ID="BtnSave" runat="server" Text="Save" OnClick="BtnSave_Click" class="btn btn-primary m-t-25" ></asp:Button>
                                                    <button class="btn btn-primary m-t-25" onclick="goBack()" type="button">
                                                        Back</button>
                                            </div>
                                        </div>
                        </div>
                    </div>
                </div>
            </div>
                    </div>
                </div>
      </div>
            </div>
    </form>
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/metisMenu.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <!-- Flot -->
    <script type="text/javascript" src="../../../ui/js/flot/jquery.flot.js"></script>
    <script type="text/javascript" src="../../../ui/js/flot/jquery.flot.tooltip.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/flot/jquery.flot.resize.js"></script>
    <script type="text/javascript" src="../../../ui/js/flot/jquery.flot.pie.js"></script>
    <script type="text/javascript" src="../../../ui/js/chartjs/Chart.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/pace.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/waves.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="../../../ui/js/custom.js"></script>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
</body>
</html>
