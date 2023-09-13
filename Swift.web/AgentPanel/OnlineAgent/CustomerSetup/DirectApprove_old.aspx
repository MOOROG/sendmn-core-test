﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DirectApprove.aspx.cs" Inherits="Swift.web.AgentPanel.OnlineAgent.CustomerSetup.DirectApprove" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Customer Operation</title>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery.min.js"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../js/functions.js"> </script>
    <script type="text/javascript">
        function showImage(param) {
            var imgSrc = $(param).attr("src");
            OpenInNewWindow(imgSrc);
        };
        $(document).ready(function () {
            $("#<%=chkConfirm.ClientID%>").change(function () {
                $("#<%=approve.ClientID%>").hide();
                if (this.checked) {
                    $("#<%=approve.ClientID%>").show();
                }
            });
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                            <li><a href="#">Online Customers</a></li>
                            <li class="active"><a href="#">Detail/Approve</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li class="selected"><a href="List.aspx" aria-controls="home" role="tab" data-toggle="tab">UnApprove Pending </a></li>
                    <li><a href="ListApproved.aspx">Approved List</a></li>
                    <li><a href="Manage.aspx">Customer Operation</a></li>
                    <li role="presentation" class="active"><a href="javascript:void(0);">Detail/Approve</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div>
                    <div class="row">
                        <div class="col-sm-12 col-md-12">
                            <div class="register-form">
                                <div class="panel  clearfix m-b-20">
                                    <div class="panel-heading">
                                        <h4>Login Information</h4>
                                    </div>
                                    <div class="panel-body row">
                                        <div class="col-md-8">
                                            <div class="col-md-6">
                                                <label>E-Mail ID:</label>
                                                <asp:Label ID="email" runat="server" placeholder="Email"></asp:Label>
                                            </div>
                                            <div class="col-sm-6">
                                                <label id="msg" runat="server" style="background-color: white; color: red; font-size: 16px" visible="false"></label>
                                            </div>
                                        </div>

                                        <div class="col-md-4">
                                            <div class="col-md-6" style="background-color: white; color: red; font-size: 18px; font-weight: bold">Wallet Number: </div>
                                            <div class="col-md-6" style="background-color: white; color: red; font-size: 18px; font-weight: bold">
                                                <div id="walletNumber" runat="server"></div>
                                            </div>
                                        </div>

                                    </div>
                                </div>


                                <div class="panel clearfix m-b-20">
                                    <div class="panel-heading">
                                        <h4>Personal Information</h4>
                                    </div>
                                    <div class="panel-body row">
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Full Name:</label>
                                                <asp:Label ID="fullName" runat="server" placeholder="Full Name" CssClass=""></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Gender:</label>
                                                <asp:Label runat="server" ID="genderList" name="genderList" CssClass="">
                                                </asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Country:</label>
                                                <asp:Label runat="server" ID="countryList" name="countryList" CssClass="">
                                                </asp:Label>
                                            </div>
                                        </div>


                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label style="background-color: white; color: red; font-size: 18px; font-weight: bold">Account Name in Bank: </label>
                                                <asp:Label ID="lblBankAcName" runat="server" CssClass="form-control" Text=""></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Bank Name: </label>
                                                <asp:Label runat="server" ID="bankName" ForeColor="Red"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Account Number:</label>
                                                <asp:Label runat="server" ID="accountNumber" ForeColor="Red"></asp:Label>
                                            </div>
                                        </div>


                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Post Code: </label>
                                                <asp:Label ID="postalCode" runat="server" placeholder="Post Code" CssClass=""></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Address </label>
                                                <asp:Label ID="addressLine1" runat="server" placeholder="Address" CssClass=""></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>City:</label>
                                                <asp:Label ID="city" runat="server" placeholder="City" CssClass=""></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Native Country:</label>
                                                <asp:Label runat="server" ID="nativeCountry" CssClass=""></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Telephone No.:</label>
                                                <asp:Label ID="phoneNumber" runat="server" placeholder="Phone Number" CssClass=""></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Mobile No.: </label>
                                                <asp:Label runat="server" MaxLength="15" ID="mobile" placeholder="Mobile No" CssClass=""></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Occupation.:</label>
                                                <asp:Label runat="server" ID="occupation" CssClass=""></asp:Label>
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
                                                <label>Date of Birth: </label>
                                                <asp:Label runat="server" ID="dob"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Verification Id Type:</label>
                                                <asp:Label runat="server" ID="idType"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label id="verificationType">Verification Type No.:</label>
                                                <asp:Label ID="verificationTypeNo" runat="server" placeholder="Verification Type Number" CssClass=""></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Issue Date:</label>
                                                <asp:Label runat="server" ID="IssueDate"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-sm-4">
                                            <div class="form-group">
                                                <label>Expire Date:</label>
                                                <asp:Label runat="server" ID="ExpireDate" CssClass=" date-field"></asp:Label>
                                            </div>
                                        </div>

                                        <div class="row col-sm-12">
                                            <div class="col-sm-3">
                                                <div class="form-group">
                                                    <label>National/Alien Reg ID Front:</label>
                                                    <asp:Image runat="server" ID="verfDoc1" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                </div>
                                            </div>
                                            <div class="col-sm-3">
                                                <div class="form-group">
                                                    <label>National/Alien Reg ID Back:</label>
                                                    <asp:Image runat="server" ID="verfDoc2" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                </div>
                                            </div>
                                            <div class="col-sm-3">
                                                <div class="form-group">
                                                    <label>Passbook:</label>
                                                    <asp:Image runat="server" ID="verfDoc3" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                </div>
                                            </div>
                                            <div class="col-sm-3">
                                                <div class="form-group">
                                                    <label>Selfie Image:</label>
                                                    <asp:Image runat="server" ID="verifyDoc4" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-sm-12" runat="server">
                                            <div class="form-group">
                                                <asp:CheckBox ID="chkConfirm" Text="Original ID verified at Branch" runat="server" />
                                            </div>
                                        </div>
                                        <div class="col-sm-12" runat="server" id="btnApprove">
                                            <div class="form-group">
                                                <asp:Button ID="approve" Style="display: none" runat="server" CssClass="btn btn-success" Text="Approve" OnClientClick="return confirm('Are You Sure You Want To Approve?');" OnClick="approve_Click" />
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
        <asp:HiddenField runat="server" ID="hdnCustomerId" />
        <asp:HiddenField runat="server" ID="hdnProcessDivision" />
        <asp:HiddenField runat="server" ID="hdnPartnerServiceKey" />
        <asp:HiddenField runat="server" ID="hdninstitution" />
        <asp:HiddenField runat="server" ID="hdnAccountName" />
        <asp:HiddenField runat="server" ID="hdnAccountNumber" />
        <asp:HiddenField runat="server" ID="hdnVirtualAccountNo" />

    </form>
</body>
</html>


