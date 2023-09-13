<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.UserTopUpLimit.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>
        <asp:UpdatePanel ID="upnl1" runat="server">
            <ContentTemplate>
                <div class="page-wrapper">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="page-title">
                                <ol class="breadcrumb">
                                    <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                                    <li><a href="#" onclick="return LoadModule('creditrisk_management')">Credit Risk Management </a></li>
                                    <li class="active"><a href="Manage.aspx">User Top_Up Limit</a></li>
                                </ol>
                            </div>
                        </div>
                    </div>
                    <div class="listtabs">
                        <ul class="nav nav-tabs" role="tablist">
                            <li role="presentation"><a href="List.aspx" aria-controls="home" role="tab" data-toggle="tab">List </a></li>
                            <li role="presentation" class="active"><a href="Javascript:void(0)" class="selected" aria-controls="home" role="tab" data-toggle="tab">Manage </a></li>
                        </ul>
                    </div>
                    <div class="tab-content">
                        <div role="tabpanel" class="tab-pane active" id="list">
                            <div class="row">
                                <div class="col-md-8">
                                    <div class="panel panel-default ">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">User Top-Up Limit Details</h4>
                                            <div class="panel-actions">
                                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                            </div>
                                        </div>

                                        <div class="panel-body">
                                            <div class="form-group">
                                                <label class="col-md-3">
                                                    User Name :
                                                </label>
                                                <div class="col-md-5">
                                                    <asp:Label ID="lblUserName" runat="server" CssClass="form-control"></asp:Label>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-md-3">
                                                    Currency :
                                                </label>
                                                <div class="col-md-5">
                                                    <asp:DropDownList ID="currency" runat="server" CssClass="form-control"></asp:DropDownList>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-md-3">
                                                    Limit Per Day :
                                                </label>
                                                <div class="col-md-5">
                                                    <asp:TextBox ID="limitPerDay" runat="server" CssClass="form-control"></asp:TextBox>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="limitPerDay" ForeColor="Red"
                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-md-3">
                                                    Per Topup Limit:
                                                </label>
                                                <div class="col-md-5">
                                                    <asp:TextBox ID="perTopUpLimit" runat="server" CssClass="form-control"></asp:TextBox>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="perTopUpLimit" ForeColor="Red"
                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-md-3">
                                                    Max Credit Limit For Agent :
                                                </label>
                                                <div class="col-md-5">
                                                    <asp:TextBox ID="maxCreditLimitForAgent" runat="server" CssClass="form-control"></asp:TextBox>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
                                                        ControlToValidate="maxCreditLimitForAgent" ForeColor="Red"
                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div class="col-md-6 col-md-offset-3">
                                                    <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country"
                                                        CssClass="btn btn-primary m-t-25" TabIndex="5" OnClick="btnSave_Click" />
                                                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                        ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                    </cc1:ConfirmButtonExtender>
                                                    &nbsp;
                                                    <input id="btnBack" type="button" value="Back" class="btn btn-primary m-t-25" onclick="Javascript: history.back(); " />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
                <tr>
                    <td width="100%">
                        <asp:Panel ID="pnl1" runat="server">
                            <table width="100%">
                                <tr>
                                    <td height="26" class="bredCrom"> <div > Credit Risk Management » User Top-Up Limit » Manage </div> </td>
                                </tr>
                                <tr>
                                    <td height="10" width="100%">
                                        <div class="tabs">
                                            <ul>
                                                <li> <a href="List.aspx">List</a></li>
                                                <li> <a href="Javascript:void(0)" class="selected"> </a></li>
                                            </ul>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                    </td>
                </tr>
                <tr>
                    <td height="524" valign="top">
                        <table border="0" cellspacing="0" cellpadding="0" class="formTable" align="left">
                            <tr>
                                <th colspan="2" class="frmTitle">User Top-Up Limit Details</th>
                            </tr>
                            <tr>--%>
                <%--<td class="frmLable">User Name</td>
                                <td>
                                    <asp:Label ID="lblUserName" runat="server" Width="150px"
                                        style="font-weight: 700; text-decoration: underline"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td class="frmLable">Currency</td>
                                <td>
                                    <asp:DropDownList ID="currency" runat="server" Width="150px"></asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                                                ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>--%>
                <%-- <td class="frmLable">Limit Per Day</td>
                                <td>
                                    <asp:TextBox ID="limitPerDay" runat="server" Width="100px"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="limitPerDay" ForeColor="Red"
                                                                ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>--%>
                <%--      <td class="frmLable">Per Topup Limit</td>
                                <td>
                                    <asp:TextBox ID="perTopUpLimit" runat="server" Width="100px"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="perTopUpLimit" ForeColor="Red"
                                                                ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>--%>
                <%--   <td class="frmLable">Max Credit Limit For Agent</td>
                                <td>
                                    <asp:TextBox ID="maxCreditLimitForAgent" runat="server" Width="100px"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
                                        ControlToValidate="maxCreditLimitForAgent" ForeColor="Red"
                                        ValidationGroup="country" Display="Dynamic"  ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>--%>
                <%--   <td></td>
                                <td><asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country"
                                                CssClass="button" TabIndex="5" onclick="btnSave_Click" />
                                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                                ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                    </cc1:ConfirmButtonExtender>&nbsp;
                                    <input id="btnBack" type="button" value="Back" class="button" onClick="Javascript: history.back(); " />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>--%>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>