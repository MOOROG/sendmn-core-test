<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Pending.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.ApproveCustomer.Pending" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../../css/TranStyle.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>

    <script language="javascript" type="text/javascript">
        function ViewDetails(id) {
            var urlRoot = "<%=GetStatic.GetUrlRoot() %>";
            var url = "" + urlRoot + "/Remit/Administration/CustomerSetup/Manage.aspx?customerId=" + id + "&mode=1";
            var ret = OpenDialog(url, 800, 1000, 50, 50);

            if (ret) {
                GetElement("<%=btnSearch.ClientID %>").click();
            }
        }
    </script>
</head>
<body>

    <form id="form1" runat="server">
        <asp:Button ID="btnSearch" runat="server" Text="Search Approve" CssClass="button" OnClick="btnSearch_Click" Style="display: none;" />
        <asp:HiddenField ID="hdnZone" runat="server" />
        <asp:HiddenField ID="hdnStatus" runat="server" />
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                            <li class="active"><a href="Pending.aspx">Customer Setup </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="DashBoard.aspx">DashBoard</a></li>
                    <li><a href="Manage.aspx">Search Customer</a></li>
                    <li class="active"><a href="#" class="selected">Approve</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Customer Approve List  </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="table table-responsive">
                                        <div id="rptGrid" runat="server" enableviewstate="false"></div>
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