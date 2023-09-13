<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.OnlineCustomer.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
    <script type="text/javascript">
        $(document).ready(function () {
            $(".date-field").attr("readonly", "readonly");
            ShowCalDefault(".date-field");
			$('.date-field').mask('0000-00-00');
            $("#<% =VerificationDoc1.ClientID %>").change(function () {
                readURL(this, "verfDoc1");
            });

            $("#<% =VerificationDoc2.ClientID%>").change(function () {
                readURL(this, "verfDoc2");
            });
            $("#<% =VerificationDoc3.ClientID%>").change(function () {
                readURL(this, "verfDoc3");
            });
            $("#<% =VerificationDoc4.ClientID%>").change(function () {
                readURL(this, "verfDoc4");
            });
        });

        function CheckFormValidation() {
            var reqField = "";
            var val = $("#<% =hdnCustomerId.ClientID%>").val();
            if (val !== "") {
                reqField = "ddlBankName,accountNumber,email,emailConfirm,firstName,countryList,city,nativeCountry,mobile,occupation,idType,verificationTypeNo,";
            } else {
                reqField = "ddlBankName,accountNumber,email,emailConfirm,firstName,countryList,city,nativeCountry,mobile,occupation,idType,verificationTypeNo,VerificationDoc2,VerificationDoc3,";
            }
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
        }

        function readURL(input, id) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    $('#' + id).attr('src', e.target.result);
                }
                reader.readAsDataURL(input.files[0]);
            }
        }

        function showImage(param) {
            var imgSrc = $(param).attr("src");
            OpenInNewWindow(imgSrc);
        };

        function ManageDivs() {
            if ($('#idType').val() == '8008') {
                $('#expiryDiv').hide();
            }
            else {
                $('#expiryDiv').show();
            }
        }
    </script>
</head>
<body>
    <form id="form2" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Online Agent</a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Customer Setup</a></li>
                            <li class="active"><a href="ManageCustomer.aspx">Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li><a href="List.aspx">Approve Pending </a></li>
                        <li><a href="ApprovedList.aspx" aria-controls="home" role="tab" data-toggle="tab">Approved List </a></li>
                        <li><a href="VerifyPendingList.aspx">Verify Pending</a></li>
                        <li class="selected"><a href="#">Edit</a></li>
                    </ul>
                </div>

                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="row">
                            <div class="col-sm-12 col-md-12">
                                <div class="register-form">
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">Login Information</div>
                                        <div class="panel-body row">
                                            <div class="col-sm-6">
                                                <div class="form-group">
                                                    <label>E-Mail ID:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="email" runat="server" placeholder="Email" CssClass="form-control" />
                                                    <asp:RegularExpressionValidator ID="rev1" runat="server" Display="Dynamic"
                                                        ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                                        ControlToValidate="email"></asp:RegularExpressionValidator>
                                                </div>
                                            </div>
                                            <div class="col-sm-6">
                                                <div class="form-group">
                                                    <label>Confirm E-Mail ID:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="emailConfirm" runat="server" placeholder="Confirm Email" data-match="#email" CssClass="form-control" />
                                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" Display="Dynamic"
                                                        ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                                        ControlToValidate="emailConfirm"></asp:RegularExpressionValidator>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">Personal Information</div>
                                        <div class="panel-body row">
                                            <div class="col-sm-12">
                                                <div class="form-group">
                                                    <label>Full Name:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="firstName" runat="server" placeholder="First Name" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Gender:</label>
                                                    <asp:DropDownList runat="server" ID="genderList" name="genderList" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Country:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="countryList" name="countryList" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4" style="display: none">
                                                <div class="form-group">
                                                    <label>Post Code:<span class="errormsg">*</span> </label>
                                                    <asp:TextBox ID="postalCode" runat="server" placeholder="Post Code" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Address:</label>
                                                    <asp:TextBox ID="addressLine1" runat="server" placeholder="Address" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>City:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="city" runat="server" placeholder="City" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Native Country:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="nativeCountry" CssClass="form-control"></asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Telephone No.:</label>
                                                    <asp:TextBox ID="phoneNumber" runat="server" placeholder="Phone Number" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Mobile No.: <span class="errormsg">*</span></label>
                                                    <asp:TextBox runat="server" MaxLength="15" ID="mobile" placeholder="Mobile No" CssClass="form-control" onblur="CheckForSpecialCharacter(this, 'Mobile Number');" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Occupation.:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="occupation" CssClass="form-control"></asp:DropDownList>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">Security Information</div>
                                        <div class="panel-body row">
                                            <div class="col-sm-4" style="display: none">
                                                <div class="form-group">
                                                    <label>Date of Birth: <span class="errormsg">*</span></label>
                                                    <div class="form-inline">
                                                        <div class="input-group input-append date dpYears">
                                                            <asp:TextBox runat="server" ID="dob" CssClass="form-control date-field"></asp:TextBox>
                                                            <div class="input-group-addon"><i class="fa fa-calendar"></i></div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Verification Id Type:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="idType" CssClass="form-control" onchange="ManageDivs();"></asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label id="verificationType">Verification Type No.:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="verificationTypeNo" runat="server" MaxLength="14" placeholder="Verification Type Number" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-4" style="display: none">
                                                <div class="form-group">
                                                    <label>Issue Date:<span class="errormsg">*</span></label>
                                                    <div class="form-inline">
                                                        <div class="input-group input-append date">
                                                            <asp:TextBox runat="server" ID="IssueDate" CssClass="form-control date-field"></asp:TextBox>
                                                            <div class="input-group-addon"><i class="fa fa-calendar"></i></div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-sm-4" id="expiryDiv" runat="server">
                                                <div class="form-group">
                                                    <label>Expire Date:<span class="errormsg">*</span></label>
                                                    <div class="form-group">
                                                        <div class="input-group input-append date">
                                                            <asp:TextBox runat="server" ID="ExpireDate" CssClass="form-control date-field"></asp:TextBox>
                                                            <div class="input-group-addon"><i class="fa fa-calendar"></i></div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row"></div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Primary Bank Name :<span class="errormsg">*</span></label>
                                                </div>
                                                <div class="form-group">
                                                    <asp:DropDownList ID="ddlBankName" runat="server" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-4">
                                                <div class="form-group">
                                                    <label>Primary Account Number:<span class="errormsg">*</span></label>
                                                </div>
                                                <div class="form-group">
                                                    <asp:TextBox ID="accountNumber" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="row"></div>

                                            <div class="col-sm-3">
                                                <div class="form-group">
                                                    <label>National/Alien Reg ID Front:<span class="errormsg">*</span></label>
                                                    <asp:FileUpload ID="VerificationDoc1" runat="server" CssClass="form-control" />
                                                    <asp:Image runat="server" ID="verfDoc1" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                </div>
                                            </div>
                                            <div class="col-sm-3">
                                                <div class="form-group">
                                                    <%--<label>Visa Page:</label>--%>
                                                    <label>National/Alien Reg ID Back:<span class="errormsg">*</span></label>
                                                    <asp:FileUpload ID="VerificationDoc2" runat="server" CssClass="form-control" />
                                                    <asp:Image runat="server" ID="verfDoc2" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                </div>
                                            </div>
                                            <div class="col-sm-3">
                                                <div class="form-group">
                                                    <%--<label>Passport:</label>--%>
                                                    <label>Passbook (if available):</label>
                                                    <asp:FileUpload ID="VerificationDoc3" runat="server" CssClass="form-control" />
                                                    <asp:Image runat="server" ID="verfDoc3" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                </div>
                                            </div>
                                            <div class="col-sm-3">
                                                <div class="form-group">
                                                    <%--<label>Passport:</label>--%>
                                                    <label>Customer Selfie:</label>
                                                    <asp:FileUpload ID="VerificationDoc4" runat="server" CssClass="form-control" />
                                                    <asp:Image runat="server" ID="verfDoc4" ImageUrl="noimage.jpg" Style="height: 120px; width: 120px; object-fit: contain;" onclick="showImage(this);" />
                                                </div>
                                            </div>
                                            <div class="col-sm-12" runat="server">
                                                <div class="form-group">
                                                    <asp:Button ID="register" runat="server" CssClass="btn btn-primary m-t-25" Text="Submit" OnClientClick="return CheckFormValidation()" OnClick="register_Click" />
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
        <asp:HiddenField runat="server" ID="hddIdNumber" />
        <asp:HiddenField runat="server" ID="hddIsApproved" />
        <asp:HiddenField runat="server" ID="hdnVerifyDoc4" />
        <asp:HiddenField runat="server" ID="hdnVerifyDoc1" />
        <asp:HiddenField runat="server" ID="hdnVerifyDoc2" />
        <asp:HiddenField runat="server" ID="hdnVerifyDoc3" />
        <asp:HiddenField runat="server" ID="hdnCustomerId" />
    </form>
</body>
</html>