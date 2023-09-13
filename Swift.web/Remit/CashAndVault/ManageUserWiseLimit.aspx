<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageUserWiseLimit.aspx.cs" Inherits="Swift.web.Remit.CashAndVault.ManageUserWiseLimit1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" ID="sm1"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a>Exchange Setup</a></li>
                            <li class="active"><a>Cash And Vault</a></li>
                            <li class="active"><a href="List.aspx">BranchWise Cash And Vault Setup</a></li>
                            <li class="active"><a>UserWise Cash And Vault Setup</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="ManageUserWiseLimit.aspx">Assign Limit Userwise</a></li>
                </ul>
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="">
                            <div class="register-form">
                                <div class="panel panel-default clearfix m-b-20">

                                    <div class="panel-heading" runat="server">
                                        <h4 class="panel-title" id="headerPart" runat="server"></h4>
                                    </div>
                                    <div class="panel-body">

                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>User<span class="errormsg">*</span></label>
                                                <asp:TextBox runat="server" ReadOnly="true" ID="UserName" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Cash Hold Limit:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="cashHoldLimit" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                        <div class="col-md-6" style="display: none">
                                            <div class="form-group">
                                                <label>Per Top Up Limit:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="perTopUpLimit" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Rule Type<span class="errormsg">*</span></label>
                                                <asp:DropDownList runat="server" ID="ddlRuleType" name="ddlRuleType" CssClass="form-control">
                                                    <asp:ListItem Text="Hold" Value="H"></asp:ListItem>
                                                    <asp:ListItem Text="Block" Value="B"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <div class="col-md-6">
                                            <asp:Button ID="Save" CssClass="btn btn-primary m-t-25" Text="Save" runat="server" OnClick="Save_Click" />
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