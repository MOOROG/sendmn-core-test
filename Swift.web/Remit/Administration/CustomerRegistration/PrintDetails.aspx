<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PrintDetails.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerRegistration.PrintDetails" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
            margin-top: 0px;
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
</head>
<body>
    <form id="form1" runat="server">
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
    </form>
</body>
</html>
