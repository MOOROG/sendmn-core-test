<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PayoutRounding.aspx.cs" Inherits="Swift.web.Remit.Administration.CurrencySetup.PayoutRounding" %>

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
    <script type="text/javascript">
            var gridName = "<% =GridName%>";

            function GridCallBack() {
                var id = GetRowId(gridName);

                if (id != "") {
                    GetElement("<% =btnEdit.ClientID%>").click();
                    GetElement("<% =btnSave.ClientID%>").disabled = false;
                } else {
                    GetElement("<% =btnSave.ClientID%>").disabled = true;
                    ResetForm();
                    ClearAll(gridName);
                }
            }

            function ResetForm() {
                SetValueById("<% =tranType.ClientID%>", "");
                SetValueById("<% =place.ClientID%>", "");
                SetValueById("<% =cDecimal.ClientID%>", "");
            }

            function NewRecord() {
                ResetForm();
                GetElement("<% =btnSave.ClientID%>").disabled = false;
                SetValueById("<% =countryCurrencyId.ClientID%>", "0");
                ClearAll(gridName);
            }
    </script>
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
                            <li class="active"><a href="PayoutRounding.aspx?currencyCode=<%=GetCurrCode() %>&currencyId=<%=GetId()%>">Currency Setup</a></li>
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
            <div>
                <label><span id="spnCname" runat="server"><%=GetCurrencyCode()%></span></label>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="deactive"><a href="Manage.aspx?currencyCode=<%=GetCurrCode() %>&currencyId=<%=GetCurrencyId()%>">Currency Information </a></li>
                    <li role="presentation" class="active"><a href="#list">Payout Rounding</a></li>
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
                                    <h4 class="panel-title">Payout Currency Rounding Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <asp:UpdatePanel ID="upnl1" runat="server">
                                        <ContentTemplate>
                                            <div class="form-group">
                                                <span class="errormsg">*</span> Fields are mandatory
                                            </div>
                                            <div class="row form-group">
                                                <div class="col-md-3">
                                                    <label>
                                                        Tran Type:<span class="errormsg">*</span>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="tranType" ForeColor="Red"
                                                            ValidationGroup="currency" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </label>
                                                    <asp:DropDownList ID="tranType" runat="server" CssClass="form-control"></asp:DropDownList>
                                                </div>
                                                <%-- </div>
                                            <div class="row form-group">--%>
                                                <div class="col-md-3">
                                                    <label>
                                                        Placing:
                                                    </label>
                                                    <asp:DropDownList ID="place" runat="server" CssClass="form-control" AutoPostBack="True" OnSelectedIndexChanged="place_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                                <%-- </div>
                                            <div class="row form-group">--%>
                                                <div class="col-md-3">
                                                    <label>
                                                        Decimal:
                                                    </label>
                                                    <asp:TextBox ID="cDecimal" runat="server" CssClass="form-control">0</asp:TextBox>
                                                </div>
                                                <%--</div>
                                            <div class="row form-group">--%>
                                                <div class="col-md-3">
                                                    <br />
                                                    <input type="button" value="New" onclick=" NewRecord(); " class="btn btn-primary" />
                                                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary" ValidationGroup="currency"
                                                        OnClick="btnSave_Click" />
                                                    <asp:Button ID="btnEdit" runat="server" Text="Edit" Style="display: none;"
                                                        OnClick="btnEdit_Click" />
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div id="rpt_grid" runat="server" class="gridDiv">
                                                </div>
                                            </div>

                                            <div class="form-group">
                                                <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                </cc1:ConfirmButtonExtender>
                                                &nbsp;
                                                <input id="btnBack" type="button" class="btn btn-primary" value="Back" onclick=" Javascript:history.back(); " />
                                                <asp:HiddenField ID="countryCurrencyId" runat="server" />
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
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/metisMenu.min.js"></script>
</body>
</html>