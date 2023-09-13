<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Compliance.RuleSetup.List" %>

<!DOCTYPE html>
<link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
<link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
<link href="../../../ui/css/style.css" rel="stylesheet" />
<script src="../../../js/Swift_grid.js"></script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="">
        .table .table {
            background-color: #f5f5f5;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remit')">Remit</a></li>
                            <li><a href="#" onclick="return LoadModule('remit_compliance')">Compliance Setup </a></li>
                            <li class="active"><a href="List.aspx">Compliance List</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Compliance Setup
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <asp:UpdatePanel ID="upd1" runat="server">
                                    <ContentTemplate>
                                        <table class="table table-responsive">
                                            <tr>
                                                <td>
                                                    <table class="table table-responsive">
                                                        <tr>
                                                            <th colspan="4" align="left">Sending
                                                            </th>
                                                        </tr>
                                                        <tr>
                                                            <td>Country
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control" OnSelectedIndexChanged="sCountry_SelectedIndexChanged"
                                                                    AutoPostBack="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>Agent
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td align="left">State
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="sState" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td align="left">Zip
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="sZip" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td align="left">Group
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="sGroup" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td align="left">Customer Type
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="sCustType" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td></td>
                                                            <td></td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="4">
                                                                <asp:Button ID="btnFilter" runat="server" Text="Filter" OnClick="btnFilter_Click"
                                                                    CssClass="btn btn-primary m-t-25" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td>
                                                    <table class="table table-responsive">
                                                        <tr>
                                                            <th colspan="4" align="left">Receiving
                                                            </th>
                                                        </tr>
                                                        <tr>
                                                            <td>Country
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="rCountry" runat="server" CssClass="form-control" OnSelectedIndexChanged="rCountry_SelectedIndexChanged"
                                                                    AutoPostBack="True">
                                                                </asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>Agent
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="rAgent" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td align="left">State
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="rState" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td align="left">Zip
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="rZip" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td align="left">Group
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="rGroup" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td align="left">Customer Type
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="rCustType" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td align="left">Currency
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="currency" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="sCountry" EventName="SelectedIndexChanged" />
                                        <asp:AsyncPostBackTrigger ControlID="rCountry" EventName="SelectedIndexChanged" />
                                        <asp:PostBackTrigger ControlID="btnFilter" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>
                            <div class="form-group">
                                <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>