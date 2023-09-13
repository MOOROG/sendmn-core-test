<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.TransactionLimit.Agentwise.ReceivingLimit.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="../../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../../ui/js/jquery.min.js"></script>
    <link href="../../../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>

        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>CREDIT RISK MANAGEMENT
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Credit Risk Management</a></li>
                            <li class="active"><a href="#">Agent Wise</a></li>
                            <li class="active"><a href="#">Transaction Limit</a></li>
                            <li class="active"><a href="#">Receiving Limit</a></li>
                            <li class="active"><a href="#">Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Receiving Limit(Agent Wise)</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <table class="table table-condensed" style="width: 80%;">
                                        <tr>
                                            <td>
                                                <asp:Panel ID="pnl1" runat="server">
                                                    <table class="table table-condensed">

                                                        <tr>
                                                            <td class="welcome"><span id="spnCname" runat="server"><%=GetAgentName()%></span></td>
                                                        </tr>
                                                    </table>
                                                </asp:Panel>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <table class="table table-condensed">

                                                    <tr>
                                                        <td>
                                                            <asp:UpdatePanel ID="up1" runat="server">
                                                                <ContentTemplate>
                                                                    <table class="table table-condensed">

                                                                        <tr id="trcountryLimit" runat="server" visible="false">
                                                                            <td>&nbsp;</td>
                                                                            <td colspan="2">
                                                                                <b>Country Max Limit :
                                            [<asp:Label ID="countryMaxLim" runat="server"></asp:Label>]</b>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable" nowrap="nowrap">Sending Country
                                                                            </td>
                                                                            <td colspan="2">
                                                                                <asp:DropDownList ID="sendingCountry" runat="server" AutoPostBack="true"
                                                                                    CssClass="form-control" OnSelectedIndexChanged="sendingCountry_SelectedIndexChanged">
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td nowrap="nowrap">Receiving Mode
                                            <span class="errormsg">*</span>
                                                                            </td>
                                                                            <td colspan="2">
                                                                                <asp:DropDownList ID="tranType" runat="server" CssClass="form-control"
                                                                                    AutoPostBack="True" OnSelectedIndexChanged="tranType_SelectedIndexChanged">
                                                                                </asp:DropDownList>
                                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="tranType" ForeColor="Red"
                                                                                    ValidationGroup="agent" Display="Dynamic" ErrorMessage="Required!">
                                                                                </asp:RequiredFieldValidator>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable" nowrap="nowrap">Max Limit
                                                                            </td>
                                                                            <td colspan="2">
                                                                                <asp:TextBox ID="maxLimitAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="maxLimitAmt" ForeColor="Red"
                                                                                    ValidationGroup="agent" Display="Dynamic" ErrorMessage="Required!">
                                                                                </asp:RequiredFieldValidator>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable" nowrap="nowrap">Currency
                                            <span class="errormsg">*</span>
                                                                            </td>
                                                                            <td colspan="2">
                                                                                <asp:DropDownList ID="currency" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                                                                    ValidationGroup="agent" Display="Dynamic" ErrorMessage="Required!">
                                                                                </asp:RequiredFieldValidator>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td nowrap="nowrap">Customer Type</td>
                                                                            <td colspan="2">
                                                                                <asp:DropDownList ID="customerType" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td nowrap="nowrap">Branch Selection</td>
                                                                            <td colspan="2">
                                                                                <asp:DropDownList ID="branchSelection" runat="server" CssClass="form-control">
                                                                                    <asp:ListItem Value="Not Required">Not Required</asp:ListItem>
                                                                                    <asp:ListItem Value="Manual Type">Manual Type</asp:ListItem>
                                                                                    <asp:ListItem Value="Select">Select</asp:ListItem>
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable" nowrap="nowrap">Beneficiary Id Required</td>
                                                                            <td colspan="2">
                                                                                <asp:DropDownList ID="benificiaryIdreq" runat="server" CssClass="form-control">
                                                                                    <asp:ListItem Value="H">Hide</asp:ListItem>
                                                                                    <asp:ListItem Value="M">Mandatory</asp:ListItem>
                                                                                    <asp:ListItem Value="O">Optional</asp:ListItem>
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable" nowrap="nowrap">Relationship Required</td>
                                                                            <td colspan="2">
                                                                                <asp:DropDownList ID="relationshipReq" runat="server" CssClass="form-control">
                                                                                    <asp:ListItem Value="H">Hide</asp:ListItem>
                                                                                    <asp:ListItem Value="M">Mandatory</asp:ListItem>
                                                                                    <asp:ListItem Value="O">Optional</asp:ListItem>
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable" nowrap="nowrap">Beneficiary Contact Required</td>
                                                                            <td colspan="2">
                                                                                <asp:DropDownList ID="benificiaryContactReq" runat="server" CssClass="form-control">
                                                                                    <asp:ListItem Value="H">Hide</asp:ListItem>
                                                                                    <asp:ListItem Value="M">Mandatory</asp:ListItem>
                                                                                    <asp:ListItem Value="O">Optional</asp:ListItem>
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <span id="acShowHide" runat="server" visible="false">
                                                                            <tr>
                                                                                <td>&nbsp;</td>
                                                                                <td>From</td>
                                                                                <td>To</td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td class="frmLable">AC Length <span class="errormsg">*</span></td>
                                                                                <td>
                                                                                    <asp:TextBox ID="acLengthFrom" runat="server" CssClass="form-control"></asp:TextBox>
                                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="acLengthFrom" ForeColor="Red"
                                                                                        ValidationGroup="agent" Display="Dynamic" ErrorMessage="Required!">
                                                                                    </asp:RequiredFieldValidator>
                                                                                </td>
                                                                                <td>
                                                                                    <asp:TextBox ID="acLengthTo" runat="server"></asp:TextBox>
                                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="acLengthTo" ForeColor="Red"
                                                                                        ValidationGroup="agent" Display="Dynamic" ErrorMessage="Required!">
                                                                                    </asp:RequiredFieldValidator>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td class="frmLable">AC Number Type</td>
                                                                                <td colspan="2">
                                                                                    <asp:DropDownList ID="acNumberType" runat="server" CssClass="form-control">
                                                                                        <asp:ListItem Value="Alphanumeric">Alphanumeric</asp:ListItem>
                                                                                        <asp:ListItem Value="Numeric">Numeric</asp:ListItem>
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                        </span>
                                                                        <tr>
                                                                            <td></td>
                                                                            <td colspan="2">
                                                                                <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="agent"
                                                                                    CssClass="btn btn-primary btn-sm" TabIndex="5" OnClick="btnSave_Click" />
                                                                                <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                                                    ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                                                </cc1:ConfirmButtonExtender>
                                                                                &nbsp;
                                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-primary btn-sm"
                                                TabIndex="6" OnClick="btnDelete_Click" />
                                                                                <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
                                                                                    ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                                                                </cc1:ConfirmButtonExtender>
                                                                                &nbsp;
                                            <input id="btnBack" type="button" value="Back" class="btn btn-primary btn-sm" onclick=" Javascript:history.back(); " />
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </ContentTemplate>
                                                            </asp:UpdatePanel>
                                                        </td>
                                                    </tr>
                                                </table>
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
    </form>
</body>
</html>