<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.BankFundTreasury.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />

    <script src="/js/Swift_grid.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
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
                            <li><a href="#" onclick="return LoadModule('account')">Remittance</a></li>
                            <li class="active"><a href="List.aspx">Fund Transfer to Partner </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Fund Transfer to Partner
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="form-group ">
                                    <label class="col-sm-2">Bank Name:<span class="errormsg">*</span></label>
                                    <div class="col-md-6">
                                        <asp:DropDownList ID="ddlbankId" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                    <div class="col-md-1">
                                        <asp:Button ID="search" Text="Search" runat="server" OnClick="search_Click" CssClass="btn btn-primary m-t-25" />
                                    </div>
                                    <div class="col-md-2">
                                        <a href="Transfer.aspx" title="" class="btn btn-primary m-t-25">Make a Transfer</a>
                                    </div>
                                    <div class="col-md-2">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <hr />
                        <div class="panel-body">
                            <div id="rptGrid" runat="server" enableviewstate="false"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>