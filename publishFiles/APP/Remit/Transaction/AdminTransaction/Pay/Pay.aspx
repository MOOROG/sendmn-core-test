<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Pay.aspx.cs" Inherits="Swift.web.Remit.Transaction.PayTransaction.Pay" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <title></title>
    <link href="/css/style.css" rel="stylesheet" type="text/css" />
    <link href="css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>

    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/ui/js/metisMenu.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="/ui/js/custom.js"></script>

    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            $.ajaxSetup({ cache: false });

            $("#<%=rIdType.ClientID %>").change(function () {
                var val = $(this).val().split('|')[1];
                if (val == 'N' || val == undefined) {
                    $("#trIdExpiryDate").hide();
                    SetValueById("<%=rIdValidDate.ClientID%>", "", "");

                    $('.trIdExpiryDate').hide();

                    $('#rIdValidDate').removeClass("required");
                }
                else {
                    $(".trIdExpiryDate").show();
                    $('#rIdValidDate').addClass("required");
                }
                //FilterIdIssuedPlace();
            });
            //FilterIdIssuedPlace();

        });

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
        function LoadCalendars() {
            ShowCalDefault("#<%=rIdIssuedDate.ClientID%>");
            VisaValidDateSend("#<% =rIdValidDate.ClientID%>");
            CalSenderDOB("#<% =rDOB.ClientID%>");
        }
        LoadCalendars();
        function GetADVsBSDate(type, control) {
            var date = "";
            if (type == "ad" && control == "rDOB")
                date = GetValue("<%=rDOB.ClientID%>");
            else if (type == "ad" && control == "rIdIssuedDate")
                date = GetValue("<%=rIdIssuedDate.ClientID%>");
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
                    var data = jQuery.parseJSON(response);
                    if (data[0].Result == "") {
                        alert("Invalid Date.");

                        if (type == "ad" && control == "rDOB")
                            SetValueById("<%=rDOB.ClientID%>", "", "");
                        else if (type == "bs" && control == "rDOBBs")
                            SetValueById("<%=rDOBBs.ClientID%>", "", "");
                        else if (type == "ad" && control == "rIdIssuedDate")
                            SetValueById("<%=rIdIssuedDate.ClientID%>", "", "");
                        else if (type == "ad" && control == "rIdValidDate")
                            SetValueById("<%=rIdValidDate.ClientID%>", "", "");

                        return;
                    }

                    if (type == "ad" && control == "rDOB")
                        SetValueById("<%=rDOBBs.ClientID %>", data[0].Result, "");
                    else if (type == "bs" && control == "rDOBBs")
                        SetValueById("<%=rDOB.ClientID %>", data[0].Result, "");

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
                var dateDOBValue = GetValue("<%=rDOB.ClientID%>");
                var issuedateValue = GetValue("<%=rIdIssuedDate.ClientID%>");
                var expiryDateValue = GetValue("<%=rIdValidDate.ClientID%>");

                var current = new Date();
                var currentYear = current.getFullYear();

                if (dateDOBValue != '') {
                    var dt = new Date(dateDOBValue);
                    var birthYear = dt.getFullYear();

                    if ((currentYear - birthYear) < 16) {
                        alert('Receiver needs to be at least 16 years old in order to receive money.');
                        SetValueById("<%=rDOB.ClientID %>", "", "");
                        return false;
                    }

                    if (dt >= current) {
                        alert('Receiver needs to be at least 16 years old in order to receive money.');
                        SetValueById("<%=rDOB.ClientID %>", "", "");
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
                            return false;
                        }

                    }
                    else {
                        alert('Invalid date format for ID Issued Date BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=rIdIssuedDate.ClientID %>", "", "");
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
                    var data = jQuery.parseJSON(response);
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
    </script>
    <style type="text/css">
        .redLabel {
            font-size: 7px;
            color: #FF0000;
            line-height: 10px !important;
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

        legend {
            background-color: red !important;
            color: white !important;
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
            line-height: 1.1 !important;
        }

        .table > tbody > tr > td, .table > tbody > tr > th, .table > tfoot > tr > td, .table > tfoot > tr > th, .table > thead > tr > td, .table > thead > tr > th {
            padding: 4px !important;
        }

        label {
            margin-bottom: 0 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
        <div class="">
            <div class="row">
                <div class="panel panel-default">
                    <div id="divTxnPanel" runat="server">
                        <div class="row">
                            <fieldset>
                                <legend>Transaction Information<span style="float: right; margin-right: 50px"><%= GetStatic.ReadWebConfig("tranNoName","") %>:
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
                                        <tr>
                                            <td>Provider Name :
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="providerName" ForeColor="Red"></asp:Label>
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
                    </div>
                </div>
                <div class="row">
                    <div class="col-sm-6">
                        <fieldset>
                            <legend>Sender Information</legend>
                            <table class="table table-bordered table-striped table-condensed table-responsive">
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
                                <tr id="trSenCity" runat="server">
                                    <td>City:</td>
                                    <td>
                                        <asp:Label runat="server" ID="senderCity"></asp:Label></td>
                                </tr>
                                <tr>
                                    <td>Country:</td>
                                    <td>
                                        <asp:Label runat="server" ID="senderCountry"></asp:Label></td>
                                </tr>
                                <tr>
                                    <td>Contact No:</td>
                                    <td>
                                        <asp:Label runat="server" ID="senderContactNo"></asp:Label></td>
                                </tr>
                                <tr id="trIdType" runat="server">
                                    <td>
                                        <asp:Label runat="server" ID="senIdType"></asp:Label></td>
                                    <td>
                                        <asp:Label runat="server" ID="senIdNo"></asp:Label></td>
                                </tr>
                                <tr id="trMsg" runat="server">
                                    <td>Message:</td>
                                    <td>
                                        <asp:Label runat="server" ID="message"></asp:Label></td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                    <div class="col-sm-6">
                        <fieldset>
                            <legend>Receiver Information</legend>
                            <table class="table table-bordered table-striped table-condensed table-responsive">
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
                                <tr id="trRecCity" runat="server">
                                    <td>City:</td>
                                    <td>
                                        <asp:Label runat="server" ID="recCity"></asp:Label></td>
                                </tr>
                                <tr id="trRecCountry" runat="server">
                                    <td>Country:</td>
                                    <td>
                                        <asp:Label runat="server" ID="recCountry"></asp:Label></td>
                                </tr>
                                <tr id="trRecContactNo" runat="server">
                                    <td>Contact No:</td>
                                    <td>
                                        <asp:Label runat="server" ID="recContactNo"></asp:Label></td>
                                </tr>
                                <tr id="trRecIdType" runat="server">
                                    <td>
                                        <asp:Label runat="server" ID="recIdType" Text="Id No"></asp:Label></td>
                                    <td>
                                        <asp:Label runat="server" ID="recIdNo"></asp:Label></td>
                                </tr>
                            </table>
                        </fieldset>
                    </div>
                </div>
                <div class="row" runat="server" id="otherAgentType" visible="false">
                    <fieldset>
                        <legend>Additional Confirmation Fields</legend>
                        <div class="col-md-4">
                            <label>Bank Name: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="rBankName"
                                Display="Dynamic" ErrorMessage="Required!" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator><br />
                            <asp:DropDownList ID="rBankName" runat="server">
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4">
                            <label>Bank Branch Name:<span class="errormsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ControlToValidate="rbankBranch"
                                Display="Dynamic" ErrorMessage="Required!" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator><br />
                            <asp:TextBox ID="rbankBranch" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <label>Account No/Cheque No.: <span class="ErrMsg">*</span></label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator9" runat="server" ControlToValidate="rcheque"
                                Display="Dynamic" ErrorMessage="Required!" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator><br />
                            <asp:TextBox ID="rcheque" onBlur="chequeNoValidation();" runat="server"></asp:TextBox>
                        </div>
                    </fieldset>
                </div>
                <div class="row">
                    <fieldset>
                        <legend>Receiver Information - Payment</legend>
                        <div class="col-md-12" style="margin-left: 5px; margin-right: 15px;">
                            <div class="row" style="display: none;">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <span id="rowFullName" runat="server" style="display: none;">
                                            <label>
                                                <b>Receiver Full Name</b></label>
                                            <asp:TextBox ID="rFullName" runat="server" CssClass="form-control" />
                                        </span>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="col-md-2">
                                        <label>Receiver ID Type: <span class="ErrMsg">*</span></label>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="rIdType"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                            SetFocusOnError="True"></asp:RequiredFieldValidator>

                                        <asp:DropDownList ID="rIdType" runat="server" Style="width: 100%; height: 30px;">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-2">
                                        <label>Receiver ID Number: <span class="ErrMsg">*</span></label>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="rIdNumber"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                        <asp:TextBox ID="rIdNumber" runat="server" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"
                                            onchange="IdNoValidation(this)" Style="width: 100%; height: 30px;"></asp:TextBox>
                                    </div>
                                    <div class="col-md-2">
                                        <label>ID Issued Date <span class="ErrMsg">*</span></label>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator12" runat="server" ControlToValidate="rIdIssuedDate"
                                            Display="Dynamic" ErrorMessage="Required!" ForeColor="Red"
                                            Enabled="false" Visible="false" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                        <asp:TextBox ID="rIdIssuedDate" runat="server" CssClass="required" Style="width: 100%; height: 30px;"></asp:TextBox>
                                    </div>
                                    <div class="col-md-2" style="display: none">
                                        <label>ID Issued Date (B.S)</label>
                                        <asp:TextBox ID="rIdIssuedDateBs" runat="server" Style="width: 100%; height: 30px;" placeholder="mm/dd/yyyy"></asp:TextBox>
                                        <%--<span class="redLabel"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>--%>
                                    </div>
                                    <div class="col-md-2 trIdExpiryDate">
                                        <label>ID Expiry Date <span class="ErrMsg">*</span> </label>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator13" runat="server" ControlToValidate="rIdValidDate"
                                            Display="Dynamic" Visible="false" ErrorMessage="Required!" ForeColor="Red"
                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                        <asp:TextBox ID="rIdValidDate" runat="server" CssClass="required" Style="width: 100%; height: 30px;"></asp:TextBox>
                                    </div>
                                    <div class="col-md-2" style="display: none">
                                        <label>ID Expiry Date (B.S)</label>
                                        <asp:TextBox ID="rIdValidDateBs" runat="server" Style="display: none; width: 100%; height: 30px;" placeholder="mm/dd/yyyy"></asp:TextBox>
                                        <%--<span class="redLabel"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>--%>
                                    </div>
                                    <%--<div class="col-md-2">
                                        <label style="background: yellow;">Country Name: <span class="ErrMsg">*</span></label>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator19" runat="server" ControlToValidate="BenCountry"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                        <br />
                                        <asp:DropDownList runat="server" ID="BenCountry" CssClass="required" Style="width: 100%; height: 30px;" />
                                    </div>--%>
                                    <div class="col-md-2">
                                        <label style="background: yellow;">Nationality: <span class="ErrMsg">*</span></label>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator20" runat="server" ControlToValidate="recNationality"
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
                                    <div class="col-md-2">
                                        <label>Relationship with sender: <span class="ErrMsg">*</span></label>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator10" runat="server" ControlToValidate="relWithSender"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                        <asp:DropDownList ID="relWithSender" runat="server" CssClass="requiredField" Style="width: 100%; height: 30px;">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-sm-2">
                                        <label style="background: yellow;">Purpose of Remittance: <span class="ErrMsg">*</span></label>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="por"
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
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator11" runat="server" ControlToValidate="rContactNo"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                        <asp:TextBox ID="rContactNo" runat="server" Style="width: 100%; height: 30px;" onchange="ContactNoValidation(this)" onkeydown="return MakeNumericContactNoIdNo(this, (event?event:evt), true);"></asp:TextBox>
                                    </div>
                                    <div class="col-sm-2">
                                        <label style="background: yellow;">Address: <span class="ErrMsg">*</span></label>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator18" runat="server" ControlToValidate="rAdd"
                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="pay" ForeColor="Red"
                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                        <br />
                                        <asp:TextBox ID="rAdd" runat="server" Width="100%" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="col-sm-3">
                                        <label style="background: yellow;">City: <span class="ErrMsg">*</span></label>
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator21" runat="server" ControlToValidate="BeneCity"
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
                                    <div class="col-md-3">
                                        <label>&nbsp;</label><br />
                                        <asp:Button ID="btnPay" runat="server" CssClass="btn btn-primary" Text="Pay Transaction" ValidationGroup="pay"
                                            OnClick="btnPay_Click" />

                                        <cc1:ConfirmButtonExtender ID="cbeBtnPay" runat="server"
                                            ConfirmText="Confirm To Pay Transaction?" Enabled="True" TargetControlID="btnPay">
                                        </cc1:ConfirmButtonExtender>
                                        <asp:Button ID="BtnBack" runat="server" Text=" Back " class="btn btn-primary"
                                            OnClick="BtnBack_Click" />
                                    </div>
                                </div>
                            </div>
                            <div id="rptLog" runat="server"></div>
                        </div>
                    </fieldset>
                    <div class="row" style="display: none">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Parent/Spouse:</label>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="relationType"
                                    Display="Dynamic" ErrorMessage="Required!" Visible="false" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                <br />
                                <asp:DropDownList ID="relationType" runat="server" CssClass="form-control">
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <div class="row" style="display: none">
                        <div class="col-md-12">
                            <label>Parent/Spouse Name: </label>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="relativeName"
                                Display="Dynamic" Visible="false" ErrorMessage="Required!" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                            <br />
                            <asp:TextBox ID="relativeName" runat="server" onkeypress="return onlyAlphabets(event,this);" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>

                    <div runat="server" id="bankAndFinanceType" visible="false">
                        <fieldset>
                            <legend>Additional Confirmation Fields</legend>
                            <div class="col-md-6">
                                <label>Account No.:<span class="ErrMsg">*</span></label>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator14" runat="server" ControlToValidate="rAccountNo"
                                    Display="Dynamic" ErrorMessage="Required!" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                <br />
                                <asp:TextBox ID="rAccountNo" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label>Cheque No.:<span class="ErrMsg">*</span></label>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator15" runat="server" ControlToValidate="brcheque"
                                    Display="Dynamic" ErrorMessage="Required!" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator><br />
                                <asp:TextBox runat="server" ID="brcheque" CssClass="form-control"></asp:TextBox>
                            </div>
                        </fieldset>
                    </div>
                    <div class="row" style="display: none">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>DOB<span class="ErrMsg">*</span></label>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="rDOB"
                                    Display="Dynamic" ErrorMessage="Required!" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                                <asp:TextBox ID="rDOB" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label>DOB (B.S)</label>
                            <asp:TextBox ID="rDOBBs" runat="server" CssClass="form-control"></asp:TextBox>
                            <span class="redLabel"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <asp:HiddenField ID="hddCeTxn" runat="server" />
                        <asp:HiddenField ID="hddRowId" runat="server" />
                        <asp:HiddenField ID="hddControlNo" runat="server" />
                        <asp:HiddenField ID="hddTokenId" runat="server" />
                        <asp:HiddenField ID="hddSCountry" runat="server" />
                        <asp:HiddenField ID="hddPayAmt" runat="server" />
                        <asp:HiddenField ID="hddAgentName" runat="server" />
                        <asp:HiddenField ID="hddPBranchId" runat="server" />
                        <asp:HiddenField ID="hddOrderNo" runat="server" />
                        <asp:HiddenField ID="hddRCurrency" runat="server" />
                        <asp:HiddenField ID="hdnMapCode" runat="server" />
                        <asp:HiddenField ID="hdnTranType" runat="server" />
                        <asp:HiddenField ID="hddCustomerId" runat="server" />
                        <asp:HiddenField ID="hddMembershipId" runat="server" />
                        <asp:HiddenField ID="hddOriginalAmt" runat="server" />
                        <asp:HiddenField ID="hddrIdPlaceOfIssue" runat="server" />
                        <asp:HiddenField ID="hddagentgroup" runat="server" />
                        <asp:HiddenField ID="hddchequenumber" runat="server" />
                        <asp:HiddenField ID="hiddenSubPartnerId" runat="server" />
                        <asp:HiddenField ID="benefCityId" runat="server" />
                        <asp:HiddenField ID="benefStateId" runat="server" />
                        <asp:HiddenField ID="refNo" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>