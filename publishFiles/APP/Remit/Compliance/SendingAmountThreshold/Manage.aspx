<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Compliance.SendingAmountThreshold.Manage" %>

<!DOCTYPE html>
<link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
<link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
<link href="../../../ui/css/style.css" rel="stylesheet" />

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
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
                            <li><a href="#" onclick="return LoadModule('remit')">Remit</a></li>
                            <li><a href="#" onclick="return LoadModule('remit_compliance')">Compliance</a></li>
                            <li class="active"><a href="Manage.aspx">Sending Amount Threshold </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="List.aspx" target="_self">List </a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Manage</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-8">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Sending Amount Threshold Setup
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <table class="table table-responsive">
                                            <tr>
                                                <td style="width: 20%;">Sending Country:
                                                </td>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="sCountry" CssClass="form-control" OnSelectedIndexChanged="sCountry_SelectedIndexChanged" AutoPostBack="true">
                                                    </asp:DropDownList>
                                                    <asp:RequiredFieldValidator ID="rvsCountry" runat="server" ControlToValidate="sCountry"
                                                        Display="Dynamic" ErrorMessage="*" ValidationGroup="compliance" ForeColor="Red"
                                                        CssClass="ErrMsg" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Receiving Country
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="rCountry" runat="server" CssClass="form-control">
                                                    </asp:DropDownList>
                                                    <asp:RequiredFieldValidator ID="rvrCountry" runat="server" ControlToValidate="rCountry"
                                                        Display="Dynamic" ErrorMessage="*" ValidationGroup="compliance" ForeColor="Red"
                                                        CssClass="ErrMsg" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Agent
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Amount:
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" ID="Amount" CssClass="form-control"></asp:TextBox>
                                                    <asp:RequiredFieldValidator ID="rvAmount" runat="server" ControlToValidate="Amount"
                                                        Display="Dynamic" ErrorMessage="*" ValidationGroup="compliance" ForeColor="Red"
                                                        CssClass="ErrMsg" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Message:
                                                </td>
                                                <td>
                                                    <asp:TextBox runat="server" TextMode="MultiLine" ID="Message" CssClass="form-control" Rows="5"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Is Active:
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="chkActive" runat="server" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td>
                                                    <asp:Button runat="server" ID="Save" CssClass="btn btn-primary m-t-25" Text="Save" OnClick="Save_Click" />
                                                </td>
                                            </tr>
                                        </table>
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