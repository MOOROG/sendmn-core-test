<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.DomesticOperation.UserWiseTxnLimit.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
    <script type="text/javascript" src="../../../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../../ui/js/jquery-ui.min.js"></script>

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
    </script>
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
                                    <li>Domestic Operation  </li>
                                    <li>User Wise Txn Limit  </li>
                                    <li class="active">Manage</li>
                                </ol>
                            </div>
                        </div>
                    </div>

                    <div class="listtabs">
                        <ul class="nav nav-tabs" role="tablist">
                            <li role="presentation"><a href="Javascript:void(0)" class="selected" aria-controls="home" role="tab" data-toggle="tab">User Wise Txn Limit List </a></li>
                        </ul>
                    </div>
                    <div class="tab-content">
                        <div role="tabpanel" class="tab-pane active" id="list">
                            <div class="row">
                                <div class="col-md-8">
                                    <div class="panel panel-default ">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">User Wise Txn Limit  Manage</h4>
                                            <div class="panel-actions">
                                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                            </div>
                                        </div>
                                        <div class="panel-body">
                                            <table class="table table-condensed" border="0" align="left" cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td>
                                                        <asp:Panel ID="pnl1" runat="server">
                                                            <table>
                                                                <tr>
                                                                    <td height="20" class="welcome"><span id="spnCname" runat="server"><%=GetUserName()%></span></td>
                                                                </tr>
                                                            </table>
                                                        </asp:Panel>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top">
                                                        <table class="table table-condensed">
                                                            <tr>
                                                                <td class="fromHeadMessage" nowrap="nowrap"><b>User Name :
                                                    <asp:Label ID="userName" runat="server"></asp:Label></b>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <div class="panel panel-default">
                                                                        <div class="panel-heading">Send Limit</div>
                                                                        <div class="panel-body">
                                                                            <table class="table table-condensed">
                                                                                <tr>
                                                                                    <td class="frmLable" nowrap="nowrap">Per Days</td>
                                                                                    <td>
                                                                                        <asp:TextBox ID="sendPerDay" runat="server" CssClass="form-control"></asp:TextBox></td>
                                                                                    <td class="frmLable" nowrap="nowrap">Per Txn</td>
                                                                                    <td>
                                                                                        <asp:TextBox ID="sendPerTxn" runat="server" CssClass="form-control"></asp:TextBox></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable" nowrap="nowrap">Send Todays</td>
                                                                                    <td colspan="3">
                                                                                        <asp:Label ID="sendTodays" runat="server" Width="100px"></asp:Label></td>
                                                                                </tr>
                                                                            </table>
                                                                        </div>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <div class="panel panel-default">
                                                                        <div class="panel-heading">Pay Limit</div>
                                                                        <div class="panel-body">
                                                                            <table class="table table-condensed">
                                                                                <tr>
                                                                                    <td class="frmLable" nowrap="nowrap">Per Days</td>
                                                                                    <td>
                                                                                        <asp:TextBox ID="payPerDay" runat="server" CssClass="form-control"></asp:TextBox></td>
                                                                                    <td class="frmLable" nowrap="nowrap">Per Txn</td>
                                                                                    <td>
                                                                                        <asp:TextBox ID="payPerTxn" runat="server" CssClass="form-control"></asp:TextBox></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable" nowrap="nowrap">Pay Todays</td>
                                                                                    <td colspan="3">
                                                                                        <asp:Label ID="payTodays" runat="server" Width="100px"></asp:Label>
                                                                                    &nbsp;
                                                                                </tr>
                                                                            </table>
                                                                        </div>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <div class="panel panel-default">
                                                                        <div class="panel-heading">Cancel Limit</div>
                                                                        <div class="panel-body">
                                                                            <table class="table table-condensed">
                                                                                <tr>
                                                                                    <td class="frmLable" nowrap="nowrap">Per Days</td>
                                                                                    <td>
                                                                                        <asp:TextBox ID="cancelPerDay" runat="server" CssClass="form-control"></asp:TextBox></td>
                                                                                    <td class="frmLable" nowrap="nowrap">Per Txn</td>
                                                                                    <td>
                                                                                        <asp:TextBox ID="cancelPerTxn" runat="server" CssClass="form-control"></asp:TextBox></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable" nowrap="nowrap">Cancel Todays</td>
                                                                                    <td colspan="3">
                                                                                        <asp:Label ID="cancelTodays" runat="server" Width="100px"></asp:Label></td>
                                                                                </tr>
                                                                            </table>
                                                                        </div>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <asp:Button ID="btnSave" runat="server" Text=" Save " ValidationGroup="country"
                                                                        CssClass="btn btn-primary" TabIndex="5" OnClick="btnSave_Click" />
                                                                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                                        ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                                    </cc1:ConfirmButtonExtender>
                                                                    &nbsp;
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
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>