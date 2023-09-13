<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AccountReport.AccountDetail.Manage" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <!-- Bootstrap Core CSS -->
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../ui/js/metisMenu.min.js"></script>
    <script src="../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="../../ui/js/custom.js"></script>
    <!--page plugins-->
    <script src="../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <%-- <script src="../../js/swift_calendar.js" type="text/javascript"></script>--%>
    <script type="text/javascript">
        function CheckFormValidation() {
            var reqField = "accNum,accName,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            GetElement("addNewAccount").click();
            return true;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Sub_Account </a></li>
                            <li class="active"><a href="Manage.aspx">Account Details</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="report-tab">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li><a href="List.aspx">List </a></li>
                        <li class="active" role="presentation"><a href="#Manage" aria-controls="profile" role="tab" data-toggle="tab">Manage</a></li>
                    </ul>
                </div>
                <!-- Tab panes -->
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane active" id="Manage">
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default ">
                                    <!-- Start .panel -->
                                    <div class="panel-heading">
                                        <h4 class="panel-title">
                                            <asp:Label ID="header" runat="server"></asp:Label>
                                        </h4>
                                        <div class="panel-actions">
                                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <div class="row">
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    GL Code:<span class="errormsg">*</span>
                                                </label>
                                                <asp:DropDownList ID="GLCode" runat="server" Width="100%" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="GLCode_SelectedIndexChanged">
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    AC Balance:</label>
                                                <asp:Label ID="acBalance" runat="server" Text="Label" Visible="false" Width="100%"></asp:Label>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    AC Num:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="accNum" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    AC Name:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="accName" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    AC Ownership:</label>
                                                <asp:DropDownList ID="accOwnership" runat="server" Width="100%" CssClass="form-control">
                                                    <asp:ListItem Value="o" Text="Office"></asp:ListItem>
                                                    <asp:ListItem Value="c" Text="Client"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    AC Reportcode:</label>
                                                <asp:TextBox ID="accReportCode" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Frez Ref Code:</label>
                                                <asp:DropDownList ID="frezRefCode" runat="server" Width="100%" CssClass="form-control">
                                                    <asp:ListItem Value="" Text="Open"></asp:ListItem>
                                                    <asp:ListItem Value="b" Text="Block"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Bank letter RefNo:</label>
                                                <asp:TextBox ID="accBankLetterRefNo" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    AC Cls Flag:</label>
                                                <asp:DropDownList ID="accClsFlag" runat="server" Width="100%" CssClass="form-control">
                                                    <asp:ListItem Value="y" Text="Open"></asp:ListItem>
                                                    <asp:ListItem Value="n" Text="Close"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Agent Name:</label>
                                                <uc1:SwiftTextBox ID="agentNameAC" runat="server" Category="partydetail" />
                                                <%--<asp:DropDownList ID="agentName" runat="server" Width="100%" CssClass="form-control">
                                                </asp:DropDownList>--%>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Llien Amount:</label>
                                                <asp:TextBox ID="lienAmt" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Lien Remarks:</label>
                                                <asp:TextBox ID="lienRemarks" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    System Reserved Amount:</label>
                                                <asp:TextBox ID="systemResAmt" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    System Reserved Remarks:</label>
                                                <asp:TextBox ID="systemResRem" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Dr Balance Limit:</label>
                                                <asp:TextBox ID="drBalLimit" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Limit Expiry:</label>
                                                <asp:TextBox ID="limitExp" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    AC Currency:</label>
                                                <asp:DropDownList ID="accCurrency" runat="server" Width="100%" CssClass="form-control">
                                                    <asp:ListItem Text="NPR" Value="NPR"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    AC Sub Group:</label>
                                                <asp:DropDownList ID="accSubGroup" runat="server" Width="100%" CssClass="form-control">
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="row" style="display: none;">
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    AC Group:</label>
                                                <asp:DropDownList ID="accGroup" runat="server" Width="100%" CssClass="form-control">
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                    Bill by Bill:</label>
                                                <asp:DropDownList ID="billByBill" runat="server" Width="100%" CssClass="form-control">
                                                    <asp:ListItem Value="n" Text="No"></asp:ListItem>
                                                    <asp:ListItem Value="y" Text="Yes"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-lg-2 col-md-4 form-group">
                                                <label class="control-label" for="">
                                                </label>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <input type="button" value="Add New Account" id="addNew" runat="server" class="btn btn-primary m-t-25"
                                                        onclick="CheckFormValidation();" />
                                                    <asp:Button ID="addNewAccount" runat="server" Text="Add New Account" OnClick="addNewAccount_Click"
                                                        Style="display: none" />
                                                    <input type="button" value="Update" class="btn btn-primary m-t-25" runat="server"
                                                        id="update" onclick="CheckFormValidation();" visible="false" />
                                                    <asp:Button ID="btnUpdate" runat="server" Text="Update" Style="display: none" OnClick="btnUpdate_Click" />
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
</body>
</html>