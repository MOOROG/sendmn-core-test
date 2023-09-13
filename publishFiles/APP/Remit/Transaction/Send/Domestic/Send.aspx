<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Send.aspx.cs" Inherits="Swift.web.Remit.Transaction.Send.Domestic.Send" EnableEventValidation="false" EnableViewState="false" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>



    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../../css/jquery-ui-1.8.14.custom.css" rel="stylesheet" />
    <link href="../../../../css/TranStyle.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../../../js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <script src="../../../../../js/swift_autocomplete.js"></script>

    <script>

        function LoadCalendars() {

            CalIDIssueDate("#<% =txtSenIdIssuedDate.ClientID%>");
            VisaValidDateSend("#<% =txtSendIdValidDate.ClientID%>");
            CalSenderDOB("#<% =txtSendDOB.ClientID%>");

        }
        LoadCalendars();
    </script>

    <script type="text/javascript">
        var urlRoot = "<%=GetStatic.GetUrlRoot() %>";

        $(document).ready(function () {
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
        });

        $(document).ajaxComplete(function (event, request, settings) {
            $("#divLoading").hide();
        });

        $(document).ready(function () {
            $(".searchinput").autocomplete({

                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: urlRoot + "/Autocomplete.asmx/GetDomesticAgent",
                        data: "{'keywordStartsWith':'" + request.term + "'}",
                        dataType: "json",
                        async: true,

                        success: function (data) {
                            response(data.d);
                            alert(data.d);
                        },

                        error: function (result) {
                            alert("Due to unexpected errors we were unable to load data");
                        }
                    });
                },
                minLength: 2,

                select: function (event, ui) {
                    var result = ui.item.value;
                    SetValueById("sendBy", result, "");
                    GetElement("spnSendBy").innerHTML = result;
                    LoadAvailableBalance();
                }
            });
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
            $.get(urlRoot + "/Remit/Transaction/Send/Domestic/FormLoader.aspx", { type: 'dl', pLocation: pLocation }, function (data) {
                GetElement("divDistrict").innerHTML = data;
            });
            Calculate();
            GetElement("location").focus();
        }
        function PopulateLocation() {
            var pDistrict = GetValue("district");
            $.get(urlRoot + "/Remit/Transaction/Send/Domestic/FormLoader.aspx", { type: 'll', pDistrict: pDistrict }, function (data) {
                GetElement("divLocation").innerHTML = data;
            });
            GetElement("district").focus();
        }
        function LoadServiceChargeTable() {
            Loading('show');
            var sBranch = GetValue("<%=hdnBranchId.ClientID %>");
            var pLocation = GetValue("location");
            var dm = GetValue("<%=deliveryMethod.ClientID %>");
            var amount = GetValue("<%=transferAmt.ClientID %>");
            var pBankBranch = GetValue("bankBranch");
            $.get(urlRoot + "/Remit/Transaction/Send/Domestic/FormLoader.aspx", { sBranch: sBranch, pBankBranch: pBankBranch, pLocation: pLocation, dm: dm, amount: amount, type: 'sct' }, function (data) {
                GetElement("divSc").innerHTML = data;
                ShowHideServiceCharge();
            });
            Loading('hide');
        }
        function PopulateBankBranch() {
            var bankId = GetValue("<%=bankName.ClientID %>");
            $.get(urlRoot + "/Remit/Transaction/Send/Domestic/FormLoader.aspx", { bankId: bankId, type: 'bb' }, function (data) {
                var res = data;
                GetElement("divBankBranch").innerHTML = res;
            });
        }
        function ManageDeliveryMethod() {
            var dmObj = GetElement("<% =deliveryMethod.ClientID%>");
            var dm = $("#<% =deliveryMethod.ClientID%>  option:selected").text();
            if (dm == "Bank Deposit")
            {
                $("#tblLocation").hide();
                $("#tblAccount").show();
                //GetElement("tblLocation").style.display = "none";
                //GetElement("tblAccount").style.display = "block";
                ValidatorEnable(GetElement("<%=rfvBankName.ClientID %>"), true);
                ValidatorEnable(GetElement("<%=rfvAcNo.ClientID %>"), true);

                $("#spnRIdType").hide();
                $("#spnRIdNo").hide();
                //GetElement("spnRIdType").style.display = "none";
                //GetElement("spnRIdNo").style.display = "none";
            }
           else
            {

                $("#tblLocation").show();
                $("#tblAccount").hide();
                //GetElement("tblLocation").style.display = "block";
                //GetElement("tblAccount").style.display = "none";
                ValidatorEnable(GetElement("<%=rfvBankName.ClientID %>"), false);
                ValidatorEnable(GetElement("<%=rfvAcNo.ClientID %>"), false);

                $("#spnRIdType").show();
                $("#spnRIdNo").show();
                //GetElement("spnRIdType").style.display = "block";
                //GetElement("spnRIdNo").style.display = "block";
            }
        }
        function Callme() {
            GetElement("btn1").click();
        }
        function LoadAvailableBalance() {
            Loading('show');
            //debugger;
            //var result = GetValue("sendBy").split('|');
            var result = GetItem("sendBy")[0];
            SetValueById("<%=hdnBranchName.ClientID %>", GetItem("sendBy")[1], "");
            //alert(result);
            SetValueById("<%=hdnBranchId.ClientID %>", result, "");
            //GetElement("sendBy").value = "";
            var sBranch = result;
            //alert(result);
            $.get(urlRoot + "/Remit/Transaction/Send/Domestic/FormLoader.aspx", { sBranch: sBranch, type: 'ac' }, function (data) {
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

            $.get(urlRoot + "/Remit/Transaction/Send/Domestic/FormLoader.aspx", { memId: sMemId, type: 's' }, function (data) {
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
            $.get(urlRoot + "/Remit/Transaction/Send/Domestic/FormLoader.aspx", { memId: rMemId, type: 'r' }, function (data) {
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

        function Calculate() {
            Loading('show');
            var dm = GetValue("<% =deliveryMethod.ClientID%>");
            var tAmt = GetValue("<%=transferAmt.ClientID %>");
            var pLocation = GetValue("location");
            var sBranch = GetValue("<%=hdnBranchId.ClientID %>");
            var pBankBranch = GetValue("bankBranch");

            var thresholdAmt = GetValue("<%=hdnThresholdAmt.ClientID %>");
            if (thresholdAmt == "")
                thresholdAmt = "50000";

            if (tAmt == "") {
                Loading('hide');
                return false;
            }
            if (dm != "Bank Deposit") {
                if (pLocation == null || pLocation == "" || pLocation == "undefined") {
                    window.parent.SetMessageBox("Please Choose Payout Location", '1');
                    Loading('hide');
                    return false;
                }
            }
            var dataToSend = { MethodName: 'sc', sBranch: sBranch, pBankBranch: pBankBranch, pLocation: pLocation, tAmt: tAmt, dm: dm };
            var options =
                        {
                            url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
                            data: dataToSend,
                            dataType: 'JSON',
                            type: 'POST',
                            success: function (response) {
                                var data = jQuery.parseJSON(response);
                                if (data[0].errorCode != "0") {
                                    GetElement("<%=serviceCharge.ClientID %>").innerHTML = "";
                                    GetElement("<%=collectAmt.ClientID %>").innerHTML = "";
                                    window.parent.SetMessageBox(data[0].msg, '1');
                                    Loading('hide');
                                    return;
                                }
                                document.getElementById("<%=serviceCharge.ClientID %>").innerHTML = data[0].serviceCharge;
                                document.getElementById("<%=collectAmt.ClientID %>").innerHTML = data[0].cAmt;
                                if (parseFloat(tAmt) >= parseFloat(thresholdAmt)) {
                                    GetElement("spnsIdType").innerHTML = "<span class='ErrMsg'>*</span>";
                                    GetElement("spnsIdNo").innerHTML = "<span class='ErrMsg'>*</span>";
                                }
                                else {
                                    GetElement("spnsIdType").innerHTML = "";
                                    GetElement("spnsIdNo").innerHTML = "";
                                }
                            }
                        };
                        $.ajax(options);
                        Loading('hide');
                        return true;
                    }

                    function PickAgent() {
                        var url = urlRoot + "/Remit/Administration/AgentSetup/PickBranch.aspx";
                        var param = "dialogHeight:400px;dialogWidth:940px;dialogLeft:200;dialogTop:100;center:yes";
                        var res = PopUpWindow(url, param);
                        if (res == "undefined" || res == null || res == "") {

                        }
                        else {
                            var result = res.split('|');
                            SetValueById("<%=hdnBranchName.ClientID %>", result[0], "");
                            SetValueById("<%=hdnBranchId.ClientID %>", result[1], "");
                            SetValueById("sendBy", result[0] + "|" + result[1], "");
                            LoadAvailableBalance();
                        }
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

                            SetValueById("<% =txtSenIdIssuedDate.ClientID%>", "", false);
                            SetValueById("<% =txtSendIdValidDate.ClientID%>", "", false);
                            SetValueById("<% =sIdIssuedPlace.ClientID%>", "", false);
                            SetValueById("<% =txtSendDOB.ClientID%>", "", false);
                            SetValueById("<% =txtSendDOBBs.ClientID%>", "", false);
                            SetValueById("<% =txtSenIdIssuedDateBs.ClientID%>", "", false);
                            SetValueById("<% =txtSendIdValidDateBs.ClientID%>", "", false);

                            GetElement("<% =occupation.ClientID%>").selectedIndex = 0;

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
                            SetValueById("<% =rIdNo.ClientID%>", "", false);
                            SetValueById("<% =relWithSender.ClientID%>", "", false);
                            SetValueById("<% =hddRMemId.ClientID%>", "", false);
                            SetValueById("<% =hddReceiverId.ClientID%>", "", false);
                            EnabledReceiverFields();
                        }
                }

                function ShowHideServiceCharge() {
                    var pos = FindPos(GetElement("btnSCDetails"));
                    GetElement("newDiv").style.left = pos[0] + 35 + "px";
                    GetElement("newDiv").style.top = pos[1] - 185 + "px";
                    GetElement("newDiv").style.border = "1px solid black";
                    if (GetElement("newDiv").style.display == "none" || GetElement("newDiv").style.display == "")
                        $("#newDiv").slideToggle("fast");
                    else
                        $("#newDiv").slideToggle("fast");
                }

                function RemoveDiv() {
                    $("#newDiv").slideToggle("fast");
                }

                function Rectify() {
                    HideElement("divStep2");
                    ShowElement("divStep1");
                    MoveWindowToTop();

                }

                function MoveWindowToTop() {
                    return true;
                    var target = window.parent.document.getElementById('Td1');

                    if (target == null || target == "") {
                        return;
                    }
                    target.scrollIntoView();
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
               function ValidateMultipleTxn() {
                   if ($('#divChkMultipleTxn').is(':visible') || $('#divChkMultipleTxn').css('display') != 'none') {
                       var ischecked = $("#chkMultipleTxn").is(':checked'); //$('#chkMultipleTxn').checked;
                       if (!ischecked) {
                           window.parent.SetMessageBox('You have not verified multiple transactions warnings. Please Check, if you want to continue with warnings.', '1');
                           GetElement("<%=transferAmt.ClientID %>").focus();
                           return false;
                       }
                   }
                   return true;
               }
               function Send() {

                   Loading('show');
                   var tAmt = parseFloat(GetValue("<%=transferAmt.ClientID %>"));
                    var sc = parseFloat(GetElement("<%=serviceCharge.ClientID %>").innerHTML);
                    var collAmtForVerify = parseFloat(GetValue("collAmtForVerify"));
                    if ((tAmt + sc) != collAmtForVerify) {
                        Loading('hide');
                        window.parent.SetMessageBox('Collection Amount doesnot match. Please check the amount details.', '1');
                        HideElement("divStep3");
                        ShowElement("divStep1");
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
                        Loading('hide');
                        window.parent.SetMessageBox('Cannot Process Transaction. Service Charge not defined', '1');
                        GetElement("<%=transferAmt.ClientID %>").focus();
                        return false;
                    }

                    var sBranch = GetValue("<% =hdnBranchId.ClientID%>");
                    var sBranchText = GetValue("<% =hdnBranchName.ClientID%>");
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
                        } catch (ex) { }
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
                    } catch (ex) { }
                    if (sIdTypeObj.value == "")
                        sIdType = "";
                    var senIdTypeArr = $("#sIdType").val().split('|');

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
                    var rel = relObj.options[relObj.selectedIndex].text;
                    if (relObj.value == "")
                        rel = "";

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

                    var agentRefId = GetValue("<%=hdnAgentRefId.ClientID %>");
                    var complianceAction = GetValue("<%=hdnComplianceAction.ClientID %>");
                    var compApproveRemark = GetValue("<%=hdnCompApproveRemark.ClientID %>");
                    var txnBatchId = GetValue("<%=hdnTxnBatchId.ClientID %>");

                    var sIdValidDate = GetValue("<%=txtSendIdValidDate.ClientID %>");
                    var sDOB = GetValue("<%=txtSendDOB.ClientID %>");

                    var sIdIssuedPlace = GetValue("<%=sIdIssuedPlace.ClientID %>");
                    var sIdIssuedDate = GetValue("<%=txtSenIdIssuedDate.ClientID %>");

                    var sIdValidDateBs = GetValue("<%=txtSendIdValidDateBs.ClientID %>");
                    var sDOBBs = GetValue("<%=txtSendDOBBs.ClientID %>");
                    var sIdIssuedDateBs = GetValue("<%=txtSenIdIssuedDateBs.ClientID %>");


                    $.get(urlRoot + "/Remit/Transaction/Send/Domestic/FormLoader.aspx", {
                        sBranch: sBranch, pDistrict: pDistrictName, pLocation: pLocation, ta: ta, sc: sc, tc: tc, dm: dm
                             , pBankBranch: pBankBranch, accountNo: accountNo
                             , senderId: senderId, sMemId: sMemId, sFirstName: sFirstName, sMiddleName: sMiddleName, sLastName1: sLastName1, sLastName2: sLastName2
                             , sAddress: sAddress, sContactNo: sContactNo, sIdType: sIdType, sIdNo: sIdNo, sEmail: sEmail
                             , receiverId: receiverId, rMemId: rMemId, rFirstName: rFirstName, rMiddleName: rMiddleName, rLastName1: rLastName1, rLastName2: rLastName2
                             , rAddress: rAddress, rContactNo: rContactNo, rel: rel, rIdType: rIdType, rIdNo: rIdNo, sDOB: sDOB, sIdIssuedPlace: sIdIssuedPlace, sIdIssuedDate: sIdIssuedDate, sIdValidDate: sIdValidDate
                             , sDOBBs: sDOBBs, sIdIssuedDateBs: sIdIssuedDateBs, sIdValidDateBs: sIdValidDateBs
                             , payMsg: payMsg, sof: sof, por: por, occupation: occ
                             , type: 'st', agentRefId: agentRefId, complianceAction: complianceAction, compApproveRemark: compApproveRemark, txnBatchId: txnBatchId
                    }, function (data) {
                        var res = data.split('|');
                        if (res[0] != "0") {
                            Loading('hide');
                            window.parent.SetMessageBox(res[1], '1');
                            HideElement("divStep3");
                            ShowElement("divStep1");
                            return;
                        }
                        alert(res[1]);
                        window.location.replace("../../Reports/SearchTransaction.aspx?controlNo=" + res[2]);
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
                function SetDDlByText(ddl, val) {

                    $("#" + ddl + " option").each(function () {
                        this.selected = $(this).text() == val;
                    });
                }

                function Clear() {
                    GetElement("sendBy").value = "";
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
                                }
                        $.ajax(options);
                    });

                });
                function ParseResponseData(response) {
                    var data = response;
                    if (data[0].errCode != "0") {
                        SetValueById("<%=hddReceiverId.ClientID %>", "", "");
                        SetValueById("<%=hddSenderId.ClientID %>", "", "");
                        SetValueById("<%=hddSMemId.ClientID %>", "", "");
                        SetValueById("<%=hddRMemId.ClientID %>", "", "");
                        window.parent.SetMessageBox(data.msg, '1');
                        return;
                    }
                    SetValueById("<%=hddSenderId.ClientID %>", data[0].sCustomerId, "");
                    SetValueById("<%=sMembershipId.ClientID %>", data[0].sCustomerCardNo, "");
                    SetValueById("<%=hddSMemId.ClientID %>", data[0].sCustomerCardNo, "");
                    SetValueById("<%=sFirstName.ClientID %>", data[0].sFirstName, "");
                    SetValueById("<%=sMiddleName.ClientID %>", data[0].sMiddleName, "");
                    SetValueById("<%=sLastName1.ClientID %>", data[0].sLastName1, "");
                    SetValueById("<%=sLastName2.ClientID %>", data[0].sLastName2, "");
                    SetValueById("<%=sAdd.ClientID %>", data[0].sAddress, "");
                    SetValueById("<%=sContactNo.ClientID %>", data[0].sMobile, "");
                    SetValueById("<%=sIdType.ClientID %>", data[0].sIdType1, "");
                    SetValueById("<%=sIdNo.ClientID %>", data[0].sIdNumber, "");
                    SetValueById("<%=sEmail.ClientID %>", data[0].sEmail, "");
                    $("#sIdType").trigger("change");

                    SetValueById("<%=txtSenIdIssuedDate.ClientID %>", data[0].sIdIssuedDate, "");
                    SetValueById("<%=txtSenIdIssuedDateBs.ClientID %>", data[0].sIdIssuedDateBs, "");
                    SetValueById("<%=txtSendIdValidDate.ClientID %>", data[0].sIdExpiryDate, "");
                    SetValueById("<%=txtSendIdValidDateBs.ClientID %>", data[0].sIdExpiryDateBs, "");
                    SetValueById("<%=txtSendDOB.ClientID %>", data[0].sDOB, "");
                    SetValueById("<%=txtSendDOBBs.ClientID %>", data[0].sDOBBs, "");
                    SetDDlByText("<%=sIdIssuedPlace.ClientID %>", data[0].sPlaceOfIssue, "");
                    SetValueById("<%=hddsIdPlaceOfIssue.ClientID %>", data[0].sPlaceOfIssue, "");
                    SetIDTypeIssuedPlace();
                    SetValueById("<%=occupation.ClientID %>", data.sOccupation, "");

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
                    if (amount >= 75000 && data.sCustomerId != "") {
                        LoadImages(data[0].sCustomerId);
                    }
                    else
                        HideImages();
                }

                function ShowSenderCustomer() {
                    var customerCardNumber = GetValue("<%=sMembershipId.ClientID %>"); //"customerCardNumber";
                    if (customerCardNumber == "") {
                        alert("Please enter Membership Id!");
                        return false;
                    }
                    var url = urlRoot + "/Remit/Administration/CustomerSetup/Display.aspx?membershipId=" + customerCardNumber + "";
                    PopUpWindow(url, "dialogHeight:800px;dialogWidth:1000px;dialogLeft:300;dialogTop:100;center:yes");
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
                    var customerCardNumber = GetValue("<%=rMembershipId.ClientID %>"); //"customerCardNumber";
                    if (customerCardNumber == "") {
                        alert("Please enter Membership Id!");
                        return false;
                    }
                    var url = urlRoot + "/Remit/Administration/CustomerSetup/Display.aspx?membershipId=" + customerCardNumber + "";
                    PopUpWindow(url, "dialogHeight:800px;dialogWidth:1000px;dialogLeft:300;dialogTop:100;center:yes");
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
                                            //var data = jQuery.parseJSON(response);
                                            var data = response;
                                            $("#loadImg").show();
                                            GetElement("imgForm").innerHTML = data.imgForm;
                                            GetElement("imgID").innerHTML = data.imgID;
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
        function uploadTxnDoc() {
            var txnBatchId = GetValue("<%=hdnTxnBatchId.ClientID %>");
                    var url = "TxnDocument.aspx?txnBatchId=" + txnBatchId;
                    OpenDialog(url, 500, 820, 100, 100);
                }

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
                        url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
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
// new line

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
function checkDOBIssuedDate(dob, issuedDate) {
    if (dob != undefined && issuedDate != undefined) {
        var d_dob = Date.parse(dob);
        var d_issueDate = Date.parse(issuedDate);
        if (d_dob > d_issueDate) {
            alert("ID issued date must be greater than DOB");
            return false;
        }
    }
    return true;
}

function VerifyTran() {
    try {

        if (!Page_ClientValidate('sendTran')) {

            return false;
        }


        if (!ValidateDate()) {

            return;
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

        var sBranch = GetValue("<% =hdnBranchId.ClientID%>");
        var sBranchText = GetValue("<% =hdnBranchName.ClientID%>");
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
            ShowElement("bankDetail");
            GetElement("spanBankName").innerHTML = pBankText;
            GetElement("spanBankBranchName").innerHTML = pBankBranchText;
            GetElement("spanAccountNo").innerHTML = accountNo;
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

        //-------------- verify dob and id issued date--------------

        var retStatus = checkDOBIssuedDate(sDOB, sIdIssuedDate);
        if (retStatus == false) {
            return false;
        }

        //--------- Transaction Verification and compliance check ----------
        var result = false;
        var dataToSend = {
            MethodName: 'vt'
             , sBranch: sBranch, sBranchName: sBranchText, pDistrict: pDistrictName, pLocation: pLocation, ta: ta, sc: sc, tc: tc, dm: dm
             , pBankBranch: pBankBranch, accountNo: accountNo
             , senderId: senderId, sMemId: sMemId, sFirstName: sFirstName, sMiddleName: sMiddleName, sLastName1: sLastName1, sLastName2: sLastName2
             , sAddress: sAddress, sContactNo: sContactNo, sIdType: senIdTypeArr[0], sIdNo: sIdNo, sEmail: sEmail
             , receiverId: receiverId, rMemId: rMemId, rFirstName: rFirstName, rMiddleName: rMiddleName, rLastName1: rLastName1, rLastName2: rLastName2
             , rAddress: rAddress, rContactNo: rContactNo, rel: rel, rIdType: rIdType, rIdNo: rIdNo, sDOB: sDOB, sIdIssuedPlace: sIdIssuedPlace, sIdIssuedDate: sIdIssuedDate, sIdValidDate: sIdValidDate
             , payMsg: payMsg, txtPass: '', sof: sof, por: por, occupation: occ
             , type: 'vt', topupMobileNo: '', senIdTypeTxt: senIdTypeArr[0]
        };
        var options =
                {
                    url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
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
    if (data.errorCode == "101") {
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
    else if (data.errorCode == "1") {
        alert(data.msg);
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

            if (data.multipleTxn != "") {
                ShowElement("divComplianceMultipleTxn");
                GetElement("divComplianceMultipleTxn").innerHTML = data[0].multipleTxn;
                ShowElement("divChkMultipleTxn");

            }
            else {
                GetElement("divComplianceMultipleTxn").innerHTML = "";
                HideElement("divComplianceMultipleTxn");
                //$('#chkMultipleTxn').checked = false;
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
    }
    catch (ex) {
    }
    if (pDistrict == "") {
        pDistrictName = "";
    }
    var pLocationObj = GetElement("location");
    var pLocation = pLocationObj.value;
    var pLocationName = "";
    try {
        pLocationName = pLocationObj.options[pLocationObj.selectedIndex].text;
    }
    catch (ex) {
    }
    var ta = GetValue("<% =transferAmt.ClientID%>");
    var tc = GetElement("<% =collectAmt.ClientID%>").innerHTML;
    var sc = GetElement("<% =serviceCharge.ClientID%>").innerHTML;
    var dmObj = GetElement("<% =deliveryMethod.ClientID%>");
    var dm = "";
    try {
        dm = dmObj.options[dmObj.selectedIndex].text;
    }
    catch (ex) {
    }
    if (sc == "" || tc == "") {
        window.parent.SetMessageBox('Cannot Process Transaction. Service Charge not defined', '1');
        GetElement("<%=transferAmt.ClientID %>").focus();
        return false;
    }
    var sBranch = GetValue("<% =hdnBranchId.ClientID%>");
    var sBranchText = GetValue("<% =hdnBranchName.ClientID%>");
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
        }
        catch (ex) {
        }
        pBankBranch = pBankBranchObj.value;
        try {
            pBankBranchText = pBankBranchObj.options[pBankBranchObj.selectedIndex].text;
        }
        catch (ex) {
        }
        accountNo = GetValue("<%=accountNo.ClientID %>");
        pLocation = "";
        pLocationName = "";
        ShowElement("bankDetail");
        GetElement("spanBankName").innerHTML = pBankText;
        GetElement("spanBankBranchName").innerHTML = pBankBranchText;
        GetElement("spanAccountNo").innerHTML = accountNo;
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
        url: '<%=ResolveUrl("Send.aspx") %>?x=' + new Date().getTime(),
        data: dataToSend,
        dataType: 'JSON',
        type: 'POST',
        success: function (response) {
            var data = response;
            $("#sIdIssuedPlace").empty();

            $("#sIdIssuedPlace").append($("<option></option>").val('').html('Select'));

            $.each(data, function (key, value) {
                $("#sIdIssuedPlace").append($("<option></option>").val(value.valueId).html(value.detailTitle));
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
function CallBackAutocomplete(id) {
    LoadAvailableBalance();

}
    </script>
    <style>
        hr {
            border-top: 1px solid rgba(14, 150, 236, 0.18) !important;
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
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="/Remit/Transaction/Send/Domestic/FormLoader.aspx">Transaction</a></li>
                            <li class="active"><a href="/Remit/Transaction/Send/Domestic/ReceiverHistory.aspx">Send Transaction</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Domestic Send (Admin)
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="divLoading">
                                <img alt="progress" src="../../../../Images/Loading_small.gif" />
                                Processing...
                            </div>
                            <div style="border: 1 1 red; height: 1050px;" id="divStep1">
                                <div class="row">
                                    <asp:Panel ID="pnlAgentPick" runat="server">
                                        <div class="form-group">
                                            <label class="col-md-2 control-label">
                                                Send By:&nbsp;<span class="errormsg">*</span>
                                            </label>
                                            <div class="col-sm-3">
                                                <span id="spnSendBy" runat="server" class="welcome" style="margin-left: 0px;"></span>
                                                <uc1:SwiftTextBox ID="sendBy" runat="server" Category="sendingAgent" onfocus="Clear();" />
                                            </div>
                                            <asp:HiddenField ID="hdnBranchName" runat="server" />
                                            <asp:HiddenField ID="hdnBranchId" runat="server" />
                                            <asp:HiddenField ID="hdnInvoicePrintMethod" runat="server" />
                                            <asp:HiddenField ID="hdnThresholdAmt" runat="server" />
                                            <asp:HiddenField ID="hdnIsTxnDocReq" runat="server" />
                                            <asp:HiddenField ID="hdnIsTxnDocExists" runat="server" />
                                        </div>
                                    </asp:Panel>
                                </div>


                                <div class="row">
                                    <asp:HiddenField ID="HiddenField1" runat="server" />
                                    <label class="col-lg-2 col-md-2 control-label">Available Balance:</label>
                                    <div class="col-md-4">
                                        <span style="font-size: 1.3em; font-weight: bold; color: red">
                                            <asp:Label ID="availableAmt" runat="server"></asp:Label>
                                        </span>&nbsp;<b>NPR</b>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="form-group">
                                        <label class="col-lg-2 col-md-2 control-label">Delivery Method<span class="errormsg">*</span></label>
                                        <div class="col-sm-3">
                                            <asp:DropDownList ID="deliveryMethod" runat="server" CssClass="form-control">
                                            </asp:DropDownList>
                                            <asp:RequiredFieldValidator
                                                ID="RequiredFieldValidator3" runat="server" ControlToValidate="deliveryMethod" ForeColor="Red"
                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True">                
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>

                                </div>
                                <div class="row" style="background-color: rgba(255, 152, 0, 0.13);">
                                    <fieldset id="tblAccount" style="display: none;">
                                        <legend style="color: red;">&nbsp;&nbsp;<b>Account Details</b></legend>
                                        <div class="form-inline form-group">
                                            <div class="col-md-4">
                                                <label class="control-label">Bank Name</label>
                                                <span id="spnBankName" runat="server" class="errormsg">*</span>
                                                <asp:RequiredFieldValidator
                                                    ID="rfvBankName" runat="server" ControlToValidate="bankName" ForeColor="Red" Enabled="false"
                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True"> 
                                                </asp:RequiredFieldValidator>
                                                <br />
                                                <asp:DropDownList ID="bankName" runat="server" CssClass="form-control" Width="240px"></asp:DropDownList>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="control-label">Bank Branch Name</label>

                                                <span id="spnBranchName" runat="server" class="errormsg">*</span>
                                                <br />
                                                <div id="divBankBranch">
                                                    <select id="bankBranch" class="form-control" width="240px"></select>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="control-label">Account No</label>


                                                <span id="spnAcNo" runat="server" class="errormsg">*</span>
                                                <asp:RequiredFieldValidator
                                                    ID="rfvAcNo" runat="server" ControlToValidate="accountNo" ForeColor="Red" Enabled="false"
                                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True"> 
                                                </asp:RequiredFieldValidator>
                                                <br />
                                                <asp:TextBox ID="accountNo" runat="server" CssClass="form-control" Width="240px"></asp:TextBox>
                                            </div>
                                        </div>
                                        <hr />

                                    </fieldset>

                                </div>

                                <div id="tblLocation">
                                    <div class="row">
                                        <div class="form-group">
                                            <label class="col-lg-2 col-md-2 control-label">Payout Location: <span class="errormsg">*</span></label>
                                            <div class="col-sm-3">
                                                <div id="divLocation" runat="server">
                                                    <select id="location" class="form-control" onclick="PopulateDistrict();"></select>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <label class="col-lg-2 col-md-2 control-label">Payout District: <span class="errormsg">*</span></label>

                                            <div class="col-sm-3">

                                                <div id="divDistrict" runat="server">
                                                    <select id="district" onchange="PopulateLocation();" class="form-control"></select>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="form-group">
                                        <label class="col-lg-2 col-md-2 control-label">Transfer Amount:<span class="errormsg">*</span></label>
                                        <div class="col-sm-3">
                                            <asp:TextBox runat="server" ID="transferAmt" CssClass="requiredField form-control" MaxLength="7"></asp:TextBox>
                                        </div>
                                        <input type="button" value="Calculate" onclick="Calculate();" class="btn btn-primary" />
                                        <img class="showHand" title="View Service Charge" id="btnSCDetails" src="../../../../Images/rule.gif" border="0" onclick="LoadServiceChargeTable()" />
                                    </div>
                                </div>

                                <br />
                                <asp:RequiredFieldValidator
                                    ID="RequiredFieldValidator1" runat="server" ControlToValidate="transferAmt" ForeColor="Red"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True">                
                                </asp:RequiredFieldValidator>
                                <cc1:FilteredTextBoxExtender ID="ftbe1"
                                    runat="server" Enabled="True" FilterType="Numbers" TargetControlID="transferAmt">
                                </cc1:FilteredTextBoxExtender>
                                <div id="newDiv" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none;">
                                    <table cellpadding="0" cellspacing="0" style="background: white;">
                                        <tr>
                                            <td style="background-color: rgba(169, 68, 66, 0.96); font: bold 11px Verdana; color: #FFFFFF;">Service Charge</td>
                                            <td style="background-color: #F44336; font: bold 11px Verdana; color: #FFFFFF;">
                                                <span title="Close" style="cursor: pointer; margin: 2px; float: right;" onclick=" RemoveDiv(); "><b>x</b></span>                                </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <div id="divSc">N/A</div>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <div class="row">
                                    <div class="form-group">
                                        <label class="control-label col-md-2 col-lg-2">Service Charge</label>
                                        <div class="col-md-4">
                                            <span style="font-size: 1.3em; font-weight: bold; color: red">
                                                <asp:Label runat="server" ID="serviceCharge"></asp:Label>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label col-md-2 col-lg-2">Collect Amount</label>
                                        <div class="col-md-4">
                                            <span style="font-size: 1.3em; font-weight: bold; color: red;">
                                                <asp:Label runat="server" ID="collectAmt"></asp:Label></span>
                                        </div>
                                    </div>
                                </div>
                                <hr />

                                <h2>Enter Sender Information</h2>

                                <div class="row">
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label"><b>Membership ID</b></label>
                                        <div class="col-sm-2">
                                            <asp:TextBox runat="server" ID="sMembershipId" Width="100%" CssClass="form-control"></asp:TextBox>
                                        </div>

                                        <input type="button" id="btnFind" class="btn btn-primary" value="Find" />
                                        <input type="button" class="btn btn-primary" value="Clear Field" onclick="ClearField('s');" />
                                        <input type="button" class="btn btn-primary" value="View Customer" onclick="ShowSenderCustomer();" />
                                        <div class="col-sm-2">
                                            <asp:TextBox ID="sLastName2" runat="server" Style="display: none;" CssClass="form-control"></asp:TextBox>
                                        </div>
                                        <asp:HiddenField ID="hddSMemId" runat="server" />
                                        <asp:HiddenField ID="hddSenderId" runat="server" />
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">First Name<span class="errormsg">*</span></label>
                                        <asp:RequiredFieldValidator
                                            ID="RequiredFieldValidator4" runat="server" ControlToValidate="sFirstName" ForeColor="Red"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True"> </asp:RequiredFieldValidator>
                                        <div class="col-sm-2">
                                            <asp:TextBox ID="sFirstName" runat="server" onkeypress="return onlyAlphabets(event,this);" CssClass="requiredField form-control" Width="100%"></asp:TextBox>
                                        </div>

                                        <label class="col-sm-2 control-label">Middle</label>
                                        <div class="col-sm-2">
                                            <asp:TextBox ID="sMiddleName" runat="server" onkeypress="return onlyAlphabets(event,this);" Width="100%" CssClass="form-control"></asp:TextBox>
                                        </div>

                                        <label class="col-sm-2 control-label">Last</label>
                                        <div class="col-sm-2">
                                            <asp:TextBox ID="sLastName1" runat="server" onkeypress="return onlyAlphabets(event,this);" CssClass="requiredField form-control" Width="100%"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Contact No<span class="errormsg">*</span></label>

                                        <asp:RequiredFieldValidator
                                            ID="RequiredFieldValidator7" runat="server" ControlToValidate="sContactNo" ForeColor="Red"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True"> </asp:RequiredFieldValidator></td>
                     <div class="col-sm-2">
                         <asp:TextBox ID="sContactNo" runat="server" CssClass="requiredField form-control" Width="130px" onchange="ContactNoValidation(this)" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"></asp:TextBox>
                         <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender1"
                             runat="server" Enabled="True" FilterType="Numbers" TargetControlID="sContactNo">
                         </cc1:FilteredTextBoxExtender>
                     </div>
                                    </div>
                                </div>


                                <div class="row">
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">ID Type<span id="spnsIdType" class="errormsg"></span></label>

                                        <div class="col-sm-2">
                                            <asp:DropDownList ID="sIdType" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>

                                        <label class="col-sm-2 control-label">ID No<span id="spnsIdNo" class="errormsg"></span></label>

                                        <div class="col-sm-2">
                                            <asp:TextBox ID="sIdNo" runat="server" CssClass="form-control" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);" onchange="IdNoValidation(this)"></asp:TextBox>
                                        </div>

                                        <label class="col-sm-2 control-label">ID Issued Place <span id="spnsIdIssuedPlace" class="errormsg"></span></label>
                                        <div class="col-sm-2">
                                            <asp:DropDownList ID="sIdIssuedPlace" runat="server" CssClass="form-control">
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="form-group">
                                        <div id="tdSenIssDateLbl" runat="server" class="col-sm-2">
                                            <asp:Label runat="server" ID="lblsIssDate" Text="ID Issued Date" CssClass="control-label"></asp:Label>
                                            <span runat="server" class="errormsg" id="spntxtSenIdIssuedDate"></span>
                                        </div>
                                        <div id="tdSenIssDateTxt" runat="server" nowrap="nowrap" class="col-sm-2">
                                            <div class="input-group m-b">
                                                <span class="input-group-addon">
                                                    <i class="fa fa-calendar" aria-hidden="true"></i>
                                                </span>
                                                <asp:TextBox ID="txtSenIdIssuedDate" ReadOnly="true" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div id="tdSenIssDateLblBs" nowrap="nowrap" runat="server" class="col-sm-2 control-label">
                                            ID Issued Date (B.S)
                                        </div>
                                        <div id="tdSenIssDateTxtBs" runat="server" nowrap="nowrap" class="col-sm-2">
                                            <asp:TextBox ID="txtSenIdIssuedDateBs" runat="server" CssClass="form-control"></asp:TextBox>
                                            <span class="redLabel"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="form-group">
                                        <div id="trIdExpiryDate" runat="server">
                                            <div nowrap="nowrap" id="tdSenExpDateLbl" runat="server" class="col-sm-2 ">
                                                <asp:Label runat="server" ID="lblsExpDate" Text="ID Expiry Date" CssClass="control-label"></asp:Label>
                                                <span runat="server" class="errormsg" id="spntxtSendIdValidDate"></span>
                                            </div>
                                            <div id="tdSenExpDateTxt" runat="server" nowrap="nowrap" class="col-sm-2 ">
                                                <div class="input-group m-b">
                                                    <span class="input-group-addon">
                                                        <i class="fa fa-calendar" aria-hidden="true"></i>
                                                    </span>
                                                    <asp:TextBox ID="txtSendIdValidDate" ReadOnly="true" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div nowrap="nowrap" id="tdSenExpDateLblBs" runat="server" class="col-sm-2">
                                                <asp:Label runat="server" ID="lblsExpDateBs" Text="ID Expiry Date (B.S)" CssClass="control-label"></asp:Label>
                                                <span runat="server" class="errormsg" id="spntxtSendIdValidDateBs"></span>
                                            </div>
                                            <div id="tdSenExpDateTxtBs" runat="server" nowrap="nowrap" class="col-sm-2">
                                                <asp:TextBox ID="txtSendIdValidDateBs" runat="server" CssClass="form-control"></asp:TextBox>
                                                <span class="redLabel"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="form-group">

                                        <div id="tdSenDobLbl" runat="server" nowrap="nowrap" class="col-sm-2">
                                            <asp:Label runat="server" ID="lblSDOB" Text="DOB" CssClass="control-label"></asp:Label>
                                            <span runat="server" class="errormsg" id='spntxtSendDOB'></span>
                                        </div>
                                        <div id="tdSenDobTxt" runat="server" nowrap="nowrap" class="col-sm-2">
                                            <div class="input-group m-b">
                                                <span class="input-group-addon">
                                                    <i class="fa fa-calendar" aria-hidden="true"></i>
                                                </span>
                                                <asp:TextBox ID="txtSendDOB" runat="server" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div id="tdSenDobLblBs" runat="server" nowrap="nowrap" class="col-sm-2">
                                            <asp:Label runat="server" ID="lblSDOBBs" Text="DOB (B.S)" CssClass="control-label"></asp:Label>
                                            <span runat="server" class="ErrMsg" id='spntxtSendDOBBs'></span>
                                        </div>
                                        <div id="tdSenDobTxtBs" runat="server" nowrap="nowrap" class="col-sm-2">
                                            <asp:TextBox ID="txtSendDOBBs" runat="server" CssClass="form-control"></asp:TextBox>
                                            <span class="redLabel"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>

                                        </div>
                                    </div>
                                </div>

                                <div class="alert alert-info">
                                    <span id="spnThresholdMessage" runat="server"></span>
                                </div>


                                <div class="row">
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Email</label>
                                        <asp:RegularExpressionValidator ID="RegularExpressionValidator6" runat="server"
                                            ValidationGroup="sendTran"
                                            ControlToValidate="sEmail" ErrorMessage="Invalid Email!" SetFocusOnError="True" ForeColor="Red"
                                            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"> </asp:RegularExpressionValidator>
                                        <div class=" col-sm-4 ">
                                            <asp:TextBox ID="sEmail" runat="server" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Address</label>
                                        <asp:RequiredFieldValidator
                                            ID="RequiredFieldValidator6" runat="server" ControlToValidate="sAdd" ForeColor="Red"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True"> </asp:RequiredFieldValidator>
                                        <div class=" col-sm-4 ">
                                            <asp:TextBox ID="sAdd" runat="server" TextMode="MultiLine" CssClass="form-control requiredField"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>



                                <div class="row">
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Occupation:<span id="spnoccupation" class="errormsg"></span></label>
                                        <div class="col-sm-2">
                                            <asp:DropDownList ID="occupation" runat="server" CssClass=" form-control">
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>

                                <hr />

                                <div style="display: none" id="loadImg">

                                    <div runat="server" id="imgForm" style="float: left; cursor: pointer;">
                                    </div>

                                    <div>
                                        <div runat="server" id="imgID" style="float: left; cursor: pointer;">
                                        </div>
                                    </div>
                                </div>




                                <h2>Enter Receiver Information</h2>

                                <div>
                                    <div class="row">
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label"><b>Membership ID</b></label>
                                            <div class="col-sm-2">
                                                <asp:TextBox runat="server" ID="rMembershipId" CssClass="col-sm-2 form-control"></asp:TextBox>
                                            </div>
                                            <input type="button" class="btn btn-primary" value="Find" onclick="PickReceiver();" />
                                            <input type="button" class="btn btn-primary" value="View History" onclick="ViewHistory();" />
                                            <input type="button" class="btn btn-primary" value="Clear Field" onclick="ClearField('r');" />
                                            <input type="button" class="btn btn-primary" value="View Customer" onclick="ShowReceiverCustomer();" />
                                            <asp:HiddenField ID="hddRMemId" runat="server" />
                                            <asp:HiddenField ID="hddReceiverId" runat="server" />
                                            <asp:TextBox ID="rLastName2" runat="server" Style="display: none;" CssClass="col-sm-2 form-control"></asp:TextBox>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="form-group">

                                            <label class="col-sm-2 control-label">First Name <span class="errormsg">*</span></label>

                                            <asp:RequiredFieldValidator
                                                ID="RequiredFieldValidator10" runat="server" ControlToValidate="rFirstName" ForeColor="Red"
                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True"> </asp:RequiredFieldValidator>
                                            <div class="col-sm-2 ">
                                                <asp:TextBox ID="rFirstName" runat="server" onkeypress="return onlyAlphabets(event,this);" CssClass="form-control requiredField"></asp:TextBox>
                                            </div>
                                            <label class="col-sm-2 control-label">Middle</label>
                                            <div class="col-sm-2 ">
                                                <asp:TextBox ID="rMiddleName" runat="server" onkeypress="return onlyAlphabets(event,this);" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <label class="col-sm-2 control-label">Last</label>
                                            <div class="col-sm-2">
                                                <asp:TextBox ID="rLastName1" runat="server" onkeypress="return onlyAlphabets(event,this);" CssClass="form-control requiredField"></asp:TextBox>

                                            </div>

                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Contact No</label>
                                            <div class="col-sm-2">
                                                <asp:TextBox ID="rContactNo" runat="server" CssClass="form-control requiredField" onchange="ContactNoValidation(this)" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"></asp:TextBox>

                                            </div>
                                            <cc1:FilteredTextBoxExtender ID="FilteredTextBoxExtender2"
                                                runat="server" Enabled="True" FilterType="Numbers" TargetControlID="rContactNo">
                                            </cc1:FilteredTextBoxExtender>
                                        </div>
                                    </div>



                                    <div class="row">
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">ID Type</label>
                                            <div class="col-sm-2">
                                                <asp:DropDownList ID="rIdType" runat="server" CssClass="form-control requiredField"></asp:DropDownList>

                                            </div>
                                            <label class="col-sm-2 control-label">ID No</label>
                                            <div class="col-sm-2">
                                                <asp:TextBox ID="rIdNo" runat="server" CssClass="form-control requiredField" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);" onchange="IdNoValidation(this)"></asp:TextBox></td>

                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Relationship with Sender <span id="spnrelWithSender" class="errormsg"></span></label>
                                            <div class="col-sm-2">
                                                <asp:DropDownList ID="relWithSender" runat="server" CssClass="form-control requiredField"></asp:DropDownList>

                                            </div>

                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <label class="control-label col-sm-2">Address<span id="spnAddress" class="errormsg">*</span></label>
                                            <asp:RequiredFieldValidator
                                                ID="rfvAddress" runat="server" ControlToValidate="rAdd" ForeColor="Red"
                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="sendTran" SetFocusOnError="True"> </asp:RequiredFieldValidator></td>
                         <div class="col-sm-4">
                             <asp:TextBox ID="rAdd" runat="server" TextMode="MultiLine" CssClass="form-control requiredField"></asp:TextBox>

                         </div>
                                        </div>
                                    </div>


                                </div>

                                <hr />
                                <h2>Customer Due Diligence Information -(CDDI)</h2>

                                <div>
                                    <div class="row">
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Source Of Fund:<span id="spnsof" class="errormsg"></span></label>
                                            <div class="col-sm-2">
                                                <asp:DropDownList runat="server" ID="sof" CssClass="form-control" />

                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Purpose of Remittance: <span id="spnpor" class="errormsg"></span></label>
                                            <div class="col-sm-2">
                                                <asp:DropDownList runat="server" ID="por" CssClass="form-control" />

                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Message to Receiver</label>
                                            <div class="col-sm-4">
                                                <asp:TextBox ID="remarks" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>

                                            </div>
                                        </div>
                                    </div>

                                    <div class="row col-sm-12">
                                        <input type="button" value="Send Transaction" class="btn btn-primary" onclick="VerifyTran();" />
                                        <asp:Button ID="btnCancel" Text="Cancel" runat="server" CssClass="btn btn-danger" />
                                        <asp:HiddenField ID="hdnAgentRefId" runat="server" />
                                        <asp:HiddenField ID="hdnTxnBatchId" runat="server" />
                                        <asp:HiddenField ID="hdnComplianceAction" runat="server" />
                                        <asp:HiddenField ID="hdnCompApproveRemark" runat="server" />
                                        <asp:HiddenField ID="hddsIdPlaceOfIssue" runat="server" />
                                    </div>
                                </div>
                            </div>
                            <div id="divStep2" style="clear: both; display: none;">
                                <h3>Summary</h3>
                                <div class="row">
                                    <div class="col-md-6">
                                        <fieldset>
                                            <legend style="color: red;">Sender</legend>
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td class="control-label" width="180px">Sender's Name: </td>
                                                    <td class="text">
                                                        <span id="spanSName"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Address: </td>
                                                    <td class="text">
                                                        <span id="spanSAddress"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Contact No: </td>
                                                    <td class="text">
                                                        <span id="spanSContactNo" runat="server"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Id Type:</td>
                                                    <td class="text">
                                                        <span id="spanSIdType"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Id Number </td>
                                                    <td class="text">
                                                        <span id="spanSIdNo"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Id Issued Place:
                                                    </td>
                                                    <td class="text">
                                                        <span id="spanSIDIssuedPlace"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Id Issued Date:
                                                    </td>
                                                    <td class="text">
                                                        <span id="spanSIDIssuedDate"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Id Issued Date (B.S):
                                                    </td>
                                                    <td class="text">
                                                        <span id="spanSIDIssuedDateBs"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">ID Expiry Date:
                                                    </td>
                                                    <td class="text">
                                                        <span id="spanSIdValidDate"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">ID Expiry Date (B.S):
                                                    </td>
                                                    <td class="text">
                                                        <span id="spanSIdValidDateBs"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">DOB:
                                                    </td>
                                                    <td class="text">
                                                        <span id="spanSDOB"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">DOB (B.S):
                                                    </td>
                                                    <td class="text">
                                                        <span id="spanSDOBBs"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Email: </td>
                                                    <td class="text">
                                                        <span id="spanSEmail"></span>
                                                    </td>
                                                </tr>

                                            </table>
                                        </fieldset>
                                    </div>
                                    <div class="col-md-6">
                                        <fieldset>
                                            <legend style="color: red;">Receiver</legend>
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td class="control-label" width="180px">Receiver's Name: </td>
                                                    <td class="text">
                                                        <span id="spanRName"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Address: </td>
                                                    <td class="text">
                                                        <span id="spanRAddress"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Contact No: </td>
                                                    <td class="text">
                                                        <span id="spanRContactNo"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Id Type: </td>
                                                    <td class="text">
                                                        <span id="spanRIdType"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Id Number: </td>
                                                    <td class="text">
                                                        <span id="spanRIdNo"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Relationship with Sender: </td>
                                                    <td class="text">
                                                        <span id="spanRelationship"></span>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>
                                    </div>
                                </div>
                                <div class="row">
                                    &nbsp;
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <fieldset>
                                            <legend style="color: red;">Payout Detail</legend>
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td class="control-label" width="180px">Payout Location: </td>
                                                    <td class="text">
                                                        <span id="spanPLocation"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">District:</td>
                                                    <td class="text">
                                                        <span id="spanPDistrict"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Country: </td>
                                                    <td class="text">
                                                        <span id="spanPCountry"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Mode of Payment: </td>
                                                    <td class="text">
                                                        <span id="spanModeOfPayment"></span>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>
                                    </div>
                                    <div class="col-md-6">
                                        <fieldset>
                                            <legend style="color: red;">Amount Details</legend>
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td class="control-label" width="180px">Transfer Amount: </td>
                                                    <td class="text-amount">
                                                        <span id="spanTransferAmt" style="background-color:yellow;color:red"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Service Charge: </td>
                                                    <td class="text-amount">
                                                        <span id="spanServiceCharge" style="background-color:yellow;color:red"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Total: </td>
                                                    <td class="text-amount">
                                                        <span id="spanTotalColl" style="background-color:yellow;color:red"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label">Payout Amount: </td>
                                                    <td class="text-amount">
                                                        <span id="spanPayoutAmt" style="background-color:yellow;color:red"></span>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>
                                    </div>
                                </div>
                                <div class="row">
                                    &nbsp;
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <fieldset>
                                            <legend style="color: red;">Customer Due Diligence Information -(CDDI)</legend>
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td class="control-label" nowrap="nowrap" width="180px">Source of fund:
                                                    </td>
                                                    <td>
                                                        <span id="lblSof" class="text"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label" nowrap="nowrap">Purpose of Remittance:
                                                    </td>
                                                    <td>
                                                        <span id="lblPor" class="text"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label" nowrap="nowrap">Occupation:
                                                    </td>
                                                    <td>
                                                        <span id="lblOccupation" class="text"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="control-label" nowrap="nowrap" valign="top">Message to Receiver:
                                                    </td>
                                                    <td>
                                                        <span id="spanPayoutMsg" class="text"></span>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>
                                    </div>
                                    <div class="col-md-6">

                                        <fieldset id="bankDetail" style="display: none;">
                                            <legend style="color: red;">Bank Details
                                            </legend>
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td class="control-label" width="180px">Bank Name
                                    <br />
                                                        <span id="spanBankName" class="text"></span>
                                                    </td>
                                                    <td class="control-label">Bank Branch Name
                                    <br />
                                                        <span id="spanBankBranchName" class="text"></span>
                                                    </td>
                                                    <td class="control-label">Account Number
                                    <br />
                                                        <span id="spanAccountNo" class="text"></span>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>

                                    </div>

                                </div>
                                <div class="row">
                                    &nbsp;
                                </div>
                                <div id='divChkMultipleTxn' style="width: 100%; display: none;">
                                    <table class="table table-responsive">
                                        <asp:CheckBox ID="chkMultipleTxn" runat="server" Style="font-family: Verdana; font-weight: bold; font-size: 18px; color: Red;"
                                        Text="We have verified this sender's previous transaction and want to proceed this transaction." />
                                    </table>
                                </div>
                                <br />
                                <span id="spnWarningMsg" style="font-family: Verdana; font-weight: bold; font-size: 14px; color: Red; display: none;"></span>
                                <br />
                                <div class="table-responsive">
                                    <div id="divComplianceMultipleTxn" style="display: none;">
                                    </div>
                                 </div>
                           
                                <div style="display: inline-flex;">
                                    <input type="button" value="Proceed" id="btnProceed" class="btn btn-primary m-t-25"  onclick="Proceed();" />
                                    <input type="button" value="Rectify" id="btnClose" class="btn btn-primary m-t-25"  onclick="Rectify();" />
                                    </div>
                            </div>
                            <div id="divStep3" style="display: none;" tabindex="1">
                                <div class="row">
                                  <div class="form-group">
                                       <div class="col-md-3">
                                         Enter Collection Amount to Proceed
                                        </div>
                                        <div class="col-md-4">
                                            <input id="collAmtForVerify" class="form-control" type="text"/>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-md-3">
                                        </div>
                                         <div class="col-md-4">
                                            <input type="button"  class="btn btn-primary m-t-25" value="Finish" id="btnFinish" onclick="Send();" />
                                        </div>
                                      </div>
                                </div>
                           </div>
                            <div id="mydiv" title="Customer Information Details">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
<style>
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

</html>
