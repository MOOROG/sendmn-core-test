<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.AgentPanel.Utilities.CustomerSetup.Manage"
    EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/jquery.validate.js"></script>
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>

    <style type="text/css">
        label.error, .msg {
            color: red;
            float: none;
            font: bold 10px 'Verdana';
            padding: 2px;
            text-align: left;
            vertical-align: top;
        }

        form input.error, form input.error:hover, form input.error:focus, form select.error, form textarea.error {
            background: #FFD9D9;
            border-style: solid;
            border-width: 1px;
        }

        .style1 {
            width: 117px;
            height: 17px;
        }
    </style>
    <script type="text/javascript">

        function LoadCalendars() {
            VisaValiCustDate("#<% =txtCustIdValidDate.ClientID%>");
            CustDOB("#<% =txtCustDOB.ClientID%>");
        }
        LoadCalendars();

        function CustDOB(cal) {
            $(function () {
                $(cal).datepicker({
                    changeMonth: true,
                    changeYear: true,
                    showOn: "both",
                    buttonImage: "../../../images/calendar.gif",
                    buttonImageOnly: true,
                    yearRange: "-90:-18", //18 years or older up until 115yo (oldest person ever, can be sensibly set to something much smaller in most cases)
                    maxDate: "-18Y", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
                    minDate: "-90Y"

                });
            });
        }
        function VisaValiCustDate(cal) {
            $(function () {
                $(cal).datepicker({
                    changeMonth: true,
                    changeYear: true,
                    showOn: "both",
                    buttonImage: "../../../images/calendar.gif",
                    buttonImageOnly: true,
                    //yearRange: "-60:-18", //18 years or older up until 115yo (oldest person ever, can be sensibly set to something much smaller in most cases)
                    maxDate: "+10Y", //Will only allow the selection of dates more than 18 years ago, useful if you need to restrict this
                    minDate: "+1"
                });
            });
        }

        $.validator.messages.required = "Required!";
        $(document).ready(function () {
            $("#custForm").validate();
        });

        function GetInput() {
            var firstName = GetValue("<%=txtCustFirstName.ClientID %>");
            var middleName = GetValue("<%=txtCustMidName.ClientID %>");
            var lastName = GetValue("<%=txtCustLastName.ClientID %>");
            var secondLastName = GetValue("<%=txtCustSecondLastName.ClientID %>");

            var idType = $("#ddCustIdType").val();
            var idTypeArr = idType.split('|');

            //var idType = GetValue("<%=ddCustIdType.ClientID %>");

            var idNo = GetValue("<%=txtCustIdNo.ClientID %>");
            var validDate = GetValue("<%=txtCustIdValidDate.ClientID %>");
            var dob = GetValue("<%=txtCustDOB.ClientID %>");
            var telNo = GetValue("<%=txtCustTel.ClientID %>");
            var mobile = GetValue("<%=txtCustMobile.ClientID %>");
            var city = GetValue("<%=txtCustCity.ClientID %>");
            var postalCode = GetValue("<%=txtCustPostal.ClientID %>");
            var companyName = GetValue("<%=companyName.ClientID %>");
            var address1 = GetValue("<%=txtCustAdd1.ClientID %>");
            var address2 = GetValue("<%=txtCustAdd2.ClientID %>");
            var nativeCountry = GetValue("<%=txtCustNativeCountry.ClientID %>");
            var email = GetValue("<%=txtCustEmail.ClientID %>");
            var gender = GetValue("<%=ddlCustGender.ClientID %>");
            var salary = GetValue("<%=ddlSalary.ClientID %>");
            var memberId = GetValue("<%=memberId.ClientID %>");
            var occupation = GetValue("<%=occupation.ClientID %>");
            var imi = "";
            try {
                imi = (GetElement("<%=isMemberIssued.ClientID %>").checked ? "Y" : "N");
            } catch (ex) { }
            var id = GetValue("<%=hddId.ClientID %>");

            var custData = { methodName: 'update', firstName: firstName, middleName: middleName, lastName: lastName, secondLastName: secondLastName, idType: idTypeArr[0]
                                , idNo: idNo, validDate: validDate, dob: dob, telNo: telNo, mobile: mobile, city: city, postalCode: postalCode, companyName: companyName
                                , address1: address1, address2: address2, nativeCountry: nativeCountry, email: email, gender: gender, salary: salary
                                , memberId: memberId, occupation: occupation, id: id, imi: imi
            };
            var options =
                            {
                                url: '<%=ResolveUrl("Manage.aspx") %>',
                                data: custData,
                                dataType: 'JSON',
                                type: 'POST',
                                success: function (response) {
                                    ParseResultData(response);
                                }
                            };

            if (dob != "") {
                if (!IsValidDOB(dob)) {
                    window.parent.SetMessageBox("Customer Not Eligible!", "1");
                    SetFocus(GetElement("<%=txtCustDOB.ClientID %>"));
                    return;
                }
            }

            if (email != "") {
                if (!IsEmail(email)) {
                    window.parent.SetMessageBox("Invalid e-mail Address!", "1");
                    SetFocus(GetElement("<%=txtCustEmail.ClientID %>"));
                    return;
                }
            }
            $.ajax(options);
            return true;
        }

        function ParseResultData(response) {
            var data = jQuery.parseJSON(response);
            window.parent.SetMessageBox(data[0].msg);
            if (data[0].errCode == "0") {
                $(location).attr('href', "List.aspx");
            }
        }

        function IsEmail(email) {
            var regex = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
            if (!regex.test(email)) {
                return false;
            } else {
                return true;
            }
        }

        function IsValidDOB(dob) {
            var CustYears = datediff(dob, 'years');
            if (parseInt(CustYears) < 16) {
                return false;
            } else {
                return true;
            }
        }

        function SetFocus(element) {
            element.focus();
            element.style.background = '#FFD9D9';
        }

        function ValidateFormData() {
            if (confirm("Are You Sure?")) {
                var valid = $("#custForm").validate().form();
                if (valid) {
                    GetInput();

                } else {
                   return false;
                }
            }
        }

        function ViewImage(custId) {
            var url = "../../Send/SendTransaction/CustomerID.aspx?customerId=" + custId;
            OpenDialog(url, 500, 620, 100, 100);
        }

        function ShowHide(me) {
            if (!me.checked) {
                HideElement("<% = lblMem.ClientID %>");
                HideElement("<% = txtMem.ClientID %>");

            } else {
                ShowElement("<% = lblMem.ClientID %>");
                ShowElement("<% = txtMem.ClientID %>");

            }
        }
    </script>
</head>
<body>
    <form id="custForm" runat="server">
        <asp:HiddenField ID="hddId" runat="server" />
        <asp:ScriptManager ID="sm1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>CUSTOMER SETUP
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Customer Setup</a></li>
                            <li class="active"><a href="#">Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="#" class="selected">Search Customer </a></li>
                    <li><a href="Manage.aspx">Customer Detail </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Customer Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <asp:UpdatePanel ID="up" runat="server" RenderMode="Inline" UpdateMode="Conditional"
                                        ChildrenAsTriggers="false">
                                        <ContentTemplate>
                                            <div class="table-responsive">
                                                <table class="table  table-condensed">

                                                    <tr>
                                                        <td>
                                                            <table id="tblCust" cellspacing="0" class="table table-condensed">
                                                                <tr>
                                                                    <td colspan="2">
                                                                        <asp:CheckBox runat="server" ID="isMemberIssued" Text="Issue Membership Id" />
                                                                    </td>
                                                                    <td>
                                                                        <asp:Label Style="display: none" ID="lblMem" runat="server" Text="Membership ID:" />
                                                                    </td>
                                                                    <td>
                                                                        <div runat="server" id="txtMem" style="display: none">
                                                                            <asp:TextBox ID="memberId" runat="server" CssClass="form-control"></asp:TextBox>
                                                                            <span id="memberCode_err" class="errormsg"></span>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>First Name: <span class="errormsg" id='txtFirstName_err'>*</span>
                                                                    </td>
                                                                    <td>
                                                                        <asp:TextBox ID="txtCustFirstName" runat="server" CssClass="required  form-control"></asp:TextBox>
                                                                    </td>
                                                                    <td>Middle Name:
                                                                    </td>
                                                                    <td>
                                                                        <asp:TextBox ID="txtCustMidName" runat="server" CssClass="SmallTextBox form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Last Name:
                                                                    </td>
                                                                    <td>
                                                                        <asp:TextBox ID="txtCustLastName" runat="server" CssClass="SmallTextBox form-control"></asp:TextBox>
                                                                        <span class="errormsg" id='txtCustLastName_err'></span>
                                                                    </td>
                                                                    <td>Second Last Name:
                                                                    </td>
                                                                    <td>
                                                                        <asp:TextBox ID="txtCustSecondLastName" runat="server" CssClass="SmallTextBox form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr id="trCustId" runat="server">
                                                                    <td>
                                                                        <asp:Label runat="server" ID="lblcIdtype" Text="ID Type:"></asp:Label>
                                                                        <span runat="server" class="errormsg" id='ddCustIdType_err'>*</span>
                                                                    </td>
                                                                    <td>
                                                                        <asp:DropDownList ID="ddCustIdType" runat="server" Class="required form-control">
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                    <td>
                                                                        <asp:Label runat="server" ID="lblcidNo" Text="ID Number:"></asp:Label>
                                                                        <span runat="server" class="errormsg" id='txtCustIdNo_err'>*</span>
                                                                    </td>
                                                                    <td>
                                                                        <asp:TextBox ID="txtCustIdNo" runat="server" Class="required form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr id="trIdExpirenDob" runat="server">
                                                                    <td id="tdCustExpDateLbl" runat="server">
                                                                        <asp:Label runat="server" ID="lblcExpDate" Text="ID Expiry Date:"></asp:Label>
                                                                        <span runat="server" id="txtCustIdValidDate_err" class="errormsg">*</span>
                                                                    </td>
                                                                    <td id="tdCustExpDateTxt" runat="server" nowrap="nowrap">
                                                                        <asp:TextBox ID="txtCustIdValidDate" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    </td>
                                                                    <td id="tdCustDobLbl" runat="server">
                                                                        <asp:Label runat="server" ID="lblcDOB" Text="DOB:"></asp:Label>
                                                                        <span runat="server" class="errormsg" id='txtCustDOB_err'>*</span>
                                                                    </td>
                                                                    <td id="tdCustDobTxt" runat="server" nowrap="nowrap">
                                                                        <asp:TextBox ID="txtCustDOB" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr id="trCustContactNo" runat="server">
                                                                    <td id="tdCustMobileNoLbl" runat="server">Mobile: <span runat="server" class="errormsg" id='txtCustMobile_err'>*</span>
                                                                    </td>
                                                                    <td id="tdCustMobileNoTxt" runat="server">
                                                                        <asp:TextBox ID="txtCustMobile" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    </td>
                                                                    <td id="tdCustTelNoLbl" runat="server">
                                                                        <asp:Label runat="server" ID="lblcTelNo" Text="Tel. No.:"></asp:Label>
                                                                    </td>
                                                                    <td id="tdCustTelNoTxt" runat="server">
                                                                        <asp:TextBox ID="txtCustTel" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td id="tdCustCityLbl" runat="server">
                                                                        <asp:Label runat="server" ID="lblcCity" Text="City:"></asp:Label>
                                                                        <span runat="server" class="errormsg" id='txtCustCity_err'>*</span>
                                                                    </td>
                                                                    <td id="tdCustCityTxt" runat="server">
                                                                        <asp:TextBox ID="txtCustCity" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    </td>
                                                                    <td>Postal Code:
                                                                    </td>
                                                                    <td>
                                                                        <asp:TextBox ID="txtCustPostal" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr id="trCustCompany" runat="server">
                                                                    <td>
                                                                        <asp:Label runat="server" ID="lblCompName" Text="Company Name:"></asp:Label>
                                                                        <span runat="server" class="errormsg" id='companyName_err'>*</span>
                                                                    </td>
                                                                    <td colspan="3">
                                                                        <asp:TextBox ID="companyName" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr id="trCustAddress1" runat="server">
                                                                    <td>Address1: <span runat="server" class="errormsg" id='txtCustAdd1_err'>*</span>
                                                                    </td>
                                                                    <td colspan="3">
                                                                        <asp:TextBox ID="txtCustAdd1" runat="server" CssClass="form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr id="trCustAddress2" runat="server">
                                                                    <td>Address2:
                                                                    </td>
                                                                    <td colspan="3">
                                                                        <asp:TextBox ID="txtCustAdd2" runat="server" CssClass="LargeTextBox form-control"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Native Country: <span class="errormsg" id='txtCustNativeCountry_err'>*</span>
                                                                    </td>
                                                                    <td colspan="3">
                                                                        <asp:DropDownList ID="txtCustNativeCountry" runat="server" CssClass="required form-control">
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Email:
                                                                    </td>
                                                                    <td colspan="3">
                                                                        <asp:TextBox ID="txtCustEmail" runat="server" CssClass="LargeTextBox form-control"></asp:TextBox>&nbsp;
                                                        <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ForeColor="Red"
                                                            ControlToValidate="txtCustEmail" ErrorMessage="Invalid Email!" CssClass="msg"
                                                            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*">
                                                        </asp:RegularExpressionValidator>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:Label runat="server" ID="lblSalaryRange" Text="Salary Range:"></asp:Label>
                                                                        <span runat="server" id="ddlSalary_err" class="errormsg">*</span>
                                                                    </td>
                                                                    <td>
                                                                        <asp:DropDownList ID="ddlSalary" runat="server" CssClass="form-control">
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>Gender: <span class="errormsg" id='ddlCustGender_err'>*</span>
                                                                    </td>
                                                                    <td>
                                                                        <asp:DropDownList ID="ddlCustGender" runat="server" CssClass="required form-control">
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr id="trOccupation" runat="server">
                                                                    <td>
                                                                        <asp:Label runat="server" ID="lblOccupation" Text="Occupation:"></asp:Label>
                                                                        <span runat="server" class="errormsg" id='occupation_err'>*</span>
                                                                    </td>
                                                                    <td>
                                                                        <asp:DropDownList ID="occupation" runat="server" CssClass="form-control">
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="3">
                                                                        <div id="custIdImg" runat="server" visible="false">
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td></td>
                                                                    <td align="center" colspan="2">
                                                                        <div>
                                                                            <asp:Button ID="btnSubmit" Text="Submit" runat="server" CssClass="btn btn-primary btn-sm" Style="float: left;"
                                                                                OnClientClick="return ValidateFormData();" />

                                                                            <div runat="server" id="upladImage" style="margin-right: 10px; float: left;">
                                                                            </div>
                                                                        </div>
                                                                        <br />
                                                                    </td>
                                                                    <td></td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </ContentTemplate>
                                        <%--<Triggers>
        <asp:AsyncPostBackTrigger ControlID ="isMemberIssued" EventName ="CheckedChanged" />
    </Triggers>--%>
                                    </asp:UpdatePanel>
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
<script type='text/javascript' language='javascript'>
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
    function EndRequest(sender, args) {
        if (args.get_error() == undefined) {
            LoadCalendars();
        }
    }
</script>