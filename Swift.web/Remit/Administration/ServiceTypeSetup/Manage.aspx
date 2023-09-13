<%@ Page ValidateRequest="false" Title="" Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.ServiceTypeSetup.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Sub_Administration</a></li>
                            <li class="active"><a href="List.aspx">Service Type Setup</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->

            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a href="List.aspx">Service Type List </a></li>
                    <li class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">Manage Service Type</a></li>
                </ul>
            </div>
            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="Manage">
                    <!--end .row-->
                    <div class="row">
                        <div class="col-md-6">
                            <div class="panel panel-default">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Service Type Details
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="col-md-12 form-group">
                                        <asp:Label ID="lblMsg" Font-Bold="true" runat="server" Text=""></asp:Label>
                                    </div>
                                    <div class="col-md-12 form-group">
                                        <label class="control-label" for="">
                                            Service Code:<span class="errormsg">*</span>
                                            <asp:RequiredFieldValidator
                                                ID="RequiredFieldValidator1" runat="server" ControlToValidate="serviceCode" ForeColor="Red"
                                                Display="Dynamic" ErrorMessage="Required!" SetFocusOnError="True" ValidationGroup="servicetype">
                                            </asp:RequiredFieldValidator>
                                        </label>
                                        <asp:TextBox ID="serviceCode" runat="server" CssClass="form-control" TabIndex="1"></asp:TextBox>
                                    </div>
                                    <div class="col-md-12 form-group">
                                        <label class="control-label" for="">
                                            Service Type Title:<span class="errormsg">*</span>
                                            <asp:RequiredFieldValidator
                                                ID="RequiredFieldValidator14" runat="server" ControlToValidate="typeTitle" ForeColor="Red"
                                                Display="Dynamic" ErrorMessage="Required!" SetFocusOnError="True" ValidationGroup="servicetype">
                                            </asp:RequiredFieldValidator>
                                        </label>
                                        <asp:TextBox ID="typeTitle" runat="server" CssClass="form-control" TabIndex="2">
                                        </asp:TextBox>
                                    </div>
                                    <div class="col-md-12 form-group">
                                        <label class="control-label" for="">
                                            Service Type Description:<span class="errormsg">*</span>
                                            <asp:RequiredFieldValidator
                                                ID="RequiredFieldValidator2" runat="server" ControlToValidate="typeDesc" ForeColor="Red"
                                                Display="Dynamic" ErrorMessage="Required!" SetFocusOnError="True" ValidationGroup="servicetype">
                                            </asp:RequiredFieldValidator>
                                        </label>
                                        <asp:TextBox ID="typeDesc" runat="server" TextMode="MultiLine" CssClass="form-control" TabIndex="3"></asp:TextBox>
                                    </div>
                                    <div class="col-md-12 form-group">
                                        <label class="control-label" for="">
                                            Is Active:
                                        </label>
                                        <asp:DropDownList ID="isActive" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="Y" Selected="True">Yes</asp:ListItem>
                                            <asp:ListItem Value="N">No</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-12 form-group">
                                        <asp:Button ID="bntSubmit" runat="server" Text="Submit" CssClass="btn btn-primary" ValidationGroup="servicetype" TabIndex="4" OnClick="bntSubmit_Click" />
                                        <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender2" runat="server"
                                            ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="bntSubmit">
                                        </cc1:ConfirmButtonExtender>
                                        &nbsp;

                                        <input id="btnBack" type="button" class="btn btn-primary" value="Back" onclick=" Javascript: history.back(); " />
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