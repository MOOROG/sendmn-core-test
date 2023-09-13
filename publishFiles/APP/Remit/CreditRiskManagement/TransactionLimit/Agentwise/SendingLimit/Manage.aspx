<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.TransactionLimit.Agentwise.SendingLimit.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../../Css/swift_component.css" rel="stylesheet" type="text/css" />

    <style type="text/css">
        .table .table {
            background-color: #F5F5F5 !important;
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
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Credit Risk Management</li>
                            <li>Transaction Limit</li>
                            <li>Agent Wise</li>
                            <li>Collection Limit</li>
                            <li class="active">Manage</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-8">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Collection Limit Details
                            </h4>
                            <%-- <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><a href="#"
                                    class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                            </div>--%>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group" style="margin-left: 8px;">
                                <span id="spnCname" runat="server"><%=GetAgentName()%></span>
                            </div>
                            <div class="form-group table table-responsive">
                                <table class="table">
                                    <tr>
                                        <td class="frmLable">Receiving Country:</td>
                                        <td>
                                            <asp:DropDownList ID="receivingCountry" runat="server" AutoPostBack="true" CssClass="form-control" OnSelectedIndexChanged="receivingCountry_SelectedIndexChanged"></asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Receiving Agent:</td>
                                        <td>
                                            <asp:DropDownList ID="receivingAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Collection Type</td>
                                        <td>
                                            <asp:DropDownList ID="collMode" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Payment Type</td>
                                        <td>
                                            <asp:DropDownList ID="tranType" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Min Per Trn. Limit</td>
                                        <td nowrap="nowrap">
                                            <asp:TextBox ID="minLimitAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="minLimitAmt" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td class="frmLable">Max Per Trn. Limit</td>
                                        <td nowrap="nowrap">
                                            <asp:TextBox ID="maxLimitAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="maxLimitAmt" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Currency</td>
                                        <td>
                                            <asp:DropDownList ID="currency" runat="server" CssClass="form-control"></asp:DropDownList>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                                ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Customer Type</td>
                                        <td>
                                            <asp:DropDownList ID="customerType" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td>
                                            <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country"
                                                CssClass="btn btn-primary" TabIndex="5" OnClick="btnSave_Click" />
                                            <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                            </cc1:ConfirmButtonExtender>
                                            &nbsp;
                                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-primary"
                                                TabIndex="6" OnClick="btnDelete_Click" />
                                            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
                                                ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                            </cc1:ConfirmButtonExtender>
                                            &nbsp;
                                            <input id="btnBack" type="button" value="Back" class="btn btn-primary" onclick=" Javascript: history.back(); " />
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