<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddGL.aspx.cs" Inherits="Swift.web.include.AddGL" %>

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
                            <li class="active"><a href="#"><span id="breadCrumb" runat="server"></span>
                            </a></li>
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
                                <div id="frmTitle" runat="server">
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
                                    <asp:Label ID="GLCode" runat="server" CssClass="form-control"></asp:Label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Description:<span class="errormsg">*</span>
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="description" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Account Prefix:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:TextBox ID="accountPrifix" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    GL Map:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="GLMap" runat="server" Enabled="false" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Condition:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="ConditionDDl" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="B" Text="Both"></asp:ListItem>
                                        <asp:ListItem Value="D" Text="DR"></asp:ListItem>
                                        <asp:ListItem Value="C" Text="Cr"></asp:ListItem>
                                        <asp:ListItem Value="N" Text="None"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-4 col-md-offset-3">
                                    <asp:Button ID="addNewGL" CssClass="btn btn-primary m-t-25" runat="server" Text="Add New GL"
                                        OnClick="addNewGL_Click" />
                                    <asp:Button ID="btnUpdate" CssClass="btn btn-primary m-t-25" runat="server" Text="Update"
                                        OnClick="btnUpdate_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <span style="display: none" id="spn_acnum"></span>
        </div>
    </form>
</body>
</html>