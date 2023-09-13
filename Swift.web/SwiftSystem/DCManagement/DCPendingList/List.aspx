<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.SwiftSystem.DCManagement.DCPendingList.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/Swift_grid.js"></script>
    <script src="../../../js/swift_autocomplete.js"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
</head>
<body>

    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('other_services')">Other Services</a></li>
                            <li class="active"><a href="List.aspx">DC Pending List</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">DC Pending List</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <div id="rpt_grid" runat="server" enableviewstate="false"></div>
                            </div>
                            <div class="form-group">
                                <asp:Button ID="btnApprove" runat="server" Text="Approve" CssClass="btn btn-primary m-t-25" OnClick="btnApprove_Click" />
                                <asp:Button ID="btnReject" runat="server" Text="Reject" CssClass="btn btn-primary m-t-25" OnClick="btnReject_Click" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
