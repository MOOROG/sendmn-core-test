<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UpdateKYC.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerRegistration.UpdateKYC" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript" language="javascript">
       
        $(document).ready(function () {
            $('#<%=ddlSearchBy.ClientID%>').change(function () {
                <% = txtSearchData.InitFunction() %>
            });
            $('#<%=ddlMethod.ClientID%>').change(function () {
                var methodType = $('#<%=ddlMethod.ClientID%>').val();
                alert
                if (methodType == '11050') {
                    $("#trackingNoDiv").show();
                    return;
                }
                $("#trackingNoDiv").hide();
            });

            $('#<%=ddlSearchBy.ClientID%>').change(function () {
                $('#<%=kycDetails.ClientID%>').hide();
                $('#<%=kycDataDetails.ClientID%>').hide();
                $('#txtSearchData_aText').val('');
                <% = txtSearchData.InitFunction() %>
            });
            $("#txtSearchData_aSearch").change(function () {
                searchValue = $(this).val();
                if (searchValue === null || searchValue === "") {
                    $('#<%=ddlMethod.ClientID%>').val('');
                    $('#<%=customerName.ClientID%>').val('');
                    $('#<%=ddlStatus.ClientID%>').val('');
                    $('#<%=customerAddress.ClientID%>').val('');
                    $('#<%=mobileNo.ClientID%>').val('');
                    $('#<%=startDate.ClientID%>').val('');
                    $('#<%=kycDetails.ClientID%>').hide();
                    $('#<%=kycDataDetails.ClientID%>').hide();
                }
            });
        });
        function ReloadParent() {
            window.onunload = window.opener.location.reload();
        }
        function GetCustomerSearchType() {
            var searchBy = $('#<%=ddlSearchBy.ClientID%>').val()
            return searchBy;
        };

        function CallBackAutocomplete(id) {
            var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
            $('#<%=hdnCustomerId.ClientID%>').val(d[0]);
            $('#<%=clickBtnForGetCustomerDetails.ClientID%>').click();
            $('#<%=kycDetails.ClientID%>').show();
            $('#<%=kycDataDetails.ClientID%>').show();
        };

        function CheckFormValidation() {
            var reqField = "ddlMethod,ddlStatus,startDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
        };
        function ClearClicked() {
            var d = ["", ""];
            SetItem("<% =txtSearchData.ClientID%>", d);
            $('#<%=kycDetails.ClientID%>').hide();
            $('#<%=kycDataDetails.ClientID%>').hide();
            $('#<%=hdnCustomerId.ClientID%>').val('');
            event.preventDefault();
        }
        function HideNecessaryDiv() {
            $('#<%=kycDetails.ClientID%>').hide();
            $('#<%=kycDataDetails.ClientID%>').hide();
        }
        function PopulateAutoComplete(custInfo) {
            var customerInfo = custInfo.split(',');
            var custId = customerInfo[0];
            var custName = customerInfo[1];
            var d = [custId, custName];
            SetItem("txtSearchData_aSearch", d);
             $('#<%=ddlMethod.ClientID%>').val('');
            $('#<%=ddlStatus.ClientID%>').val('');
            $('#<%=kycDetails.ClientID%>').show();
            $('#<%=kycDataDetails.ClientID%>').show();
            <%=HideSearchDiv()%>;
            ReloadParent();
        }
        //function HideSearchDiv() {
        //     $("#displayOnlyOnEdit").attr("style", "display:none");
        //}
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField runat="server" ID="hdnCustomerId" />
        <div class="hidden">
            <asp:Button ID="clickBtnForGetCustomerDetails" runat="server" Text="click" />
            <%--<asp:Button ID="Button1" runat="server" Text="click" OnClick="clickBtnForGetCustomerDetails_Click" />--%>
        </div>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                            <%--              <li class="active"><a href="UpdateKYC.aspx">Customer KYC Update </a></li>--%>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <%--<li role="presentation"><a href="List.aspx">Customer List</a></li>--%>
                        <li role="presentation" class="active"><a >Customer KYC Operation</a></li>
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
                                        <div class="panel-heading">KYC - Process <label runat="server" id="lblCustName"></label></div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-sm-12" id="msgDiv" runat="server" visible="false" style="background-color: red;">
                                                    <asp:Label ID="msgLabel" runat="server" ForeColor="White"></asp:Label>
                                                </div>
                                                <div class="col-sm-12">
                                                    <div id="displayOnlyOnEdit" runat="server">
                                                        <div class="col-sm-4">
                                                            <label class="control-label">Search By</label>
                                                            <asp:DropDownList ID="ddlSearchBy" runat="server" CssClass="form-control" Style="margin-bottom: 5px;">
                                                            </asp:DropDownList>
                                                        </div>
                                                        <div class="col-sm-4">
                                                            <div class="form-group">
                                                                <label>Choose Customer :<span class="errormsg">*</span></label>
                                                                <uc1:SwiftTextBox ID="txtSearchData" runat="server" Category="remit-searchCustomer" CssClass="form-control" Param1="@GetCustomerSearchType()" Title="Blank for All" />
                                                            </div>
                                                        </div>
                                                        <div class="col-sm-4">
                                                            <div class="form-group">
                                                                <label>&nbsp;</label><br />
                                                                <asp:Button runat="server" class="btn btn-primary m-t-25" ID="clear" OnClientClick="ClearClicked()" Text="Clear" />
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div id="kycDetails" class="col-sm-12" runat="server">
                                                    <div class="col-sm-4">
                                                        <div class="form-group">
                                                            <label>Method <span class="errormsg">*</span></label>
                                                            <asp:DropDownList runat="server" ID="ddlMethod" CssClass="form-control"></asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div id="trackingNoDiv" class="col-sm-4" style="display: none">
                                                        <div class="form-group">
                                                            <label>Tracking Number</label>
                                                            <asp:TextBox runat="server" ID="trackingNo" MaxLength="20" CssClass="form-control"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-sm-4">

                                                        <div class="form-group">
                                                            <label>Customer Name </label>
                                                            <asp:TextBox runat="server" ID="customerName" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-sm-4">
                                                        <div class="form-group">
                                                            <label>Status <span class="errormsg">*</span></label>
                                                            <asp:DropDownList runat="server" ID="ddlStatus" Name="ddlStatus" CssClass="form-control"></asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="col-sm-4">

                                                        <div class="form-group">
                                                            <label>Address </label>
                                                            <asp:TextBox runat="server" ID="customerAddress" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-sm-4">
                                                        <div class="form-group">
                                                            <label>Date <span class="errormsg">*</span></label>
                                                            <div class="input-group m-b">
                                                                <span class="input-group-addon">
                                                                    <i class="fa fa-calendar" aria-hidden="true"></i>
                                                                </span>
                                                                <asp:TextBox ID="startDate" runat="server" CssClass="form-control"></asp:TextBox>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-sm-4">
                                                        <div class="form-group">
                                                            <label>Mobile no</label>
                                                            <asp:TextBox runat="server" ID="mobileNo" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-sm-12">
                                                        <div class="form-group">
                                                            <label>Remarks </label>
                                                            <asp:TextBox runat="server" ID="remarks" CssClass="form-control" TextMode="MultiLine"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-sm-3">
                                                        <div runat="server">
                                                            <div class="form-group">
                                                                <asp:Button ID="save" runat="server" CssClass="btn btn-primary m-t-25" Text="Save" OnClientClick="return CheckFormValidation()" OnClick="save_Click" />
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
            </div>

            <div class="row" runat="server" id="kycDataDetails">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer KYC Details</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="rpt_grid" runat="server"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
