<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.CurrencySetup.Manage" %>

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

  <%--  <script type="text/javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<%=IssueDate.ClientID%>", "#<%=ExpireDate.ClientID %>", 1);
        }
        LoadCalendars();
    </script>--%>
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
                            <li class="active"><a href="Manage.aspx">Currency Setup</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->

            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="deactive"><a href="List.aspx">Currency List </a></li>
                    <li role="presentation" class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">Manage Currency</a></li>
                </ul>
            </div>
            <div id="CurrencyCodeDiv" runat="server" visible="false">
                <label><span id="spnCname" runat="server"><%=GetCurrencyCode()%></span></label>
            </div>
            <div class="listtabs" id="pnl1" runat="server" visible="false">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="#" aria-controls="home" role="tab" data-toggle="tab">Currency Information </a></li>
                    <li role="presentation" class="deactive"><a href="PayoutRounding.aspx?currencyCode=<%=GetCurrCode() %>&currencyId=<%=GetId()%>">Payout Rounding</a></li>
                </ul>
            </div>
            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-7">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Currency Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <span class="errormsg">*</span> Fields are mandatory
                                    </div>
                                    <div class="panel panel-default ">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Currency Details</h4>
                                        </div>
                                        <div class="panel-body">
                                            <div class="row form-group">
                                                <div class="col-md-4">
                                                    <label>
                                                        Currency Code:
                                                            <span class="errormsg">*</span>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="currencyCode" ForeColor="Red"
                                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </label>
                                                    <asp:TextBox ID="currencyCode" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="col-md-4">
                                                    <label>
                                                        ISO Numeric:
                                                    </label>
                                                    <asp:TextBox ID="isoNumeric" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                            </div>

                                            <div class="row form-group">
                                                <div class="col-md-4">
                                                    <label>
                                                        Currency Name:<span class="errormsg">*</span>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currencyName" ForeColor="Red"
                                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </label>
                                                    <asp:TextBox ID="currencyName" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="col-md-4">
                                                    <label>
                                                        Currency Description:
                                                    </label>
                                                    <asp:TextBox ID="currencyDesc" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="col-md-4">
                                                    <label>
                                                        Currency Decimal Name:
                                                    </label>
                                                    <asp:TextBox ID="currencyDecimalName" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="row form-group">
                                                <div class="col-md-4">
                                                    <label>
                                                        After Decimal Count:
                                                    </label>
                                                    <asp:TextBox ID="countAfterDecimal" runat="server" CssClass="form-control"></asp:TextBox>
                                                    <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender1" runat="server" Enabled="True" FilterType="Numbers" TargetControlID="countAfterDecimal">
                                                    </cc1:FilteredTextBoxExtender>
                                                </div>
                                                <div class="col-md-4">
                                                    <label>
                                                        Decimal Digit Round:
                                                    </label>
                                                    <asp:TextBox ID="roundNoDecimal" runat="server" CssClass="form-control"></asp:TextBox>
                                                    <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender2" runat="server" Enabled="True" FilterType="Numbers" TargetControlID="roundNoDecimal">
                                                    </cc1:FilteredTextBoxExtender>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="panel panel-default ">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Rate Tolerance Setup Against <%=Swift.web.Library.GetStatic.ReadWebConfig("currencyUSA","") %></h4>
                                        </div>
                                        <div class="panel-body">
                                            <div class="row form-group">
                                                <div class="col-md-4">
                                                    <label>
                                                        Factor:
                                                    </label>
                                                    <asp:RadioButtonList ID="factor" runat="server">
                                                        <asp:ListItem Value="M" Selected="true">&nbsp;Multiplication</asp:ListItem>
                                                        <asp:ListItem Value="D">&nbsp;Division</asp:ListItem>
                                                    </asp:RadioButtonList>
                                                </div>
                                            </div>
                                            <div class="row form-group">
                                                <div class="col-md-4">
                                                    <label>
                                                        Rate Min:
                                                    </label>
                                                    <asp:TextBox ID="rateMin" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="col-md-4">
                                                    <label>
                                                        Rate Max:
                                                    </label>
                                                    <asp:TextBox ID="rateMax" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <asp:Button ID="btnSumit" runat="server" Text="Submit" CssClass="btn btn-primary" ValidationGroup="country" Display="Dynamic" OnClick="btnSumit_Click" />
                                        <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSumit">
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