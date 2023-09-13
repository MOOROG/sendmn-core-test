<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentGroupSetup.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>

    <!-- Bootstrap -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Sub_Administration</a></li>
                            <li class="active"><a href="List.aspx">Agent and Group Mapping </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->

            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">Agent Group List</a></li>
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
                                    <h4 class="panel-title">Agent Group List</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><%--<a href="#"
                                            class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <asp:UpdatePanel ID="upnl1" runat="server">
                                        <ContentTemplate>

                                            <div class="form-group">
                                                <label class="col-lg-2 col-md-3 control-label" for="">
                                                    Group Category:
                                                </label>
                                                <div class="col-lg-10 col-md-9">
                                                    <asp:DropDownList ID="groupCat" runat="server" AutoPostBack="true" CssClass="form-control"
                                                        OnSelectedIndexChanged="groupCat_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-lg-2 col-md-3 control-label" for="">
                                                    Group Detail:
                                                </label>
                                                <div class="col-lg-10 col-md-9">
                                                    <asp:DropDownList ID="groupDetail" runat="server" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-lg-2 col-md-3 control-label" for="">
                                                    Agent Name:
                                                </label>
                                                <div class="col-lg-10 col-md-9">
                                                    <asp:TextBox ID="agentName" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="row form-group">
                                                <div class="col-md-2 col-md-offset-2">
                                                    <asp:Button ID="btnFilter" runat="server" CssClass="btn btn-primary" ValidationGroup="location"
                                                        OnClick="btnFilter_Click" Text="Filter" />
                                                </div>
                                            </div>
                                        </ContentTemplate>
                                        <Triggers>
                                            <asp:PostBackTrigger ControlID="btnFilter" />
                                        </Triggers>
                                    </asp:UpdatePanel>
                                </div>
                            </div>
                            <!-- End .panel -->
                        </div>
                        <!--end .col-->
                    </div>
                    <!--end .row-->
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <div id="rpt_grid" runat="server" class="gridDiv">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <%--<div role="tabpanel" class="tab-pane active" id="list2">
                </div>--%>
            </div>
        </div>
    </form>
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/metisMenu.min.js"></script>
</body>
</html>