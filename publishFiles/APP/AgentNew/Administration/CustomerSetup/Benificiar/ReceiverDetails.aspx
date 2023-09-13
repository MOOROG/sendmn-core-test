<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="ReceiverDetails.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CustomerSetup.Benificiar.ReceiverDetails" %>

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
    <style>
        .detailInfo {
            margin-top: 100px;
        }

        @media print {
            .page-wrapper {
                margin-top: 5px;
                min-height: inherit;
            }

            .detailInfo {
                margin-top: 1px;
            }
        }



        .tg {
            border-collapse: collapse;
            border-spacing: 0;
        }

            .tg td {
                font-family: Arial, sans-serif;
                font-size: 11px;
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

            .tg .tg-1wig {
                font-weight: bold;
                text-align: left;
                vertical-align: top
            }

            .tg .tg-g7sd {
                font-weight: bold;
                border-color: inherit;
                text-align: left;
                vertical-align: middle
            }

            .tg .tg-fymr {
                font-weight: bold;
                border-color: inherit;
                text-align: left;
                vertical-align: top
            }

            .tg .tg-0pky {
                border-color: inherit;
                text-align: left;
                vertical-align: top
            }

            .tg .tg-0lax {
                text-align: left;
                vertical-align: top
            }

            .tg .tg-7btt {
                font-weight: bold;
                border-color: inherit;
                text-align: center;
                vertical-align: top
            }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="detailInfo">
        <div class="page-wrapper">
            <table class="tg">
                <tr>
                    <th class="tg-lboi image" colspan="6">
                        <img style="height: 50px; width: 300px; position: relative; left: 20%;" src="/Images/jme.png" /></th>
                </tr>
                <tr>
                    <td class="tg-7btt" colspan="6">Customer Information</td>
                </tr>
                <tr>
                    <td class="tg-fymr">Customer Name:</td>
                    <td colspan="5" class="tg-0pky" runat="server" id="txtCustomerName"></td>
                </tr>
                <tr>
                    <td class="tg-fymr">MembershipId:</td>
                    <td colspan="5" class="tg-0pky" runat="server" id="txtMembershipId"></td>
                </tr>
                <tr>
                    <td class="tg-7btt" colspan="6">Receiver Information</td>
                </tr>

                <tr>
                    <td style="white-space:nowrap" class="tg-fymr">First Name:</td>
                    <td class="tg-0pky" runat="server" id="txtFirstName"></td>
                    <td style="white-space: nowrap" class="tg-fymr">Middle Name:</td>
                    <td class="tg-0pky" runat="server" id="txtMiddleName"></td>
                    <td style="white-space: nowrap" class="tg-fymr">Last Name:</td>
                    <td class="tg-0pky" runat="server" id="txtLastName"></td>
                </tr>
                <tr>
                    <td class="tg-g7sd">Country:</td>
                    <td colspan="2" class="tg-lboi" runat="server" id="txtCountry"></td>
                    <td style="white-space: nowrap" class="tg-fymr">Beneficiary Type :</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtBeneficiaryType"></td>

                </tr>
                <tr>
                    <td class="tg-fymr">Email:</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtEmail"></td>
                    <td class="tg-fymr">Native country:</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtNativeCountry"></td>
                </tr>
                <tr>
                    <td class="tg-fymr">Address:</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtAddress"></td>
                    <td class="tg-fymr">City:</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtCity"></td>
                </tr>
                <tr>
                    <td class="tg-fymr">Contact No:</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtContactNo"></td>
                    <td class="tg-fymr">Mobile No. :</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtMobileNo"></td>

                </tr>
                <tr>
                    <td class="tg-fymr">Id Type:</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtIdType"></td>
                    <td class="tg-fymr">Id Number :</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtIdNumber"></td>
                </tr>
                <tr>
                    <td class="tg-fymr">Place Of Issue :</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtPlaceOfIssue"></td>
                    <td style="white-space:nowrap" class="tg-fymr">Relationship To Beneficiary</td>
                    <td colspan="2" class="tg-0pky" runat="server" id="txtRelationshipToBeneficiary"></td>
                </tr>
                <tr>
                    <td class="tg-7btt" colspan="6">Transaction Information</td>
                </tr>
                <tr>
                    <td class="tg-1wig" style="white-space: nowrap">Purpose Of Remittance :</td>
                    <td colspan="2" class="tg-0lax" runat="server" id="txtPurposeOfRemittance"></td>
                    <td class="tg-1wig">Payment Mode:</td>
                    <td colspan="2" class="tg-0lax" runat="server" id="txtPaymentMode"></td>

                </tr>
                <tr>
                    <td class="tg-1wig">Agent/Bank :</td>
                    <td colspan="2" class="tg-0lax" runat="server" id="txtAgentBank"></td>
                    <td class="tg-1wig">Beneficiary A/c :</td>
                    <td colspan="2" class="tg-0lax" runat="server" id="txtBeneficiaryAc"></td>
                </tr>
                <tr>
                    <td class="tg-1wig">Agent/Bank Branch:</td>
                    <td colspan="5" class="tg-0lax" runat="server" id="txtAgentBankBranch"></td>

                </tr>
                <tr>
                    <td class="tg-1wig">Remarks :</td>
                    <td class="tg-0lax" runat="server" id="txtRemarks" colspan="5"></td>
                </tr>
            </table>
            <%-- <div class="tab-content" id="mainDiv">
                <div>
                    <div class="row">
                        <div class="col-sm-12 col-md-12">
                            <div class="register-form">
                                <div class="panel clearfix m-b-20">
                                    <div class="panel-heading">
                                        <h4>Receiver Information</h4>
                                    </div>
                                    <div class="alert alert-danger" runat="server" id="msg" visible="false"></div>
                                    <div class="panel-body row">
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Country:</label>
                                                <asp:Label CssClass="col-md-6" ID="txtcountry" runat="server"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Beneficiary Type:</label>
                                                <asp:Label CssClass="col-md-6" ID="txtBeneficiaryType" runat="server"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Email:</label>
                                                <asp:Label CssClass="col-md-6" ID="txtemail" runat="server"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label class="col-md-6">First Name:</label>
                                                <asp:Label CssClass="col-md-6" ID="txtFirstName" runat="server"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Middle Name:</label>
                                                <asp:Label runat="server" ID="txtMiddleName" name="genderList" CssClass="col-md-6">
                                                </asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Last Name:</label>
                                                <asp:Label runat="server" ID="txtLastName" name="countryList" CssClass="col-md-6">
                                                </asp:Label>
                                            </div>
                                        </div>
                                        <div hidden>
                                            <div class="form-group">
                                                <label style="background-color: white; color: red; font-size: 18px; font-weight: bold">Native Country: </label>
                                                <asp:Label ID="txtNativeCountry" runat="server" CssClass="form-control" Text=""></asp:Label>
                                            </div>
                                        </div>
                                        <div hidden>
                                            <div class="form-group">
                                                <label>Receiver Address: </label>
                                                <asp:Label runat="server" ID="txtReceiverAddress" ForeColor="Red"></asp:Label>
                                            </div>
                                        </div>
                                        <div hidden>
                                            <div class="form-group">
                                                <label>Receiver City</label>
                                                <asp:Label runat="server" ID="txtReceiverCity" ForeColor="Red"></asp:Label>
                                            </div>
                                        </div>

                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Contact No: </label>
                                                <asp:Label ID="txtcontactNo" runat="server" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Mobile No:</label>
                                                <asp:Label ID="txtmobileNo" runat="server" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Id Type:</label>
                                                <asp:Label ID="txtIdType" runat="server" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Id Number:</label>
                                                <asp:Label runat="server" ID="txtIdNumber" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Place Of Issue:</label>
                                                <asp:Label ID="txtPlaceOfIssue" runat="server" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Relationship To Beneficiary: </label>
                                                <asp:Label runat="server" MaxLength="15" ID="txtRelationShip" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="panel  clearfix m-b-20">
                                    <div class="panel-heading">
                                        <h4>Transaction Information</h4>
                                    </div>
                                    <div class="panel-body row">
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Purpose Of Remittance: </label>
                                                <asp:Label runat="server" ID="txtPurposeOfRemittance" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Payment Mode:</label>
                                                <asp:Label runat="server" ID="txtpaymentMode" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label id="verificationType" class="col-md-6">Agent/Bank:</label>
                                                <asp:Label ID="txtAgentBank" runat="server" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Beneficiary A/c:</label>
                                                <asp:Label runat="server" ID="txtBeneficairyAc" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Agent/Bank Branch:</label>
                                                <asp:Label runat="server" ID="txtAgentBankBranch" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label class="col-md-6">Remarks:</label>
                                                <asp:Label runat="server" ID="txtremarks" CssClass="col-md-6"></asp:Label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>--%>
            <%--           <div class="col-sm-12">
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
