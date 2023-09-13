<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ApproveReqUnapprovedTxn.aspx.cs"
    Inherits="Swift.web.Remit.Transaction.Cancel.ApproveReqUnapprovedTxn" %>

<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransactionInt.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <%--    <style type="text/css">
        legend {
            color: #FFFFFF;
            background: #FF0000;
            border-radius: 2px;
        }

        fieldset {
            border: 1px solid #000000;
        }

        td {
            color: #000000;
        }

        .watermark {
            font-size: 14px;
        }

        .HeighlightTex {
            font-size: 1.4em;
            font-weight: bold;
            color: red;
        }
    </style>--%>
    <script type="text/javascript">
        function CallBack(mes, url) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] != 0) {
                return;
            }

            window.returnValue = resultList[0];
            window.location.replace(url);
        }
        function GridCallBack() {
            var boolDisabled = (GetRowId('<%=GridName %>') == "");
            var btnA = GetElement("<% = btnTranSelect.ClientID %>");
            btnA.disabled = boolDisabled;

            var cssClass = (boolDisabled ? "buttonDisabled" : "");
            var thisClass = btnA.className;

            thisClass = thisClass.replace("buttonDisabled", "");
            thisClass = thisClass.replace("buttonEnabled", "");

            cssClass = cssClass + " " + thisClass;
            SetCSSByObj(btnA, cssClass);
        }

        function DoNext() {
            return confirm("Are you sure?");
        }
    </script>
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
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a>
                            </li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="ApproveReqUnapprovedTxn.aspx">Approve Cancel Transaction</a></li>

                            <li class="active">
                                <asp:Label ID="breadCrumb" runat="server"></asp:Label>
                            </li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-danger recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Approve Cancel Transaction
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <div style="min-height: 720px">
                                    <div style="clear: both;" id="gridDisplay" runat="server">

                                        <div id="grd_tran" runat="server" enableviewstate="false" class="gridDiv">
                                        </div>
                                        <asp:HiddenField ID="hddTran" runat="server" />
                                        <asp:HiddenField ID="hddRCustomerId" runat="server" />
                                    </div>
                                    <asp:Button ID="btnTranSelect" Enabled="False" runat="server" Text="Select" Style="margin-left: 20px;"
                                        OnClick="btnTranSelect_Click" CssClass="btn btn-primary" />
                                    <div id="divTranDetails" runat="server" visible="false" style="margin-left: 20px;">
                                        <div class="HeighlightTex">
                                            Cancel Request For: <u>
                                                <asp:Label ID="trnStatusBeforeCnlReq" runat="server"></asp:Label></u>
                                        </div>
                                        <br />
                                        <div>
                                            <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true"
                                                ShowCommentBlock="false" />
                                        </div>

                                        <div class="panel panel-danger">
                                            <div class="panel-heading">Approve Cancel Request</div>
                                            <div class="panel-body">
                                                <table class="table">
                                                    <tr>
                                                        <td valign="top" nowrap="nowrap" width="10%;">
                                                            <b>Approve Remarks</b>
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <asp:TextBox ID="approveRemarks" runat="server" TextMode="MultiLine" Height="40px"
                                                                Width="300px" CssClass="form-control"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <asp:Button ID="btnApprove" runat="server" Text=" Approve " ValidationGroup="approve"
                                                                CssClass="btn btn-primary" OnClick="btnApprove_Click" />&nbsp;&nbsp;&nbsp;&nbsp;
                            <cc1:ConfirmButtonExtender ID="btnCancelcc" runat="server" ConfirmText="Confirm To Approve?"
                                Enabled="True" TargetControlID="btnApprove">
                            </cc1:ConfirmButtonExtender>
                                                            <asp:Button ID="btnReject" runat="server" Text=" Reject " CssClass="btn btn-danger" OnClick="btnReject_Click" />&nbsp;&nbsp;&nbsp;&nbsp;
                            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" ConfirmText="Confirm To Reject?"
                                Enabled="True" TargetControlID="btnReject">
                            </cc1:ConfirmButtonExtender>
                                                            <asp:Button ID="btnBack" runat="server" Text=" Back " CssClass="btn btn-primary" OnClick="btnBack_Click" />
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
            </div>
        </div>
    </form>
</body>
</html>
