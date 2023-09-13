<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Detail.aspx.cs" Inherits="Swift.web.AgentNew.Transaction.ApproveCustomer.Detail" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <script type="text/javascript">
        function showImage(param) {
            var imgSrc = $(param).attr("src");
            OpenInNewWindow(imgSrc);
        };
        //MakeEditable();
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
     <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Other Services</a></li>
                            <li><a href="#">Approve Customer</a></li>
                            <li class="active"><a href="#">Detail/Approve</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a href="List.aspx" aria-controls="home" role="tab" data-toggle="tab">Approve Pending</a></li>
                    <li><a href="ApprovedList.aspx">Approved List</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div>
                    <div class="row">
                        <div class="col-sm-12 col-md-12">
                            <div class="register-form">
                                <div class="panel  clearfix m-b-20">
                                    <div class="panel-heading">
                                        <h4>Customer Information</h4>
                                    </div>
                                    <div class="alert alert-danger" runat="server" id="msg" visible="false"></div>
                                    <div class="panel-body row">
                                        <div class="col-md-4">
                                            <div class="col-md-6">
                                                <label>Customer Type:</label>
                                            </div>
                                            <div class="col-md-6">
                                                <asp:Label ID="txtCustomerType" runat="server"></asp:Label>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="col-md-6">
                                                <label>Full Name:</label>
                                            </div>
                                            <div class="col-md-6">
                                                <asp:Label ID="fullName" runat="server"></asp:Label>
                                                  <%--<asp:TextBox ID="fullName" ReadOnly="true" runat="server" CssClass="form-control"></asp:TextBox>--%>
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="col-md-6">
                                                <label>Membership No:</label>
                                            </div>
                                            <div class="col-sm-6">
                                                <asp:Label ID="txtMembershipNo" runat="server"></asp:Label>
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
                                <div class="col-sm-12">
                                    <div class="form-group">
                                        <asp:Button ID="approve" runat="server" CssClass="btn btn-success" Text="Approve" OnClientClick="return confirm('Are You Sure You Want To Approve?');" OnClick="approve_Click" />
                                        &nbsp;
                                        <asp:Button ID="reject" runat="server" CssClass="btn btn-danger" Text="Reject" OnClientClick="return confirm('Are You Sure You Want To Reject?');" OnClick="reject_Click" />

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
        <%-- Max-실지명의조회 --%>
        <asp:HiddenField runat="server" ID="hdnGenderCode" />
        <asp:HiddenField runat="server" ID="hdnNativeCountryCode" />
        <asp:HiddenField runat="server" ID="hdnDobYmd" />
        <asp:HiddenField runat="server" ID="hdnIdTypeCode" />
</asp:Content>
