<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.CreditLimit.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_calendar.js"></script>
    <script type="text/javascript">
        function CallBack(mes) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] != 0) {
                return;
            }
            window.returnValue = resultList[2];
            window.close();
        }

        function LoadCalendars() {
            ShowCalDefault("#<% =expiryDate.ClientID%>");
        }
        LoadCalendars();
    </script>
    <style type="text/css">
        .table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
            border-top: none !important;
        }

        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="container page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('creditrisk_management')">Credit Risk Management </a></li>
                            <li class="active"><a href="Manage.aspx">Credit Limit</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-8">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Credit Limit Details
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <span id="spnCname" runat="server"><%=GetAgentName()%></span>
                            </div>
                            <div class="table-responsive">
                                <table class="table">
                                    <tr>
                                        <td>
                                            <div class="panel panel-default">
                                                <div class="panel-heading">
                                                    Credit Limit Information
                                                </div>
                                                <div class="panel-body">
                                                    <div class="table-responsive">
                                                        <table class="table">
                                                            <tr>
                                                                <td class="frmLable">Currency</td>
                                                                <td colspan="3">
                                                                    <asp:DropDownList ID="currency" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="frmLable">Base Limit</td>
                                                                <td colspan="3">
                                                                    <asp:TextBox ID="limitAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="limitAmt" ForeColor="Red"
                                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="frmLable">Max Limit</td>
                                                                <td>
                                                                    <asp:TextBox ID="maxLimitAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="maxLimitAmt" ForeColor="Red"
                                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>
                                                                </td>
                                                                <td class="frmLable" style="display: none;">Todays Added Max Limit</td>
                                                                <td style="display: none;">
                                                                    <asp:TextBox ID="todaysAddedMaxLimit" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="frmLable">Per Topup Limit  </td>
                                                                <td>
                                                                    <asp:TextBox ID="perTopUpLimit" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="perTopUpLimit" ForeColor="Red"
                                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>
                                                                </td>
                                                                <td class="frmLable">Expiry Date</td>
                                                                <td>
                                                                    <asp:TextBox ID="expiryDate" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    <%--<cc1:CalendarExtender ID="ce1" runat="server" CssClass="cal_Theme1" TargetControlID="expiryDate"></cc1:CalendarExtender>--%>
                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="expiryDate" ForeColor="Red"
                                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>
                                                                    <asp:RangeValidator ID="RangeValidator2" runat="server"
                                                                        ControlToValidate="expiryDate"
                                                                        MaximumValue="12/31/2100"
                                                                        MinimumValue="01/01/1900"
                                                                        Type="Date"
                                                                        ErrorMessage="*Invalid date"
                                                                        ValidationGroup="country"
                                                                        CssClass="errormsg"
                                                                        SetFocusOnError="true"
                                                                        Display="Dynamic">
                                                                    </asp:RangeValidator>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div class="panel panel-default">
                                                <div class="panel-heading">
                                                    Agent Limit Request Information
                                                </div>
                                                <div class="panel-body">
                                                    <div class="table-responsive">
                                                        <table class="table">
                                                            <tr>
                                                                <td class="frmLable">Per Topup Request <span class="ErrMsg">*</span></td>
                                                                <td>
                                                                    <asp:TextBox ID="perToupRequest" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    <br />
                                                                    <asp:RequiredFieldValidator ID="rfv7" runat="server"
                                                                        ControlToValidate="perToupRequest" ForeColor="Red"
                                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>
                                                                </td>
                                                                <td class="frmLable">Max Topup Request <span class="ErrMsg">*</span></td>
                                                                <td>
                                                                    <asp:TextBox ID="maxTopupRequest" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    <br />
                                                                    <asp:RequiredFieldValidator ID="rfv6" runat="server"
                                                                        ControlToValidate="maxTopupRequest" ForeColor="Red"
                                                                        ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div id="divAuditLog" runat="server"></div>
                                        </td>
                                    </tr>
                                    <tr>
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
                                            <input type="button" onclick="Javascript: history.back();" value="Back" class="btn btn-primary" />
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