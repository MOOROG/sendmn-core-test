<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Pay.aspx.cs" Inherits="Swift.web.AgentPanel.Pay.PayTransaction.Pay" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <title></title>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>

    <script src="/ui/js/jquery.validate.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            $("#topupTR").hide();
            $('.issuemember').hide();
            $('div.issuemember.row').hide();
            $.ajaxSetup({ cache: false });
            $("#<%=rIdType.ClientID %>").change(function () {
                var val = $(this).val().split('|')[1];
                //var ischecked = $("#chkIssueCustCard").is(':checked');
                //if (ischecked) {
                if (val == 'N' || val == undefined) {
                    SetValueById("<%=rIdValidDate.ClientID%>", "", "");

                    $('#rIdValidDate').removeClass("required");

                    $('.trIdExpiryDate').hide();
                }
                else {
                    $(".trIdExpiryDate").show();

                    $('#rIdValidDate').addClass("required");
                }
                /*}
                else {
                $("#trIdExpiryDate").hide();
               <%-- SetValueById("<%=rIdValidDate.ClientID%>", "", "");--%>
                //}*/
                //FilterIdIssuedPlace();

            });

            //FilterIdIssuedPlace();

        });
        //

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

        $(document).ajaxStart(function () {
            $("#DivLoad").show();
        });

        $(document).ajaxComplete(function (event, request, settings) {
            $("#DivLoad").hide();
        });
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

        var urlRoot = "<%=GetStatic.GetUrlRoot()%>";
        function SetDDLValueSelected(ddl, selectText) {
            $("#" + ddl + " option").each(function () {
                var text = $.trim($(this).text()).toUpperCase();
                var search = $.trim(selectText).toUpperCase();
                if (text == search) {
                    $(this).attr("selected", "selected");
                    return;
                }
            });
        }
        function PickReceiver() {
            var rMemId = GetValue("<%=rMembershipId.ClientID %>");
            $.get(urlRoot + "/Remit/Transaction/ThirdPartyTXN/Pay/FormLoader.aspx", { memId: rMemId, type: 'rPayThirdParty' }, function (data) {
                var array = eval(data);

                if (array[0].errorCode != "0") {
                    SetValueById("<%=hddCustomerId.ClientID %>", "", "");
                    SetValueById("<%=hddMembershipId.ClientID %>", "", "");
                    window.parent.SetMessageBox(array[0].errorMsg, '1');
                    return;
                }
                rowFullName.style.display = "block";
                SetValueById("<%=rFullName.ClientID %>", array[0].fullName, "");
                SetValueById("<%=hddMembershipId.ClientID %>", array[0].membershipId, "");
                SetValueById("<%=rIdType.ClientID %>", array[0].IdType1, "");
                $("#rIdType").trigger("change");
                SetValueById("<%=rIdNumber.ClientID %>", array[0].idNumber, "");
                SetValueById("<%=hddrIdPlaceOfIssue.ClientID %>", array[0].placeOfIssue, "");
                SetValueById("<%=rContactNo.ClientID %>", array[0].mobile, "");
                SetValueById("<%=hddCustomerId.ClientID %>", array[0].customerId, "");
                SetValueById("<%=relationType.ClientID %>", array[0].relationType, "");
                SetValueById("<%=relativeName.ClientID %>", array[0].relativeName, "");

                SetValueById("<%=rDOB.ClientID %>", array[0].dobEng, "");
                SetValueById("<%=rDOBBs.ClientID %>", array[0].dobNep, "");

                SetValueById("<%=rIdIssuedDate.ClientID %>", array[0].issueDate, "");
                SetValueById("<%=rIdIssuedDateBs.ClientID %>", array[0].issueDateNp, "");

                SetValueById("<%=rIdValidDate.ClientID %>", array[0].expiryDate, "");

                var contlNo = $("#securityNo").text();
                var l = contlNo.substring(contlNo.length - 1, contlNo.length);
                if (l != "D")
                    ShowAlternateContactForTopUp(array[0].mobile);

                ShowCustomer();

            });
        }

        function DisabledReceiverFields() {
            $('#rMembershipId').attr("readonly", true);
            $('#rFullName').attr("readonly", true);
            GetElement("<%=rIdType.ClientID %>").disabled = false;
            GetElement("<%=relationType.ClientID %>").disabled = true;
            $('#rIdNumber').attr("readonly", true);
            //GetElement("<%=hddrIdPlaceOfIssue.ClientID %>").disabled = false;

            $('#relativeName').attr("readonly", true);
            $('#alternateMobileNo').attr("readonly", true);
            $('#rBankName').attr("readonly", true);
            $('#rbankBranch').attr("readonly", true);
            $('#rBankName').attr("readonly", true);

            $('#rBankName').attr("readonly", false);
            $('#rbankBranch').attr("readonly", false);
            $('#rcheque').attr("readonly", false);
            $('#rAccountNo').attr("readonly", false);
            $('#brcheque').attr("readonly", false);
            $('#rContactNo').attr("readonly", false);
            var ischecked = $("#chkIssueCustCard").is(':checked');
            if (ischecked) {
                $('#chkIssueCustCard').attr('checked', false);
                $('.issuemember.row').hide();
                $('div.issuemember.row').hide();
                $('div.searchreceiver').show();
            }

            GetElement("<%=rOccupation.ClientID %>").disabled = false;

            GetElement("<%=chkIssueCustCard.ClientID %>").disabled = true;

        }
        function EnabledReceiverFields() {
            $('#rMembershipId').attr("readonly", false);
            $('#rFullName').attr("readonly", false);
            $('#relativeName').attr("readonly", false);
            $('#rIdNumber').attr("readonly", false);
            $('#alternateMobileNo').attr("readonly", false);
            $('#rBankName').attr("readonly", false);
            $('#rbankBranch').attr("readonly", false);
            GetElement("<%=rIdType.ClientID %>").disabled = false;
            GetElement("<%=relationType.ClientID %>").disabled = false;
            //GetElement("<%=hddrIdPlaceOfIssue.ClientID %>").disabled = false;
            $('#rBankName').attr("readonly", false);
            $('#rbankBranch').attr("readonly", false);
            $('#rcheque').attr("readonly", false);
            $('#rAccountNo').attr("readonly", false);
            $('#brcheque').attr("readonly", false);
            $('#rContactNo').attr("readonly", false);
            GetElement("<%=rOccupation.ClientID %>").disabled = false;
            GetElement("<%=chkIssueCustCard.ClientID %>").disabled = false;

        }

        function ShowAlternateContactForTopUp(contactNo) {
            $("#topupTR").hide();

            var topUpNum = contactNo.substring(0, 3);
            if (topUpNum == '980' || topUpNum == '981' || topUpNum == '982' || topUpNum == '984' || topUpNum == '986') {
                $("#topupTR").hide();
            } else {
                $("#topupTR").show();
            }
        }

        function ClearField() {
            $("#topupTR").hide();
            $("#alternateMobileNo").text();
            rowFullName.style.display = "none";
            SetValueById("<% =rFullName.ClientID%>", "", false);
            SetValueById("<% =rMembershipId.ClientID%>", "", false);
            SetValueById("<% =rContactNo.ClientID%>", "", false);
            GetElement("<% =rIdType.ClientID%>").selectedIndex = 0;

            SetValueById("<% =rIdNumber.ClientID%>", "", false);
            SetValueById("<% =hddrIdPlaceOfIssue.ClientID%>", "", false);
            SetValueById("<% =relationType.ClientID%>", "", false);
            SetValueById("<% =relativeName.ClientID%>", "", false);
            SetValueById("<% =hddMembershipId.ClientID%>", "", false);
            SetValueById("<% =hddCustomerId.ClientID%>", "", false);

            SetValueById("<% =txtCustCardId.ClientID%>", "", false);
            $('#txtCustCardId').attr("readonly", false);
            SetValueById("<% =rIdIssuedDate.ClientID%>", "", false);
            SetValueById("<% =rIdIssuedDateBs.ClientID%>", "", false);
            SetValueById("<% =rIdValidDate.ClientID%>", "", false);
            SetValueById("<% =rDOB.ClientID%>", "", false);
            SetValueById("<% =rDOBBs.ClientID%>", "", false);

            SetValueById("<% =rIdIssuedDate.ClientID%>", "", false);
            SetValueById("<% =rIdIssuedDateBs.ClientID%>", "", false);
            SetValueById("<% =rIdValidDate.ClientID%>", "", false);

            SetValueById("<% =rEmail.ClientID%>", "", false);
            SetValueById("<% =rAdd.ClientID%>", "", false);

            SetValueById("<% =hddIssueCustCardInfoSaved.ClientID%>", "", false);
            SetValueById("<% =hddIssueCustCardId.ClientID%>", "", false);

            GetElement("<% =rOccupation.ClientID%>").selectedIndex = 0;
            GetElement("<% =rGender.ClientID%>").selectedIndex = 0;

            GetElement("<% =relWithSender.ClientID%>").selectedIndex = 0;
            GetElement("<% =por.ClientID%>").selectedIndex = 0;

            GetElement("<%=chkIssueCustCard.ClientID %>").disabled = false;
            var ischecked = $("#chkIssueCustCard").is(':checked');
            if (ischecked) {
                $('#chkIssueCustCard').attr('checked', false);
                $('.issuemember.row').hide();
                $('div.issuemember.row').hide();
                $('div.searchreceiver').show();
            }

            EnabledReceiverFields();
        }

        function ShowReceiverCustomer() {
            var customerCardNumber = GetValue("<%=rMembershipId.ClientID %>");
            if (customerCardNumber == "") {
                alert("Please enter Membership Id!");
                return false;
            }
            //alert(url);

            var url = "<%=GetStatic.GetUrlRoot() %>" + "/Remit/Administration/CustomerSetup/Display.aspx?membershipId=" + customerCardNumber + "";
            PopUpWindow(url, "dialogHeight:800px;dialogWidth:1000px;dialogLeft:300;dialogTop:100;center:yes");
        }

        function ShowCustomer() {
            var customerCardNumber = GetValue("<%=rMembershipId.ClientID %>");
            if (customerCardNumber == "") {
                alert("Please enter Membership Id!");
                return false;
            }

            $(document).ready(function () {
                var mydiv = $('#mydiv');

                mydiv.dialog(
                    {
                        autoOpen: false
                        , closeOnEscape: false
                        , modal: true
                        , resizable: false
                        //, position: [50, 20]
                        , draggable: false
                        , buttons:
                        {

                            'I recommend to accept the transaction. ': function () {
                                mydiv.dialog("close");
                                DisabledReceiverFields();
                            },
                            'I recommend to reject the transaction.': function () {
                                ClearField();
                                EnabledReceiverFields();
                                mydiv.dialog("close");
                            }
                        },
                        create: function () {
                            $(".ui-dialog-buttonset").find("button").addClass("btns");
                            $(this).closest(".ui-dialog").find(".btns").eq(0).addClass("btn btn-primary btn-sm");
                            $(this).closest(".ui-dialog").find(".btns").eq(1).addClass("btn btn-danger btn-sm");
                        }
                    }
                );

                var url = "../../../Remit/Transaction/Agent/Send/Domestic/Display.aspx?membershipId=" + customerCardNumber + "";
                mydiv.load(url);

                // Open the dialog
                mydiv.dialog('open');

                return false;

            });
        }

        $('#rDOB').blur(function () {
            var CustomerDob = GetValue("<%=rDOB.ClientID %>");
            if (CustomerDob != "") {
                var CustYears = datediff(CustomerDob, 'years');

                if (parseInt(CustYears) < 16) {
                    alert('Customer age must be 16 or above !');
                    return;
                }
            }
        });
        $(function () {
            $('#chkIssueCustCard').click(function () {
                var val = $("#rIdType").val().split('|')[1];
                if ($('#chkIssueCustCard').is(':checked')) {
                    $('.issuemember.row').show();
                    $('div.issuemember.row').show();
                    $('div.searchreceiver').hide();
                    HideElement("uploadDocForCustCard");
                    $("#rIdType option[value='6208|E']").remove();

                    if (val == 'N' || val == undefined) {
                        $("#trIdExpiryDate").hide();
                        SetValueById("<%=rIdValidDate.ClientID%>", "", "");
                    }
                    else {
                        $("#trIdExpiryDate").show();
                    }

                }
                else {
                    SetValueById("<% =txtCustCardId.ClientID%>", "", false);
                    SetValueById("<% =rIdIssuedDate.ClientID%>", "", false);
                    SetValueById("<% =rIdIssuedDateBs.ClientID%>", "", false);
                    SetValueById("<% =rIdValidDate.ClientID%>", "", false);
                    SetValueById("<% =rDOB.ClientID%>", "", false);
                    SetValueById("<% =rDOBBs.ClientID%>", "", false);

                    SetValueById("<% =rEmail.ClientID%>", "", false);
                    SetValueById("<% =rAdd.ClientID%>", "", false);

                    SetValueById("<% =hddIssueCustCardInfoSaved.ClientID%>", "", false);
                    SetValueById("<% =hddIssueCustCardId.ClientID%>", "", false);

                    GetElement("<% =rOccupation.ClientID%>").selectedIndex = 0;
                    GetElement("<% =rGender.ClientID%>").selectedIndex = 0;

                    GetElement("spnCustomerEnrollMsg").innerHTML = '';
                    $('#spnCustomerEnrollMsg').removeClass(function () {
                        return $(this).attr("class");
                    });

                    $('.issuemember.row').hide();
                    $('div.issuemember.row').hide();
                    $('div.searchreceiver').show();
                    $("#rIdType").append($("<option value='6208|E'>Valid Government ID</option>"));
                    $("#trIdExpiryDate").hide();
                }
            });
        });
        function uploadCusDoc() {
            var customerId = GetValue("<%=hddIssueCustCardId.ClientID %>");
            if (customerId == "") {
                alert("Customer information has not been saved yet. Please save and re-try again.");
                return;
            }

            var url = "../../../Remit/Transaction/Agent/Send/Domestic/CustomerDocument.aspx?customerId=" + customerId;

            OpenDialog(url, 500, 820, 100, 100);
        }
        function LoadCalendars() {
            ShowCalDefault("#<% =rIdIssuedDate.ClientID%>");
            VisaValidDateSend("#<% =rIdValidDate.ClientID%>");
            CalSenderDOB("#<% =rDOB.ClientID%>");

        }
        LoadCalendars();
        function GetADVsBSDate(type, control) {
            var date = "";
            if (type == "ad" && control == "rDOB")
                date = GetValue("<%=rDOB.ClientID%>");
            else if (type == "bs" && control == "rDOBBs")
                date = GetValue("<%=rDOBBs.ClientID%>");
            else if (type == "ad" && control == "rIdIssuedDate")
                date = GetValue("<%=rIdIssuedDate.ClientID%>");
            else if (type == "bs" && control == "rIdIssuedDateBs")
                date = GetValue("<%=rIdIssuedDateBs.ClientID%>");
            else if (type == "ad" && control == "rIdValidDate")
                date = GetValue("<%=rIdValidDate.ClientID%>");

            var dataToSend = { MethodName: "getdate", date: date, type: type };
            var options =
            {
                url: '<%=ResolveUrl("Pay.aspx") %>?x=' + new Date().getTime(),
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success: function (response) {
                    //var data = jQuery.parseJSON(response);
                    var data = response;
                    if (data[0].Result == "") {
                        alert("Invalid Date.");

                        if (type == "ad" && control == "rDOB")
                            SetValueById("<%=rDOB.ClientID%>", "", "");
                        else if (type == "bs" && control == "rDOBBs")
                            SetValueById("<%=rDOBBs.ClientID%>", "", "");
                        else if (type == "ad" && control == "rIdIssuedDate")
                            SetValueById("<%=rIdIssuedDate.ClientID%>", "", "");
                        else if (type == "bs" && control == "rIdIssuedDateBs")
                            SetValueById("<%=rIdIssuedDateBs.ClientID%>", "", "");
                        else if (type == "ad" && control == "rIdValidDate")
                            SetValueById("<%=rIdValidDate.ClientID%>", "", "");

                        return;
                    }

                    if (type == "ad" && control == "rDOB")
                        SetValueById("<%=rDOBBs.ClientID %>", data[0].Result, "");
                    else if (type == "bs" && control == "rDOBBs")
                        SetValueById("<%=rDOB.ClientID %>", data[0].Result, "");
                    else if (type == "ad" && control == "rIdIssuedDate")
                        SetValueById("<%=rIdIssuedDateBs.ClientID %>", data[0].Result, "");
                    else if (type == "bs" && control == "rIdIssuedDateBs")
                        SetValueById("<%=rIdIssuedDate.ClientID %>", data[0].Result, "");

                    ValidateDate();

                },
                error: function (request, error) {
                    alert(request);
                }
            };
            $.ajax(options);
        }

        function VerifyEnrollCust() {
            var ischecked = $("#chkIssueCustCard").is(':checked');
            if (ischecked) {
                var isSaved = GetValue("<% =hddIssueCustCardInfoSaved.ClientID%>");
                var custId = GetValue("<% =hddIssueCustCardId.ClientID%>");

                if (isSaved != 'true' && custId == '') {
                    window.parent.SetMessageBox('Cannot Process Transaction. Save customer card issue information and then try again.', '1');
                    return false;
                }
                return confirm('Confirm To Pay Transaction?')
            }
            else {
                return confirm('Confirm To Pay Transaction?')
            }
            return true;

        }

        function SaveCustInfoToIssueCard() {
            var senderId = GetValue("<%=hddCustomerId.ClientID %>");
            var custId = GetValue("<%=hddIssueCustCardId.ClientID %>");
            var rMemId = GetValue("<%=txtCustCardId.ClientID %>");

            var rName = $("#<%=recName.ClientID%>").text();
            rName = $.trim(rName);
            rNameArr = rName.split(' ');

            var rFirstName = '';
            var rLastName1 = '';

            if (rNameArr.length > 0)
                rFirstName = rNameArr[0];
            if (rNameArr.length > 1) {
                for (var i = 1; i < rNameArr.length; i++) {
                    rLastName1 += rNameArr[i] + ' ';
                }
                rLastName1 = $.trim(rLastName1);
            }
            var rMiddleName = '';
            var rLastName2 = '';

            var rAddress = $('#<%=rAdd.ClientID%>').text();
            var rContactNo = GetValue("<%=rContactNo.ClientID %>");
            var rIdTypeObj = GetElement("<%=rIdType.ClientID %>");
            var rIdType = rIdTypeObj.options[rIdTypeObj.selectedIndex].value;
            var rIdNo = GetValue("<%=rIdNumber.ClientID %>");
            var recIdType = $("#rIdType").val();
            var recIdTypeArr = recIdType.split('|');
            var rEmail = GetValue("<%=rEmail.ClientID %>");
            var rIdIssuedPlace = GetValue("<%=hddrIdPlaceOfIssue.ClientID %>");

            var rIdIssuedDate = GetValue("<%=rIdIssuedDate.ClientID %>");
            var rIdValidDate = GetValue("<%=rIdValidDate.ClientID %>");
            var rDOB = GetValue("<%=rDOB.ClientID %>");

            var rIdIssuedDateBs = GetValue("<%=rIdIssuedDateBs.ClientID %>");
            var rDOBBs = GetValue("<%=rDOBBs.ClientID %>");

            var occObj = GetElement("<%=rOccupation.ClientID %>");
            var occ = occObj.options[occObj.selectedIndex].value;
            var rGender = GetValue("<%=rGender.ClientID %>");
            var relationType = GetValue("<%=relationType.ClientID %>");
            var relativeName = GetValue("<%=relativeName.ClientID %>");

            if (rMemId == "") {
                alert('Customer Card Id should not be blank.');
                return;
            }
            if (rIdType == "") {
                alert('Please select customer Id type.');
                return;
            }
            if (rIdNo == "") {
                alert('Customer Id no. should not be blank.');
                return;
            }
            if (rFirstName == "") {
                alert('Customer name should not be blank.');
                return;
            }
            if (rContactNo == "") {
                alert('Customer contact no. should not be blank.');
                return;
            }
            if (rDOB == "") {
                alert('Customer D.O.B should not be blank.');
                return;
            }
            /*

            if (rIdIssuedDate == "") {
                alert('Customer ID issued date should not be blank.');
                return;
            }

            if (recIdTypeArr[1] == "E") {
                if (rIdValidDate == "") {
                    alert('Customer ID expired date should not be blank.');
                    return;
                }
            }

            */

            if (rAddress == "") {
                alert('Customer address should not be blank.');
                return;
            }
            if (rGender == "") {
                alert('Please select customer gender.');
                return;
            }
            if (relationType == "") {
                alert('Please select customer relation type.');
                return;
            }
            //if (relativeName == "") {
            //    alert('Parent/Spouse name should not be blank.');
            //    return;
            //}
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
                , senderId: senderId, cMemId: rMemId, cFirstName: rFirstName, cMiddleName: rMiddleName, cLastName1: rLastName1, cLastName2: rLastName2
                , cAddress: rAddress, cContactNo: rContactNo, cIdType: recIdTypeArr[0], cIdNo: rIdNo, cIdIssuedPlace: rIdIssuedPlace, cIdIssuedDate: rIdIssuedDate
                , cEmail: rEmail, cOccupation: occ
                , cGender: rGender, cDOB: rDOB, cIdValidDate: rIdValidDate, cRelationType: relationType
                , cRelativeName: relativeName, type: 'issuecard', custId: custId, cIdIssuedDateBs: rIdIssuedDateBs, cDOBBs: rDOBBs, cIdValidDateBs: ''
            };
            var options =
            {
                url: '<%=ResolveUrl("Pay.aspx") %>?x=' + new Date().getTime(),
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                async: false,
                beforeSend: function () {
                    $("#DivLoad").show();
                },
                success: function (response) {
                    //var data = jQuery.parseJSON(response);
                    var data = response;
                    if (data[0].errorCode == "0") {
                        window.parent.SetMessageBox(data[0].msg, "0");
                        GetElement("spnCustomerEnrollMsg").innerHTML = data[0].msg;
                        $('#spnCustomerEnrollMsg').addClass('SuccessMsg');
                        $('#txtCustCardId').attr("readonly", true);
                        GetElement("<%=chkIssueCustCard.ClientID %>").disabled = true;
                        SetValueById("<%=hddIssueCustCardInfoSaved.ClientID %>", "true", "");
                        SetValueById("<%=hddIssueCustCardId.ClientID %>", data[0].id, "");
                        SetValueById("<%=hddCustomerId.ClientID %>", data[0].id, "");
                        SetValueById("<%=hddMembershipId.ClientID %>", rMemId, "");
                        ShowElement("uploadDocForCustCard");
                    }
                    else {
                        window.parent.SetMessageBox(data[0].msg, "1");
                        GetElement("spnCustomerEnrollMsg").innerHTML = data[0].msg;
                        $('#spnCustomerEnrollMsg').addClass('ErrorAlert');
                        SetValueById("<%=hddIssueCustCardInfoSaved.ClientID %>", "false", "");
                        SetValueById("<%=hddIssueCustCardId.ClientID %>", "", "");
                        SetValueById("<%=hddCustomerId.ClientID %>", "", "");
                        SetValueById("<%=hddMembershipId.ClientID %>", "", "");
                        HideElement("uploadDocForCustCard");
                    }
                },
                error: function (xhr) { // if error occured
                    alert("Error occured." + xhr.statusText + xhr.responseText);
                },
                complete: function () {
                    $("#DivLoad").hide();
                }
            };
            $.ajax(options);

        }

        function ValidateDate() {
            try {
                var dateDOBValue = GetValue("<%=rDOB.ClientID%>");
                var issuedateValue = GetValue("<%=rIdIssuedDate.ClientID%>");
                var expiryDateValue = GetValue("<%=rIdValidDate.ClientID%>");

                var dateDOBValueBs = GetValue("<%=rDOBBs.ClientID%>");
                var issuedateValueBs = GetValue("<%=rIdIssuedDateBs.ClientID%>");

                var current = new Date();
                var currentYear = current.getFullYear();

                if (dateDOBValue != '') {
                    var dt = new Date(dateDOBValue);
                    var birthYear = dt.getFullYear();

                    if ((currentYear - birthYear) < 16) {
                        alert('Receiver needs to be at least 16 years old in order to receive money.');
                        SetValueById("<%=rDOB.ClientID %>", "", "");
                        SetValueById("<%=rDOBBs.ClientID%>", "", "");
                        return false;
                    }

                    if (dt >= current) {
                        alert('Receiver needs to be at least 16 years old in order to receive money.');
                        SetValueById("<%=rDOB.ClientID %>", "", "");
                        SetValueById("<%=rDOBBs.ClientID%>", "", "");
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
                        SetValueById("<%=rDOBBs.ClientID%>", "", "");
                        SetValueById("<%=rDOB.ClientID %>", "", "");
                        return false;
                    }

                    if (dateDOBValueBsArr.length == 3) {
                        var bsDD = dateDOBValueBsArr[1];
                        var bsMM = dateDOBValueBsArr[0];
                        var bsYear = dateDOBValueBsArr[2];

                        if ((bsDD.length == 0 || bsDD.length > 2) || (bsMM.length == 0 || bsMM.length > 2) || (bsYear.length != 4)) {
                            alert('Invalid date format for DOB BS. Date should be in MM/DD/YYYY format.');
                            SetValueById("<%=rDOBBs.ClientID%>", "", "");
                            SetValueById("<%=rDOB.ClientID %>", "", "");
                            return false;
                        }

                    }
                    else {
                        alert('Invalid date format for DOB BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=rDOBBs.ClientID%>", "", "");
                        SetValueById("<%=rDOB.ClientID %>", "", "");
                        return false;
                    }

                }

                if (issuedateValue != '') {
                    var dtIssue = new Date(issuedateValue);
                    if (dtIssue > current) {
                        alert('ID Issued date cannot be future date. Please enter valid ID Issued date.');
                        SetValueById("<%=rIdIssuedDate.ClientID %>", "", "");
                        SetValueById("<%=rIdIssuedDateBs.ClientID %>", "", "");
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
                        SetValueById("<%=rIdIssuedDate.ClientID %>", "", "");
                        SetValueById("<%=rIdIssuedDateBs.ClientID %>", "", "");
                        return false;
                    }

                    if (dateValueBsArr.length == 3) {
                        var bsDD = dateValueBsArr[1];
                        var bsMM = dateValueBsArr[0];
                        var bsYear = dateValueBsArr[2];

                        if ((bsDD.length == 0 || bsDD.length > 2) || (bsMM.length == 0 || bsMM.length > 2) || (bsYear.length != 4)) {
                            alert('Invalid date format for ID Issued Date BS. Date should be in MM/DD/YYYY format.');
                            SetValueById("<%=rIdIssuedDate.ClientID %>", "", "");
                            SetValueById("<%=rIdIssuedDateBs.ClientID %>", "", "");
                            return false;
                        }

                    }
                    else {
                        alert('Invalid date format for ID Issued Date BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=rIdIssuedDate.ClientID %>", "", "");
                        SetValueById("<%=rIdIssuedDateBs.ClientID %>", "", "");
                        return false;
                    }
                }

                if (expiryDateValue != '') {
                    var dtExpiry = new Date(expiryDateValue);
                    if (dtExpiry < current) {
                        alert('ID Expiry date cannot be past date. Please enter valid ID Expiry date.');
                        SetValueById("<%=rIdValidDate.ClientID %>", "", "");
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
                        SetValueById("<%=rIdValidDate.ClientID %>", "", "");
                        return false;
                    }

                    if (dateValueBsArr.length == 3) {
                        var bsDD = dateValueBsArr[1];
                        var bsMM = dateValueBsArr[0];
                        var bsYear = dateValueBsArr[2];

                        if ((bsDD.length == 0 || bsDD.length > 2) || (bsMM.length == 0 || bsMM.length > 2) || (bsYear.length != 4)) {
                            alert('Invalid date format for ID Expiry Date BS. Date should be in MM/DD/YYYY format.');
                            SetValueById("<%=rIdValidDate.ClientID %>", "", "");
                            return false;
                        }
                    }
                    else {
                        alert('Invalid date format for ID Expiry Date BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=rIdValidDate.ClientID %>", "", "");
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

        function FilterIdIssuedPlace() {
            Loading('show');
            var rIdType = $("#rIdType").val();
            var rIdTypeArr = rIdType.split('|');

            var dataToSend = { MethodName: "idissuedplace", IdType: rIdTypeArr[0] };
            var options = {
                url: '<%=ResolveUrl("Pay.aspx") %>?x=' + new Date().getTime(),
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success: function (response) {
                    // var data = jQuery.parseJSON(response);
                    var data = response;
                    $("#rIdPlaceOfIssue").empty();

                    $("#rIdPlaceOfIssue").append($("<option></option>").val('').html('Select'));

                    $.each(data, function (key, value) {
                        $("#rIdPlaceOfIssue").append($("<option></option>").val(value.valueId).html(value.detailTitle));
                    });

                    SetIDTypeIssuedPlace();
                }
            };
            $.ajax(options);
            Loading('hide');
        }

        <%--$(function () {
            $('#rIdPlaceOfIssue').change(function () {
                var IdIssuedPlaceSelected = $("#rIdPlaceOfIssue").val();
                SetValueById("<%=hddrIdPlaceOfIssue.ClientID %>", IdIssuedPlaceSelected, "");
                SetIDTypeIssuedPlace();
            });
        });--%>

        function SetIDTypeIssuedPlace() {
            var IdIssuedPlace = GetValue("<% =hddrIdPlaceOfIssue.ClientID%>");
            SetDDlByText("rIdPlaceOfIssue", IdIssuedPlace, "");
        }
        function SetDDlByText(ddl, val) {

            $("#" + ddl + " option").each(function () {
                this.selected = $(this).text() == val;
            });
        }

        function chequeNoValidation() {
            try {
                var chequeNo = GetValue("<%=rcheque.ClientID %>").trim()

                if (chequeNo == "")
                    return;

                if (!checkIfValidChars(chequeNo)) {

                    SetValueById("<% =rcheque.ClientID%>", "", "");
                    GetElement("<%=rcheque.ClientID %>").focus();
                    return;
                }

                if (!checkIfFistCharIsValid(chequeNo.substring(0, 1))) {
                    SetValueById("<% =rcheque.ClientID%>", "", "");
                    GetElement("<%=rcheque.ClientID %>").focus();
                    return;
                }
                if (!checkIfAllCharIsSame(chequeNo)) {
                    SetValueById("<% =rcheque.ClientID%>", "", "");
                    GetElement("<%=rcheque.ClientID %>").focus();
                    return;
                }
                if (!checkIfCharsRepeated(chequeNo)) {
                    SetValueById("<% =rcheque.ClientID%>", "", "");
                    GetElement("<%=rcheque.ClientID %>").focus();
                    return;
                }
            }
            catch (err) {
            }

        }
    </script>
    <style type="text/css">
        .redLabel {
            font-size: 7pt;
            color: #FF0000;
        }

        .error {
            color: Red;
            font-weight: bold;
        }

        legend {
            font: 17px/21px Calibri, Arial, Helvetica, sans-serif;
            padding: 2px;
            font-weight: bold;
            font-family: Verdana, Arial;
            font-size: 12px;
            padding: 1px;
            margin-left: 2em;
        }

        .head {
            color: #FFFFFF;
            background: #FF0000;
            padding: 2px;
            border-radius: 2px;
        }

        input.error {
            border-style: solid;
            border-width: 1px;
            background-color: #FFD9D9;
        }

        select.error {
            border-style: solid;
            border-width: 1px;
            background-color: #FFD9D9;
        }

        .disabled {
            background: #EFEFEF !important;
            color: #666666 !important;
        }

        label {
            float: left;
        }

            label.error {
                float: none;
                color: red;
                vertical-align: top;
                font-size: 10px;
                font-family: Verdana;
                font-weight: bold;
            }

        .inv {
            float: none;
            color: red;
            vertical-align: top;
            font-size: 10px;
            font-family: Verdana;
            font-weight: bold;
        }

        .hide {
            display: none;
        }

        .ui-button {
            color: Red !important;
            font-weight: bold !important;
            font-size: 10px !important;
        }

            .ui-button:first-child {
                color: Green !important;
            }

        .ui-dialog {
            width: 900px !important;
            height: 100%;
            opacity: 1;
            z-index: 999;
            top: 0px;
            left: 0;
        }

        .ui-dialog-titlebar-close {
            visibility: hidden !important;
        }

        .SuccessMsg {
            border: 1px solid;
            margin: 10px 0px;
            padding: 2px 2px 2px 30px;
            background-repeat: no-repeat;
            background-position: 10px center;
            background-image: url("../../../images/true.png");
            color: #4F8A10;
            background-color: #DFF2BF;
            font-size: 13px;
        }

        .ErrorAlert {
            border: 1px solid;
            margin: 10px 0px;
            padding: 2px 2px 2px 30px;
            background-repeat: no-repeat;
            background-position: 10px center;
            background-image: url("../../../images/exclamation.png");
            color: #D8000C;
            background-color: #FFBABA;
            font-size: 13px;
        }

        legend {
            background: red !important;
            color: white;
            margin-bottom: 0 !important;
            font-family: Verdana, Arial;
            font-size: 12px;
            margin-right: 2px;
            padding-bottom: 0px !important;
        }

        fieldset {
            padding: 10px !important;
            margin: 5px !important;
            border: 1px solid rgba(158, 158, 158, 0.21) !important;
        }

        .amount {
            color: #17010f !important;
        }

        .table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
            line-height: 1.6 !important;
        }

        .table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
            padding: 1px !important;
        }

        label {
            margin-bottom: 0 !important;
        }

        .formTable tr td input, select {
            height: 27px !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" ID="sm"></asp:ScriptManager>
        <div class="page-wrapper">
            <div id="DivLoad" style="position: absolute; height: 20px; width: 220px; background-color: #333333; display: none; left: 185px; top: 135px;">
                <img src="../../../images/progressBar.gif" border="0" alt="Loading..." />
            </div>
            <div id="divTxnPanel" runat="server">
                <div class="row">
                    <fieldset>
                        <legend>Transaction Information<span style="float: right; margin-right: 50px"><%= Swift.web.Library.GetStatic.ReadWebConfig("tranNoName","") %>:
                                <asp:Label runat="server" ID="securityNo" CssClass="amount"></asp:Label></span></legend>
                        <div class="col-md-6">
                            <table class="table table-responsive table-striped table-bordered">
                                <tr>
                                    <td>Sending Country: </td>
                                    <td>
                                        <asp:Label runat="server" ID="sendingCountry"></asp:Label></td>
                                </tr>
                                <tr>
                                    <td>Sending Agent: </td>
                                    <td>
                                        <asp:Label runat="server" ID="sendingAgent" ForeColor="Red" BackColor="White"></asp:Label></td>
                                </tr>
                                <tr>
                                    <td>TXN Date:</td>
                                    <td>
                                        <asp:Label runat="server" ID="transactionDate"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div class="col-md-6">
                            <table class="table table-responsive table-striped table-bordered">
                                <tr>
                                    <td>Payout Amount:
                                    </td>
                                    <td>
                                        <asp:Label ID="payoutAmount" runat="server" CssClass="amount" BackColor="yellow"></asp:Label>
                                        <asp:Label ID="payoutCurr" runat="server" BackColor="yellow"></asp:Label>
                                        (<asp:Label runat="server" ID="amtToWords" BackColor="yellow"></asp:Label>)
                                    </td>
                                </tr>
                                <tr>
                                    <td>Paying Agent :
                                    </td>
                                    <td>
                                        <asp:Label ID="lblBranchName" runat="server" ForeColor="Red" BackColor="White"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Payment Mode:
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="paymentMode"></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </fieldset>
                </div>

                <div class="row">
                    <div class="col-sm-6">
                        <fieldset>
                            <legend>Sender Information</legend>
                            <table class="table table-responsive table-striped table-bordered">
                                <tr>
                                    <td>Name:</td>
                                    <td>
                                        <asp:Label runat="server" ID="senderName"></asp:Label></td>
                                </tr>
                                <tr>
                                    <td>Address:</td>
                                    <td>
                                        <asp:Label runat="server" ID="senderAddress"></asp:Label></td>
                                </tr>
                                <tr>
                                    <td>Country:</td>
                                    <td>
                                        <asp:Label runat="server" ID="senderCountry"></asp:Label></td>
                                </tr>
                                <tr>
                                    <div id="trSenCity" runat="server">
                                        <td>City:</td>
                                        <td>
                                            <asp:Label runat="server" ID="senderCity"></asp:Label></td>
                                    </div>
                                </tr>
                                <tr>
                                    <td>Contact No:</td>
                                    <td>
                                        <asp:Label runat="server" ID="senderContactNo"></asp:Label></td>
                                </tr>
                                <tr>
                                    <div class="row" id="trIdType" runat="server">
                                        <td>
                                            <asp:Label runat="server" ID="senIdType"></asp:Label></td>
                                        <td>
                                            <asp:Label runat="server" ID="senIdNo"></asp:Label></td>
                                    </div>
                                </tr>
                                <tr>
                                    <div id="trMsg" runat="server">
                                        <td>Message:</td>
                                        <td>
                                            <asp:Label runat="server" ID="message"></asp:Label></td>
                                    </div>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div class="col-sm-6">

                        <fieldset>
                            <legend>Receiver Information</legend>
                            <table class="table table-responsive table-striped table-bordered">
                                <tr>
                                    <td>Name:</td>
                                    <td>
                                        <asp:Label runat="server" ID="recName"></asp:Label></td>
                                </tr>
                                <tr>
                                    <td>Address:</td>
                                    <td>
                                        <asp:Label runat="server" ID="recAddress"></asp:Label></td>
                                </tr>
                                <tr>
                                    <div id="trRecCountry" runat="server">
                                        <td>Country:</td>
                                        <td>
                                            <asp:Label runat="server" ID="recCountry"></asp:Label></td>
                                    </div>
                                </tr>
                                <tr>
                                    <div id="trRecCity" runat="server">
                                        <td>City:</td>
                                        <td>
                                            <asp:Label runat="server" ID="recCity"></asp:Label></td>
                                    </div>
                                </tr>
                                <tr>
                                    <div id="trRecContactNo" runat="server">
                                        <td>Contact No:</td>
                                        <td>
                                            <asp:Label runat="server" ID="recContactNo"></asp:Label></td>
                                    </div>
                                </tr>
                                <tr>
                                    <div class="row" id="trRecIdType" runat="server">
                                        <td>
                                            <asp:Label runat="server" ID="recIdType" Text="Id No"></asp:Label>
                                        </td>
                                        <td>
                                            <asp:Label runat="server" ID="recIdNo"></asp:Label>
                                        </td>
                                    </div>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                </div>
                <div class="row" style="display: none">
                    <div class="col-sm-12">
                        <div class="pull-right">
                            <asp:CheckBox ID="chkIssueCustCard" Text="Issue Customer Card" runat="server" />
                        </div>
                    </div>
                </div>

                <div class="row" style="display: none;">
                    <div class="form-group">
                        <div class="searchreceiver">
                            <div class="col-sm-2">
                                <b>Membership ID</b>
                            </div>
                            <br />
                            <div class="col-sm-8 form-inline">
                                <asp:TextBox runat="server" ID="rMembershipId" CssClass="form-control" Width="34%" Text=""></asp:TextBox>
                                <input type="button" class="btn btn-primary btn-sm" value="Find" onclick="PickReceiver();" />
                                <input type="button" class="btn btn-primary btn-sm" value="Clear Field" onclick="ClearField();" />
                                <input type="button" class="btn btn-primary btn-sm" value="View Customer" onclick="ShowReceiverCustomer();" />
                            </div>
                        </div>
                    </div>
                    <div class="issuemember row col-sm-8">
                        <div class="form-group">
                            <b>Card No</b><span class="errormsg">*</span>
                            <asp:TextBox runat="server" ID="txtCustCardId" MaxLength="8" CssClass="form-control" Width="35%"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div runat="server" id="otherAgentType" visible="false">
                    <fieldset>
                        <legend>Additional Confirmation Fields</legend>
                        <div class="col-sm-3">
                            <label style="background: yellow;">Bank Name: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="rBankName"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <br />
                            <asp:DropDownList ID="rBankName" runat="server" CssClass="form-control" Width="100%">
                            </asp:DropDownList>
                        </div>
                        <div class="col-sm-3">
                            <label style="background: yellow;">Bank Branch Name:<span class="errormsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ControlToValidate="rbankBranch"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator><br />
                            <asp:TextBox CssClass="form-control" ID="rbankBranch" runat="server" Width="100%"></asp:TextBox>
                        </div>
                        <div class="col-sm-3">
                            <label style="background: yellow;">Account No./Cheque No.: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator9" runat="server" ControlToValidate="rcheque"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator><br />
                            <asp:TextBox Width="100%" CssClass="form-control" ID="rcheque" onBlur="chequeNoValidation();" runat="server"></asp:TextBox>
                        </div>
                    </fieldset>
                </div>
                <fieldset>
                    <legend>Receiver Information - Payment</legend>
                    <span id="rowFullName" runat="server" style="display: none;"><b>Receiver Full Name</b><br />
                        <asp:TextBox ID="rFullName" runat="server" CssClass="form-control" />
                    </span>
                    <div class="clearfix"></div>
                    <div class="col-md-12">
                        <div class="col-sm-2">
                            <label style="background: yellow;">Receiver ID Type: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="rIdType"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <br />
                            <asp:DropDownList ID="rIdType" runat="server" Style="width: 100%; height: 30px;">
                            </asp:DropDownList>
                        </div>
                        <div class="col-sm-2">
                            <label style="background: yellow;">Receiver ID Number: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="rIdNumber"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <br />
                            <asp:TextBox Style="width: 100%; height: 30px;" ID="rIdNumber" runat="server" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);" onchange="IdNoValidation(this)"></asp:TextBox>
                        </div>
                        <div class="col-sm-2">
                            <label style="background: yellow;">ID Issued Date<span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator12" runat="server" ControlToValidate="rIdIssuedDate"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red" Enabled="false" Visible="false"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <asp:TextBox ID="rIdIssuedDate" runat="server" CssClass="required" Style="width: 100%; height: 30px;"></asp:TextBox>
                        </div>
                        <div class="col-sm-2" style="display: none">
                            <label style="background: yellow;">ID Issued Date (B.S)<span class="ErrMsg">*</span></label>
                            <asp:TextBox ID="rIdIssuedDateBs" runat="server" Width="100%" placeholder="mm/dd/yyyy"></asp:TextBox>
                        </div>
                        <div class="col-sm-2 trIdExpiryDate">
                            <label style="background: yellow;">ID Expiry Date<span class="ErrMsg">*</span></label>
                            <asp:TextBox ID="rIdValidDate" runat="server" CssClass="required" Style="width: 100%; height: 30px;"></asp:TextBox>
                        </div>
                        <%--<div class="col-sm-4" style="display: none">
                            <label style="background: yellow;">Place Of Issue (District)<span class="ErrMsg">*</span></label>
                            <select id="rId" class="required" style="width: 100%">
                            </select>
                        </div>--%>
                        <%--<div class="col-sm-2">
                            <label style="background: yellow;">Country Name: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator15" runat="server" ControlToValidate="BenCountry"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <br />
                            <asp:DropDownList runat="server" ID="BenCountry" CssClass="required" Style="width: 100%; height: 30px;" />
                        </div>--%>
                        <div class="col-sm-2">
                            <label style="background: yellow;">Nationality: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="recNationality"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <br />
                            <asp:DropDownList runat="server" ID="recNationality" Style="width: 100%; height: 30px;" />
                        </div>
                        <div class="col-sm-2">
                            <label style="background: yellow;">Place Of Issue (Country)<span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator16" runat="server" ControlToValidate="rIdPlaceOfIssue"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <asp:DropDownList runat="server" ID="rIdPlaceOfIssue" CssClass="required" Style="width: 100%; height: 30px;" />
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="col-sm-2">
                            <label style="background: yellow;">Relationship with sender: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="relWithSender"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <br />
                            <asp:DropDownList ID="relWithSender" runat="server" CssClass="requiredField" Style="width: 100%; height: 30px;">
                            </asp:DropDownList>
                        </div>
                        <div class="col-sm-2">
                            <label style="background: yellow;">Purpose of Remittance: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator10" runat="server" ControlToValidate="por"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <br />
                            <asp:DropDownList runat="server" ID="por" Style="width: 100%; height: 35px;" />
                        </div>
                        <div class="col-sm-2">
                            <label style="background: yellow;">Occupation: <span class="ErrMsg">*</span></label>
                            <asp:DropDownList ID="rOccupation" runat="server" Style="width: 100%; height: 30px">
                            </asp:DropDownList>
                        </div>
                        <div class="col-sm-2">
                            <label style="background: yellow;">Gender : <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator17" runat="server" ControlToValidate="receiverGenderDDL"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <asp:DropDownList ID="receiverGenderDDL" runat="server" Style="width: 100%; height: 30px !important;">
                                <asp:ListItem Text="Select" Value=""></asp:ListItem>
                                <asp:ListItem Text="Male" Value="M"></asp:ListItem>
                                <asp:ListItem Text="Female" Value="F"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-sm-2">
                            <label style="background: yellow;">Contact No.: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="rContactNo"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <asp:TextBox ID="rContactNo" runat="server" Style="width: 100%; height: 30px;" onchange="ContactNoValidation(this)" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"></asp:TextBox>
                        </div>
                        <div class="col-sm-2">
                            <label style="background: yellow;">Address: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator11" runat="server" ControlToValidate="rAdd"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <br />
                            <asp:TextBox ID="rAdd" runat="server" Width="100%" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="col-sm-3">
                            <label style="background: yellow;">City: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator13" runat="server" ControlToValidate="BeneCity"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <br />
                            <asp:TextBox ID="BeneCity" runat="server" Width="100%" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-sm-6">
                            <label>Are you or any member of your family or relative Politically Exposed Persons (PEP)? :</label>
                            <asp:DropDownList ID="ddlPEP" runat="server" Style="width: 100%; height: 30px;">
                                <asp:ListItem Text="Select" Value=""></asp:ListItem>
                                <asp:ListItem Text="YES" Value="YES"></asp:ListItem>
                                <asp:ListItem Selected="True" Text="NO" Value="NO"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-sm-3">
                            <label>&nbsp;</label><br />
                            <asp:Button ID="btnPay" runat="server" CssClass="btn btn-primary" Text="Pay Transaction" OnClientClick="if (!VerifyEnrollCust()) return false;" ValidationGroup="pay"
                                OnClick="btnPay_Click" />
                            <asp:Button ID="BtnBack" runat="server" Text=" Back " class="cancel btn btn-primary" OnClick="BtnBack_Click" />
                        </div>
                    </div>
                    <div class="col-md-12">

                        <div class="col-sm-3" style="display: none;">
                            Parent/Spouse:
                            <br />
                            <asp:DropDownList ID="relationType" runat="server" CssClass="form-control" Width="100%">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-sm-3" style="display: none;">
                        Parent/Spouse Name:
                        <asp:TextBox CssClass="form-control" ID="relativeName" runat="server" onkeypress="return onlyAlphabets(event,this);" Width="100%"></asp:TextBox>
                    </div>
                </fieldset>
                <div id="rptLog" runat="server" style="display: none"></div>
                <div class="row" id="topupTR">
                    <div class="col-sm-3">
                        Alternate Mobile No.:
                                        <asp:TextBox ID="alternateMobileNo" runat="server" Width="100%" CssClass="form-control" onchange="ContactNoValidation(this)"
                                            onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"></asp:TextBox>
                        <span style="background-color: Yellow; color: red; font-weight: bold; font-size: 12px;">(Note: Only NTC Prepaid/Ncell for free topup)</span>
                    </div>
                </div>

                <div runat="server" id="bankAndFinanceType" visible="false">
                    <fieldset>
                        <legend>Additional Confirmation Fields</legend>
                        <div class="col-sm-3">
                            <label style="background: yellow;">Account No.:<span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator14" runat="server" ControlToValidate="rAccountNo"
                                Display="Dynamic" ErrorMessage="Required!" ForeColor="Red" ValidationGroup="pay"
                                SetFocusOnError="True"></asp:RequiredFieldValidator><br />
                            <asp:TextBox CssClass="form-control" ID="rAccountNo" runat="server" Width="100%"></asp:TextBox>
                        </div>
                        <div class="col-sm-3">
                            <label style="background: yellow;">Cheque No.:<span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="brcheque"
                                Display="Dynamic" ErrorMessage="Required!" ForeColor="Red" ValidationGroup="pay"
                                SetFocusOnError="True"></asp:RequiredFieldValidator><br />
                            <asp:TextBox CssClass="form-control" ID="TextBox1" runat="server" Width="100%"></asp:TextBox>
                            <br />
                            <asp:TextBox runat="server" ID="brcheque" Width="100%"></asp:TextBox>
                        </div>
                    </fieldset>
                </div>

                <div class="row" style="display: none;">
                    <div class="col-sm-3">
                        <label style="background: yellow;">DOB: <span class="ErrMsg">*</span></label>

                        <%--<asp:RequiredFieldValidator ID="RequiredFieldValidator11" runat="server" ControlToValidate="rDOB"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                            SetFocusOnError="True"></asp:RequiredFieldValidator>--%>
                        <asp:TextBox ID="rDOB" runat="server" CssClass="form-control" Width="100%"></asp:TextBox>
                    </div>
                    <div class="col-sm-3">
                        DOB (B.S)
                                        <asp:TextBox ID="rDOBBs" runat="server" CssClass="form-control" Width="100%"></asp:TextBox>
                        <span class="redLabel"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                    </div>
                </div>
                <div class="issuemember row">
                    <div class="col-sm-3">
                        Email
                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator6" runat="server" ValidationGroup="payTran"
                                        ControlToValidate="rEmail" ErrorMessage="Invalid Email!" SetFocusOnError="True"
                                        ForeColor="Red" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"> </asp:RegularExpressionValidator>
                        <asp:TextBox ID="rEmail" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="issuemember row">

                    <div class="col-sm-3">
                        Gender<span class="ErrMsg">*</span>
                        <asp:DropDownList ID="rGender" runat="server" CssClass="form-control" Width="100%">
                        </asp:DropDownList>
                    </div>
                </div>
                <br />
                <div class="issuemember row">

                    <div class="col-sm-6">
                        <input type="button" class="btn btn-primary" id="issueCustCard" value="Save Information" onclick="SaveCustInfoToIssueCard();" />
                        <input type="button" class="btn btn-primary" id="uploadDocForCustCard" onclick="uploadCusDoc();" value="Upload Document" />
                    </div>
                </div>
                <br />
                <div class="issuemember row">
                    <div class="col-sm-12">
                        <span id="spnCustomerEnrollMsg" style="display: block;"></span>
                    </div>
                </div>
            </div>
            <div id="mydiv" title="Customer Information">
            </div>
        </div>
        <asp:HiddenField ID="hddCeTxn" runat="server" />
        <asp:HiddenField ID="hddRowId" runat="server" />
        <asp:HiddenField ID="hddControlNo" runat="server" />
        <asp:HiddenField ID="hddTokenId" runat="server" />
        <asp:HiddenField ID="hddSCountry" runat="server" />
        <asp:HiddenField ID="hddPayAmt" runat="server" />
        <asp:HiddenField ID="hddAgentName" runat="server" />
        <asp:HiddenField ID="hddOrderNo" runat="server" />
        <asp:HiddenField ID="hddRCurrency" runat="server" />
        <asp:HiddenField ID="hdnMapCode" runat="server" />
        <asp:HiddenField ID="hdnTranType" runat="server" />
        <asp:HiddenField ID="hddCustomerId" runat="server" />
        <asp:HiddenField ID="hddMembershipId" runat="server" />
        <asp:HiddenField ID="hddOriginalAmt" runat="server" />
        <asp:HiddenField ID="hddagentgroup" runat="server" />
        <asp:HiddenField ID="hddchequenumber" runat="server" />
        <asp:HiddenField ID="hddIssueCustCardInfoSaved" runat="server" />
        <asp:HiddenField ID="hddIssueCustCardId" runat="server" />
        <asp:HiddenField ID="hddIdType" runat="server" />
        <asp:HiddenField ID="hddrIdPlaceOfIssue" runat="server" />
        <asp:HiddenField ID="hddrelationType" runat="server" />
        <asp:HiddenField ID="hiddenSubPartnerId" runat="server" />
        <asp:HiddenField ID="benefCityId" runat="server" />
        <asp:HiddenField ID="benefStateId" runat="server" />
        <asp:HiddenField ID="refNo" runat="server" />
    </form>
</body>
</html>