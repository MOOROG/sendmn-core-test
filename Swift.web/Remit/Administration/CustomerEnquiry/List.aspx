<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerEnquiry.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
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
                            <li><a href="#" onclick="return LoadModule('account_report')">Online Customer</a></li>
                            <li class="active"><a href="List.aspx">Customer Enquiry Message</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Search Customer Enquiry Message
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                    <label class="col-md-2 control-label">Choose Enquiry Type:</label>
                                    <div class="col-md-4">
                                        <asp:DropDownList ID="ddlEnquiryMsg" runat="server" CssClass="form-control">
                                            <asp:ListItem Value="e">General Enquiry Request</asp:ListItem>
                                            <asp:ListItem Value="t">Transaction Amendment Request</asp:ListItem>
                                            <asp:ListItem Value="f">Sugession/FeedBack Request</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Button ID="btnSearch" Text="Search" runat="server" OnClick="btnSearch_Click" CssClass="btn btn-primary m-t-25" />
                                    </div>
                            </div>
                            <div class="row">
                                <hr />
                                <hr />
                                <div class="form-group">
                                    <div id="rptGrid" runat="server" enableviewstate="false"></div>
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
