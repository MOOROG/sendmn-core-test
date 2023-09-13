<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="UpdateKYC.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CustomerSetup.CustomerRegistration.UpdateKYC" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript" language="javascript">
        $('#<%=kycDetails.ClientID%>').hide();
        $('#<%=kycDataDetails.ClientID%>').hide();
        $('#<%=startDate.ClientID%>').mask('0000-00-00');
        $(document).ready(function () {
            $('#<%=ddlSearchBy.ClientID%>').change(function () {
                $('#<%=kycDetails.ClientID%>').hide();
                $('#<%=kycDataDetails.ClientID%>').hide();
                $('#ContentPlaceHolder1_txtSearchData_aText').val('');
                <% = txtSearchData.InitFunction() %>
            });

            var a = $("#<%=hideSearchDiv.ClientID%>").val();
            if (a == "true") {
                $("#<%=hideSearchDiv.ClientID%>").hide();
                $('.main-nav').hide();
            }
        });
        function ReloadParent() {
            window.onunload = window.opener.location.reload();
        }
        function GetCustomerSearchType() {
            var searchBy = $('#<%=ddlSearchBy.ClientID%>').val()
            return searchBy;
        }

        function CallBackAutocomplete(id) {
            var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
            $('#<%=hdnCustomerId.ClientID%>').val(d[0]);
            $('#<%=kycDetails.ClientID%>').show();
            $('#<%=kycDataDetails.ClientID%>').show();
            $('#<%=clickBtnForGetCustomerDetails.ClientID%>').click();
        }

        $(document).on('change', '#ContentPlaceHolder1_txtSearchData_aSearch', function () {
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

        function CheckFormValidation() {
            var reqField = "ContentPlaceHolder1_txtSearchData_aSearch,<%=ddlMethod.ClientID%>,<%=ddlStatus.ClientID%>,<%=startDate.ClientID%>,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
        }
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
            SetItem("ContentPlaceHolder1_txtSearchData_aSearch", d);
            $('#<%=ddlMethod.ClientID%>').val('');
            $('#<%=ddlStatus.ClientID%>').val('');
            $('#<%=kycDetails.ClientID%>').show();
            $('#<%=kycDataDetails.ClientID%>').show();
            HideSearchDiv();
            ReloadParent();
        }
        function HideSearchDiv() {
            $("#displayOnlyOnEdit").attr("style", "display:none");
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:HiddenField runat="server" ID="hdnCustomerId" />
    <asp:HiddenField ID="hideSearchDiv" runat="server" />
    <div class="hidden">
        <asp:Button ID="clickBtnForGetCustomerDetails" runat="server" Text="click" OnClick="clickBtnForGetCustomerDetails_Click" />
    </div>
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="/AgentNew/Dashboard.aspx"><i class="fa fa-home"></i></a></li>
                        <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a>
                        </li>
                        <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="report-tab" runat="server" id="regUp">
            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="#">Customer KYC Operation</a></li>
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
                                        KYC - Process
                                        <label runat="server" id="lblCustName"></label>
                                    </div>
                                    <div class="panel-body">
                                        <div class="row">
                                            <div class="col-md-12">
                                                <div class="row">
                                                    <div class="col-md-12" id="msgDiv" runat="server" visible="false" style="background-color: red;">
                                                        <asp:Label ID="msgLabel" runat="server" ForeColor="White"></asp:Label>
                                                    </div>
                                                </div>
                                                <div id="displayOnlyOnEdit" class="row" runat="server">
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
                                                <div class="row" id="kycDetails" runat="server">
                                                    <div class="col-sm-4">
                                                        <div class="form-group">
                                                            <label>Method <span class="errormsg">*</span></label>
                                                            <asp:DropDownList runat="server" ID="ddlMethod" CssClass="form-control"></asp:DropDownList>
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
                                                                <asp:TextBox ID="startDate" onchange="return DateValidation('startDate')" runat="server" CssClass="form-control"></asp:TextBox>
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
        </div>

        <div class="row" id="kycDataDetails" runat="server">
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
</asp:Content>
