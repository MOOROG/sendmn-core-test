<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.CountrySetup.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>

    <!-- Bootstrap -->
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
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
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Sub_Administration</a></li>
                            <li class="active"><a href="List.aspx">Country Setup</a></li>
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
            <div id="CountryNameDiv" runat="server" visible="false">
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
                                    <h4 class="panel-title">Country Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><%--<a href="#"
                                            class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label>
                                            Country Code:
                                            <span class="errormsg">*</span>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="countryCode" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </label>
                                        <asp:TextBox ID="countryCode" runat="server" CssClass="form-control" MaxLength="2"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            Country Name:
                                            <span class="errormsg">*</span>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="countryName" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </label>
                                        <asp:TextBox ID="countryName" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            ISO Aplha3:
                                        </label>
                                        <asp:TextBox ID="isoAlpha3" runat="server" CssClass="form-control" MaxLength="3"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            IOC Olympic:
                                        </label>
                                        <asp:TextBox ID="iocOlympic" runat="server" CssClass="form-control" MaxLength="3"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            ISO Numeric:
                                        </label>
                                        <asp:TextBox ID="isoNumeric" runat="server" CssClass="form-control" MaxLength="5"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            IS Operative Country:
                                        </label>
                                        <asp:DropDownList ID="isOperativeCountry" runat="server" AutoPostBack="true" CssClass="form-control"
                                            OnSelectedIndexChanged="isOperativeCountry_SelectedIndexChanged">
                                            <asp:ListItem Value="Y">Yes</asp:ListItem>
                                            <asp:ListItem Value="N" Selected="True">No</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div runat="server" id="opTypePanel" visible="False" class="form-group">
                                        <label>
                                            Operation Type:
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="operationType" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </label>
                                        <asp:DropDownList ID="operationType" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="" Selected="True"> Select</asp:ListItem>
                                            <asp:ListItem Value="S">Send</asp:ListItem>
                                            <asp:ListItem Value="R">Receive</asp:ListItem>
                                            <asp:ListItem Value="B">Both</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            FATF Rating:
                                        </label>
                                        <asp:TextBox ID="fatfRating" runat="server" CssClass="form-control" MaxLength="3"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            Time Zone:
                                        </label>
                                        <asp:DropDownList ID="timeZone" runat="server" CssClass="form-control">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            Agent Operation Control Type:
                                        </label>
                                        <asp:DropDownList ID="agentOperationControlType" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="" Selected="True">Select</asp:ListItem>
                                            <asp:ListItem Value="HAC">Hide for AC</asp:ListItem>
                                            <asp:ListItem Value="HBD">Hide for Bank Deposit</asp:ListItem>
                                            <asp:ListItem Value="HAL">Hide for ALL</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div runat="server" id="routingAget" visible="false" class="form-group">
                                        <label>
                                            Default Routing Agent:
                                        </label>
                                        <asp:DropDownList ID="defRoutingAgent" runat="server" CssClass="form-control">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            Country Mobile Code:
                                        </label>
                                        <asp:TextBox ID="countryMobCode" runat="server" CssClass="form-control" MaxLength="10"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label>
                                            Country Mobile Length:
                                        </label>
                                        <asp:TextBox ID="countryMobLength" runat="server" CssClass="form-control" MaxLength="10"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <asp:Button ID="btnSumit" runat="server" Text="Submit" CssClass="btn btn-primary" ValidationGroup="country" Display="Dynamic" TabIndex="16" OnClick="btnSumit_Click" />
                                        <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                            ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSumit">
                                        </cc1:ConfirmButtonExtender>
                                        &nbsp;

                                            <input id="btnBack" type="button" class="btn btn-primary" value="Back" onclick=" Javascript: history.back(); " />
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
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/metisMenu.min.js"></script>
</body>
</html>