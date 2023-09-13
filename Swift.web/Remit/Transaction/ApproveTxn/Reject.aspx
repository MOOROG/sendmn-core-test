<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Reject.aspx.cs" Inherits="Swift.web.Remit.Transaction.ApproveTxn.Reject" %>

<%@ Register TagPrefix="cc1" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit, Version=3.0.20820.16598, Culture=neutral, PublicKeyToken=28f01b0e84b6d53e" %>
<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransaction.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <base id="Base1" target="_self" runat="server" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />

    <link href="/css/style.css" rel="stylesheet" type="text/css" />
    <link href="/css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/Swift_grid.js" type="text/javascript"></script>
    <link href="/js/jQuery/jquery.gritter.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
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
    </style>
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
        function CheckRequiredField() {
            var reqField = "remarks,";
            if ($('#hddIsRealTime').val() == 'True') {
                reqField = "remarks,ddlRemarks,";
            }

            if (ValidRequiredField(reqField) == true) {
                return true;
            }
        }
        function RejectClicked() {
            if (CheckRequiredField()) {
                var partnerRemarks = '';
                var partnerRemarksText = '';
                if ($('#hddIsRealTime').val() == 'True') {
                    partnerRemarks = $('#ddlRemarks').val();
                    partnerRemarksText = $("#ddlRemarks option:selected").text();
                }

                var res = confirm("Confirm to Reject ?");
                if (res == true) {
                    $.ajax({
                        type: "POST",
                        url: "Reject.aspx",
                        data: {
                            MethodName: "RejectClicked", id: "<%=GetTranNo()%>"
                            , remarks: $('#remarks').val()
                            , partnerRemarksId: partnerRemarks
                            , partnerRemarksText: partnerRemarksText
                        },
                        success: function (response) {
                            if (response.ErrorCode == "0") {
                                alert(response.Msg);
                                opener.location.href = 'holdTxnList.aspx';
                                close();
                            } else {
                                alert(response.Msg);
                            }
                        },
                        fail: function () {
                            alert("Something went wrong");
                        }
                    });
                }
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:Button ID="hdnBtn" runat="server" Style="display: none;" />
        <asp:HiddenField ID="hddPartnerPin" runat="server" />
        <asp:HiddenField ID="hddIsRealTime" runat="server" />
        <asp:HiddenField ID="hddPartnerId" runat="server" />
        <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
        <div id="divControlno" runat="server">
            <div class="page-wrapper">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="page-title">
                            <h1></h1>
                            <ol class="breadcrumb">
                                <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                                <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                                <li class="active"><a href="Reject.aspx">Reject Transaction Details </a></li>
                            </ol>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default recent-activites">
                            <!-- Start .panel -->
                            <div class="panel-heading">
                                <h4 class="panel-title">Detail Of Hold Approval Waiting Transaction
                                </h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>

                            <div class="panel-body">
                                <div class="form-group">
                                    <div id="divTranDetails" runat="server" visible="false">
                                        <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="false" ShowCompliance="false" ShowOfac="false" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>Remarks:  <span class="errormsg">*</span></label>
                                            <asp:TextBox ID="remarks" runat="server" TextMode="MultiLine" ValidationGroup="reject" class="form-control"></asp:TextBox>

                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3"
                                                runat="server" ControlToValidate="remarks" ValidationGroup="reject" Display="Dynamic" ErrorMessage="Required!" ForeColor="Red">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                     <div class="col-md-12" id="partnerRemarksDiv" runat="server">
                                        <div class="form-group">
                                            <label>Remarks For Partner:  <span class="errormsg">*</span></label>
                                            <asp:DropDownList ID="ddlRemarks" runat="server" class="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <div class="form-group">
                                                <%--<asp:Button ID="btnReject" runat="server" Text=" Reject " ValidationGroup="reject"
                                                OnClick="btnReject_Click" />--%>
                                                <input type="button" id='btnReject' value="Reject" onclick="RejectClicked()" />

                                                <%--    <cc1:ConfirmButtonExtender ID="btnReject1" runat="server"
                                                    ConfirmText="Confirm To Reject ?" Enabled="True" TargetControlID="btnReject">
                                                </cc1:ConfirmButtonExtender>--%>
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
