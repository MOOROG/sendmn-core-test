<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SendV2.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.Send.Domestic.SendV2" %>
<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../../../js/menucontrol.js" type="text/javascript"></script>
    <script src="../../../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../../../../js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    
    <style>
     .ui-button
     {
         color:Red !important;
         font-weight:bold  !important;
         font-size:10px !important;      }           
      
      .ui-button:first-child
      {
        color:Green !important;    
      } 
    </style>
    <script type="text/javascript">
        var urlRoot = "<%=GetStatic.GetUrlRoot() %>";

        $(document).ready(function () {

            $("#lblalternateMobileNo").hide();
            $("#alternateMobileNo").hide();
            $("#spanalternateMobileNo").hide();
            $('tr.issuemember').hide();
            $('tr td div.issuemember').hide();
            $.ajaxSetup({ cache: false });

            FilterIdIssuedPlace();

            $("#<%=sIdType.ClientID %>").change(function () {
                var val = $(this).val().split('|')[1];
                if (val == 'N') {
                    $("#<%=trIdExpiryDate.ClientID %>").hide();
                    SetValueById("<%=txtSendIdValidDate.ClientID%>", "", "");
                    SetValueById("<%=txtSendIdValidDateBs.ClientID %>", "", "");
                }
                else {
                    $("#<%=trIdExpiryDate.ClientID %>").show();
                }
                FilterIdIssuedPlace();
            });
        });

        $(document).ajaxStart(function () {
            $("#divLoading").show();
            $("#DivLoad").show();

        });

        $(document).ajaxComplete(function (event, request, settings) {
            $("#divLoading").hide();
            $("#DivLoad").hide();
        });

        function Loading(flag) {
            if (flag == "show")
                ShowElement("divLoading");
            else
                HideElement("divLoading");
        }

        function LoadServiceCharge() {
            Calculate();
        }

        function PopulateDistrict() {
            var pLocation = GetValue("location");
            $.get(urlRoot + "/Remit/Transaction/Agent/Send/Domestic/FormLoader.aspx", { type: 'dl', pLocation: pLocation }, function (data) {
                GetElement("divDistrict").innerHTML = data;
            });
            Calculate();
            GetElement("location").focus();
        }
        function PopulateLocation() {
            var pDistrict = GetValue("district");
            $.get(urlRoot + "/Remit/Transaction/Agent/Send/Domestic/FormLoader.aspx", { type: 'll', pDistrict: pDistrict }, function (data) {
                GetElement("divLocation").innerHTML = data;
            });
            GetElement("district").focus();
        }
        function LoadServiceChargeTable() {
            Loading('show');
            var sBranch = "";
            var pLocation = GetValue("location");
            var dm = GetValue("<%=deliveryMethod.ClientID %>");
            var amount = GetValue("<%=transferAmt.ClientID %>");
            var pBankBranch = GetValue("bankBranch");
            $.get(urlRoot + "/Remit/Transaction/Agent/Send/Domestic/FormLoader.aspx", { sBranch: sBranch, pBankBranch: pBankBranch, pLocation: pLocation, dm: dm, amount: amount, type: 'sct' }, function (data) {
                GetElement("divSc").innerHTML = data;
                ShowHideServiceCharge();
            });
            Loading('hide');
        }
        function PopulateBankBranch() {
            var bankId = GetValue("<%=bankName.ClientID %>");
            $.get(urlRoot + "/Remit/Transaction/Agent/Send/Domestic/FormLoader.aspx", { bankId: bankId, type: 'bb' }, function (data) {
                var res = data;
                GetElement("divBankBranch").innerHTML = res;
            });
        }
        function ManageDeliveryMethod() {
            var dmObj = GetElement("<% =deliveryMethod.ClientID%>");
            var dm = GetValueForSelectedIndex(dmObj); // dmObj.options[dmObj.selectedIndex].text;
            if (dm == "Bank Deposit") {
                //GetElement("tblLocation").style.display = "none";
                $("#tblLocation").hide();
                $("#tblAccount").show();
                //GetElement("tblAccount").style.display = "block";
                ValidatorEnable(GetElement("<%=rfvBankName.ClientID %>"), true);
                ValidatorEnable(GetElement("<%=rfvAcNo.ClientID %>"), true);

                $("#spnRContactNo").hide();
                $("#spnRIdType").hide();
                $("#spnRIdNo").hide();
                //GetElement("spnRContactNo").style.display = "none";
                //GetElement("spnRIdType").style.display = "none";
                //GetElement("spnRIdNo").style.display = "none";
            }
            else {
                //GetElement("tblLocation").style.display = "block";
                //GetElement("tblAccount").style.display = "none";
                $("#tblLocation").show();
                $("#tblAccount").hide();
                ValidatorEnable(GetElement("<%=rfvBankName.ClientID %>"), false);
                ValidatorEnable(GetElement("<%=rfvAcNo.ClientID %>"), false);

                $("#spnRContactNo").show();
                $("#spnRIdType").show();
                $("#spnRIdNo").show();
                //GetElement("spnRContactNo").style.display = "block";
                //GetElement("spnRIdType").style.display = "block";
                //GetElement("spnRIdNo").style.display = "block";
            }
        }
        function LoadAvailableBalance() {
            Loading('show');
            var sBranch = "";
            $.get(urlRoot + "/Remit/Transaction/Agent/Send/Domestic/FormLoader.aspx", { sBranch: sBranch, type: 'ac' }, function (data) {
                var res = data.split('|');
                if (res[0] != "0") {
                    GetElement("<%=availableAmt.ClientID %>").innerHTML = res[1];
                    return;
                }
                GetElement("<%=availableAmt.ClientID %>").innerHTML = res[1];
            });
            Loading('hide');
        }

        function PickSender() {
            Loading('show');
            var sMemId = GetValue("<%=sMembershipId.ClientID %>");

            $.get(urlRoot + "/Remit/Transaction/Agent/Send/Domestic/FormLoader.aspx", { memId: sMemId, type: 's' }, function (data) {
                var res = data.split('|');
                if (res[0] != "0") {
                    SetValueById("<%=hddSenderId.ClientID %>", "", "");
                    SetValueById("<%=hddSMemId.ClientID %>", "", "");
                    window.parent.SetMessageBox(res[1], '1');
                    return;
                }
                SetValueById("<%=hddSMemId.ClientID %>", res[1], "");
                SetValueById("<% =sFirstName.ClientID%>", res[2], "");
                SetValueById("<%=sMiddleName.ClientID %>", res[3], "");
                SetValueById("<%=sLastName1.ClientID %>", res[4], "");
                SetValueById("<%=sLastName2.ClientID %>", res[5], "");
                SetValueById("<%=sAdd.ClientID %>", res[6], "");
                SetValueById("<%=sContactNo.ClientID %>", res[7], "");
                SetValueById("<%=sIdType.ClientID %>", res[8], "");
                SetValueById("<%=sIdNo.ClientID %>", res[9], "");
                SetValueById("<%=hddSenderId.ClientID %>", res[10], "");
                DisabledSenderFields();
            });
            Loading('hide');
        }

        function PickReceiver() {
            Loading('show');
            var rMemId = GetValue("<%=rMembershipId.ClientID %>");

            $.get(urlRoot + "/Remit/Transaction/Agent/Send/Domestic/FormLoader.aspx", { memId: rMemId, type: 'r' }, function (data) {

                var res = data.split('|');
                if (res[0] != "0") {
                    SetValueById("<%=hddReceiverId.ClientID %>", "", "");
                    SetValueById("<%=hddRMemId.ClientID %>", "", "");
                    window.parent.SetMessageBox(res[1], '1');
                    return;
                }


                SetValueById("<%=hddRMemId.ClientID %>", res[1], "");
                SetValueById("<% =rFirstName.ClientID%>", res[2], "");
                SetValueById("<%=rMiddleName.ClientID %>", res[3], "");
                SetValueById("<%=rLastName1.ClientID %>", res[4], "");
                SetValueById("<%=rLastName2.ClientID %>", res[5], "");
                SetValueById("<%=rAdd.ClientID %>", res[6], "");
                SetValueById("<%=rContactNo.ClientID %>", res[7], "");
                SetValueById("<%=rIdType.ClientID %>", res[8], "");
                SetValueById("<%=rIdNo.ClientID %>", res[9], "");
                SetValueById("<%=hddReceiverId.ClientID %>", res[10], "");
                ShowReceiverCustomerPopup();
                DisabledReceiverFields();
            });
            Loading('hide');
        }

        function ShowAlternateContactForTopUp(contactNo) {
            $("#lblalternateMobileNo").hide();
            $("#alternateMobileNo").hide();
            $("#spanalternateMobileNo").hide();

            var topUpNum = contactNo.substring(0, 3);
            if (topUpNum == '980' || topUpNum == '981' || topUpNum == '982' || topUpNum == '984' || topUpNum == '986') {
                $("#lblalternateMobileNo").hide();
                $("#alternateMobileNo").hide();
            } else {
                $("#lblalternateMobileNo").show();
                $("#alternateMobileNo").show();
                $("#spanalternateMobileNo").show();
            }
        }

        function Calculate() {
            Loading('show');
            var dm = GetValue("<% =deliveryMethod.ClientID%>");
            var tAmt = GetValue("<%=transferAmt.ClientID %>");
            var pLocation = GetValue("location");
            var pBankBranch = GetValue("bankBranch");

            var thresholdAmt = GetValue("<%=hdnThresholdAmt.ClientID %>");
            if (thresholdAmt == "")
                thresholdAmt = "50000";

            if (tAmt == "") {
                Loading('hide');
                return false;
            }
            if (dm == "Cash Payment") {
                if (pLocation == null || pLocation == "" || pLocation == "undefined") {
                    window.parent.SetMessageBox("Please Choose Payout Location", '1');
                    Loading('hide');
                    return false;
                }
            }
            var dataToSend = { MethodName: 'sc', pBankBranch: pBankBranch, pLocation: pLocation, tAmt: tAmt, dm: dm };
            var options =
                        {
                            url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
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
                                document.getElementById("<%=serviceCharge.ClientID %>").innerHTML = data[0].serviceCharge;
                                document.getElementById("<%=collectAmt.ClientID %>").innerHTML = data[0].cAmt;
                                SetValueById("<%=hdnInvoicePrintMethod.ClientID %>", data[0].invoiceMethod, "");
                                if (parseFloat(tAmt) >= parseFloat(thresholdAmt)) {
                                    GetElement("spnsIdType").innerHTML = "<span class='ErrMsg'>*</span>";
                                    GetElement("spnsIdNo").innerHTML = "<span class='ErrMsg'>*</span>";
                                }
                                else {
                                    GetElement("spnsIdType").innerHTML = "";
                                    GetElement("spnsIdNo").innerHTML = "";
                                }
                                ManageSendIdValidity();
                            }
                        };
                        $.ajax(options);
                        Loading('hide');
                        return true;
                    }
                    function CheckSession(data) {
                        if (data == undefined || data == "" || data == null)
                            return;
                        if (data[0].session_end == "1") {
                            document.location = "../../../../../Logout.aspx";
                        }
                    }
                    function ClearField(section) {
                        if (section == "s") {
                            $("#alternateMobileNo").text();
                            $("#lblalternateMobileNo").hide();
                            $("#alternateMobileNo").hide();
                            $("#spanalternateMobileNo").hide();
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
                SetValueById("<% =txtSenIdIssuedDate.ClientID%>", "", false);
                SetValueById("<% =txtSendIdValidDate.ClientID%>", "", false);
                GetElement("<% =sIdIssuedPlace.ClientID%>").selectedIndex = 0;
                SetValueById("<% =txtSendDOB.ClientID%>", "", false);
                SetValueById("<% =txtSendDOBBs.ClientID%>", "", false);
                SetValueById("<% =txtSenIdIssuedDateBs.ClientID%>", "", false);
                SetValueById("<% =txtSendIdValidDateBs.ClientID%>", "", false);
                SetValueById("<% =txtCustCardId.ClientID%>", "", false);
                $('#txtCustCardId').attr("readonly", false);
                SetValueById("<% =hddIssueCustCardInfoSaved.ClientID%>", "", false);
                SetValueById("<% =hddIssueCustCardId.ClientID%>", "", false);
                SetValueById("<% =hddsIdPlaceOfIssue.ClientID%>", "", false);

                GetElement("<% =occupation.ClientID%>").selectedIndex = 0;
                GetElement("<% =ddlGender.ClientID%>").selectedIndex = 0;
                SetValueById("<% =txtfathermothername.ClientID%>", "", false);

                GetElement("<%=chkIssueCustCard.ClientID %>").disabled = false;
                var ischecked = $("#chkIssueCustCard").is(':checked');
                if (ischecked) {
                    $('#chkIssueCustCard').attr('checked', false);
                    $('tr.issuemember').hide();
                    $('tr td div.issuemember').hide();
                    $('tr td div.searchsender').show();
                }

                EnabledSenderFields();
                FilterIdIssuedPlace();
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
                GetElement("<% =relWithSender.ClientID%>").selectedIndex = 0;
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
        return true;
        var target = window.parent.document.getElementById('Td1');
        target.scrollIntoView();
    }

    function Rectify() {
        HideElement("divStep2");
        ShowElement("divStep1");
        MoveWindowToTop();
    }
    function Proceed() {

        var IsTxnDocExists = GetValue("<%=hdnIsTxnDocExists.ClientID %>");
            var IsTxnDocReq = GetValue("<%=hdnIsTxnDocReq.ClientID %>");

            if (IsTxnDocReq == "required" && (IsTxnDocExists == "false" || IsTxnDocExists == "")) {
                window.parent.SetMessageBox('This transaction required transaction related document. Please upload it and proceed further.', '1');
                return;
            }

            if (!ValidateMultipleTxn()) return;

            HideElement("divStep2");
            ShowElement("divStep3");
            GetElement("collAmtForVerify").focus();
            MoveWindowToTop();
        }
        function DisableSendButton() {
            GetElement("btnFinish").disabled = true;
        }

        function EnableSendButton() {
            GetElement("btnFinish").disabled = false;
        }
        function ValidateMultipleTxn() {

            //alert($('#divChkMultipleTxn').is(':visible'));
            //alert($('#divChkMultipleTxn').css('display'));
            //alert($("#chkMultipleTxn").is(':checked'));

            if ($('#divChkMultipleTxn').is(':visible') || $('#divChkMultipleTxn').css('display') != 'none') {
                var ischecked = $("#chkMultipleTxn").is(':checked'); //$('#chkMultipleTxn')[0].checked;
                if (!ischecked) {
                    window.parent.SetMessageBox('You have not verified multiple transactions warnings. Please Check, if you want to continue with warnings.', '1');
                    GetElement("<%=transferAmt.ClientID %>").focus();
                    return false;
                }
            }
            return true;
        }

        function Send() {
            DisableSendButton();
            Loading('show');
            var tAmt = parseFloat(GetValue("<%=transferAmt.ClientID %>"));
            var sc = parseFloat(GetElement("<%=serviceCharge.ClientID %>").innerHTML);
            var collAmtForVerify = parseFloat(GetValue("collAmtForVerify"));
            if ((tAmt + sc) != collAmtForVerify) {
                EnableSendButton();
                Loading('hide');
                window.parent.SetMessageBox('Collection Amount doesnot match. Please check the amount details.', '1');
                HideElement("divStep3");
                ShowElement("divStep1");
                MoveWindowToTop();
                return false;
            }
            var pDistrictObj = GetElement("district");
            var pDistrict = pDistrictObj.Value;
            var pDistrictName = "";
            try {
                pDistrictName = pDistrictObj.options[pDistrictObj.selectedIndex].text;
            } catch (ex) { }
            if (pDistrict == "") {
                pDistrictName = "";
            }
            var pLocationObj = GetElement("location");
            var pLocation = pLocationObj.value;
            var pLocationName = "";
            try {
                pLocationName = pLocationObj.options[pLocationObj.selectedIndex].text;
            } catch (ex) { }
            var ta = GetValue("<% =transferAmt.ClientID%>");
            var tc = GetElement("<% =collectAmt.ClientID%>").innerHTML;
            var dmObj = GetElement("<% =deliveryMethod.ClientID%>");

            var dm = "";
            try {
                dm = dmObj.options[dmObj.selectedIndex].text;
            } catch (ex) { }
            if (sc == "" || tc == "") {
                EnableSendButton();
                Loading('hide');
                window.parent.SetMessageBox('Cannot Process Transaction. Service Charge not defined', '1');
                HideElement("divStep3");
                ShowElement("divStep1");
                MoveWindowToTop();
                GetElement("<%=transferAmt.ClientID %>").focus();
                return false;
            }

            var sBranch = "";
            var sBranchText = "";
            var pBankBranchObj;
            var pBankObj;
            var pBank = "";
            var pBankText = "";
            var pBankBranch = "";
            var pBankBranchText = "";
            var accountNo = "";
            if (dm == "Bank Deposit") {
                pBankBranchObj = GetElement("bankBranch");
                pBankObj = GetElement("<%=bankName.ClientID %>");
                pBank = pBankObj.value;
                pBankText = pBankObj.options[pBankObj.selectedIndex].text;
                pBankBranch = pBankBranchObj.value;

                try {
                    pBankBranchText = GetValueForSelectedIndex(pBankBranchObj); //.options[pBankBranchObj.selectedIndex].text;
                } catch (ex) { }
                accountNo = GetValue("<%=accountNo.ClientID %>");
                pLocation = "";
                pLocationName = "";
                ShowElement("bankDetail");
                GetElement("spanBankName").innerHTML = pBankText;
                GetElement("spanBankBranchName").innerHTML = pBankBranchText;
                GetElement("spanAccountNo").innerHTML = accountNo;
            }

            var senderId = GetValue("<%=hddSenderId.ClientID %>");
            var IssueCustCardId = GetValue("<%=hddIssueCustCardId.ClientID %>");

            if (senderId == "" && IssueCustCardId != "") {
                senderId = IssueCustCardId;
            }

            var sMemId = GetValue("<%=sMembershipId.ClientID %>");
            var CustCardId = GetValue("<%=txtCustCardId.ClientID %>");

            if (sMemId == "" && CustCardId != "")
                sMemId = CustCardId;

            var sFirstName = GetValue("<%=sFirstName.ClientID %>");
            var sMiddleName = GetValue("<%=sMiddleName.ClientID %>");
            var sLastName1 = GetValue("<%=sLastName1.ClientID %>");
            var sLastName2 = GetValue("<%=sLastName2.ClientID %>");
            var sAddress = GetValue("<%=sAdd.ClientID %>");
            var sContactNo = GetValue("<%=sContactNo.ClientID %>");
            var sIdTypeObj = GetElement("<%=sIdType.ClientID %>");
            var sIdType = "";

            try {
                sIdType = sIdTypeObj.options[sIdTypeObj.selectedIndex].text;
            } catch (ex) { }
            if (sIdTypeObj.value == "")
                sIdType = "";

            //var senIdType = $("#sIdType").val();
            var senIdTypeArr = $("#sIdType").val().split('|');
            //alert(senIdTypeArr[0]);

            var sIdNo = GetValue("<%=sIdNo.ClientID %>");
            var sEmail = GetValue("<%=sEmail.ClientID %>");

            var receiverId = GetValue("<%=hddReceiverId.ClientID %>");
            var rMemId = GetValue("<%=rMembershipId.ClientID %>");
            var rFirstName = GetValue("<%=rFirstName.ClientID %>");
            var rMiddleName = GetValue("<%=rMiddleName.ClientID %>");
            var rLastName1 = GetValue("<%=rLastName1.ClientID %>");
            var rLastName2 = GetValue("<%=rLastName2.ClientID %>");
            var rAddress = GetValue("<%=rAdd.ClientID %>");
            var rContactNo = GetValue("<%=rContactNo.ClientID %>");
            var rIdTypeObj = GetElement("<%=rIdType.ClientID %>");

            var rIdType = "";
            try {
                rIdType = rIdTypeObj.options[rIdTypeObj.selectedIndex].text;
            } catch (ex) { }
            if (rIdTypeObj.value == "")
                rIdType = "";
            var rIdNo = GetValue("<%=rIdNo.ClientID %>");
            var payMsg = GetValue("<% =remarks.ClientID%>");
            var relObj = GetElement("<% = relWithSender.ClientID %>");
            var rel = GetValueForSelectedIndex(relObj); //.options[relObj.selectedIndex].text;
            var txtPass = GetValue("<% =txnPassword.ClientID%>");

            if (relObj.value == "") rel = "";

            var sofObj = GetElement("<%=sof.ClientID %>");
            var sof = "";
            try {
                sof = sofObj.options[sofObj.selectedIndex].text;
            } catch (ex) { }
            if (sofObj.value == "")
                sof = "";
            var porObj = GetElement("<%=por.ClientID %>");
            var por = "";
            try {
                por = porObj.options[porObj.selectedIndex].text;
            } catch (ex) { }
            if (porObj.value == "")
                por = "";
            var occObj = GetElement("<%=occupation.ClientID %>");

            var occ = "";
            try {
                occ = occObj.options[occObj.selectedIndex].text;
            } catch (ex) { }

            if (occObj.value == "")
                occ = "";

            var alternateMobileNo = GetValue("<%=alternateMobileNo.ClientID %>");

            var agentRefId = GetValue("<%=hdnAgentRefId.ClientID %>");
            var complianceAction = GetValue("<%=hdnComplianceAction.ClientID %>");
            var compApproveRemark = GetValue("<%=hdnCompApproveRemark.ClientID %>");
            var txnBatchId = GetValue("<%=hdnTxnBatchId.ClientID %>");

            var sIdValidDate = GetValue("<%=txtSendIdValidDate.ClientID %>");
            var sDOB = GetValue("<%=txtSendDOB.ClientID %>");

            var sIdIssuedPlace = $("#sIdIssuedPlace").val();

            var sIdIssuedDate = GetValue("<%=txtSenIdIssuedDate.ClientID %>");

            var sIdValidDateBs = GetValue("<%=txtSendIdValidDateBs.ClientID %>");
            var sDOBBs = GetValue("<%=txtSendDOBBs.ClientID %>");
            var sIdIssuedDateBs = GetValue("<%=txtSenIdIssuedDateBs.ClientID %>");

            var CustCardId = GetValue("<%=txtCustCardId.ClientID %>");
            var gender = "";
            var motherFatherName = "";
            var isIssueCardchecked = $("#chkIssueCustCard").is(':checked');
            if (isIssueCardchecked) {
                gender = GetValue("<%=ddlGender.ClientID %>");
                motherFatherName = GetValue("<%=txtfathermothername.ClientID %>");
            }

            $.get(urlRoot + "/Remit/Transaction/Agent/Send/Domestic/FormLoader.aspx", {
                sBranch: sBranch, pDistrict: pDistrictName, pLocation: pLocation, ta: ta, sc: sc, tc: tc, dm: dm
                     , pBankBranch: pBankBranch, accountNo: accountNo
                     , senderId: senderId, sMemId: sMemId, sFirstName: sFirstName, sMiddleName: sMiddleName, sLastName1: sLastName1, sLastName2: sLastName2
                     , sAddress: sAddress, sContactNo: sContactNo, sIdType: senIdTypeArr[0], sIdNo: sIdNo, sEmail: sEmail
                     , receiverId: receiverId, rMemId: rMemId, rFirstName: rFirstName, rMiddleName: rMiddleName, rLastName1: rLastName1, rLastName2: rLastName2
                     , rAddress: rAddress, rContactNo: rContactNo, rel: rel, rIdType: rIdType, rIdNo: rIdNo, sDOB: sDOB, sIdIssuedPlace: sIdIssuedPlace, sIdIssuedDate: sIdIssuedDate, sIdValidDate: sIdValidDate
                     , sDOBBs: sDOBBs, sIdIssuedDateBs: sIdIssuedDateBs, sIdValidDateBs: sIdValidDateBs, CustCardId: CustCardId
                     , payMsg: payMsg, txtPass: txtPass, sof: sof, por: por, occupation: occ, gender: gender, motherFatherName: motherFatherName
                     , type: 'st', topupMobileNo: alternateMobileNo, agentRefId: agentRefId, complianceAction: complianceAction, compApproveRemark: compApproveRemark, txnBatchId: txnBatchId
            }, function (data) {
                var res = data.split('|');
                if (res[0] != "0") {
                    EnableSendButton();
                    Loading('hide');
                    alert(res[1]);
                    //window.parent.SetMessageBox(res[1], '1');
                    HideElement("divStep3");
                    ShowElement("divStep1");
                    MoveWindowToTop();
                    return;
                }
                window.location.replace(urlRoot + "/Remit/Transaction/Agent/ReprintReceipt/SendReceipt.aspx?controlNo=" + res[2]);
            });
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
        function pageLoadonDemand(myvalue) {
            SetValueById("<%=hdnIsTxnDocExists.ClientID %>", myvalue, "");
        }

        function SaveCustInfoToIssueCard() {

            var senderId = GetValue("<%=hddSenderId.ClientID %>");
            var custId = GetValue("<%=hddIssueCustCardId.ClientID %>");
            var sMemId = GetValue("<%=txtCustCardId.ClientID %>");
            var sFirstName = GetValue("<%=sFirstName.ClientID %>");
            var sMiddleName = GetValue("<%=sMiddleName.ClientID %>");
            var sLastName1 = GetValue("<%=sLastName1.ClientID %>");
            var sLastName2 = GetValue("<%=sLastName2.ClientID %>");
            var sAddress = GetValue("<%=sAdd.ClientID %>");
            var sContactNo = GetValue("<%=sContactNo.ClientID %>");
            var sIdTypeObj = GetElement("<%=sIdType.ClientID %>");
            var sIdType = sIdTypeObj.options[sIdTypeObj.selectedIndex].value;
            var sIdNo = GetValue("<%=sIdNo.ClientID %>");
            var senIdType = $("#sIdType").val();
            var senIdTypeArr = senIdType.split('|');
            var sEmail = GetValue("<%=sEmail.ClientID %>");

            var sIdIssuedPlace = $("#sIdIssuedPlace").val();

            var sIdIssuedDate = GetValue("<%=txtSenIdIssuedDate.ClientID %>");
            var sIdValidDate = GetValue("<%=txtSendIdValidDate.ClientID %>");
            var sDOB = GetValue("<%=txtSendDOB.ClientID %>");

            var sIdIssuedDateBs = GetValue("<%=txtSenIdIssuedDateBs.ClientID %>");
            var sIdValidDateBs = GetValue("<%=txtSendIdValidDateBs.ClientID %>");
            var sDOBBs = GetValue("<%=txtSendDOBBs.ClientID %>");

            var occObj = GetElement("<%=occupation.ClientID %>");
            var occ = occObj.options[occObj.selectedIndex].value;
            var gender = GetValue("<%=ddlGender.ClientID %>");
            var motherFatherName = GetValue("<%=txtfathermothername.ClientID %>");

            if (sMemId == "") {
                alert('Customer Card Id should not be blank.');
                return;
            }

            if (senIdType != "") {
                //alert('Please select customer Id type.');
                //return;

                if (sIdNo == "") {
                    alert('Customer Id no. should not be blank when Id type is selected.');
                    return;
                }
                if (sIdIssuedPlace == "") {
                    alert('Customer Id Issued place should not be blank when Id type is selected.');
                    return;
                }
            }

            if (sFirstName == "") {
                alert('Customer name should not be blank.');
                return;
            }
            if (sContactNo == "") {
                alert('Customer contact no. should not be blank.');
                return;
            }
            /*
            if (sDOB == "") {
            alert('Customer D.O.B should not be blank.');
            return;
            }
            if (sIdIssuedDate == "") {
            alert('Customer ID issued date should not be blank.');
            return;
            }
            if (senIdTypeArr[1] == "E") {
            if (sIdValidDate == "") {
            alert('Customer ID expired date should not be blank.');
            return;
            }
            }*/
            if (sAddress == "") {
                alert('Customer address should not be blank.');
                return;
            }
            if (gender == "") {
                alert('Please select customer gender.');
                return;
            }
            if (motherFatherName == "") {
                alert('Customer Mother Father name should not be blank.');
                return;
            }
            if (occ == "") {
                alert('Please select customer occupation.');
                return;
            }

            GetElement("spnCustomerEnrollMsg").innerHTML = '';
            $('#spnCustomerEnrollMsg').removeClass(function () {
                return $(this).attr("class");
            });

            var dataToSend = {
                MethodName: 'issuecard'
                     , senderId: senderId, sMemId: sMemId, sFirstName: sFirstName, sMiddleName: sMiddleName, sLastName1: sLastName1, sLastName2: sLastName2
                     , sAddress: sAddress, sContactNo: sContactNo, sIdType: senIdTypeArr[0], sIdNo: sIdNo, sIdIssuedPlace: sIdIssuedPlace, sIdIssuedDate: sIdIssuedDate, sEmail: sEmail, occupation: occ, sGender: gender, sDOB: sDOB, sIdValidDate: sIdValidDate
                     , motherFatherName: motherFatherName, type: 'issuecard', custId: custId, sIdIssuedDateBs: sIdIssuedDateBs, sDOBBs: sDOBBs, sIdValidDateBs: sIdValidDateBs
            };
            var options =
                        {
                            url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                            data: dataToSend,
                            dataType: 'JSON',
                            type: 'POST',
                            async: false,
                            beforeSend: function () {
                                Loading('show');
                            },
                            success: function (response) {
                                var data = jQuery.parseJSON(response);
                                if (data[0].errorCode == "0") {
                                    window.parent.SetMessageBox(data[0].msg, '0');

                                    //SuccessMsg
                                    GetElement("spnCustomerEnrollMsg").innerHTML = data[0].msg;
                                    $('#spnCustomerEnrollMsg').addClass('SuccessMsg');

                                    $('#txtCustCardId').attr("readonly", true);
                                    GetElement("<%=chkIssueCustCard.ClientID %>").disabled = true;
                                    SetValueById("<%=hddIssueCustCardInfoSaved.ClientID %>", "true", "");
                                    SetValueById("<%=hddIssueCustCardId.ClientID %>", data[0].id, "");
                                    ShowElement("uploadDocForCustCard");
                                }
                                else {
                                    window.parent.SetMessageBox(data[0].msg, '1');
                                    GetElement("spnCustomerEnrollMsg").innerHTML = data[0].msg;
                                    $('#spnCustomerEnrollMsg').addClass('ErrorAlert');
                                    SetValueById("<%=hddIssueCustCardInfoSaved.ClientID %>", "false", "");
                                    SetValueById("<%=hddIssueCustCardId.ClientID %>", "", "");
                                    HideElement("uploadDocForCustCard");
                                }
                            },
                            error: function (xhr) { // if error occured                                
                                alert("Error occured." + xhr.statusText + xhr.responseText);
                            },
                            complete: function () {
                                Loading('hide');
                            }
                        };
                        $.ajax(options);

                    }



                    $(function () {
                        $('#btnFind').click(function () {
                            var customerCardNumber = GetValue("<%=sMembershipId.ClientID %>");
                var sAmount = "0";
                if (!isNaN(GetValue("<%=transferAmt.ClientID %>")) && GetValue("<%=transferAmt.ClientID %>") != "") {
                    sAmount = parseFloat(GetValue("<%=transferAmt.ClientID %>"));
                }

                var dataToSend = { MethodName: 'SearchCustomer', customerCardNumber: customerCardNumber, sAmount: sAmount };
                var options =
                        {
                            url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                            data: dataToSend,
                            dataType: 'JSON',
                            type: 'POST',
                            success: function (response) {
                                ParseResponseData(response);
                            }
                        };
                $.ajax(options);
            });


            $('#chkIssueCustCard').click(function () {
                if ($(this).attr('checked')) {
                    $('tr td div.issuemember').show();
                    $('tr.issuemember').show(); //custCardSection
                    $('tr td div.searchsender').hide();
                    HideElement("uploadDocForCustCard");
                    $("#sIdType option[value='6208|E']").remove();
                }
                else {

                    SetValueById("<% =txtCustCardId.ClientID%>", "", false);
                    GetElement("<% =ddlGender.ClientID%>").selectedIndex = 0;
                    SetValueById("<% =txtfathermothername.ClientID%>", "", false);
                    SetValueById("<% =hddIssueCustCardInfoSaved.ClientID%>", "", false);
                    SetValueById("<% =hddIssueCustCardId.ClientID%>", "", false);
                    GetElement("spnCustomerEnrollMsg").innerHTML = '';
                    $('#spnCustomerEnrollMsg').removeClass(function () {
                        return $(this).attr("class");
                    });

                    $('tr td div.issuemember').hide();
                    $('tr.issuemember').hide();
                    $('tr td div.searchsender').show();
                    $("#sIdType").append($("<option value='6208|E'>Valid Government ID</option>"));
                }
            });

            $('#txnPassword').keypress(function (event) {
                var keycode = (event.keyCode ? event.keyCode : event.which);
                if (keycode == '13') {
                    $("#btnFinish").click();
                }

            });

            $('#sIdIssuedPlace').change(function () {
                var IdIssuedPlaceSelected = $("#sIdIssuedPlace").val();
                SetValueById("<%=hddsIdPlaceOfIssue.ClientID %>", IdIssuedPlaceSelected, "");
                SetIDTypeIssuedPlace();
            });
        });
        function ParseResponseData(response) {
            var data = jQuery.parseJSON(response);

            if (data[0].errCode != "0") {
                SetValueById("<%=hddReceiverId.ClientID %>", "", "");
                SetValueById("<%=hddSenderId.ClientID %>", "", "");
                SetValueById("<%=hddSMemId.ClientID %>", "", "");
                SetValueById("<%=hddRMemId.ClientID %>", "", "");
                SetValueById("<%=sMembershipId.ClientID %>", "", "");
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
            SetValueById("<%=sIdType.ClientID %>", data[0].sIdType1);
            $("#sIdType").trigger("change");

            SetValueById("<%=sIdNo.ClientID %>", data[0].sIdNumber, "");
            SetValueById("<%=sEmail.ClientID %>", data[0].sEmail, "");

            SetValueById("<%=txtSenIdIssuedDate.ClientID %>", data[0].sIdIssuedDate, "");
            SetValueById("<%=txtSenIdIssuedDateBs.ClientID %>", data[0].sIdIssuedDateBs, "");
            SetValueById("<%=txtSendIdValidDate.ClientID %>", data[0].sIdExpiryDate, "");
            SetValueById("<%=txtSendIdValidDateBs.ClientID %>", data[0].sIdExpiryDateBs, "");
            SetValueById("<%=txtSendDOB.ClientID %>", data[0].sDOB, "");
            SetValueById("<%=txtSendDOBBs.ClientID %>", data[0].sDOBBs, "");
            SetDDlByText("<%=sIdIssuedPlace.ClientID %>", data[0].sPlaceOfIssue, "");
            SetValueById("<%=hddsIdPlaceOfIssue.ClientID %>", data[0].sPlaceOfIssue, "");
            SetIDTypeIssuedPlace();
            SetValueById("<%=occupation.ClientID %>", data[0].sOccupation, "");
            SetValueById("<%=ddlGender.ClientID %>", data[0].sGender, "");
            SetValueById("<%=txtfathermothername.ClientID %>", data[0].sFatherMotherName, "");

            ShowAlternateContactForTopUp(data[0].sMobile);



            SetValueById("<%=rMembershipId.ClientID %>", data[0].rCustomerCardNo, "");
            SetValueById("<%=hddReceiverId.ClientID %>", data[0].rCustomerId, "");
            SetValueById("<%=hddRMemId.ClientID %>", data[0].rCustomerCardNo, "");
            SetValueById("<%=rFirstName.ClientID %>", data[0].rFirstName, "");
            SetValueById("<%=rMiddleName.ClientID %>", data[0].rMiddleName, "");
            SetValueById("<%=rLastName1.ClientID %>", data[0].rLastName1, "");
            SetValueById("<%=rLastName2.ClientID %>", data[0].rLastName2, "");
            SetValueById("<%=rAdd.ClientID %>", data[0].rAddress, "");
            SetValueById("<%=rContactNo.ClientID %>", data[0].rMobile, "");
            if (data[0].rIdType != "")
                SetValueById("<%=rIdType.ClientID %>", data[0].rIdType, "");
            SetValueById("<%=rIdNo.ClientID %>", data[0].rIdNumber, "");
            ShowSenderCustomer();
            DisabledSenderFields();
        }
        function SetDDlByText(ddl, val) {

            $("#" + ddl + " option").each(function () {
                this.selected = $(this).text() == val;
            });
        }


        function ShowSenderCustomerNewWindow() {
            var customerCardNumber = GetValue("<%=sMembershipId.ClientID %>");
            if (customerCardNumber == "") {
                alert("Please enter Membership Id!");
                return false;
            }
            var url = urlRoot + "/Remit/Administration/CustomerSetup/Display.aspx?membershipId=" + customerCardNumber + "";
            PopUpWindow(url, "dialogHeight:800px;dialogWidth:1000px;dialogLeft:300;dialogTop:100;center:yes");
        }

        function ShowSenderCustomer() {
            var customerCardNumber = GetValue("<%=sMembershipId.ClientID %>");
            if (customerCardNumber == "") {
                alert("Please enter Membership Id!");
                return false;
            }

            $(document).ready(function () {
                var mydiv = $('#mydiv');

                //mydiv.dialog(
                //        {
                //            autoOpen: false
                //            , closeOnEscape: false
                //            , modal: true
                //            , resizable: false
                //            , position: [50, 20]
                //            , draggable: false
                //            , buttons:
                //            {
                //                'I recommend to accept the transaction. ': function () {
                //                    mydiv.dialog("close");
                //                    DisabledSenderFields();
                //                },
                //                ' I recommend to reject the transaction.': function () {
                //                    mydiv.dialog("close");
                //                    ClearField('s');
                //                    EnabledSenderFields();

                //                }
                //            },
                //            create: function () {


                //            }
                //        }
                //      );

              //  var url = "Display.aspx?membershipId=" + customerCardNumber + "";
              //  mydiv.load(url);

                // Open the dialog
               // mydiv.dialog('open');

                return false;

            });
        }

        function ShowReceiverCustomerPopup() {
            var customerCardNumber = GetValue("<%=rMembershipId.ClientID %>");
            if (customerCardNumber == "") {
                alert("Please enter Membership Id!");
                return false;
            }

            $(document).ready(function () {
                var mydiv = $('#mydiv');

                //mydiv.dialog(
                //        {
                //            autoOpen: false
                //            , closeOnEscape: false
                //            , modal: true
                //            , resizable: false
                //            , position: [50, 20]
                //            , draggable: false
                //            , buttons:
                //            {
                //                'I recommend to accept the transaction.': function () {
                //                    mydiv.dialog("close");
                //                    DisabledReceiverFields();
                //                },
                //                'I recommend to reject the transaction.': function () {
                //                    mydiv.dialog("close");
                //                    ClearField('r');

                //                }
                //            },
                //            create: function () {

                //            }
                //        }

                //      );

              //  var url = "Display.aspx?membershipId=" + customerCardNumber + "";
              //  mydiv.load(url);

                //open the dialog
              //  mydiv.dialog('open');

                return false;

            });
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
            var customerCardNumber = GetValue("<%=rMembershipId.ClientID %>");
            if (customerCardNumber == "") {
                alert("Please enter Membership Id!");
                return false;
            }
            var url = urlRoot + "/Remit/Administration/CustomerSetup/Display.aspx?membershipId=" + customerCardNumber + "";
            PopUpWindow(url, "dialogHeight:800px;dialogWidth:1000px;dialogLeft:300;dialogTop:100;center:yes");
        }

        function DisabledSenderFields() {
            $('#sMembershipId').attr("readonly", true);
            $('#sFirstName').attr("readonly", true);
            $('#sMiddleName').attr("readonly", true);
            $('#sLastName1').attr("readonly", true);
            $('#sLastName2').attr("readonly", true);
            $('#sAdd').attr("readonly", true);
            $('#sContactNo').attr("readonly", true);
            GetElement("<%=sIdType.ClientID %>").disabled = false;
            $('#sIdNo').attr("readonly", true);
            $('#sEmail').attr("readonly", true);

            $('#chkIssueCustCard')[0].checked = false;
            GetElement("<%=chkIssueCustCard.ClientID %>").disabled = true;
            $('tr.issuemember').hide();
            $("#tdCustCardIdlbl").hide();
            $("#tdCustCardIdtxt").hide();

            $('#alternateMobileNo').attr("readonly", true);
            GetElement("<%=sIdIssuedPlace.ClientID %>").disabled = false;
            $('#txtSenIdIssuedDateBs').attr("readonly", true);
            $('#txtSendIdValidDateBs').attr("readonly", true);
            $('#txtSendDOBBs').attr("readonly", true);

            $('#txtSendIdValidDate').attr("readonly", true);
            $('#txtSendIdValidDate').removeClass("hasDatepicker");
            $('#txtSendIdValidDate').attr("disabled", true);
            $('.ui-datepicker-trigger').css("display", "none");

            $('#txtSenIdIssuedDate').attr("readonly", true);
            $('#txtSenIdIssuedDate').removeClass("hasDatepicker");
            $('#txtSenIdIssuedDate').attr("disabled", true);
            $('.ui-datepicker-trigger').css("display", "none");

            $('#txtSendDOB').attr("readonly", true);
            $('#txtSendDOB').removeClass("hasDatepicker");
            $('#txtSendDOB').attr("disabled", true);
            $('.ui-datepicker-trigger').css("display", "none");

            //if (GetValue("<%=occupation.ClientID %>") == "") {
            //    GetElement("<%=occupation.ClientID %>").disabled = false;
            //}
            //else {
            GetElement("<%=occupation.ClientID %>").disabled = false;
            //}


        }

        function DisabledReceiverFields() {
            $('#rMembershipId').attr("readonly", true);
            $('#rFirstName').attr("readonly", true);
            $('#rMiddleName').attr("readonly", true);
            $('#rLastName1').attr("readonly", true);
            $('#rContactNo').attr("readonly", true);
            GetElement("<%=rIdType.ClientID %>").disabled = true;
            GetElement("<%=relWithSender.ClientID %>").disabled = false;
            $('#rIdNo').attr("readonly", true);
            $('#rAdd').attr("readonly", true);
            $('#rAdd').attr("readonly", true);
        }
        function EnabledSenderFields() {
            $('#sMembershipId').attr("readonly", false);
            $('#sFirstName').attr("readonly", false);
            $('#sMiddleName').attr("readonly", false);
            $('#sLastName1').attr("readonly", false);
            $('#sLastName2').attr("readonly", false);
            $('#sAdd').attr("readonly", false);
            $('#sContactNo').attr("readonly", false);
            GetElement("<%=sIdType.ClientID %>").disabled = false;
            $('#sIdNo').attr("readonly", false);
            $('#sEmail').attr("readonly", false);


            $('#txtSendIdValidDate').attr("readonly", false);
            $('#txtSendIdValidDate').addClass("hasDatepicker");
            $('#txtSendIdValidDate').attr("disabled", false);
            $('.ui-datepicker-trigger').css("display", "block");

            $('#txtSenIdIssuedDate').attr("readonly", false);
            $('#txtSenIdIssuedDate').addClass("hasDatepicker");
            $('#txtSenIdIssuedDate').attr("disabled", false);
            $('.ui-datepicker-trigger').css("display", "block");

            $('#txtSendDOB').attr("readonly", false);
            $('#txtSendDOB').addClass("hasDatepicker");
            $('#txtSendDOB').attr("disabled", false);
            $('.ui-datepicker-trigger').css("display", "block");

            $('#txtSenIdIssuedDateBs').attr("readonly", false);
            $('#txtSendIdValidDateBs').attr("readonly", false);
            $('#txtSendDOBBs').attr("readonly", false);

            GetElement("<%=sIdIssuedPlace.ClientID %>").disabled = false;
            GetElement("<%=occupation.ClientID %>").disabled = false;

        }

        function EnabledReceiverFields() {
            $('#rMembershipId').attr("readonly", false);
            $('#rFirstName').attr("readonly", false);
            $('#rMiddleName').attr("readonly", false);
            $('#rLastName1').attr("readonly", false);
            $('#rContactNo').attr("readonly", false);
            GetElement("<%=rIdType.ClientID %>").disabled = false;
            GetElement("<%=relWithSender.ClientID %>").disabled = false;

            $('#rIdNo').attr("readonly", false);
            $('#rAdd').attr("readonly", false);
        }
        function LoadImages(customerId) {
            var dataToSend = { MethodName: "LoadImages", customerId: customerId };
            var options =
                            {
                                url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
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


        function ManageSendIdValidity() {
            var senIdType = "";
            senIdType = $("#sIdType").val();

            var tAmt = GetValue("<%=transferAmt.ClientID %>");
            var thresholdAmt = GetValue("<%=hdnThresholdAmt.ClientID %>");

            if (thresholdAmt == "")
                thresholdAmt = "50000";

            if (parseFloat(tAmt) >= parseFloat(thresholdAmt)) {
                GetElement("spntxtSendIdValidDate").innerHTML = "";
                GetElement("spntxtSendDOB").innerHTML = "";
            }
            else {
                GetElement("spntxtSendIdValidDate").innerHTML = "";
                GetElement("spntxtSendDOB").innerHTML = "";
            }

        }
        $('#txtSendDOB').blur(function () {
            var CustomerDob = GetValue("<%=txtSendDOB.ClientID %>");
            if (CustomerDob != "") {
                var CustYears = datediff(CustomerDob, 'years');

                if (parseInt(CustYears) < 18) {
                    alert('Customer age must be 18 or above !');
                    return;
                }
            }
        });

            function uploadTxnDoc() {
                var txnBatchId = GetValue("<%=hdnTxnBatchId.ClientID %>");
            var url = "TxnDocument.aspx?txnBatchId=" + txnBatchId;
            OpenDialog(url, 500, 820, 100, 100);
        }

        function uploadCusDoc() {
            var customerId = GetValue("<%=hddIssueCustCardId.ClientID %>");
            if (customerId == "") {
                alert("Customer information has not been saved yet. Please save and re-try again.");
                return;
            }
            var url = "CustomerDocument.aspx?customerId=" + customerId;

            OpenDialog(url, 500, 820, 100, 100);
        }
        function LoadCalendars() {
            CalIDIssueDate("#<% =txtSenIdIssuedDate.ClientID%>");
            VisaValidDateSend("#<% =txtSendIdValidDate.ClientID%>");
            CalSenderDOB("#<% =txtSendDOB.ClientID%>");

        }
        LoadCalendars();

        function GetADVsBSDate(type, control) {
            var date = "";
            if (type == "ad" && control == "txtSendDOB")
                date = GetValue("<%=txtSendDOB.ClientID%>");
            else if (type == "bs" && control == "txtSendDOBBs")
                date = GetValue("<%=txtSendDOBBs.ClientID%>");
            else if (type == "ad" && control == "txtSenIdIssuedDate")
                date = GetValue("<%=txtSenIdIssuedDate.ClientID%>");
            else if (type == "bs" && control == "txtSenIdIssuedDateBs")
                date = GetValue("<%=txtSenIdIssuedDateBs.ClientID%>");
            else if (type == "ad" && control == "txtSendIdValidDate")
                date = GetValue("<%=txtSendIdValidDate.ClientID%>");
            else if (type == "bs" && control == "txtSendIdValidDateBs")
                date = GetValue("<%=txtSendIdValidDateBs.ClientID%>");

    var dataToSend = { MethodName: "getdate", date: date, type: type };
    var options =
            {
                url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                        data: dataToSend,
                        dataType: 'JSON',
                        type: 'POST',
                        success: function (response) {
                            var data = jQuery.parseJSON(response);
                            if (data[0].Result == "") {
                                alert("Invalid Date.");
                                return;
                            }

                            if (type == "ad" && control == "txtSendDOB")
                                SetValueById("<%=txtSendDOBBs.ClientID %>", data[0].Result, "");
                            else if (type == "bs" && control == "txtSendDOBBs")
                                SetValueById("<%=txtSendDOB.ClientID %>", data[0].Result, "");
                            else if (type == "ad" && control == "txtSenIdIssuedDate")
                                SetValueById("<%=txtSenIdIssuedDateBs.ClientID %>", data[0].Result, "");
                            else if (type == "bs" && control == "txtSenIdIssuedDateBs")
                                SetValueById("<%=txtSenIdIssuedDate.ClientID %>", data[0].Result, "");
                            else if (type == "ad" && control == "txtSendIdValidDate")
                                SetValueById("<%=txtSendIdValidDateBs.ClientID %>", data[0].Result, "");
                            else if (type == "bs" && control == "txtSendIdValidDateBs")
                                SetValueById("<%=txtSendIdValidDate.ClientID %>", data[0].Result, "");

                            ValidateDate();

                        },
                        error: function (request, error) {
                            alert(request);
                        }
                    };
    $.ajax(options);
}


function ValidateDate() {
    try {
        var dateDOBValue = GetValue("<%=txtSendDOB.ClientID%>");
                var issuedateValue = GetValue("<%=txtSenIdIssuedDate.ClientID%>");
                var expiryDateValue = GetValue("<%=txtSendIdValidDate.ClientID%>");

                var dateDOBValueBs = GetValue("<%=txtSendDOBBs.ClientID%>");
                var issuedateValueBs = GetValue("<%=txtSenIdIssuedDateBs.ClientID%>");
                var expiryDateValueBs = GetValue("<%=txtSendIdValidDateBs.ClientID%>");

                var current = new Date();
                var currentYear = current.getFullYear();

                if (dateDOBValue != '') {
                    var dt = new Date(dateDOBValue);
                    var birthYear = dt.getFullYear();

                    if ((currentYear - birthYear) < 16) {
                        alert('Sender needs to be at least 16 years old in order to send money.');
                        SetValueById("<%=txtSendDOB.ClientID %>", "", "");
                        SetValueById("<%=txtSendDOBBs.ClientID%>", "", "");
                        return false;
                    }

                    if (dt >= current) {
                        alert('Sender needs to be at least 16 years old in order to send money.');
                        SetValueById("<%=txtSendDOB.ClientID %>", "", "");
                        SetValueById("<%=txtSendDOBBs.ClientID%>", "", "");
                        return false;
                    }
                }

                if (dateDOBValueBs != '') {
                    //MM/DD/YYYY
                    var dateDOBValueBsArr = dateDOBValueBs.split('/');
                    if (dateDOBValueBsArr.length == 1)
                        dateDOBValueBsArr = dateDOBValueBs.split('-');

                    try {
                        var dtBS = new Date(dateDOBValueBs);
                    }
                    catch (e) {

                        alert('Invalid date format for DOB BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=txtSendDOBBs.ClientID%>", "", "");
                        SetValueById("<%=txtSendDOB.ClientID %>", "", "");
                        return false;
                    }


                    if (dateDOBValueBsArr.length == 3) {
                        var bsDD = dateDOBValueBsArr[1];
                        var bsMM = dateDOBValueBsArr[0];
                        var bsYear = dateDOBValueBsArr[2];

                        if ((bsDD.length == 0 || bsDD.length > 2) || (bsMM.length == 0 || bsMM.length > 2) || (bsYear.length != 4)) {
                            alert('Invalid date format for DOB BS. Date should be in MM/DD/YYYY format.');
                            SetValueById("<%=txtSendDOBBs.ClientID%>", "", "");
                            SetValueById("<%=txtSendDOB.ClientID %>", "", "");
                            return false;
                        }


                    }
                    else {
                        alert('Invalid date format for DOB BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=txtSendDOBBs.ClientID%>", "", "");
                        SetValueById("<%=txtSendDOB.ClientID %>", "", "");
                        return false;
                    }




                }

                if (issuedateValue != '') {
                    var dtIssue = new Date(issuedateValue);
                    if (dtIssue > current) {
                        alert('ID Issued date cannot be future date. Please enter valid ID Issued date.');
                        SetValueById("<%=txtSenIdIssuedDate.ClientID %>", "", "");
                        SetValueById("<%=txtSenIdIssuedDateBs.ClientID %>", "", "");
                        return false;
                    }
                }

                if (issuedateValueBs != '') {
                    //MM/DD/YYYY
                    var dateValueBsArr = issuedateValueBs.split('/');

                    if (dateValueBsArr.length == 1)
                        dateValueBsArr = issuedateValueBs.split('-');

                    try {
                        var dtBS = new Date(issuedateValueBs);
                    }
                    catch (e) {
                        alert('Invalid date format for ID Issued Date BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=txtSenIdIssuedDateBs.ClientID%>", "", "");
                        SetValueById("<%=txtSenIdIssuedDate.ClientID %>", "", "");
                        return false;
                    }


                    if (dateValueBsArr.length == 3) {
                        var bsDD = dateValueBsArr[1];
                        var bsMM = dateValueBsArr[0];
                        var bsYear = dateValueBsArr[2];

                        if ((bsDD.length == 0 || bsDD.length > 2) || (bsMM.length == 0 || bsMM.length > 2) || (bsYear.length != 4)) {
                            alert('Invalid date format for ID Issued Date BS. Date should be in MM/DD/YYYY format.');
                            SetValueById("<%=txtSenIdIssuedDateBs.ClientID%>", "", "");
                            SetValueById("<%=txtSenIdIssuedDate.ClientID %>", "", "");
                            return false;
                        }



                    }
                    else {
                        alert('Invalid date format for ID Issued Date BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=txtSenIdIssuedDateBs.ClientID%>", "", "");
                        SetValueById("<%=txtSenIdIssuedDate.ClientID %>", "", "");
                        return false;
                    }
                }


                if (expiryDateValue != '') {
                    var dtExpiry = new Date(expiryDateValue);
                    if (dtExpiry <= current) {
                        alert('ID Expiry date cannot be past or current date. Please enter valid ID Expiry date.');
                        SetValueById("<%=txtSendIdValidDate.ClientID %>", "", "");
                        SetValueById("<%=txtSendIdValidDateBs.ClientID %>", "", "");
                        return false;
                    }
                }

                if (expiryDateValueBs != '') {
                    //MM/DD/YYYY
                    var dateValueBsArr = expiryDateValueBs.split('/');
                    if (dateValueBsArr.length == 1)
                        dateValueBsArr = expiryDateValueBs.split('-');

                    try {
                        var dtBS = new Date(expiryDateValueBs);
                    }
                    catch (e) {
                        alert('Invalid date format for ID Expiry Date BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=txtSendIdValidDate.ClientID%>", "", "");
                        SetValueById("<%=txtSendIdValidDateBs.ClientID %>", "", "");
                        return false;
                    }


                    if (dateValueBsArr.length == 3) {
                        var bsDD = dateValueBsArr[1];
                        var bsMM = dateValueBsArr[0];
                        var bsYear = dateValueBsArr[2];

                        if ((bsDD.length == 0 || bsDD.length > 2) || (bsMM.length == 0 || bsMM.length > 2) || (bsYear.length != 4)) {
                            alert('Invalid date format for ID Expiry Date BS. Date should be in MM/DD/YYYY format.');
                            SetValueById("<%=txtSendIdValidDate.ClientID%>", "", "");
                            SetValueById("<%=txtSendIdValidDateBs.ClientID %>", "", "");
                            return false;
                        }
                    }
                    else {
                        alert('Invalid date format for ID Expiry Date BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=txtSendIdValidDateBs.ClientID%>", "", "");
                        SetValueById("<%=txtSendIdValidDate.ClientID %>", "", "");
                        return false;
                    }
                }

                if (issuedateValue != '' && expiryDateValue != '') {
                    var dtIssue = new Date(issuedateValue);
                    var dtExpiry = new Date(expiryDateValue);
                    if (dtIssue >= dtExpiry) {
                        alert('ID Issued date cannot be greater than ID Expiry date. Please enter valid ID Issued and Expiry date.');
                        return false;
                    }
                }
            }
            catch (e) {
                // alert(e);                
            }

            return true;
        }
        function GetValueForSelectedIndex(obj) {
            try {
                return obj.options[obj.selectedIndex].text;
            } catch (ex) { }
            return "";
        }

        function VerifyTran() {

            try {

                if (!Page_ClientValidate('sendTran')) {

                    return false;
                }


                if (!ValidateDate()) {

                    return;
                }
               var amnt = GetElement("<%=availableAmt.ClientID %>").innerHTML;
                if (amnt == 'N/A' || amnt == null || amnt == '') {
                    window.parent.SetMessageBox('Credit limit not set for sending agent, please contact HO.', '1');
                    
                    return false;
                }

                var pDistrictObj = GetElement("district");
                var pDistrict = pDistrictObj.Value;
                var pDistrictName = GetValueForSelectedIndex(pDistrictObj);
                if (pDistrict == "") {
                    pDistrictName = "";
                }
                var pLocationObj = GetElement("location");
                var pLocation = pLocationObj.value;
                var pLocationName = GetValueForSelectedIndex(pLocationObj);
                var ta = GetValue("<% =transferAmt.ClientID%>");
                var tc = GetElement("<% =collectAmt.ClientID%>").innerHTML;
                var sc = GetElement("<% =serviceCharge.ClientID%>").innerHTML;
                var dmObj = GetElement("<% =deliveryMethod.ClientID%>");
                var dm = GetValueForSelectedIndex(dmObj); //.options[dmObj.selectedIndex].text;
                if (sc == "" || tc == "") {
                    window.parent.SetMessageBox('Cannot Process Transaction. Service Charge not defined', '1');
                    GetElement("<%=transferAmt.ClientID %>").focus();

                    return false;
                }

                // Issue Membership card validation.

                var ischecked = $("#chkIssueCustCard").is(':checked');
                if (ischecked) {
                    var isSaved = GetValue("<% =hddIssueCustCardInfoSaved.ClientID%>");
                    var custId = GetValue("<% =hddIssueCustCardId.ClientID%>");

                    if (isSaved != 'true' && custId == '') {
                        window.parent.SetMessageBox('Cannot Process Transaction. Save customer card issue information and then try again.', '1');
                        //SaveCustInfoToIssueCard();                       
                        return;
                    }
                }


                var sBranch = "";
                var sBranchText = "";
                var pBankBranchObj;
                var pBankObj;
                var pBank = "";
                var pBankText = "";
                var pBankBranch = "";
                var pBankBranchText = "";
                var accountNo = "";
                if (dm == "Bank Deposit") {
                    pBankBranchObj = GetElement("bankBranch");
                    pBankObj = GetElement("<%=bankName.ClientID %>");
                    pBank = pBankObj.value;
                    pBankText = GetValueForSelectedIndex(pBankObj); //.options[pBankObj.selectedIndex].text;
                    pBankBranch = pBankBranchObj.value;
                    pBankBranchText = GetValueForSelectedIndex(pBankBranchObj); //.options[pBankBranchObj.selectedIndex].text;
                    accountNo = GetValue("<%=accountNo.ClientID %>");
                    pLocation = "";
                    pLocationName = "";
                }
                var senderId = GetValue("<%=hddSenderId.ClientID %>");

                var IssueCustCardId = GetValue("<%=hddIssueCustCardId.ClientID %>");

                if (senderId == "" && IssueCustCardId != "") {
                    senderId = IssueCustCardId;
                }

                var sMemId = GetValue("<%=sMembershipId.ClientID %>");
                var sFirstName = GetValue("<%=sFirstName.ClientID %>");
                var sMiddleName = GetValue("<%=sMiddleName.ClientID %>");
                var sLastName1 = GetValue("<%=sLastName1.ClientID %>");
                var sLastName2 = GetValue("<%=sLastName2.ClientID %>");
                var sAddress = GetValue("<%=sAdd.ClientID %>");
                var sContactNo = GetValue("<%=sContactNo.ClientID %>");

                var sIdTypeObj = GetElement("<%=sIdType.ClientID %>");
                var sIdType = GetValueForSelectedIndex(sIdTypeObj); //.options[sIdTypeObj.selectedIndex].text;
                if (sIdTypeObj.value == "")
                    sIdType = "";
                var sIdNo = GetValue("<%=sIdNo.ClientID %>");

                var senIdType = $("#sIdType").val();
                var senIdTypeArr = senIdType.split('|');

                var sEmail = GetValue("<%=sEmail.ClientID %>");

                var thresholdAmt = GetValue("<%=hdnThresholdAmt.ClientID %>");

                if (thresholdAmt == "")
                    thresholdAmt = "50000";



                try {
                    var sIdValidDate = GetValue("<%=txtSendIdValidDate.ClientID %>");
                    var sDOB = GetValue("<%=txtSendDOB.ClientID %>");

                    var sIdValidDateBs = GetValue("<%=txtSendIdValidDateBs.ClientID %>");
                    var sDOBBs = GetValue("<%=txtSendDOBBs.ClientID %>");

                    var receiverId = GetValue("<%=hddReceiverId.ClientID %>");
                    var rMemId = GetValue("<%=rMembershipId.ClientID %>");
                    var rFirstName = GetValue("<%=rFirstName.ClientID %>");
                    var rMiddleName = GetValue("<%=rMiddleName.ClientID %>");
                    var rLastName1 = GetValue("<%=rLastName1.ClientID %>");
                    var rLastName2 = GetValue("<%=rLastName2.ClientID %>");
                    var rAddress = GetValue("<%=rAdd.ClientID %>");
                    var rContactNo = GetValue("<%=rContactNo.ClientID %>");
                    var rIdTypeObj = GetElement("<%=rIdType.ClientID %>");
                    var rIdType = GetValueForSelectedIndex(rIdTypeObj);


                    if (rIdTypeObj.value == "")
                        rIdType = "";
                    var rIdNo = GetValue("<%=rIdNo.ClientID %>");
                    var payMsg = GetValue("<% =remarks.ClientID%>");
                    var relObj = GetElement("<% = relWithSender.ClientID %>");

                    var rel = "";
                    try {
                        rel = relObj.options[relObj.selectedIndex].text;
                    } catch (ex) { }
                    if (relObj.value == "")
                        rel = "";

                    var sofObj = GetElement("<%=sof.ClientID %>");

                    var sof = "";

                    try {
                        sof = sofObj.options[sofObj.selectedIndex].text;
                    } catch (ex) { }

                    if (sofObj.value != "") {
                        GetElement("lblSof").innerHTML = sof;
                    }
                    else {
                        GetElement("lblSof").innerHTML = "";
                    }

                    var porObj = GetElement("<%=por.ClientID %>");
                    var por = "";
                    try {
                        por = porObj.options[porObj.selectedIndex].text;
                    } catch (ex) { }
                    if (porObj.value != "") {
                        GetElement("lblPor").innerHTML = por;
                    }
                    else {
                        GetElement("lblPor").innerHTML = "";
                    }
                    var occObj = GetElement("<%=occupation.ClientID %>");
                    var occ = GetValueForSelectedIndex(occObj); //.options[occObj.selectedIndex].text;
                    if (occObj.value != "") {
                        GetElement("lblOccupation").innerHTML = occ;
                    }
                    else {
                        GetElement("lblOccupation").innerHTML = "";
                    }

                    var sIdIssuedPlace = $("#sIdIssuedPlace").val();
                    var sIdIssuedDate = GetValue("<%=txtSenIdIssuedDate.ClientID %>");
                    var sIdIssuedDateBs = GetValue("<%=txtSenIdIssuedDateBs.ClientID %>");

                    var gender = "";
                    var motherFatherName = "";
                    var isIssueCardchecked = $("#chkIssueCustCard").is(':checked');
                    if (!isIssueCardchecked) {
                        gender = GetValue("<%=ddlGender.ClientID %>");
                        motherFatherName = GetValue("<%=txtfathermothername.ClientID %>");
                    }
                } catch (ex) { }

                SetValueById("<%=hdnIsTxnDocReq.ClientID %>", "", "");

                GetElement("spnWarningMsg").innerHTML = "";
                HideElement("spnWarningMsg");
                SetValueById("<%=hdnAgentRefId.ClientID %>", "", "");
                ShowElement("btnProceed");
                SetValueById("<%=hdnComplianceAction.ClientID %>", "", "");
                SetValueById("<%=hdnCompApproveRemark.ClientID %>", "", "");
                GetElement("divComplianceMultipleTxn").innerHTML = "";
                HideElement("divComplianceMultipleTxn");

                //$('#chkMultipleTxn')[0].checked = false;
                HideElement("divChkMultipleTxn");

                //--------- Transaction Verification and compliance check ----------
                var result = false;
                var dataToSend = {
                    MethodName: 'vt'
                     , sBranch: sBranch, pDistrict: pDistrictName, pLocation: pLocation, ta: ta, sc: sc, tc: tc, dm: dm
                     , pBankBranch: pBankBranch, accountNo: accountNo
                     , senderId: senderId, sMemId: sMemId, sFirstName: sFirstName, sMiddleName: sMiddleName, sLastName1: sLastName1, sLastName2: sLastName2
                     , sAddress: sAddress, sContactNo: sContactNo, sIdType: senIdTypeArr[0], sIdNo: sIdNo, sEmail: sEmail
                     , receiverId: receiverId, rMemId: rMemId, rFirstName: rFirstName, rMiddleName: rMiddleName, rLastName1: rLastName1, rLastName2: rLastName2
                     , rAddress: rAddress, rContactNo: rContactNo, rel: rel, rIdType: rIdType, rIdNo: rIdNo, sDOB: sDOB, sIdIssuedPlace: sIdIssuedPlace, sIdIssuedDate: sIdIssuedDate, sIdValidDate: sIdValidDate
                     , payMsg: payMsg, txtPass: '', sof: sof, por: por, occupation: occ, gender: gender, motherFatherName: motherFatherName
                     , type: 'vt', topupMobileNo: '', senIdTypeTxt: senIdTypeArr[0]
                };
                var options =
                        {
                            url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                            data: dataToSend,
                            dataType: 'JSON',
                            type: 'POST',
                            success: function (response) {
                                var data = jQuery.parseJSON(response);
                                if (data[0].errorCode != "0") {
                                    if (data[0].vtype == "compliance") {

                                        CallBackComplianceValidation(data);
                                    }
                                    else {

                                        CallBackIDRuleValidation(data);
                                    }
                                }
                                else {

                                    CallBackComplianceValidation(data);
                                }
                                return result;
                            }
                        };
                $.ajax(options);
            } catch (ex) {
                //alert(ex);
            }

        }

        function CallBackIDRuleValidation(data) {

            //var data = jQuery.parseJSON(response);
            if (data[0].errorCode == "101") {
                var alertMsgHeader = "Sorry, we cannot proceed furthers until you fill the below mentioned field(s):\r\n";
                var newLine = "\r\n";
                var alertMsg = "";
                var focusCtrl = null;

                for (var i = 0; i < data.length; i++) {
                    try {
                        var obj = data[i];
                        var controlId = (obj.controlId != "") ? obj.controlId : null;

                        var ctrl = document.getElementById(controlId);

                        var spanId = (obj.controlId != "") ? "spn" + obj.controlId : null;
                        var spanCtrl = document.getElementById(spanId);

                        if (controlId == "txtSendIdValidDate") {
                            var senIdType = $("#sIdType").val();
                            var myvalue = document.getElementById(controlId).value;

                            if (senIdType != "") {
                                var senIdTypeArr = senIdType.split('|');
                                if (senIdTypeArr[1] == "E") {
                                    if (myvalue == "") {
                                        alertMsg += newLine;
                                        alertMsg += obj.errorMsg;

                                        if (spanCtrl != null)
                                            spanCtrl.innerHTML = "*";

                                        focusCtrl = (focusCtrl == null) ? ctrl : focusCtrl;
                                    }
                                    else {
                                        if (spanCtrl != null)
                                            spanCtrl.innerHTML = "";
                                    }
                                }
                            }
                            else {

                                if (myvalue == "") {
                                    alertMsg += newLine;
                                    alertMsg += obj.errorMsg;
                                    if (spanCtrl != null)
                                        spanCtrl.innerHTML = "*";
                                    focusCtrl = (focusCtrl == null) ? ctrl : focusCtrl;
                                }
                                else {
                                    if (spanCtrl != null)
                                        spanCtrl.innerHTML = "";
                                }
                            }
                        }
                        else if (ctrl != null && ctrl.type == "text") {
                            //control is textbox
                            var myvalue = document.getElementById(controlId).value;
                            if (myvalue == "") {
                                alertMsg += newLine;
                                alertMsg += obj.errorMsg;
                                if (spanCtrl != null)
                                    spanCtrl.innerHTML = "*";
                                focusCtrl = (focusCtrl == null) ? ctrl : focusCtrl;
                            }
                            else {
                                if (spanCtrl != null)
                                    spanCtrl.innerHTML = "*";
                            }
                        }
                        else if (ctrl != null && ctrl.type == "select-one") {
                            //control is dropdownlist
                            var myvalue = GetValueForSelectedIndex(ctrl);
                            if (myvalue == "" || myvalue == "Select" || myvalue == "select") {
                                alertMsg += newLine;
                                alertMsg += obj.errorMsg;
                                if (spanCtrl != null)
                                    spanCtrl.innerHTML = "*";
                                focusCtrl = (focusCtrl == null) ? ctrl : focusCtrl;
                            }
                            else {
                                if (spanCtrl != null)
                                    spanCtrl.innerHTML = "*";
                            }
                        }
                        else {
                            if (ctrl != null)
                                SetValueById(controlId, "required", "");
                        }
                    }
                    catch (e) {
                    }
                }

                if (alertMsg != "") {
                    alert(alertMsgHeader + alertMsg);

                    if (focusCtrl != null)
                        focusCtrl.focus();
                    return false;
                }
            }
            else if (data[0].errorCode == "1") {
                alert(data[0].msg);
            }

            return false;
        }

        function CallBackComplianceValidation(data) {

            try {
                //var data = jQuery.parseJSON(response);
                if (data[0].errorCode != "0") {

                    ShowElement("spnWarningMsg");
                    GetElement("spnWarningMsg").innerHTML = data[0].msg;

                    SetValueById("<%=hdnAgentRefId.ClientID %>", data[0].agentRefId, "");

                    if (data[0].errorCode == "101") {
                        SetValueById("<%=hdnComplianceAction.ClientID %>", data[0].id, "");
                        SetValueById("<%=hdnCompApproveRemark.ClientID %>", data[0].compApproveRemark, "");

                        if (GetValue("<%=hdnComplianceAction.ClientID %>") == "B") {
                            HideElement("btnProceed");
                            alert(data[0].msg);
                        }
                        else {
                            ShowElement("btnProceed");
                        }
                    }
                }
                else {
                    GetElement("spnWarningMsg").innerHTML = "";
                    SetValueById("<%=hdnAgentRefId.ClientID %>", data[0].agentRefId, "");
                    HideElement("spnWarningMsg");

                    if (data[0].multipleTxn != "") {
                        ShowElement("divComplianceMultipleTxn");
                        GetElement("divComplianceMultipleTxn").innerHTML = data[0].multipleTxn;
                        ShowElement("divChkMultipleTxn");

                    }
                    else {
                        GetElement("divComplianceMultipleTxn").innerHTML = "";
                        HideElement("divComplianceMultipleTxn");
                        //$('#chkMultipleTxn')[0].checked = false;
                        HideElement("divChkMultipleTxn");
                    }

                }

                return ConfirmTran();
            } catch (ex) {
                alert(ex);
            }
        }


        function ConfirmTran() {

            var param = "dialogHeight:450px;dialogWidth:820px;dialogLeft:200;dialogTop:100;center:yes";
            var pDistrictObj = GetElement("district");
            var pDistrict = pDistrictObj.Value;
            var pDistrictName = "";
            try {
                pDistrictName = GetValueForSelectedIndex(pDistrictObj);
            } catch (ex) {
            }
            if (pDistrict == "") {
                pDistrictName = "";
            }
            var pLocationObj = GetElement("location");
            var pLocation = pLocationObj.value;
            var pLocationName = "";
            try {
                pLocationName = pLocationObj.options[pLocationObj.selectedIndex].text;
            } catch (ex) {
            }
            var ta = GetValue("<% =transferAmt.ClientID%>");
            var tc = GetElement("<% =collectAmt.ClientID%>").innerHTML;
            var sc = GetElement("<% =serviceCharge.ClientID%>").innerHTML;
            var dmObj = GetElement("<% =deliveryMethod.ClientID%>");
            var dm = "";
            try {
                dm = dmObj.options[dmObj.selectedIndex].text;
            } catch (ex) {
            }
            if (sc == "" || tc == "") {
                window.parent.SetMessageBox('Cannot Process Transaction. Service Charge not defined', '1');
                GetElement("<%=transferAmt.ClientID %>").focus();
                return false;
            }

            // Issue Membership card validation.

            var ischecked = $("#chkIssueCustCard").is(':checked');
            if (ischecked) {
                var isSaved = GetValue("<% =hddIssueCustCardInfoSaved.ClientID%>");
                var custId = GetValue("<% =hddIssueCustCardId.ClientID%>");

                if (isSaved != 'true' && custId == '') {
                    window.parent.SetMessageBox('Cannot Process Transaction. Save customer card issue information and then try again.', '1');
                    SaveCustInfoToIssueCard();
                    return;
                }
            }


            var sBranch = "";
            var sBranchText = "";
            var pBankBranchObj;
            var pBankObj;
            var pBank = "";
            var pBankText = "";
            var pBankBranch = "";
            var pBankBranchText = "";
            var accountNo = "";
            if (dm == "Bank Deposit") {
                pBankBranchObj = GetElement("bankBranch");
                pBankObj = GetElement("<%=bankName.ClientID %>");
                pBank = pBankObj.value;
                try {
                    pBankText = pBankObj.options[pBankObj.selectedIndex].text;
                } catch (ex) {
                }
                pBankBranch = pBankBranchObj.value;
                try {
                    pBankBranchText = pBankBranchObj.options[pBankBranchObj.selectedIndex].text;
                } catch (ex) {
                }
                accountNo = GetValue("<%=accountNo.ClientID %>");
                pLocation = "";
                pLocationName = "";
            }
            var senderId = GetValue("<%=hddSenderId.ClientID %>");

            var IssueCustCardId = GetValue("<%=hddIssueCustCardId.ClientID %>");

            if (senderId == "" && IssueCustCardId != "") {
                senderId = IssueCustCardId;
            }

            var sMemId = GetValue("<%=sMembershipId.ClientID %>");
            var sFirstName = GetValue("<%=sFirstName.ClientID %>");
            var sMiddleName = GetValue("<%=sMiddleName.ClientID %>");
            var sLastName1 = GetValue("<%=sLastName1.ClientID %>");
            var sLastName2 = GetValue("<%=sLastName2.ClientID %>");
            var sAddress = GetValue("<%=sAdd.ClientID %>");
            var sContactNo = GetValue("<%=sContactNo.ClientID %>");

            var sIdTypeObj = GetElement("<%=sIdType.ClientID %>");
            var sIdType = "";
            try {
                sIdType = sIdTypeObj.options[sIdTypeObj.selectedIndex].text;
            } catch (ex) {
            }
            if (sIdTypeObj.value == "")
                sIdType = "";
            var sIdNo = GetValue("<%=sIdNo.ClientID %>");

            var senIdType = $("#sIdType").val();
            var senIdTypeArr = senIdType.split('|');

            var sEmail = GetValue("<%=sEmail.ClientID %>");

            var thresholdAmt = GetValue("<%=hdnThresholdAmt.ClientID %>");

            if (thresholdAmt == "")
                thresholdAmt = "50000";



            var sIdValidDate = GetValue("<%=txtSendIdValidDate.ClientID %>");
            var sDOB = GetValue("<%=txtSendDOB.ClientID %>");

            var sIdValidDateBs = GetValue("<%=txtSendIdValidDateBs.ClientID %>");
            var sDOBBs = GetValue("<%=txtSendDOBBs.ClientID %>");

            var receiverId = GetValue("<%=hddReceiverId.ClientID %>");
            var rMemId = GetValue("<%=rMembershipId.ClientID %>");
            var rFirstName = GetValue("<%=rFirstName.ClientID %>");
            var rMiddleName = GetValue("<%=rMiddleName.ClientID %>");
            var rLastName1 = GetValue("<%=rLastName1.ClientID %>");
            var rLastName2 = GetValue("<%=rLastName2.ClientID %>");
            var rAddress = GetValue("<%=rAdd.ClientID %>");
            var rContactNo = GetValue("<%=rContactNo.ClientID %>");
            var rIdTypeObj = GetElement("<%=rIdType.ClientID %>");
            var rIdType = "";
            try {
                rIdType = rIdTypeObj.options[rIdTypeObj.selectedIndex].text;
            } catch (ex) {
            }
            if (rIdTypeObj.value == "")
                rIdType = "";
            var rIdNo = GetValue("<%=rIdNo.ClientID %>");
            var payMsg = GetValue("<% =remarks.ClientID%>");
            var relObj = GetElement("<% = relWithSender.ClientID %>");
            var rel = "";
            try {
                rel = relObj.options[relObj.selectedIndex].text;
            } catch (ex) {
            }
            if (relObj.value == "")
                rel = "";

            var sofObj = GetElement("<%=sof.ClientID %>");
            var sof = "";
            try {
                sof = sofObj.options[sofObj.selectedIndex].text;
            } catch (ex) {
            }

            if (sofObj.value != "") {
                GetElement("lblSof").innerHTML = sof;
            }
            else {
                GetElement("lblSof").innerHTML = "";
            }

            var porObj = GetElement("<%=por.ClientID %>");
            var por = "";
            try {
                por = porObj.options[porObj.selectedIndex].text;
            } catch (ex) {
            }
            if (porObj.value != "") {
                GetElement("lblPor").innerHTML = por;
            }
            else {
                GetElement("lblPor").innerHTML = "";
            }
            var occObj = GetElement("<%=occupation.ClientID %>");
            var occ = "";
            try {
                occ = occObj.options[occObj.selectedIndex].text;
            } catch (ex) {
            }
            if (occObj.value != "") {
                GetElement("lblOccupation").innerHTML = occ;
            }
            else {
                GetElement("lblOccupation").innerHTML = "";
            }

            var sIdIssuedPlace = $("#sIdIssuedPlace").val();
            var sIdIssuedDate = GetValue("<%=txtSenIdIssuedDate.ClientID %>");
            var sIdIssuedDateBs = GetValue("<%=txtSenIdIssuedDateBs.ClientID %>");

            var gender = "";
            var motherFatherName = "";
            var isIssueCardchecked = $("#chkIssueCustCard").is(':checked');
            if (!isIssueCardchecked) {
                gender = GetValue("<%=ddlGender.ClientID %>");
                motherFatherName = GetValue("<%=txtfathermothername.ClientID %>");
            }


            GetElement("spanSName").innerHTML = ConcatenateName(sFirstName, sMiddleName, sLastName1, sLastName2);
            GetElement("spanSAddress").innerHTML = sAddress;
            GetElement("spanSContactNo").innerHTML = sContactNo;
            GetElement("spanSIdType").innerHTML = sIdType;
            GetElement("spanSIdNo").innerHTML = sIdNo;

            GetElement("spanSIDIssuedPlace").innerHTML = sIdIssuedPlace;
            GetElement("spanSIDIssuedDate").innerHTML = sIdIssuedDate;
            GetElement("spanSIDIssuedDateBs").innerHTML = sIdIssuedDateBs;

            GetElement("spanSIdValidDate").innerHTML = sIdValidDate;
            GetElement("spanSIdValidDateBs").innerHTML = sIdValidDateBs;

            GetElement("spanSDOB").innerHTML = sDOB;
            GetElement("spanSDOBBs").innerHTML = sDOBBs;

            GetElement("spanSEmail").innerHTML = sEmail;

            GetElement("spanSGender").innerHTML = gender;
            GetElement("spanSMotherFatherName").innerHTML = motherFatherName;

            GetElement("spanRName").innerHTML = ConcatenateName(rFirstName, rMiddleName, rLastName1, rLastName2);

            GetElement("spanRAddress").innerHTML = rAddress;
            GetElement("spanRContactNo").innerHTML = rContactNo;
            GetElement("spanRIdType").innerHTML = rIdType;
            GetElement("spanRIdNo").innerHTML = rIdNo;

            GetElement("spanPLocation").innerHTML = pLocationName;
            GetElement("spanPDistrict").innerHTML = pDistrictName;
            GetElement("spanRelationship").innerHTML = rel;
            GetElement("spanPCountry").innerHTML = "Nepal";
            GetElement("spanModeOfPayment").innerHTML = dm;

            GetElement("spanTransferAmt").innerHTML = CommaFormatted(ta + ".00");
            GetElement("spanTotalColl").innerHTML = tc;
            GetElement("spanServiceCharge").innerHTML = sc;
            GetElement("spanPayoutAmt").innerHTML = CommaFormatted(ta + ".00");
            if (payMsg != "") {
                GetElement("spanPayoutMsg").innerHTML = payMsg;
            }
            else {
                GetElement("spanPayoutMsg").innerHTML = "";
            }

            HideElement("divStep1");
            ShowElement("divStep2");
            GetElement("btnProceed").focus();
            MoveWindowToTop();
            return true;
        }


        function FilterIdIssuedPlace() {
            Loading('show');
            var senIdType = $("#sIdType").val();
            var senIdTypeArr = senIdType.split('|');

            var dataToSend = { MethodName: "idissuedplace", IdType: senIdTypeArr[0] };
            var options = {
                url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success: function (response) {
                    var data = jQuery.parseJSON(response);
                    $("#sIdIssuedPlace").empty();

                    $("#sIdIssuedPlace").append($("<option></option>").val
        ('').html('Select'));

                    $.each(data, function (key, value) {
                        $("#sIdIssuedPlace").append($("<option></option>").val
        (value.valueId).html(value.detailTitle));
                    });

                    SetIDTypeIssuedPlace();
                }
            };
            $.ajax(options);
            Loading('hide');
        }


        function SetIDTypeIssuedPlace() {
            var IdIssuedPlace = GetValue("<% =hddsIdPlaceOfIssue.ClientID%>");
            SetDDlByText("sIdIssuedPlace", IdIssuedPlace, "");
        }

    </script>
    <style type="text/css">
        td
        {
            font-size: 11px;
        }
        
        .panels
        {
            background: #dcf8d7;
            padding: 10px;
            border: 1px solid #fff;
            border-color: #f2f2e6 #4DB8481 #4DB848 #f2f2e6;
            margin-bottom: 5px;
            margin-left: 20px;
          
        }
        
        .panels2
        {
            background: #f2f2f2;
            padding: 10px;
            border: 1px solid #fff;
            border-color: #f2f2e6 #666661 #666661 #f2f2e6;
            margin-bottom: 5px;
            margin-left: 20px;
            width: 800px;
            height: 15px;
        }
        
        .headers
        {
           background: #0e96ec none repeat scroll 0 0;
            clear: both;
            color: #fff;
            font-family: Verdana;
            font-size: 12px;
            font-weight: bold;
            margin-left: 20px;
            padding: 5px;
        }
        
        .label
        {
            font-family: Verdana;
            font-size: 13px;
            width: 150px;
        }
        
        .text
        {
            font-family: Verdana;
            font-size: 13px;
            font-weight: bolder;
        }
        
        .text-amount
        {
            font-family: Verdana;
            font-size: 13px;
            text-align: right;
            font-weight: bold;
        }
         .redLabel
        {
            font-size: 7pt;
            color: #FF0000;
        }
          .ui-dialog
        {
            width: 800px !important;
            height: 100%;
            opacity: 1;
            z-index: 999;
            top: 0px;
            left: 0;
        }
        
        .ui-dialog-titlebar-close
        {
            visibility: hidden !important;
        }
        
        #DivLoad
        {            
            z-index:60;
            display:none;
            white-space:nowrap;
        }
        .SuccessMsg {    
        
            border: 1px solid;
            margin: 10px 0px;
            padding: 2px 2px 2px 30px;
            background-repeat: no-repeat;
            background-position: 10px center;
            background-image: url("../../../../../images/true.png");    
            color: #4F8A10;
            background-color: #DFF2BF;
            font-size:13px;   
            
        }
        .ErrorAlert 
        {
            border: 1px solid;
            margin: 10px 0px;
            padding: 2px 2px 2px 30px;
            background-repeat: no-repeat;
            background-position: 10px center;
            background-image: url("../../../../../images/exclamation.png");    
            color: #D8000C;
            background-color: #FFBABA;
            font-size:13px;       
    }
    </style>
</head>
<body>
    <form id="form1" runat="server" autocomplete="off">
    <asp:ScriptManager runat="server" ID="sm1">
    </asp:ScriptManager>
 <div style="margin-top:120px">

 </div>
        
    <div id="divLoading" style="position: fixed; left: 450px; top: 0px; background-color: white;
        border: 1px solid black;">
        <img alt="progress" src="../../../../../Images/Loading_small.gif" />
        Processing...
    </div>

    
    <div style="border: 1 1 red; height: 1050px;" id="divStep1">
         <div class="headers">
            Transaction Details, Available Balance:
            <b><asp:Label ID="availableAmt" runat="server"  ForeColor="#ffa7a7"></asp:Label></b>&nbsp;NPR

       

        </div>
        <div class="panels">
            <table>
                <tr>
                    <td colspan="2">
                        <asp:HiddenField ID="hdnInvoicePrintMethod" runat="server" />
                        <asp:HiddenField ID="hdnThresholdAmt" runat="server" />
                        <asp:HiddenField ID="hdnIsTxnDocReq" runat="server" />
                        <asp:HiddenField ID="hdnIsTxnDocExists" runat="server" />
                        <div style="font-size: 1.3em; background: white;">
                            <table>
                                <tr>
                                  
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td style="width: 150px;">
                        Delivery Method <span class="ErrMsg">*</span>
                    </td>
                    <td>
                        <asp:DropDownList ID="deliveryMethod" runat="server" style="width:240px;" CssClass="requiredField">
                        </asp:DropDownList>
                        <br />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="deliveryMethod"
                            ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran"
                            SetFocusOnError="True">                
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <fieldset id="tblAccount" style="display: none;">
                            <legend><b>Account Details</b></legend>
                            <table>
                                <tr>
                                    <td>
                                        Bank Name <span id="spnBankName" runat="server" class="ErrMsg">*</span>
                                        <asp:RequiredFieldValidator ID="rfvBankName" runat="server" ControlToValidate="bankName"
                                            ForeColor="Red" Enabled="false" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran"
                                            SetFocusOnError="True">                                    </asp:RequiredFieldValidator>
                                        <br />
                                        <asp:DropDownList ID="bankName" runat="server" Width="130px">
                                        </asp:DropDownList>
                                    </td>
                                    <td>
                                        Bank Branch Name <span id="spnBranchName" runat="server" class="ErrMsg">*</span>
                                        <br />
                                        <div id="divBankBranch">
                                            <select id="bankBranch" style="width: 130px">
                                            </select>
                                        </div>
                                    </td>
                                    <td>
                                        Account No <span id="spnAcNo" runat="server" class="ErrMsg">*</span>
                                        <asp:RequiredFieldValidator ID="rfvAcNo" runat="server" ControlToValidate="accountNo"
                                            ForeColor="Red" Enabled="false" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran"
                                            SetFocusOnError="True">                                    </asp:RequiredFieldValidator>
                                        <br />
                                        <asp:TextBox ID="accountNo" runat="server" Width="130px"></asp:TextBox>
                                    </td>
                                </tr>
                            </table>
                        </fieldset>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table id="tblLocation">
                            <tr>
                                <td style="width: 147px">
                                    Payout Location: <span class="ErrMsg">*</span>
                                </td>
                                <td>
                                    <div id="divLocation" runat="server">
                                        <select id="location" style="width:240px" onclick="PopulateDistrict();">
                                        </select>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 147px">
                                    Payout District: <span class="ErrMsg">*</span>
                                </td>
                                <td>
                                    <div id="divDistrict" runat="server">
                                        <select id="district" style="width: 240px" onchange="PopulateLocation();">
                                        </select>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        Transfer Amount: <span class="ErrMsg">*</span>
                    </td>
                    <td>
                        <asp:TextBox runat="server" ID="transferAmt" CssClass="requiredField" MaxLength="7"
                            Width="117px"></asp:TextBox>
                        <input type="button" value="Calculate" onclick="Calculate();" class="InputButtons" />
                        <img class="showHand" title="View Service Charge" id="btnSCDetails" src="../../../../../images/rule.gif"
                            border="0" onclick="LoadServiceChargeTable()" />
                        <br />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="transferAmt"
                            ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran"
                            SetFocusOnError="True">                
                        </asp:RequiredFieldValidator>
                        <cc1:FilteredTextBoxExtender ID="ftbe1" runat="server" Enabled="True" FilterType="Numbers"
                            TargetControlID="transferAmt">
                        </cc1:FilteredTextBoxExtender>
                        <div id="newDiv" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none;">
                            <table cellpadding="0" cellspacing="0" style="background: white;">
                                <tr>
                                    <td style="background-color:#E91E63; font: bold 11px Verdana; color:rgb(10, 10, 10);">
                                        Service Charge
                                    </td>
                                    <td style="background-color:#03a9f4; font: bold 11px Verdana; color: rgb(10, 10, 10)">
                                        <span title="Close" style="cursor: pointer; margin: 2px; float: right;" onclick=" RemoveDiv(); ">
                                            <b>x</b></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <div id="divSc">
                                            N/A</div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        Service Charge
                    </td>
                    <td>
                          <span style="font-size: 1.3em; font-weight: bold; color:#D8000C">
                        <asp:Label runat="server" ID="serviceCharge"></asp:Label>
                              </span>
                    </td>
                </tr>
                <tr>
                    <td>
                        Collect Amount
                    </td>
                    <td>
                        <span style="font-size: 1.3em; font-weight: bold; color:#D8000C">
                            <asp:Label runat="server" ID="collectAmt"></asp:Label></span>
                    </td>
                </tr>
                <tr>
                    <td>
                        &nbsp;
                    </td>
                    <td>
                        &nbsp;
                    </td>
                </tr>
            </table>
        </div>
        <div class="headers">
            Enter Sender Information <div style="float:right;"><asp:CheckBox ID="chkIssueCustCard" Text="Issue Customer Card" runat="server" style="display:none;" /></div> 

        </div>

        <div class="panels">
            <table>
                <tr>
                    <td>
                        <table>                      
                            <tr>
                                <td style="width: 130px">
                                    <div class="searchsender" style="display:none;">
                                        <b>Membership ID</b></div>
                                        <div class="issuemember">
                                        <b>Card No.</b> <span class="ErrMsg">*</span>
                                        </div>
                                </td>
                                <td colspan="3">
                                 <div class="searchsender" style="display:none;">
                                    <asp:TextBox runat="server" ID="sMembershipId" Width="130px"></asp:TextBox>
                                    <input type="button" id="btnFind" class="InputButtons" value="Find" />
                                    <input type="button" class="InputButtons" value="Clear Field" onclick="ClearField('s');" />
                                    <input type="button" class="InputButtons" value="View Customer" onclick="ShowSenderCustomerNewWindow();" />

                                 </div>
                                    <div class="issuemember">
                                            <asp:TextBox runat="server" ID="txtCustCardId" MaxLength="8" Width="130px"></asp:TextBox>
                                        </div>
                                    <asp:HiddenField ID="hddSMemId" runat="server" />
                                    <asp:HiddenField ID="hddSenderId" runat="server" />
                                    <asp:HiddenField ID="hddIssueCustCardInfoSaved" runat="server" />
                                    <asp:HiddenField ID="hddIssueCustCardId" runat="server" />
                                    <asp:TextBox ID="sLastName2" runat="server" Style="display: none;"></asp:TextBox>
                                </td>
                                <td>
                                   
                                </td>
                                <td>
                                   
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    First Name <span class="ErrMsg">*</span>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="sFirstName"
                                        ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran"
                                        SetFocusOnError="True"> </asp:RequiredFieldValidator>
                                </td>
                                <td>
                                    <asp:TextBox ID="sFirstName" runat="server" onkeypress="return onlyAlphabets(event,this);"
                                        CssClass="requiredField" Width="130px"></asp:TextBox>
                                </td>
                                <td>
                                    Middle
                                </td>
                                <td>
                                    <asp:TextBox ID="sMiddleName" runat="server" onkeypress="return onlyAlphabets(event,this);"
                                        Width="130px"></asp:TextBox>
                                </td>
                                <td>
                                    Last
                                </td>
                                <td>
                                    <asp:TextBox ID="sLastName1" runat="server" onkeypress="return onlyAlphabets(event,this);"
                                        CssClass="requiredField" Width="130px"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    Contact No <span class="ErrMsg">*</span>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="sContactNo"
                                        ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran"
                                        SetFocusOnError="True"> </asp:RequiredFieldValidator>
                                </td>
                                <td>
                                    <asp:TextBox ID="sContactNo" runat="server" CssClass="requiredField" Width="130px"
                                        onchange="ContactNoValidation(this)" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"></asp:TextBox>
                                </td>
                                <td nowrap="nowrap">
                                    <asp:Label ID="lblalternateMobileNo" runat="server" Text="Alternate Mobile No."></asp:Label>
                                </td>
                                <td colspan="3" nowrap="nowrap">
                                    <asp:TextBox ID="alternateMobileNo" runat="server" Width="130px" onchange="ContactNoValidation(this)"
                                        onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"></asp:TextBox>
                                    <span style="background-color: Yellow; color: red; font-weight: bold; font-size: 12px;"
                                        id="spanalternateMobileNo">Only NTC Prepaid/Ncell for free topup</span>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap">
                                    ID Type<span id="spnsIdType" class="ErrMsg"></span>
                                </td>
                                <td>
                                    <asp:DropDownList ID="sIdType" runat="server" Width="140px">
                                    </asp:DropDownList>
                                </td>
                                <td nowrap="nowrap">
                                    ID No<span id="spnsIdNo" class="ErrMsg"></span>
                                </td>
                                <td>
                                    <asp:TextBox ID="sIdNo" runat="server" Width="130px" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"
                                        onchange="IdNoValidation(this)"></asp:TextBox>
                                </td>
                                <td nowrap="nowrap">
                                    ID Issued Place <span id="spnsIdIssuedPlace" class="ErrMsg"></span>
                                </td>
                                <td>                                    
                                    <asp:DropDownList ID="sIdIssuedPlace" runat="server" Width="145px">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td nowrap="nowrap" id="tdSenIssDateLbl" runat="server">
                                    <asp:Label runat="server" ID="lblsIssDate" Text="ID Issued Date"></asp:Label>
                                    <span runat="server" class="ErrMsg" id="spntxtSenIdIssuedDate"></span>
                                </td>
                                <td id="tdSenIssDateTxt" runat="server" nowrap="nowrap" style="white-space:nowrap;">
                                    <asp:TextBox ID="txtSenIdIssuedDate" runat="server" Width="130px"></asp:TextBox>
                                </td>
                                <td id="tdSenIssDateLblBs" nowrap="nowrap" runat="server">
                                    ID Issued Date (B.S)
                                </td>
                                <td id="tdSenIssDateTxtBs" runat="server" nowrap="nowrap">
                                    <asp:TextBox ID="txtSenIdIssuedDateBs" runat="server"  MaxLength="10" Width="130px"></asp:TextBox>
                                    <br />
                                    <span class="redLabel"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                                </td>
                                <td>
                                </td>
                                <td>
                                </td>
                            </tr>

                            <tr id="trIdExpiryDate" runat="server">
                                <td nowrap="nowrap" id="tdSenExpDateLbl" runat="server">
                                    <asp:Label runat="server" ID="lblsExpDate" Text="ID Expiry Date"></asp:Label>
                                    <span runat="server" class="ErrMsg" id="spntxtSendIdValidDate"></span>
                                </td>
                                <td id="tdSenExpDateTxt" runat="server" nowrap="nowrap" style="white-space:nowrap;">
                                    <asp:TextBox ID="txtSendIdValidDate" runat="server" Width="130px"></asp:TextBox>
                                </td>
                                <td nowrap="nowrap" id="tdSenExpDateLblBs" runat="server">
                                    <asp:Label runat="server" ID="lblsExpDateBs" Text="ID Expiry Date (B.S)"></asp:Label>
                                    <span runat="server" class="ErrMsg" id="spntxtSendIdValidDateBs"></span>
                                </td>
                                <td id="tdSenExpDateTxtBs" runat="server" nowrap="nowrap">
                                    <asp:TextBox ID="txtSendIdValidDateBs" runat="server"  MaxLength="10" Width="130px"></asp:TextBox>
                                    <br />
                                    <span class="redLabel"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                                </td>
                                <td>
                                </td>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td id="tdSenDobLbl" runat="server" nowrap="nowrap">
                                    <asp:Label runat="server" ID="lblSDOB" Text="DOB"></asp:Label>
                                    <span runat="server" class="ErrMsg" id='spntxtSendDOB'></span>
                                </td>
                                <td id="tdSenDobTxt" runat="server" nowrap="nowrap" style="white-space:nowrap;">
                                    <asp:TextBox ID="txtSendDOB" runat="server" Width="130px"></asp:TextBox>
                                </td>
                                <td id="tdSenDobLblBs" runat="server" nowrap="nowrap">
                                    <asp:Label runat="server" ID="lblSDOBBs" Text="DOB (B.S)"></asp:Label>
                                    <span runat="server" class="ErrMsg" id='spntxtSendDOBBs'></span>
                                </td>
                                <td id="tdSenDobTxtBs" runat="server" nowrap="nowrap">
                                    <asp:TextBox ID="txtSendDOBBs" runat="server"  MaxLength="10" Width="130px"></asp:TextBox>
                                    <br />
                                    <span class="redLabel"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                                </td>
                                <td>
                                </td>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                </td>
                                <td colspan="5" style="background-color: Yellow; color: red; font-weight: bold; font-size: 12px; display:none;">
                                    <span id="spnThresholdMessage" runat="server"></span>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    Email
                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator6" runat="server" ValidationGroup="sendTran"
                                        ControlToValidate="sEmail" ErrorMessage="Invalid Email!" SetFocusOnError="True"
                                        ForeColor="Red" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"> </asp:RegularExpressionValidator>
                                </td>
                                <td colspan="5">
                                    <asp:TextBox ID="sEmail" runat="server" Width="311px"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    Address <span class="ErrMsg">*</span>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="sAdd"
                                        ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran"
                                        SetFocusOnError="True"> </asp:RequiredFieldValidator>
                                </td>
                                <td colspan="5">
                                    <asp:TextBox ID="sAdd" runat="server" Width="480px" Height="30px" TextMode="MultiLine"
                                        CssClass="requiredField"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    Occupation: <span id="spnoccupation" class="ErrMsg"></span>
                                </td>
                                <td colspan="5">
                                    <asp:DropDownList ID="occupation" runat="server" Width="200px">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                           
                                <tr class="issuemember">
                                    <td style="width: 92px">
                                        Gender
                                    </td>
                                    <td colspan="5">
                                        <asp:DropDownList ID="ddlGender" runat="server">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr class="issuemember">
                                    <td>
                                        Parent/Spouse Name
                                    </td>
                                    <td colspan="5">
                                        <asp:TextBox ID="txtfathermothername" runat="server" Width="260px">
                                        </asp:TextBox>
                                    </td>
                                </tr>
                                <tr class="issuemember">
                                    <td>
                                    </td>
                                    <td nowrap="nowrap">
                                        <input type="button" id="issueCustCard" value="Save Information" onclick="SaveCustInfoToIssueCard();" />
                                    </td>
                                    <td>
                                        <input type="button" id="uploadDocForCustCard" onclick="uploadCusDoc();" value="Upload Document" />
                                    </td>
                                    <td colspan="3">
                                    </td>
                                </tr>
                          

                            <tr style="display: none" id="loadImg">
                                <td colspan="2">
                                    <div runat="server" id="imgForm" style="float: left; cursor: pointer;">
                                    </div>
                                </td>
                                <td colspan="2">
                                    <div runat="server" id="imgID" style="float: left; cursor: pointer;">
                                    </div>
                                </td>
                            </tr>
                            <tr class="issuemember">
                                <td colspan="4">
                                <span id="spnCustomerEnrollMsg" style="display: block;"></span>                                                                   
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
        <div class="headers">
            Enter Receiver Information</div>
        <div class="panels">
            <table>
                <tr>
                    <td>
                        <table>
                            <tr style="display:none;">
                                <td style="width: 130px">
                                    <b>Membership ID</b>
                                </td>
                                <td colspan="5">
                                    <asp:TextBox runat="server" ID="rMembershipId" Width="130px"></asp:TextBox>
                                    <input type="button" class="InputButtons" value="Find" onclick="PickReceiver();" />
                                    <input type="button" class="InputButtons" value="View History" onclick="ViewHistory();" />
                                    <input type="button" class="InputButtons" value="Clear Field" onclick="ClearField('r');" />
                                    <input type="button" class="InputButtons" value="View Customer" onclick="ShowReceiverCustomer();" />
                                    <asp:HiddenField ID="hddRMemId" runat="server" />
                                    <asp:HiddenField ID="hddReceiverId" runat="server" />
                                    <asp:TextBox ID="rLastName2" runat="server" Style="display: none;"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    First Name <span class="ErrMsg">*</span>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator10" runat="server" ControlToValidate="rFirstName"
                                        ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran"
                                        SetFocusOnError="True"> </asp:RequiredFieldValidator>
                                </td>
                                <td>
                                    <asp:TextBox ID="rFirstName" runat="server" onkeypress="return onlyAlphabets(event,this);"
                                        CssClass="requiredField" Width="130px"></asp:TextBox>
                                </td>
                                <td nowrap="nowrap">
                                    Middle
                                </td>
                                <td nowrap="nowrap">
                                    <asp:TextBox ID="rMiddleName" runat="server" onkeypress="return onlyAlphabets(event,this);"
                                        Width="130px"></asp:TextBox>
                                </td>
                                <td>
                                    Last
                                </td>
                                <td>
                                    <asp:TextBox ID="rLastName1" runat="server" onkeypress="return onlyAlphabets(event,this);"
                                        CssClass="requiredField" Width="130px"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    Contact No
                                </td>
                                <td>
                                    <asp:TextBox ID="rContactNo" runat="server" CssClass="requiredField" Width="130px"
                                        onchange="ContactNoValidation(this)" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"></asp:TextBox>
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    ID Type
                                </td>
                                <td>
                                    <asp:DropDownList ID="rIdType" runat="server" Width="150px" CssClass="requiredField">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    ID No
                                </td>
                                <td>
                                    <asp:TextBox ID="rIdNo" runat="server" CssClass="requiredField" Width="130px" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"
                                        onchange="IdNoValidation(this)"></asp:TextBox>
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    Relationship<br />
                                    with Sender <span id="spnrelWithSender" class="ErrMsg"></span>                                    
                                </td>
                                <td>
                                    <asp:DropDownList ID="relWithSender" runat="server" Width="150px" CssClass="requiredField">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    Address <span id="spnAddress" class="ErrMsg">*</span>
                                    <asp:RequiredFieldValidator ID="rfvAddress" runat="server" ControlToValidate="rAdd"
                                        ForeColor="Red" Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran"
                                        SetFocusOnError="True"> </asp:RequiredFieldValidator>
                                </td>
                                <td colspan="5">
                                    <asp:TextBox ID="rAdd" runat="server" Width="480px" Height="30px" TextMode="MultiLine"
                                        CssClass="requiredField"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
        <div class="headers">
            Customer Due Diligence Information -(CDDI)</div>
        <div class="panels">
            <table>
                <tr>
                    <td style="width: 130px">
                        Source Of Fund: <span id="spnsof" class="ErrMsg"></span>
                    </td>
                    <td>
                        <asp:DropDownList runat="server" ID="sof" Width="325px" />
                    </td>
                   <%-- <td rowspan="3" valign="bottom">
                        In Association with<br>
                        <img alt="Global IME Bank" src="../../../../../Images/GlobalIMEBankLogo.gif" style="height: 42px;
                            width: 226px" />
                    </td>--%>
                </tr>
                <tr>
                    <td>
                        Purpose of Remittance: <span id="spnpor" class="ErrMsg"></span>
                    </td>
                    <td>
                        <asp:DropDownList runat="server" ID="por" Width="325px" />
                    </td>
                </tr>
                <tr>
                    <td> Message to Receiver</td>
                    <td colspan="2">
                        <asp:TextBox ID="remarks" runat="server" TextMode="MultiLine" Height="50px" Width="325px"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <input type="button" value="Send Transaction" class="InputButtons" onclick="VerifyTran();" />
                        <asp:Button ID="btnCancel" Text="Cancel" runat="server" CssClass="InputButtons" />
                        <div id="DivLoad" >
                            Processing ... Please Wait.....
                            <img src="../../../../../images/progressBar.gif" border="0" alt="Loading..." />
                       </div>
                        <br />

                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:HiddenField ID="hdnAgentRefId" runat="server" />
                        <asp:HiddenField ID="hdnTxnBatchId" runat="server" />
                        <asp:HiddenField ID="hdnComplianceAction" runat="server" />
                        <asp:HiddenField ID="hdnCompApproveRemark" runat="server" />
                        <asp:HiddenField ID="hddsIdPlaceOfIssue" runat="server" />
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <div id="divStep2" style="clear: both; display: none;">
        <h3>
            Summary</h3>
        <table style="width: 100%">
            <tr>
                <td class="label" style="vertical-align:top ;width: 50%">
                    <fieldset>
                        <legend>Sender</legend>
                        <table style="width: 50%">
                            <tr>
                                <td class="label">
                                    Sender's Name:
                                </td>
                                <td class="text">
                                    <span id="spanSName"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Address:
                                </td>
                                <td class="text">
                                    <span id="spanSAddress"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Contact No:
                                </td>
                                <td class="text">
                                    <span id="spanSContactNo" runat="server"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Id Type:
                                </td>
                                <td class="text">
                                    <span id="spanSIdType"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Id Number:
                                </td>
                                <td class="text">
                                    <span id="spanSIdNo"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Id Issued Place:
                                </td>
                                <td class="text">
                                    <span id="spanSIDIssuedPlace"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Id Issued Date:
                                </td>
                                <td class="text">
                                    <span id="spanSIDIssuedDate"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Id Issued Date (B.S):
                                </td>
                                <td class="text">
                                    <span id="spanSIDIssuedDateBs"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    ID Expiry Date:
                                </td>
                                <td class="text">
                                    <span id="spanSIdValidDate"></span>
                                </td>
                            </tr>
                             <tr>
                                <td class="label">
                                    ID Expiry Date (B.S):
                                </td>
                                <td class="text">
                                    <span id="spanSIdValidDateBs"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    DOB:
                                </td>
                                <td class="text">
                                    <span id="spanSDOB"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    DOB (B.S):
                                </td>
                                <td class="text">
                                    <span id="spanSDOBBs"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Email:
                                </td>
                                <td class="text">
                                    <span id="spanSEmail"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Gender:
                                </td>
                                <td class="text">
                                    <span id="spanSGender"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Parents Name:
                                </td>
                                <td class="text">
                                    <span id="spanSMotherFatherName"></span>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>                
                <td class="label" style="vertical-align:top;width:50%">
                    <fieldset>
                        <legend>Receiver</legend>
                        <table>
                            <tr>
                                <td class="label">
                                    Receiver's Name:
                                </td>
                                <td class="text">
                                    <span id="spanRName"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Address:
                                </td>
                                <td class="text">
                                    <span id="spanRAddress"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Contact No:
                                </td>
                                <td class="text">
                                    <span id="spanRContactNo"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Id Type:
                                </td>
                                <td class="text">
                                    <span id="spanRIdType"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Id Number:
                                </td>
                                <td class="text">
                                    <span id="spanRIdNo"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Relationship with Sender:
                                </td>
                                <td class="text">
                                    <span id="spanRelationship"></span>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td class="label" valign="top" style="width: 50%">
                    <fieldset>
                        <legend>Payout Detail</legend>
                        <table >
                            <tr>
                                <td class="label">
                                    Payout Location:
                                </td>
                                <td class="text">
                                    <span id="spanPLocation" ></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    District:
                                </td>
                                <td class="text">
                                    <span id="spanPDistrict"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Country:
                                </td>
                                <td class="text">
                                    <span id="spanPCountry"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Mode of Payment:
                                </td>
                                <td class="text">
                                    <span id="spanModeOfPayment"></span>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
                <td class="label" valign="top" style="width: 50%">
                    <fieldset>
                        <legend>Amount Details</legend>
                        <table>
                            <tr>
                                <td class="label">
                                    Transfer Amount:
                                </td>
                                <td class="text-amount">
                                    <span id="spanTransferAmt"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Service Charge:
                                </td>
                                <td class="text-amount">
                                    <span id="spanServiceCharge"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Total:
                                </td>
                                <td class="text-amount">
                                    <span id="spanTotalColl"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label">
                                    Payout Amount:
                                </td>
                                <td class="text-amount">
                                    <span id="spanPayoutAmt"></span>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <fieldset id="bankDetail" style="display: none;">
                        <legend>
                            <h4>
                                Bank Details</h4>
                        </legend>
                        <table style="width: 100%">
                            <tr>
                                <td class="label">
                                    Bank Name
                                    <br />
                                    <span id="spanBankName" class="text"></span>
                                </td>
                                <td class="label">
                                    Bank Branch Name
                                    <br />
                                    <span id="spanBankBranchName" class="text"></span>
                                </td>
                                <td class="label">
                                    Account Number
                                    <br />
                                    <span id="spanAccountNo" class="text"></span>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <fieldset>
                        <legend>Customer Due Diligence Information -(CDDI)</legend>
                        <table>
                            <tr>
                                <td class="label" nowrap="nowrap">
                                    Source of fund:
                                </td>
                                <td>
                                    <span id="lblSof" class="text"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label" nowrap="nowrap">
                                    Purpose of Remittance:
                                </td>
                                <td>
                                    <span id="lblPor" class="text"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label" nowrap="nowrap">
                                    Occupation:
                                </td>
                                <td>
                                    <span id="lblOccupation" class="text"></span>
                                </td>
                            </tr>
                            <tr>
                                <td class="label" nowrap="nowrap" valign="top">
                                    Message to Receiver:
                                </td>
                                <td>
                                    <span id="spanPayoutMsg" class="text"></span>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr style="display:none;">
                <td>
                    <div id="dvUploadTxnDoc" style="float: left; cursor: pointer;">
                        <a href="#" onclick="uploadTxnDoc();" title="Upload Transaction Document">Upload/View
                            Transaction Document</a>
                    </div>
                </td>
            </tr>
        </table>
        <br />
        <div id='divChkMultipleTxn' style="width: 100%; display: none;">
            <table style="width: 800px">
                <tr>
                    <td>
                        <asp:CheckBox ID="chkMultipleTxn" Checked="True" runat="server" Style="font-family: Verdana; font-weight: bold;
                            font-size: 24px; color: Red;" Text="We have verified this sender's previous transaction and want to proceed this transaction." />
                    </td>
                </tr>
            </table>
        </div>
        <br />
        <span id="spnWarningMsg" style="font-family: Verdana; font-weight: bold; font-size: 14px;
            color: Red; display: none;"></span>
        <br />
        <div id="divComplianceMultipleTxn" style="width: 100%; display: none;">
        </div>
        <div style="width: 100%; display: inline-flex;">
            <input type="button" value="Proceed" id="btnProceed" onclick="Proceed();" />
            <input type="button" value="Rectify" id="btnClose" onclick="Rectify();" />
        </div>
    </div>
    <div id="divStep3" style="display: none;">
        <table>
            <tr>
                <td>
                    <span class="text">Enter Collection Amount to Proceed:</span>
                </td>
                <td>
                    <input id="collAmtForVerify" type="text" style="width: 100px" />
                </td>
            </tr>
            <tr>
                <td>
                    <span class="text">Txn. Password:</span>
                </td>
                <td>
                    <asp:TextBox ID="txnPassword" runat="server" Width="130px" TextMode="Password"></asp:TextBox>(Note:
                    Please enter your password for the transaction confirmation)
                </td>
            </tr>
            <tr>
                <td>
                    &nbsp;
                </td>
                <td>
                    <input type="button" value="Finish" id="btnFinish" onclick="Send();" />
                </td>
            </tr>
        </table>
    </div>
    
     <div id="mydiv" title="Customer Information Details">
    </div>
    </form>
</body>
</html>
