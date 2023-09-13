<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewRoleFunction.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.ApplicationRoleSetup.ViewRoleFunction" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form2" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li class="active"><a href="ViewRoleFunction.aspx?roleId=<%= GetRoleId() %>&roleName=<%= GetRoleName() %>">View Role Functions</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="report-tab">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li><a href="../ApplicationUserSetup/List.aspx">User List</a></li>
                        <li role="presentation" class="active"><a href="#list" aria-controls="home" role="tab"
                            data-toggle="tab">Role Functions</a></li>
                    </ul>
                </div>
                <!-- Tab panes -->
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="list">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default ">
                                    <!-- Start .panel -->
                                    <div class="panel-heading">
                                        <h4 class="panel-title">Role List</h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><a href="#"
                                                class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <div class="gridDiv">
                                            <div id="rpt_grid" runat="server" style="width: 100%"></div>
                                            <br style="clear: both" />
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
    <%--<form id="form1" runat="server">
    <div class="breadCrumb">User Management » User Setup » View Role Functions</div>
    <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td height="20" class="welcome"><%=GetRoleName() %></td>
        </tr>
        <tr>
            <td height="10"> 
                <div class="tabs">
                    <ul>
                        <li> <a href="../ApplicationUserSetup/List.aspx">User List </a></li>
                        <li> <a href="#"  class="selected">Role Functions </a></li>
                    </ul> 
                </div>
            </td>
        </tr>
        <tr>
            <td height="524" valign="top">
                <div class = "gridDiv">
                    <div id = "rpt_grid" runat = "server" style = "width: 700px"></div>
                    <br style = "clear: both" />
                </div>
            </td>
        </tr>
    </table>
    </form>--%>
</body>
</html>
