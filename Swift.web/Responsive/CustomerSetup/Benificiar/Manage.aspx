<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Responsive.CustomerSetup.Benificiar.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            PaymentChage();
            PayoutPatnerChange();
        });
        function PaymentChage() {
            $(".showOnBankMethod").hide();
            paymentMode = $("#<% =ddlPaymentMode.ClientID%>").val();
            if (paymentMode !== "" && paymentMode !== null) {
                if (paymentMode == "2") {
                    return $(".showOnBankMethod").show();
                } else {
                    return $('.clearOnNotBank').val('');
                }
            }
        }
        function PayoutPatnerChange() {
            $("#<%=txtBankName.ClientID%>").attr("readonly", false);
            $("#<%=txtBankName.ClientID%>").val('');
            payoutPatnerId = $("#<% =ddlPayoutPatner.ClientID%>").val();
            if (payoutPatnerId !== "" && payoutPatnerId !== null) {
                $("#<%=txtBankName.ClientID%>").attr("readonly", true);
                payoutName = $("#<% =ddlPayoutPatner.ClientID%> :selected").text();
                return $("#<%=txtBankName.ClientID%>").val(payoutName);
            }
        }
        function CheckFormValidation() {

            paymentMode = $("#<% =ddlPaymentMode.ClientID%>").val();
            if (paymentMode == "2") {
                bankName = $("#<%=txtBankName.ClientID%>").val();
                if (bankName === "" || bankName === null) {
                    alert("Bank Name Is Required");
                    $("#<%=txtBankName.ClientID%>").focus();
                    return false;
                }
            }
            var reqField = "ddlCountry,ddlBenificiaryType,txtReceiverFName,txtReceiverAddress,txtSenderMobileNo,ddlPaymentMode,";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            clearInputFields.forEach(function (fields) {
                $(fields).val('');
            });
            return true;
        };
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <%-- <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                            <li class="active"><a href="CustomerDocument.aspx">Customer Document </a></li>
                        </ol>--%>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation"><a href="List.aspx?customerId=<%=hideCustomerId.Value %>">Beneficiary List</a></li>
                        <li class="active"><a href="Manage.aspx?receiverId=<%=hideBenificialId.Value %>&customerId=<%=hideCustomerId.Value %>">Beneficiary Setup </a></li>
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
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Beneficiary Setup:
                                                <label id="txtCustomerName" runat="server"></label>
                                                (<label><%=hideMembershipId.Value %></label>) </h4>
                                        </div>
                                        <div class="panel-body row">
                                            <div class="col-md-12" id="msgDiv" runat="server" visible="false" style="background-color: red;">
                                                <asp:Label ID="msgLabel" runat="server" ForeColor="White"></asp:Label>
                                            </div>
                                            <p class="col-md-12"><b>Receiver Details</b></p>
                                            <%--body part--%>
                                            <asp:HiddenField ID="hideCustomerId" runat="server" />
                                            <asp:HiddenField ID="hideBenificialId" runat="server" />
                                            <asp:HiddenField ID="hideMembershipId" runat="server" />
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label>Country:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList ID="ddlCountry" CssClass="form-control" runat="server" OnSelectedIndexChanged="ddlCountry_SelectedIndexChanged" AutoPostBack="true">
                                                        <asp:ListItem Text="Select.."></asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label>Beneficiary Type:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList ID="ddlBenificiaryType" CssClass="form-control" runat="server">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label>Email:</label>
                                                    <asp:TextBox ID="txtEmail" TextMode="Email" runat="server" CssClass="form-control"></asp:TextBox>
                                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" Display="Dynamic"
                                                        ErrorMessage="Invalid Email Id!" ForeColor="Red" SetFocusOnError="True" ValidationGroup="send"
                                                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" CssClass="inv"
                                                        ControlToValidate="txtEmail"></asp:RegularExpressionValidator>
                                                </div>
                                            </div>
                                            <div class="col-md-12">
                                                <div class="form-group">
                                                    <label>Receiver Name:</label>
                                                    <div class="row">
                                                        <div class="col-md-4">
                                                            <label class="col-md-4">First Name:<span class="errormsg">*</span></label>
                                                            <asp:TextBox runat="server" ID="txtReceiverFName" CssClass="form-control" placeholder="Receiver First Name"></asp:TextBox>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label class="col-md-4">Mid Name:</label>
                                                            <asp:TextBox runat="server" ID="txtReceiverMName" CssClass="form-control" placeholder="Receiver Mid Name"></asp:TextBox>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label class="col-md-4">Last Name:</label>
                                                            <asp:TextBox runat="server" ID="txtReceiverLName" CssClass="form-control" placeholder="Receiver Last Name"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label>Receiver Address:<span class="errormsg">*</span></label>
                                                    <asp:TextBox runat="server" ID="txtReceiverAddress" CssClass="form-control" placeholder="Receiver Address"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label>Receiver City:</label>
                                                    <asp:TextBox runat="server" ID="txtReceiverCity" CssClass="form-control" placeholder="Receiver City"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label>Contact No:</label>
                                                    <asp:TextBox runat="server" ID="txtContactNo" CssClass="form-control" placeholder="Receiver Contact No"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label>Mobile No:<span class="errormsg">*</span></label>
                                                    <asp:TextBox runat="server" ID="txtSenderMobileNo" CssClass="form-control" placeholder="Sender Mobile No"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label>Relationship To Beneficiary:</label>
                                                    <asp:DropDownList ID="ddlRelationship" CssClass="form-control" runat="server">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label>Place of Issue:</label>
                                                    <asp:TextBox runat="server" ID="txtPlaceOfIssue" CssClass="form-control" placeholder="Place Of Issue"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-md-12">
                                                <div class="row">
                                                    <div class="col-md-4">
                                                        <label>Id Type:</label>
                                                        <asp:DropDownList ID="ddlIdType" CssClass="form-control" runat="server">
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <label>Id Value:</label>
                                                        <div class="form-group">
                                                            <asp:TextBox runat="server" ID="txtIdValue" CssClass="form-control" placeholder="Any Photo Id"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="clearfix"></div>
                                            <p class="col-md-12">
                                                <label class="">Transaction Information</label>
                                            </p>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label>Purpose of Remitance:</label>
                                                    <asp:DropDownList ID="ddlPurposeOfRemitance" runat="server" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label>Payment Mode:</label>
                                                    <asp:DropDownList ID="ddlPaymentMode" runat="server" CssClass="form-control" onchange="PaymentChage()">
                                                        <asp:ListItem Text="Select Country." Value=""></asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-md-4 showOnBankMethod" hidden="hidden">
                                                <div class="form-group">
                                                    <label>Payout Partner/Bank:</label>
                                                    <asp:DropDownList ID="ddlPayoutPatner" onchange="PayoutPatnerChange()" runat="server" CssClass="form-control clearOnNotBank">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-md-4 showOnBankMethod" hidden="hidden">
                                                <div class="form-group">
                                                    <label>Bank Name:<span><i>Type if Not Found</i></span></label>
                                                    <asp:TextBox ID="txtBankName" runat="server" CssClass="form-control clearOnNotBank"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-md-4 showOnBankMethod" hidden="hidden">
                                                <div class="form-group">
                                                    <label>Beneficiary A/c #:</label>
                                                    <asp:TextBox ID="txtBenificaryAc" runat="server" CssClass="form-control clearOnNotBank"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <label>Location:(used for webAgent)</label>
                                                    <asp:TextBox ID="txtBankLocation" runat="server" CssClass="form-control">
                                                    </asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-md-12">
                                                <div class="form-group">
                                                    <label>Remarks:</label>
                                                    <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-sm-12" runat="server">
                                                <div class="form-group">
                                                    <asp:Button ID="register" runat="server" CssClass="btn btn-primary m-t-25" Text="Submit" OnClientClick="return CheckFormValidation()" OnClick="register_Click" />
                                                </div>
                                            </div>
                                            <%--End body part--%>
                                        </div>
                                    </div>
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
