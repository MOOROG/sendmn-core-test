<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddNewAc.aspx.cs" Inherits="Swift.web.include.AddNewAc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
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
    <script src="../ajax_func.js" type="text/javascript"></script>
    <script src="../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript">
        function LoadCalendars() {
            ShowCalFromTo("#<% =limitExp.ClientID %>", 1);
        }
        LoadCalendars();
    </script>
    <style>
        body {
            margin-top: -80px !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>Create Account <small></small>
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="#"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Account</a></li>
                            <li class="active"><a href="#">
                                <span class="breadCrumb" id="breadCrumb" runat="server"></span></a>
                            </li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4>
                                <div runat="server" id="frmTitle">
                                </div>
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                <%-- <a href="#" class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    GL Code:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="GLCode" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    AC Balance:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:Label ID="acBalance" runat="server" Text="Label" Visible="false"></asp:Label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    AC Num: <span class="errormsg">*</span>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="accNum" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    AC Name: <span class="errormsg">*</span>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="accName" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group" style="display: none">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    AC Ownership:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="accOwnership" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="o" Text="Office"></asp:ListItem>
                                        <asp:ListItem Value="c" Text="Client"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    AC Reportcode:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="accReportCode" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group" style="display: none">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Bank letter RefNo:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="accBankLetterRefNo" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Agent Name:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="agentName" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group" style="display: none">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Llien Amt:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="lienAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                    NUMBER
                                </div>
                            </div>
                            <div class="form-group" style="display: none">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Lien Remarks:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="lienRemarks" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group" style="display: none">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    System Reserved Amt:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="systemResAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                    NUMBER
                                </div>
                            </div>
                            <div class="form-group" style="display: none">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    System Reserved Remarks:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="systemResRem" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group" style="display: none">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Dr Balance Limit:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="drBalLimit" runat="server" CssClass="form-control"></asp:TextBox>
                                    NUMBER
                                </div>
                            </div>
                            <div class="form-group" style="display: none">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Limit Expiry:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="limitExp" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    AC Currency: <span class="errormsg">*</span>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="accCurrency" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group" style="display: none">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    AC Sub Group:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="accSubGroup" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group" style="display: none">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    AC Group:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="accGroup" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div id="populate" runat="server" visible="false">
                                <div class="form-group">
                                    <label class="col-lg-2 col-md-3 control-label" for="">
                                        Created By:
                                    </label>
                                    <div class="col-lg-10 col-md-9">
                                        <asp:Label ID="createdBy" runat="server" CssClass="form-control"></asp:Label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-2 col-md-3 control-label" for="">
                                        Created Date:
                                    </label>
                                    <div class="col-lg-10 col-md-9">
                                        <asp:Label ID="createdDate" runat="server" CssClass="form-control"></asp:Label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-2 col-md-3 control-label" for="">
                                        Modified By:
                                    </label>
                                    <div class="col-lg-10 col-md-9">
                                        <asp:Label ID="modifiedBy" runat="server" CssClass="form-control"></asp:Label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-2 col-md-3 control-label" for="">
                                        Modified Date:
                                    </label>
                                    <div class="col-lg-10 col-md-9">
                                        <asp:Label ID="modifiedDate" runat="server" CssClass="form-control"></asp:Label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-4 col-md-offset-3">
                                    <asp:Button ID="addNewAccount" runat="server" OnClientClick="return CheckFormValidation();" CssClass="btn btn-primary m-t-25" Text="Add New Account"
                                        OnClick="addNewAccount_Click" Style="display: block" />
                                    <asp:Button ID="btnUpdate" runat="server" OnClientClick="return CheckFormValidation1();" CssClass="btn btn-primary m-t-25" Text="Update"
                                        OnClick="btnUpdate_Click" />
                                </div>
                            </div>
                            <span style="display: none" id="spn_acnum"></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script type="text/javascript">
        function CheckFormValidation() {
            var reqField = "GLCode,accNum,accName,accCurrency,";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
        }
        function CheckFormValidation1() {
            var reqField = "accNum,accName,accCurrency,";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
        }
    </script>
</body>
</html>