<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Send.aspx.cs" Inherits="Swift.web.AgentPanel.Send.SendRegional.Send" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <%--<link href="../../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/menucontrol.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        var urlRoot = "<%=GetStatic.GetUrlRoot() %>";

        $(document).ready(function () {
            $.ajaxSetup({ cache: false });
        });

        $(document).ajaxStart(function () {
            $("#divLoading").show();
        });

        $(document).ajaxComplete(function (event, request, settings) {
            $("#divLoading").hide();
        });
        if (!window.showModalDialog) {
            window.showModalDialog = function (arg1, arg2, arg3) {

                var w;
                var h;
                var resizable = "no";
                var scroll = "no";
                var status = "no";

                // get the modal specs
                var mdattrs = arg3.split(";");
                for (i = 0; i < mdattrs.length; i++) {
                    var mdattr = mdattrs[i].split(":");

                    var n = mdattr[0];
                    var v = mdattr[1];
                    if (n) { n = n.trim().toLowerCase(); }
                    if (v) { v = v.trim().toLowerCase(); }

                    if (n == "dialogheight") {
                        h = v.replace("px", "");
                    } else if (n == "dialogwidth") {
                        w = v.replace("px", "");
                    } else if (n == "resizable") {
                        resizable = v;
                    } else if (n == "scroll") {
                        scroll = v;
                    } else if (n == "status") {
                        status = v;
                    }
                }

                var left = window.screenX + (window.outerWidth / 2) - (w / 2);
                var top = window.screenY + (window.outerHeight / 2) - (h / 2);
                var targetWin = window.open(arg1, arg1, 'toolbar=no, location=no, directories=no, status=' + status + ', menubar=no, scrollbars=' + scroll + ', resizable=' + resizable + ', copyhistory=no, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);
                targetWin.focus();
            };
        }

        function Loading(flag) {
            if (flag == "show")
                ShowElement("divLoading");
            else
                HideElement("divLoading");
        }

        function CheckSession(data) {
            if (data == undefined || data == "" || data == null)
                return;
            if (data[0].session_end == "1") {
                document.location = "../../../Logout.aspx";
            }
        }
        function ManageDeliveryMethod() {
            var dmObj = GetElement("<% =deliveryMethod.ClientID%>");
            var dm = dmObj.options[dmObj.selectedIndex].text;
            if (dm == "Bank Deposit") {
                GetElement("tblLocation").style.display = "none";
                GetElement("tblAccount").style.display = "block";
                ValidatorEnable(GetElement("<%=rfvBankName.ClientID %>"), true);
               ValidatorEnable(GetElement("<%=rfvAcNo.ClientID %>"), true);

               GetElement("spnRIdType").style.display = "none";
               GetElement("spnRIdNo").style.display = "none";
           }
           else {
               GetElement("tblLocation").style.display = "block";
               GetElement("tblAccount").style.display = "none";
               ValidatorEnable(GetElement("<%=rfvBankName.ClientID %>"), false);
               ValidatorEnable(GetElement("<%=rfvAcNo.ClientID %>"), false);

                GetElement("spnRIdType").style.display = "block";
                GetElement("spnRIdNo").style.display = "block";
            }
        }
        $(function () {
            $("#sBranch").change(function () {
                LoadAvailableBalance();
            });
        });

        function PopulateDistrict() {
            var pLocation = GetValue("location");
            $.get(urlRoot + "/AgentPanel/Send/SendRegional/FormLoader.aspx", { type: 'dl', pLocation: pLocation }, function (data) {
                GetElement("divDistrict").innerHTML = data;
            });
            Calculate();
            GetElement("location").focus();
        }
        function PopulateLocation() {
            var pDistrict = GetValue("district");
            $.get(urlRoot + "/AgentPanel/Send/SendRegional/FormLoader.aspx", { type: 'll', pDistrict: pDistrict }, function (data) {
                GetElement("divLocation").innerHTML = data;
            });
            GetElement("district").focus();
        }
        function PopulateBankBranch() {
            var bankId = GetValue("<%=bankName.ClientID %>");
            $.get(urlRoot + "/AgentPanel/Send/SendRegional/FormLoader.aspx", { bankId: bankId, type: 'bb' }, function (data) {
                var res = data;
                GetElement("divBankBranch").innerHTML = res;
            });
        }
        function LoadServiceCharge() {
            Calculate();
        }
        function Calculate() {
            Loading('show');
            var dm = GetValue("<% =deliveryMethod.ClientID%>");
           var amount = GetValue("<%=transferAmt.ClientID %>");
           var pLocation = GetValue("location");
           var sBranch = GetValue("<%=sBranch.ClientID %>");
           var pBankBranch = GetValue("bankBranch");
           if (dm != "Bank Deposit") {
               if (pLocation == null || pLocation == "" || pLocation == "undefined") {
                   window.parent.SetMessageBox("Please Choose Payout Location", '1');
                   Loading('hide');
                   return;
               }
           }
           $.get(urlRoot + "/AgentPanel/Send/SendRegional/FormLoader.aspx", { sBranch: sBranch, pBankBranch: pBankBranch, pLocation: pLocation, amount: amount, dm: dm, type: 'a' }, function (data) {
               var res = data.split('|');
               if (res[0] != "0") {
                   GetElement("<%=serviceCharge.ClientID %>").innerHTML = "";
                   GetElement("<%=collectAmt.ClientID %>").innerHTML = "";
                   window.parent.SetMessageBox(res[1], '1');
                   Loading('hide');
                   return;
               }
               document.getElementById("<%=serviceCharge.ClientID %>").innerHTML = res[1];
               document.getElementById("<%=collectAmt.ClientID %>").innerHTML = res[2];
               if (amount >= 75000) {
                   GetElement("spnIdType").innerHTML = "<span class='errormsg'>*</span>";
                   GetElement("spnIdNo").innerHTML = "<span class='errormsg'>*</span>";
               }
               else {
                   GetElement("spnIdType").innerHTML = "";
                   GetElement("spnIdNo").innerHTML = "";
               }
           });
            Loading('hide');
        }
        function LoadServiceChargeTable() {
            Loading('show');
            var sBranch = GetValue("<%=sBranch.ClientID %>");
           var pLocation = GetValue("location");
           var dm = GetValue("<%=deliveryMethod.ClientID %>");
           var amount = GetValue("<%=transferAmt.ClientID %>");
            var pBankBranch = GetValue("bankBranch");
            $.get(urlRoot + "/AgentPanel/Send/SendRegional/FormLoader.aspx", { sBranch: sBranch, pBankBranch: pBankBranch, pLocation: pLocation, dm: dm, amount: amount, type: 'sct' }, function (data) {
                GetElement("divSc").innerHTML = data;
                ShowHideServiceCharge();
            });
            Loading('hide');
        }
        function LoadAvailableBalance() {
            Loading('show');
            var sBranch = GetValue("<%=sBranch.ClientID %>");
            $.get(urlRoot + "/AgentPanel/Send/SendRegional/FormLoader.aspx", { sBranch: sBranch, type: 'ac' }, function (data) {
                var res = data.split('|');
                if (res[0] != "0") {
                    GetElement("<%=availableAmt.ClientID %>").innerHTML = res[1];
                   return;
               }
               GetElement("<%=availableAmt.ClientID %>").innerHTML = res[1];
           });
            Loading('hide');
        }
        function PickReceiver() {
            Loading('show');
            var rMemId = GetValue("<%=rMembershipId.ClientID %>");
           $.get(urlRoot + "/AgentPanel/Send/SendRegional/FormLoader.aspx", { memId: rMemId, type: 'r' }, function (data) {
               var res = data.split('|');

               if (res[0] != "0") {
                   SetValueById("<%=hddReceiverId.ClientID %>", "", "");
                   SetValueById("<%=hddRMemId.ClientID %>", "", "");
                   window.parent.SetMessageBox(res[1], '1');
                   return;
               }
               SetValueById("<%=hddRMemId.ClientID %>", res[1], "");
               SetValueById("<%=rFirstName.ClientID%>", res[2], "");
               SetValueById("<%=rMiddleName.ClientID %>", res[3], "");
               SetValueById("<%=rLastName1.ClientID %>", res[4], "");
               SetValueById("<%=rLastName2.ClientID %>", res[5], "");
               SetValueById("<%=rAdd.ClientID %>", res[6], "");
               SetValueById("<%=rContactNo.ClientID %>", res[7], "");
               SetValueById("<%=rIdType.ClientID %>", res[8], "");
               SetValueById("<%=rIdNo.ClientID %>", res[9], "");
               SetValueById("<%=hddReceiverId.ClientID %>", res[10], "");
               DisabledReceiverFields();
           });
            Loading('hide');
        }

        function ClearField(section) {
            if (section == "s") {
                SetValueById("<% =sMembershipId.ClientID%>", "", false);
               SetValueById("<% =sFirstName.ClientID%>", "", false);
               SetValueById("<% =sMiddleName.ClientID%>", "", false);
               SetValueById("<% =sLastName1.ClientID%>", "", false);
               SetValueById("<% =sLastName2.ClientID%>", "", false);
               SetValueById("<% =sAdd.ClientID%>", "", false);
               SetValueById("<% =sContactNo.ClientID%>", "", false);
               GetElement("<% =sIdType.ClientID%>").selectedIndex = 0;
               SetValueById("<% =sIdNo.ClientID%>", "", false);
               SetValueById("<% =sEmail.ClientID%>", "", false);
               SetValueById("<% =hddSMemId.ClientID%>", "", false);
               SetValueById("<% =hddSenderId.ClientID%>", "", false);
               EnabledSenderFields();
               HideImages();
           }
           else if (section == "r") {
               SetValueById("<% =rMembershipId.ClientID%>", "", false);
               SetValueById("<% =rFirstName.ClientID%>", "", false);
               SetValueById("<% =rMiddleName.ClientID%>", "", false);
               SetValueById("<% =rLastName1.ClientID%>", "", false);
               SetValueById("<% =rLastName2.ClientID%>", "", false);
               SetValueById("<% =rAdd.ClientID%>", "", false);
               SetValueById("<% =rContactNo.ClientID%>", "", false);
               GetElement("<% =rIdType.ClientID%>").selectedIndex = 0;
               SetValueById("<% =rIdNo.ClientID%>", "", false);
               SetValueById("<% =relWithSender.ClientID%>", "", false);
               SetValueById("<% =hddRMemId.ClientID%>", "", false);
               SetValueById("<% =hddReceiverId.ClientID%>", "", false);
                EnabledReceiverFields();
            }
        }
        function ShowHideServiceCharge() {
            var pos = FindPos(GetElement("btnSCDetails"));
            GetElement("newDiv").style.left = pos[0] + "px";
            GetElement("newDiv").style.top = pos[1] + "px";
            GetElement("newDiv").style.border = "1px solid black";
            if (GetElement("newDiv").style.display == "none" || GetElement("newDiv").style.display == "")
                $("#newDiv").slideToggle("fast");
            else
                $("#newDiv").slideToggle("fast");
        }

        function RemoveDiv() {
            $("#newDiv").slideToggle("fast");
        }

        function MoveWindowToTop() {
            var target = window.parent.document.getElementById('Td1');
            target.scrollIntoView();
        }

        function DisableSendButton() {
            GetElement("btnSend").disabled = true;
        }

        function EnableSendButton() {
            GetElement("btnSend").disabled = false;
        }

        function Send() {
            if (!Page_ClientValidate('sendTran'))
                return false;
            Loading('show');
            var tAmt = parseFloat(GetValue("<%=transferAmt.ClientID %>"));
       var sc = parseFloat(GetElement("<%=serviceCharge.ClientID %>").innerHTML);
       var pDistrictObj = GetElement("district");
       var pDistrict = pDistrictObj.Value;
       var pDistrictName = pDistrictObj.options[pDistrictObj.selectedIndex].text;
       if (pDistrict == "") {
           pDistrictName = "";
       }
       var pLocationObj = GetElement("location");
       var pLocation = pLocationObj.value;
       var pLocationName = pLocationObj.options[pLocationObj.selectedIndex].text;

       var cAmt = GetElement("<% =collectAmt.ClientID%>").innerHTML;
       var dmObj = GetElement("<% =deliveryMethod.ClientID%>");
       var dm = dmObj.options[dmObj.selectedIndex].text;
       if (sc == "" || tAmt == "") {
           EnableSendButton();
           Loading('hide');
           window.parent.SetMessageBox('Cannot Process Transaction. Service Charge not defined', '1');
           MoveWindowToTop();
           GetElement("<%=transferAmt.ClientID %>").focus();
           return false;
       }
       var sBranch = GetValue("<%=sBranch.ClientID %>");
       var pBankBranchObj;
       var pBankObj;
       var pBank = "";
       var pBankBranch = "";
       var accountNo = "";
       var pBankBranchName = "";
       var pBankName = "";
       if (dm == "Bank Deposit") {
           pBankBranchObj = GetElement("bankBranch");
           pBankObj = GetElement("<%=bankName.ClientID %>");
               pBank = pBankObj.value;
               pBankName = pBankObj.options[pBankObj.selectedIndex].text;
               pBankBranch = pBankBranchObj.value;
               pBankBranchName = pBankBranchObj.options[pBankBranchObj.selectedIndex].text;
               accountNo = GetValue("<%=accountNo.ClientID %>");
       }
       var senderId = GetValue("<%=hddSenderId.ClientID %>");
       var sMemId = GetValue("<%=sMembershipId.ClientID %>");
       var sFirstName = GetValue("<%=sFirstName.ClientID %>");
       var sMiddleName = GetValue("<%=sMiddleName.ClientID %>");
       var sLastName1 = GetValue("<%=sLastName1.ClientID %>");
       var sLastName2 = GetValue("<%=sLastName2.ClientID %>");
       var sAddress = GetValue("<%=sAdd.ClientID %>");
       var sContactNo = GetValue("<%=sContactNo.ClientID %>");
       var sIdTypeObj = GetElement("<%=sIdType.ClientID %>");
       var sIdType = sIdTypeObj.options[sIdTypeObj.selectedIndex].text;
       if (sIdTypeObj.value == "")
           sIdType = "";
       var sIdNo = GetValue("<%=sIdNo.ClientID %>");
       var sEmail = GetValue("<%=sEmail.ClientID %>");

       if (tAmt >= 75000 && (sIdType == "" || sIdNo == "")) {
           window.parent.SetMessageBox('Cannot Process Transaction. Sender Id Type & Id Number is required.', '1');
           GetElement("<%=sIdType.ClientID %>").focus();
           return false;
       }

       var receiverId = GetValue("<%=hddReceiverId.ClientID %>");
       var rMemId = GetValue("<%=rMembershipId.ClientID %>");
       var rFirstName = GetValue("<%=rFirstName.ClientID %>");
       var rMiddleName = GetValue("<%=rMiddleName.ClientID %>");
       var rLastName1 = GetValue("<%=rLastName1.ClientID %>");
       var rLastName2 = GetValue("<%=rLastName2.ClientID %>");
       var rAddress = GetValue("<%=rAdd.ClientID %>");
       var rContactNo = GetValue("<%=rContactNo.ClientID %>");
       var rIdTypeObj = GetElement("<%=rIdType.ClientID %>");
       var rIdType = rIdTypeObj.options[rIdTypeObj.selectedIndex].text;
       if (rIdTypeObj.value == "")
           rIdType = "";
       var rIdNo = GetValue("<%=rIdNo.ClientID %>");
       var payMsg = GetValue("<% =remarks.ClientID%>");
       var relObj = GetElement("<% = relWithSender.ClientID %>");
       var rel = relObj.options[relObj.selectedIndex].text;
       if (relObj.value == "")
           rel = "";
       var sofObj = GetElement("<%=sof.ClientID %>");
       var sof = sofObj.options[sofObj.selectedIndex].text;
       if (sofObj.value == "")
           sof = "";

       var porObj = GetElement("<%=por.ClientID %>");
       var por = porObj.options[porObj.selectedIndex].text;
       if (porObj.value == "")
           por = "";
       var occObj = GetElement("<%=occupation.ClientID %>");
            var occ = occObj.options[occObj.selectedIndex].text;
            if (occObj.value == "")
                occ = "";
            var url = "Confirm.aspx?sBranch=" + sBranch +
                "&pDistrict=" + pDistrict +
                "&pDistrictName=" + pDistrictName +
                "&pLocation=" + pLocation +
                "&pLocationName=" + pLocationName +
                "&tAmt=" + tAmt +
                "&sc=" + sc +
                "&cAmt=" + cAmt +
                "&dm=" + dm +
                "&pBankBranch=" + pBankBranch +
                "&pBankBranchName=" + pBankBranchName +
                "&pBank=" + pBank +
                "&pBankName=" + pBankName +
                "&accountNo=" + accountNo +
                "&senderId=" + senderId +
                "&sMemId=" + sMemId +
                "&sFirstName=" + sFirstName +
                "&sMiddleName=" + sMiddleName +
                "&sLastName1=" + sLastName1 +
                "&sLastName2=" + sLastName2 +
                "&sAddress=" + sAddress +
                "&sContactNo=" + sContactNo +
                "&sIdType=" + sIdType +
                "&sIdNo=" + sIdNo +
                "&sEmail=" + sEmail +
                "&receiverId=" + receiverId +
                "&rMemId=" + rMemId +
                "&rFirstName=" + rFirstName +
                "&rMiddleName=" + rMiddleName +
                "&rLastName1=" + rLastName1 +
                "&rLastName2=" + rLastName2 +
                "&rAddress=" + rAddress +
                "&rContactNo=" + rContactNo +
                "&rel=" + rel +
                "&rIdType=" + rIdType +
                "&rIdNo=" + rIdNo +
                "&payMsg=" + payMsg +
                "&sof=" + sof +
                "&por=" + por +
                "&occupation=" + occ;

            var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";
            var id = PopUpWindow(url, param);
            Loading('hide');
            if (id == "undefined" || id == null || id == "") { }
            else {
                var res = id.split('|');
                if (res[0] == "1") {
                    var errormsgArr = res[1].split('\n');
                    for (var i = 0; i < errormsgArr.length; i++) {
                        alert(errormsgArr[i]);
                    }
                    EnableSendButton();
                    Loading('hide');
                    HideElement("divStep3");
                    ShowElement("divStep1");
                    MoveWindowToTop();
                    return false;
                }
                else {
                    window.location.replace("Receipt.aspx?controlNo=" + res[1] + "&invoicePrintMode=" + res[2]);
                }
            }
            return true;
        }

        function ConcatenateName(firstName, middleName, lastName1, lastName2) {
            var fullName = "";
            if (firstName != "")
                fullName = fullName + firstName;
            if (middleName != "")
                fullName = fullName + " " + middleName;
            if (lastName1 != "")
                fullName = fullName + " " + lastName1;
            if (lastName2 != "")
                fullName = fullName + " " + lastName2;
            return fullName;
        }

        $(function () {
            $('#btnFind').click(function () {
                var customerCardNumber = GetValue("<%=sMembershipId.ClientID %>");
               var dataToSend = { MethodName: 'SearchCustomer', customerCardNumber: customerCardNumber };
               var options =
               {
                   url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
                   data: dataToSend,
                   dataType: 'JSON',
                   type: 'POST',
                   success: function (response) {
                       ParseResponseData(response);
                   }
               };
               $.ajax(options);
           });
       });
        function ParseResponseData(response) {
            var data = jQuery.parseJSON(response);
            if (data[0].errCode != "0") {
                SetValueById("<%=hddReceiverId.ClientID %>", "", "");
               SetValueById("<%=hddSenderId.ClientID %>", "", "");
               SetValueById("<%=hddSMemId.ClientID %>", "", "");
               SetValueById("<%=hddRMemId.ClientID %>", "", "");
               window.parent.SetMessageBox(data[0].msg, '1');
               return;
           }
           SetValueById("<%=hddSenderId.ClientID %>", data[0].sCustomerId, "");
           SetValueById("<%=sMembershipId.ClientID %>", data[0].sCustomerCardNo, "");
           SetValueById("<%=sFirstName.ClientID %>", data[0].sFirstName, "");
           SetValueById("<%=sMiddleName.ClientID %>", data[0].sMiddleName, "");
           SetValueById("<%=sLastName1.ClientID %>", data[0].sLastName1, "");
           SetValueById("<%=sLastName2.ClientID %>", data[0].sLastName2, "");
           SetValueById("<%=sAdd.ClientID %>", data[0].sAddress, "");
           SetValueById("<%=sContactNo.ClientID %>", data[0].sMobile, "");
           SetValueById("<%=sIdType.ClientID %>", data[0].sIdType, "");
           SetValueById("<%=sIdNo.ClientID %>", data[0].sIdNumber, "");
           SetValueById("<%=sEmail.ClientID %>", data[0].sEmail, "");
           DisabledSenderFields();

           SetValueById("<%=rMembershipId.ClientID %>", data[0].rCustomerCardNo, "");
           SetValueById("<%=hddReceiverId.ClientID %>", data[0].rCustomerId, "");
           SetValueById("<%=hddRMemId.ClientID %>", data[0].rCustomerCardNo, "");
           SetValueById("<%=rFirstName.ClientID %>", data[0].rFirstName, "");
           SetValueById("<%=rMiddleName.ClientID %>", data[0].rMiddleName, "");
           SetValueById("<%=rLastName1.ClientID %>", data[0].rLastName1, "");
           SetValueById("<%=rLastName2.ClientID %>", data[0].rLastName2, "");
           SetValueById("<%=rAdd.ClientID %>", data[0].rAddress, "");
           SetValueById("<%=rContactNo.ClientID %>", data[0].rMobile, "");
           SetValueById("<%=rIdType.ClientID %>", data[0].rIdType, "");
           SetValueById("<%=rIdNo.ClientID %>", data[0].rIdNumber, "");
           var amount = GetValue("<%=transferAmt.ClientID %>");
            if (amount >= 75000 && data[0].sCustomerId != "") {
                LoadImages(data[0].sCustomerId);
            }
            else
                HideImages();
        }

        function ShowSenderCustomer() {
            var customerCardNumber = GetValue("<%=sMembershipId.ClientID %>");
            if (customerCardNumber == "") {
                alert("Please enter Membership Id!");
                return false;
            }
            var url = urlRoot + "/Remit/Administration/CustomerSetup/Display.aspx?membershipId=" + customerCardNumber + "";
            PopUpWindow(url, "");
        }

        function ViewHistory() {
            var sMembershipId = GetValue("<%=sMembershipId.ClientID %>");
           var sFirstName = GetValue("<%=sFirstName.ClientID %>");
           var sMiddleName = GetValue("<%=sMiddleName.ClientID %>");
           var sLastName = GetValue("<%=sLastName1.ClientID %>");
           var sContactNo = GetValue("<%=sContactNo.ClientID %>");

           var url = urlRoot + "/Remit/Transaction/Send/Domestic/ReceiverHistory.aspx?sMembershipId=" + sMembershipId + "&sFirstName=" + sFirstName + "&sMiddleName=" + sMiddleName + "&sLastName=" + sLastName + "&sContactNo=" + sContactNo;
           var data = PopUpWindowWithCallBack(url, "dialogWidth:800px; dialogHeight:600px;");
           var res = data.split('|');

           if (res[0] != "0") {
               SetValueById("<%=hddReceiverId.ClientID %>", "", "");
               SetValueById("<%=hddRMemId.ClientID %>", "", "");
               SetValueById("<% =rMembershipId.ClientID%>", "", false);
               SetValueById("<% =rFirstName.ClientID%>", "", false);
               SetValueById("<% =rMiddleName.ClientID%>", "", false);
               SetValueById("<% =rLastName1.ClientID%>", "", false);
               SetValueById("<% =rLastName2.ClientID%>", "", false);
               SetValueById("<% =rAdd.ClientID%>", "", false);
               SetValueById("<% =rContactNo.ClientID%>", "", false);
               GetElement("<% =rIdType.ClientID%>").selectedIndex = 0;
               SetValueById("<% =rIdNo.ClientID%>", "", false);
               SetValueById("<% =relWithSender.ClientID%>", "", false);
               window.parent.SetMessageBox(res[1], '1');
               return;
           }
           SetValueById("<%=rMembershipId.ClientID %>", res[1], "");
           SetValueById("<%=hddRMemId.ClientID %>", res[1], "");
           SetValueById("<%=hddReceiverId.ClientID %>", res[2], "");
           SetValueById("<% =rFirstName.ClientID%>", res[3], "");
           SetValueById("<%=rMiddleName.ClientID %>", res[4], "");
           SetValueById("<%=rLastName1.ClientID %>", res[5], "");

           SetValueById("<%=rContactNo.ClientID %>", res[6], "");
           SetValueById("<%=rIdType.ClientID %>", res[7], "");
           SetValueById("<%=rIdNo.ClientID %>", res[8], "");
           SetValueById("<%=rAdd.ClientID %>", res[9], "");
            DisabledReceiverFields();
        }
        function ShowReceiverCustomer() {
            var memId = GetValue("<%=rMembershipId.ClientID %>");
            if (memId == "") {
                alert("Please enter Membership Id!");
                return false;
            }
            var url = urlRoot + "/Remit/Administration/CustomerSetup/Display.aspx?membershipId=" + memId + "";
            PopUpWindow(url, "");
            return true;
        }

        function DisabledSenderFields() {
            $('#sFirstName').attr("readonly", true);
            $('#sMiddleName').attr("readonly", true);
            $('#sLastName1').attr("readonly", true);
            $('#sLastName2').attr("readonly", true);
            $('#sAdd').attr("readonly", true);
            $('#sContactNo').attr("readonly", true);
            GetElement("<%=sIdType.ClientID %>").disabled = true;
            $('#sIdNo').attr("readonly", true);
            $('#sEmail').attr("readonly", true);
        }

        function DisabledReceiverFields() {
            $('#rFirstName').attr("readonly", true);
            $('#rMiddleName').attr("readonly", true);
            $('#rLastName1').attr("readonly", true);
            $('#rContactNo').attr("readonly", true);
            GetElement("<%=rIdType.ClientID %>").disabled = true;
            $('#rIdNo').attr("readonly", true);
            $('#rAdd').attr("readonly", true);
        }
        function EnabledSenderFields() {
            $('#sFirstName').attr("readonly", false);
            $('#sMiddleName').attr("readonly", false);
            $('#sLastName1').attr("readonly", false);
            $('#sLastName2').attr("readonly", false);
            $('#sAdd').attr("readonly", false);
            $('#sContactNo').attr("readonly", false);
            GetElement("<%=sIdType.ClientID %>").disabled = false;
            $('#sIdNo').attr("readonly", false);
            $('#sEmail').attr("readonly", false);
        }

        function EnabledReceiverFields() {
            $('#rFirstName').attr("readonly", false);
            $('#rMiddleName').attr("readonly", false);
            $('#rLastName1').attr("readonly", false);
            $('#rContactNo').attr("readonly", false);
            GetElement("<%=rIdType.ClientID %>").disabled = false;
            $('#rIdNo').attr("readonly", false);
            $('#rAdd').attr("readonly", false);
        }
        function LoadImages(customerId) {
            var dataToSend = { MethodName: "LoadImages", customerId: customerId };
            var options =
            {
                url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success: function (response) {
                    var data = jQuery.parseJSON(response);
                    $("#loadImg").show();
                    GetElement("imgForm").innerHTML = data[0].imgForm;
                    GetElement("imgID").innerHTML = data[0].imgID;
                }
            };
            $.ajax(options);
        }
        function HideImages() {
            $("#loadImg").hide();
            GetElement("imgForm").innerHTML = "";
            GetElement("imgID").innerHTML = "";
        }
    </script>
    <style type="text/css">
        td {
            font-size: 11px;
        }

        .panels {
            padding: 7px;
            margin-bottom: 5px;
            margin-left: 20px;
            width: 100%;
        }

        .panels2 {
            background: #f2f2f2;
            padding: 10px;
            border: 1px solid #fff;
            border-color: #f2f2e6 #666661 #666661 #f2f2e6;
            margin-bottom: 5px;
            margin-left: 20px;
            width: 800px;
            height: 15px;
        }

        .headers {
            margin-left: 30px;
            font-family: Verdana;
            font-size: large;
            font-weight: bold;
            clear: both;
        }

        .label {
            font-family: Verdana;
            font-size: 13px;
            width: 150px;
        }

        .text {
            font-family: Verdana;
            font-size: 13px;
            font-weight: bolder;
        }

        .text-amount {
            font-family: Verdana;
            font-size: 13px;
            text-align: right;
            font-weight: bold;
        }
    </style>
    </head>
<body>
    <form id="form1" runat="server" autocomplete="off">
        <asp:ScriptManager runat="server" ID="sm1"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Transaction</a></li>
                            <li class="active"><a href="#">Send Transaction</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div id="divLoading" style="position: fixed; left: 450px; top: 0px; background-color: white; border: 1px solid black; display: none;">
                <img alt="progress" src="../../../Images/Loading_small.gif" />
                Processing...
            </div>
            <div id="divStep1" class="mainContainer">
                <div class="row">
                    <div class="col-md-12">
                        <div class="row" style="margin-left:8px;">
                            <div class="form-group">
                                 <label class="col-lg-2 col-md-2 control-label" for="">
                                    Branch Name</label>

                               <div class="col-lg-5 col-md-5">
                                    <asp:DropDownList runat="server" ID="sBranch" CssClass="form-control" Width="95%" />
                                </div>
                            </div>
                        </div>
                        <div class="clearfix"></div>
                        <br />
                <div class="panel panel-default margin-b-30">
                    <div class="panel-heading">
                        <h4 class="panel-title">Available Balance:
                    <asp:Label ID="availableAmt" runat="server" BackColor="Yellow" ForeColor="Red"></asp:Label>&nbsp;NPR</h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                        </div>
                    </div>
                    <div class="panel-body">
                        <asp:HiddenField ID="hdnInvoicePrintMethod" runat="server" />
                        <div class="form-group">
                            <label class="col-lg-2 col-md-2 control-label" for="">
                                Delivery Method<span class="errormsg">*</span>
                            </label>
                            <div class="col-lg-5 col-md-5">
                                <asp:DropDownList ID="deliveryMethod" runat="server"
                                    CssClass="requiredField form-control col-sm-offset-0">
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator
                                    ID="RequiredFieldValidator3" runat="server" ControlToValidate="deliveryMethod" ForeColor="Red"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True">
                                </asp:RequiredFieldValidator>
                            </div>
                        </div>
                        <fieldset id="tblAccount" style="display: none;" class="fieldset">
                            <legend>
                                <b>Account Details</b>
                            </legend>

                            <div class="form-group">
                                <label class="col-lg-2 col-md-2 control-label" for="">
                                    Bank Name <span id="spnBankName" runat="server" class="errormsg">*</span>
                                </label>
                                <div class="col-lg-5 col-md-5">
                                    <asp:DropDownList ID="bankName" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvBankName" runat="server" ControlToValidate="bankName"
                                        ForeColor="Red" Enabled="false" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran"
                                        SetFocusOnError="True">                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                                    <div class="form-group">
                                        <label class="col-lg-2 col-md-2 control-label" for="">
                                            Bank Branch Name <span id="spnBranchName" runat="server" class="errormsg">*</span>
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <div id="divBankBranch">
                                                <asp:DropDownList ID="bankBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-2 col-md-2 control-label" for="">
                                            Account No <span id="spnAcNo" runat="server" class="errormsg">*</span>
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <asp:TextBox ID="accountNo" runat="server" CssClass="form-control"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="rfvAcNo" runat="server" ControlToValidate="accountNo"
                                                ForeColor="Red" Enabled="false" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran"
                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                        </fieldset>
                        <div id="tblLocation">
                            <div class="form-group">
                                <label class="col-lg-2 col-md-2 control-label" for="">
                                    Payout Location:
                                        <span class="errormsg">*</span></label>

                                <div class="col-lg-5 col-md-5">
                                    <div id="divLocation" runat="server">
                                        <select id="location" class="form-control" onclick="PopulateDistrict();" ></select>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-lg-2 col-md-2 control-label" for="">
                                    Payout District:
                        <span class="errormsg">*</span></label>

                              <div class="col-lg-5 col-md-5">
                                    <div id="divDistrict" runat="server">
                                        <select id="district" class="form-control" onchange="PopulateLocation();"></select>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-lg-2 col-md-2 control-label" for="">
                                    Transfer Amount:<span class="errormsg">*</span></label>

                                <div class="col-lg-3 col-md-3">
                                    <asp:TextBox runat="server" ID="transferAmt" CssClass="requiredField form-control"></asp:TextBox>
                                    </div>
                                <div class="col-lg-2 col-md-2">
                                    <input type="button" value="Calculate" onclick="CalculateServiceCharge();" class="btn btn-primary btn-sm" / style="margin-top:10px;">
                                    <img class="showHand" title="View Service Charge" id="btnSCDetails" src="../../../images/rule.gif" border="0" onclick="LoadServiceChargeTable()" />
                                    <asp:RequiredFieldValidator
                                        ID="RequiredFieldValidator1" runat="server" ControlToValidate="transferAmt" ForeColor="Red"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True">
                                    </asp:RequiredFieldValidator>
                                    <cc1:FilteredTextBoxExtender ID="ftbe1"
                                        runat="server" Enabled="True" FilterType="Numbers" TargetControlID="transferAmt">
                                    </cc1:FilteredTextBoxExtender>
                                    </div>
                                     <div id="newDiv" style="position: absolute; margin-top: -175px; margin-left: 0px; display: none; z-index: 9999;">

                                        <div class="panel panel-default">
                                            <div class="panel-heading">
                                                <div class="row">
                                                    <div class="col-md-5">
                                                         Service Charge
                                                    </div>
                                                    <div class="col-md-3 pull-right">
                                                         <span title="Close" style="cursor: pointer; margin: 2px; float: right;" onclick=" RemoveDiv(); ">
                                                                <b>x</b></span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="panel-body">
                                                <table cellpadding="0" cellspacing="0" style="background: white;" class="table  table-condensed">
                                                    <tr>
                                                        <td colspan="4">
                                                            <div id="divSc">
                                                                N/A
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-lg-2 col-md-2 control-label" for="">
                                    Service Charge</label>

                                <div class="col-lg-6 col-md-6">
                                    <asp:Label runat="server" ID="serviceCharge"></asp:Label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-2 col-md-2 control-label" for="">
                                    Collect Amount</label>
                                     <div class="col-lg-6 col-md-6">
                                        <span style="font-size: 1.3em; font-weight: bold;">
                                            <asp:Label runat="server" ID="collectAmt"></asp:Label></span>
                                    </div>
                        </div>
                    </div>
                </div>

                <div class="clearfix"></div>

                        <div class="panel panel-default margin-b-30">
                            <div class="panel-heading">
                                <h4 class="panel-title">Enter Sender Information</h4>
                            </div>
                            <div class="panel-body">

                                <div class="form-group">
                                   <label class="col-lg-1 col-md-1 control-label" for="">
                                        <b>Membership ID</b>
                                       </label>

                                     <div class="col-lg-3 col-md-3">
                                        <asp:TextBox runat="server" ID="sMembershipId" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    </div>
                                <div class="form-group">
                                   <div class="col-lg-5 col-md-5 col-md-offset-1">
                                        <input type="button" id="btnFind" class="btn btn-primary btn-sm" value="Find" />
                                        <input type="button" class="btn btn-primary btn-sm" value="Clear Field" onclick="ClearField('s');" />
                                        <input type="button" class="btn btn-primary btn-sm" value="View Customer" onclick="ShowSenderCustomer();" />
                                        <asp:HiddenField ID="hddSMemId" runat="server" />
                                        <asp:HiddenField ID="hddSenderId" runat="server" />
                                        <asp:TextBox ID="sLastName2" runat="server" Style="display: none;"></asp:TextBox>
                                    </div>
                                </div>

                                <div class="form-group">
                                   <label class="col-lg-2 col-md-1 control-label" for="">
                                        First Name <span class="errormsg">*</span>
                                    </label>
                                    <div class="col-lg-3 col-md-3">
                                        <asp:RequiredFieldValidator
                                            ID="RequiredFieldValidator4" runat="server" ControlToValidate="sFirstName" ForeColor="Red"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True"> </asp:RequiredFieldValidator>
                                        <asp:TextBox ID="sFirstName" runat="server" onkeypress="return onlyAlphabets(event,this);" CssClass="requiredField form-control"></asp:TextBox>
                                    </div>
                                    <label class="col-lg-1 col-md-1 control-label" for="">
                                        Middle
                                    </label>
                                     <div class="col-lg-3 col-md-3">
                                        <asp:TextBox ID="sMiddleName" runat="server" onkeypress="return onlyAlphabets(event,this);" CssClass="form-control"></asp:TextBox>
                                    </div>
                                     <label class="col-lg-1 col-md-1 control-label" for="">
                                        Last
                                    </label>
                                     <div class="col-lg-3 col-md-3">
                                        <asp:TextBox ID="sLastName1" runat="server" onkeypress="return onlyAlphabets(event,this);" CssClass="requiredField form-control"></asp:TextBox>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label class="col-lg-1 col-md-1 control-label" for="">
                                        ID Type<span id="spnIdType"></span>
                                    </label>
                                    <div class="col-lg-3 col-md-3">
                                        <asp:DropDownList ID="sIdType" runat="server" CssClass="form-control"></asp:DropDownList>
                                    </div>
                                     <label class="col-lg-1 col-md-1 control-label" for="">
                                        ID No<span id="spnIdNo"></span>
                                    </label>
                                   <div class="col-lg-3 col-md-3">
                                        <asp:TextBox ID="sIdNo" runat="server" CssClass="form-control" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);" onchange="IdNoValidation(this)"></asp:TextBox>
                                    </div>

                                    <label class="col-lg-1 col-md-1 control-label" for="">
                                        Contact No <span class="errormsg">*</span>
                                        <asp:RequiredFieldValidator
                                            ID="RequiredFieldValidator7" runat="server" ControlToValidate="sContactNo" ForeColor="Red"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True">
                                        </asp:RequiredFieldValidator>
                                    </label>
                                   <div class="col-lg-3 col-md-3">
                                        <asp:TextBox ID="sContactNo" onchange="ContactNoValidation(this)" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);" runat="server" CssClass="requiredField form-control"></asp:TextBox>
                                    </div>
                                </div>

                                <div class=" col-sm-12 ">
                                    <div class="alert alert-info" style="color: red; font-weight: bold; font-size: 12px;">
                                        75,000 वा सो भन्दा माथिको कारोबारमा अनिबार्यरुपमा सरकारी मन्यता प्राप्त परिचय
                        पत्र को प्रतिलिपी लिनुका साथै सिस्टममा पनि ID Type तथा ID Number उल्लेख गर्नु
                        होला |
                                    </div>
                                </div>
                                <div class="clearfix"></div>
                                <div class="form-group">
                                    <label class="col-lg-1 col-md-1 control-label" for="">
                                        Email
                                   </label>
                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator6" runat="server"
                                        ValidationGroup="sendTran"
                                        ControlToValidate="sEmail" ErrorMessage="Invalid Email!" SetFocusOnError="True" ForeColor="Red"
                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"> </asp:RegularExpressionValidator>
                                    <div class="col-lg-3 col-md-3">
                                        <asp:TextBox ID="sEmail" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <label class="col-lg-1 col-md-1 control-label" for="">
                                        Address <span class="errormsg">*</span>
                                        <asp:RequiredFieldValidator
                                            ID="RequiredFieldValidator6" runat="server" ControlToValidate="sAdd" ForeColor="Red"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True"> </asp:RequiredFieldValidator>
                                   </label>
                                    <div class="col-lg-3 col-md-3">
                                        <asp:TextBox ID="sAdd" runat="server" TextMode="MultiLine" CssClass="requiredField form-control"></asp:TextBox>
                                    </div>
                                </div>

                                <div class="row panels" style="display: none" id="loadImg">
                                    <div class="col-sm-2">
                                        <div runat="server" id="imgForm" style="float: left; cursor: pointer;">
                                        </div>
                                    </div>
                                    <div class="col-sm-2">
                                        <div runat="server" id="imgID" style="float: left; cursor: pointer;">
                                        </div>
                                    </div>
                                </div>
                            </div>
                            </div>

                         <div class="panel panel-default margin-b-30">
                            <div class="panel-heading">
                                <h4 class="panel-title">Enter Receiver Information</h4>
                            </div>
                            <div class="panel-body">
                                   <div class="form-group">
                                <label class="col-lg-1 col-md-1 control-label" for=""><b>Membership ID</b></label>
                                 <div class="col-lg-3 col-md-3">
                                    <asp:TextBox runat="server" ID="rMembershipId" CssClass="form-control"></asp:TextBox>
                                </div>
                                       </div>
                                <div class="form-group">
                                <div class="col-lg-5 col-md-5 col-md-offset-1">
                                    <input type="button" class="btn btn-primary btn-sm" value="Find" onclick="PickReceiver();" />
                                    <input type="button" class="btn btn-primary btn-sm" value="View History" onclick="ViewHistory();" />
                                    <input type="button" class="btn btn-primary btn-sm" value="Clear Field" onclick="ClearField('r');" />
                                    <input type="button" class="btn btn-primary btn-sm" value="View Customer" onclick="ShowReceiverCustomer();" />
                                    <asp:HiddenField ID="hddRMemId" runat="server" />
                                    <asp:HiddenField ID="hddReceiverId" runat="server" />
                                    <asp:TextBox ID="rLastName2" runat="server" Style="display: none;" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                  <label class="col-lg-1 col-md-1 control-label" for="">
                                    First Name <span class="errormsg">*</span>
                                    <asp:RequiredFieldValidator
                                        ID="RequiredFieldValidator10" runat="server" ControlToValidate="rFirstName" ForeColor="Red"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True"> </asp:RequiredFieldValidator>
                                </label>
                                <div class="col-lg-3 col-md-3">
                                    <asp:TextBox ID="rFirstName" runat="server" CssClass="requiredField form-control" onkeypress="return onlyAlphabets(event,this);"></asp:TextBox>
                                </div>
                                  <label class="col-lg-1 col-md-1 control-label" for="">Middle</label>
                                 <div class="col-lg-3 col-md-3">
                                    <asp:TextBox ID="rMiddleName" runat="server" CssClass="form-control" onkeypress="return onlyAlphabets(event,this);"></asp:TextBox>
                                </div>
                                  <label class="col-lg-1 col-md-1 control-label" for="">Last</label>
                                <div class="col-lg-3 col-md-3">
                                    <asp:TextBox ID="rLastName1" runat="server" CssClass="requiredField form-control" onkeypress="return onlyAlphabets(event,this);"></asp:TextBox>
                                </div>
                            </div>

                            <div class="form-group">
                                 <label class="col-lg-1 col-md-1 control-label" for="">ID Type </label>
                                <div class="col-lg-3 col-md-3">
                                    <asp:DropDownList ID="rIdType" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                                  <label class="col-lg-1 col-md-1 control-label" for="">ID No</label>
                               <div class="col-lg-3 col-md-3">
                                    <asp:TextBox ID="rIdNo" runat="server" CssClass="form-control" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);" onchange="IdNoValidation(this)"></asp:TextBox>
                                </div>

                                  <label class="col-lg-1 col-md-1 control-label" for="">
                                    Contact No <span id="spnRContactNo" class="errormsg">*</span>
                                    <asp:RequiredFieldValidator
                                        ID="rfvRContactNo" runat="server" ControlToValidate="rContactNo" ForeColor="Red"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True">
                                    </asp:RequiredFieldValidator>
                                </label>
                               <div class="col-lg-3 col-md-3">
                                    <asp:TextBox ID="rContactNo" runat="server" CssClass="requiredField form-control"
                                        onchange="ContactNoValidation(this)" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);">
                                    </asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                  <label class="col-lg-1 col-md-1 control-label" for="">
                                    Relationship
                                    with Sender <span id="spnRelWithSender" class="errormsg">*</span>
                                    <asp:RequiredFieldValidator
                                        ID="rfvRelWithSender" runat="server" ControlToValidate="relWithSender" ForeColor="Red"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True"> </asp:RequiredFieldValidator>
                               </label>
                                <div class="col-lg-3 col-md-3">
                                    <asp:DropDownList ID="relWithSender" runat="server" CssClass="requiredField form-control" Width="100%"></asp:DropDownList>
                                </div>

                                 <label class="col-lg-1 col-md-1 control-label" for="">
                                    Address <span id="spnAddress" class="errormsg">*</span>
                                    <asp:RequiredFieldValidator
                                        ID="rfvAddress" runat="server" ControlToValidate="rAdd" ForeColor="Red"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True"> </asp:RequiredFieldValidator>
                                </label>
                                <div class="col-lg-3 col-md-3">
                                    <asp:TextBox ID="rAdd" runat="server" TextMode="MultiLine" Width="100%" CssClass="requiredField form-control"></asp:TextBox>
                                </div>
                            </div>
                            </div>
                        </div>

                         <div class="panel panel-default margin-b-30">
                            <div class="panel-heading">
                                <h4 class="panel-title">Customer Due Diligence Information -(CDDI)</h4>
                            </div>
                            <div class="panel-body">
                               <div class="form-group">
                                  <label class="col-lg-1 col-md-1 control-label" for="">Source Of Fund:</label>
                                <div class="col-lg-3 col-md-3">
                                    <asp:DropDownList runat="server" ID="sof" CssClass="form-control" Width="100%" />
                                </div>
                                     <label class="col-lg-1 col-md-1 control-label" for="">Purpose of Remittance:</label>
                               <div class="col-lg-3 col-md-3">
                                    <asp:DropDownList runat="server" ID="por" CssClass="form-control" Width="100%" />
                                </div>
                            </div>

                            <div class="form-group">
                                  <label class="col-lg-1 col-md-1 control-label" for="">Occupation:</label>
                               <div class="col-lg-3 col-md-3">
                                    <asp:DropDownList ID="occupation" runat="server" CssClass="form-control" Width="100%"></asp:DropDownList>
                                </div>
                                  <label class="col-lg-1 col-md-1 control-label" for="">
                                    Message to Receiver<br />
                               </label>
                               <div class="col-lg-3 col-md-3">
                                    <asp:TextBox ID="remarks" runat="server" TextMode="MultiLine"
                                        CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>

                            <div class="form-group" style="margin-bottom: 100px;">
                              <div class="col-lg-3 col-md-3 col-md-offset-1">
                                    <input type="button" id="btnSend" value="Send Transaction" class="btn btn-primary btn-sm" onclick="Send();" />
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