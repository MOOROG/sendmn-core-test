<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.APILocationMapping.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
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
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
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
                    <li role="presentation" class="deactive"><a href="List.aspx">API Location List </a></li>
                    <li role="presentation" class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">Location District Map</a></li>
                </ul>
            </div>
            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Location Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><%--<a href="#"
                                            class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                                        <ContentTemplate>
                                            <div runat="server" class="form-group">
                                                <label>
                                                    District Code:<span class="errormsg">*</span>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2"
                                                        runat="server" ControlToValidate="districtCode" ValidationGroup="static" ErrorMessage="Required!" Display="Dynamic" ForeColor="Red">
                                                    </asp:RequiredFieldValidator>
                                                </label>
                                                <asp:TextBox ID="districtCode" runat="server" CssClass="form-control">
                                                </asp:TextBox>
                                            </div>
                                            <div class="form-group">
                                                <label>
                                                    District Name:<span class="errormsg">*</span>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1"
                                                        runat="server" ControlToValidate="districtName" ValidationGroup="static" ErrorMessage="Required!" Display="Dynamic" ForeColor="Red">
                                                    </asp:RequiredFieldValidator>
                                                </label>
                                                <asp:TextBox ID="districtName" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="form-group">
                                                <label>
                                                    Is Active:
                                                </label>
                                                </td>
                                                <asp:DropDownList ID="isActive" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                    <asp:ListItem Value="N">No</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                            <div class="form-group">
                                                <asp:Button ID="btnSumit" runat="server" Text="Submit" ValidationGroup="static" OnClick="btnSumit_Click" CssClass="btn btn-primary" TabIndex="5" />
                                                <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                    ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSumit">
                                                </cc1:ConfirmButtonExtender>
                                                &nbsp;
                                    <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-danger" TabIndex="6" OnClick="btnDelete_Click" />
                                                <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
                                                    ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                                </cc1:ConfirmButtonExtender>
                                                &nbsp; 
                                    <input id="btnBack" type="button" class="btn btn-primary" value="Back" onclick=" Javascript: history.back(); " />
                                            </div>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>

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
    </form>
</body>
</html>
