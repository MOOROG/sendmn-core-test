<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerDetails.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.CustomerDetails" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>

    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            $('#<%=ddlSearchBy.ClientID%>').change(function () {
                <% = txtSearchData.InitFunction() %>
            });
        });

        function CallBackAutocomplete(id) {
            var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
            $('#<%=hdnCustomerId.ClientID%>').val(d[0]);
            $('#<%=clickBtnForGetCustomerDetails.ClientID%>').click();
        };
        function GetCustomerSearchType() {
            var searchBy = $('#<%=ddlSearchBy.ClientID%>').val()
            return searchBy;
        };
        function ShowReceiverPopUp() {
            var id = $('#<%=hdnCustomerId.ClientID%>').val();
            //var url = "/AgentNew/Administration/CustomerSetup/Benificiar/List.aspx?customerDetails=true&customerId=" + id + "";
            var url = "/Remit/Administration/CustomerRegistration/Beneficiary/List.aspx?customerId=" + id + "&hideSearchDiv=true";
            window.open(url, "popup", "height=600,width=1200");
        }
        function ShowdocumentPopUp() {
            var id = $('#<%=hdnCustomerId.ClientID%>').val();
            var url = "/Remit/Administration/CustomerRegistration/CustomerDocument.aspx?fromCustDetail=true&customerId=" + id + "&hideSearchDiv=true";

            window.open(url, "popup", "height=600,width=1200");
        }
        function ShowKYCPopUp() {
            var id = $('#<%=hdnCustomerId.ClientID%>').val();
            var url = "/Remit/Administration/CustomerRegistration/UpdateKYC.aspx?customerId=" + id + "&hideSearchDiv=true";

            window.open(url, "popup", "height=600,width=1200");
        }
        function PostMessageToParentAddReceiver(msg) {
            alert("post masg to parentr reachyed" + msg);
        }
        function HideDiv() {
            $('.info').hide();
        }
        function ClearClicked() {
            var d = ["", ""];
            SetItem("<% =txtSearchData.ClientID%>", d);
            $('.info').hide();
            EmptyGridDatas();
            event.preventDefault();
        }
        function EmptyGridDatas() {
            $('#modDetails').empty();
            $('#txnDetails').empty();
            $('#kycDetail').empty();
            $('#docdetails').empty();
            $('#recDetails').empty();
        }
    </script>
    <style type="text/css">
        .tb-scroll {
            overflow-y: scroll;
            height: 150px;
        }

        .scroll-main {
            overflow-y: scroll;
            height: 580px;
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField runat="server" ID="hdnCustomerId" />
        <asp:HiddenField runat="server" ID="hdnCustomerName" />
        <div class="hidden">
            <asp:Button ID="clickBtnForGetCustomerDetails" runat="server" Text="click" OnClick="clickBtnForGetCustomerDetails_Click" />
        </div>
        <div class="page-wrapper container-fluid">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a>Administration </a></li>
                            <li><a>Customer Management</a></li>
                            <li class="active"><a href="CustomerDetails.aspx">Customer Details</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <%--<li role="presentation"><a href="List.aspx">Customer List</a></li>--%>
                        <li role="presentation" class="active"><a href="#">Customer Details</a></li>
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
                                        <div class="panel-heading">Customer Details</div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-sm-3">
                                                    <div class="form-group">
                                                        <label class="control-label">Search By</label>
                                                        <asp:DropDownList ID="ddlSearchBy" runat="server" CssClass="form-control" Style="margin-bottom: 5px;">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-sm-3">
                                                    <div class="form-group">
                                                        <label>Choose Customer :<span class="errormsg">*</span></label>
                                                        <uc1:SwiftTextBox ID="txtSearchData" runat="server" Category="remit-searchCustomer" cssclass="form-control" Param1="@GetCustomerSearchType()" title="Blank for All" />
                                                    </div>
                                                </div>
                                                <div class="col-sm-3">
                                                    <div class="form-group">
                                                        <label>&nbsp;</label><br />
                                                        <asp:Button runat="server" class="btn btn-primary m-t-25" ID="clear" OnClientClick="ClearClicked()" Text="Clear" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row  info">
                                                <div class="col-sm-6">
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">Customer Details</div>
                                                        <div class="panel-body scroll-main">
                                                            <div class="row">
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>Membership ID</label>
                                                                        <asp:TextBox runat="server" ID="memId" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>Customer Name</label>
                                                                        <asp:TextBox runat="server" ID="custName" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6" hidden>
                                                                    <div class="form-group">
                                                                        <label>Wallet No</label>
                                                                        <asp:TextBox runat="server" ID="walletNo" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>Gender</label>
                                                                        <asp:TextBox runat="server" ID="custGender" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>Email Address</label>
                                                                        <asp:TextBox runat="server" ID="custEmail" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>Country</label>
                                                                        <asp:TextBox runat="server" ID="custCountry" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>State</label>
                                                                        <asp:TextBox runat="server" ID="custState" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>City</label>
                                                                        <asp:TextBox runat="server" ID="custCity" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>Mobile</label>
                                                                        <asp:TextBox runat="server" ID="custMobile" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>Occupation</label>
                                                                        <asp:TextBox runat="server" ID="custOccupation" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>DOB</label>
                                                                        <asp:TextBox runat="server" ID="custDob" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>ID Type</label>
                                                                        <asp:TextBox runat="server" ID="idType" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>ID Number</label>
                                                                        <asp:TextBox runat="server" ID="idNumber" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>ID Issued Date</label>
                                                                        <asp:TextBox runat="server" ID="idIssuedDate" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <div class="form-group">
                                                                        <label>ID Expiry Date</label>
                                                                        <asp:TextBox runat="server" ID="idExpiryDate" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>
                                                                <div class="col-md-6" hidden>
                                                                    <div class="form-group">
                                                                        <label>Place of Issue</label>
                                                                        <asp:TextBox runat="server" ID="placeOfIssue" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                                    </div>
                                                                </div>

                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-sm-6">
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">
                                                            Receiver List
                            <div class="panel-actions">
                                <a href="#" onclick="ShowReceiverPopUp()">
                                    <i class="fa fa-edit"></i>
                                </a>
                            </div>
                                                        </div>
                                                        <div class="panel-body tb-scroll">
                                                            <table class="table table-bordered">
                                                                <thead>
                                                                    <tr>
                                                                        <th>SN.</th>
                                                                        <th>Reciever Name</th>
                                                                        <th>Address</th>
                                                                        <th>Mobile</th>
                                                                        <th>Country</th>

                                                                    </tr>
                                                                </thead>
                                                                <tbody id="recDetails" runat="server">
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">
                                                            Customer Document
                            <div class="panel-actions">
                                <a href="#" onclick="ShowdocumentPopUp()">
                                    <i class="fa fa-edit"></i>
                                </a>
                            </div>
                                                        </div>
                                                        <div class="panel-body  tb-scroll">
                                                            <table class="table table-bordered">
                                                                <thead>
                                                                    <tr>
                                                                        <th>SN.</th>
                                                                        <th>Doc Type</th>
                                                                        <th>File Type</th>
                                                                        <th>File Name</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody id="docdetails" runat="server">
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">
                                                            KYC Details

                                   <div class="panel-actions">
                                       <a href="#" onclick="ShowKYCPopUp()">
                                           <i class="fa fa-edit"></i>
                                       </a>
                                   </div>
                                                        </div>
                                                        <div class="panel-body  tb-scroll">
                                                            <table class="table table-bordered">
                                                                <thead>
                                                                    <tr>
                                                                        <th>SN</th>
                                                                        <th>Method</th>
                                                                        <th>KYC Status</th>
                                                                        <th>Remarks</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody id="kycDetail" runat="server">
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="row info">
                                                <div class="col-sm-12">
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">Last 3 Transaction</div>
                                                        <div class="panel-body  tb-scroll">
                                                            <table class="table table-bordered">
                                                                <thead>
                                                                    <tr>
                                                                        <th>SN.</th>
                                                                        <th>Created Date</th>
                                                                        <th>Receiver Name</th>
                                                                        <th><%= Swift.web.Library.GetStatic.ReadWebConfig("tranNoName","") %></th>
                                                                        <th>Amount</th>
                                                                        <th>Tranasction Status</th>
                                                                        <th>Pay Status</th>
                                                                        <th>Payout Country</th>

                                                                    </tr>
                                                                </thead>
                                                                <tbody id="txnDetails" runat="server">
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row info">
                                                <div class="col-sm-12">
                                                    <div class="panel panel-default">
                                                        <div class="panel-heading">Modify Log</div>
                                                        <div class="panel-body  tb-scroll">
                                                            <table class="table table-bordered">
                                                                <thead>
                                                                    <tr>
                                                                        <th>SN.</th>
                                                                        <th>Field</th>
                                                                        <th>Old Value</th>
                                                                        <th>New Value</th>
                                                                        <th>Modified By</th>
                                                                        <th>Modified Date</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody id="modDetails" runat="server">
                                                                </tbody>
                                                            </table>
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
    </form>
</body>
</html>

