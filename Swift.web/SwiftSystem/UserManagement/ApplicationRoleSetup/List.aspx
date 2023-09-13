<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.ApplicationRoleSetup.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
<%--    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />--%>
</head>
<body>
        <form id="form1" runat="server">
            <div class="page-wrapper">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="page-title">
                            <h1>
                            </h1>
                            <ol class="breadcrumb">
                                <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                                <li class="active"><a href="List.aspx">Role Management</a></li>
                            </ol>
                        </div>
                    </div>
                </div>
                <!-- end .page title-->
                <div class="report-tab">
                    <!-- Nav tabs -->
                    <div class="listtabs">
                        <ul class="nav nav-tabs" role="tablist">
                            <li role="presentation" class="active">
                                <a href="#list" aria-controls="home" role="tab" data-toggle="tab">Role List</a></li>
                            <li><a href="Manage.aspx">Manage Role </a></li>
                            <%-- <li role="presentation"><a href="#Manage" aria-controls="profile" role="tab" data-toggle="tab"><a href="Manage.aspx">Manage</a>
                        </a></li>--%>
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
                                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                                <%--<a href="#" class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                            </div>
                                        </div>
                                        <div class="panel-body">
                                            <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false">
                                            </div>
                                        </div>
                                    </div>
                                    <!-- End .panel -->
                                </div>
                                <!--end .col-->
                            </div>
                            <!--end .row-->
                        </div>
                        <div role="tabpanel" class="tab-pane" id="Manage">
                        </div>
                    </div>
                </div>
            </div>
    <%--<table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td height="524" valign="top">
                <div id="rpt_grid" runat="server" class="gridDiv">
                </div>
            </td>
        </tr>
    </table>--%>
    <script language="javascript" type="text/javascript">
        function PopUpForm(url) {
            var res = OpenDialog(url, 400, 400, 0, 0);
            SubmitForm("<% =GridName%>");
        }
    </script>
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
