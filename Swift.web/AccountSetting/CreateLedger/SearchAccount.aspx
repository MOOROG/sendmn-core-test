<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SearchAccount.aspx.cs"
    Inherits="Swift.web.AccountSetting.CreateLedger.SearchAccount" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
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
    <script src="../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../ajax_func.js" type="text/javascript"></script>
    <script language="javascript" type="text/javascript">
        function traceAccountRoute() {
            var searchBy = document.getElementById("searchBy").value;
            var accNumber = document.getElementById('acInfo_aValue').value;
            exec_AJAX('SearchLedger.aspx?accNumber=' + accNumber + '&searchBy=' + searchBy, 'spnTree', '');
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Sub_Account </a></li>
                            <li class="active"><a href="SearchAccount.aspx">Create Account</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4>Search Ledger
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                <%--<a href="#"class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Search By:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <asp:DropDownList ID="searchBy" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="a" Text="Account"></asp:ListItem>
                                        <asp:ListItem Value="g" Text="Group"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-3 control-label" for="">
                                    Ac Information:
                                </label>
                                <div class="col-lg-10 col-md-9">
                                    <uc1:SwiftTextBox ID="acInfo" runat="server" Category="SearchGL_AC" CssClass="required"
                                        Title="Blank for All" />
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-4 col-md-offset-3">
                                    <input class="btn btn-primary m-t-25" type="button" value=" Search" onclick="traceAccountRoute();" />
                                </div>
                            </div>
                            <span style="display: block" id="spnTree"></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>