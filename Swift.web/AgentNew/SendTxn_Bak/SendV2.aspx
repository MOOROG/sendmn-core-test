<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" EnableEventValidation="false" AutoEventWireup="true" CodeBehind="SendV2.aspx.cs" Inherits="Swift.web.AgentNew.SendTxn.SendV2" %>

<%@ Register Src="/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        #divStep1 .panel-body {
            background: rgba(236, 28, 28, 0.2);
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
            $(".check").click(function () {
                $("input[name*='chkDepositMapping']").prop("checked", true);
                $('.check').hide();
                $('.uncheck').show();
            });
            $(".uncheck").click(function () {
                $("input[name*='chkDepositMapping']").prop("checked", false);
                $('.check').show();
                $('.uncheck').hide();
            });
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
                RemoveDisableProperty();
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
                $("#<%=hddCustomerId.ClientID%>").val(GetItem("<%=txtSearchData.ClientID %>")[0]);
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
        function ConfirmSave() {
            var tranIds = [];
            $.each($("input[name='chkDepositMapping']:checked"), function () {
                tranIds.push($(this).val());
            });
            if (tranIds == '') {
                alert('No data to save');
                return false;
            }
            dataToSend = { MethodName: 'MapData', tranIds: tranIds, customerId: $('#<%=hddCustomerId.ClientID%>').val() };
            if (confirm('Do you want to continue with save?')) {
                $.post("", dataToSend, function (response) {
                    var data = jQuery.parseJSON(response);
                    if (data.ErrorCode == '0') {
                        alert(data.Msg);
                        $("#myModal2").modal('hide');
                        CheckAvailableBalance($("input[name='chkCollMode']:checked").val());
                        ClearAmountFields();
                    } else {
                        alert(data.Msg);
                    }
                });
            }
            return false;
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
            $("#availableBalSpan").hide();
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
            if (isManualSc == undefined) {
                if ($("#<%=editServiceCharge.ClientID%>").is(':checked')) {
                    isManualSc = 'Y';
                }
                else {
                    isManualSc = 'N';
                }
            }
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
            debugger
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
         function RemoveDisableProperty() {
            $("#<%=txtSendMobile.ClientID%>").prop("disabled", false);
            $("#<%=ddlSalary.ClientID%>").removeAttr("disabled");
            $("#<%=txtSendEmail.ClientID%>").attr("disabled", false);
            $("#<%=ddlIdIssuedCountry.ClientID%>").removeAttr("disabled");
            $("#<%=occupation.ClientID%>").removeAttr("disabled");
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
                RemoveDisableProperty();
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
                    alert('Please choose collect mode first!');
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
                var branchId = $("#<%=sendingAgentOnBehalfDDL.ClientID%>").val().split('|')[0];
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
                    "&sMobile=" + encodeURIComponent(sMobile) +
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
            $("#filterBtn").click(function () {
                GetDataInList();
            });
            $('#clearBtn').click(function () {
                $('#<%=tranDate.ClientID%>').val('');
                $('#<%=particulars.ClientID%>').val('');
                $('.check').hide();
                $('.uncheck').show();
                GetDataInList();
            });
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
                    $("#<%=tranDate.ClientID%>").val('');
                    $("#<%=particulars.ClientID%>").val('');
                    GetDataInList();
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
        function GetDataInList() {
            $("#<%=customerDepositMapping.ClientID%>").html('');
                var tranDate = $('#<%=tranDate.ClientID%>').val();
                var particulars = $('#<%=particulars.ClientID%>').val();
                var dataToSend = { MethodName: 'getListData', particulars: particulars, tranDate: tranDate }
                $.ajax({
                    type: "POST",
                    data: dataToSend,
                    async: true,
                    success: function (response) {
                        $("#myModal2").modal('show');
                        $("#<%=customerDepositMapping.ClientID%>").html(response);
                    ShowCalDefault("#<% =tranDate.ClientID%>");
                },
                fail: function () {
                    alert("Error from Deposit Mapping");
                }

            });
        }

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
            var branchId = $("#<%=sendingAgentOnBehalfDDL.ClientID%>").val().split('|')[0];
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
    <div class="page-wrapper">
        <input type="hidden" id="confirmHidden" />
        <input type="hidden" id="confirmHiddenChrome" />
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <ol class="breadcrumb">
                        <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li class="active"><a href="#">Transaction</a></li>
                        <li class="active"><a href="#">Send Transaction Int'l</a></li>
                        <span style="float: right;">
                            <div class="row" style="float: right;">
                                <div class="amountDiv">
                                    Available Limit :&nbsp;
                                <asp:Label ID="availableAmt" runat="server" Text="0.00"></asp:Label>
                                    <asp:Label ID="balCurrency" runat="server" Text="JPY"></asp:Label>
                                </div>
                            </div>
                        </span>
                    </ol>
                </div>
            </div>
        </div>
        <div id="divLoad" style="position: absolute; left: 450px; top: 250px; background-color: black; border: 1px solid black; display: none;">
            Processing...
        </div>
        <div id="divStep1" class="mainContainer">
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Sending Branch</h4>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-2 form-group">
                                    <label>Sending Branch/Agent:</label>
                                </div>
                                <div class="col-md-6 form-group">
                                    <asp:DropDownList ID="sendingAgentOnBehalfDDL" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <div class="row" style="display: none;">
                                <div class="col-xs-4 col-sm-2">
                                    <asp:CheckBox ID="NewCust" runat="server" Checked="true" Text="New Customer" onclick="ClearData();" />
                                </div>
                                <div class="col-sm-2 col-xs-4">
                                    <asp:CheckBox ID="ExistCust" runat="server" Text="Existing Customer" onclick="ExistingData();" />
                                </div>
                                <div class="col-sm-2" style="display: none;">
                                    <asp:CheckBox ID="EnrollCust" runat="server" Text="Issue Membership Card" onclick="ClickEnroll();" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-xs-12">
                                    <h4 class="panel-title">Choose Customer </h4>
                                </div>
                            </div>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body" id="divHideShow">
                            <div class="row">
                                <div class="col-sm-2">
                                    <asp:DropDownList ID="ddlCustomerType" runat="server" CssClass="form-control" Style="margin-bottom: 5px;">
                                        <asp:ListItem Value="accountNo" Text="Account No."></asp:ListItem>
                                        <asp:ListItem Value="email" Text="Email ID" Selected="True"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-sm-6" style="margin-bottom: 5px;">
                                    <uc1:SwiftTextBox ID="txtSearchData" runat="server" Category="remit-searchCustomerForSendPage" CssClass="form-control" Param1="@GetCustomerSearchType()" Title="Blank for All" />
                                </div>
                                <div class="col-sm-2 col-xs-6" style="display: none">
                                    <input name="button3" type="button" id="btnAdvSearch" onclick="PickSenderData('a');" class="btn btn-primary" value="Advance Search" style="margin-bottom: 2px;" />
                                </div>
                                <div class="col-sm-2 col-xs-6">
                                    <input name="button4" type="button" id="btnClear" value="Clear" class="btn btn-clear" onclick="ClearAllCustomerInfo();" style="margin-bottom: 2px; margin-left: 30px;" />
                                </div>
                                <div class="col-sm-2" style="display: none;">
                                    <span>Country: </span>
                                    <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-xs-12">
                                    <div class="table-responsive">
                                        <table class="table">
                                            <tr>
                                                <td style="width: 17%;">
                                                    <label>Collection Mode:</label>
                                                    <span class="ErrMsg">*</span></td>
                                                <td id="collModeTd" runat="server"></td>

                                            </tr>
                                        </table>
                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>
                    <input type="hidden" id="hdnPayMode" runat="server" />
                    <input type="hidden" id="hdntranCount" runat="server" />
                    <asp:HiddenField ID="hdnLimitAmount" runat="server" />
                    <asp:HiddenField ID="hdnRefAvailableLimit" runat="server" />
                    <asp:HiddenField ID="hdnBeneficiaryIdReq" runat="server" />
                    <asp:HiddenField ID="hdnBeneficiaryContactReq" runat="server" />
                    <asp:HiddenField ID="hdnRelationshipReq" runat="server" />
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <table class="table table-responsive">
                                <tr>
                                    <td>
                                        <h4 class="panel-title">Sender Information: <span id="senderName"></span></h4>
                                    </td>
                                    <td style="float: right; margin-right: 15px;"></td>
                                </tr>
                            </table>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="table-responsive">
                                        <table class="table">
                                            <tr style="display: none;">
                                                <td>&nbsp;</td>
                                                <td>FIRST NAME</td>
                                                <td>MIDDLE NAME</td>
                                                <td>LAST NAME</td>
                                            </tr>
                                            <tr>
                                                <td style="width: 27%;">Sender Name:
                                                        <span class="ErrMsg" id='txtSendFirstName_err'>*</span>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtSendFirstName" placeholder="First Name" runat="server" CssClass="required SmallTextBox form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this,'Sender First Name');"></asp:TextBox>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtSendMidName" runat="server" placeholder="Middle Name" CssClass="SmallTextBox form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Middle Name');"></asp:TextBox>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtSendLastName" runat="server" placeholder="Last Name" CssClass="SmallTextBox form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Last Name');"></asp:TextBox>
                                                    <span class="ErrMsg" id='txtSendLastName_err'></span>
                                                </td>
                                                <td style="display: none;">
                                                    <asp:TextBox ID="txtSendSecondLastName" runat="server" CssClass="SmallTextBox form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Second Last Name');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Zip Code</td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtSendPostal" runat="server" placeholder="Postal Code" CssClass="form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Postal Code');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Street
                                                        <span runat="server" class="ErrMsg" id='sCustStreet_err'>*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="sCustStreet" runat="server" placeholder="Street" CssClass="required SmallTextBox form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Street Name');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td id="tdSenCityLbl" runat="server">
                                                    <asp:Label runat="server" ID="lblsCity" Text="City:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='txtSendCity_err'>*</span>
                                                </td>
                                                <td id="tdSenCityTxt" runat="server" colspan="3">
                                                    <asp:TextBox ID="txtSendCity" runat="server" placeholder="City" CssClass="required form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender City');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>State:<span class="ErrMsg">*</span></td>
                                                <td colspan="2">
                                                    <div class="form-group">
                                                        <div class="input-group">
                                                            <asp:DropDownList ID="custLocationDDL" runat="server" CssClass="required form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                                            <div class="input-group-addon"><span id="lblSendCountryName"><b>JAPAN</b></span></div>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr id="trSenContactNo" runat="server">
                                                <td id="tdSenMobileNoLbl" runat="server">Mobile No:
                                                        <span runat="server" class="ErrMsg" id='txtSendMobile_err'>*</span>
                                                </td>
                                                <td id="tdSenMobileNoTxt" runat="server" colspan="2">
                                                    <asp:TextBox ID="txtSendMobile" runat="server" placeholder="Mobile Number" CssClass="required form-control readonlyOnCustomerSelect" MaxLength="16" onchange="CheckForMobileNumber(this, 'Sender Mobile No.');"></asp:TextBox>
                                                </td>
                                                <td id="tdSenTelNoTxt" runat="server">
                                                    <asp:TextBox ID="txtSendTel" runat="server" placeholder="Phone Number" CssClass="form-control readonlyOnCustomerSelect" onchange="CheckForPhoneNumber(this,'Sender Phone No.');" MaxLength="15"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Gender:
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlSenGender" runat="server" CssClass="form-control readonlyOnCustomerSelect">
                                                        <asp:ListItem Value="">Select</asp:ListItem>
                                                        <asp:ListItem Value="Male">Male</asp:ListItem>
                                                        <asp:ListItem Value="Female">Female</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td id="tdSenDobLbl" runat="server">
                                                    <asp:Label runat="server" ID="lblSDOB" Text="Date Of Birth:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='txtSendDOB_err'>*</span>
                                                </td>
                                                <td id="tdSenDobTxt" runat="server" nowrap="nowrap">
                                                    <asp:TextBox ID="txtSendDOB" runat="server" ReadOnly="true" CssClass="form-control readonlyOnCustomerSelect" placeholder="YYYY/MM/DD"></asp:TextBox>
                                                    <asp:RangeValidator ID="RangeValidator1" runat="server"
                                                        ControlToValidate="txtSendDOB"
                                                        MaximumValue="12/31/2100"
                                                        MinimumValue="01/01/1900"
                                                        Type="Date"
                                                        ErrorMessage="Invalid date!"
                                                        ValidationGroup="customer"
                                                        CssClass="inv"
                                                        SetFocusOnError="true"
                                                        Display="Dynamic"> </asp:RangeValidator>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Native Country:
                                                        <span class="ErrMsg" id='txtSendNativeCountry_err'>*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:DropDownList ID="txtSendNativeCountry" runat="server" CssClass="required form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr id="trSalaryRange" runat="server" class="showOnIndividual">
                                                <td>
                                                    <asp:Label runat="server" ID="lblSalaryRange" Text="Monthly Income:"></asp:Label>
                                                    <span runat="server" id="ddlSalary_err" class="ErrMsg">*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:DropDownList ID="ddlSalary" runat="server" CssClass="form-control readonlyOnCustomerSelect">
                                                        <asp:ListItem>Select</asp:ListItem>
                                                        <asp:ListItem>JPY 0 - JPY1,700,000</asp:ListItem>
                                                        <asp:ListItem>JPY1,700,000 - JPY3,400,000</asp:ListItem>
                                                        <asp:ListItem>JPY3,400,000 - JPY6,800,000</asp:ListItem>
                                                        <asp:ListItem>JPY6,800,000 - JPY13,000,000</asp:ListItem>
                                                        <asp:ListItem>Above JPY13,000,000</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="table-responsive">
                                        <table class="table">
                                            <tr>
                                                <td style="width: 27%;">Email:</td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtSendEmail" runat="server" placeholder="Email" CssClass="LargeTextBox form-control readonlyOnCustomerSelect"></asp:TextBox>
                                                    <asp:RegularExpressionValidator ID="rev1" runat="server" Display="Dynamic"
                                                        ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                                        ControlToValidate="txtSendEmail"></asp:RegularExpressionValidator>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Customer Type:</td>
                                                <td colspan="3">
                                                    <asp:DropDownList ID="ddlSendCustomerType" runat="server" onchange="ChangeCustomerType()" CssClass="SmallTextBox form-control readonlyOnCustomerSelect">
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr id="trSenCompany" runat="server" class="hideOnIndividual">
                                                <td>
                                                    <asp:Label runat="server" ID="lblCompName" Text="Company Name:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='companyName_err'>*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="companyName" runat="server" placeholder="Company Name" CssClass="form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Company Name');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr class="hideOnIndividual">
                                                <td>Business Type
                                                        <span runat="server" class="ErrMsg" id='Span2'>*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:DropDownList ID="ddlEmpBusinessType" runat="server" CssClass="required form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr id="trSenId" runat="server" valign="bottom">
                                                <td>
                                                    <asp:Label runat="server" ID="lblsIdtype" Text="ID Type:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='ddSenIdType_err'>*</span>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddSenIdType" runat="server" CssClass="required form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                                </td>
                                                <td>
                                                    <asp:Label runat="server" ID="lblSidNo" Text="ID Number:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='txtSendIdNo_err'>*</span>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtSendIdNo" placeholder="ID Number" MaxLength="14" runat="server" CssClass="form-control readonlyOnCustomerSelect" onblur="CheckSenderIdNumber(this);" Style="width: 100%;"></asp:TextBox>
                                                    <br />
                                                    <span id="spnIdNumber" style="color: red; font-size: 10px; font-family: verdana; font-weight: bold; display: none;"></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Place Of Issue</td>
                                                <td colspan="3">
                                                    <asp:DropDownList ID="ddlIdIssuedCountry" runat="server" CssClass="form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr id="trIdExpirenDob" runat="server">
                                                <td id="tdSenIssuedDateLbl" runat="server" class="showHideIDIssuedDate" nowrap="nowrap">
                                                    <asp:Label runat="server" ID="lblsIssuedDate" Text="Issued Date:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='Span1'>*</span>
                                                </td>
                                                <td id="td2" runat="server" nowrap="nowrap" class="showHideIDIssuedDate">
                                                    <asp:TextBox ID="txtSendIdExpireDate" onchange="return DateValidation('txtSendIdExpireDate','i')" MaxLength="10" runat="server" placeholder="YYYY/MM/DD" CssClass="required form-control readonlyOnCustomerSelect"></asp:TextBox>
                                                    <asp:RangeValidator ID="RangeValidator3" runat="server"
                                                        ControlToValidate="txtSendIdExpireDate"
                                                        MaximumValue="12/31/2100"
                                                        MinimumValue="01/01/1900"
                                                        Type="Date"
                                                        ForeColor="Red"
                                                        ErrorMessage="Invalid date!"
                                                        ValidationGroup="customer"
                                                        CssClass="inv"
                                                        SetFocusOnError="true"
                                                        Display="Dynamic"> </asp:RangeValidator>
                                                </td>
                                                <td id="tdSenExpDateLbl" runat="server" class="showHideIDExpDate" nowrap="nowrap">
                                                    <asp:Label runat="server" ID="lblsExpDate" Text="Expire Date:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='txtSendIdValidDate_err'>*</span>
                                                </td>
                                                <td id="tdSenExpDateTxt" runat="server" nowrap="nowrap" class="showHideIDExpDate" width="170">
                                                    <asp:TextBox ID="txtSendIdValidDate" onchange="return DateValidation('txtSendIdValidDate')" MaxLength="10" runat="server" placeholder="YYYY/MM/DD" CssClass="form-control readonlyOnCustomerSelect"></asp:TextBox>
                                                    <asp:RangeValidator ID="RangeValidator2" runat="server"
                                                        ControlToValidate="txtSendIdValidDate"
                                                        MaximumValue="12/31/2100"
                                                        MinimumValue="01/01/1900"
                                                        Type="Date"
                                                        ForeColor="Red"
                                                        ErrorMessage="Invalid date!"
                                                        ValidationGroup="customer"
                                                        CssClass="inv"
                                                        SetFocusOnError="true"
                                                        Display="Dynamic"> </asp:RangeValidator>
                                                </td>
                                            </tr>
                                            <br />
                                            <tr id="trOccupation" runat="server" class="showOnIndividual">
                                                <td>
                                                    <asp:Label runat="server" ID="lblOccupation" Text="Occupation:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='occupation_err'>*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:DropDownList ID="occupation" runat="server" CssClass="required form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>
                            <table class="table table-responsive" style="display: none;">
                                <tr id="trSenAddress1" runat="server" style="display: none;">
                                    <td>Address1:
                                        <span runat="server" class="ErrMsg" id='txtSendAdd1_err'>*</span>
                                    </td>
                                    <td colspan="3">
                                        <asp:TextBox ID="txtSendAdd1" runat="server" CssClass="form-control"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr id="trSenAddress2" runat="server" style="display: none;">
                                    <td>Address2:</td>
                                    <td colspan="3">
                                        <asp:TextBox ID="txtSendAdd2" runat="server" CssClass="LargeTextBox form-control"></asp:TextBox></td>
                                </tr>

                                <tr style="display: none">
                                    <td>Send SMS To Sender:</td>
                                    <td nowrap="nowrap">
                                        <asp:CheckBox ID="ChkSMS" runat="server" />
                                    </td>
                                    <td></td>
                                    <td></td>
                                </tr>
                                <tr>

                                    <td id="lblMem" style="display: none">Membership ID:</td>
                                    <td id="valMem" style="display: none">
                                        <asp:TextBox ID="memberCode" runat="server" CssClass="form-control"></asp:TextBox>
                                        <span id="memberCode_err" class="ErrMsg"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <div id="divSenderIdImage"></div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <table class="table table-responsive">
                                <tr>
                                    <td>
                                        <h4 class="panel-title">Receiver Information:  <span id="receiverName"></span></h4>
                                    </td>
                                    <td style="float: right; margin-right: 15px;">
                                        <a href="javascript:void(0);" class="btn btn-sm btn-primary showOnCustomerSelect hidden" onclick="PickReceiverFromSender('a');" title="Add New Receiver"><i class="fa fa-plus"></i></a>
                                        <a href="javascript:void(0);" class="btn btn-sm btn-primary" onclick="PickReceiverFromSender('r');" title="Pick Receiver"><i class="fa fa-file-archive-o"></i></a>
                                        <a href="javascript:void(0);" id="btnReceiverClr" class="btn btn-sm btn-primary" title="Clear"><i class="fa fa-eraser"></i></a>
                                    </td>
                                </tr>
                            </table>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="table-responsive">
                                        <table class="table">
                                            <tr>
                                                <td style="width: 27%;">Choose Receiver:
                                                </td>
                                                <td colspan="3">
                                                    <asp:DropDownList ID="ddlReceiver" runat="server" onchange="DDLReceiverOnChange();" CssClass="form-control"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Receiver Name:
                                                        <span class="ErrMsg" id='txtRecFName_err'>*</span>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtRecFName" runat="server" placeholder="First Name" CssClass="required SmallTextBox form-control readonlyOnReceiverSelect" onblur="CheckForSpecialCharacter(this, 'Receiver First Name');"></asp:TextBox>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtRecMName" runat="server" placeholder="Middle Name" CssClass="SmallTextBox form-control readonlyOnReceiverSelect" onblur="CheckForSpecialCharacter(this, 'Receiver Middle Name');"></asp:TextBox>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtRecLName" runat="server" placeholder="Last Name" CssClass="SmallTextBox form-control readonlyOnReceiverSelect" onblur="CheckForSpecialCharacter(this, 'Receiver Last Name');"></asp:TextBox>
                                                    <span class="ErrMsg" id='txtRecLName_err'></span>
                                                </td>
                                                <td style="display: none;">
                                                    <asp:TextBox ID="txtRecSLName" runat="server" CssClass="SmallTextBox form-control readonlyOnReceiverSelect" onblur="CheckForSpecialCharacter(this, 'Receiver Second Last Name');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="trRecAddress1" runat="server">
                                                <td>Address1:
                                                <span runat="server" class="ErrMsg" id='txtRecAdd1_err'>*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtRecAdd1" runat="server" placeholder="Receiver Address" CssClass="required form-control"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr id="trRecAddress2" runat="server" style="display: none;">
                                                <td>
                                                    <asp:Label runat="server" ID="lblrAdd" Text="Address2:"></asp:Label></td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtRecAdd2" runat="server" CssClass="LargeTextBox form-control readonlyOnReceiverSelect"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td id="tdRecCityLbl" runat="server">
                                                    <asp:Label runat="server" ID="lblrCity" Text="City:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='txtRecCity_err'>*</span>
                                                </td>
                                                <td id="tdRecCityTxt" runat="server" colspan="3">
                                                    <asp:TextBox ID="txtRecCity" placeholder="Receiver City" runat="server" CssClass="form-control readonlyOnReceiverSelect" onblur="CheckForSpecialCharacter(this, 'Receiver City');"></asp:TextBox>
                                                </td>
                                                <asp:TextBox Style="display: none" ID="txtRecPostal" runat="server" CssClass="form-control" onblur="CheckForSpecialCharacter(this, 'Receiver Postal Code');"></asp:TextBox>
                                            </tr>
                                            <tr id="trRecContactNo" runat="server">
                                                <td id="tdRecMobileNoLbl" runat="server">Mobile No: <span runat="server" class="ErrMsg" id='txtRecMobile_err'>*</span>
                                                </td>
                                                <td id="tdRecMobileNoTxt" runat="server" colspan="2">
                                                    <asp:TextBox ID="txtRecMobile" runat="server" placeholder="Mobile Number" MaxLength="16" CssClass="required form-control" onchange="CheckForMobileNumber(this, 'Receiver Mobile No.');"></asp:TextBox>
                                                </td>
                                                <td id="tdRecTelNoTxt" runat="server">
                                                    <asp:TextBox ID="txtRecTel" runat="server" placeholder="Phone Number" MaxLength="15" CssClass="form-control readonlyOnReceiverSelect" onchange="CheckForPhoneNumber(this, 'Receiver Tel. No.');"></asp:TextBox>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="table-responsive">
                                        <table class="table">
                                            <tr>
                                                <td style="width: 27%;">&nbsp;</td>
                                                <td>&nbsp;</td>
                                            </tr>
                                            <tr id="trRecId" runat="server" class="trRecId">
                                                <td>
                                                    <asp:Label runat="server" ID="lblRidType" Text="ID Type:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='ddlRecIdType_err'>*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:DropDownList ID="ddlRecIdType" runat="server" CssClass="form-control readonlyOnReceiverSelect"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr id="trRecId1" runat="server" class="trRecId">
                                                <td>
                                                    <asp:Label runat="server" ID="lblRidNo" Text="ID Number:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='txtRecIdNo_err'>*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtRecIdNo" runat="server" placeholder="ID Number" CssClass="form-control readonlyOnReceiverSelect" onblur="CheckForSpecialCharacter(this, 'Receiver ID Number');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr style="display: none">
                                                <td>Gender:
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlRecGender" runat="server" CssClass="form-control readonlyOnReceiverSelect">
                                                        <asp:ListItem Value="">SELECT</asp:ListItem>
                                                        <asp:ListItem Value="Male">Male</asp:ListItem>
                                                        <asp:ListItem Value="Female">Female</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Email:</td>
                                                <td colspan="3">
                                                    <asp:TextBox ID="txtRecEmail" runat="server" placeholder="Email" CssClass="LargeTextBox form-control readonlyOnReceiverSelect"></asp:TextBox>
                                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" Display="Dynamic"
                                                        ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                                        ControlToValidate="txtRecEmail"></asp:RegularExpressionValidator>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Transaction Information:</h4>
                            <span style="display: none; background-color: black; font-size: 15px; color: #FFFFFF; line-height: 13px; vertical-align: middle; text-align: center; font-weight: bold;">[Per day per customer transaction limit:
                                    <asp:Label ID="lblPerDayLimit" runat="server"></asp:Label>&nbsp;<asp:Label ID="lblPerDayCustomerCurr" runat="server"></asp:Label>
                                ]
                            </span>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="table-responsive">
                                        <table class="table">
                                            <tr style="">
                                                <td style="vertical-align: top;">Receiving Country:
                                                     <span class="ErrMsg" id="pCountry_err">*</span>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="pCountry" runat="server" CssClass="required form-control"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr class="locationRow">
                                                <td>State:<span class="ErrMsg">*</span></td>
                                                <td>
                                                    <asp:DropDownList ID="locationDDL" runat="server" CssClass="required form-control"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <span id="lblPayoutAgent">Agent / Bank:</span>
                                                    <span class="ErrMsg" id="pAgent_err">*</span>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="pAgent" runat="server" CssClass="required form-control"></asp:DropDownList>
                                                    <asp:DropDownList ID="pAgentDetail" runat="server" CssClass="form-control" Style="display: none;"></asp:DropDownList>
                                                    <asp:DropDownList ID="pAgentMaxPayoutLimit" runat="server" CssClass="form-control" Style="display: none;"></asp:DropDownList>
                                                    <span id="hdnreqAgent" style="display: none"></span>
                                                    <input type="hidden" id="hdnBankType" />
                                                </td>
                                            </tr>

                                            <tr id="trForCPOB" style="display: none;">
                                                <td>Payment through:
                                                        <span class="ErrMsg">*</span>
                                                </td>
                                                <td colspan="3">
                                                    <asp:DropDownList ID="paymentThrough" runat="server" CssClass="form-control"></asp:DropDownList>
                                                </td>
                                            </tr>

                                            <tr class="trScheme">
                                                <td>Scheme/Offer:</td>
                                                <td>
                                                    <asp:DropDownList ID="ddlScheme" runat="server" CssClass="form-control"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr id="trAccno" style="display: none;">
                                                <td>Bank Account No:
                                                        <span id="txtRecDepAcNo_err" class="ErrMsg">*</span>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtRecDepAcNo" runat="server" CssClass="form-control" onblur="CheckForSpecialCharacter(this, 'Receiver Acc No.');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td valign="top">Collection Amount:
                                                        <span class="ErrMsg" id='txtCollAmt_err'>*</span>
                                                </td>
                                                <td>
                                                    <div class="input-group m-b">
                                                        <asp:TextBox ID="txtCollAmt" runat="server" placeholder="Amount including service charge" CssClass="required BigAmountField form-control" Style="font-size: 16px; font-weight: bold; padding: 2px;"></asp:TextBox>
                                                        <span class="input-group-addon">(Max Limit: <u><b>
                                                            <asp:Label ID="lblPerTxnLimit" runat="server" Text="0.00"></asp:Label>
                                                        </b></u>)&nbsp;
                                                            <asp:Label ID="lblPerTxnLimitCurr" runat="server">JPY</asp:Label>
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Sending Amount: </td>
                                                <td>
                                                    <div class="input-group m-b">
                                                        <asp:TextBox ID="lblSendAmt" runat="server" Text="0.00" class="amountLabel required form-control disabled" disabled="disabled"></asp:TextBox>
                                                        <span class="input-group-addon">
                                                            <asp:Label ID="lblSendCurr" runat="server" Text="JPY" class="amountLabel"></asp:Label>
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Service Charge:
                                                </td>
                                                <td>
                                                    <input type="checkbox" id="editServiceCharge" runat="server" /><label for="editServiceCharge">EDIT</label>
                                                    <asp:HiddenField ID="allowEditSC" runat="server" />
                                                    <asp:TextBox ID="lblServiceChargeAmt" runat="server" Text="0" class="form-control" Width="20%" Style="display: inherit !important;" onblur="return ReCalculate();"></asp:TextBox>
                                                    <asp:Label ID="lblServiceChargeCurr" runat="server" Text="JPY" class="amountLabel"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr runat="server" id="customerRateFields">
                                                <td>Customer Rate:</td>
                                                <td>
                                                    <asp:Label ID="lblExRate" runat="server" Text="0.00" class="amountLabel"></asp:Label>
                                                    <asp:Label ID="lblExCurr" runat="server" Text="" class="amountLabel"></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="table-responsive">
                                        <table class="table">
                                            <tr class="deposited-bank-hide">
                                                <td style="width: 27%;">&nbsp;</td>
                                                <td>&nbsp;</td>
                                            </tr>
                                            <tr class="deposited-bank" style="display: none;">
                                                <td>Deposited Bank: <span class="ErrMsg">*</span></td>
                                                <td>
                                                    <asp:DropDownList ID="depositedBankDDL" runat="server" CssClass="form-control"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr style="">
                                                <td style="vertical-align: top;">Receiving Mode:<span class="ErrMsg">*</span>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="pMode" runat="server" CssClass="required form-control"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr id="subLocation">
                                                <td>City:<span class="ErrMsg">*</span></td>
                                                <td>
                                                    <asp:DropDownList ID="subLocationDDL" runat="server" CssClass="form-control"></asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="display: none" class="same">Branch:<span class="ErrMsg" id="agentBranchRequired">*</span>
                                                </td>
                                                <td style="display: none" class="same">
                                                    <div id="divBankBranch">
                                                        <select id="branch" runat="server" class="form-control">
                                                            <option value="">SELECT BANK</option>
                                                        </select>
                                                    </div>
                                                    <input type="hidden" id="txtpBranch_aValue" class="form-control" />
                                                    <span id="hdnreqBranch" style="display: none"></span><span class="ErrMsg" id="reqBranch" style="display: none"></span>
                                                    <div id="divBranchMsg" style="display: none;" class="note"></div>
                                                </td>
                                            </tr>

                                            <tr class="trScheme">
                                                <td id="tdItelCouponIdLbl" style="display: none;">ITEL Coupon ID:</td>
                                                <td id="tdItelCouponIdTxt" style="display: none;">
                                                    <asp:TextBox ID="iTelCouponId" runat="server" CssClass="form-control"></asp:TextBox>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td id="tdLblPCurr">Payout Currency:<span class="ErrMsg">*</span></td>

                                                <td id="tdTxtPCurr">
                                                    <select id="pCurrDdl" runat="server" class="required form-control" onchange="CalculateTxn();"></select>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Payout Amount: <span class="ErrMsg" id='txtPayAmt_err'>*</span></td>
                                                <td>
                                                    <div class="input-group m-b">
                                                        <asp:TextBox ID="txtPayAmt" runat="server" Enabled="false" CssClass="required BigAmountField disabled form-control"></asp:TextBox>
                                                        <span class="input-group-addon">
                                                            <asp:Label ID="lblPayCurr" runat="server" Text="" class="amountLabel"></asp:Label>
                                                            <i class="fa fa-refresh btn btn-sm btn-primary" onclick="ChangeCalcBy()"></i>
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td id="tdScheme" style="display: none;" valign="top">Scheme/Offer:</td>
                                                <td id="tdSchemeVal" style="display: none;">
                                                    <span id="spnSchemeOffer" style="font-weight: bold; font-family: Verdana; color: black; font-size: 10px;"></span>
                                                    <input type="hidden" id="scDiscount" name="scDiscount" />
                                                    <input type="hidden" id="exRateOffer" value="exRateOffer" />
                                                </td>
                                            </tr>
                                            <tr id="ReferralDiv">
                                                <td>Introducer (If Any):
                                                </td>
                                                <td>
                                                    <uc1:SwiftTextBox ID="introducerTxt" runat="server" Category="remit-referralCode" CssClass="form-control" Title="Blank for All" />

                                                </td>

                                                <td colspan="2" rowspan="4">
                                                    <span id="spnPayoutLimitInfo" style="color: red; font-size: 16px; font-weight: bold;"></span></td>
                                            </tr>
                                            <tr>
                                                <td id="Td1" runat="server"></td>
                                                <td id="referralBalId" runat="server"></td>
                                            </tr>
                                            <tr class="displayPayerInfo">
                                                <td>Payer : </td>
                                                <td><span runat="server" id="payerText"></span></td>
                                            </tr>
                                            <tr class="displayPayerInfo">
                                                <td>Payer Branch : </td>
                                                <td><span runat="server" id="payerBranchText"></span></td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="table-responsive">
                                        <table class="table">
                                            <tr>
                                                <td style="width: 13%;">&nbsp;</td>

                                                <td>
                                                    <input type="button" id="btnCalculate" value="Calculate" class="btn btn-primary" />&nbsp;
                                                        <input type="button" id="btnCalcClean" value="Clear" class="btn btn-clear" />&nbsp;
                                                        <%--<input name="button" type="button" id="btnCalcPopUp" value="Calculator" class="btn btn-primary" />--%>
                                                    <span id="finalSenderId" style="display: none"></span>
                                                    <span id="finalBenId" style="display: none"></span>
                                                    <input type="hidden" id="finalAgentId" />
                                                    <input type="hidden" id="txtCustomerLimit" value="0" />
                                                    <asp:HiddenField ID="txnPerDayCustomerLimit" runat="server" Value="0" />
                                                    <input type="hidden" id="hdnInvoicePrintMethod" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" align="center">
                                                    <div align="center">
                                                        <span id="span_txnInfo" align="center" runat="server" style="font-size: 14px; color: #FFFFFF; background-color: #333333; line-height: 15px; vertical-align: middle; text-align: center; font-weight: 500;"></span>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <span id="spnWarningMsg" style="font-size: 13px; font-family: Verdana; font-weight: bold; color: Red;"></span></td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer Due Diligence Information -(CDDI)</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="col-md-6">
                                <div class="table-responsive">
                                    <table class="table">
                                        <tr id="trPurposeOfRemittance" runat="server">
                                            <td style="width: 27%;">
                                                <asp:Label runat="server" ID="lblPoRemit" Text="Purpose of Remittance:"></asp:Label>
                                                <span runat="server" class="ErrMsg" id='purpose_err'>*</span>
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="purpose" runat="server" CssClass="required form-control"></asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr id="trRelWithRec" runat="server">
                                            <td>
                                                <asp:Label runat="server" ID="lblRelation" Text="Relationship with Receiver:"></asp:Label>
                                                <span runat="server" class="ErrMsg" id='relationship_err'>*</span>
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="relationship" runat="server" CssClass="required form-control"></asp:DropDownList>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="table-responsive">
                                    <table class="table">
                                        <tr id="trSourceOfFund" runat="server">
                                            <td style="width: 27%;">
                                                <asp:Label runat="server" ID="lblSof" Text="Source of Fund:"></asp:Label>
                                                <span runat="server" class="ErrMsg" id='sourceOfFund_err'>*</span>
                                            </td>
                                            <td>
                                                <asp:DropDownList ID="sourceOfFund" runat="server" CssClass="required form-control"></asp:DropDownList>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div class="col-md-12">
                                <div class="table-responsive">
                                    <table class="table">
                                        <tr>
                                            <td id="msgRecDiv">Message to Receiver:</td>
                                            <td>
                                                <asp:TextBox ID="txtPayMsg" runat="server" CssClass="LargeTextBox form-control" TextMode="MultiLine" onblur="CheckForSpecialCharacter(this, 'Message to Receiver');"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td></td>
                                            <td>
                                                <br />
                                                <input type="button" name="calc" id="calc" value="Send Transaction" class="btn btn-primary" />
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
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="modal fade" id="myModal2" style="margin-top: 100px;" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                        <div class="modal-dialog modal-md" role="document">
                            <div class="modal-content">
                                <div class="modal-header" id="modelUserForSave1">
                                    <center> <h2 class="modal-title">Customer Deposit Mapping<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></h2></center>
                                </div>
                                <div class="modal-body">
                                    <div class="row">
                                        <div class="form-group col-md-6">
                                            <label class="">Tran Date:</label>
                                            <div class="form-inline">
                                                <div class="input-group input-append date">
                                                    <asp:TextBox runat="server" ID="tranDate" onchange="return DateValidation('tranDate','i')" MaxLength="10" AutoComplete="off" placeholder="YYYY/MM/DD" CssClass="form-control datepicker date-field required"></asp:TextBox>
                                                    <div class="input-group-addon "><i class="fa fa-calendar"></i></div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="form-group col-md-6">
                                            <label>Particulars</label>
                                            <asp:TextBox ID="particulars" runat="server" CssClass="form-control"></asp:TextBox>
                                        </div>
                                        <div class="form-group col-md-12">
                                            <input type="button" id="filterBtn" value="Filter" class="btn btn-primary" />
                                            <input type="button" id="clearBtn" value="Clear" class="btn btn-primary" />
                                        </div>
                                    </div>
                                    <div class="row form-group">
                                        <div class="col-md-12 table-responsive">
                                            <table class="table table-responsive table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th width="5%"><i class="fa fa-check check" style="display: none;"></i><i class="fa fa-times uncheck"></i></th>
                                                        <th width="50%">Particulars</th>
                                                        <th width="15%">Deposit Date</th>
                                                        <th width="15%">Deposit Amount</th>
                                                        <th width="15%">Withdraw Amount</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="customerDepositMapping" runat="server">
                                                    <tr>
                                                        <td colspan="5" align="center">No Data To Display </td>
                                                    </tr>
                                                </tbody>

                                            </table>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group col-md-12">
                                            <%--<asp:Button ID="btnConfirmSave" runat="server" OnClientClick="return ConfirmSave();" CssClass="btn btn-primary" Text="Confirm Save" OnClick="btnConfirmSave_Click" />--%>
                                            <asp:Button ID="btnConfirmSave" runat="server" OnClientClick="return ConfirmSave();" CssClass="btn btn-primary" Text="Confirm Save" />
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="modal fade" id="myModal1" style="margin-top: 200px;" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                        <div class="modal-dialog modal-md" role="document">
                            <div class="modal-content">
                                <div class="modal-header" id="modelUserForSave">
                                    <center> <h2 class="modal-title">Choose Payer Details<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></h2></center>
                                </div>
                                <div class="modal-body">
                                    <div class="form-group">
                                        <div class="col-md-4">
                                            <label class="control-label">Payer Data :<span class="ErrMsg">*</span></label>
                                        </div>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="ddlPayer" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-md-4">
                                            <label class="control-label">Payer Branch : <span class="ErrMsg">*</span></label>
                                        </div>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="ddlPayerBranch" runat="server" CssClass="form-control"></asp:DropDownList>
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
    <asp:HiddenField ID="hddPayoutPartner" runat="server" />
    <asp:HiddenField ID="hddTPExRate" runat="server" />
    <asp:HiddenField ID="hddCustomerId" runat="server" />

    <script type="text/javascript">

        ClearData();
        function Autocomplete() {
            $(".searchinput").autocomplete({
                source: function (request, response) {
                    $.ajax({
                        type: "POST",
                        contentType: "application/json; charset=utf-8",
                        url: "../../../Autocomplete.asmx/GetAllCountry",
                        data: "{'keywordStartsWith':'" + request.term + "'}",
                        dataType: "json",
                        async: true,
                        success: function (data) {
                            response(
                                $.map(data.d, function (item) {
                                    return {
                                        value: item.Value,
                                        key: item.Key
                                    };
                                }));
                            window.parent.resizeIframe();
                        },

                        error: function (result) {
                            alert("Due to unexpected errors we were unable to load data");
                        }
                    });
                },

                minLength: 2
            });
        }

        Autocomplete();
    </script>
    <script type="text/javascript">
        //PickLocation
        function PickLocation() {
            var pAgent = $('#<%=pAgent.ClientID %> option:selected').val();
            $('#<%=pAgentDetail.ClientID %>').val(pAgent);
            var pAgentType = $('#<%=pAgentDetail.ClientID %> option:selected').text();
            if (pAgent == "" || pAgent == undefined || pAgent == 0) {
                alert('First Select a Agent/Branch');
                $('#<%=pAgent.ClientID %>').focus();
                return;
            }
            var url = "TxnHistory/PickLocationByAgent.aspx?pAgent=" + pAgent;
            var param = "dialogHeight:470px;dialogWidth:700px;dialogLeft:200;dialogTop:100;center:yes";
            var res = PopUpWindow(url, param);
        }

        function PickpBranch() {
            var pAgent = $('#<%=pAgent.ClientID %> option:selected').val();
            $('#<%=pAgentDetail.ClientID %>').val(pAgent);
            var pAgentType = $('#<%=pAgentDetail.ClientID %> option:selected').text();
            if (pAgent == "" || pAgent == undefined || pAgent == 0) {
                alert('First Select a Agent/Branch');
                $('#<%=pAgent.ClientID %>').focus();
                return;
            }
            var url = "TxnHistory/PickBranchByAgent.aspx?pAgent=" + pAgent + "&pAgentType=" + pAgentType;
            var param = "dialogHeight:470px;dialogWidth:700px;dialogLeft:200;dialogTop:100;center:yes";
            var res = PopUpWindow(url, param);
            if (res == "undefined" || res == null || res == "") {
            }
            else {
                var splitVal = res.split('|');
                var pBranchValue = splitVal[0];
                var pBranchText = splitVal[1];
                $("#txtpBranch_aValue").val(splitVal[0]);
                $("#txtpBranch_aText").val(splitVal[1]);

                var pMode = $("#<%=pMode.ClientID%> option:selected").text();
                if (pMode == "CASH PAYMENT TO OTHER BANK")
                    PBranchChange(pBranchValue);
            }
        }

        function ShowHide(me, tbl) {
            var text = me.value;
            if (text == "+") {
                me.value = "-";
                me.title = "Hide";
                ShowElement(tbl);
            } else {
                me.value = "+";
                me.title = "Show";
                HideElement(tbl);
            }
        }

        function Show(me, tbl) {
            me.value = "-";
            me.title = "Hide";
            ShowElement(tbl);
        }

        $('#<%=txtSendDOB.ClientID%>').blur(function () {
            var CustomerDob = GetValue("<%=txtSendDOB.ClientID %>");
            if (CustomerDob != "") {
                var CustYears = datediff(CustomerDob, 'years');

                if (parseInt(CustYears) < 18) {
                    alert('Customer age must be 18 or above !');
                    return;
                }
            }
        });

        $(function () {
            $('#btnCalcPopUp').click(function () {
                var pCountry = GetValue("<%=pCountry.ClientID %>");
                var pMode = GetValue("<%=pMode.ClientID %>");
                var pAgent = GetValue("<%=pAgent.ClientID %>");
                if (pMode == "") {
                    alert("Please select receiving mode");
                    return;
                }
                var queryString = "?pMode=" + pMode + "&pCountry=" + pCountry + "&pAgent=" + pAgent;
                var param = "dialogHeight:900px;dialogWidth:900px;dialogLeft:200;dialogTop:100;center:yes";
                var res = PopUpWindow("Calculator.aspx" + queryString, param);
                if (res == "undefined" || res == null || res == "") {
                }
                else {
                    GetElement("<%=txtCollAmt.ClientID %>").value = res;
                    CalculateTxn();
                }
            });
        });

        document.getElementById("<%=NewCust.ClientID%>").focus();

        $(function () {
            $('#<%=ddlRecIdType.ClientID%>').change(function () {
                $('#<%=txtRecIdNo.ClientID%>').val('');
                var idType = $("#<%=ddlRecIdType.ClientID%> option:selected").text();
                var idTypeVal = $("#<%=ddlRecIdType.ClientID%> option:selected").val();
                $('#<%=txtRecIdNo.ClientID%>').attr('disabled', 'disabled').removeClass('required').removeAttr('style');
                $('#<%=txtRecIdNo_err.ClientID%>').hide();
                if (idTypeVal !== "" && idTypeVal !== null && idTypeVal !== "0") {
                    $('#<%=txtRecIdNo.ClientID%>').removeAttr('disabled').addClass('required');
                    $('#<%=txtRecIdNo_err.ClientID%>').show();
                }
                if (idType == "Alien Registration Card") {
                    $(".recIdDateValidate").css("display", "");
                }
                else {
                    $(".recIdDateValidate").css("display", "none");
                }
            });
        });

        $(function () {
            $("#<%= pAgent.ClientID %>").change(function () {
                var bankId = $("#<%= pAgent.ClientID %> option:selected").val();
                if (bankId === "" || bankId === null) {
                    return;
                }
                var pmode = $("#<%=pMode.ClientID%>").val();
                var partnerId = $("#<%=hddPayoutPartner.ClientID%>").val();
                $('.same').hide();
                $('#<%=branch.ClientID%>').removeClass('required');
                $('.displayPayerInfo').hide();
                PopulateBankDetails(bankId, pmode);
                if (partnerId === apiPartnerIds[0] || pmode === "2") {
                    if ((partnerId === apiPartnerIds[0]) && pmode === "2") {
                        $('#agentBranchRequired').hide();
                    }
                    $('.same').show();
                    if ((partnerId === apiPartnerIds[0]) && pmode === "2" && (bankId != "0" && bankId != null && bankId != "")) {
                        LoadPayerData();
                    }
                }
            });
        });

        function PopulateBankDetails(bankId, receiveMode, isBranchByName, branchSelected) {
            ManageHiddenFields(receiveMode);
            var partnerId = $("#<%=hddPayoutPartner.ClientID%>").val();
            var receivingCountryId = $("#<%=pCountry.ClientID%>").val();
            var dataToSend = '';
            if (isBranchByName == '' || isBranchByName == undefined) {
                dataToSend = { bankId: bankId, type: 'bb', pMode: receiveMode, partnerId: partnerId , receivingCountryId: receivingCountryId };
            }
            else {
                dataToSend = { bankId: bankId, type: 'bb', isBranchByName: isBranchByName, branchSelected: branchSelected, pMode: receiveMode, partnerId: partnerId, receivingCountryId: receivingCountryId  };
            }
            $.get("/AgentNew/SendTxn/FormLoader.aspx", dataToSend, function (data) {
                GetElement("divBankBranch").innerHTML = data;
            });
        }

        function ManageHiddenFields(receiveMode) {
            receiveMode = ($("#<%=pMode.ClientID%> option:selected").val() == '' || $("#<%=pMode.ClientID%> option:selected").val() == undefined) ? receiveMode : $("#<%=pMode.ClientID%> option:selected").val();
            if (receiveMode == "2" || receiveMode.toUpperCase() == 'BANK DEPOSIT') {
                $(".same").css("display", "");
                $('#<%=branch.ClientID%>').addClass('required');
            }
            else {
                $(".same").css("display", "none");
                $('#<%=branch.ClientID%>').removeClass('required');

            }
        }

        function ManageLocationData() {
            var pCountry = $('#<%=pCountry.ClientID%> :selected').text();
            var pMode = $('#<%=pMode.ClientID%>').val();
            var payoutPartnerId = $('#<%=hddPayoutPartner.ClientID%>').val();
            if (pCountry == '151') {
                GetElement("<%=locationDDL.ClientID %>").className = "form-control";
                GetElement("<%=subLocationDDL.ClientID %>").className = "form-control";
                $('#<%=locationDDL.ClientID%>').empty();
                $('#<%=subLocationDDL.ClientID%>').empty();
                return;
            }
            GetElement("<%=locationDDL.ClientID %>").className = "required form-control";
            GetElement("<%=subLocationDDL.ClientID %>").className = "required form-control";
            $('.locationRow').show();
            var dataToSend = { MethodName: 'getLocation', PCountry: pCountry, PMode: pMode, PartnerId: payoutPartnerId };
            var options = {
                url: '<%=ResolveUrl("SendV2.aspx") %>?',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success:
                    function (response) {
                        LoadLocationDDL(response);
                    },
                error: function (result) {
                    alert("Due to unexpected errors we were unable to load data");
                }
            };
            $.ajax(options);
        }

        function LoadLocationDDL(response) {
            var data = response;
            var ddl = GetElement("<%=locationDDL.ClientID %>");
            $(ddl).empty();

            $('#<%=subLocationDDL.ClientID%>').empty();

            var option;
            option = document.createElement("option");

            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");
                if (data[i].LOCATIONNAME == 'Any State') {
                    $('#subLocation').hide();
                }
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

        function GetPayoutPartner(payMode) {
            var pCountry = $('#<%=pCountry.ClientID%>').val();
            var pMode = $('#<%=pMode.ClientID%>').val();
            var dataToSend = { MethodName: 'getPayoutPartner', PCountry: pCountry, PMode: pMode };
            var options = {
                url: '<%=ResolveUrl("SendV2.aspx") %>?',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                async: false,
                success:
                    function (response) {
                        var datas = response;
                        var agentId = "";
                        if (datas.length > 0) {
                            agentId = datas[0].agentId;
                        }
                        $('#<%=hddPayoutPartner.ClientID%>').val(agentId);
                    },
                error: function (result) {
                    alert("Due to unexpected errors we were unable to load data");
                }
            };
            $.ajax(options);
        }

        function GetAddressByZipCode() {
            var zipCodeValue = $("#<%=txtSendPostal.ClientID%>").val();
            $("#txtState").val('');
            $("#txtStreet").val('');
            $("#city").val('');
            $("#txtsenderCityjapan").val('');
            $("#txtstreetJapanese").val('');
            var zipCodePattern = /^\d{3}(-\d{4})?$/;
            test = zipCodePattern.test(zipCodeValue);
            if (!test) {
                $("#<%=txtSendPostal.ClientID%>").val('');
                $("#<%=txtSendPostal.ClientID%>").focus();
                $("#<%=txtSendPostal.ClientID%>").attr("style", "display:block; background:#FFCCD2");
                return alert("Please Enter Valid Zip Code(XXX-XXXX)");
            }
            var dataToSend = { MethodName: 'GetAddressDetailsByZipCode', zipCode: zipCodeValue };
            var options = {
                url: '<%=ResolveUrl("SendV2.aspx") %>?',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success:
                    function (response) {
                        ShowAddress(response);
                    },
                error: function (result) {
                    alert("Due to unexpected errors we were unable to load data");
                }
            };
            $.ajax(options);
        }

        function ShowAddress(erd) {
            if (erd !== null) {
                if (erd == false) {
                    $("#<%=txtSendPostal.ClientID%>").val('');
                    $("#<%=txtSendPostal.ClientID%>").focus();
                    $("#<%=txtSendPostal.ClientID%>").attr("style", "display:block; background:#FFCCD2");
                    return alert("Please Enter Valid Zip Code(XXX-XXXX)");
                }
                $("#<%=txtSendPostal.ClientID%>").removeAttr("style");
                $("#tempAddress").html(erd);
                var fullAddress = $(".town div:first-child").text();
                var newZipCode = $(".town a:first-child").text();
                fullAddress = fullAddress.replace(newZipCode, '');
                fullAddress = fullAddress.split('(')[0];
                var fullAddressArr = fullAddress.split(",");
                $("#zipCode").val(newZipCode);
                fullAddressArr.reverse();
                $("#txtState").val(fullAddressArr[0].trim());
                $("#<%=sCustStreet.ClientID%>").val(fullAddressArr[1].trim());
                $("#<%=txtSendCity.ClientID%>").val(fullAddressArr[2]);
                $("#txtsenderCityjapan").val(fullAddressArr[3]);
                $("#txtstreetJapanese").val(fullAddressArr[4]);
            }
        }

        function LoadPayerData() {
            var bankId = $("#<%=pAgent.ClientID%>").val();
            if (bankId !== null && bankId !== "") {
                var partnerId = $('#<%=hddPayoutPartner.ClientID%>').val();
                if (partnerId === apiPartnerIds[1]) {
                    bankId = $('#<%=pAgent.ClientID%> :selected').text();
                }
                var dataToSend = { MethodName: 'getPayerDataByBankId', bankId: bankId, partnerId: partnerId };
                $.post("", dataToSend, function (response) {
                    $("#myModal1").modal('show');
                    var data = jQuery.parseJSON(response);
                    var ddl = GetElement("<%=ddlPayerBranch.ClientID%>");
                    $(ddl).empty();
                    CreateDDLFromData(data, "<%=ddlPayer.ClientID%>");
                });
            }
        }

        function CreateDDLFromData(data, elementId, defaultText = null) {
            var ddl = GetElement(elementId);
            $(ddl).empty();

            var option;
            if (defaultText !== null) {
                option = document.createElement("option");
                option.text = defaultText;
                option.value = '';
                ddl.options.add(option);
            }
            for (var i = 0; i < data.length; i++) {
                option = document.createElement("option");
                option.text = data[i].payerName;
                option.value = data[i].payerId;
                try {
                    ddl.options.add(option);
                }
                catch (e) {
                    alert(e);
                }
            }
        }

        $('#<%=ddlPayer.ClientID%>').change(function () {
            var payerId = $(this).val();
            var cityId = $("#<%=subLocationDDL.ClientID%>").val();
            if (payerId !== "" && payerId !== null) {
                var partnerId = $('#<%=hddPayoutPartner.ClientID%>').val();
                var dataToSend = { MethodName: 'getPayerBranchDataByPayerAndCityId', payerId: payerId, partnerId: partnerId, CityId: cityId };
                $.post("", dataToSend, function (response) {
                    $("#myModal1").modal('show');
                    var data = jQuery.parseJSON(response);
                    CreateDDLFromData(data, "<%=ddlPayerBranch.ClientID%>");
                });
            }
        });

        $('#<%=ddlPayerBranch.ClientID%>').change(function () {
            payerBranchId = $(this).val();
            if (payerBranchId === null || payerBranchId === "") {
                return alert("Please Select Payer Branch Information");
            }
            payerText = $('#<%=ddlPayer.ClientID%> option:selected').text();
            payerBranchText = $('#<%=ddlPayerBranch.ClientID%> option:selected').text();
            $("#<%=payerText.ClientID%>").text(payerText);
            $("#<%=payerBranchText.ClientID%>").text(payerBranchText);
            $('.displayPayerInfo').show();
            $("#myModal1").modal('hide');
        });
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            var allowOnBehalf = '<%=IsAllowOnBehalf%>';
            if (allowOnBehalf == 'N') {
                $("#<%=sendingAgentOnBehalfDDL.ClientID%>").attr("disabled", "disabled");
                $('#<%=sendingAgentOnBehalfDDL.ClientID%>').val('<%=LogginBranch%>');
                OnBehalfAgentOnChange();
            }
            $('#<%=sendingAgentOnBehalfDDL.ClientID%>').change(function () {
                OnBehalfAgentOnChange();
            });
        });

        function OnBehalfAgentOnChange() {
            var dataToSend = { MethodName: 'getAvailableBalance', branchId: $('#<%=sendingAgentOnBehalfDDL.ClientID%>').val().split('|')[0] };
            $.post("", dataToSend, function (response) {
                var data = jQuery.parseJSON(response);
                ClearTxnData();
                var actAsBranch = $('#<%=sendingAgentOnBehalfDDL.ClientID%>').val().split('|')[1];
                if (actAsBranch == "N") {
                    $("#ReferralDiv").hide();
                } else {
                    $("#ReferralDiv").show();
                }
                if (data == null || data == undefined || data == '') {
                    $('#<%=availableAmt.ClientID%>').text('N/A');
                }
                else {
                    $('#<%=availableAmt.ClientID%>').text(data[0].availableBal);
                    $('#<%=balCurrency.ClientID%>').text(data[0].balCurrency);
                    $('#<%=lblPerDayLimit.ClientID%>').text(data[0].txnPerDayCustomerLimit);
                    $('#<%=lblPerDayCustomerCurr.ClientID%>').text(data[0].sCurr);
                    $('#<%=lblPerTxnLimitCurr.ClientID%>').text(data[0].sCurr);
                    $('#<%=lblSendCurr.ClientID%>').text(data[0].sCurr);
                    $('#<%=lblServiceChargeCurr.ClientID%>').text(data[0].sCurr);
                    $('#<%=txnPerDayCustomerLimit.ClientID%>').val(data[0].txnPerDayCustomerLimit);
                    $('#<%=hdnLimitAmount.ClientID%>').val(data[0].sCountryLimit);
                }
            });
        }
    </script>
</asp:Content>
