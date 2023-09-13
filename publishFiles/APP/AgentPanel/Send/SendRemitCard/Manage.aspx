<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentPanel.Send.SendRemitCard.Manage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Send Transaction</title>
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        $.validator.messages.required = "Required!";
        $(document).ready(function () {
            $("#form1").validate();
        });

        function Loading(flag) {
            if (flag == "show")
                ShowElement("DivLoad");
            else
                HideElement("DivLoad");
        }
        function CheckSession(data) {
            if (data == undefined || data == "" || data == null)
                return;
            if (data[0].session_end == "1") {
                document.location = "../../../Logout.aspx";
            }
        }
        function LoadReceiver() {
            Loading('show');
            var remitCardNo = GetValue("<%=remitCardNo.ClientID %>");
            var dataToSend = { MethodName: 'lc', remitCardNo: remitCardNo };
            var options =
                        {
                            url: '<%=ResolveUrl("Manage.aspx") %>?x=' + new Date().getTime(),
                            data: dataToSend,
                            dataType: 'JSON',
                            type: 'POST',
                            success: function (response) {
                                var data = jQuery.parseJSON(response);
                                CheckSession(data);
                                if (data[0].errorCode != "0") {

                                    GetElement("<%=benefName.ClientID %>").innerHTML = "";
                                    GetElement("<%=benefAddress.ClientID %>").innerHTML = "";
                                    GetElement("<%=benefMobile.ClientID %>").innerHTML = "";
                                    GetElement("<%=benefIdType.ClientID %>").innerHTML = "";
                                    GetElement("<%=benefIdNo.ClientID %>").innerHTML = "";
                                    GetElement("<%=senderName.ClientID %>").value = "";
                                    GetElement("<%=senderAddress.ClientID %>").value = "";
                                    GetElement("<%=senderMobile.ClientID %>").value = "";
                                    GetElement("<%=senderIdType.ClientID %>").value = "";
                                    GetElement("<%=senderIdNo.ClientID %>").value = "";
                                    GetElement("<%=hddReceiverRemitCard.ClientID %>").value = "";
                                    GetElement("<%=hddSenderRemitCard.ClientID %>").value = "";
                                    window.parent.SetMessageBox(data[0].msg, '1');
                                    Loading('hide');
                                    return;
                                }
                                GetElement("<%=benefName.ClientID %>").innerHTML = data[0].fullName;
                                GetElement("<%=benefAddress.ClientID %>").innerHTML = data[0].pAddress;
                                GetElement("<%=benefMobile.ClientID %>").innerHTML = data[0].mobileP;
                                GetElement("<%=benefIdType.ClientID %>").innerHTML = data[0].idCardType;
                                GetElement("<%=benefIdNo.ClientID %>").innerHTML = data[0].idCardNo;
                                GetElement("<%=senderName.ClientID %>").value = data[0].fullName;
                                GetElement("<%=senderAddress.ClientID %>").value = data[0].pAddress;
                                GetElement("<%=senderMobile.ClientID %>").value = data[0].mobileP;
                                GetElement("<%=senderIdType.ClientID %>").value = data[0].idCardType;
                                GetElement("<%=senderIdNo.ClientID %>").value = data[0].idCardNo;
                                GetElement("<%=senderRemitCardNo.ClientID %>").value = data[0].remitCardNo;
                                GetElement("<%=hddReceiverRemitCard.ClientID %>").value = data[0].remitCardNo;
                                GetElement("<%=hddSenderRemitCard.ClientID %>").value = data[0].remitCardNo;
                                DisabledSenderFields();
                            }
                        };
                        $.ajax(options);
                        Loading('hide');
                        return true;
                    }

                    function ClearReceiver() {
                        GetElement("<%=benefName.ClientID %>").innerHTML = "";
            GetElement("<%=benefAddress.ClientID %>").innerHTML = "";
            GetElement("<%=benefMobile.ClientID %>").innerHTML = "";
            GetElement("<%=benefIdType.ClientID %>").innerHTML = "";
            GetElement("<%=benefIdNo.ClientID %>").innerHTML = "";
            GetElement("<%=hddReceiverRemitCard.ClientID %>").value = "";
            GetElement("<%=remitCardNo.ClientID %>").value = "";
            return true;
        }
        function ClearSender() {
            GetElement("<%=senderName.ClientID %>").value = "";
            GetElement("<%=senderAddress.ClientID %>").value = "";
            GetElement("<%=senderMobile.ClientID %>").value = "";
            GetElement("<%=senderIdType.ClientID %>").value = "";
            GetElement("<%=senderIdNo.ClientID %>").value = "";
            GetElement("<%=hddSenderRemitCard.ClientID %>").value = "";
            GetElement("<%=senderRemitCardNo.ClientID %>").value = "";
            EnabledSenderFields();
            return true;
        }
        function LoadSender() {
            Loading('show');
            var remitCardNo = GetValue("<%=senderRemitCardNo.ClientID %>");
            var dataToSend = { MethodName: 'lc', remitCardNo: remitCardNo };
            var options =
                        {
                            url: '<%=ResolveUrl("Manage.aspx") %>?x=' + new Date().getTime(),
                            data: dataToSend,
                            dataType: 'JSON',
                            type: 'POST',
                            success: function (response) {
                                var data = jQuery.parseJSON(response);
                                CheckSession(data);
                                if (data[0].errorCode != "0") {
                                    GetElement("<%=senderName.ClientID %>").value = "";
                                    GetElement("<%=senderAddress.ClientID %>").value = "";
                                    GetElement("<%=senderMobile.ClientID %>").value = "";
                                    GetElement("<%=senderIdType.ClientID %>").value = "";
                                    GetElement("<%=senderIdNo.ClientID %>").value = "";
                                    GetElement("<%=hddSenderRemitCard.ClientID %>").value = "";
                                    window.parent.SetMessageBox(data[0].msg, '1');
                                    Loading('hide');
                                    return;
                                }
                                GetElement("<%=senderName.ClientID %>").value = data[0].fullName;
                                GetElement("<%=senderAddress.ClientID %>").value = data[0].pAddress;
                                GetElement("<%=senderMobile.ClientID %>").value = data[0].mobileP;
                                GetElement("<%=senderIdType.ClientID %>").value = data[0].idCardType;
                                GetElement("<%=senderIdNo.ClientID %>").value = data[0].idCardNo;
                                GetElement("<%=hddSenderRemitCard.ClientID %>").value = data[0].remitCardNo;
                                DisabledSenderFields();
                            }
                        };
                        $.ajax(options);
                        GetElement("<%=serviceCharge.ClientID %>").innerHTML = "";
                        GetElement("<%=collectAmt.ClientID %>").innerHTML = "";
            Loading('hide');
            return true;
        }

        function DisabledSenderFields() {
            $('#senderName').attr("readonly", true);
            $('#senderAddress').attr("readonly", true);
            $('#senderMobile').attr("readonly", true);
            GetElement("<%=senderIdType.ClientID %>").disabled = true;
            $('#senderIdNo').attr("readonly", true);
            $('#hddSenderRemitCard').attr("readonly", true);
        }
        function EnabledSenderFields() {
            $('#senderName').attr("readonly", false);
            $('#senderAddress').attr("readonly", false);
            $('#senderMobile').attr("readonly", false);
            GetElement("<%=senderIdType.ClientID %>").disabled = false;
            $('#senderIdNo').attr("readonly", false);
            $('#hddSenderRemitCard').attr("readonly", false);
        }
        function CalculateServiceCharge() {
            Loading('show');
            var tAmt = GetValue("<%=tAmt.ClientID %>");
            var rRemitCardNo = GetValue("<%=remitCardNo.ClientID %>");
            var rName = GetElement("<% =benefName.ClientID%>").innerHTML;
            var rMobile = GetElement("<% =benefMobile.ClientID%>").innerHTML;
            var rIdNo = GetElement("<% =benefIdNo.ClientID%>").innerHTML;

            var sRemitCardNo = GetValue("<%=senderRemitCardNo.ClientID %>");
            var sName = GetValue("<%=senderName.ClientID %>");
            var sMobile = GetValue("<%=senderMobile.ClientID %>");
            var sIdNo = GetValue("<%=senderIdNo.ClientID %>");
            var dataToSend = { MethodName: 'sc', tAmt: tAmt };
            var options =
                        {
                            url: '<%=ResolveUrl("Manage.aspx") %>?x=' + new Date().getTime(),
                            data: dataToSend,
                            dataType: 'JSON',
                            type: 'POST',
                            success: function (response) {
                                var data = jQuery.parseJSON(response);
                                CheckSession(data);
                                if (data[0].errorCode != "0") {
                                    GetElement("<%=serviceCharge.ClientID %>").innerHTML = "";
                                    GetElement("<%=collectAmt.ClientID %>").innerHTML = "";
                                    window.parent.SetMessageBox(data[0].msg, '1');
                                    Loading('hide');
                                    return;
                                }
                                //self sender deposit sc = 0
                                if ($.trim(rRemitCardNo) == $.trim(sRemitCardNo) && $.trim(rName) == $.trim(sName) && $.trim(rMobile) == $.trim(sMobile) && $.trim(rIdNo) == $.trim(sIdNo)) {
                                    document.getElementById("<%=serviceCharge.ClientID %>").innerHTML = "0";
                                    document.getElementById("<%=collectAmt.ClientID %>").innerHTML = tAmt;
                                }
                                else {
                                    document.getElementById("<%=serviceCharge.ClientID %>").innerHTML = data[0].serviceCharge;
                                    document.getElementById("<%=collectAmt.ClientID %>").innerHTML = data[0].cAmt;
                                }
                            }
                        };
                        $.ajax(options);
                        Loading('hide');
                        return true;
                    }
                    $(function () {
                        $('#btnSend').click(function () {
                            if ($("#form1").validate().form() == false) {
                                $(".required").each(function () {
                                    if (!$.trim($(this).val())) {
                                        $(this).focus();
                                    }

                                });
                                return false;
                            }
                            Loading('show');
                            var tAmt = parseFloat(GetValue("<%=tAmt.ClientID %>"));
                var cAmt = GetElement("<% =collectAmt.ClientID%>").innerHTML;
                var sc = GetElement("<% =serviceCharge.ClientID%>").innerHTML;
                if (sc == "" || tAmt == "") {
                    Loading('hide');
                    window.parent.SetMessageBox('Cannot Process Transaction. Service Charge not defined', '1');
                    MoveWindowToTop();
                    GetElement("<%=tAmt.ClientID %>").focus();
                    return false;
                }
                var cusId = GetValue("<%=hddReceiverRemitCard.ClientID %>");
                var cusName = GetElement("<% =benefName.ClientID%>").innerHTML;
                if (cusId == "" || cusId == null || cusName == "" || cusName == null) {
                    Loading('hide');
                    window.parent.SetMessageBox('Cannot Process Transaction. KYC customer can not be blank.', '1');
                    MoveWindowToTop();
                    return false;
                }
                var cusAddress = GetElement("<% =benefAddress.ClientID%>").innerHTML;
                var cusMobile = GetElement("<% =benefMobile.ClientID%>").innerHTML;
                var cusIdType = GetElement("<% =benefIdType.ClientID%>").innerHTML;
                var cusIdNo = GetElement("<% =benefIdNo.ClientID%>").innerHTML;
                var senName = GetValue("<%=senderName.ClientID %>");
                var senAddress = GetValue("<%=senderAddress.ClientID %>");
                var senMobile = GetValue("<%=senderMobile.ClientID %>");
                var senIdType = GetValue("<%=senderIdType.ClientID %>");
                var senIdNo = GetValue("<%=senderIdNo.ClientID %>");
                var senRemitCardNo = GetValue("<%=hddSenderRemitCard.ClientID %>");
                var purposeOfRemit = GetValue("<% = purpose.ClientID %>");
                var sourceOfFund = GetValue("<%=sourceOfFund.ClientID %>");
                var remarks = GetValue("<%=remarks.ClientID %>");
                var url = "Confirm.aspx?remitCardNo=" + cusId +
                    "&cusName=" + cusName +
                    "&cusAddress=" + cusAddress +
                    "&cusMobile=" + cusMobile +
                    "&cusIdType=" + cusIdType +
                    "&cusIdNo=" + cusIdNo +
                    "&tAmt=" + tAmt +
                    "&sc=" + sc +
                    "&cAmt=" + cAmt +
                    "&senName=" + senName +
                    "&senAddress=" + senAddress +
                    "&senMobile=" + senMobile +
                    "&senIdType=" + senIdType +
                    "&senIdNo=" + senIdNo +
                    "&senRemitCardNo=" + senRemitCardNo +
                    "&purposeOfRemit=" + purposeOfRemit +
                    "&sourceOfFund=" + sourceOfFund +
                    "&remarks=" + remarks;
                Loading('hide');
                var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";
                var id = PopUpWindow(url, param);

                if (id == "undefined" || id == null || id == "") {
                }
                else {
                    var res = id.split('|');
                    if (res[0] == "1") {
                        var errMsgArr = res[1].split('\n');
                        for (var i = 0; i < errMsgArr.length; i++) {
                            alert(errMsgArr[i]);
                        }
                    }
                    else {
                        window.location.replace("Receipt.aspx?controlNo=" + res[1]);
                    }
                }
                return true;
            });
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper" style="margin-top: 100px;">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>Send Transaction
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Send Money</a></li>
                            <li class="active"><a href="#">Send Money To IME Remit Card </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div id="DivLoad" style="position: absolute; height: 20px; width: 220px; background-color: #333333; display: none; left: 300px; top: 150px;">
                <img src="../../../images/progressBar.gif" border="0" alt="Loading..." />
            </div>
            <div class="headers">Card Holder's Information</div>
            <div class="panels">
                <table>
                    <tr>
                        <td colspan="2">
                            <div style="font-size: 1.3em; background: white;">
                                <table>
                                    <tr>
                                        <th style="text-align: left; width: 320px">Available Balance:
                                <asp:Label ID="availableAmt" runat="server" BackColor="Yellow" ForeColor="Red"></asp:Label>&nbsp;NPR
                                        </th>
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap" style="width: 125px">Remit Card Number:</td>
                        <td nowrap="nowrap">
                            <asp:TextBox runat="server" ID="remitCardNo" Width="150px"></asp:TextBox>
                            <span class="ErrMsg">*</span>
                            <input type="button" value="Find" onclick="LoadReceiver();" />
                            <input type="button" value="Clear Field" onclick="ClearReceiver();" />
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap" style="width: 130px">Name:
                        </td>
                        <td colspan="2">
                            <asp:Label runat="server" Width="95%" ID="benefName"></asp:Label>
                        </td>
                        <td></td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap">Address:
                        </td>
                        <td>
                            <asp:Label runat="server" ID="benefAddress"></asp:Label>
                        </td>
                        <td>Mobile:
                        </td>
                        <td>
                            <asp:Label runat="server" ID="benefMobile"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>ID Type:
                        </td>
                        <td>
                            <asp:Label runat="server" ID="benefIdType"></asp:Label>
                        </td>
                        <td>ID No.:
                        </td>
                        <td>
                            <asp:Label runat="server" ID="benefIdNo"></asp:Label>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="headers">Enter Sender's Information</div>
            <div class="panels">
                <table>
                    <tr>
                        <td nowrap="nowrap" style="width: 125px">Remit Card Number:</td>
                        <td nowrap="nowrap">
                            <asp:TextBox runat="server" ID="senderRemitCardNo" Width="150px"></asp:TextBox>
                            <span class="ErrMsg">*</span>
                            <input type="button" value="Find" onclick="LoadSender();" />
                            <input type="button" value="Clear Field" onclick="ClearSender();" />
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap" style="width: 130px">Name:
                        </td>
                        <td colspan="3">
                            <asp:TextBox ID="senderName" Width="300px" runat="server" CssClass="required"></asp:TextBox>
                            <span class="ErrMsg">*</span>
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap">Address:
                        </td>
                        <td nowrap="nowrap">
                            <asp:TextBox ID="senderAddress" Width="200px" runat="server" CssClass="required"></asp:TextBox>
                            <span class="ErrMsg">*</span>
                        </td>
                        <td nowrap="nowrap">Mobile:
                        </td>
                        <td nowrap="nowrap">
                            <asp:TextBox ID="senderMobile" Width="150px" runat="server" CssClass="required"></asp:TextBox>
                            <span class="ErrMsg">*</span>
                        </td>
                    </tr>
                    <tr>
                        <td>ID Type:
                        </td>
                        <td>
                            <asp:DropDownList ID="senderIdType" runat="server" Width="145px" CssClass="required">
                            </asp:DropDownList>
                            <span class="ErrMsg">*</span>
                        </td>
                        <td>ID No.:
                        </td>
                        <td>
                            <asp:TextBox ID="senderIdNo" Width="150px" runat="server" CssClass="required"></asp:TextBox>
                            <span class="ErrMsg">*</span>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="headers">Enter Transaction Information</div>
            <div class="panels">
                <table>
                    <tr>
                        <td nowrap="nowrap" style="width: 130px">Transaction Amount:
                        </td>
                        <td colspan="3">
                            <asp:TextBox ID="tAmt" Width="100px" runat="server" CssClass="required"></asp:TextBox>
                            <input type="button" value="Calculate" onclick="CalculateServiceCharge();" class="button" />
                            <span class="ErrMsg">*</span>
                        </td>
                    </tr>
                    <tr>
                        <td>Service Charge:</td>
                        <td colspan="3">
                            <asp:Label runat="server" ID="serviceCharge"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>Collect Amount:</td>
                        <td colspan="3">
                            <span style="font-size: 1.3em; font-weight: bold;">
                                <asp:Label runat="server" ID="collectAmt"></asp:Label></span>
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap">Purpose Of Remittance: &nbsp;
                        </td>
                        <td colspan="3">
                            <asp:DropDownList ID="purpose" runat="server" Width="180px" CssClass="required">
                            </asp:DropDownList>
                            <span class="ErrMsg">*</span>
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap">Source Of Fund:
                        </td>
                        <td colspan="3">
                            <asp:DropDownList ID="sourceOfFund" runat="server" Width="180px" CssClass="required">
                            </asp:DropDownList>
                            <span class="ErrMsg">*</span>
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap">Remarks:
                        </td>
                        <td colspan="3">
                            <asp:TextBox ID="remarks" TextMode="MultiLine" Width="95%" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>&nbsp;</td>
                        <td colspan="3">
                            <input type="button" name="btnSend" id="btnSend" value="Send Transaction" />
                            <asp:HiddenField ID="hddReceiverRemitCard" runat="server" />
                            <asp:HiddenField ID="hddSenderRemitCard" runat="server" />
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </form>
</body>
</html>