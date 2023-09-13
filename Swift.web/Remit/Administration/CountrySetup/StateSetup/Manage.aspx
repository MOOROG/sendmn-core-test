<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.CountrySetup.StateSetup.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
<script src="../../../../js/functions.js" type="text/javascript"> </script>

<!-- Bootstrap -->
<link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
<!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
<link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
<link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
<link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
<!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Sub_Administration</a></li>
                            <li class="active"><a href="manage.aspx">Country Setup</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->

            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="deactive"><a href="List.aspx">Country List </a></li>
                    <li role="presentation" class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">Manage Country</a></li>
                </ul>
            </div>
            <div>
                <label><span id="spnCname" runat="server"><%=GetCountryName()%></span></label>
            </div>
            <div id="divTab" runat="server">
            </div>
            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">State Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><%--<a href="#"
                                            class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label><span class="errormsg">*</span> Fields are mandatory</label>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            State Code:
                                        </label>
                                        <asp:TextBox ID="stateCode" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            State Name:
                                             <span class="errormsg">*</span><asp:RequiredFieldValidator ID="RequiredFieldValidator1"
                                                 runat="server" ControlToValidate="stateName" ValidationGroup="static" ErrorMessage="Required!" Display="Dynamic" ForeColor="Red">
                                             </asp:RequiredFieldValidator>
                                        </label>
                                        <asp:TextBox ID="stateName" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="static" OnClick="btnSave_Click" CssClass="btn btn-primary" TabIndex="5" />
                                        <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                            ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                        </cc1:ConfirmButtonExtender>
                                        &nbsp;
                                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-primary" TabIndex="6" OnClick="btnDelete_Click" />
                                        <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
                                            ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                        </cc1:ConfirmButtonExtender>
                                        &nbsp;
                                        <input id="btnBack" type="button" value="Back" class="btn btn-primary" onclick=" Javascript: history.back(); " />
                                    </div>
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
    <script type="text/javascript" src="../../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../../../../ui/js/metisMenu.min.js"></script>
</body>
</html>