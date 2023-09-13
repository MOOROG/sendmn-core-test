<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.APILocationMapping.List" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <script src="../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/functions.js" type="text/javascript"> </script>

    <!-- Bootstrap -->
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body >
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
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Sub_Administration</a></li>
                            <li class="active"><a href="List.aspx">API Location Mapper</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->

            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li id="countryListTab" runat="server" role="presentation" class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">API Location List </a></li>
                </ul>
            </div>
            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <!--end .row-->
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <%--<asp:Button ID="btnImportLoc" runat="server" Text="Import Location" 
                                            CssClass="button" Style="margin-left: 50px;" onclick="btnImportLoc_Click" />--%>
                                    <div id = "rpt_grid" runat = "server" class = "gridDiv"></div>
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
</body>
</html>