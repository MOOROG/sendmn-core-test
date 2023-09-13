<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.ThirdPartyTXN.APILog.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />


    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
        .borderless td, .borderless th {
    border: none !important;
}
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('other_services')">Other Services</a></li>
                            <li class="active"><a href="Manage.aspx">API Log</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">API Transaction  Log Details </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <table class="table table-responsive borderless">
                                    <tr>
                                        <td class="frmLable">Provider:</td>
                                        <td>
                                            <asp:Label runat="server" ID="provider" /></td>
                                        <td class="frmLable">Method:</td>
                                        <td>
                                            <asp:Label runat="server" ID="Method" /></td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Control No:</td>
                                        <td>
                                            <asp:Label runat="server" ID="ControlNo" /></td>
                                        <td class="frmLable">User:</td>
                                        <td>
                                            <asp:Label runat="server" ID="User" /></td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Request Date:</td>
                                        <td>
                                            <asp:Label runat="server" ID="RequestDate" /></td>
                                        <td class="frmLable">Response Date:</td>
                                        <td>
                                            <asp:Label runat="server" ID="ResponseDate" /></td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Code:</td>
                                        <td>
                                            <asp:Label runat="server" ID="Code" /></td>
                                        <td class="frmLable">Message:</td>
                                        <td>
                                            <asp:Label runat="server" ID="Message" /></td>
                                    </tr>
                                    <tr>
                                        <td>&nbsp;</td>
                                    </tr>
                                </table>
                            </div>
                        <div class="form-group">
                            <table class="table-responsive">
                                <tr>
                                    <td colspan="4"><span class="frmLable">Request xml:</span><br />
                                        <asp:TextBox ID="reqXml" runat="server" TextMode="MultiLine" Rows="15" Columns="98" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td colspan="4"><span class="frmLable">Response xml:</span><br />
                                        <asp:TextBox ID="resXml" runat="server" TextMode="MultiLine" Rows="15" Columns="98" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <input type="button" id="close" class="btn btn-primary m-t-25" value="Close" onclick="javascript: window.close();" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
