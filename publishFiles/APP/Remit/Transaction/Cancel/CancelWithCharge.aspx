<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CancelWithCharge.aspx.cs" Inherits="Swift.web.Remit.Transaction.Cancel.CancelWithCharge" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransaction.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <%-- <link href="../../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <link href="../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
        function GridCallBack() {
            GetElement("<% =btnTranSelect.ClientID%>").click();
        }
        function CallBack(mes, url) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] != 0) {
                return;
            }

            window.returnValue = resultList[0];
            window.location.replace(url);
        }
    </script>
</head>
<body>

    <form id="form1" runat="server">
        <asp:ScriptManager runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-md-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="CancelWithCharge.aspx">Cancel With Charge Transaction </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <asp:UpdateProgress ID="updProgress" AssociatedUpdatePanelID="upd1" runat="server">
                <ProgressTemplate>
                    <div style="position: fixed; left: 450px; top: 0px; background-color: white; border: 1px solid black;">
                        <img alt="progress" src="../../../Images/Loading_small.gif" />
                        Processing...
                    </div>
                </ProgressTemplate>
            </asp:UpdateProgress>
            <asp:UpdatePanel ID="upd1" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">
                                        <asp:Label ID="header" runat="server" Text="Search By"></asp:Label></h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div>
                                        <div id="tblSearch" runat="server">
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td valign="top">
                                                        <div id="searchDiv" runat="server">
                                                            <table class="table table-responsive">
                                                                <tr>
                                                                    <td>
                                                                        <b><%=GetStatic.GetTranNoName()%></b>
                                                                        <span class="errormsg">*</span>
                                                                        <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="controlNo"
                                                                            ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="srh"
                                                                            SetFocusOnError="True">
                                                                        </asp:RequiredFieldValidator>
                                                                        <br />
                                                                        <asp:TextBox ID="controlNo" runat="server" CssClass="form-control" Width="400px"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:Button ID="btnSearch" runat="server" Text="Search" ValidationGroup="srh" CssClass="btn btn-primary m-t-25"
                                                                            OnClick="btnSearch_Click" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                        <div id="divTranDetails" runat="server" visible="false">
                                                            <div>
                                                                <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="false" />
                                                            </div>
                                                            <div class="headers">Choose Action</div>
                                                            <div class="panels">
                                                                <table class="table table-responsive">
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <asp:Button ID="btnReject" CssClass="btn btn-primary m-t-25" runat="server" Text="Reject Cancel Request"
                                                                                OnClick="btnReject_Click" />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td valign="top">
                                                                            <b>Cancel Reason<span class="errormsg">*</span></b>
                                                                        </td>
                                                                        <td>
                                                                            <asp:TextBox ID="cancelReason" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>

                                                                            <asp:RequiredFieldValidator ID="Rfd1" runat="server" ControlToValidate="cancelReason"
                                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="cancel" ForeColor="Red"
                                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        </td>
                                                                    </tr>
                                                                    <%--<tr>
                                                                        <td valign="top">
                                                                            <b>Refund Commission ?<span class="errormsg">*</span></b>
                                                                        </td>
                                                                        <td>
                                                                            <asp:DropDownList ID="refund" runat="server" CssClass="form-control">
                                                                                <asp:ListItem Value="D">Default</asp:ListItem>
                                                                            </asp:DropDownList>
                                                                        </td>
                                                                    </tr>--%>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <asp:Button ID="btnCancel" runat="server" Text="Cancel Transaction" ValidationGroup="cancel" CssClass="btn btn-primary m-t-25" OnClick="btnCancel_Click" />&nbsp;&nbsp;&nbsp;&nbsp;
                                                            <cc1:ConfirmButtonExtender ID="btnCancelcc" runat="server"
                                                                ConfirmText="Confirm To Cancel Transaction?" Enabled="True" TargetControlID="btnCancel">
                                                            </cc1:ConfirmButtonExtender>
                                                                            <input type="button" id="btnBack" value="Back" class="btn btn-primary m-t-25" onclick=" Javascript: history.back(); " />
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <asp:HiddenField ID="hddTran" runat="server" />
                    <asp:HiddenField ID="hddRCustomerId" runat="server" />
                    <asp:Button ID="btnTranSelect" runat="server" CssClass="btn btn-primary" Text="Select" Style="display: none;" OnClick="btnTranSelect_Click" />

                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
    </form>
</body>
</html>
