<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserRole.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.ApplicationUserSetup.UserRole" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />


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
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                            <li class="active"><a href="UserRole.aspx">User Management</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a href="list.aspx?agentId=<%=GetAgent()%>&mode=<%=GetMode()%>">User List </a></li>
                    <li role="presentation" class="active"><a href="#" aria-controls="home" role="tab" data-toggle="tab">User Roles </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">User Roles (  Username : <%=GetUserName() %>)</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div id="rpt_grid" runat="server" class="gridDiv">
                                    </div>
                                    <asp:Label ID="mes" runat="server"></asp:Label>
                                    <br style="clear: both" />
                                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary" ValidationGroup="user"
                                        OnClick="btnSave_Click" />
                                    &nbsp;
                                    <asp:Button ID="btnBack" runat="server" Text="Back" CssClass="btn btn-primary"
                                        OnClick="btnBack_Click" />
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
        <%--<table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    <asp:Panel ID="pnlBreadCrumb" runat="server">
                        <table style="width: 100%;">
                            <tr>
                                <td height="20" class="welcome">Username : <%=GetUserName() %></td>
                            </tr>
                            <tr>
                                <td height="10"> 
                                    <div class="tabs"> 
                                        <ul> 
                                            <li> <a href="list.aspx?agentId=<%=GetAgent()%>&mode=<%=GetMode()%>">User List </a></li>
                                            <li> <a href="#" class="selected">User Roles </a></li>
                                        </ul> 
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </asp:Panel>
                </td>
            </tr>
            <tr>
                <td>
                    <div class = "gridDiv">
                        <div id = "rpt_grid" runat = "server" style = "width: 700px"></div>
                        <asp:Label ID="mes" runat="server" ></asp:Label>
                        <br style = "clear: both" />
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="button" ValidationGroup="user" 
                                    onclick="btnSave_Click" /> &nbsp;
                        <asp:Button ID="btnBack" runat="server" Text="Back" CssClass="button" 
                                    onclick="btnBack_Click" />
                    </div>
                </td>
            </tr>
        </table>--%>
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

