<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Transaction.Restore.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../js/Swift_grid.js"></script>
    <script src="../../../js/functions.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                               <li><a href="#" onclick="return LoadModule('account')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Transaction</a></li>
                            <li class="active"><a href="List.aspx">Restore Details</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="report-tab">
                <!-- Nav tabs -->
                <%--<div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation" class="active"><a href="#list" aria-controls="home" role="tab"
                            data-toggle="tab">list</a></li>
                        <li><a href="Manage.aspx">Manage </a></li>
                        <%-- <li role="presentation"><a href="#Manage" aria-controls="profile" role="tab" data-toggle="tab"><a href="Manage.aspx">Manage</a>
                        </a></li>
                    </ul>
                </div>--%>
                <!-- Tab panes -->
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="list">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default ">
                                    <!-- Start .panel -->
                                    <div class="panel-heading">
                                        <h4 class="panel-title">Account Details</h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <div id="rpt_grid" runat="server" class="gridDiv">
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
    </form>
</body>
</html>
