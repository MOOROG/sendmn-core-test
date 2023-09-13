<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewDetail.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.TopUpApprove.ViewDetail" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script type="text/javascript">
        function CallBack(mes) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);
            if (resultList[0] != 0) {
                return;
            }
            window.returnValue = resultList[0];
            window.close();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" ID="sc"></asp:ScriptManager>

        <div class="row">
            <div class="col-md-6">
                <div class="panel panel-default recent-activites">
                    <!-- Start .panel -->
                    <div class="panel-heading">
                        <h4 class="panel-title">Balance Top-Up Approve
                        </h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="form-group">
                            <label class=" control-label col-md-4">Agent Name : </label>
                            <asp:Label ID="lblAgentName" runat="server" CssClass=" control-label col-md-4"> </asp:Label>
                        </div>
                        <div class="form-group">
                            <asp:Label ID="lblSecurityType" runat="server" CssClass=" control-label col-md-4"></asp:Label>
                            <asp:Label ID="lblSecurityValue" runat="server" CssClass=" control-label col-md-4"> </asp:Label>
                        </div>
                        <div class="form-group">
                            <label class=" control-label col-md-4">Base Limit :  </label>
                            <asp:Label ID="lblBaseLimit" runat="server" CssClass=" control-label col-md-4"> </asp:Label>
                        </div>
                        <div class="form-group">
                            <label class=" control-label col-md-4">Max Limit :  </label>
                            <asp:Label ID="lblMaxLimit" runat="server" CssClass=" control-label col-md-4"> </asp:Label>
                        </div>
                        <div class="form-group">
                            <label class=" control-label col-md-4">Today's Topup :  </label>
                            <asp:Label ID="lblTodaysTopup" runat="server" CssClass=" control-label col-md-4"> </asp:Label>
                        </div>
                        <div class="form-group">
                            <label class=" control-label col-md-4">Current Balance  :  </label>
                            <asp:Label ID="lblCurrBal" BackColor="Yellow" runat="server" CssClass=" control-label col-md-4"> </asp:Label>
                        </div>
                        <div class="form-group form-inline">
                            <label class=" control-label col-md-4">Available Balance  :  </label>
                            <asp:Label ID="lblAvailableBal" BackColor="Yellow" runat="server" CssClass=" control-label col-md-4"> </asp:Label>
                        </div>
                        <div class="form-group form-inline">
                            <label class=" control-label col-md-4">Request Limit :  </label>
                            <asp:TextBox ID="txtReqLimit" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="form-group form-inline">
                            <label class=" control-label col-md-4">Approve/Reject Remarks :  </label>
                            <asp:TextBox ID="remarks" runat="server" CssClass="form-control" TextMode="MultiLine"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <div class="col-md-4"></div>
                            <div class="col-md-4">
                                <asp:Button ID="btnApprove" runat="server" Text="Approve" CssClass="btn btn-primary m-t-25" OnClick="btnApprove_Click" />
                                <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" ConfirmText="Confirm To Approve ?" Enabled="True" TargetControlID="btnApprove">
                                </cc1:ConfirmButtonExtender>
                                <asp:Button ID="btnReject" runat="server" Text="Reject" CssClass="btn btn-primary m-t-25" OnClick="btnReject_Click" />
                                <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" ConfirmText="Confirm To Reject ?" Enabled="True" TargetControlID="btnReject">
                                </cc1:ConfirmButtonExtender>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%--    <table border="0" cellspacing="0" cellpadding="0" align="left" class="formTable">
            <tr>
                <th colspan="2" class="frmTitle">Balance Topup Approve</th>
            </tr>
            <tr>
                <td>
                    <div align="right">Agent Name : </div>
                </td>
                <td nowrap="nowrap">
                    <asp:Label ID="lblAgentName" runat="server"
                        Style="font-weight: 700"></asp:Label></td>
            </tr>
            <tr>
                <td>
                    <div align="right">
                        <asp:Label ID="lblSecurityType" runat="server"></asp:Label>
                        : </div>
                </td>
                <td style="width: 200px" nowrap="nowrap">
                    <asp:Label ID="lblSecurityValue"
                        runat="server" Style="font-weight: 700"></asp:Label></td>
            </tr>
            <tr>
                <td>
                    <div align="right">Base Limit : </div>
                </td>
                <td>
                    <asp:Label ID="lblBaseLimit" runat="server" Style="font-weight: 700"></asp:Label></td>
            </tr>
            <tr>
                <td>
                    <div align="right">Max Limit : </div>
                </td>
                <td>
                    <asp:Label ID="lblMaxLimit" runat="server" Style="font-weight: 700"></asp:Label></td>
            </tr>
            <tr>
                <td>
                    <div align="right">Today's Topup : </div>
                </td>
                <td>
                    <asp:Label ID="lblTodaysTopup" runat="server" Style="font-weight: 700"></asp:Label></td>
            </tr>
            <tr>
                <td>
                    <div align="right"><strong>Current Balance</strong> : </div>
                </td>
                <td>
                    <asp:Label runat="server" ID="lblCurrBal" BackColor="Yellow"
                        ForeColor="Red" Style="font-weight: 700"></asp:Label>
                </td>
            </tr>
            <tr>
                <td>
                    <div align="right">Available Balance : </div>
                </td>
                <td>
                    <asp:Label ID="lblAvailableBal" runat="server" BackColor="Yellow"
                        ForeColor="Red" Style="font-weight: 700"></asp:Label></td>
            </tr>
            <tr>--%>
        <%--  <td>
                    <div align="right">Request Limit : </div>
                </td>
                <td>
                    <asp:TextBox ID="txtReqLimit" runat="server" Style="font-weight: 700"></asp:TextBox></td>
            </tr>
            <tr>
                <td valign="top">
                    <div align="right">Approve/Reject<br />
                        Remarks : </div>
                </td>
                <td>
                    <asp:TextBox ID="remarks" runat="server" TextMode="MultiLine" Height="50px" Width="250px"></asp:TextBox></td>
            </tr>
            <tr>
                <td>&nbsp;</td>
                <td>--%>
        <%--  <asp:Button ID="btnApprove" runat="server" Text="Approve"
                        OnClick="btnApprove_Click" />
                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                        ConfirmText="Confirm To Approve ?" Enabled="True" TargetControlID="btnApprove">
                    </cc1:ConfirmButtonExtender>
                    <asp:Button ID="btnReject" runat="server" Text="Reject"
                        OnClick="btnReject_Click" />
                    <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
                        ConfirmText="Confirm To Reject ?" Enabled="True" TargetControlID="btnReject">
                    </cc1:ConfirmButtonExtender>
                </td>
            </tr>
        </table>--%>
    </form>
</body>
</html>