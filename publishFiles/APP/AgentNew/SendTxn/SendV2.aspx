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
            border-color: red;
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

        .table-responsive br {
            display: none;
        }

        legend {
            background-color: #b50000 !important;
            color: white !important;
            margin-bottom: 0 !important;
            font-family: Verdana, Arial;
            font-size: 12px;
            margin-right: 2px;
            padding-bottom: 6px !important;
            text-align: -webkit-center;
        }

        fieldset {
            padding: 5px !important;
            margin: 5px !important;
            border: 1px solid #0000001c !important;
        }
    </style>
    <!--<![endif]-->
    <style type="text/css">
        .allow-dropdown {
            width: 100% !important;
        }

        .select2-container {
            width: 100% !important;
        }

        .input-group {
            width: 100% !important;
        }
    </style>
    <script type="text/javascript">
        function GetCustomerSearchType() {
            return $("#" + mId + "ddlCustomerType").val();
        }
        function ClearSearchField() {
            var d = ["", ""];
            SetItem("<% =txtSearchData.ClientID%>", d);
            <% = txtSearchData.InitFunction() %>;
        }
        function IntroducerDataClear() {
            var d = ["", ""];
            SetItem("<% =introducerTxt.ClientID%>", d);
            <% = introducerTxt.InitFunction() %>;
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
                                    <asp:Label ID="balCurrency" runat="server" Text="MNT"></asp:Label>
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
                    <div class="infoDiv">
                        <div class="panel panel-default" style="display: none;">
                            <div class="panel-heading">
                                <h4 class="panel-title">Sending Branch</h4>
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-2 form-group">
                                        <label>
                                            Sending Branch/Agent:
                                            <span class="ErrMsg">*</span>
                                        </label>
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
                                        <asp:CheckBox ID="NewCust" runat="server" Checked="true" CssClass="btn green" Text="New Customer" onclick="ClearData();" />
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
                                    <div class="col-sm-1 col-xs-6 notDisable">
                                        <input name="button4" type="button" id="btnClear" value="Clear" class="btn btn-clear" onclick="ClearAllCustomerInfo();" style="margin-bottom: 2px; margin-left: 30px; cursor: pointer" />
                                    </div>
                                    <div class="col-sm-2 col-xs-3 notDisable">
                                        <input name="button5" type="button" id="btnHistroy" value="History" class="btn btn-primary" onclick="ShowHistory();" style="margin-bottom: 2px; margin-left: 30px; cursor: pointer" />
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
                        <asp:HiddenField ID="cancelrequestId" runat="server" />
                        <asp:HiddenField ID="hdnRelationshipReq" runat="server" />
                        <asp:HiddenField ID="visaStatusNotFound" runat="server" />

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
                                                <tr style="display: none">
                                                    <td>Zip Code</td>
                                                    <td colspan="3">
                                                        <asp:TextBox ID="txtSendPostal" runat="server" placeholder="Postal Code" CssClass="form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Postal Code');"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr style="display: none">
                                                    <td>Street
                                                        <span runat="server" class="ErrMsg" id='sCustStreet_err'>*</span>
                                                    </td>
                                                    <td colspan="3">
                                                        <asp:TextBox ID="sCustStreet" runat="server" placeholder="Street" CssClass="SmallTextBox form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Street Name');"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr style="display: none">
                                                    <td id="tdSenCityLbl" runat="server">
                                                        <asp:Label runat="server" ID="lblsCity" Text="City:"></asp:Label>
                                                        <span runat="server" class="ErrMsg" id='txtSendCity_err'>*</span>
                                                    </td>
                                                    <td id="tdSenCityTxt" runat="server" colspan="3">
                                                        <asp:TextBox ID="txtSendCity" runat="server" placeholder="City" CssClass="required form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender City');"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr style="display: none">
                                                    <td>State:<span class="ErrMsg">*</span></td>
                                                    <td colspan="2">
                                                        <div class="form-group">
                                                            <div class="input-group">
                                                                <asp:DropDownList ID="custLocationDDL" runat="server" CssClass="required form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                                                <div class="input-group-addon"><span id="lblSendCountryName"><b>Mongolia</b></span></div>
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
                                                <tr id="trOccupation" runat="server" class="showOnIndividual">
                                                    <td>
                                                        <asp:Label runat="server" ID="lblOccupation" Text="Occupation:"></asp:Label>
                                                        <span runat="server" class="ErrMsg" id='occupation_err'>*</span>
                                                    </td>
                                                    <td colspan="3">
                                                        <asp:DropDownList ID="occupation" runat="server" CssClass="required form-control readonlyOnCustomerSelect"></asp:DropDownList>
                                                    </td>
                                                </tr>
                                                <tr id="trSalaryRange" runat="server" style="display: none">
                                                    <td>
                                                        <asp:Label runat="server" ID="lblSalaryRange" Text="Monthly Income:"></asp:Label>
                                                        <span runat="server" id="ddlSalary_err" class="ErrMsg">*</span>
                                                    </td>
                                                    <td colspan="3">
                                                        <asp:DropDownList ID="ddlSalary" runat="server" CssClass="form-control readonlyOnCustomerSelect">
                                                            <asp:ListItem Value="null">Select</asp:ListItem>
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
                                                    <td>Email:<span class="ErrMsg" id="senderEmailIsRequired" hidden>*</span></td>
                                                    <td colspan="3">
                                                        <asp:TextBox ID="txtSendEmail" runat="server" placeholder="Email" CssClass="LargeTextBox form-control readonlyOnCustomerSelect"></asp:TextBox>
                                                        <asp:RegularExpressionValidator ID="rev1" runat="server" Display="Dynamic"
                                                            ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                                            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                                            ControlToValidate="txtSendEmail"></asp:RegularExpressionValidator>
                                                    </td>
                                                </tr>
                                                <tr style="display: none">
                                                    <td>Customer Type:</td>
                                                    <td colspan="3">
                                                        <asp:DropDownList ID="ddlSendCustomerType" runat="server" onchange="ChangeCustomerType()" CssClass="SmallTextBox form-control readonlyOnCustomerSelect">
                                                        </asp:DropDownList>
                                                    </td>
                                                </tr>
                                                <tr id="trSenCompany" runat="server" style="display: none">
                                                    <td>
                                                        <asp:Label runat="server" ID="lblCompName" Text="Company Name:"></asp:Label>
                                                        <span runat="server" class="ErrMsg" id='companyName_err'>*</span>
                                                    </td>
                                                    <td colspan="3">
                                                        <asp:TextBox ID="companyName" runat="server" placeholder="Company Name" CssClass="form-control readonlyOnCustomerSelect" onblur="CheckForSpecialCharacter(this, 'Sender Company Name');"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr style="display: none">
                                                    <td>Business Type
                                                        <span runat="server" class="ErrMsg" id='Span2'>*</span>
                                                    </td>
                                                    <td colspan="3">
                                                        <asp:DropDownList ID="ddlEmpBusinessType" runat="server" CssClass="form-control readonlyOnCustomerSelect"></asp:DropDownList>
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

                                                <tr>
                                                    <td>Place Of Issue</td>
                                                    <td colspan="3">
                                                        <asp:DropDownList ID="ddlIdIssuedCountry" runat="server" CssClass="form-control readonlyOnCustomerSelect"></asp:DropDownList>
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
                                                    <td>Receiver Name:<span class="ErrMsg" id='txtRecFName_err'>*</span>
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
                                                    <td>Address1:<span runat="server" class="ErrMsg" id='txtRecAdd1_err'>*</span>
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
                                                <tr style="display: none;">
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
                                                    <td>Email:<span class="ErrMsg" id="receiverEmailIsRequired" hidden>*</span></td>
                                                    <td colspan="3">
                                                        <asp:TextBox ID="txtRecEmail" runat="server" placeholder="Email" CssClass="LargeTextBox form-control "></asp:TextBox>
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
                                                            <asp:Label ID="lblPerTxnLimitCurr" runat="server">MNT</asp:Label>
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
                                                                <asp:Label ID="lblSendCurr" runat="server" Text="MNT" class="amountLabel"></asp:Label>
                                                            </span>
                                                        </div>
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
                                                <tr class="deposited-bank-hide" style="display: none">
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
                                                            <div class="input-group mb-2 mr-sm-2 mb-sm-0">
                                                                <asp:DropDownList ID="branch" runat="server" CssClass="js-example-basic-single form-group">
                                                                </asp:DropDownList>
                                                            </div>
                                                            <label id="branchDetail" style="background-color: yellow"></label>
                                                            <%--<select id="branch" runat="server" class="form-control" style="display: none;">
                                                            <option value="">SELECT BANK</option>
                                                        </select>--%>
                                                        </div>
                                                        <div id="divBankBranch_manualType">
                                                            <div class="input-group mb-2 mr-sm-2 mb-sm-0">
                                                                <input type="text" class="form-control" id="branch_manual" />
                                                            </div>
                                                            <%--<select id="branch" runat="server" class="form-control" style="display: none;">
                                                            <option value="">SELECT BANK</option>
                                                        </select>--%>
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
                                                    <td>Service Charge:
                                                    </td>
                                                    <td>
                                                        <input type="checkbox" id="editServiceCharge" runat="server" /><label for="editServiceCharge">EDIT</label>
                                                        <asp:HiddenField ID="allowEditSC" runat="server" />
                                                        <asp:TextBox ID="lblServiceChargeAmt" runat="server" Text="0" class="form-control" Width="20%" Style="display: inherit !important;" onblur="return ReCalculate();"></asp:TextBox>
                                                        <asp:Label ID="lblServiceChargeCurr" runat="server" Text="MNT" class="amountLabel"></asp:Label>&nbsp;
                                                        <label id="lblCampaign" style="background-color: yellow; font-weight: 600;"></label>
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
                                                <tr id="ReferralDiv" style="display: none;">
                                                    <td style="font-weight: 700">Introducer (If Any):
                                                    </td>
                                                    <td>
                                                        <uc1:SwiftTextBox ID="introducerTxt" runat="server" Category="remit-referralCode" CssClass="form-control required" Title="Blank for All" />
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
                                                        <input type="button" id="btnChoosePayer" value="Choose Payer" class="btn btn-primary" />&nbsp;
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
                                <div class="col-md-12">
                                    <div class="table-responsive">
                                        <table class="table">
                                            <tr id="trPurposeOfRemittance" runat="server">
                                                <td style="width: 12%;">
                                                    <asp:Label runat="server" ID="lblPoRemit" Text="Purpose of Remittance:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='purpose_err'>*</span>
                                                </td>
                                                <td style="width: 17%;">
                                                    <asp:DropDownList ID="purpose" runat="server" CssClass="required form-control"></asp:DropDownList>
                                                </td>
                                                <td style="width: 12%;">
                                                    <asp:Label runat="server" ID="lblRelation" Text="Relationship with Receiver:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='relationship_err'>*</span>
                                                </td>
                                                <td style="width: 17%;">
                                                    <asp:DropDownList ID="relationship" runat="server" CssClass="required form-control"></asp:DropDownList>
                                                </td>
                                                <td style="width: 12%;">
                                                    <asp:Label runat="server" ID="lblSof" Text="Source of Fund:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='sourceOfFund_err'>*</span>
                                                </td>
                                                <td style="width: 17%;">
                                                    <asp:DropDownList ID="sourceOfFund" runat="server" CssClass="required form-control"></asp:DropDownList>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>

                                <div class="col-md-12">
                                    <fieldset>
                                        <legend>questionnaire</legend>
                                        <div class="table-responsive">
                                            <table class="table">
                                                <div id="Div_Questionaries" runat="server"></div>
                                            </table>
                                        </div>
                                    </fieldset>
                                </div>
                                <div class="col-md-6">
                                    <div class="table-responsive">
                                        <table class="table">
                                            <%--tr id="trIsYourMoney" runat="server">
                                                <td style="width: 27%;">
                                                    <asp:Label runat="server" ID="lblIym" Text="Is this Your Money?:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='trIsYourMoney_err'>*</span>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="isYourMoney" runat="server"  CssClass="required form-control">
                                                    <asp:ListItem Value="">Select</asp:ListItem>
                                                    <asp:ListItem Selected="True" Value="Y">Yes</asp:ListItem>
                                                    <asp:ListItem Value="N">No</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>----%>
                                            <%--tr id="trSourceOfFund" runat="server"></tr>----%>
                                        </table>
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="table-responsive">
                                        <table class="table">
                                            <%--  <tr id="trIsPep" runat="server">
                                                <td class="col-md-6">
                                                    <asp:Label runat="server" ID="lblip" Text="Are you or any member of your family or relative politically exposed person(PEP)?:"></asp:Label>
                                                    <span runat="server" class="ErrMsg" id='trIsPep_err'>*</span>
                                                </td>
                                                <td class="col-md-6">
                                                    <asp:DropDownList ID="isPep" runat="server" CssClass="required form-control">
                                                    <asp:ListItem Value="">Select</asp:ListItem>
                                                    <asp:ListItem Selected="True" Value="Y">Yes</asp:ListItem>
                                                    <asp:ListItem Value="N">No</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>----%>
                                            <tr style="display: none">
                                                <td id="msgRecDiv">Message to Receiver:</td>
                                                <td>
                                                    <asp:TextBox ID="txtPayMsg" runat="server" CssClass="LargeTextBox form-control" TextMode="MultiLine" onblur="CheckForSpecialCharacter(this, 'Message to Receiver');"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="display: none"></td>
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

                    <div class="panel panel-default" id="additionalCDDI" style="display: none;">
                        <div class="panel-heading">
                            <h4 class="panel-title">Additional Customer Due Diligence Information -(CDDI)</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="col-md-12 form-group">
                                <div class="table-responsive">
                                    <table class="table" id="tblComplianceQsn">
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="col-md-12 form-group">
                                <input type="button" id="btnSendTxnCDDI" class="btn btn-primary" value="Send Txn" />
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
                                <div style="margin: 10px" role="tabpanel">
                                    <!-- Nav tabs -->
                                    <ul class="nav nav-tabs" role="tablist">
                                        <li role="presentation" class="active"><a href="#unMappedTab" aria-controls="uploadTab" role="tab" data-toggle="tab">Unmapped Deposit List</a>
                                        </li>
                                        <li role="presentation"><a href="#unApprovedTab" aria-controls="browseTab" role="tab" data-toggle="tab">Unapproved Deposit List</a>
                                        </li>
                                    </ul>
                                    <!-- Tab panes -->
                                    <div class="tab-content">
                                        <div role="tabpanel" class="tab-pane active" id="unMappedTab">
                                            <div class="row">
                                                <div class="form-group col-md-4">
                                                    <label class="">Tran Date:</label>
                                                    <div class="form-inline">
                                                        <div class="input-group input-append date">
                                                            <asp:TextBox runat="server" ID="tranDate" onchange="return DateValidation('tranDate','i')" MaxLength="10" AutoComplete="off" placeholder="YYYY/MM/DD" CssClass="form-control datepicker date-field required"></asp:TextBox>
                                                            <div class="input-group-addon "><i class="fa fa-calendar"></i></div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="form-group col-md-4">
                                                    <label>Particulars</label>
                                                    <asp:TextBox ID="particulars" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="form-group col-md-4">
                                                    <label>Amount</label>
                                                    <asp:TextBox ID="amount" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="form-group col-md-12">
                                                    <input type="button" id="filterBtn" value="Filter" class="btn btn-primary" />
                                                    <input type="button" id="clearBtn" value="Clear" class="btn btn-primary" />
                                                </div>
                                            </div>
                                            <div class="row form-group" style="max-height: 350px; overflow-y: scroll;">
                                                <div class="col-md-12 table-responsive">
                                                    <table class="table table-responsive table-bordered">
                                                        <thead>
                                                            <tr>
                                                                <th width="5%"><i class="fa fa-check check"></i><i class="fa fa-times uncheck" style="display: none;"></i></th>
                                                                <th width="50%">Particulars</th>
                                                                <th width="15%">Deposit Date</th>
                                                                <th width="15%">Deposit Amount</th>
                                                                <th width="15%">Withdraw Amount</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody id="UnmappedDepositMapping" runat="server">
                                                            <tr>
                                                                <td colspan="5" align="center">No Data To Display </td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group col-md-12">
                                                    <asp:Button ID="btnConfirmSave" runat="server" OnClientClick="return ConfirmSave();" CssClass="btn btn-primary" Text="Confirm Save" />
                                                </div>
                                            </div>
                                        </div>
                                        <div role="tabpanel" class="tab-pane" id="unApprovedTab">
                                            <div class="row form-group">
                                                <div class="col-md-12 table-responsive">
                                                    <table class="table table-responsive table-bordered">
                                                        <thead>
                                                            <tr>
                                                                <th width="5%"><i class="fa fa-check check"></i><i class="fa fa-times uncheck" style="display: none;"></i></th>
                                                                <th width="50%">Particulars</th>
                                                                <th width="15%">Deposit Date</th>
                                                                <th width="15%">Deposit Amount</th>
                                                                <th width="15%">Withdraw Amount</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody id="UnApprovedDepositMapping" runat="server">
                                                            <tr>
                                                                <td colspan="5" align="center">No Data To Display </td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                            <div class="row form-group">
                                                <div class="form-group col-md-12">
                                                    <input type="button" id="btnRelease" onclick="return UnmapTxn();" class="btn btn-primary" value="Unmap Data" />
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
                                            <label class="control-label">Choose Payer :<span class="ErrMsg">*</span></label>
                                        </div>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="ddlPayer" runat="server" CssClass="form-control"></asp:DropDownList>
                                            <label id="payerDetailsHistory" style="background-color: yellow"></label>
                                        </div>
                                    </div>
                                    <div class="form-group" style="display: none;">
                                        <div class="col-md-4">
                                            <label class="control-label">Payer Branch : <span class="ErrMsg">*</span></label>
                                        </div>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="ddlPayerBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-md-4">
                                            <input type="button" id="btnClosePopup" value="Ok" class="btn btn-primary disabled" data-dismiss="modal" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Modal -->
        <div class="modal fade" id="modalAdditionalDocumentRequired" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" style="font-size: 18px; font-weight: 600;">Addition Document Required</h5>
                        <%--<button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>--%>
                    </div>
                    <div class="modal-body">
                        Additional document required for this transaction, do you want to proceed?
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" id="btnHaveDocumentNo">No</button>
                        <button type="button" class="btn btn-primary" id="btnHaveDocumentYes" data-dismiss="modal">Yes</button>
                    </div>
                </div>
            </div>
        </div>
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="modal fade" id="visaStatusModal" style="margin-top: 200px;" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
                        <div class="modal-dialog modal-md" role="document">
                            <div class="modal-content">
                                <div class="modal-header" id="modelUserForSave">
                                    <center> <h2 class="modal-title"> Visa Status<%--<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>--%></h2></center>
                                </div>
                                <div class="modal-body">
                                    <div class="form-group">
                                        <div class="col-md-4">
                                            <label class="control-label">Choose Visa Status :<span class="ErrMsg">*</span></label>
                                        </div>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="visaStatusDdl" runat="server" CssClass="form-control"></asp:DropDownList>
                                            <%--<label id="payerDetailsHistory" style="background-color: yellow"></label>--%>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-md-4">
                                            <input type="button" id="btnVisaStatusClosePopup" value="Ok" class="btn btn-primary disabled" />
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
    <asp:HiddenField ID="hddChoosePayer" runat="server" />
    <asp:HiddenField ID="hddPCountryCode" runat="server" />
    <asp:HiddenField ID="hddBranchRequired" runat="server" />
    <asp:HiddenField ID="hddIsRealTimeTxn" runat="server" />
    <asp:HiddenField ID="hddFetchExrateFromPartner" runat="server" />
    <asp:HiddenField ID="hddPayoutPartner" runat="server" />
    <asp:HiddenField ID="hddTPExRate" runat="server" />
    <input type="hidden" id="hiddenExRateTP" />
    <asp:HiddenField ID="hddCustomerId" runat="server" />
    <asp:HiddenField ID="hddAgentRefId" runat="server" />
    <asp:HiddenField ID="hddLocation" runat="server" />
    <asp:HiddenField ID="hddreceiverId" runat="server" />
    <asp:HiddenField ID="hddPayerData" runat="server" />
    <asp:HiddenField ID="hddSubLocation" runat="server" />
    <asp:HiddenField ID="hddCalcBy" runat="server" />
    <asp:HiddenField ID="hddIsAdditionalCDDI" runat="server" Value="N" />
    <input type="hidden" id="hddPromotionCode" />
    <input type="hidden" id="hddPromotionAmt" />

    <script src="/AgentNew/js/SendTxn/sendSender.js?v=2.7" type="text/javascript"></script>
    <script src="/AgentNew/js/SendTxn/sendReceiver.js?v=2.6" type="text/javascript"></script>
    <script src="/AgentNew/js/SendTxn/sendTxnInfo.js?v=2.8" type="text/javascript"></script>
    <script src="/AgentNew/js/SendTxn/agentAndLocation.js?v=2.6" type="text/javascript"></script>
    <script src="/AgentNew/js/SendTxn/usableunctions.js?v=2.6" type="text/javascript"></script>
    <script type="text/javascript">
        $("#" + mId + "cancelrequestId").val('<%=GetResendId()%>');

        $.validator.messages.required = "Required!";

        $(document).ajaxComplete(function (event, request, settings) {
            $("#DivLoad").hide();
        });

        $(document).ready(function () {
            OnBehalfAgentOnChange(); // new added as its trigger point agent/branch ddl commented at top
            $("#ContentPlaceHolder1_introducerTxt_aText").prop('required', true);
            $("#ContentPlaceHolder1_branch").change(function () {
                var choosePayer = $("#" + mId + "hddChoosePayer").val();
                if (choosePayer === 'true') {
                    LoadPayerData();
                }
            });

            $(document).on('click', '#btnHaveDocumentNo', function (e) {
                $('#calc').attr('disabled', true);
                $('#btnSendTxnCDDI').attr('disabled', true);
            });

            $(document).on('click', '#btnHaveDocumentYes', function (e) {
                $('#btnSendTxnCDDI').attr('disabled', false);
            });

            $("#ContentPlaceHolder1_ddlPayer").change(function () {
                var payerId = $("#ContentPlaceHolder1_ddlPayer").val();
                if (payerId === null || payerId === "") {
                    $("#btnClosePopup").removeAttr("data-dismiss");
                    $('#btnClosePopup').addClass("btn btn-primary disabled");
                }
                else {
                    $("#btnClosePopup").attr("data-dismiss", "modal");
                    $("#btnClosePopup").removeClass("disabled");
                }
            });

            $(document).on('click', '#btnChoosePayer', function (e) {
                var choosePayer = $("#" + mId + "hddChoosePayer").val();
                var branch = $('#ContentPlaceHolder1_branch').val();
                if (choosePayer === 'true') {
                    $("#myModal1").modal('show');
                    $("#myModal1").addClass("isopen");
                }
                else {
                    alert('No payer data required for following transaction!');
                }
            });

            $("#ContentPlaceHolder1_visaStatusDdl").change(function () {
                var visaStatusId = $("#ContentPlaceHolder1_visaStatusDdl").val();
                if (visaStatusId !== null && visaStatusId !== "") {
                    $("#btnVisaStatusClosePopup").removeClass("disabled");
                }
                else {
                    $("#btnVisaStatusClosePopup").addClass("btn btn-primary disabled");
                }
            });

            $(document).on('click', '.check', function (e) {
                $(".unmapped").prop("checked", true);
                $('.check').hide();
                $('.uncheck').show();
            });

            $(document).on('click', '.uncheck', function () {
                $(".unmapped").prop("checked", false);
                $('.check').show();
                $('.uncheck').hide();
            });
            $(document).on('click', '.check', function (e) {
                $(".unapproved").prop("checked", true);
                $('.check').hide();
                $('.uncheck').show();
            });

            $(document).on('click', '.uncheck', function () {
                $(".unapproved").prop("checked", false);
                $('.check').show();
                $('.uncheck').hide();
            });

            $(window).keydown(function (event) {
                if (event.keyCode == 13) {
                    event.preventDefault();
                    return false;
                }
            });

            document.getElementById(mId + "NewCust").focus();

            $('#subLocation').hide();
            $(mId + "introducerTxt_aText").attr("placeholder", "Referral (If any)");
            $('#divHideShow').show();
            $('.displayPayerInfo').hide();
            var customerIdFromMapping = '<%=GetCustomerId()%>';

            $('#<%=ddlCustomerType.ClientID%>').change(function () {
                <%=txtSearchData.InitFunction() %>
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
            })

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
            })

            $(".readonlyOnCustomerSelect").attr("disabled", "disabled");

            var allowOnBehalf = '<%=IsAllowOnBehalf%>';
            if (allowOnBehalf == 'N') {
                $("#<%=sendingAgentOnBehalfDDL.ClientID%>").attr("disabled", "disabled");
                $('#<%=sendingAgentOnBehalfDDL.ClientID%>').val('<%=LogginBranch%>');
                OnBehalfAgentOnChange();
            }

            $("#form2").validate();
        })

        $(document).unbind('keydown').bind('keydown', function (event) {
            var doPrevent = false;
            if (event.keyCode === 8) {
                var d = event.srcElement || event.target;
                if ((d.tagName.toUpperCase() === 'INPUT' && (d.type.toUpperCase() === 'TEXT' || d.type.toUpperCase() === 'PASSWORD'))
                    || d.tagName.toUpperCase() === 'TEXTAREA' || d.type.toUpperCase() === 'SEARCH') {
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
        })

        $(document).ajaxStart(function () {
            $("#DivLoad").show();
        })

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
    </script>
    <script type="text/javascript">
        $(".js-example-basic-single").select2({
            ajax: {
                type: "POST",
                url: '<%=ResolveUrl("/AgentNew/SendTxn/SendV2.aspx")%>',
                dataType: "JSON",
                quietMillis: 100,
                data: function (params) {
                    return {
                        MethodName: 'PopulateBranch',
                        payoutPartner: $('#ContentPlaceHolder1_hddPayoutPartner').val(),
                        Bank: $('#ContentPlaceHolder1_pAgent').val(),
                        Country: $('#ContentPlaceHolder1_pCountry').val(),
                        PayMode: $('#ContentPlaceHolder1_pMode').val(),
                        searchText: params.term,
                        page: params.page
                    };
                },
                error: function (xhr, status, error) {
                    alert(error);
                },
                processResults: function (data, params) {

                    params.page = params.page || 1;
                    var results = [];
                    $.each(data, function (index, item) {
                        results.push({
                            id: item.agentId,
                            text: item.agentName
                        });
                    });

                    return {
                        results: results,
                        pagination: {
                            more: (params.page * 30) < data.total_count
                        }
                    };
                },
                cache: true
            },
            placeholder: 'Search for a Bank Branch',
            escapeMarkup: function (markup) { return markup; },
            minimumInputLength: 0,
            templateSelection: formatRepoSelection
        });

        function formatRepoSelection(repo) {
            return repo.full_name || repo.text;
        }
    </script>
</asp:Content>