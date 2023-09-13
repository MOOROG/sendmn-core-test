<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="PrintDetails.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CustomerSetup.CustomerRegistration.PrintDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    <title>Customer Operation</title>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery.min.js"></script>
    <script src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/functions.js"> </script>
    <script type="text/javascript">
        function PrintDiv() {
            var divToPrint = document.getElementById('mainDiv');

            var newWin = window.open('', 'Print-Window');

            newWin.document.open();

            newWin.document.write('<html><body onload="window.print()">' + divToPrint.innerHTML + '</body></html>');

            newWin.document.close();

            setTimeout(function () { newWin.close(); }, 10);
        }
    </script>
    <style type="text/css">
        .tg {
            border-collapse: collapse;
            border-spacing: 0;
        }

            .tg td {
                font-family: Arial, sans-serif;
                font-size: 10px;
                padding: 5px;
                border-style: solid;
                border-width: 1px;
                overflow: hidden;
                word-break: normal;
                border-color: black;
            }

            .tg th {
                font-family: Arial, sans-serif;
                font-size: 14px;
                font-weight: normal;
                padding: 10px 5px;
                border-style: solid;
                border-width: 1px;
                overflow: hidden;
                word-break: normal;
                border-color: black;
            }

            .tg .tg-lboi {
                border-color: inherit;
                text-align: left;
                vertical-align: middle
            }

            .tg .tg-0pky {
                border-color: inherit;
                text-align: left;
                vertical-align: top;
            }

            .tg .tg-fymr {
                font-weight: bold;
                border-color: inherit;
                text-align: left;
                vertical-align: top
            }

            .tg .tg-uzvj {
                font-weight: bold;
                border-color: inherit;
                text-align: center;
                vertical-align: middle
            }

            .tg .tg-g7sd {
                font-weight: bold;
                border-color: inherit;
                text-align: left;
                vertical-align: middle
            }

            .tg .tg-7btt {
                font-weight: bold;
                border-color: inherit;
                text-align: center;
                vertical-align: top
            }

        .detailInfo {
            margin-top: 100px;
        }

        @media print {
            .page-wrapper {
                min-height: 350px;
            }

            .detailInfo {
                margin-top: 0px;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="detailInfo">
        <div class="page-wrapper">
            <table class="tg" runat="server">
                <tr style="padding-left: 200px">
                    <th class="tg-lboi" colspan="6">
                        <img style="height: 50px; width: 300px; position: relative; left: 20%" src="/Images/jme.png" /></th>
                </tr>
                <tr>
                    <td class="tg-7btt" colspan="6">Customer Information</td>
                </tr>
                <tr>
                    <td colspan="4" class="tg-fymr"></td>
                    <td style="white-space: nowrap" class="tg-fymr">Membership Id :</td>
                    <td class="tg-0pky" runat="server" id="TxtMembershipId"></td>
                </tr>
                <tr>
                    <td style="white-space: nowrap" class="tg-fymr">Full Name:</td>
                    <td colspan="3" class="tg-0pky" runat="server" id="txtFullName"></td>
                    <td class="tg-fymr">Customer Type :</td>
                    <td colspan="1" class="tg-0pky" runat="server" id="txtCustomerType"></td>


                </tr>
                <tr>
                    <td class="tg-7btt" colspan="6">Personal Information</td>
                </tr>
                <tr>
                    <td class="tg-fymr">Country:</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtCountry"></td>
                    <td class="tg-fymr">Zip Code :</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtZipcCode"></td>

                </tr>
                <tr>
                    <td class="tg-fymr">Address:</td>
                    <td colspan="3" class="tg-0pky" runat="server" id="txtAddress"></td>
                    <td class="tg-fymr">City:</td>
                    <td colspan="1" class="tg-0pky" runat="server" id="txtCity"></td>
                </tr>
                <tr>
                    <td class="tg-fymr">Occupation :</td>
                    <td colspan="3" class="tg-0pky" runat="server" id="txtOccupation"></td>
                    <td class="tg-fymr">Gender:</td>
                    <td colspan="1" class="tg-0pky" runat="server" id="txtGender"></td>
                </tr>
                <tr>
                    <td class="tg-fymr">Source Of Fund :</td>
                    <td colspan="3" class="tg-0pky" runat="server" id="txtSourceOfFund"></td>
                    <td style="white-space:nowrap" class="tg-fymr">Native Country :</td>
                    <td colspan="1" class="tg-0pky" runat="server" id="txtNativeCountry"></td>

                </tr>
                <tr>
                    <td class="tg-fymr">Monthly Income :</td>
                    <td colspan="3" class="tg-0pky" runat="server" id="txtMonthlyIncome"></td>
                    <td class="tg-fymr">Telephone No. :</td>
                    <td colspan="1" class="tg-0pky" runat="server" id="txtTelephoneNo"></td>

                </tr>
                <tr>
                    <td class="tg-fymr">E-Mail ID:</td>
                    <td colspan="3" class="tg-0pky" runat="server" id="txtEmailId"></td>

                    <td class="tg-fymr">Mobile No. :</td>
                    <td colspan="1" class="tg-0pky" runat="server" id="txtMobileNo"></td>
                </tr>
                <tr>
                    <td class="tg-fymr">Visa Status :</td>
                    <td style="white-space:nowrap" colspan="2" class="tg-0pky" runat="server" id="txtVisaStatus"></td>
                    <td style="white-space: nowrap" class="tg-fymr">Employee Business Type :</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtEmployeeBusinessType"></td>
                </tr>
                <tr>
                    <td class="tg-fymr">Name of Employer :</td>
                    <td style="white-space:nowrap" colspan="2" class="tg-0pky" runat="server" id="txtNameOfEmployer"></td>
                    <td class="tg-fymr">SSN No. :</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtSSnNo"></td>
                </tr>
                <tr>
                    <td class="tg-fymr">Date of Birth :</td>
                    <td colspan="5" class="tg-0pky" runat="server" id="txtDateOfBirth"></td>
                </tr>
                <tr>
                </tr>
                <tr>
                    <td class="tg-fymr">Remarks:</td>
                    <td class="tg-0pky" runat="server" id="txtRemarks" colspan="5"></td>
                </tr>
                <tr>
                    <td class="tg-7btt" colspan="6">Security Information</td>
                </tr>
                <tr>
                    <td style="white-space: nowrap" class="tg-fymr">Verification Id Type:</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtIdType"></td>
                    <td class="tg-fymr">Verification Type No. :</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtIdNumber"></td>
                </tr>
                <tr>
                    <td class="tg-fymr">Issue Date:</td>
                    <td style="white-space:nowrap" colspan="2" class="tg-0pky" runat="server" id="txtIssueDate"></td>
                    <td class="tg-fymr">Expire Date:</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtExpireDate"></td>
                </tr>
                <tr>
                    <td style="white-space: nowrap" class="tg-fymr">Remittance Allowed:</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtRemittanceAllowed"></td>
                    <td class="tg-fymr">Online Login Allowed:</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtOnlineLoginAllowed"></td>
                </tr>
                <tr>
                </tr>
            </table>
            <div class="panel-body row" id="docDiv" runat="server">
            </div>
            <%--<div class="tab-content" id="mainDiv">
                <div>
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="register-form">
                                <div class="panel clearfix m-b-20">
                                    <div class="panel-heading test">
                                        <h4>Customer Information</h4>
                                    </div>
                                    <div class="alert alert-danger" runat="server" id="msg" visible="false"></div>
                                    <div class="panel-body row">
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label class="col-md-6 test">Customer Type:</label>
                                                <asp:Label CssClass="col-md-6" ID="txtCustomerType" runat="server"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Full Name:</label>
                                                <asp:Label CssClass="col-md-6" ID="fullName" runat="server"></asp:Label>
                                                <%--<asp:TextBox ID="fullName" ReadOnly="true" runat="server" CssClass="form-control"></asp:TextBox>--%>
            <%--   </div>
    </div>
    <div class="col-md-4">
        <div class="form-group">
            <label class="col-md-6">Membership No:</label>
            <asp:Label CssClass="col-md-6" ID="txtMembershipNo" runat="server"></asp:Label>
        </div>
    </div>
    </div>
                                </div>
                                <div class="panel clearfix m-b-20">
                                    <div class="panel-heading">
                                        <h4>Personal Information</h4>
                                    </div>
                                    <div class="panel-body row">
                                        <div class="col-md-4">
                                            <div class="col-md-6">
                                                <label>E-Mail ID:</label>
                                            </div>
                                            <div class="col-md-6">
                                                <asp:Label ID="email" runat="server"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Gender:</label>
                                                <asp:Label runat="server" ID="genderList" name="genderList" CssClass="col-md-6">
                                                </asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Country:</label>
                                                <asp:Label runat="server" ID="countryList" name="countryList" CssClass="col-md-6">
                                                </asp:Label>
                                            </div>
                                        </div>
                                        <div hidden>
                                            <div class="form-group">
                                                <label style="background-color: white; color: red; font-size: 18px; font-weight: bold">Account Name in Bank: </label>
                                                <asp:Label ID="lblBankAcName" runat="server" CssClass="form-control" Text=""></asp:Label>
                                            </div>
                                        </div>
                                        <div hidden>
                                            <div class="form-group">
                                                <label>Bank Name: </label>
                                                <asp:Label runat="server" ID="bankName" ForeColor="Red"></asp:Label>
                                            </div>
                                        </div>
                                        <div hidden>
                                            <div class="form-group">
                                                <label>Account Number:</label>
                                                <asp:Label runat="server" ID="accountNumber" ForeColor="Red"></asp:Label>
                                            </div>
                                        </div>

                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Zip Code: </label>
                                                <asp:Label ID="postalCode" runat="server" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Address </label>
                                                <asp:Label ID="addressLine1" runat="server" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">City:</label>
                                                <asp:Label ID="city" runat="server" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Native Country:</label>
                                                <asp:Label runat="server" ID="nativeCountry" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Telephone No.:</label>
                                                <asp:Label ID="phoneNumber" runat="server" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Mobile No.: </label>
                                                <asp:Label runat="server" MaxLength="15" ID="mobile" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Occupation.:</label>
                                                <asp:Label runat="server" ID="occupation" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
    <div class="panel  clearfix m-b-20">
        <div class="panel-heading">
            <h4>Security Information</h4>
        </div>
        <div class="panel-body row">
            <div class="col-sm-4">
                <div class="form-group">
                    <label class="col-md-6">Date of Birth: </label>
                    <asp:Label runat="server" ID="dob" CssClass="col-md-6"></asp:Label>
                </div>
            </div>
            <div class="col-sm-4">
                <div class="form-group">
                    <label class="col-md-6">Verification Id Type:</label>
                    <asp:Label runat="server" ID="idType" CssClass="col-md-6"></asp:Label>
                </div>
            </div>
            <div class="col-sm-4">
                <div class="form-group">
                    <label id="verificationType" class="col-md-6">Verification Type Id.:</label>
                    <asp:Label ID="verificationTypeNo" runat="server" CssClass="col-md-6"></asp:Label>
                </div>
            </div>
            <div class="col-sm-4">
                <div class="form-group">
                    <label class="col-md-6">Issue Date:</label>
                    <asp:Label runat="server" ID="IssueDate" CssClass="col-md-6"></asp:Label>
                </div>
            </div>
            <div class="col-sm-4">
                <div class="form-group">
                    <label class="col-md-6">Expire Date:</label>
                    <asp:Label runat="server" ID="ExpireDate" CssClass="col-md-6"></asp:Label>
                </div>
            </div>
        </div>
    </div>
    <div class="panel clearfix m-b-20" runat="server" id="showDocDiv" visible="false">
        <div class="panel-heading">
            <h4>Document Information</h4>
        </div>
        <div class="panel-body row" id="docDiv" runat="server">
        </div>
    </div>

    </div>
                        </div>
                    </div>
                </div>
            </div>--%>
            <%--      <div class="col-sm-12">
                <div class="form-group">
                    <input class="btn btn-primary" type="button" id="print" onclick="PrintDiv()" value="Print" />
                </div>
            </div>--%>
        </div>
    </div>
    <asp:HiddenField runat="server" ID="hdnCustomerId" />
    <asp:HiddenField runat="server" ID="hdnProcessDivision" />
    <asp:HiddenField runat="server" ID="hdnPartnerServiceKey" />
    <asp:HiddenField runat="server" ID="hdninstitution" />
    <asp:HiddenField runat="server" ID="hdnAccountName" />
    <asp:HiddenField runat="server" ID="hdnAccountNumber" />
    <asp:HiddenField runat="server" ID="hdnVirtualAccountNo" />
    <%-- Max-실지명의조회 --%>
    <asp:HiddenField runat="server" ID="hdnGenderCode" />
    <asp:HiddenField runat="server" ID="hdnNativeCountryCode" />
    <asp:HiddenField runat="server" ID="hdnDobYmd" />
    <asp:HiddenField runat="server" ID="hdnIdTypeCode" />
</asp:Content>
