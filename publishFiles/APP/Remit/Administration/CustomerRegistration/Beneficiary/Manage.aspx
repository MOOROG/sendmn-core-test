<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerRegistration.Beneficiary.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="icon" type="image/ico" sizes="32x32" href="/ui/index/images/favicon.ico" />
    <!-- Bootstrap -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/css/receipt.css" rel="stylesheet" />
    <link href="/css/receiver.css" rel="stylesheet">
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/AgentNew/css/ie9.css" rel="stylesheet" />
    <link href="/AgentNew/css/signature-pad.css" type="text/css" rel="stylesheet" />

    <%--<link href="/css/swift_component.css" rel="stylesheet" type="text/css" />--%>
    <link href="/ui/css/menu1.css" rel="stylesheet" />
    <link href="/css/TranStyle.css" rel="stylesheet" type="text/css" />
    <link href="/css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <link href="/js/jQuery/jquery.gritter.css" rel="stylesheet" type="text/css" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" />
    <%--    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />--%>
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <%-- <link href="/css/signature-pad.css" rel="stylesheet" />--%>
    <script src="/ui/js/jquery.min.js"></script>
    <%--<script src="../js/jQuery/jquery.min.js"></script>--%>
    <script src="/ui/bootstrap/js/bootstrap.min.js" type="text/javascript"> </script>
    <script src="/AgentNew/js/functions.js"></script>
    <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="/AgentNew/js/swift_calender.js"></script>
    <script src="/js/browserDetect.js"></script>
    <script src="/AgentNew/js/signature_pad.umd.js"></script>
    <%-- <script src="js/jquery.validate.js" type="text/javascript"></script>--%>
    <script src="/ui/js/jquery.validate.js" type="text/javascript"></script>
    <script src="/js/popper/popper.min.js"></script>
    <script src="/ui/js/metisMenu.min.js"></script>

    <%-- <script src="/ui/js/pickers-init.js"></script>--%>
    <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/css/intlTelInput.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/js/intlTelInput.min.js"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {

            $(document).on('change', '#<%=ddlPayoutPatner.ClientID%>', function () {
                var bankId = $('#<%=ddlPayoutPatner.ClientID%> option:selected').val();
                var countryId = $('#<%=ddlCountry.ClientID%> option:selected').val();
                var pMode = $('#<%=ddlPaymentMode.ClientID%> option:selected').val();
                var data = { MethodName: "GetBankBranch", bankId: bankId, countryId: countryId, pMode: pMode, branchId: null };
                $.post("", data, function (response) {
                    PopulateBranchDDL(response, "<%=DDLBankBranch.ClientID%>", "Select Branch");
                });
            });

            hideShowMenuBar();
        });

        function CheckForMobileNumber(nField, fieldName) {
            var numberPattern = /^[+]?[0-9]{6,16}$/;
            test = numberPattern.test(nField.value);
            if (!test) {
                alert(fieldName + ' Is Not Valid !');
                nField.value = '';
                return false
            }
            return true;
        }

        function CheckForPhoneNumber(nField, fieldName) {
            var numberPattern = /^[+]?[0-9]{6,15}$/;
            test = numberPattern.test(nField.value);
            if (!test) {
                alert(fieldName + ' Is Not Valid !');
                nField.value = '';
                return false
            }
            return true;
        }
        function hideShowMenuBar() {
            var addType = '<%=GetReceiverAddType()%>';
            if (addType === "s") {
                $('.navbar.navbar-inverse.yamm.navbar-fixed-top.main-nav').hide();
                $('.listtabs').hide();
            }
        }

        function PopulatePaymentMethod() {
            var data =
            {
                MethodName: "PopulatePaymentMode",
                country: $("#<%=ddlCountry.ClientID%> option:selected").text()
            };
            $.ajax({
                url: "",
                type: "post",
                data: data,
                dataType: "json",
                async: false,
                success: function (response) {
                    PopulateDDL(response, '<%=ddlPaymentMode.ClientID%>', "", "", "");
                },
                error: function (error) {
                    alert("Something went wrong!!!")
                }
            })
        }

        function PopulatePayoutPartner() {
            $('#<%=ddlPayoutPatner.ClientID%>').empty();
            $('#<%=DDLBankBranch.ClientID%>').empty();
            var pmode = $("#<%=ddlPaymentMode.ClientID%> option:selected").val();
            if (pmode == "2") {
                $("#<%=receiverAccountNo.ClientID%>").show();
                //$("#agentBankBranchDiv").show();
            }
            else {
                $("#<%=receiverAccountNo.ClientID%>").hide();
                $("#<%=DDLBankBranch.ClientID%>").val('');
                //$("#agentBankBranchDiv").hide();
            }
            var data =
            {
                MethodName: "PopulatePayoutPartner",
                country: $("#<%=ddlCountry.ClientID%> option:selected").val(),
                paymentMode: $("#<%=ddlPaymentMode.ClientID%> option:selected").text()
            };
            $.post("", data, function (response) {
                PopulateDDL(response, '<%=ddlPayoutPatner.ClientID%>', "", "", "");
            }).fail(function (error) {
                alert("Something went wrong!!!");
            });
        }

        function PopulateBranchDDL(populateData, ddlId, defaultText) {
            var myDDL = document.getElementById(ddlId);
            $(myDDL).empty();
            var option;
            if (defaultText != '') {
                option = document.createElement('option');
                option.text = defaultText;
                option.value = '';
                myDDL.options.add(option);
            }
            for (var i = 0; i < populateData.length; i++) {
                option = document.createElement('option');
                option.text = populateData[i].agentName;
                option.value = populateData[i].agentId;
                try {
                    myDDL.options.add(option);
                } catch (e) {
                    alert(e.message);

                }
            }
        }

        function PopulateDDL(populateData, ddlId, selectedId, selectedText, defaultText) {
            var myDDL = document.getElementById(ddlId);
            $(myDDL).empty();
            var option;
            if (defaultText != '') {
                option = document.createElement('option');
                option.text = defaultText;
                option.value = '';

                myDDL.options.add(option);
            }
            for (var i = 0; i < populateData.length; i++) {
                option = document.createElement('option');
                if (ddlId == '<%=ddlPaymentMode.ClientID%>') {
                    option.text = populateData[i].Value;
                    option.value = populateData[i].Key;

                } else {
                    option.text = populateData[i].AGENTNAME;
                    option.value = populateData[i].bankId;
                }

                if (selectedId != '' && selectedId == populateData[i].value) {
                    option.selected = true;
                } else if (selectedText != '' && selectedText.toUpperCase() == populateData[i].Key.toUpperCase()) {
                    option.selected = true;
                }

                try {
                    myDDL.options.add(option);
                } catch (e) {
                    alert(e.message);

                }
            }
        }
        function getUrlVars() {
            var vars = [], hash;
            var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
            for (var i = 0; i < hashes.length; i++) {
                hash = hashes[i].split('=');
                vars.push(hash[0]);
                vars[hash[0]] = hash[1];
            }
            return vars;
        }

        function showTextBox() {
            var res = $("#<% =ddlRelationship.ClientID%>").val();
            if (res.toUpperCase() == "11065") {
                $("#<%=otherRelationDiv.ClientID%>").show();
            }
            else {
                $("#<%=otherRelationDiv.ClientID%>").hide();
            }
        }
        function CheckFormValidation() {
            var input = $("#<%=txtSenderMobileNo.ClientID%>");
            var mobileNo = input.val();
            if (mobileNo != '') {
                var countryCode = $('.country.active .dial-code').text();
                var maxLength = input.attr('maxLength');
                if (mobileNo.indexOf(countryCode) < 0) {
                    mobileNo = countryCode + mobileNo;
                }
                if (mobileNo.length > maxLength) {
                    alert('Mobile No. Can allow input maxmum ' + maxLength + ' digit only');
                    $("#<%=txtSenderMobileNo.ClientID%>").val('');
                    return false;
                }
                $("#<%=txtSenderMobileNo.ClientID%>").val(mobileNo);
                var numberPattern = /^[+]?[0-9]{6,16}$/;
                test = numberPattern.test(mobileNo);
                if (!test) {
                    alert('Mobile No Is Not Valid !');
                    input.val('');
                    return false
                }
            }

            paymentMode = $("#<% =ddlPaymentMode.ClientID%>").val();
            var reqField = "";
            var requiredElement = document.getElementsByClassName('required');
            for (var i = 0; i < requiredElement.length; ++i) {
                var item = requiredElement[i].id;
                reqField += item + ",";
            }
            idTypeVal = $('#<%=ddlIdType.ClientID%>').val();
            idTypeNumber = $('#<%=txtIdValue.ClientID%>').val();
            if ((idTypeVal !== null && idTypeVal !== "" && idTypeVal !== "0") || (idTypeNumber !== null && idTypeNumber !== "" && idTypeNumber !== "0")) {
                reqField +="<%=ddlIdType.ClientID%>,<%=txtIdValue.ClientID%>,";
            }
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            save();
        };
        function save() {
            var addType = '<%=GetReceiverAddType()%>';
            var bankBranch = $("#<%=DDLBankBranch.ClientID%> option:selected").val();
            if (bankBranch === undefined || bankBranch === null || bankBranch.length < 0) {
                bankBranch = "";
            }
            var data =
            {
                MethodName: "SaveReceiverDetails",
                nativeCountry: $("#<%=ddlNativeCountry.ClientID%>").val(),
                paymentMode: $("#<%=ddlPaymentMode.ClientID%> option:selected").val(),
                PayoutPatner: $("#<%=ddlPayoutPatner.ClientID%> option:selected").val(),
                Country: $("#<%=ddlCountry.ClientID%> option:selected").text().split('(')[0],
                BenificiaryType: $("#<%=ddlBenificiaryType.ClientID%> option:selected").val(),
                Email: $("#<%=txtEmail.ClientID%>").val(),
                ReceiverFName: $("#<%=txtReceiverFName.ClientID%>").val(),
                ReceiverMName: $("#<%=txtReceiverMName.ClientID%>").val(),
                ReceiverLName: $("#<%=txtReceiverLName.ClientID%>").val(),
                ReceiverAddress: $("#<%=txtReceiverAddress.ClientID%>").val(),
                ReceiverCity: $("#<%=txtReceiverCity.ClientID%>").val(),
                ContactNo: $("#<%=txtContactNo.ClientID%>").val(),
                SenderMobileNo: $("#<%=txtSenderMobileNo.ClientID%>").val(),
                Relationship: $("#<%=ddlRelationship.ClientID%> option:selected").val(),
                PlaceOfIssue: $("#<%=txtPlaceOfIssue.ClientID%>").val(),
                TypeId: $("#<%=ddlIdType.ClientID%> option:selected").val(),
                TypeValue: $("#<%=txtIdValue.ClientID%>").val(),
                BenificaryAc: $("#<%=receiverAccountNo.ClientID%>").val(),
                PurposeOfRemitance: $("#<%=ddlPurposeOfRemitance.ClientID%>").val(),
                BankLocation: bankBranch,
                BankName: $("#<%=txtBankName.ClientID%>").val(),
                BenificaryAc: $("#<%=txtBenificaryAc.ClientID%>").val(),
                Remarks: $("#<%=txtRemarks.ClientID%>").val(),
                OtherRelationDescription: $("#<%=otherRelationshipTextBox.ClientID%>").val(),
                membershipId: $("#<%=hideMembershipId.ClientID%>").val(),
                ReceiverId: $("#<%=hideBenificialId.ClientID%>").val(),
                hideCustomerId: $("#<%=hideCustomerId.ClientID%>").val(),
                hideBenificialId: $("#<%=hideBenificialId.ClientID%>").val()
            };
            $.ajax({
                url: "",
                type: "post",
                data: data,
                dataType: "json",
                success: function (response) {
                    if (response.ErrorCode == "1") {
                        alert(response.Msg);
                        return false;
                    } else {
                        if (addType.toLowerCase() == "s") {
                            CallBack(response.Id);
                        }
                        else {
                            var hide = $("#<%=hideSearchDivVal.ClientID%>").val();
                            if (hide == "true") {
                                window.location.href = "List.aspx?customerDetails=true&customerId=" + response.Extra + "&hideSearchDiv=true";
                            } else {
                                window.location.href = "List.aspx?customerDetails=true&customerId=" + response.Extra + "";
                            }
                            return;
                        }
                        return true;
                    }
                },
                error: function (error) {
                    alert("Something went wrong!!!");
                    return false;
                }
            })

        }
        var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
        function CallBack(res) {
            window.returnValue = res;
            if (isChrome) {
                window.opener.PostMessageToParentAddReceiver(window.returnValue);
            }
            window.close();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" ID="sm1"></asp:ScriptManager>
        <asp:UpdatePanel ID="up1" runat="server">
            <ContentTemplate>
                <div class="page-wrapper">
                    <div class="row">
                        <div class="col-sm-12">
                            <div class="page-title">
                                <h1></h1>
                            </div>
                        </div>
                    </div>
                    <div class="report-tab" runat="server" id="regUp">
                        <!-- Nav tabs -->
                        <div class="listtabs">
                            <ul class="nav nav-tabs" role="tablist">
                                <li role="presentation" runat="server" id="receiverList"><a href="List.aspx?customerId=<%=hideCustomerId.Value %>&hideSearchDiv=<%=hideSearchDivVal.Value %>">Beneficiary List</a></li>
                                <li class="active"><a href="Manage.aspx?receiverId=<%=hideBenificialId.Value %>&customerId=<%=hideCustomerId.Value %>&hideSearchDiv=<%=hideSearchDivVal.Value %>">Beneficiary Setup </a></li>
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
                                                <div class="panel-body">
                                                    <div class="col-md-12" id="msgDiv" runat="server" visible="false" style="background-color: red;">
                                                        <asp:Label ID="msgLabel" runat="server" ForeColor="White"></asp:Label>
                                                    </div>
                                                    <p class="col-md-12"><b>Receiver Details</b></p>
                                                    <%--body part--%>
                                                    <asp:HiddenField ID="hideCustomerId" runat="server" />
                                                    <asp:HiddenField ID="hideBenificialId" runat="server" />
                                                    <asp:HiddenField ID="hideMembershipId" runat="server" />
                                                    <asp:HiddenField ID="hideSearchDivVal" runat="server" />
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Country:<span class="errormsg">*</span></label>
                                                            <asp:DropDownList ID="ddlCountry" CssClass="form-control required" runat="server">
                                                                <asp:ListItem Text="Select.."></asp:ListItem>
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Beneficiary Type:<span class="errormsg">*</span></label>
                                                            <asp:DropDownList ID="ddlBenificiaryType" CssClass="form-control required" disabled="disabled" runat="server">
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
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>First Name:<span class="errormsg">*</span></label>
                                                            <asp:TextBox runat="server" ID="txtReceiverFName" CssClass="form-control required" placeholder="Receiver First Name"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Mid Name:</label>
                                                            <asp:TextBox runat="server" ID="txtReceiverMName" CssClass="form-control" placeholder="Receiver Mid Name"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Last Name:<span class="errormsg">*</span></label>
                                                            <asp:TextBox runat="server" ID="txtReceiverLName" CssClass="form-control required" placeholder="Receiver Last Name"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Native Country :<span class="errormsg">*</span></label>
                                                            <asp:DropDownList ID="ddlNativeCountry" CssClass="form-control required" runat="server">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Receiver Address:<span class="errormsg">*</span></label>
                                                            <asp:TextBox runat="server" ID="txtReceiverAddress" CssClass="form-control required" placeholder="Receiver Address"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Receiver City:<span class="errormsg">*</span></label>
                                                            <asp:TextBox runat="server" ID="txtReceiverCity" CssClass="form-control required" placeholder="Receiver City"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Contact No:</label>
                                                            <asp:TextBox runat="server" ID="txtContactNo" CssClass="form-control" placeholder="Receiver Contact No" MaxLength="15" onchange="return CheckForPhoneNumber(this,'Phone No')"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group" style="overflow: initial;">
                                                            <label>Mobile No.: <span class="errormsg">*</span></label><br />
                                                            <asp:TextBox runat="server" MaxLength="16" ID="txtSenderMobileNo" placeholder="Mobile No" CssClass="form-control required" />
                                                        </div>
                                                    </div>

                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Id Type:</label>
                                                            <asp:DropDownList ID="ddlIdType" CssClass="form-control" runat="server">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <label>Id Number: </label>
                                                        <div class="form-group">
                                                            <asp:TextBox runat="server" ID="txtIdValue" CssClass="form-control" placeholder="Any Photo Id"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Place of Issue:</label>
                                                            <asp:TextBox runat="server" ID="txtPlaceOfIssue" CssClass="form-control" placeholder="Place Of Issue"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Relationship To Beneficiary:<span class="errormsg">*</span></label>
                                                            <asp:DropDownList ID="ddlRelationship" onChange="showTextBox()" CssClass="form-control required" runat="server">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group" id="otherRelationDiv" runat="server">
                                                            <label>Description of other relationship:</label>
                                                            <asp:TextBox runat="server" ID="otherRelationshipTextBox" CssClass="form-control" placeholder="Other Relation Description"></asp:TextBox>
                                                        </div>
                                                    </div>

                                                    <div class="clearfix"></div>
                                                    <p class="col-md-12">
                                                        <label class="">Transaction Information</label>
                                                    </p>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Purpose of Remitance:<span class="errormsg">*</span></label>
                                                            <asp:DropDownList ID="ddlPurposeOfRemitance" runat="server" CssClass="form-control required">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Payment Mode:<span class="errormsg">*</span></label>
                                                            <asp:DropDownList ID="ddlPaymentMode" runat="server" CssClass="form-control required" onchange="PopulatePayoutPartner()">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <label>Agent/Bank:</label>
                                                            <asp:DropDownList ID="ddlPayoutPatner" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4" hidden="hidden">
                                                        <div class="form-group">
                                                            <label>Agent/Bank:<span><i>Type if Not Found</i></span></label>
                                                            <asp:TextBox ID="txtBankName" runat="server" CssClass="form-control clearOnNotBank"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4 showOnBankMethod" id="receiverAccountNo" runat="server">
                                                        <div class="form-group">
                                                            <label>Beneficiary A/c #:</label>
                                                            <asp:TextBox ID="txtBenificaryAc" runat="server" CssClass="form-control clearOnNotBank"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4" id="agentBankBranchDiv" style="display: none">
                                                        <div class="form-group">
                                                            <label>Agent/Bank Branch:</label>
                                                            <asp:DropDownList ID="DDLBankBranch" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
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
                                                            <asp:Button ID="register" runat="server" CssClass="btn btn-primary m-t-25" Text="Submit" OnClientClick="return CheckFormValidation()" />
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
            </ContentTemplate>
        </asp:UpdatePanel>
        <script>
            $(document).ready(function () {
                $("#<%=txtSenderMobileNo.ClientID%>").intlTelInput({
                    nationalMode: true,
                    formatOnDisplay: false,
                    utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/12.1.3/js/utils.js" // just for formatting/placeholders etc
                });

                $("#<%=txtSenderMobileNo.ClientID%>").on("change", function () {
                    var input = $("#<%=txtSenderMobileNo.ClientID%>");
                    var mobileNo = input.val();
                    var countryCode = $('.country.active .dial-code').text();
                    var maxLength = input.attr('maxLength');
                    if (mobileNo.indexOf(countryCode) < 0) {
                        mobileNo = countryCode + mobileNo;
                    }
                    if (mobileNo.length > maxLength) {
                        alert('Mobile No. Can allow input maxmum ' + maxLength + ' digit only');
                        return $(this).val('');
                    }
                    $(this).val(mobileNo);
                    CheckForMobileNumber(this, 'Mobile No.');
                });
                PopulateCountryFlagForMobileNumber();

                $('#<%=ddlCountry.ClientID%>').on('change', function () {
                    PopulateCountryFlagForMobileNumber();
                    PopulatePaymentMethod();
                    PopulatePayoutPartner();
                });

            });

            function PopulateCountryFlagForMobileNumber() {
                $('#<%=txtSenderMobileNo.ClientID%>').attr('disabled', 'disabled');
                var getCountry = $("#<%=ddlCountry.ClientID%> option:selected").text();
                var countryId = $("#<%=ddlCountry.ClientID%> option:selected").val();
                if (countryId === "" || countryId === null || countryId === "0") {
                    return;
                }
                $('#<%=txtSenderMobileNo.ClientID%>').removeAttr('disabled');
                var code = getCountry.split('(');
                code = code[1].split(')')[0];
                $("#<%=txtSenderMobileNo.ClientID%>").intlTelInput('setCountry', code);

                if ('<%=GetReceiverId() %>' != '') {
                    CheckMobileNumberorCountryCode();
                }
            }
            function CheckMobileNumberorCountryCode() {
                var input = $("#<%=txtSenderMobileNo.ClientID%>");
                var mobileNo = input.val();
                var newMobile = '';

                if (mobileNo.indexOf('+') >= 0 || mobileNo === '') {
                    return true;
                }

                if (mobileNo != '') {
                    var countryCode = $('.country.active .dial-code').text();
                    var len = countryCode.length;
                    var firstletters = mobileNo.substring(0, len - 1);

                    var codeWithoutPlus = countryCode.replace('+', '');

                    if (codeWithoutPlus === firstletters) {
                        newMobile = '+' + mobileNo;
                    }
                    else {
                        newMobile = countryCode + mobileNo;
                    }

                    $("#<%=txtSenderMobileNo.ClientID%>").val(newMobile);
                }
            }
        </script>
    </form>
</body>
</html>