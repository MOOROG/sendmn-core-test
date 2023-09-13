<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="SendV2.aspx.cs" Inherits="Swift.web.AgentNew.SendTxnInficare.SendV2" %>

<%@ Register Src="/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        #divStep1 .panel-body {
            /*background: rgba(236, 28, 28, 0.2);*/
            background: rgba(174, 214, 241, 0.4);
        }

        .error {
            color: red;
        }

        #divStep1 .panel-body td {
            color: #212121;
            font-size: 12px !important;
        }

            #divStep1 .panel-body td .form-control {
                font-size: 12px !important;
            }

        input, textarea {
            text-transform: uppercase;
        }

        @media (max-width: 986px) {
            #msgRecDiv {
                width: 27%;
            }
        }

        @media (min-width: 1024px) {
            #msgRecDiv {
                width: 13%;
            }
        }

        .input-group-addon {
            padding: 4px 12px !important;
            font-weight: 600 !important;
        }

        .input-group .form-control:first-child {
            font-weight: 600 !important;
        }

        .input-group {
            position: relative;
        }

            .input-group label.error {
                position: absolute;
                left: 0;
                z-index: 999;
                top: 30px;
            }

        .amountDiv {
            background: none repeat scroll 0 0 black;
            clear: both;
            color: white;
            float: right;
            font-size: 12px;
            font-weight: 600;
            padding: 2px 8px;
            margin-right: 15px;
            margin-bottom: 10px;
            width: auto;
        }

        .ErrMsg {
            color: red !important;
        }

        td:empty:after {
            content: "\00a0";
        }

        @media (min-width: 768px) {
            .container {
                width: 100% !important;
            }
        }
    </style>

    <script type="text/javascript">

        function AddNewReceiver(senderId) {
            url = "" + "/AgentNew/Administration/CustomerSetup/Benificiar/Manage.aspx?customerId=" + senderId + "&AddType=s";
            var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
            var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";
            if (isChrome) {
                PopUpWindow(url, param);
                return true;
            }
            var id = PopUpWindow(url, param);

            if (id == "undefined" || id == null || id == "") {
            }
            else {
                PopulateReceiverDDL(senderId);
                SearchReceiverDetails(id);
            }
        }

        function PostMessageToParentAddReceiver(id) {
            var senderId = $("#ContentPlaceHolder1_txtSearchData_aValue").val();
            PopulateReceiverDDL(senderId);
            SearchReceiverDetails(id);
        }

        $(document).ready(function () {
            $('#subLocation').hide();
            $('#ContentPlaceHolder1_introducerTxt_aText').attr("placeholder", "Referral (If any)");
            $('#divHideShow').show();
            $('.displayPayerInfo').hide();
            var customerIdFromMapping = '<%=GetCustomerId()%>';

            $('#<%=ddlCustomerType.ClientID%>').change(function () {
                <%=txtSearchData.InitFunction() %>
            });
            //added by gunn
            $('#ContentPlaceHolder1_introducerTxt_aSearch').blur(function () {
                var referral = $('#ContentPlaceHolder1_introducerTxt_aText').val();
                if (referral == "") {
                    $('#availableBalReferral').text('');
                    $('#availableBalReferral').val('');
                    $('#<%=hdnRefAvailableLimit.ClientID%>').val('');
                    $('#availableBalSpanReferral').hide();
                }
            });

            if (customerIdFromMapping !== null && customerIdFromMapping !== '') {
                $('#<%=NewCust.ClientID%>').prop('checked', false);
                $('#<%=ExistCust.ClientID%>').prop('checked', true);
                ExistingData();
                PopulateReceiverDDL(customerIdFromMapping);
                SearchCustomerDetails(customerIdFromMapping, 'mapping');
            }
            $('.trScheme').hide();
            $("#<%=editServiceCharge.ClientID%>").attr("disabled", true);
            $("#<%=lblServiceChargeAmt.ClientID%>").attr("readonly", true);
            $("#<%=ddlCustomerType.ClientID%>").change(function () {
                var d = ["", ""];
                SetItem("<% =txtSearchData.ClientID%>", d);
                <%= txtSearchData.InitFunction() %>;

            });
            $("#<%=editServiceCharge.ClientID%>").change(function () {
                if ($('#<%=allowEditSC.ClientID%>').val() == 'N') {
                    alert('You are not allowed to edit Service Charge!');
                    $("#<%=editServiceCharge.ClientID%>").prop("checked", false);
                    return false;
                }
                var ischecked = $(this).is(':checked');
                if (ischecked) {
                    $('#<%=lblServiceChargeAmt.ClientID%>').removeAttr('disabled');
                    $('#<%=lblServiceChargeAmt.ClientID%>').removeAttr('readonly');
                }
                else {
                    $('#<%=lblServiceChargeAmt.ClientID%>').attr('disabled', true);
                    $('#<%=lblServiceChargeAmt.ClientID%>').attr('readonly', true);
                }

            });

            $('#<%=customerRateFields.ClientID%>').hide();

            $(window).focus(function () {
                if ($('#confirmHidden').val() != '') {
                    var id = $('#confirmHidden').val();
                    $('#confirmHidden').val('');

                    if (id == "undefined" || id == null || id == "") {
                    }
                    else {
                        var res = id.split('-:::-');
                        if (res[0] == "1") {
                            var errMsgArr = res[1].split('\n');
                            for (var i = 0; i < errMsgArr.length; i++) {
                                alert(errMsgArr[i]);
                            }
                        }
                        else {
                            ClearAllCustomerInfo();
                            window.location.replace("/AgentNew/SendTxn/SendIntlReceipt.aspx?controlNo=" + res[2] + "&invoicePrint=" + res[3]);
                        }
                    }
                }
            });

            $('#ContentPlaceHolder1_txtPayMsg').focus(function () {
                if ($('#confirmHiddenChrome').val() != '') {
                    var id = $('#confirmHiddenChrome').val();
                    $('#confirmHiddenChrome').val('');
                    $('#ContentPlaceHolder1_txtSearchData_aSearch').blur();

                    if (id == "undefined" || id == null || id == "") {
                    }
                    else {
                        var res = id.split('-:::-');
                        if (res[0] == "1") {
                            var errMsgArr = res[1].split('\n');
                            for (var i = 0; i < errMsgArr.length; i++) {
                                alert(errMsgArr[i]);
                            }
                        }
                        else {
                            ClearAllCustomerInfo();
                            window.location.replace("/AgentNew/SendTxn/SendIntlReceipt.aspx?controlNo=" + res[2] + "&invoicePrint=" + res[3]);
                        }
                    }
                }
            });
        });

        function ChangeCalcBy() {
            ClearCalculatedAmount();
            if ($("#<%=txtPayAmt.ClientID%>").is(":disabled")) {
                $('#<%=txtCollAmt.ClientID%>').attr('disabled', true);
                $('#<%=txtPayAmt.ClientID%>').attr('disabled', false);
            } else {
                $('#<%=txtPayAmt.ClientID%>').attr('disabled', true);
                $('#<%=txtCollAmt.ClientID%>').attr('disabled', false);
            }
        }

        function PostMessageToParent(id) {
            alert(id);
            if (id == "undefined" || id == null || id == "") {
            }
            else {
                var res = id.split('-:::-');
                if (res[0] == "1") {
                    var errMsgArr = res[1].split('\n');
                    for (var i = 0; i < errMsgArr.length; i++) {
                        alert(errMsgArr[i]);
                    }
                }
                else {
                    ClearAllCustomerInfo();
                    window.location.replace("/AgentNew/SendTxn/SendIntlReceipt.aspx?controlNo=" + res[2] + "&invoicePrint=" + res[3]);
                }
            }
        }

        function ReCalculate() {
            if (!$("#<%=lblServiceChargeAmt.ClientID%>").attr("readonly")) {
                if (parseFloat($('#<%=lblServiceChargeAmt.ClientID%>').val()) >= 0) {
                    CalculateTxn($("#<%=txtCollAmt.ClientID%>").val(), 'cAmt', 'Y');
                }
                else {
                    alert('Service charge can not be negative!');
                    $('#<%=lblServiceChargeAmt.ClientID%>').val('0');
                    $('#<%=lblServiceChargeAmt.ClientID%>').focus();
                }
            }
        }

        function PostMessageToParentNew(id) {
            if (id == "undefined" || id == null || id == "") {
                alert('No customer selected!');
            }
            else {
                ClearSearchField();
                PopulateReceiverDDL(id);
                SearchCustomerDetails(id);
            }
        }

        function PickSenderData(obj) {
            var url = "";
            if (obj == "a") {
                url = "" + "TxnHistory/SenderAdvanceSearch.aspx";
            }
            if (obj == "s") {
                url = "" + "TxnHistory/SenderTxnHistory.aspx";
            }
            var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
            var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";

            if (isChrome) {
                PopUpWindow(url, param);

                return true;
            }

            var id = PopUpWindow(url, param);

            if (id == "undefined" || id == null || id == "") {
            }
            else {
                ClearSearchField();
                PopulateReceiverDDL(id);
                SearchCustomerDetails(id);
            }
        }

        function PickReceiverFromSender(obj) {
            var senderId = $('#finalSenderId').text();
            var sName = $('#senderName').text();
            if (senderId == "" || senderId == "undefined") {
                alert('Please select the Sender`s Details');
                return;
            }
            var url = "";
            if (obj === "a") {
                return AddNewReceiver(senderId);

            }
            if (obj == "r") {
                url = "" + "/AgentNew/SendTxn/TxnHistory/ReceiverHistoryBySender.aspx?sname=" + sName + "&senderId=" + senderId;
            }

            if (obj == "s") {
                url = "" + "/AgentNew/SendTxn/TxnHistory/SenderAdvanceSearch.aspx?senderId=" + senderId;
            }
            var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";
            var res = PopUpWindow(url, param);
            if (res == "undefined" || res == null || res == "") {
            }
            else {
                SearchReceiverDetails(res);
            }
        }

        function PostMessageToParentNewFromCalculator(collAmt) {
            if (collAmt == "undefined" || collAmt == null || collAmt == "") {
                alert('No Amount selected!');
            }
            else {
                SetValueById("<%=txtCollAmt.ClientID %>", collAmt, "");
                CalculateTxn();
            }
        }

        function PostMessageToParentNewForReceiver(id) {
            if (id == "undefined" || id == null || id == "") {
                alert('No customer selected!');
            }
            else {
                SearchReceiverDetails(id);
            }
        }

        function DDLReceiverOnChange() {
            ClearTxnData();
            var receiverId = $("#<%=ddlReceiver.ClientID%>").val();
            if (receiverId != '' && receiverId != undefined && receiverId != "0") {
                SearchReceiverDetails(receiverId);
            }
            else if (receiverId == "0") {
                ClearReceiverData();
                PickReceiverFromSender('a');
            }
            else if (receiverId == null || receiverId == "") {
                $('.readonlyOnReceiverSelect').removeAttr("disabled");
                ClearReceiverData();
            }
        }

        function SearchReceiverDetails(customerId) {
            if (customerId == "" || customerId == null) {
                ClearReceiverData();
                alert('Invalid receiver selected!');
            }
            var dataToSend = { MethodName: 'SearchReceiver', customerId: customerId };
            $.post('<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(), dataToSend, function (response) {
                ParseResponseForReceiverData(response);
            }).fail(function () {
            });
            return true;
        }

        function ParseResponseForReceiverData(response) {
            $('.readonlyOnReceiverSelect').attr("disabled", "disabled");
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            if (data[0].errorCode != "0") {
                alert(data[0].msg);
                return;
            }
            if (data.length > 0) {
                //****Transaction Detail****
                $("#receiverName").text(data[0].firstName + ' ' + data[0].middleName + ' ' + data[0].lastName1);
                $("#<%=txtRecFName.ClientID %>").val(data[0].firstName);
                $("#<%=txtRecMName.ClientID %>").val(data[0].middleName);
                $("#<%=txtRecLName.ClientID %>").val(data[0].lastName1);
                $("#<%=txtRecAdd1.ClientID %>").val(data[0].address);
                $("#<%=txtRecCity.ClientID %>").val(data[0].city);
                $("#<%=txtRecMobile.ClientID %>").val(data[0].mobile);
                $("#<%=txtRecTel.ClientID %>").val(data[0].homePhone);
                $("#<%=txtRecIdNo.ClientID %>").val(data[0].idNumber);
                $("#<%=txtRecEmail.ClientID %>").val(data[0].email);
                $("#<%=ddlRecGender.ClientID %>").val(data[0].gender);
                SetDDLValueSelected("<%=ddlRecIdType.ClientID %>", data[0].idType);
                SetDDLTextSelected("<%=ddlRecGender.ClientID %>", data[0].gender);
                SetDDLValueSelected("<%=ddlReceiver.ClientID %>", data[0].receiverId);

                if ($.isNumeric(data[0].purposeOfRemit)) {
                    SetDDLValueSelected("<%=purpose.ClientID %>", data[0].purposeOfRemit);
                } else {
                    SetDDLTextSelected("<%=purpose.ClientID %>", data[0].purposeOfRemit);
                }
                if ($.isNumeric(data[0].relationship)) {
                    SetDDLValueSelected("<%=relationship.ClientID %>", data[0].relationship);

                } else {
                    SetDDLTextSelected("<%=relationship.ClientID %>", data[0].relationship);

                }

                //****Transaction Detail****
                ClearTxnData();
                SetDDLTextSelected("<%=pCountry.ClientID%>", data[0].country.toUpperCase());

                PcountryOnChange('c', data[0].paymentMethod.toUpperCase(), data[0].bankId);
                if (data[0].paymentMethod.toUpperCase() == 'BANK DEPOSIT') {
                    var isBranchByName = 'N';
                    var branch = '';
                    PopulateBankDetails(data[0].bankId, 2, isBranchByName, data[0].branchId);
                }
                SetPayCurrency(data[0].COUNTRYID);
                PAgentChange();
                $('#<%=txtRecDepAcNo.ClientID%>').val(data[0].receiverAccountNo);
                ManageHiddenFields(data[0].paymentMethod.toUpperCase());

                $(".readonlyOnCustomerSelect").attr("disabled", "disabled");
                $("#txtpBranch_aValue").val('');
                $("#txtpBranch_aText").val('');
                ManageLocationData();
            }
        }

        function CallBackAutocomplete(id) {
            if (id == '#ContentPlaceHolder1_txtSearchData') {
                var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
                SetItem("<% =txtSearchData.ClientID%>", d);
                ClearReceiverData();
                PopulateReceiverDDL(GetItem("<%=txtSearchData.ClientID %>")[0]);
                SearchCustomerDetails(GetItem("<%=txtSearchData.ClientID %>")[0]);
            }
            //added by gunn
            else if (id == '#ContentPlaceHolder1_introducerTxt') {
                GetReferralAvailabelLimit();
                if (GetValue("<%=txtCollAmt.ClientID %>") != "") {
                    var res = CheckReferralBalAndCamt();
                    if (res == false) {
                        if ($("#<%=txtCollAmt.ClientID%>").is(':disabled')) {
                            $("#<%=txtPayAmt.ClientID%>").val('');
                            $("#<%=txtPayAmt.ClientID%>").focus();
                        } else if ($("#<%=txtPayAmt.ClientID%>").is(':disabled')) {
                            $("#<%=txtCollAmt.ClientID%>").val('');
                            $("#<%=txtCollAmt.ClientID%>").focus();
                        }
                    }
                }
            }
        }

        //added by gunn
        function CheckReferralBalAndCamt() {
            var availableLimit = $('#<%=hdnRefAvailableLimit.ClientID%>').val();
            var collAmt = GetValue("<%=txtCollAmt.ClientID %>");
            if (parseFloat(collAmt) > parseFloat(availableLimit)) {
                alert("Introducer available balance exceeded");
                return false;
            }
        }

        //added by gunn
        function GetReferralAvailabelLimit() {
            var dataToSend = { MethodName: 'getReferralBalance', referralCode: $('#ContentPlaceHolder1_introducerTxt_aValue').val() };
            $.ajax({
                type: "POST",
                url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                data: dataToSend,
                async: false,
                success: function (response) {
                    $('#availableBalSpanReferral').show();
                    $("#ContentPlaceHolder1_referralBalId").html(response);
                    var bal = parseFloat($('#availableBalReferral').text().replace(/,/g, ''));
                    $('#<%=hdnRefAvailableLimit.ClientID%>').val(bal);
                },
                fail: function () {
                    alert("Error from GetReferralBalance");
                }

            });
        }

        function PopulateReceiverDDL(customerId) {
            if (customerId == "" || customerId == null) {
                alert('Invalid customer selected!');
            }
            var dataToSend = { MethodName: 'PopulateReceiverDDL', customerId: customerId };
            $.post('<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(), dataToSend, function (response) {
                PopulateReceiverDataDDL(response);
            }).fail(function () {
                alert("Error from pupulatereceiverDDL");
            });
            return true;
        }

        function PopulateReceiverDataDDL(response) {
            var data = jQuery.parseJSON(response);
            var ddl = GetElement("<%=ddlReceiver.ClientID%>");
            $(ddl).empty();

            var option = document.createElement("option");
            option.text = 'Select Receiver';
            option.value = '';

            ddl.options.add(option);

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");
                option.text = data[i].fullName.toUpperCase();
                option.value = data[i].receiverId;
                try {
                    ddl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
            option = document.createElement("option");
            option.text = 'New Receiver';
            option.value = '0';
            ddl.options.add(option);

        }

        function GetCustomerSearchType() {
            return $('#<%=ddlCustomerType.ClientID%>').val();
        }

        function ClearSearchField() {
            var d = ["", ""];
            SetItem("<% =txtSearchData.ClientID%>", d);
            <% = txtSearchData.InitFunction() %>;
        }

        function CheckForMobileNumber(nField, fieldName) {
            var numberPattern = /^[+]?[0-9]{6,16}$/;
            var maxLength = nField.maxLength;
            test = numberPattern.test(nField.value);
            if (!test) {
                alert(fieldName + ' Is Not Valid ! Maximum ' + maxLength + ' Numeric Characters only valid ');
                nField.value = '';
                nField.focus();
                return false
            }
            return true;
        }

        function CheckForPhoneNumber(nField, fieldName) {
            var numberPattern = /^[+]?[0-9]{6,15}$/;
            var maxLength = nField.maxLength;
            test = numberPattern.test(nField.value);
            if (!test) {
                alert(fieldName + ' Is Not Valid ! Maximum ' + maxLength + ' Numeric Characters only valid ');
                nField.value = '';
                nField.focus();
                return false
            }
            return true;
        }

        function LoadCalendars() {
            ShowCalDefault("#<% =txtSendIdValidDate.ClientID%>");
            CalIDIssueDate("#<% =txtSendIdExpireDate.ClientID%>");
            CalSenderDOB("#<% =txtSendDOB.ClientID%>");
           <%-- CalReceiverDOB("#<% =txtRecDOB.ClientID%>");
            CalFromToday("#<% =txtRecValidDate.ClientID%>");--%>
        }
        LoadCalendars();
    </script>
    <script type="text/javascript" language="javascript">
        $.validator.messages.required = "Required!";
        $(document).ready(function () {
            $("#form2").validate();
        });
        $(document).ajaxStart(function () {
            $("#DivLoad").show();
        });
        $(document).ajaxComplete(function (event, request, settings) {
            $("#DivLoad").hide();
        });
        function CheckSession(data) {
            if (data == undefined || data == "" || data == null)
                return;
            if (data[0].session_end == "1") {
                document.location = "../../../Logout.aspx";
            }
        }

        function GetpAgentId() {
            var pagent = $("#<%=pAgent.ClientID %> option:selected").val();
            return pagent;
        }

        function ResetAmountFields() {
            //Reset Fields
            $("#<%=txtPayAmt.ClientID%>").val('');
            $('#<%=txtPayAmt.ClientID%>').attr("readonly", false);
            $("#<%=lblSendAmt.ClientID%>").val('0.00');
            $("#<%=lblServiceChargeAmt.ClientID%>").val('0');
            $("#<%=lblExRate.ClientID%>").text('0.00');
            $("#lblDiscAmt").text('0.00');
            $("#<%=lblPayCurr.ClientID%>").text('');
            GetElement("spnSchemeOffer").innerHTML = "";
            GetElement("spnWarningMsg").innerHTML = "";
        }

        function checkdata(amt, obj) {
            if (amt > 0)
                CalculateTxn(amt, obj);
            else
                ClearCalculatedAmount();
        }

        function CalcOnEnter(e) {
            var evtobj = window.event ? event : e;

            var charCode = e.which || e.keyCode;
            if (charCode == 13) {
                $("#btnCalculate").focus();
            }
        }

        function ManageSendIdValidity() {
            var senIdType = $("#<%=ddSenIdType.ClientID%>").val();
            if (senIdType == "") {
                $("#<%=tdSenExpDateLbl.ClientID%>").show();
                $("#<%=tdSenExpDateTxt.ClientID%>").show();
                $("#<%=txtSendIdValidDate.ClientID%>").attr("class", "required readonlyOnCustomerSelect form-control");
            }
            else {
                var senIdTypeArr = senIdType.split('|');
                if (senIdTypeArr[1] == "E") {
                    $("#<%=tdSenExpDateLbl.ClientID%>").show();
                    $("#<%=tdSenExpDateTxt.ClientID%>").show();
                    $("#<%=txtSendIdValidDate.ClientID%>").attr("class", "required readonlyOnCustomerSelect form-control");
                }
                else {
                    $("#<%=tdSenExpDateLbl.ClientID%>").hide();
                    $("#<%=tdSenExpDateTxt.ClientID%>").hide();
                    $("#<%=txtSendIdValidDate.ClientID%>").attr("class", "readonlyOnCustomerSelect form-control");
                }
            }
        }

        function CheckSenderIdOnKeyUp(me) {
            var sIdNo = me.value;
            if (sIdNo == "" || sIdNo == null || sIdNo == undefined) {
                return;
            }
            var dataToSend = { MethodName: "CheckSenderIdNumber", sIdNo: sIdNo };
            $.post('<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(), dataToSend,
                function (response) {
                    var data = jQuery.parseJSON(response);
                    if (data[0].errorCode != "0") {
                        GetElement("spnIdNumber").innerHTML = data[0].msg;
                        GetElement("spnIdNumber").style.display = "block";
                    }
                    else {
                        GetElement("spnIdNumber").innerHTML = "";
                        GetElement("spnIdNumber").style.display = "none";
                    }
                }).fail(function () {

                });
        }

        function CheckSenderIdNumber(me) {
            if (me.readOnly) {
                GetElement("spnIdNumber").innerHTML = "";
                GetElement("spnIdNumber").style.display = "none";
                return;
            }
            CheckForSpecialCharacter(me, 'Sender ID Number');
            var sIdNo = me.value;
            var dataToSend = { MethodName: "CheckSenderIdNumber", sIdNo: sIdNo };
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        var data = jQuery.parseJSON(response);
                        if (data[0].errorCode != "0") {
                            GetElement("spnIdNumber").innerHTML = data[0].msg;
                            GetElement("spnIdNumber").style.display = "block";
                        }
                        else {
                            GetElement("spnIdNumber").innerHTML = "";
                            GetElement("spnIdNumber").style.display = "none";
                        }
                    }
                };
            $.ajax(options);
        }

        function LoadCustomerRate() {
            var pCountry = $("#<%=pCountry.ClientID%> option:selected").val();
            var pMode = $('#<%=pMode.ClientID %> option:selected').val();
            var pModeTxt = $('#<%=pMode.ClientID %> option:selected').text();
            var pAgent = $("#<%=pAgent.ClientID%> option:selected").val();
            if (pAgent === "undefined")
                pAgent = null;
            if (pModeTxt == "CASH PAYMENT TO OTHER BANK")
                pAgent = $("#<%=paymentThrough.ClientID%> option:selected").val();
            var collCurr = $('#<%=lblPerTxnLimitCurr.ClientID%>').text();
            var dataToSend = {
                MethodName: 'LoadCustomerRate', pCountry: pCountry, pMode: pMode, pAgent: pAgent, collCurr: collCurr
            };

            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        var data = response;
                        var collectionAmount = Number($('#<%=txtCollAmt.ClientID%>').val());
                        $('#<%=customerRateFields.ClientID%>').hide();
                        if (data == null || data == undefined || data == "")
                            return;
                        if (data[0].ErrCode != "0") {
                            $("#<%=lblExRate.ClientID%>").text(data[0].Msg);
                            if (collectionAmount > 0) {
                                $('#<%=customerRateFields.ClientID%>').show();
                            }
                            return;
                        }
                        var exRate = data[0].exRate;
                        var pCurr = data[0].pCurr;
                        var limit = data[0].limit;
                        var limitCurr = data[0].limitCurr;
                        exRate = roundNumber(exRate, 10);
                        $("#<%=lblExRate.ClientID%>").text(exRate);
                        $("#<%=lblExCurr.ClientID%>").text(pCurr);
                        $("#<%=lblPerTxnLimit.ClientID%>").text(limit);
                        $("#<%=lblPerTxnLimitCurr.ClientID%>").text(limitCurr);
                        $('#<%=customerRateFields.ClientID%>').hide();
                        if (collectionAmount > 0) {
                            $('#<%=customerRateFields.ClientID%>').show();
                        }
                        return;
                    }
                };
            $.ajax(options);
            return true;
        }

        function CollAmtOnChange() {
            var collAmt = $("#<%=txtCollAmt.ClientID%>").val();
            if (collAmt == "")
                collAmt = "0";
            var collAmtFormatted = CurrencyFormatted(collAmt); //collAmt;
            collAmtFormatted = CommaFormatted(collAmtFormatted);
            var collCurr = $('#<%=lblPerTxnLimitCurr.ClientID%>').text();
            if (collAmt == "0") {
                ClearCalculatedAmount();
                return;
            }
            checkdata(collAmt, 'cAmt');
        }

        function ClearAllCustomerInfo() {
            ClearSearchSection();
            ClearAmountFields();
            ClearCollModeAndAvailableBal();
            $('.displayPayerInfo').hide();
        }

        function ClearCollModeAndAvailableBal() {
            $('#availableBal').text('0');
            $('#11063').removeAttr('checked');
            $('#11062').prop('checked', true);
        }

        $(document).ready(function () {
            $('txtpBranch_aText').attr("readonly", true);

            $("#<%=txtCollAmt.ClientID%>").blur(function () {
                CollAmtOnChange();
            });

            $("#<%=txtPayAmt.ClientID%>").blur(function () {
                checkdata($("#<%=txtPayAmt.ClientID%>").val(), 'pAmt');
            });

            //btnDepositDetail
            $('#btnDepositDetail').click(function () {
                var collAmt = PopUpWindow("CollectionDetail.aspx", "");
                if (collAmt == "undefined" || collAmt == null || collAmt == "") {
                    collAmt = $('#<%=txtCollAmt.ClientID%>').text();
                }
                else {
                    if ((collAmt) > 0) {
                        SetValueById("<%=txtCollAmt.ClientID %>", collAmt, "");
                        $('#<%=txtCollAmt.ClientID%>').attr("readonly", true);
                        $('#<%=txtPayAmt.ClientID%>').attr("readonly", true);
                    }
                    else {
                        SetValueById("<%=txtCollAmt.ClientID %>", "", "");
                        SetValueById("<%=txtPayAmt.ClientID %>", "", "");
                        $('#<%=txtCollAmt.ClientID%>').attr("readonly", false);
                        $('#<%=txtPayAmt.ClientID%>').attr("readonly", false);
                    }
                    CalculateTxn(collAmt);
                }
            });

            $("#<%=ddSenIdType.ClientID%>").change(function () {
                ManageSendIdValidity();
            });

            $("#<%=locationDDL.ClientID%>").change(function () {

                LoadSublocation();
            });

            $("#<%=pCountry.ClientID%>").change(function () {
                ResetAmountFields();
                ClearCalculatedAmount();
                $('#<%=branch.ClientID%>').empty();
                $("#branch").empty();
                $("#<%=pMode.ClientID %>").empty();
                $("#<%=pAgent.ClientID %>").empty();
                $('.same').hide();
                $('#<%=branch.ClientID%>').removeClass('required');
                $("#tdLblBranch").hide();
                $("#tdTxtBranch").hide();
                $("#tdItelCouponIdLbl").hide();
                $("#tdItelCouponIdTxt").hide();
                $('#txtpBranch_aText').attr("class", "disabled form-control");
                $("#txtpBranch_err").hide();
                $("#txtpBranch_aValue").val('');
                $("#txtpBranch_aText").val('');
                $("#<%=txtRecDepAcNo.ClientID%>").val('');
                $("#<%=lblExCurr.ClientID%>").text('');
                $("#<%=lblPayCurr.ClientID%>").text('');
                $('#<%=lblPerTxnLimit.ClientID%>').text('0.00');
                GetElement("spnPayoutLimitInfo").innerHTML = "";
                if ($("#<%=pCountry.ClientID%> option:selected ").val() != "") {
                    PcountryOnChange('c', "");
                    SetPayCurrency($("#<%=pCountry.ClientID%>").val());
                    ManageLocationData();
                }
                var pmode = $("#<%=pMode.ClientID%>").val();
                var partnerId = $("#<%=hddPayoutPartner.ClientID%>").val();
                if (partnerId === apiPartnerIds[0] || pmode === "2") {
                    $('#<%=branch.ClientID%>').addClass('required');
                    if ((partnerId === apiPartnerIds[0]) && pmode === "2") {
                        $('#agentBranchRequired').hide();
                        $('#<%=branch.ClientID%>').removeClass('required');
                    }
                    $('.same').show();

                }
                if ((partnerId === apiPartnerIds[0]) && pmode === "2") {
                    LoadPayerData();
                }
            });

            $("#<%=pMode.ClientID%>").change(function () {
                ManageHiddenFields();
                $('#<%=branch.ClientID%>').empty();
                $("#branch").empty();
                ClearCalculatedAmount();
                $('.displayPayerInfo').hide();
                $("#<%=txtRecDepAcNo.ClientID%>").val('');
                $("#tdLblBranch").hide();
                $("#tdTxtBranch").hide();
                $('#txtpBranch_aText').attr("class", "disabled form-control");
                $("#txtpBranch_err").hide();
                $("#txtpBranch_aValue").val('');
                $("#txtpBranch_aText").val('');
                ReceivingModeOnChange();
                GetPayoutPartner();
                var pmode = $("#<%=pMode.ClientID%>").val();
                var partnerId = $("#<%=hddPayoutPartner.ClientID%>").val();
                if (partnerId === apiPartnerIds[0] || pmode === "2") {
                    $('#<%=branch.ClientID%>').addClass('required');
                    if ((partnerId === apiPartnerIds[0]) && pmode === "2") {
                        $('#agentBranchRequired').hide();
                        $('#<%=branch.ClientID%>').removeClass('required');
                    }
                    $('.same').show();
                    if ((partnerId === apiPartnerIds[0]) && pmode === "2") {
                        LoadPayerData();
                    }
                }
            });

            $("#<%=paymentThrough.ClientID%>").change(function () {
                ResetAmountFields();
                LoadCustomerRate();
            });

            $("#<%=ddlScheme.ClientID %>").change(function () {
                ResetAmountFields();
                $("#tdItelCouponIdLbl").hide();
                $("#tdItelCouponIdTxt").hide();
                if ($("#<%=ddlScheme.ClientID%> option:selected").text().toUpperCase() == "ITEL COUPON SCHEME") {
                    $("#tdItelCouponIdLbl").show();
                    $("#tdItelCouponIdTxt").show();
                }
            });
        });

        function ClearCalculatedAmount() {
            $("#<%=txtCollAmt.ClientID%>").val('');
            $('#<%=lblSendAmt.ClientID%>').val(0);
            $('#<%=lblServiceChargeAmt.ClientID%>').val(0);
            $('#<%=lblExRate.ClientID%>').val(0);
            $('#<%=txtPayAmt.ClientID%>').val('');
            $('#<%=customerRateFields.ClientID%>').hide();
        }

        function LoadSublocation() {
            var pLocation = $('#<%=locationDDL.ClientID%>').val();
            var dataToSend = { MethodName: 'getSubLocation', PLocation: pLocation };
            var options = {
                url: '<%=ResolveUrl("SendV2.aspx") %>?',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success:
                    function (response) {
                        LoadSubLocationDDL(response);
                    },
                error: function (result) {
                    alert("Due to unexpected errors we were unable to load data");
                }
            };
            $.ajax(options);
        }

        function LoadSubLocationDDL(response) {
            $('#subLocation').show();
            var data = response;
            var ddl = GetElement("<%=subLocationDDL.ClientID %>");
            $(ddl).empty();

            var option;
            option = document.createElement("option");

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");

                option.text = data[i].LOCATIONNAME;
                option.value = data[i].LOCATIONID;

                try {
                    ddl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
        }

        $(function () {
            $('#btnCalcClean').click(function () {
                ClearTxnData();
            });
        });

        //function to clear transaction
        function ClearTxnData() {
            $("#<%=pAgent.ClientID%>").empty();
            $("#<%=pMode.ClientID%>").empty();
            $("#txtpBranch_aValue").val("");
            $("#txtpBranch_aText").val("");
            $("#<%=txtRecDepAcNo.ClientID%>").val("");

            $("#<%=txtCollAmt.ClientID%>").val("");
            $('#<%=txtCollAmt.ClientID%>').attr("readonly", false);
            $("#<%=txtPayAmt.ClientID%>").val("");
            $('#<%=txtPayAmt.ClientID%>').attr("readonly", false);
            $("#<%=lblSendAmt.ClientID%>").val('0.00');
            $("#<%=lblServiceChargeAmt.ClientID%>").val('0');
            $("#<%=lblExRate.ClientID%>").text('0.00');
            $("#lblDiscAmt").text('0.00');
            $("#<%=lblExRate.ClientID%>").text('0.00');

            $("#scDiscount").val('0.00');
            $("#exRateOffer").val('0.00');

            $("#<%=lblPayCurr.ClientID%>").text("");
            $("#<%=lblPerTxnLimit.ClientID%>").text('0.00');

            SetDDLValueSelected("<%=pCountry.ClientID%>", "");
            SetDDLValueSelected("<%=ddlSalary.ClientID%>", "");
            SetDDLTextSelected("<%=ddlScheme.ClientID%>", "");
            $('#<%=branch.ClientID%>').empty();
            $('#<%=subLocationDDL.ClientID%>').empty();
            $('#<%=pCurrDdl.ClientID%>').empty();
            $('#<%=locationDDL.ClientID%>').empty();
            $("#branch").empty();

            GetElement("spnWarningMsg").innerHTML = "";
            //added by gagan
            d = ["", ""];
            SetItem('<%=introducerTxt.ClientID%>', d);
            $('#availableBalReferral').text('');
            $('#availableBalReferral').val('');
            $('#<%=hdnRefAvailableLimit.ClientID%>').val('');
            $('#availableBalSpanReferral').hide();
        }

        function SearchCustomerDetails(customerId, type) {
            if (customerId == "" || customerId == null) {
                alert('Search value is missing');
                $('#<%=txtSearchData.ClientID%>').focus();
                return false;
            }
            var dataToSend = { MethodName: 'SearchCustomer', customerId: customerId };
            $.post('<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                dataToSend,
                function (response) {
                    ParseResponseData(response);
                    debugger
                    if (type == 'mapping') {
                        var data = jQuery.parseJSON(response);
                        var d = [customerId, data[0].senderName];
                        SetItem("<% =txtSearchData.ClientID%>", d);
                    }
                }).fail(function () {

                });
            return true;
        }

        ////calculation part
        $(function () {
            $('#btnCalculate').click(function () {
                CalculateTxn();
            });
        });

        function CalculateTxn(amt, obj, isManualSc) {
            var collAmt = parseFloat($('#<%=txtCollAmt.ClientID%>').val().replace(',', '').replace(',', '').replace(',', ''));
            var availableBal = parseFloat($('#availableBal').text().replace(',', '').replace(',', '').replace(',', ''));

            var customerId = $('#ContentPlaceHolder1_txtSearchData_aValue').val();
            if ($('#11063').is(':checked')) {
                if (collAmt > availableBal) {
                    alert('Collection amount can not be greated then Available Balance!');
                    ClearAmountFields();
                    return false;
                }
            }
            if (obj == '' || obj == null) {
                if (document.getElementById("<%=txtPayAmt.ClientID%>").disabled) {
                    obj = 'cAmt';
                    amt = GetValue("<%=txtCollAmt.ClientID %>");
                }
                else {
                    obj = 'pAmt';
                    amt = GetValue("<%=txtPayAmt.ClientID %>");
                }
            }

            if (isManualSc == '' || isManualSc == undefined) {
                isManualSc = 'N';
            }
            $("#DivLoad").show();
            var pCountry = GetValue("<%=pCountry.ClientID %>");
            var pCountrytxt = $("#<%=pCountry.ClientID %> option:selected").text();
            var pMode = GetValue("<%=pMode.ClientID %>");
            var pModetxt = $("#<%=pMode.ClientID %> option:selected").text();


            if (pCountry == "" || pCountry == null || pCountry == undefined) {
                alert("Please choose payout country");
                GetElement("<%=pCountry.ClientID %>").focus();
                return false;
            }

            if (pMode == "" || pMode == null || pMode == undefined) {
                alert("Please choose payment mode");
                GetElement("<%=pMode.ClientID %>").focus();
                return false;
            }
            var sAgent = $("#<%=sendingAgentOnBehalfDDL.ClientID %> option:selected").val();
            if (sAgent == "" || sAgent == null || sAgent == undefined) {
                alert("Please choose Sending AgentBbranch");
                GetElement("<%=sendingAgentOnBehalfDDL.ClientID %>").focus();
                return false;
            }
            //added by gagan
            if ($('#ContentPlaceHolder1_introducerTxt_aSearch').val() != "") {
                var res = CheckReferralBalAndCamt();
                if (res == false) {
                    $("#<%=txtCollAmt.ClientID%>").val('');
                    $("#<%=txtCollAmt.ClientID%>").focus();
                    return;
                }
            }

            var pAgent = Number(GetValue("<%=pAgent.ClientID %>"));
            var pAgentBranch = GetValue("txtpBranch_aValue");
            if (pModetxt == "CASH PAYMENT TO OTHER BANK") {
                pAgent = $("#<%=paymentThrough.ClientID %> option:selected").val();
                pAgentBranch = "";
                if (pAgent == "" || pAgent == undefined)
                    pAgent = "";
            }

            var collAmt = GetValue("<%=txtCollAmt.ClientID %>");
            var txtCustomerLimit = GetValue("txtCustomerLimit");
            var txnPerDayCustomerLimit = GetValue("<%=txnPerDayCustomerLimit.ClientID %>");
            var schemeCode = GetValue("<%=ddlScheme.ClientID %>");

            if (obj == "cAmt") {
                collAmt = amt;
                payAmt = 0;
            }

            if (parseFloat(txtCustomerLimit) + parseFloat(collAmt) > txnPerDayCustomerLimit) {
                alert('Transaction cannot be proceed. Customer limit exceeded ' + parseFloat(txnPerDayCustomerLimit));
                ClearAmountFields();
                return false;
            }

            var payAmt = GetValue("<%=txtPayAmt.ClientID %>");

            if (obj == "pAmt") {
                payAmt = amt;
                collAmt = 0;
            }

            var payCurr = $('#<%=pCurrDdl.ClientID%>').val();
            var collCurr = $('#<%=lblPerTxnLimitCurr.ClientID%>').text();
            var senderId = $('#finalSenderId').text();
            var couponId = $("#<%=iTelCouponId.ClientID%>").val();
            var sc = $("#<%=lblServiceChargeAmt.ClientID%>").val();

            if (pCountry == "203" && payCurr == "USD") {
                if ((pMode == "1" && pAgent != "2091") || (pMode != "12" && pAgent != "2091")) {
                    alert('USD receiving is only allow for Door to Door');
                    ClearAmountFields();
                    return false;
                }
            }

            var dataToSend = {
                MethodName: 'CalculateTxn', pCountry: pCountry, pCountrytxt: pCountrytxt, pMode: pMode, pAgent: pAgent
                , pAgentBranch: pAgentBranch, collAmt: collAmt, payAmt: payAmt, payCurr: payCurr, collCurr: collCurr
                , pModetxt: pModetxt, senderId: senderId, schemeCode: schemeCode, couponId: couponId, isManualSc: isManualSc
                , sc: sc
            };

            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        ParseCalculateData(response, obj);
                    }
                };
            $.ajax(options);
            $("#DivLoad").hide();
            return true;
        }

        function ClearAmountFields() {
            $('#<%=lblSendAmt.ClientID%>').val('0.00');
            $('#<%=lblExRate.ClientID%>').text('0.00');
            $('#<%=lblPerTxnLimit.ClientID%>').text('0.00');
            $('#<%=lblServiceChargeAmt.ClientID%>').val('0');
            $('#lblDiscAmt').text('0.00');
            SetValueById("<%=txtCollAmt.ClientID %>", '', "");
            SetValueById("<%=txtPayAmt.ClientID %>", '', "");
            GetElement("spnSchemeOffer").innerHTML = "";
        }

        //Calculate Button Pressed and Json return;
        function ParseCalculateData(response, amtType) {
            var data = response;
            CheckSession1(data);
            if (data[0].ErrCode == "1") {
                alert(data[0].Msg);
                ClearAmountFields();
                return;
            }
            if (data[0].ErrCode == "101") {
                SetValueById("spnWarningMsg", "", data[0].Msg);
            }
            $('#<%=lblSendAmt.ClientID%>').val(parseFloat(Number(data[0].sAmt).toFixed(3))); //
            $('#<%=lblExRate.ClientID%>').text(roundNumber(data[0].exRate, 8));
            $('#<%=lblPayCurr.ClientID%>').text(data[0].pCurr);
            $('#<%=lblExCurr.ClientID%>').text(data[0].pCurr);

            if ($('#<%=allowEditSC.ClientID%>').val() == 'Y') {
                $("#<%=editServiceCharge.ClientID%>").attr("disabled", false);
            }

            $('#<%=lblPerTxnLimit.ClientID%>').text(data[0].limit);
            $('#<%=lblPerTxnLimitCurr.ClientID%>').text(data[0].limitCurr);

            if (!$("#<%=editServiceCharge.ClientID%>").is(':checked')) {
                $('#<%=lblServiceChargeAmt.ClientID%>').attr('disabled', 'disabled');
            }

            $('#<%=lblServiceChargeAmt.ClientID%>').val(parseFloat(data[0].scCharge).toFixed(0));

            if (data[0].tpExRate != '' || data[0].tpExRate != undefined) {
                $('#<%=hddTPExRate.ClientID%>').val(data[0].tpExRate)
            }

            SetValueById("<%=txtCollAmt.ClientID %>", parseFloat(Number(data[0].collAmt).toFixed(3)), ""); //
            //added by gunn
            if ($('#ContentPlaceHolder1_introducerTxt_aSearch').val() != "") {
                var res = CheckReferralBalAndCamt();
                if (res == false) {
                    $("#<%=txtPayAmt.ClientID%>").val('');
                    $("#<%=txtPayAmt.ClientID%>").focus();
                    return;
                }
            }
            SetValueById("<%=lblSendAmt.ClientID %>", parseFloat(Number(data[0].sAmt).toFixed(3)), ""); //
            SetValueById("<%=txtPayAmt.ClientID %>", parseFloat(Number(data[0].pAmt).toFixed(2)), "");



            var exRateOffer = data[0].exRateOffer;
            var scOffer = data[0].scOffer;
            var scDiscount = data[0].scDiscount;
            SetValueById("scDiscount", data[0].scDiscount, "");
            SetValueById("exRateOffer", data[0].exRateOffer, "");
            var html = "<span style='color: red;'>" + exRateOffer + "</span> (Exchange Rate)<br />";
            html += "<span style='color: red;'>" + scDiscount + "</span> (Service Charge)";
            SetValueById("spnSchemeOffer", "", html);
            $('#<%=customerRateFields.ClientID%>').hide();
            var collectionAmount = Number($('#<%=txtCollAmt.ClientID%>').val());
            if (collectionAmount > 0) {
                $('#<%=customerRateFields.ClientID%>').show();
            }
        }

        var eddval = "<%=Swift.web.Library.GetStatic.ReadWebConfig("cddEddBal","300000") %>";

        function CheckThriK(sAmt) {
            GetElement("<%=sourceOfFund.ClientID %>").className = "";
            GetElement("<%=purpose.ClientID %>").className = "";
            $('#<%=sourceOfFund_err.ClientID%>').html("");
            $('#<%=purpose_err.ClientID%>').html("");

            if (sAmt >= parseInt(eddval)) {
                GetElement("<%=sourceOfFund.ClientID %>").className = "required";
                GetElement("<%=purpose.ClientID %>").className = "required";
                $('#<%=sourceOfFund_err.ClientID%>').html("*");
                $('#<%=purpose_err.ClientID%>').html("*");
            }
        }

        function CheckSession1(data) {
            if (data == undefined || data == "" || data == null)
                return;
            if (data.session_end == "1") {
                document.location = "../../../Logout.aspx";
            }
        };

        //load payement mode
        function LoadPayMode(response, myDDL, recall, selectField, obj) {
            var data = response;
            CheckSession(data);
            $(myDDL).empty();

            var option;
            if (selectField != "" && selectField != undefined) {
                option = document.createElement("option");
                option.text = selectField;
                option.value = "";
                myDDL.options.add(option);
            }

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");
                option.text = data[i].typeTitle;
                option.value = data[i].serviceTypeId;

                try {
                    myDDL.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
            if (recall == 'pcurr') {
                SetDDLTextSelected("<%=pMode.ClientID%>", obj);
            }
        }

        function ParseLoadDDl(response, myDDL, recall, selectField) {
            var data = response;
            CheckSession(data);
            var ddl2 = GetElement("<%=pAgentDetail.ClientID %>");
            var ddl3 = GetElement("<%=pAgentMaxPayoutLimit.ClientID%>");
            $(ddl2).empty();
            $(ddl3).empty();
            $(myDDL).empty();

            GetElement("spnPayoutLimitInfo").innerHTML = "";
            if ($("#<%=pMode.ClientID%> option:selected").val() != "" && recall == "agentSelection") {
                $('#hdnreqAgent').text(data[0].agentSelection);
            }

            var option;
            if (selectField != "" && selectField != undefined) {
                option = document.createElement("option");
                option.text = selectField;
                option.value = "";
                myDDL.options.add(option);
            }

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");

                option.text = data[i].AGENTNAME.toUpperCase();
                option.value = data[i].bankId;

                var option2 = document.createElement("option");
                option2.value = data[i].bankId;
                option2.text = data[i].FLAG;

                var option3 = document.createElement("option");
                option3.value = data[i].bankId;
                option3.text = data[i].maxPayoutLimit;

                try {
                    myDDL.options.add(option);
                    ddl2.options.add(option2);
                    ddl3.options.add(option3);
                }
                catch (e) {
                    alert(e);
                }
            }

            if (data[0].AGENTNAME == "[SELECT BANK]") {
                $('#pAgent_err').show();
                GetElement("pAgent_err").innerHTML = "*";
                GetElement("<%=pAgent.ClientID%>").className = "required form-control";
            }
            else {
                $('#pAgent_err').hide();
                GetElement("pAgent_err").innerHTML = "";
                GetElement("<%=pAgent.ClientID %>").className = "form-control";
            }

            var pCountry = $("#<%=pCountry.ClientID%> option:selected").text();
            var pCurr = $("#<%=lblPayCurr.ClientID%>").text();
            GetElement("spnPayoutLimitInfo").innerHTML = "Payout Limit for " + pCountry + " : " + data[0].maxPayoutLimit;
        }

        function SetDDLTextSelected(ddl, selectText) {
            $("#" + ddl + " option").each(function () {
                if ($(this).text() == selectText) {
                    $(this).prop('selected', true);
                    return;
                }
            });
        }

        function SetDDLValueSelected(ddl, selectText) {
            $("#" + ddl + " option").each(function () {
                if ($(this).val() == selectText) {
                    $(this).prop('selected', true);
                    return;
                }
            });
        };

        function ClickEnroll() {
            if ($('#<%=EnrollCust.ClientID%>').is(':checked')) {
                if ($('#<%=NewCust.ClientID%>').is(':checked') == false && $('#senderName').text() == "" || $('#senderName').text() == null) {
                    ClearSearchSection();
                    ClearData();
                }
                $('#lblMem').show();
                $('#valMem').show();
                $('#memberCode_err').html("*");
                return;
            }
            $('#<%=NewCust.ClientID%>').attr("checked", false);
            $('#lblMem').hide();
            $('#valMem').hide();
            $('#memberCode_err').html("");
        }

        function ExistingData() {
            if ($('#<%=ExistCust.ClientID%>').is(':checked')) {
                GetElement("<%=NewCust.ClientID %>").checked = false;
                ClearData();
            }
            else {
                GetElement("<%=NewCust.ClientID %>").checked = true;
                ClearData();
            }
        }

        //clear data  btnClear
        function ClearData() {
            var a = false;
            var b = false;

            if ($('#<%=NewCust.ClientID%>').is(':checked')) {
                $(".readonlyOnCustomerSelect").removeAttr("disabled");
                $('.readonlyOnReceiverSelect').removeAttr("disabled");
                $(".showOnCustomerSelect").addClass("hidden");
                a = false;
                b = true;
                ClearSearchSection();
                HideElement('tblSearch');
                $('#divHideShow').hide();
                GetElement("<%=ExistCust.ClientID %>").checked = false;
            }
            else {
                $(".readonlyOnCustomerSelect").attr("disabled", "disabled");
                $(".showOnCustomerSelect").removeClass("hidden");
                ShowElement('tblSearch');
                $('#divHideShow').show();
                GetElement("<%=ExistCust.ClientID %>").checked = true;
            }
            $('#<%=txtSendFirstName.ClientID%>').attr("readonly", a);
            $('#<%=txtSendMidName.ClientID%>').attr("readonly", a);
            $('#<%=txtSendLastName.ClientID%>').attr("readonly", a);
            $('#<%=txtSendSecondLastName.ClientID%>').attr("readonly", a);
            $('#<%=txtSendIdNo.ClientID%>').attr("readonly", a);
            $('#<%=txtSendNativeCountry.ClientID%>').attr("readonly", a);
            $('#availableBal').text('0');
        }

        function SchemeByPCountry() {
            var pCountry = GetValue("<%=pCountry.ClientID %>");
            var pAgent = GetValue("<%=pAgent.ClientID %>");
            var sCustomerId = $('#finalSenderId').text();
            if (pCountry == "" || pCountry == null)
                return;
            var dataToSend = { MethodName: 'LoadSchemeByRcountry', pCountry: pCountry, pAgent: pAgent, sCustomerId: sCustomerId };
            var option;
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?',
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        var myDDL = document.getElementById("<%=ddlScheme.ClientID %>");
                        $(myDDL).empty();

                        option = document.createElement("option");
                        option.text = "Select";
                        option.value = "";
                        myDDL.options.add(option);

                        var data = jQuery.parseJSON(response);
                        CheckSession(data);
                        if (response == "") {
                            $(".trScheme").hide();
                            $("#tdScheme").hide();
                            $("#tdSchemeVal").hide();
                            return false;
                        }
                        $(".trScheme").show();
                        $("#tdScheme").show();
                        $("#tdSchemeVal").show();
                        for (var i = 0; i < data.length; i++) {
                            option = document.createElement("option");
                            option.text = data[i].schemeName;
                            option.value = data[i].schemeCode;
                            try {
                                myDDL.options.add(option);
                            }
                            catch (e) {
                                alert(e);
                            }
                        }
                        return true;
                    }
                };
            $.ajax(options);
        }

        // pcountryn onchange
        function PcountryOnChange(obj, pmode) {
            PcountryOnChange(obj, pmode, "");
        };

        function PcountryOnChange(obj, pmode, pAgentSelected) {
            debugger
            var pCountry = GetValue("<%=pCountry.ClientID %>");
            if (pCountry == "" || pCountry == null)
                return;

            var method = "";
            if (obj == 'c') {
                method = "PaymentModePcountry";
            }
            if (obj == 'pcurr') {
                method = "PCurrPcountry";
            }

            var dataToSend = { MethodName: method, pCountry: pCountry };
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?',
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    async: false,
                    success: function (response) {
                        if (obj == 'c') {
                            var data = response;
                            LoadPayMode(response, document.getElementById("<%=pMode.ClientID %>"), 'pcurr', "", pmode);
                            ReceivingModeOnChange("", pAgentSelected);
                            GetPayoutPartner(data[0].serviceTypeId);
                        }
                        else if (obj == 'pcurr') {
                            var data = response;
                            if (response == "")
                                return false;
                            $('#<%=lblPayCurr.ClientID%>').text(data[0].currencyCode);
                            $('#<%=lblExCurr.ClientID%>').text(data[0].currencyCode);

                            return true;
                        }
                        return true;
                    },
                    error: function (result) {
                        alert("Due to unexpected errors we were unable to load data");
                    }
                };
            $.ajax(options);
        }

        function ReceivingModeOnChange(pModeSelected, pAgentSelected) {
            ResetAmountFields();
            $("#<%=pAgent.ClientID %>").empty();
            PaymentModeChange(pModeSelected, pAgentSelected);
        }

        // WHILE CLICKING COLL MODE POPULATE AGENT/BANK
        function PaymentModeChange(pModeSelected, pAgentSelected) {
            var pMode = "";
            if (pModeSelected == "" || pModeSelected == null)
                pMode = $("#<%=pMode.ClientID %> option:selected").text();
            else {
                pMode = pModeSelected;
            }

            pCountry = GetValue("<%=pCountry.ClientID %>");
            $('#trAccno').hide();
            $("#<%=txtRecDepAcNo.ClientID%>").attr("class", "form-control");
            $('#trForCPOB').hide();
            GetElement("<%=paymentThrough.ClientID %>").className = "";
            if (pMode == "BANK DEPOSIT") {
                $('#trAccno').show();
                $("#<%=txtRecDepAcNo.ClientID%>").attr("class", "required form-control");
                $('#trAccno').show();
            }
            var dataToSend = { MethodName: "loadAgentBank", pMode: pMode, pCountry: pCountry };
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        LoadAgentSetting();
                        ParseLoadDDl(response, GetElement("<%=pAgent.ClientID %>"), 'agentSelection', "");
                        if (pAgentSelected != "" && pAgentSelected != null && pAgentSelected != undefined) {
                            SetDDLValueSelected("<%=pAgent.ClientID %>", pAgentSelected);
                        }
                        LoadCustomerRate();
                    }
                };
            $.ajax(options);
        }

        function LoadAgentSetting() {
            var pCountry = $("#<%=pCountry.ClientID%> option:selected").val();
            var pMode = $("#<%=pMode.ClientID%> option:selected").val();
            var pModeTxt = $("#<%=pMode.ClientID%> option:selected").text();
            var dataToSend = { MethodName: "PAgentChange", pCountry: pCountry, pMode: pMode };
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        ApplyAgentSetting(response, pModeTxt);
                    }
                };
            $.ajax(options);
        }

        function LoadPaymentThroughDdl(response, myDdl, label) {
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            $(myDdl).empty();

            var option;
            if (label != "") {
                option = document.createElement("option");
                option.text = label;
                option.value = "";
                myDdl.options.add(option);
            }

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");

                option.text = data[i].agentName;
                option.value = data[i].agentId;
                try {
                    myDdl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
        }

        function PBranchChange(pBranch) {
            ResetAmountFields();
            var dataToSend = { MethodName: "PBranchChange", pBranch: pBranch };
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        LoadPaymentThroughDdl(response, GetElement("<%=paymentThrough.ClientID %>"), "SELECT");
                    }
                };
            $.ajax(options);
        }

        function LoadAgentByExtAgent(pAgent) {
            var dataToSend = { MethodName: "LoadAgentByExtAgent", pAgent: pAgent };
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        LoadPaymentThroughDdl(response, GetElement("<%=paymentThrough.ClientID %>"), "SELECT");
                    }
                };
            $.ajax(options);
        }

        // WHILE CLICKING Pagent POPULATE agent branch
        function PAgentChange() {
            $('#<%=branch.ClientID%>').empty();
            $("#branch").empty();
            var pAgent = GetValue("<%=pAgent.ClientID %>");
            if (pAgent == null || pAgent == "" || pAgent == undefined)
                return;
            SetDDLValueSelected("<%=pAgentDetail.ClientID %>", pAgent);
            var pBankType = $("#<%=pAgentDetail.ClientID%> option:selected").text();
            var pCountry = $("#<%=pCountry.ClientID%> option:selected").val();
            var pMode = $("#<%=pMode.ClientID%> option:selected").val();
            var pModeTxt = $("#<%=pMode.ClientID%> option:selected").text();
            var dataToSend = { MethodName: "PAgentChange", pCountry: pCountry, pAgent: pAgent, pMode: pMode, pBankType: pBankType };
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        ApplyAgentSetting(response, pModeTxt);
                        if (pModeTxt == "CASH PAYMENT TO OTHER BANK")
                            LoadAgentByExtAgent(pAgent);
                        LoadCustomerRate();
                    }
                };
            $.ajax(options);
        }

        function ApplyAgentSetting(response, pModeTxt) {
            var data = response;
            CheckSession(data);
            $("#btnPickBranch").show();
            $("#divBranchMsg").hide();
            if (data == "" || data == null) {
                var defbeneficiaryIdReq = $("#<%=hdnBeneficiaryIdReq.ClientID%>").val();
                var defbeneficiaryContactReq = $("<%=hdnBeneficiaryContactReq.ClientID%>").val();
                var defrelationshipReq = $("<%=hdnRelationshipReq.ClientID%>").val();
                $("#<%=txtRecIdNo.ClientID%>").attr("disabled", "disabled");

                if (defbeneficiaryIdReq == "H") {
                    $(".trRecId").hide();
                    $("#<%=ddlRecIdType.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                    $("#<%=txtRecIdNo.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                    $("#<%=txtRecIdNo_err.ClientID%>").hide();
                }
                else if (defbeneficiaryIdReq == "M") {
                    $(".trRecId").show();
                    $("#<%=ddlRecIdType.ClientID%>").attr("class", "required form-control readonlyOnReceiverSelect");
                    $("#<%=txtRecIdNo.ClientID%>").attr("class", "required form-control readonlyOnReceiverSelect");
                    $("#<%=ddlRecIdType_err.ClientID%>").show();
                    $("#<%=txtRecIdNo_err.ClientID%>").show();
                }
                else if (defbeneficiaryIdReq == "O") {
                    $(".trRecId").show();
                    $("#<%=ddlRecIdType.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                    $("#<%=txtRecIdNo.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                    $("#<%=ddlRecIdType_err.ClientID%>").hide();
                    $("#<%=txtRecIdNo_err.ClientID%>").hide();
                }

                if (defrelationshipReq == "H") {
                    $("#<%=trRelWithRec.ClientID%>").hide();
                    $("#<%=relationship.ClientID%>").attr("class", "form-control");
                }
                else if (defrelationshipReq == "M") {
                    $("#<%=trRelWithRec.ClientID%>").show();
                    $("#<%=relationship.ClientID%>").attr("class", "required form-control");
                    $("#<%=relationship_err.ClientID%>").show();
                }
                else if (defrelationshipReq == "O") {
                    $("#<%=trRelWithRec.ClientID%>").show();
                    $("#<%=relationship.ClientID%>").attr("class", "form-control");
                    $("#<%=relationship_err.ClientID%>").hide();
                }

                if (defbeneficiaryContactReq == "H") {
                    $("#<%=trRecContactNo.ClientID%>").hide();
                    $("#<%=txtRecMobile.ClientID%>").attr("class", "form-control");
                }
                else if (defbeneficiaryContactReq == "M") {
                    $("#<%=trRecContactNo.ClientID%>").show();
                    $("#<%=txtRecMobile.ClientID%>").attr("class", "required form-control");
                    $("#<%=txtRecMobile_err.ClientID%>").show();
                }
                else if (defbeneficiaryContactReq == "O") {
                    $("#<%=trRecContactNo.ClientID%>").show();
                    $("#<%=txtRecMobile.ClientID%>").attr("class", "form-control");
                    $("#<%=txtRecMobile_err.ClientID%>").hide();
                }

                $("#tdLblBranch").show();
                $("#tdTxtBranch").show();

                if (pModeTxt == "BANK DEPOSIT") {
                    $('#txtpBranch_aText').attr("readonly", true);
                    $('#txtpBranch_aText').attr("class", "required disabled form-control");
                    $("#txtpBranch_err").show();
                }
                else {
                    $('#txtpBranch_aText').attr("readonly", true);
                    $('#txtpBranch_aText').attr("class", "disabled form-control");
                    $("#txtpBranch_err").hide();
                }
                return;
            }
            var branchSelection = data[0].branchSelection;
            var maxLimitAmt = data[0].maxLimitAmt;
            var agMaxLimitAmt = data[0].agMaxLimitAmt;
            var beneficiaryIdReq = data[0].benificiaryIdReq;
            var relationshipReq = data[0].relationshipReq;
            var beneficiaryContactReq = data[0].benificiaryContactReq;
            var acLengthFrom = data[0].acLengthFrom;
            var acLengthTo = data[0].acLengthTo;
            var acNumberType = data[0].acNumberType;
            $("#<%=txtRecIdNo.ClientID%>").attr("disabled", "disabled");

            if (branchSelection == "Not Required") {
                $("#tdLblBranch").hide();
                $("#tdTxtBranch").hide();
                $('#txtpBranch_aText').attr("class", "disabled form-control");
                $("#txtpBranch_err").hide();
            }
            else if (branchSelection == "Manual Type") {
                $("#tdLblBranch").show();
                $("#tdTxtBranch").show();
                $('#txtpBranch_aText').attr("readonly", false);
                $('#txtpBranch_aText').attr("class", "required form-control");

                $("#txtpBranch_err").show();
                $("#divBranchMsg").show();
                $("#btnPickBranch").hide();
            }
            else if (branchSelection == "SELECT") {
                $("#tdLblBranch").show();
                $("#tdTxtBranch").show();
                $('#txtpBranch_aText').attr("readonly", true);
                $('#txtpBranch_aText').attr("class", "required disabled form-control");
                $("#txtpBranch_err").show();
            }
            else {
                $("#tdLblBranch").show();
                $("#tdTxtBranch").show();
                $('#txtpBranch_aText').attr("readonly", true);
                $('#txtpBranch_aText').attr("class", "disabled form-control");
                $("#txtpBranch_err").hide();
            }
            if (beneficiaryIdReq == "H") {
                $("#<%=trRecId.ClientID%>").hide();
                $("#<%=ddlRecIdType.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                $("#<%=txtRecIdNo.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                $("#<%=txtRecIdNo_err.ClientID%>").hide();
            }
            else if (beneficiaryIdReq == "M") {
                $("#<%=trRecId.ClientID%>").show();
                $("#<%=ddlRecIdType.ClientID%>").attr("class", "required form-control readonlyOnReceiverSelect");
                $("#<%=txtRecIdNo.ClientID%>").attr("class", "required form-control readonlyOnReceiverSelect");
                $("#<%=ddlRecIdType_err.ClientID%>").show();
                $("#<%=txtRecIdNo_err.ClientID%>").show();
            }
            else if (beneficiaryIdReq == "O") {
                $("#<%=trRecId.ClientID%>").show();
                $("#<%=ddlRecIdType.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                $("#<%=txtRecIdNo.ClientID%>").attr("class", "form-control readonlyOnReceiverSelect");
                $("#<%=ddlRecIdType_err.ClientID%>").hide();
                $("#<%=txtRecIdNo_err.ClientID%>").hide();
            }

            if (relationshipReq == "H") {
                $("#<%=trRelWithRec.ClientID%>").hide();
                $("#<%=relationship.ClientID%>").attr("class", "form-control");
            }
            else if (relationshipReq == "M") {
                $("#<%=trRelWithRec.ClientID%>").show();
                $("#<%=relationship.ClientID%>").attr("class", "required form-control");
                $("#<%=relationship_err.ClientID%>").show();
            }
            else if (relationshipReq == "O") {
                $("#<%=trRelWithRec.ClientID%>").show();
                $("#<%=relationship.ClientID%>").attr("class", "form-control");
                $("#<%=relationship_err.ClientID%>").hide();
            }

            if (beneficiaryContactReq == "H") {
                $("#<%=trRecContactNo.ClientID%>").hide();
                $("#<%=txtRecMobile.ClientID%>").attr("class", "form-control");
            }
            else if (beneficiaryContactReq == "M") {
                $("#<%=trRecContactNo.ClientID%>").show();
                $("#<%=txtRecMobile.ClientID%>").attr("class", "required form-control");
                $("#<%=txtRecMobile_err.ClientID%>").show();
            }
            else if (beneficiaryContactReq == "O") {
                $("#<%=trRecContactNo.ClientID%>").show();
                $("#<%=txtRecMobile.ClientID%>").attr("class", "form-control");
                $("#<%=txtRecMobile_err.ClientID%>").hide();
            }
        }

        //PICK AGENT FROM SENDER HISTORY  --SenderDetailById
        function PickDataFromSender(obj) {
            var dataToSend = { MethodName: "SearchCustomer", searchValue: obj, searchType: "customerId" };
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
        }

        //PICK receiveer FROM SENDER HISTORY
        function SetReceiverFromSender(obj) {
            var senderId = $('#finalSenderId').text();
            var dataToSend = { MethodName: "ReceiverDetailBySender", id: obj, senderId: senderId };
            var options =
                {
                    url: '<%=ResolveUrl("SendV2.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        ParseReceiverData(response);
                    }
                };
            $.ajax(options);
        }

        ////populate receiver data
        function ParseReceiverData(response) {
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            if (data.length > 0) {
                alert(data[0].receiverName);
                $('#receiverName').text(data[0].receiverName);
                $('#finalBenId').text(data[0].receiverId);
                SetDDLTextSelected("<%=pCountry.ClientID%>", data[0].country.toUpperCase());
                PcountryOnChange('c', data[0].paymentMethod, data[0].pBank);
                $("#txtpBranch_aValue").val('');
                $("#txtpBranch_aText").val('');
                if (data[0].pBankBranch != "" && data[0].pBankBranch != undefined) {
                    $("#tdLblBranch").show();
                    $("#tdTxtBranch").show();
                    $('#txtpBranch_aText').attr("readonly", true);
                    $('#txtpBranch_aText').attr("class", "required disabled form-control");
                    $("#txtpBranch_err").show();
                    $("#txtpBranch_aValue").val(data[0].pBankBranch);
                    $("#txtpBranch_aText").val(data[0].pBankBranchName);
                }
                SetValueById("<%=txtRecFName.ClientID %>", data[0].firstName, "");
                SetValueById("<%=txtRecMName.ClientID %>", data[0].middleName, "");
                SetValueById("<%=txtRecLName.ClientID %>", data[0].lastName1, "");
                SetValueById("<%=txtRecSLName.ClientID %>", data[0].lastName2, "");

                SetDDLTextSelected("<%=ddlRecIdType.ClientID%>", data[0].idType);
                SetValueById("<%=txtRecIdNo.ClientID %>", data[0].idNumber, "");
                <%--SetValueById("<%=txtRecValidDate.ClientID %>", data[0].validDate, "");
                SetValueById("<%=txtRecDOB.ClientID %>", data[0].dob, "");--%>
                SetValueById("<%=txtRecTel.ClientID %>", data[0].homePhone, "");
                SetValueById("<%=txtRecMobile.ClientID %>", data[0].mobile, "");

                SetValueById("<%=txtRecAdd1.ClientID %>", data[0].address, "");
                SetValueById("<%=txtRecAdd2.ClientID %>", data[0].state, "");
                SetValueById("<%=txtRecCity.ClientID %>", data[0].state, "");
                SetValueById("<%=txtRecPostal.ClientID %>", data[0].zipCode, "");

                SetValueById("<%=txtRecEmail.ClientID %>", data[0].email, "");
                SetValueById("<%=txtRecDepAcNo.ClientID %>", data[0].accountNo, "");
            }
        }

        function ParseResponseData(response) {
            var data = jQuery.parseJSON(response);
            CheckSession(data);
            if (data[0].errorCode != "0") {
                alert(data[0].msg);
                return;
            }
            $(".readonlyOnCustomerSelect").removeAttr("disabled");
            $(".readonlyOnReceiverSelect").removeAttr("disabled");
            if (data.length > 0) {
                //****Transaction Detail****
                ClearTxnData();
                SetDDLTextSelected("<%=ddlSalary.ClientID%>", data[0].monthlyIncome);
                $(".readonlyOnCustomerSelect").attr("disabled", "disabled");
                //****Sender Detail****
                $('#senderName').text(data[0].senderName);
                $('#finalSenderId').text(data[0].customerId);

                //New data added
                $('#<%=txtSendPostal.ClientID%>').val(data[0].szipCode);
                $('#<%=sCustStreet.ClientID%>').val(data[0].street);
                $('#<%=txtSendCity.ClientID%>').val(data[0].sCity);
                $('#<%=companyName.ClientID%>').val(data[0].companyName);
                $('#<%=custLocationDDL.ClientID %>').val(data[0].sState);
                $('#<%=ddlEmpBusinessType.ClientID %>').val(data[0].organizationType);

                SetValueById("<%=ddlSendCustomerType.ClientID %>", data[0].customerType, "");
                SetValueById("<%=txtSendIdExpireDate.ClientID %>", data[0].idIssueDate, "");

                SetValueById("<%=txtSendFirstName.ClientID %>", data[0].sfirstName, "");
                SetValueById("<%=txtSendMidName.ClientID %>", data[0].smiddleName, "");
                SetValueById("<%=txtSendLastName.ClientID %>", data[0].slastName1, "");
                SetValueById("<%=txtSendSecondLastName.ClientID %>", data[0].slastName2, "");

                SetValueById("<%=txtSendIdNo.ClientID %>", data[0].sidNumber, "");
                if (data[0].sidNumber == "") {
                    $('#<%=txtSendIdNo.ClientID%>').attr("readonly", false);
                    SetDDLValueSelected("<%=ddSenIdType.ClientID %>", "");
                }
                else {
                    $('#<%=txtSendIdNo.ClientID%>').attr("readonly", true);
                }

                SetValueById("<%=txtSendIdValidDate.ClientID %>", data[0].svalidDate, "");
                SetValueById("<%=ddlIdIssuedCountry.ClientID %>", data[0].PLACEOFISSUE, "");

                SetValueById("<%=txtSendDOB.ClientID %>", data[0].sdob, "");
                SetValueById("<%=txtSendTel.ClientID %>", data[0].shomePhone, "");
                if (data[0].shomePhone == "")
                    $('#<%=txtSendTel.ClientID%>').attr("readonly", false);
                SetValueById("<%=txtSendMobile.ClientID %>", data[0].smobile, "");
                if (data[0].smobile == "")
                    $('#<%=txtSendMobile.ClientID%>').attr("readonly", false);
                SetValueById("<%=txtSendAdd1.ClientID %>", data[0].saddress, "");
                if (data[0].saddress == "")
                    $('#<%=txtSendAdd1.ClientID%>').attr("readonly", false);
                SetValueById("<%=txtSendAdd2.ClientID %>", data[0].saddress2, "");
                if (data[0].saddress2 == "")
                    $('#<%=txtSendAdd2.ClientID%>').attr("readonly", false);

                SetValueById("<%=txtSendPostal.ClientID %>", data[0].szipCode, "");
                if (data[0].szipCode == "")
                    $('#<%=txtSendPostal.ClientID%>').attr("readonly", false);
                SetDDLValueSelected("<%=txtSendNativeCountry.ClientID%>", data[0].scountry);
                SetValueById("<%=txtSendEmail.ClientID %>", data[0].semail, "");
                if (data[0].semail == "")
                    $('#<%=txtSendEmail.ClientID%>').attr("readonly", false);
                SetValueById("<%=companyName.ClientID %>", data[0].companyName, "");
                SetValueById("<%=sourceOfFund.ClientID %>", data[0].sourceOfFund, "");

                SetDDLValueSelected("<%=ddlSenGender.ClientID%>", data[0].sgender);
                SetDDLTextSelected("<%=ddSenIdType.ClientID%>", data[0].idName);
                ManageSendIdValidity();

                GetElement("divSenderIdImage").innerHTML = data[0].SenderIDimage;
                //****End of Sender Detail****

                //****Customer Due Diligence Information****
                SetDDLValueSelected("<%=occupation.ClientID%>", data[0].sOccupation);
                SetDDLTextSelected("<%=relationship.ClientID%>", data[0].relWithSender);
                //****End of CDDI****

                //if (data[0].rId != null && data[0].rId != "") {
                //    $(".readonlyOnReceiverSelect").attr("disabled", "disabled");
                //}
                ChangeCustomerType();
            }
            ManageLocationData();
        }

        function ClearSearchSection() {
            $('#senderName').text("");
            $('#finalSenderId').text("");
            ClearSearchField();
            $("#<%=ddlReceiver.ClientID%>").empty();
            SetDDLTextSelected("<%=ddlCustomerType.ClientID %>", "Passport No.");
            SetDDLValueSelected("<%=pCountry.ClientID %>", "");
            $("#<%=pMode.ClientID%>").empty();
            $("#<%=pAgent.ClientID%>").empty();
            $("#tdLblBranch").hide();
            $("#tdTxtBranch").hide();
            $("#trAccno").hide();
            $("#spnPayoutLimitInfo").hide();
            $("#divSenderIdImage").hide();
            SetValueById("<%=txtSendFirstName.ClientID %>", "", "");
            SetValueById("<%=txtSendMidName.ClientID %>", "", "");
            SetValueById("<%=txtSendLastName.ClientID %>", "", "");
            SetValueById("<%=txtSendSecondLastName.ClientID %>", "", "");

            SetDDLTextSelected("<%=ddSenIdType.ClientID%>", "SELECT");
            SetDDLTextSelected("<%=ddlSenGender.ClientID%>", "SELECT");
            SetValueById("<%=txtSendIdNo.ClientID %>", "", "");
            SetValueById("<%=memberCode.ClientID %>", "", "");
            SetValueById("<%=txtSendIdValidDate.ClientID %>", "", "");
            SetValueById("<%=txtSendDOB.ClientID %>", "", "");
            SetValueById("<%=txtSendTel.ClientID %>", "", "");
            SetValueById("<%=txtSendMobile.ClientID %>", "", "");
            SetValueById("<%=companyName.ClientID %>", "", "");

            SetValueById("<%=txtSendAdd1.ClientID %>", "", "");
            SetValueById("<%=txtSendAdd2.ClientID %>", "", "");
            SetValueById("<%=txtSendCity.ClientID %>", "", "");
            SetValueById("<%=txtSendPostal.ClientID %>", "", "");
            SetValueById("<%=txtSendNativeCountry.ClientID %>", "", "");
            SetValueById("<%=txtSendEmail.ClientID %>", "", "");
            SetValueById("<%=sCustStreet.ClientID %>", "", "");
            SetValueById("<%=txtSendCity.ClientID %>", "", "");
            SetValueById("<%=txtSendIdExpireDate.ClientID %>", "", "");
            SetValueById("<%=txtSendPostal.ClientID %>", "", "");
            SetValueById("<%=txtSendPostal.ClientID %>", "", "");
            SetValueById("<%=txtSendPostal.ClientID %>", "", "");

            SetDDLValueSelected("<%=occupation.ClientID %>", "");
            SetDDLValueSelected("<%=relationship.ClientID %>", "");
            $("#<%=ddlSalary.ClientID %>").val("Select");
            SetDDLValueSelected("<%=ddlSendCustomerType.ClientID %>", "");
            SetDDLValueSelected("<%=custLocationDDL.ClientID %>", "");
            SetDDLValueSelected("<%=ddlSenGender.ClientID %>", "");
            SetDDLValueSelected("<%=branch.ClientID %>", "");
            SetDDLValueSelected("<%=pCurrDdl.ClientID %>", "");
            $('#<%=locationDDL.ClientID%>').empty();
            $('#<%=subLocationDDL.ClientID%>').empty();
            $("#<%=branch.ClientID%>").empty();
            $("#<%=pCurrDdl.ClientID%>").empty();
            $('#<%=lblPerTxnLimit.ClientID%>').text('0.00');
            $("#branch").empty();
            SetValueById("<%=sourceOfFund.ClientID %>", "", "");
            ClearReceiverData();
        }

        function ClearReceiverData() {
            $('#receiverName').text('');
            $('#finalBenId').text('');
            SetDDLValueSelected("<%=ddlEmpBusinessType.ClientID %>", "11007");
            SetDDLValueSelected("<%=ddlRecIdType.ClientID %>", "");
            SetDDLValueSelected("<%=ddlReceiver.ClientID %>", "");

            SetValueById("<%=txtRecFName.ClientID %>", "", "");
            SetValueById("<%=txtRecMName.ClientID %>", "", "");
            SetValueById("<%=txtRecLName.ClientID %>", "", "");
            SetValueById("<%=txtRecSLName.ClientID %>", "", "");
            SetDDLTextSelected("<%=ddlRecIdType.ClientID%>", "SELECT");
            SetDDLTextSelected("<%=ddlRecGender.ClientID%>", "SELECT");
            SetValueById("<%=txtRecIdNo.ClientID %>", "", "");
            SetValueById("<%=txtRecTel.ClientID %>", "", "");
            SetValueById("<%=txtRecMobile.ClientID %>", "", "");
            SetValueById("<%=txtRecAdd1.ClientID %>", "", "");
            SetValueById("<%=txtRecAdd2.ClientID %>", "", "");
            SetValueById("<%=txtRecCity.ClientID %>", "", "");
            SetValueById("<%=txtRecPostal.ClientID %>", "", "");
            SetValueById("<%=txtRecEmail.ClientID %>", "", "");
            SetValueById("<%=purpose.ClientID %>", "", "");
            SetValueById("<%=relationship.ClientID %>", "", "");
            SetDDLValueSelected("<%=relationship.ClientID %>", "");
            $('#<%=txtRecIdNo.ClientID%>').removeClass('required');
            $('#<%=txtRecIdNo_err.ClientID%>').hide();
        }

        //clear receiver dtaa
        $(function () {
            $('#btnReceiverClr').click(function () {
                $('.readonlyOnReceiverSelect').removeAttr("disabled");
                ClearReceiverData();
            });
        });

        function ValidateDate(date) {
            if (date == "") {
                return true;
            }
            if (Date.parse(date)) {
                return true;
            } else {
                return false;
            }
        }
        ////send transacion calc
        $(function () {
            $('#calc').click(function () {
                $(".readonlyOnCustomerSelect").each(function () {
                    if ($(this).is(":disabled")) {
                        $(this).addClass('abc').removeAttr("disabled");
                    }
                });
                $(".readonlyOnReceiverSelect").each(function () {
                    if ($(this).is(":disabled")) {
                        $(this).addClass('abc').removeAttr('disabled');
                    }
                });
                if ($("#form1").validate().form() == false) {
                    $(".required").each(function () {
                        if (!$.trim($(this).val())) {
                            $(this).focus();
                        }
                    });
                    $(".abc").each(function () {
                        $(this).removeClass('abc').attr('disabled', 'disabled');
                    });
                    return false;
                }
                $(".abc").each(function () {
                    $(this).removeClass('abc').attr('disabled', 'disabled');
                });

                var pBankBranchText = $("#<%=branch.ClientID%> option:selected").text();
                if (pBankBranchText.length <= 0) {
                    pBankBranchText = $("#branch option:selected").text();
                }

                var pBankBranch = $("#<%=branch.ClientID%> option:selected").val();
                if (pBankBranch === undefined || pBankBranch.length <= 0) {
                    pBankBranch = $("#branch option:selected").val();
                }
                if (pBankBranch === undefined) {
                    pBankBranch = "";
                }
                var pBank = $("#<%=pAgent.ClientID %> option:selected").val();
                if (pBank == "SELECT" || pBank == "undefined")
                    pBank = "";
                var hdnreqAgent = $('#hdnreqAgent').html();
                var hdnreqBranch = $('#hdnreqBranch').html();
                var dm = $("#<%=pMode.ClientID %> option:selected").text();
                if ($('#<%=pMode.ClientID%>').val() == '2') {
                    if (pBankBranchText == null || pBankBranchText == "" || pBankBranchText == "undefined" || pBankBranchText == "-1") {
                        alert("Branch is required ");
                        return false;
                    }
                    if (hdnreqBranch == "Manual Type") {
                        if (pBankBranchText == null || pBankBranchText == "" || pBankBranchText == "undefined" || pBankBranchText == "-1") {
                            alert("Branch is required ");
                            return false;
                        }
                    }
                }
                if (hdnreqAgent == "M") {
                    if (pBank == null || pBank == "" || pBank == "undefined") {
                        alert("Agent/Bank is required ");
                        $("#<%=pAgent.ClientID %>").focus();
                        return false;
                    }
                }
                var por = $("#<%=purpose.ClientID %> option:selected").text();
                por = por.replace("SELECT", "");
                var sof = $("#<%=sourceOfFund.ClientID %> option:selected").text().replace("SELECT", "");
                sof = sof.replace("SELECT", "");
                var sendAmt = $('#<%=lblSendAmt.ClientID%>').val();

                if (sendAmt > parseInt(eddval)) {
                    if (por == "") {
                        alert("Purpose of Remittance is required for sending amount greater than " + eddval);
                        $("#<%=purpose.ClientID %>").focus();
                        return false;
                    }
                    if (sof == "") {
                        alert("Source of fund is required for sending amount greater than " + eddval);
                        $("#<%=sourceOfFund.ClientID %>").focus();
                        return false;
                    }
                }
                var pCountry = $("#<%=pCountry.ClientID %> option:selected").text();
                if (pCountry == "SELECT" || pCountry == undefined)
                    pCountry = "";
                var pCountryId = $("#<%=pCountry.ClientID %> option:selected").val();
                var collMode = $("#<%=pMode.ClientID %> option:selected").text();
                var collModeId = $("#<%=pMode.ClientID %> option:selected").val();

                var pAgent = "";
                var pAgentName = "";
                if (collMode == "CASH PAYMENT TO OTHER BANK") {
                    pAgent = $("#<%=paymentThrough.ClientID %> option:selected").val();
                    pAgentName = $("#<%=paymentThrough.ClientID %> option:selected").text();
                    if (pAgentName == "SELECT" || pAgentName == undefined) {
                        pAgent = "";
                        pAgentName = "";
                    }
                }

                var pBankText = $("#<%=pAgent.ClientID %> option:selected").text();
                if (pBankText == "[SELECT]" || pBankText == "[Any Where]" || pBankText == undefined)
                    pBankText = "";

                SetDDLValueSelected("<%=pAgentDetail.ClientID %>", pBank);
                var pBankType = $("#<%=pAgentDetail.ClientID%> option:selected").text();
                var pCurr = $('#<%=lblPayCurr.ClientID%>').text();
                var collCurr = $('#<%=lblPerTxnLimitCurr.ClientID%>').text();
                var collAmt = GetValue("<%=txtCollAmt.ClientID %>");
                var customerTotalAmt = GetValue("txtCustomerLimit");
                var payAmt = GetValue("<% =txtPayAmt.ClientID %>");
                var scharge = $('#<%=lblServiceChargeAmt.ClientID%>').val();
                var discount = $('#lblDiscAmt').text();
                var handling = "0";
                var exRate = $('#<%=lblExRate.ClientID%>').text();
                var scDiscount = $('#scDiscount').val();
                var exRateOffer = $('#exRateOffer').val();
                var schemeName = $("#<%=ddlScheme.ClientID %> option:selected").text();
                if (schemeName == "SELECT" || schemeName == "undefined")
                    schemeName = "";

                var schemeType = $("#<%=ddlScheme.ClientID %> option:selected").val();
                if (schemeType == "SELECT" || schemeType == "undefined")
                    schemeType = "";

                var couponId = $("#<%=iTelCouponId.ClientID%>").val();
                //sender values
                var senderId = $('#finalSenderId').text();
                var sfName = GetValue("<% =txtSendFirstName.ClientID %>");
                var smName = GetValue("<% =txtSendMidName.ClientID %>");
                var slName = GetValue("<% =txtSendLastName.ClientID %>");
                var slName2 = GetValue("<% =txtSendSecondLastName.ClientID %>");
                var sIdType = $("#<% =ddSenIdType.ClientID %> option:selected").text();
                if (sIdType == "SELECT" || sIdType == undefined || sIdType == "")
                    sIdType = "";
                else
                    sIdType = sIdType.split('|')[0];
                var sGender = $("#<% =ddlSenGender.ClientID %> option:selected").val();
                var sIdNo = GetValue("<% =txtSendIdNo.ClientID %>");
                var sIdValid = GetValue("<% =txtSendIdValidDate.ClientID %>");
                if (ValidateDate(sIdValid) == false) {
                    alert('Sender Id expiry date is invalid');
                    $('#<%=txtSendIdValidDate.ClientID%>').focus();
                    return false;
                }
                var sdob = GetValue("<% =txtSendDOB.ClientID %>");
                var sTel = GetValue("<% =txtSendTel.ClientID %>");
                var sMobile = GetValue("<% =txtSendMobile.ClientID %>");
                var sCompany = GetValue("<%=companyName.ClientID %>");

                var sNaCountry = $("#<%=txtSendNativeCountry.ClientID %> option:selected").text();

                var sCity = $('#<%=txtSendCity.ClientID%>').val();
                var sPostCode = GetValue("<% =txtSendPostal.ClientID %>");
                var sAdd1 = GetValue("<% =txtSendAdd1.ClientID %>");
                var sAdd2 = GetValue("<% =txtSendAdd2.ClientID %>");
                var sEmail = GetValue("<% =txtSendEmail.ClientID %>");
                var memberCode = GetValue("<%=memberCode.ClientID %>");
                var smsSend = "N";
                if ($('#<%=ChkSMS.ClientID%>').is(":checked"))
                    smsSend = "Y";
                var newCustomer = "N";

                var rfName = GetValue("<% =txtRecFName.ClientID %>");
                var rmName = GetValue("<% =txtRecMName.ClientID %>");
                var rlName = GetValue("<% =txtRecLName.ClientID %>");
                var rlName2 = GetValue("<% =txtRecSLName.ClientID %>");

                var rIdType = $("#<% =ddlRecIdType.ClientID %> option:selected").text();

                if (rIdType == "SELECT" || rIdType == "undefined")
                    rIdType = "";

                var rGender = $("#<% =ddlRecGender.ClientID %> option:selected").val();
                var rIdNo = GetValue("<% =txtRecIdNo.ClientID %>");
                <%--var rIdValid = GetValue("<% =txtRecValidDate.ClientID %>");
                var rdob = GetValue("<% =txtRecDOB.ClientID %>");--%>
                var rTel = GetValue("<% =txtRecTel.ClientID %>");
                var rMobile = GetValue("<% =txtRecMobile.ClientID %>");

                var rCity = GetValue("<% =txtRecCity.ClientID %>");
                var rPostCode = GetValue("<% =txtRecPostal.ClientID %>");
                var rAdd1 = GetValue("<% =txtRecAdd1.ClientID %>");
                var rAdd2 = GetValue("<% =txtRecAdd2.ClientID %>");
                var rEmail = GetValue("<% =txtRecEmail.ClientID %>");
                var accountNo = GetValue("<% =txtRecDepAcNo.ClientID %>");

                var pLocation = GetValue("<% =locationDDL.ClientID %>");
                var pLocationText = $("#<%=locationDDL.ClientID %> option:selected").text();
                var pSubLocation = GetValue("<% =subLocationDDL.ClientID %>");
                var pSubLocationText = $("#<%=subLocationDDL.ClientID %> option:selected").text();

                var tpExRate = $('#<%=hddTPExRate.ClientID%>').val();

                var isManualSC = 'N';
                if ($('#<%=editServiceCharge.ClientID%>').is(":checked"))
                    isManualSC = "Y";

                var manualSC = $('#<%=lblServiceChargeAmt.ClientID%>').val();

                //********IF NEW CUSTOMER CHECK REQUIRED FIELD******

                if ($('#<%=NewCust.ClientID%>').is(":checked")) {
                    newCustomer = "Y";

                    if (sfName == "" || sfName == null) {
                        alert('Sender First Name missing');
                        $('#<%=txtSendFirstName.ClientID %>').focus();
                        return false;
                    }
                }
                if ($('#<%=NewCust.ClientID%>').is(":checked") == false) {
                    if (senderId == "" || senderId == null) {
                        alert('Please Choose Existing Sender ');
                        return false;
                    }
                }
                var enrollCustomer = "N";
                var collModeFrmCustomer = $("input[name='chkCollMode']:checked").val();
                if (collModeFrmCustomer == undefined || collModeFrmCustomer == '') {
                    alert('Please choose collect mode first3!');
                    return false;
                }

                //New params added
                var sCustStreet = $('#<%=sCustStreet.ClientID%>').val();
                var sCustLocation = $('#<%=custLocationDDL.ClientID%>').val();
                var sCustomerType = $('#<%=ddlSendCustomerType.ClientID%>').val();
                var sCustBusinessType = $('#<%=ddlEmpBusinessType.ClientID%>').val();
                var sCustIdIssuedCountry = $('#<%=ddlIdIssuedCountry.ClientID%>').val();
                var sCustIdIssuedDate = $('#<%=txtSendIdExpireDate.ClientID%>').val();

                var benId = $('#finalBenId').text();
                var receiverId = $('#<%=ddlReceiver.ClientID%>').val();
                if (benId == '' || benId == null || benId == undefined) {
                    benId = $('#<%=ddlReceiver.ClientID%>').val();
                }

                var payoutPartnerId = $('#<%=hddPayoutPartner.ClientID%>').val();
                var cashCollMode = collModeFrmCustomer;
                var customerDepositedBank = $('#<%=depositedBankDDL.ClientID%>').val();
                var introducerTxt = $('#ContentPlaceHolder1_introducerTxt_aValue').val();

                var rel = $("#<%=relationship.ClientID %> option:selected").text().replace("Select", "");
                rel = rel.replace("Select", "");
                var occupation = $("#<%=occupation.ClientID %> option:selected").val();
                var payMsg = escape(GetValue("<% = txtPayMsg.ClientID %>"));
                var company = GetValue("<% =companyName.ClientID %>");
                var cancelrequestId = '<%=GetResendId()%>';
                var salary = $("#<%=ddlSalary.ClientID %> option:selected").val();
                if (salary == "Select" || rIdType == "undefined")
                    salary = "";
                var payerId = "";
                var payerBranchId = "";
                if ((payoutPartnerId === apiPartnerIds[0]) && collModeId === "2") {
                    payerId = $("#<%=ddlPayer.ClientID%>").val();
                    payerBranchId = $("#<%=ddlPayerBranch.ClientID%>").val();
                    if (payerBranchId === null || payerBranchId === "") {
                        alert("Payer Branch Data Not Selected Please Choose Payer Branch Information ");
                        return;
                    }
                }
                var branchId = $("#<%=sendingAgentOnBehalfDDL.ClientID%>").val();
                var branchName = $("#<%=sendingAgentOnBehalfDDL.ClientID%> :selected").text();
                var url = "Confirm.aspx?senderId=" + senderId +
                    "&sfName=" + sfName +
                    "&smName=" + smName +
                    "&slName=" + slName +
                    "&slName2=" + slName2 +
                    "&sIdType=" + sIdType +
                    "&sIdNo=" + sIdNo +
                    "&sIdValid=" + sIdValid +
                    "&sGender=" + sGender +
                    "&sdob=" + sdob +
                    "&sTel=" + sTel +
                    "&sMobile=" + sMobile +
                    "&sNaCountry=" + FilterString(sNaCountry) +
                    "&sCity=" + FilterString(sCity) +
                    "&sPostCode=" + FilterString(sPostCode) +
                    "&sAdd1=" + FilterString(sAdd1) +
                    "&sAdd2=" + FilterString(sAdd2) +
                    "&sEmail=" + sEmail +
                    "&smsSend=" + FilterString(smsSend) +
                    "&memberCode=" + FilterString(memberCode) +
                    "&sCompany=" + FilterString(sCompany) +
                    "&benId=" + FilterString(benId) +
                    "&rfName=" + FilterString(rfName) +
                    "&rmName=" + FilterString(rmName) +
                    "&rlName=" + FilterString(rlName) +
                    "&rlName2=" + FilterString(rlName2) +
                    "&rIdType=" + FilterString(rIdType) +
                    "&rIdNo=" + FilterString(rIdNo) +
                    "&rGender=" + FilterString(rGender) +
                    "&rTel=" + FilterString(rTel) +
                    "&rMobile=" + FilterString(rMobile) +
                    "&rCity=" + FilterString(rCity) +
                    "&rPostCode=" + FilterString(rPostCode) +
                    "&rAdd1=" + FilterString(rAdd1) +
                    "&rAdd2=" + FilterString(rAdd2) +
                    "&rEmail=" + rEmail +
                    "&accountNo=" + FilterString(accountNo) +
                    "&pCountry=" + FilterString(pCountry) +
                    "&payCountryId=" + FilterString(pCountryId) +
                    "&collMode=" + FilterString(collMode) +
                    "&collModeId=" + FilterString(collModeId) +
                    "&pBank=" + FilterString(pBank) +
                    "&pBankText=" + FilterString(pBankText) +
                    "&pBankBranch=" + FilterString(pBankBranch) +
                    "&pBankBranchText=" + FilterString(pBankBranchText) +
                    "&pAgent=" + FilterString(pAgent) +
                    "&pAgentName=" + FilterString(pAgentName) +
                    "&pBankType=" + pBankType +
                    "&pCurr=" + FilterString(pCurr) +
                    "&collCurr=" + FilterString(collCurr) +
                    "&collAmt=" + FilterString(collAmt) +
                    "&payAmt=" + FilterString(payAmt) +
                    "&sendAmt=" + FilterString(sendAmt) +
                    "&scharge=" + FilterString(scharge) +
                    "&customerTotalAmt=" + FilterString(customerTotalAmt) +
                    "&discount=" + FilterString(discount) +
                    "&scDiscount=" + FilterString(scDiscount) +
                    "&exRateOffer=" + FilterString(exRateOffer) +
                    "&exRate=" + FilterString(exRate) +
                    "&por=" + FilterString(por) +
                    "&sof=" + FilterString(sof) +
                    "&rel=" + FilterString(rel) +
                    "&occupation=" + FilterString(occupation) +
                    "&payMsg=" + payMsg +
                    "&company=" + FilterString(company) +
                    "&newCustomer=" + FilterString(newCustomer) +
                    "&EnrollCustomer=" + FilterString(enrollCustomer) +
                    "&cancelrequestId=" + FilterString(cancelrequestId) +
                    "&hdnreqAgent=" + FilterString(hdnreqAgent) +
                    "&hdnreqBranch = " + FilterString(hdnreqBranch) +
                    "&salary=" + salary +
                    "&pLocation=" + pLocation +
                    "&pLocationText=" + pLocationText +
                    "&pSubLocation=" + pSubLocation +
                    "&tpExRate=" + tpExRate +
                    "&manualSC=" + manualSC +
                    "&isManualSC=" + isManualSC +
                    //new fields
                    "&sCustStreet=" + sCustStreet +
                    "&sCustLocation=" + sCustLocation +
                    "&sCustomerType=" + sCustomerType +
                    "&sCustBusinessType=" + sCustBusinessType +
                    "&sCustIdIssuedCountry=" + sCustIdIssuedCountry +
                    "&sCustIdIssuedDate=" + sCustIdIssuedDate +
                    "&receiverId=" + receiverId +
                    "&payoutPartnerId=" + payoutPartnerId +
                    "&cashCollMode=" + cashCollMode +
                    "&customerDepositedBank=" + customerDepositedBank +
                    "&introducerTxt=" + introducerTxt +
                    "&pSubLocationText=" + pSubLocationText +
                    "&payerId=" + payerId +
                    "&payerBranchId=" + payerBranchId +
                    "&branchId=" + branchId +
                    "&branchName=" + branchName;

                var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";

                var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
                var isSafari = navigator.userAgent.toLowerCase().indexOf('safari') > -1;

                var is_mobile = false;
                if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
                    is_mobile = true;
                }

                if (is_mobile) {
                    window.open(url, '_blank');
                    return true;
                }

                if (isChrome) {
                    PopUpWindow(url, param);

                    return true;
                }
                var id = PopUpWindow(url, param);

                if (isSafari) {
                    var confirmResponse = document.getElementById("confirmHidden").value;
                    var res = confirmResponse.split('-:::-');
                    if (res[0] == "1") {
                        var errMsgArr = res[1].split('\n');
                        for (var i = 0; i < errMsgArr.length; i++) {
                            alert(errMsgArr[i]);
                        }
                    }
                    else {
                        window.location.replace("/AgentNew/SendTxn/SendIntlReceipt.aspx?controlNo=" + res[2] + "&invoicePrint=" + res[3]);
                    }
                }

                else {

                    if (id == "undefined" || id == null || id == "") {
                    }
                    else {
                        var res = id.split('-:::-');
                        if (res[0] == "1") {
                            var errMsgArr = res[1].split('\n');
                            for (var i = 0; i < errMsgArr.length; i++) {
                                alert(errMsgArr[i]);
                            }
                        }
                        else {
                            window.location.replace("/AgentNew/SendTxn/SendIntlReceipt.aspx?controlNo=" + res[2] + "&invoicePrint=" + res[3]);
                        }
                    }
                }

                return true;
            });
        });

        $(document).unbind('keydown').bind('keydown', function (event) {
            var doPrevent = false;
            if (event.keyCode === 8) {
                var d = event.srcElement || event.target;
                if ((d.tagName.toUpperCase() === 'INPUT' && (d.type.toUpperCase() === 'TEXT' || d.type.toUpperCase() === 'PASSWORD'))
                    || d.tagName.toUpperCase() === 'TEXTAREA') {
                    doPrevent = d.readOnly || d.disabled;
                }
                else {
                    doPrevent = true;
                }
            }

            if (doPrevent) {
                event.preventDefault();
                if (confirm("You have pressed back button. Are you sure you want to leave this page?")) {
                    window.history.back();
                }
            }
        });

        function SetPayCurrency(pCountry) {
            var dataToSend = { MethodName: 'PCurrPcountry', pCountry: pCountry };
            var options = {
                url: '<%=ResolveUrl("SendV2.aspx") %>?',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                async: false,
                success:
                    function (response) {
                        var data = response;
                        var ddl = GetElement("<%=pCurrDdl.ClientID%>");
                        $(ddl).empty();

                        var option;

                        for (var i = 0; i < data.length; i++) {
                            option = document.createElement("option");

                            option.text = data[i].currencyCode;
                            option.value = data[i].currencyCode;

                            try {
                                ddl.options.add(option);
                                if (data[i].isDefault == "Y") {
                                    $('#<%=pCurrDdl.ClientID%>').val(data[i].currencyCode);
                                }
                            }
                            catch (e) {
                                alert(e);
                            }
                        }
                    },
                error: function (result) {
                    alert("Due to unexpected errors we were unable to load data");
                }
            };
            $.ajax(options);
        }

        $(document).ready(function () {
            $(".readonlyOnCustomerSelect").attr("disabled", "disabled");
            $('.collMode-chk').click(function () {
                if (!$(this).is(':checked')) {
                    return false;
                }
                if ($(this).val() == 'Bank Deposit') {
                    var customerId = $('#ContentPlaceHolder1_txtSearchData_aValue').val();
                    if (customerId == "" || customerId == null || customerId == undefined) {
                        alert('Please Choose Existing Sender for Coll Mode: Bank Deposit');
                        return false;
                    }
                    CheckAvailableBalance($(this).val());
                    ClearAmountFields();
                }
                else {
                    $('#availableBalSpan').hide();
                    ClearAmountFields();
                }
                $('.collMode-chk').not(this).prop('checked', false);
            });
        });

        function ChangeCustomerType() {
            //if customer type is individual
            customerTypeId = $("#<%=ddlSendCustomerType.ClientID%>").val();
            if (customerTypeId == "4700") {
                $(".hideOnIndividual").hide();
                $(".showOnIndividual").show();
                $("#<%=companyName.ClientID%>").removeClass("Required");
                $("#<%=ddlEmpBusinessType.ClientID%>").removeClass("required");
                $("#<%=occupation.ClientID%>").addClass("required");
            }
            else if (customerTypeId == "4701") {
                $(".hideOnIndividual").show();
                $(".showOnIndividual").hide();
                $("#<%=ddlEmpBusinessType.ClientID%>").addClass("required");
                $("#<%=occupation.ClientID%>").removeClass("required");
            }
        }

        function CheckAvailableBalance(collectionMode) {
            var customerId = $("#ContentPlaceHolder1_txtSearchData_aValue").val();
            var branchId = $("#<%=sendingAgentOnBehalfDDL.ClientID%>").val();
            var dataToSend = { MethodName: 'CheckAvialableBalance', collectionMode: collectionMode, customerId: customerId, branchId: branchId };
            $.post('<%=ResolveUrl("SendV2.aspx") %>?', dataToSend, function (response) {
                $('#availableBalSpan').show();
                $("#availableBalSpan").html(response);
            }).fail(function () {
                alert("Due to unexpected errors we were unable to load data");
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
</asp:Content>
