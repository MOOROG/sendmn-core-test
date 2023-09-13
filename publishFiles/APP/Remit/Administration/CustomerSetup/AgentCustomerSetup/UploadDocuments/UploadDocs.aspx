<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UploadDocs.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.AgentCustomerSetup.UploadDocuments.UploadDocs" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../../../ui/js/jquery.min.js"></script>
    <script src="../../../../../ui/js/jquery.validate.js"></script>
    <script src="../../../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript">
        $.validator.messages.required = "Required!";

        $(document).ready(function () {
            $("#form1").validate();
        });
        $(document).ajaxStart(function () {
            $("#DivLoad").show();
        });

        $(document).ajaxComplete(function (event, request, settings) {
            $("#DivLoad").hide();
        });
        function LoadCalender(type, control) {
            var date = "";
            if (type == "e" && control == "dob")
                date = GetValue("<%=dobEng.ClientID%>");
            else if (type == "n" && control == "dob")
                date = GetValue("<%=dobNep.ClientID%>");
            else if (type == "e" && control == "issue")
                date = GetValue("<%=issueDate.ClientID%>");
            else if (type == "n" && control == "issue")
                date = GetValue("<%=issueDateNp.ClientID%>");
            else if (type == "e" && control == "expiry")
                date = GetValue("<%=expiryDate.ClientID%>");
            else if (type == "n" && control == "expiry")
                date = GetValue("<%=expiryDateNp.ClientID%>");

            var dataToSend = { MethodName: "calender", date: date, type: type };
            var options =
                    {
                        url: '<%=ResolveUrl("../Manage.aspx") %>?x=' + new Date().getTime(),
                        data: dataToSend,
                        dataType: 'JSON',
                        type: 'POST',
                        success: function (response) {
                            var data = jQuery.parseJSON(response);
                            if (data[0].Result == "") {
                                alert("Invalid Date.");
                                return;
                            }
                            if (type == "e" && control == "dob")
                                SetValueById("<%=dobNep.ClientID %>", data[0].Result, "");
                            else if (type == "n" && control == "dob")
                                SetValueById("<%=dobEng.ClientID %>", data[0].Result, "");

                            else if (type == "e" && control == "issue")
                                SetValueById("<%=issueDateNp.ClientID %>", data[0].Result, "");
                            else if (type == "n" && control == "issue")
                                SetValueById("<%=issueDate.ClientID %>", data[0].Result, "");

                            else if (type == "e" && control == "expiry")
                                SetValueById("<%=expiryDateNp.ClientID %>", data[0].Result, "");
                            else if (type == "n" && control == "expiry")
                                SetValueById("<%=expiryDate.ClientID %>", data[0].Result, "");
                        },
                        error: function (request, error) {
                            alert(request);
                        }
                    };
            $.ajax(options);
        }

        function IdOnChange() {

            var IdType = $("#idType").val();
            if (IdType == "") return;
            var spanCtrl = document.getElementById('spnexpiryDate');
            var ctrl = document.getElementById('expiryDate');

            if (IdType != "") {
                var IdTypeArr = IdType.split('|');
                if (IdTypeArr[1] == "E") {
                    if (spanCtrl != null)
                        spanCtrl.innerHTML = "*";
                }
                else {
                    if (spanCtrl != null)
                        spanCtrl.innerHTML = "";
                }
            }
            else {
                spanCtrl.innerHTML = "";
            }

            if (IdTypeArr[1] == "E") {
                $("#abc").show();
            }
            else {
                $("#abc").hide();
            }
        }
        LoadCalendars();
        function LoadCalendars() {
            CalSenderDOB("#<% =dobEng.ClientID%>");
            CalIDIssueDate("#<% =issueDate.ClientID%>");
            ExpiryDate("#<% =expiryDate.ClientID%>");
        }

        function ValidateDate() {
            try {
                var dateDOBValue = GetValue("<%=dobEng.ClientID%>");
                var issuedateValue = GetValue("<%=issueDate.ClientID%>");
                var expiryDateValue = GetValue("<%=expiryDate.ClientID%>");

                var dateDOBValueBs = GetValue("<%=dobNep.ClientID%>");
                var issuedateValueBs = GetValue("<%=issueDateNp.ClientID%>");
                var expiryDateValueBs = GetValue("<%=expiryDateNp.ClientID%>");

                var current = new Date();
                var currentYear = current.getFullYear();

                if (dateDOBValue != '') {
                    var dt = new Date(dateDOBValue);
                    var birthYear = dt.getFullYear();

                    if ((currentYear - birthYear) < 16) {
                        alert('Customer needs to be at least 16 years old.');
                        SetValueById("<%=dobEng.ClientID %>", "", "");
                        SetValueById("<%=dobNep.ClientID%>", "", "");
                        return false;
                    }

                    if (dt >= current) {
                        alert('Customer needs to be at least 16 years old.');
                        SetValueById("<%=dobEng.ClientID %>", "", "");
                        SetValueById("<%=dobNep.ClientID%>", "", "");
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
                        SetValueById("<%=dobEng.ClientID %>", "", "");
                        SetValueById("<%=dobNep.ClientID%>", "", "");
                        return false;
                    }

                    if (dateDOBValueBsArr.length == 3) {
                        var bsDD = dateDOBValueBsArr[1];
                        var bsMM = dateDOBValueBsArr[0];
                        var bsYear = dateDOBValueBsArr[2];

                        if ((bsDD.length == 0 || bsDD.length > 2) || (bsMM.length == 0 || bsMM.length > 2) || (bsYear.length != 4)) {
                            alert('Invalid date format for DOB BS. Date should be in MM/DD/YYYY format.');
                            SetValueById("<%=dobEng.ClientID %>", "", "");
                            SetValueById("<%=dobNep.ClientID%>", "", "");
                            return false;
                        }

                    }
                    else {
                        alert('Invalid date format for DOB BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=dobEng.ClientID %>", "", "");
                        SetValueById("<%=dobNep.ClientID%>", "", "");
                        return false;
                    }

                }

                if (issuedateValue != '') {
                    var dtIssue = new Date(issuedateValue);
                    if (dtIssue > current) {
                        alert('ID Issued date cannot be future date. Please enter valid ID Issued date.');
                        SetValueById("<%=issueDate.ClientID %>", "", "");
                        SetValueById("<%=issueDateNp.ClientID %>", "", "");
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
                        SetValueById("<%=issueDate.ClientID %>", "", "");
                        SetValueById("<%=issueDateNp.ClientID %>", "", "");
                        return false;
                    }

                    if (dateValueBsArr.length == 3) {
                        var bsDD = dateValueBsArr[1];
                        var bsMM = dateValueBsArr[0];
                        var bsYear = dateValueBsArr[2];

                        if ((bsDD.length == 0 || bsDD.length > 2) || (bsMM.length == 0 || bsMM.length > 2) || (bsYear.length != 4)) {
                            alert('Invalid date format for ID Issued Date BS. Date should be in MM/DD/YYYY format.');
                            SetValueById("<%=issueDate.ClientID %>", "", "");
                            SetValueById("<%=issueDateNp.ClientID %>", "", "");
                            return false;
                        }

                    }
                    else {
                        alert('Invalid date format for ID Issued Date BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=issueDate.ClientID %>", "", "");
                        SetValueById("<%=issueDateNp.ClientID %>", "", "");
                        return false;
                    }
                }

                if (expiryDateValue != '') {
                    var dtExpiry = new Date(expiryDateValue);
                    if (dtExpiry <= current) {
                        alert('ID Expiry date cannot be past or current date. Please enter valid ID Expiry date.');
                        SetValueById("<%=expiryDate.ClientID %>", "", "");
                        SetValueById("<%=expiryDateNp.ClientID %>", "", "");
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
                        SetValueById("<%=expiryDate.ClientID %>", "", "");
                        SetValueById("<%=expiryDateNp.ClientID %>", "", "");
                        return false;
                    }

                    if (dateValueBsArr.length == 3) {
                        var bsDD = dateValueBsArr[1];
                        var bsMM = dateValueBsArr[0];
                        var bsYear = dateValueBsArr[2];

                        if ((bsDD.length == 0 || bsDD.length > 2) || (bsMM.length == 0 || bsMM.length > 2) || (bsYear.length != 4)) {
                            alert('Invalid date format for ID Expiry Date BS. Date should be in MM/DD/YYYY format.');
                            SetValueById("<%=expiryDate.ClientID %>", "", "");
                            SetValueById("<%=expiryDateNp.ClientID %>", "", "");
                            return false;
                        }
                    }
                    else {
                        alert('Invalid date format for ID Expiry Date BS. Date should be in MM/DD/YYYY format.');
                        SetValueById("<%=expiryDate.ClientID %>", "", "");
                        SetValueById("<%=expiryDateNp.ClientID %>", "", "");
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

            }

            return confirm('Confirm To Continue ?')
        }
    </script>
    <style>
        .head {
            color: #FFFFFF;
            background: #FF0000;
            padding: 2px;
            border-radius: 2px;
        }

        .style2 {
            font-size: xx-small;
            color: #FF0000;
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

        .SmallTextBox {
            width: 130px;
        }

        .LargeTextBox {
            width: 425px
        }

        td {
            font-size: 11px;
        }

        .frmTitle {
            background: #e00024 !important;
        }

        .amountLabel {
            font-size: 16px;
            font-weight: bold;
            color: Red;
            padding: 2px;
        }

        #availableAmt {
            color: Red;
        }

        .mainContainer {
            clear: both;
            width: 850px;
            float: left;
        }

        .rowContainer {
            clear: both;
            display: block;
            float: left;
            margin-bottom: 5px;
        }

        .amountDiv {
            background: none repeat scroll 0 0 black;
            clear: both;
            color: white;
            float: right;
            font-size: 20px;
            font-weight: 600;
            padding: 2px 8px;
            width: auto;
        }

        #mask {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: red;
            z-index: 99;
        }

        .SuccessMsg {
            background: url("../../../../images/true.png") 8px 5px no-repeat;
            background-color: #dfffdf;
            border-color: #9fcf9f;
            color: #005f00;
            padding: 4px 4px 4px 30px;
            margin-bottom: 12px;
            font-size: 2.1em;
            border: 1px solid;
            margin-top: 10px;
        }

        table {
            table-layout: fixed;
        }

        td {
            width: 25%;
            background-color: #e6e6e6;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <asp:HiddenField runat="server" ID="hdnRowId" />
        <asp:HiddenField runat="server" ID="hdnCustomerId" />
        <asp:HiddenField runat="server" ID="hdnIsDelete" />

        <div id="DivLoad" style="position: absolute; height: 20px; width: 220px; background-color: #333333; display: none; left: 300px; top: 150px;">
            <img src="../../../../images/progressBar.gif" border="0" alt="Loading..." />
        </div>

        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>UPLOAD CUSTOMER DOCS
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Utilities</a></li>
                            <li class="active"><a href="#">Enroll Customer</a></li>
                            <li class="active"><a href="#">Upload Documents</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">CUSTOMER SETUP: Basic Information</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <table class="table table-bordered table-condensed">

                                        <tr>
                                            <td>

                                                <table class="table table-condensed">
                                                    <tr>
                                                        <td nowrap="nowrap">Customer Card No.<span class="errormsg">*</span>
                                                            <asp:TextBox ID="customerCardNo" runat="server" CssClass="required form-control"></asp:TextBox>
                                                        </td>
                                                        <td nowrap="nowrap">First Name<span class="errormsg">*</span>
                                                            <asp:TextBox ID="firstName" runat="server" CssClass="required form-control"></asp:TextBox>
                                                        </td>
                                                        <td nowrap="nowrap">Middle Name
                                                        <asp:TextBox ID="middleName" runat="server" CssClass="form-control"></asp:TextBox>
                                                        </td>
                                                        <td nowrap="nowrap">Last Name<span class="errormsg">*</span>
                                                            <asp:TextBox ID="lastName" runat="server" CssClass="required form-control"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Id Type<span class="errormsg">*</span><br />
                                                            <asp:DropDownList ID="idType" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
                                                            <asp:RequiredFieldValidator ID="rqIdType" runat="server" ControlToValidate="idType" ValidationGroup="save"
                                                                Display="Dynamic" ErrorMessage="Required!" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                        </td>
                                                        <td>Id No.<span class="errormsg">*</span><br />
                                                            <asp:TextBox runat="server" ID="idNo" CssClass="form-control"></asp:TextBox>
                                                            <asp:RequiredFieldValidator ID="rqidNo" runat="server" ControlToValidate="idNo" ValidationGroup="save"
                                                                Display="Dynamic" ErrorMessage="Required!" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                        </td>
                                                        <td>Place of Issue<span class="errormsg">*</span><br />
                                                            <asp:DropDownList ID="placeOfIssue" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
                                                            <asp:RequiredFieldValidator ID="rqPlaceofissue" runat="server" ControlToValidate="placeOfIssue" ValidationGroup="save"
                                                                Display="Dynamic" ErrorMessage="Required!" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td nowrap="nowrap">Date of Birth (Eng. Date) <span class="errormsg">*</span>
                                                            <asp:Label ID="lblDobChk" runat="server" ForeColor="Red"></asp:Label>
                                                            <br />
                                                            <asp:TextBox ID="dobEng" runat="server" CssClass="form-control"></asp:TextBox>
                                                            <asp:RequiredFieldValidator ID="rqdobEng" runat="server" ControlToValidate="dobEng" ValidationGroup="save"
                                                                Display="Dynamic" ErrorMessage="Required!" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                            <br />
                                                            <span class="style2"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                                                        </td>
                                                        <td nowrap="nowrap">Date of Birth (Nep. Date)<br />
                                                            <asp:TextBox ID="dobNep" runat="server" CssClass="form-control">
                                                            </asp:TextBox><br />
                                                            <span class="style2"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                                                        </td>
                                                        <td nowrap="nowrap">Issue Date (Eng. Date)<span class="errormsg">*</span>
                                                            <asp:Label ID="lblIssueChk" runat="server" ForeColor="Red"></asp:Label>
                                                            <br />
                                                            <asp:TextBox runat="server" ID="issueDate" CssClass="form-control"></asp:TextBox>
                                                            <asp:RequiredFieldValidator ID="rqissueDate" runat="server" ControlToValidate="issueDate" ValidationGroup="save"
                                                                Display="Dynamic" ErrorMessage="Required!" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>

                                                            <br />
                                                            <span class="style2"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                                                        </td>
                                                        <td nowrap="nowrap">Issue Date (Nep. Date)<br />
                                                            <asp:TextBox ID="issueDateNp" runat="server" CssClass="form-control">
                                                            </asp:TextBox><br />
                                                            <span class="style2"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                                                        </td>
                                                    </tr>
                                                    <tr id="abc" style="display: none;" runat="server">
                                                        <td nowrap="nowrap">Expiry Date (Eng. Date)<span id="spnexpiryDate" class="errormsg"></span>
                                                            <asp:Label ID="lblExpiryChk" runat="server" ForeColor="Red"></asp:Label>
                                                            <br />
                                                            <asp:TextBox runat="server" ID="expiryDate" CssClass="form-control" Width="262px"></asp:TextBox>
                                                            <br />
                                                            <span class="style2"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                                                        </td>
                                                        <td nowrap="nowrap">Expiry Date (Nep. Date)<br />
                                                            <asp:TextBox ID="expiryDateNp" runat="server" CssClass="form-control" Width="262px">
                                                            </asp:TextBox><br />
                                                            <span class="style2"><em><strong>(Date Format : MM/DD/YYYY) </strong></em></span>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap">
                                                <asp:Button ID="btnSave" runat="server" CssClass="btn btn-primary btn-sm" ValidationGroup="save" OnClientClick="if (!ValidateDate()) return false;" OnClick="btnSave_Click"
                                                    Text="Save Customer Information" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <div class="panel panel-default">
                                                    <div class="panel-heading panel-title">CUSTOMER SETUP: Document Upload</div>
                                                    <div class="panel-body">
                                                        <table class="table table-condensed">

                                                            <tr>
                                                                <td colspan="4" class="alert alert-info">
                                                                    <strong>Please upload the .JPG/.PNG/.JPEG File Format &amp; Image size below 500kb.</strong><br />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="frmLable">Document:
                                                                </td>
                                                                <td>
                                                                    <input id="fileUpload" runat="server" name="fileUpload" type="file" size="20" class="form-control" />
                                                                </td>
                                                                <td class="frmLable">File Type:<span class="errormsg">*</span>
                                                                </td>
                                                                <td class="style1">
                                                                    <asp:DropDownList ID="docType" runat="server" CssClass="form-control">
                                                                    </asp:DropDownList>
                                                                    <asp:RequiredFieldValidator ID="rqdocType" runat="server" ControlToValidate="docType" ValidationGroup="upload"
                                                                        Display="Dynamic" ErrorMessage="Required!" ForeColor="Red" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="frmLable">&nbsp;
                                                                </td>
                                                                <td>&nbsp;<asp:Button ID="btnUpload" runat="server" Text="Upload" ValidationGroup="upload" CssClass="btn btn-primary btn-sm" OnClick="btnUpload_Click" />
                                                                </td>
                                                                <td class="frmLable">&nbsp;
                                                                </td>
                                                                <td></td>
                                                            </tr>
                                                            <tr>
                                                                <td></td>
                                                                <td class="style2" colspan="3">
                                                                    <asp:Label ID="lblMsg" Font-Bold="true" ForeColor="Red" runat="server" Text=""></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="4">
                                                                    <asp:Table ID="tblResult" runat="server" Width="100%">
                                                                    </asp:Table>
                                                                    <br />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </div>
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
    </form>
</body>
</html>