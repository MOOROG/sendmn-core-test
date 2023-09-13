<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ModifyTran.aspx.cs" Inherits="Swift.web.Remit.Transaction.ApproveModification.ModifyTran" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register Src="../../UserControl/UcTransaction.ascx" TagName="UcTransaction" TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery.gritter.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>

    <script type="text/javascript">
        function CallBack(mes, url) {
            alert("lillwayne");
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] != 0) {
                return;
            }

            window.returnValue = resultList[0];
            window.location.replace(url);
        }
        function PostMessageToParent(controlNo) {
            window.location.href = "/Remit/Transaction/ApproveModification/ModifyTran.aspx?filterControlNo='" + controlNo + "'";
        }
    </script>
</head>
<body>

    <form id="form1" runat="server">

        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>

        <div class="bredCrom" style="width: 90%">Transaction » Modify Transaction</div>
        <asp:UpdatePanel ID="upd1" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
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
                                    <li class="active"><a href="ModifyTran.aspx">Transaction Modification Request</a></li>
                                </ol>
                                <li class="active">
                                    <asp:Label ID="breadCrumb" runat="server"></asp:Label>
                                </li>
                            </div>
                        </div>
                    </div>
                    <div id="divTranDetails" runat="server" visible="false">
                        <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="false" />
                    </div>

                    <asp:Panel ID="pnlCompliance" runat="server" Visible="false">
                        <div class="panel panel-default">
                            <div class="panel-heading">Transaction Modification Request </div>
                            <div class="panel-body">
                                <div style="clear: both;">
                                    <div style="overflow: auto;" id="dispRequest" runat="server" visible="false"></div>
                                    <div>
                                        <br />
                                        <asp:CheckBox ID="chkSms" runat="server" Text="Send SMS to Sender" />
                                        <asp:CheckBox ID="chkEmail" runat="server" Text="Send Email to Agent" />
                                        <br />
                                        <br />
                                        <asp:Button ID="btnReloadDetail" runat="server" OnClick="btnReloadDetail_Click" Style="display: none;" CssClass="btn btn-primary" />
                                        <asp:Button ID="btnApproveAll" runat="server"
                                            Text="Approve" OnClick="btnApproveAll_Click" CssClass="btn btn-primary" />&nbsp;

                    <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" ConfirmText="Confirm To Approve?"
                        Enabled="True" TargetControlID="btnApproveAll">
                    </cc1:ConfirmButtonExtender>

                                        <asp:Button ID="btnReject" runat="server"
                                            Text="Reject" OnClick="btnReject_Click" CssClass="btn btn-danger" />&nbsp;

                    <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender2" runat="server" ConfirmText="Confirm To Reject?"
                        Enabled="True" TargetControlID="btnReject">
                    </cc1:ConfirmButtonExtender>

                                        <input type="button" id="btnBack" class="btn btn-primary" style="margin-left: 0px;" value="Back"
                                            onclick="window.location.replace('RequestTxnModification.aspx');" />
                                        <asp:HiddenField ID="hdTranId" runat="server" />
                                        <asp:HiddenField ID="hdRowId" runat="server" />
                                    </div>
                                </div>

                            </div>
                        </div>
                    </asp:Panel>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>

</body>
</html>
<script language="javascript">
    function EditData(label, fieldName, oldValue, tranId) {
        var url = "../Modify/ModifyField.aspx?label=" + label +
            "&fieldName=" + fieldName +
            "&oldValue=" + oldValue +
            "&tranId=" + tranId;


        var id = PopUpWindow(url, "");
        if (id == "undefined" || id == null || id == "") {
        }
        else {
            GetElement("<%=btnReloadDetail.ClientID %>").click();
        }
        return false;
    }

    function EditPayoutLocation(label, fieldName, oldValue, tranId) {
        var url = "../Modify/ModifyLocation.aspx?label=" + label +
            "&fieldName=" + fieldName +
            "&oldValue=" + oldValue +
            "&tranId=" + tranId;


        var id = PopUpWindow(url, "");
        if (id == "undefined" || id == null || id == "") {
        }
        else {
            GetElement("<%=btnReloadDetail.ClientID %>").click();
        }
        return false;
    }

</script>
