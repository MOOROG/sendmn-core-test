<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.CustomerRefund.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-md-offset-1 col-md-10">
                    <div class="tab-content">
                        <div role="tabpanel" class="tab-pane active" id="list">
                            <div class="row">
                                <div class="col-sm-12">
                                    <div class="page-title">
                                        <h1></h1>
                                        <ol class="breadcrumb">
                                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                            <li><a href="#">Remit </a></li>
                                            <li><a href="#">Customer Refund</a></li>
                                        </ol>
                                    </div>
                                </div>
                            </div>
                            <div class="report-tab" runat="server" id="regUp">
                                <!-- Nav tabs -->
                                <div class="listtabs">
                                    <ul class="nav nav-tabs" role="tablist">
                                        <li class="active" role="presentation"><a href="List.aspx">Customer Refund List</a></li>
                                        <li role="presentation"><a href="Manage.aspx">Manage Customer Refund</a></li>
                                    </ul>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="panel panel-default ">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Customer Refund Details</h4>
                                            <div class="panel-actions">
                                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                            </div>
                                        </div>
                                        <div class="panel-body">
                                            <div id="rpt_grid" runat="server"></div>
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
</body>
</html>