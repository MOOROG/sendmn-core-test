<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Swift.web.Admin.Dashboard" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title><%=Swift.web.Library.GetStatic.ReadWebConfig("companyName","") %> - Admin</title>
    <!-- Bootstrap -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!-- <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/menu1.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />

    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <link rel="icon" type="image/ico" sizes="32x32" href="/ui/index/images/favicon.ico">
    <script src="/ui/js/metisMenu.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>

    <link href="/ui/css/red.css" type="text/css" rel="stylesheet" />
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <style>
        /*.dropdown-menu {
     background-color: rgb(181, 0, 0) !important;
    }*/

        .dropdown-lg li.notify-title {
            background-color: rgb(19, 6, 6) !important;
            color: rgb(255, 255, 255) !important;
        }

        .dropdown-lg li a {
            color: #fff !important;
        }

            .dropdown-lg li a :hover {
                color: rgb(19, 6, 6) !important;
            }

        element.style {
            color: #FFEB3B !important;
        }

        .fa .fa-bell {
            color: #FFEB3B !important;
        }

        .badge-warning {
            background-color: rgb(19, 6, 6) !important;
        }

        .badge-info {
            background-color: rgb(19, 6, 6) !important;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#btnIAgree').on("click", function () {
                $('#mainFrame').contents().find('input[name=agreement]').prop("checked", true);
                 $('#mainFrame').contents().find('#register').removeAttr('disabled');
            });
        });

        function resizeIframe() {
        }
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
        function CallBackAutocomplete(id) {
            var url = $("#searchMenu_aValue").val();
            window.open(url, "mainFrame");
        }

        function GetUsers() {
            var user = "<%=getUser1() %>";
            return user;
        }
        function ExportToExcel() {

            var prtContent = document.getElementById('mainFrame');
            var html = prtContent.contentWindow.document.getElementById("main").innerHTML;
            //alert(html);
            if (prtContent == null || prtContent == "" || prtContent == undefined) {
                return false;
            }
            window.open('data:application/vnd.ms-excel,' + encodeURIComponent(html));
        }
        function RefreshChildPage() {
            var url = window.frames["mainFrame"].location;
            window.open(url, "mainFrame");
        }

        function AgreementModalPopup() {
            $("#btnmodalPopUP").click();
        }

      //notification part
      var notification;
      $(document).ready(function () {
        setInterval(function () {
          getErrorTrx();
        }, 30000);
      });

      function createNotification(data) {

        var options = {
          body: data,
          vibrate: true
        };

        notification = new Notification("Алдаатай гүйлгээ үүссэн байна", options);
      }

      function notifyMe(data) {
        if (!("Notification" in window)) {
          //alert("This browser does not support desktop notification");
        }
        else if (Notification.permission === "granted") {
          createNotification(data);
        }
        else if (Notification.permission !== 'denied') {
          Notification.requestPermission(function (permission) {
            if (!('permission' in Notification)) {
              Notification.permission = permission;
            }
            if (permission === 'granted') {

              createNotification();
            }
          });
        }
      }

      function getErrorTrx() {
        $.ajax({
          type: "POST",
          contentType: "application/json; charset=utf-8",
          url: "../Autocomplete.asmx/GetErrorTransactionList",
          data: "",
          dataType: "json",
          success: function (data) {
            if (data.d != "") {
              notifyMe(data.d);
            }
          },
          error: function (result) {
            alert("Due to unexpected errors we were unable to load data");
          }
        });
      }

    </script>
    <style type="text/css">
        .ui-widget-content {
            z-index: 9999 !important;
            position: fixed !important;
        }

        .modal-content {
            margin-top: 110px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Static navbar -->
        <nav class="navbar navbar-inverse yamm navbar-fixed-top ">
            <div class="container-fluid">
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href="#">
                        <img src="../ui/images/jme.png" /></a>
                </div>
                <div id="navbar" class="navbar-collapse collapse">
                    <ul class="nav navbar-nav navbar-right navbar-top-drops">
                        <li class="search-info">
                            <uc1:SwiftTextBox ID="searchMenu" runat="server" Category="remit-menuSearchAdmin" CssClass="form-control" Param1="@GetUsers()" Title="Blank for All" />
                        </li>
                        <%--<li class="dropdown"><a href="#" class="dropdown-toggle button-wave" data-toggle="dropdown"><i class="fa fa-envelope"></i> <span class="badge badge-xs badge-info">6</span></a>

                           <ul class="dropdown-menu dropdown-lg">
                                <li class="notify-title">
                                    3 New messages
                                </li>
                                <li class="clearfix">
                                    <a href="#">
                                        <span class="pull-left">
                                            <img src="../ui/images/avtar-2.jpg" alt="" class="img-circle" width="30">
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
                                            <img src="../ui/images/avtar-2.jpg" alt="" class="img-circle" width="30">
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
                                            <img src="../ui/images/avtar-3.jpg" alt="" class="img-circle" width="30">
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
                        <li class="dropdown"><a href="#" class="dropdown-toggle button-wave" data-toggle="dropdown">
                            <i class="fa fa-bell"></i>
                            <span class="badge badge-xs badge-warning">
                                <asp:Label ID="count" Text="0" runat="server"></asp:Label>
                            </span></a>

                            <ul class="dropdown-menu dropdown-lg" id="notification" runat="server">
                                <li class="notify-title">0 New messages
                                </li>
                                <%--<li class="read-more"><a href="#">View All Alerts <i class="fa fa-angle-right"></i></a></li>--%>
                            </ul>
                        </li>
                        <li class="dropdown profile-dropdown">
                            <a href="#" class="dropdown-toggle button-wave" data-toggle="dropdown" role="button">
                                <img src="../ui/images/avtar-2.jpg" alt="" width="30" style="background-color: rgb(255, 255, 255);">
                                <%=Swift.web.Library.GetStatic.GetUser() %>
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
                    <a href="javascript:void(0);" onclick="RefreshChildPage();" target="_self" class="btn calculator" title="Refresh Draw"><i class="fa fa-refresh"></i></a>
                </div>
                <!--/.nav-collapse -->
            </div>
            <!--/.container-fluid -->
            <!--top navigation-->
            <div class="clearfix">
            </div>
            <%--<a href="../Remit/Transaction/Restore/List.aspx" target="mainFrame">TEST MENU</a>--%>
            <!-- Static navbar -->
            <nav class="navbar navbar-default">
                <div class="container-fluid">
                    <div class="navbar-header">
                        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-main" aria-expanded="false" aria-controls="navbar">
                            <span class="sr-only">Toggle navigation</span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>
                    </div>
                    <div id="menu" runat="server">
                        <div id="navbar-main" class="menu navbar-collapse collapse">
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
                                        <li class="dropdown-submenu"><a tabindex="-1" href="#">Reports</a></li>
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
                                        <li><a href="BillVoucher/VoucherEntry/List.aspx">Voucher Entry</a></li>
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
                        </div>
                        <!--/.nav-collapse -->
                    </div>
                </div>
                <!--/.container-fluid -->
            </nav>
        </nav>

        <div class="container-fluid" style="height: calc(100vh - 135px); overflow-x: hidden; margin-top: 100px; overflow-y: hidden">
            <iframe id="mainFrame" name="mainFrame" scrolling="auto" height="100%" style="width: 100% !important" frameborder="0" src="../Front.aspx" onload="ParentScrollTop();"></iframe>
            <!--Terms Modal -->

        </div>

        <footer>
            <div class="container-fluid text-center">
                <p style="color:#FFF;text-align:center;background-color:#00c864"><%=DateTime.Today.ToString("yyyy") %> © <%= Swift.web.Library.GetStatic.ReadWebConfig("copyRightName","") %>. All rights Reserved.</p>
            </div>
        </footer>

        <script type="text/javascript">
            function ParentScrollTop() {
                $("html,body").animate({ scrollTop: 0 }, 100);
            }
            function SetMessageBox(msg, errorCode) {
                if (msg == "")
                    return;
                alert(msg);

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
