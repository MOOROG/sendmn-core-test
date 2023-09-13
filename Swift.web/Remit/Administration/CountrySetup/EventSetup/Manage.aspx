<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.CountrySetup.EventSetup.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
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
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Sub_Administration</a></li>
                            <li class="active"><a href="Manage.aspx">Country Setup</a></li>
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
                                    <h4 class="panel-title">Event Setup</h4>
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
                                            Event Date:
                                            <span class="errormsg">*</span>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="eventDate" ForeColor="Red"
                                                ValidationGroup="event" Display="Dynamic" SetFocusOnError="True" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                            <asp:RangeValidator ID="RangeValidator1" runat="server"
                                                ControlToValidate="eventDate"
                                                MaximumValue="12/31/2100"
                                                MinimumValue="01/01/1900"
                                                Type="Date"
                                                ErrorMessage="* Invalid date"
                                                ValidationGroup="soa"
                                                CssClass="errormsg"
                                                SetFocusOnError="true"
                                                Display="Dynamic"> </asp:RangeValidator>
                                            <cc1:CalendarExtender ID="CalendarExtender1" TargetControlID="eventDate" CssClass="cal_Theme1" runat="server"></cc1:CalendarExtender>
                                        </label>
                                        <asp:TextBox ID="eventDate" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            Event Name:
                                             <span class="errormsg">*</span><asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="eventName" ForeColor="Red"
                                                 ValidationGroup="event" Display="Dynamic" SetFocusOnError="True" ErrorMessage="Required!">
                                             </asp:RequiredFieldValidator>
                                        </label>
                                        <asp:TextBox ID="eventName" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            Event Description:
                                        </label>
                                        <asp:TextBox ID="eventDesc" runat="server" CssClass="form-control" TextMode="MultiLine"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <asp:Button ID="btnSumit" runat="server" Text="Submit" CssClass="btn btn-primary" ValidationGroup="event" Display="Dynamic" TabIndex="16" OnClick="btnSumit_Click" />
                                        <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                            ConfirmText="Confirm To Save ?" Enabled="True"
                                            TargetControlID="btnSumit">
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