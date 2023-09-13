<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VerifyUser.aspx.cs" Inherits="Swift.web.AgentPanel.OnlineAgent.CustomerSetup.VerifyUser" %>

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
    <script src="../../../js/swift_calendar.js"></script>
    <script src="../../../js/functions.js"> </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script>
		function showImage(param) {
			var imgSrc = $(param).attr("src");
			OpenInNewWindow(imgSrc);
		};
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div class="page-wrapper">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="page-title">
                            <h1></h1>
                            <ol class="breadcrumb">
                                <li><a href="javascript:void(0);" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                <li><a href="javascript:void(0)">Online Agent</a></li>
                                <li><a href="javascript:void(0)">Customer Setup</a></li>
                                <li class="active"><a href="javascript:void(0)">Verify</a></li>
                            </ol>
                        </div>
                    </div>
                </div>
                <div class="report-tab">
                    <!-- Nav tabs -->
                    <div class="listtabs">
                        <ul class="nav nav-tabs" role="tablist">
                            <li><a href="List.aspx" aria-controls="home" role="tab" data-toggle="tab">Customer List</a></li>
                            <li><a href="Manage.aspx">Customer Operation</a></li>
                            <li role="presentation" class="active"><a href="javascript:void(0);">Verify Customer</a></li>
                        </ul>
                    </div>
                    <div class="tab-content">
                        <div role="tabpanel" id="Manage">
                            <div class="row">
                                <div class="col-sm-12 col-md-12">
                                    <div class="register-form">
                                        <div class="panel  clearfix m-b-20">
                                            <div class="panel-heading">
                                                <h4>Login Information</h4>
                                            </div>
                                            <div class="panel-body row">
                                                <div class="col-sm-6">
                                                    <div class="">
                                                        <label>E-Mail ID:</label>
                                                        <asp:Label ID="email" runat="server" placeholder="Email"></asp:Label>
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
                                                <div class="row"></div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <label>National/Alien Reg ID Front:</label>
                                                        <%--<asp:FileUpload ID="VerificationDoc3" runat="server" CssClass="form-control" />--%>
                                                        <asp:Image runat="server" ID="verfDoc1" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <%--<label>Visa Page:</label>--%>
                                                        <label>National/Alien Reg ID Back:</label>
                                                        <%--<asp:FileUpload ID="VerificationDoc2" runat="server" CssClass="form-control" />--%>
                                                        <asp:Image runat="server" ID="verfDoc2" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-4">
                                                    <div class="form-group">
                                                        <%--<label>Passport:</label>--%>
                                                        <label>Passbook:</label>
                                                        <%--<asp:FileUpload ID="VerificationDoc1" runat="server" CssClass="form-control" />--%>
                                                        <asp:Image runat="server" ID="verfDoc3" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-12">
                                                    <div class="form-group">
                                                        <asp:Button ID="verify" runat="server" CssClass="btn btn-success" Text="Verify" OnClientClick="return confirm('Are You Sure About The Confirmation?');" OnClick="verify_Click" />
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
        </div>

        <asp:HiddenField runat="server" ID="hdnCustomerId" />
        <script>
			$(document).ready(function () {
				$('.date-field').mask('0000-00-00');
				$('#form1 input').attr('readonly', 'readonly');
			});
        </script>
    </form>
</body>
</html>