<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Compliance.RuleSetup.Manage" %>

<!DOCTYPE html>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
<link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
<link href="../../../ui/css/style.css" rel="stylesheet" />

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
                            <li class="active"><a href="Manage.aspx">Compliance Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Compliance Setup Manage
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <asp:UpdatePanel ID="upnl1" runat="server">
                                    <ContentTemplate>
                                        <table class="table table-responsive">
                                            <tr>
                                                <td valign="top">
                                                    <table class="table table-responsive">
                                                        <tr>
                                                            <th colspan="4" align="left">Sending
                                                            </th>
                                                        </tr>
                                                        <tr>
                                                            <td>Country <span class="ErrMsg">*</span>
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
                                                                <asp:TextBox ID="sZip" runat="server" CssClass="form-control"></asp:TextBox>
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
                                                        </tr>
                                                        <tr>
                                                            <th colspan="4" align="left">Scope
                                                            </th>
                                                        </tr>
                                                        <tr>
                                                            <td align="left">Rule Scope
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="ruleScope" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td></td>
                                                <td valign="top">
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
                                                                <asp:TextBox ID="rZip" runat="server" CssClass="form-control"></asp:TextBox>
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
                                            <tr>
                                                <td>
                                                    <table>
                                                        <tr>
                                                            <td colspan="3">
                                                                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary m-t-25" ValidationGroup="compliance"
                                                                    Display="Dynamic" TabIndex="17" OnClick="btnSave_Click" />
                                                                <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" ConfirmText="Confirm To Save ?"
                                                                    Enabled="True" TargetControlID="btnSave">
                                                                </cc1:ConfirmButtonExtender>
                                                                &nbsp;
                                                    <asp:Button ID="btnDisable" runat="server" Text="Disable" CssClass="btn btn-primary m-t-25" ValidationGroup="admin"
                                                        Display="Dynamic" TabIndex="18" OnClick="btnDisable_Click" />
                                                                <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender2" runat="server" ConfirmText="Are you sure?"
                                                                    Enabled="True" TargetControlID="btnDisable">
                                                                </cc1:ConfirmButtonExtender>
                                                                &nbsp;
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            </td>
                                        </table>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="sCountry" EventName="SelectedIndexChanged" />
                                        <asp:AsyncPostBackTrigger ControlID="rCountry" EventName="SelectedIndexChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </div>
                            <div class="form-group">
                                <div id="rpt_grid" runat="server"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>