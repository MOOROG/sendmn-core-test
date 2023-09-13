<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.GroupLocationMap.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />

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
        <asp:ScriptManager ID="sc" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Sub_Administration</a></li>
                            <li class="active"><a href="List.aspx">Location and Group Mapping </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->

            <!-- Nav tabs -->
            <div class="report-tab">
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li id="agentGroupTab" runat="server" role="presentation" class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">Location Group List </a></li>
                        <li id="locationListTab" runat="server"></li>
                    </ul>
                </div>
                <!-- Tab panes -->
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="list">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default recent-activites">
                                    <!-- Start .panel -->
                                    <div class="panel-heading">
                                        <h4 class="panel-title">Location Group List</h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <asp:UpdatePanel ID="upnl1" runat="server">
                                            <ContentTemplate>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        Group Detail:
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
                                                            ErrorMessage="*" ForeColor="Red" ControlToValidate="groupDetail" ValidationGroup="location">
                                                        </asp:RequiredFieldValidator>
                                                    </label>
                                                    <div class="col-lg-6 col-md-6">
                                                        <asp:DropDownList ID="groupDetail" runat="server" AutoPostBack="true" CssClass="form-control"
                                                            OnSelectedIndexChanged="groupDetail_SelectedIndexChanged">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
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
                                        <div class="row">
                                            <div class="col-md-12">
                                                <div id="div_btn" runat="server" visible="false" style="margin-left: 50px;">
                                                    <asp:Button ID="btnAdd" Text="Add Selected" runat="server"
                                                        CssClass="btn btn-primary" OnClick="btnAdd_Click" />
                                                </div>
                                            </div>
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
</body>
</html>

<script>
    $("#btnFilter").click(function () {
        var group = $("#groupDetail").val();
        if (group == "") {
            alert("Please select group detail...")
        }
    });
</script>