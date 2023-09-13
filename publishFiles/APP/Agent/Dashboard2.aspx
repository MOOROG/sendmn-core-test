<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard2.aspx.cs" Inherits="Swift.web.Agent.Dashboard2" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title><%=Swift.web.Library.GetStatic.ReadWebConfig("companyName","") %> - Agent</title>
    <!-- Bootstrap -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/menu1.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js" type="text/javascript"> </script>
    <script src="/ui/bootstrap/js/bootstrap.min.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link rel="icon" type="image/ico" sizes="32x32" href="/ui/index/images/favicon.ico" />
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="../ui/js/respond.min.js"></script>
        <script src="../ui/js/html5shiv.min.js"></script>
    <![endif]-->
</head>
<body>
    <form id="form1" runat="server">
        <!-- Static navbar -->
        <nav class="navbar navbar-inverse yamm navbar-fixed-top " role="navigation">
            <div class="container">

                <div class="navbar-header">
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-menu" aria-expanded="false" aria-controls="navbar">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href="#">
                        <img src="../Images/jme.png" alt="logo" /></a>
                </div>
                <div id="navbar-menu" class="navbar-collapse collapse">
                    <ul class="nav navbar-nav navbar-right navbar-top-drops">
                        <%--<li class="search-info"><uc1:SwiftTextBox ID="searchMenu" runat="server" Category="remit-menuSearchAdmin" CssClass="form-control" Param1="@GetUsers()" Title="Blank for All" /></li>--%>
                        <%--<li class="dropdown"><a href="#" class="dropdown-toggle button-wave" data-toggle="dropdown"><i class="fa fa-envelope"></i> <span class="badge badge-xs badge-info">0</span></a>

                            <ul class="dropdown-menu dropdown-lg">
                                <li class="notify-title">
                                    0 New messages
                                </li>
                                <li class="clearfix">
                                    <a href="#">
                                        <span class="pull-left">
                                            <img src="#" alt="" class="img-circle" width="30">
                                        </span>
                                        <span class="block">
                                            John Doe
                                        </span>
                                        <span class="media-body">
                                            Lorem ipsum dolor sit amet
                                            <em>28 minutes ago</em>
                                        </span>
                                    </a>
                                </li>
                                <li class="clearfix">
                                    <a href="#">
                                        <span class="pull-left">
                                            <img src="#" alt="" class="img-circle" width="30">
                                        </span>
                                        <span class="block">
                                            John Doe
                                        </span>
                                        <span class="media-body">
                                            Lorem ipsum dolor sit amet
                                            <em>28 minutes ago</em>
                                        </span>
                                    </a>
                                </li>
                                <li class="clearfix">
                                    <a href="#">
                                        <span class="pull-left">
                                            <img src="#" alt="" class="img-circle" width="30">
                                        </span>
                                        <span class="block">
                                            John Doe
                                        </span>
                                        <span class="media-body">
                                            Lorem ipsum dolor sit amet
                                            <em>28 minutes ago</em>
                                        </span>
                                    </a>
                                </li>
                                <li class="read-more"><a href="#">View All Messages <i class="fa fa-angle-right"></i></a></li>
                            </ul>
                        </li>--%>
                        <li class="dropdown"><a href="#" class="dropdown-toggle button-wave" data-toggle="dropdown"><i class="fa fa-bell"></i><span class="badge badge-xs badge-warning">
                            <label id="countNotification" runat="server" style="display: contents;">0</label></span></a>
                            <ul class="dropdown-menu dropdown-lg" id="notiUL" runat="server">
                                <li class="notify-title">0 New Notification(s)
                                </li>
                                <li class="clearfix">
                                    <a href="#">
                                        <span class="pull-left">
                                            <i class="fa fa-bell" style='color: #0e96ec'></i>
                                        </span>

                                        <span class="media-body">No New Notification(s)
                                            <em></em>
                                        </span>
                                    </a>
                                </li>
                            </ul>
                        </li>
                        <li class="dropdown profile-dropdown">
                            <a href="#" class="dropdown-toggle button-wave" data-toggle="dropdown" role="button">
                                <img src="#" alt="" width="25">
                                <asp:Label ID="userName" runat="server"></asp:Label>
                            </a>
                            <ul class="dropdown-menu">
                                <li><a href="/Admin/ChangePassword.aspx" target="mainFrame"><i class="fa fa-key"></i>Change Password</a></li>
                                <%--<li><a href="#"><i class="fa fa-user"></i>My Profile</a></li>
                                <li><a href="#"><i class="fa fa-calendar"></i>My Calendar</a></li>
                                <li><a href="#"><i class="fa fa-envelope"></i>My Inbox</a></li>
                                <li><a href="#"><i class="fa fa-barcode"></i>My Task</a></li>
                                <li class="divider"></li>
                                <li><a href="#"><i class="fa fa-lock"></i>Screen lock</a></li>--%>
                                <li><a href="../LogOut.aspx"><i class="fa fa-key"></i>Logout</a></li>
                            </ul>
                        </li>
                    </ul>

                    <a onclick="PrintFrame();" class="btn print" title="Print Docs"><i class="fa fa-print"></i></a>&nbsp;
                    <a onclick="ExportToExcel();" class="btn printExcel" title="Export to Excel"><i class="fa fa-file-excel-o"></i></a>
                    <a onclick="ShowCalc();" class="btn calculator" title="Calculate Ex. Rate"><i class="fa fa-calculator"></i></a>
                </div>
                <!--/.nav-collapse -->
            </div>
            <!--/.container-fluid -->
            <!--top navigation-->
            <div class="clearfix">
            </div>
            <%--<a href="../Remit/Transaction/Restore/List.aspx" target="mainFrame">TEST MENU</a>--%>
            <!-- Static navbar -->
            <nav class="navbar navbar-default" role="navigation">
                <div class="container">
                    <div class="navbar-header">
                        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target=".menu" aria-expanded="false" aria-controls="navbar">
                            <span class="sr-only">Toggle navigation</span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>
                    </div>

                    <div id="menu" class="menu navbar-collapse collapse" runat="server">
                    </div>
                    <%--<ul>
                    <li><a href="#">Responsive<span class="caret"></span></a>
                        <ul>
                            <li id="Li1" runat="server"><a href="../Responsive/CustomerSetup/List.aspx" target="mainFrame">Customer Setup</a></li>
                            <li><a href="../Responsive/Send/SendV2.aspx" target="mainFrame">Send Transaction</a></li>
                            <li><a href="../Responsive/AdminPanel/SOAManage.aspx" target="mainFrame">SOA</a></li>
                            <li><a href="../Responsive/AdminPanel/TxnSummaryManage.aspx" target="mainFrame">Transaction Summary Report</a></li>
                        </ul>
                    </li>
                </ul>--%>
                </div>
                <!--/.container-fluid -->
            </nav>
        </nav>
        <div class="container-fluid">
            <div class="embed-responsive embed-responsive-16by9">
                <iframe class="embed-responsive-item" id="mainFrame" name="mainFrame" src="AgentMain.aspx" style="width: 100%;"></iframe>
            </div>
        </div>
        <div class="footer">
            <div class="container text-center">
                &copy; Copyright <%=DateTime.Now.ToString("yyyy") %>. <%= Swift.web.Library.GetStatic.ReadWebConfig("copyRightName","") %>
            </div>
        </div>
    </form>
</body>
</html>