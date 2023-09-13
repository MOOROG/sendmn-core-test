<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Swift.web.Dashboard" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>FASTMoneyPro - Admin</title>
    <!-- Bootstrap -->
    <link href="ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <script type="text/javascript">
        function PrintFrame() {
            window.frames["mainFrame"].focus();
            window.frames["mainFrame"].print();
            //var prtContent = document.getElementById('printDiv');
            //var Print = window.open('', '', 'width=600px,height=500px,toolbar=0px,scrollbars=1,status=0px');
            //Print.document.write(prtContent.innerHTML);
            //Print.document.close();
            //Print.focus();
            //Print.print();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Static navbar -->
        <nav class="navbar navbar-inverse yamm navbar-fixed-top ">
            <div class="container">

                <div class="navbar-header">
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href="#"><img src="ui/images/logo.png" /></a>
                </div>
                <div id="navbar" class="navbar-collapse collapse">
                    <ul class="nav navbar-nav navbar-right navbar-top-drops">
                        <li class="dropdown"><a href="#" class="dropdown-toggle button-wave" data-toggle="dropdown"><i class="fa fa-envelope"></i> <span class="badge badge-xs badge-info">6</span></a>

                            <ul class="dropdown-menu dropdown-lg">
                                <li class="notify-title">
                                    3 New messages 
                                </li>
                                <li class="clearfix">
                                    <a href="#">
                                        <span class="pull-left">
                                            <img src="ui/images/avtar-2.jpg" alt="" class="img-circle" width="30">
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
                                            <img src="ui/images/avtar-2.jpg" alt="" class="img-circle" width="30">
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
                                            <img src="ui/images/avtar-3.jpg" alt="" class="img-circle" width="30">
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
                        </li>
                        <li class="dropdown"><a href="#" class="dropdown-toggle button-wave" data-toggle="dropdown"><i class="fa fa-bell"></i> <span class="badge badge-xs badge-warning">6</span></a>

                            <ul class="dropdown-menu dropdown-lg">
                                <li class="notify-title">
                                    3 New messages 
                                </li>
                                <li class="clearfix">
                                    <a href="#">
                                        <span class="pull-left">
                                            <i class="fa fa-envelope"></i>
                                        </span>

                                        <span class="media-body">
                                            15 New Messages
                                            <em>20 Minutes ago</em>
                                        </span>
                                    </a>
                                </li>
                                <li class="clearfix">
                                    <a href="#">
                                        <span class="pull-left">
                                            <i class="fa fa-twitter"></i>
                                        </span>

                                        <span class="media-body">
                                            13 New Followers
                                            <em>2 hours ago</em>
                                        </span>
                                    </a>
                                </li>
                                <li class="clearfix">
                                    <a href="#">
                                        <span class="pull-left">
                                            <i class="fa fa-download"></i>
                                        </span>

                                        <span class="media-body">
                                            Download complete
                                            <em>2 hours ago</em>
                                        </span>
                                    </a>
                                </li>
                                <li class="read-more"><a href="#">View All Alerts <i class="fa fa-angle-right"></i></a></li>
                            </ul>
                        </li>
                        <li class="dropdown profile-dropdown">
                            <a href="#" class="dropdown-toggle button-wave" data-toggle="dropdown" role="button" ><img src="ui/images/avtar-2.jpg" alt="" width="25">
                                <%=Swift.web.Library.GetStatic.GetUser() %>
                            </a>
                            <ul class="dropdown-menu">
                                <%--<li><a href="#"><i class="fa fa-user"></i>My Profile</a></li>
                                <li><a href="#"><i class="fa fa-calendar"></i>My Calendar</a></li>                         
                                <li><a href="#"><i class="fa fa-envelope"></i>My Inbox</a></li>
                                <li><a href="#"><i class="fa fa-barcode"></i>My Task</a></li>
                                <li class="divider"></li>
                                <li><a href="#"><i class="fa fa-lock"></i>Screen lock</a></li>--%>
                                <li><a href="LogOut.aspx"><i class="fa fa-key"></i>Logout</a></li>
                            </ul>
                        </li>
                    </ul>
                </div><!--/.nav-collapse -->
                <a onclick="PrintFrame();" class="btn btn-primary print"><i class="fa fa-print"></i></a>
            </div><!--/.container-fluid -->
       
    <!--top navigation-->
    <div class="clearfix">
    </div>
    <!-- Static navbar -->
    <nav class="navbar navbar-default">
            <div class="container">
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-main" aria-expanded="false" aria-controls="navbar">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                </div>
                <div id="menu" runat="server">
                <div id="navbar-main" class="navbar-collapse collapse">
                    <ul class="nav navbar-nav">
                        <li class="active"><a href="index.html">Dashboard</a></li>
						
						<li class="dropdown">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Administration  <span class="caret"></span></a>
                            <ul class="dropdown-menu">
                                <li class="dropdown-submenu">
                                    <a tabindex="-1" href="#">User Management</a>
                                   <!--  <ul class="dropdown-menu">
                                        <li><a href="#">Pay Transaction</a></li>
                                        <li><a href="#">Cancel Transaction</a></li>
                                        <li><a href="#">Modify Transaction</a></li>
                                        <li><a href="#">Approve Transaction</a></li>
                                        <li><a href="#">Block/Unblock Transaction</a></li>
                                    </ul> -->
                                </li>
                                <li class="dropdown-submenu">
                                    <a tabindex="-1" href="#">Applications Settings</a>
                                   <!--  <ul class="dropdown-menu">
                                        <li><a href="#">Transaction Report Master</a></li>
                                        <li><a href="#">Remittance Payble Report</a></li>
                                        <li><a href="#">Agent Balance Report</a></li>
                                        <li><a href="#">Agent Statement Report</a></li>
                                        <li><a href="#">Statement of Account</a></li>
                                    </ul> -->
                                </li>
                                <li class="dropdown-submenu"><a tabindex="-1" href="#">DC Management</a></li>
                                <li class="dropdown-submenu"><a tabindex="-1" href="#">Site Maintenance</a></li>
                                <li class="dropdown-submenu"><a tabindex="-1" href="#">Utilities</a></li>
                                <li class="dropdown-submenu"><a tabindex="-1" href="#">Administration</a></li>
                                
                               

                                </li>
                            </ul>
                        </li>
						<li class="dropdown">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Security <span class="caret"></span></a>
                            <ul class="dropdown-menu">
                                <li><a href="#">System security</a></li>
                                <li><a href="#">Sub menu 2</a></li>
                            </ul>
                        </li>
						<li class="dropdown">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Remittance <span class="caret"></span></a>
                            <ul class="dropdown-menu">
                                <li class="dropdown-submenu">
                                    <a tabindex="-1" href="#">Exchange Rate</a>
                                    <ul class="dropdown-menu">
                                        <li class="submenu"><a tabindex="-1" href="#">test</a></li>
                                    </ul>
                                </li>
                                <li class="dropdown-submenu"><a tabindex="-1" href="#">Service Charge and Commission</a></li>
                                <li class="dropdown-submenu"><a tabindex="-1" href="#">Credit Risk Management</a></li>
                                <li class="dropdown-submenu"><a tabindex="-1" href="#">Reports</a>
                                <li><a href="#">Transaction</a></li>
                                <li><a href="#">Reports</a></li>
                                <li><a href="#">Send Domestic</a></li>
                                <li><a href="#">Pay Domestic</a></li>
                            </ul>
                        </li>
						<li class="dropdown">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Account <span class="caret"></span></a>
                            <ul class="dropdown-menu">
                                <li><a href="#">Create Account</a></li>
                                <li><a href="#">Account Details</a></li>
                                <li><a href="BillVoucher/VoucherEntry/List.aspx"> Voucher Entry</a></li>
                                <li><a href="#">Remittance Voucher</a></li>
                                <li><a href="#">Report</a></li>
                                <li><a href="#">Balancesheet</a></li>
                                <li><a href="#">Trail Balance</a></li>
                                <li><a href="#">Voucher Report</a></li>
                                <li><a href="#">Daybook</a></li>
                                <li><a href="#">Profit and Loss</a></li>
                            </ul>
                        </li>
						<li class="dropdown">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Compliance <span class="caret"></span></a>
                            <ul class="dropdown-menu">
                                <li><a href="#">Compliance Rule Setup</a></li>
                                <li><a href="#">OFAC Management</a></li>
                            </ul>
                        </li>
		 
                         
                    </ul>
                   <!--  <ul class="nav navbar-nav navbar-right">

                        <li>
                            <form class="mainnav-form" role="search">
                                <input type="text" class="form-control input-md" placeholder="Search">
                                <button class="btn btn-sm mainnav-form-btn" type="button"><i class="fa fa-search"></i></button>
                            </form>
                        </li>
                    </ul> -->
                </div><!--/.nav-collapse -->
                </div>
            </div><!--/.container-fluid -->
    </nav>
  </nav>
        <div class="container" style="height: 1500px">
            <iframe id="mainFrame" name="mainFrame" runat="server" scrolling="auto" height="100%" width="100%" frameborder="0" src="front.aspx"></iframe>
        </div>
        <footer>
            <div class="container text-center">
                &copy; Copyright 2015. Sara. All right reserved.
            </div>
    </footer>
        <script type="text/javascript" src="ui/js/jquery.min.js"></script>
        <script type="text/javascript" src="ui/bootstrap/js/bootstrap.min.js"></script>
        <script src="ui/js/metisMenu.min.js"></script>
        <script src="ui/js/jquery-jvectormap-1.2.2.min.js"></script>
        <!-- Flot -->
        <script src="ui/js/jquery-jvectormap-world-mill-en.js"></script>
        <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
        <script type="text/javascript" src="ui/js/custom.js"></script>
        <script type="text/javascript">
            function SetMessageBox(msg, errorCode) {
                if (msg == "")
                    return;
                alert(msg);
                //if (errorCode == 0) {
                //    $.gritter.add({
                //        title: '<span style="color: green;">Success</span>',
                //        text: '<span style="color: green; font-size: 12px; font-weight: bold;">' + msg + '</span>',
                //        image: 'Images/success-icon.png',
                //        sticky: false,
                //        time: ''
                //    });
                //}
                //else if (errorCode == 1) {
                //    $.gritter.add({
                //        title: '<span style="color: red;">Error</span>',
                //        text: '<span style="color: red; font-size: 12px; font-weight: bold;">' + msg + '</span>',
                //        image: 'Images/error-icon.png',
                //        sticky: false,
                //        time: ''
                //    });
                //}
                //else if (errorCode == 2) {
                //    $.gritter.add({
                //        title: '<span style="color: black;">Agent</span>',
                //        text: '<span style="color: black; font-size: 11px; font-weight: bold;">' + msg + '</span>',
                //        image: false,
                //        sticky: true,
                //        time: ''
                //    });
                //}
                //else {
                //    $.gritter.add({
                //        title: '<span style="color: Orange;">Warning</span>',
                //        text: '<span style="color: black; font-size: 12px; font-weight: bold;">' + msg + '</span>',
                //        image: 'Images/warning-icon.png',
                //        sticky: true,
                //        time: ''
                //    });
                //}
            }

            $(function () {

                var barData = {
                    labels: ["January", "February", "March", "April", "May", "June", "July"],
                    datasets: [
                            {
                                label: "My First dataset",
                                fillColor: "rgba(220,220,220,0.5)",
                                strokeColor: "rgba(220,220,220,0.8)",
                                highlightFill: "rgba(220,220,220,0.75)",
                                highlightStroke: "rgba(220,220,220,1)",
                                data: [65, 59, 80, 81, 56, 55, 40]
                            },
                            {
                                label: "My Second dataset",
                                fillColor: "rgba(14, 150, 236,0.5)",
                                strokeColor: "rgba(14, 150, 236,0.8)",
                                highlightFill: "rgba(14, 150, 236,0.75)",
                                highlightStroke: "rgba(14, 150, 236,1)",
                                data: [28, 48, 40, 19, 86, 27, 90]
                            }
                    ]
                };

                var barOptions = {
                    scaleBeginAtZero: true,
                    scaleShowGridLines: true,
                    scaleGridLineColor: "rgba(0,0,0,.05)",
                    scaleGridLineWidth: 1,
                    barShowStroke: true,
                    barStrokeWidth: 2,
                    barValueSpacing: 5,
                    barDatasetSpacing: 1,
                    responsive: true
                };
            });
        </script>
    </form>
</body>
</html>
