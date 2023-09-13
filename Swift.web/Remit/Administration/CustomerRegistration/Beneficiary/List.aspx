<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerRegistration.Beneficiary.List" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>
    <script src="/ui/js/jquery.validate.js" type="text/javascript"></script>

    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="/AgentNew/js/swift_calender.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
        ShowCalFromToUpToToday("#grid_Beneficiarylist_fromDate", "#grid_Beneficiarylist_toDate");
        $('#grid_Beneficiarylist_fromDate').mask('0000-00-00');
        $('#grid_Beneficiarylist_toDate').mask('0000-00-00');
        $(document).ready(function () {
            $('#<%=ddlSearchBy.ClientID%>').change(function () {
                <% = txtSearchData.InitFunction() %>
            });
            var a = $("#<%=hideSearchDiv.ClientID%>").val();
            if (a == "true") {
                $("#<%=hideSearchDiv.ClientID%>").hide();
            }

        });
        function CallBackAutocomplete(id) {
            var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
            $('#<%=hideCustomerId.ClientID%>').val(d[0]);
            $('#<%=clickBtnForGetCustomerDetails.ClientID%>').click();
        };

        function GetCustomerSearchType() {
            var searchBy = $('#<%=ddlSearchBy.ClientID%>').val()
            return searchBy;
        };
        function PopulateAutocomplete(custInfo) {
            var customerInfo = custInfo.split(',');
            var id = customerInfo[0];
            var name = customerInfo[1];
            var d = [id, name];
            SetItem("<% =txtSearchData.ClientID%>", d);
            var hideSearch = $("#<%=hideSearchDiv.ClientID%>").val();
            if (hideSearch == "true") {
                    ReloadParent();
            }
        }
        function ClearClicked() {
            var d = ["", ""];
            SetItem("<% =txtSearchData.ClientID%>", d);
            $("#<%=rpt_grid.ClientID%>").hide();
            $('#<%=hideCustomerId.ClientID%>').val('');
            $('#txtMembershipId').text('');
            $('#customerName').text('');
            event.preventDefault();
        }
        function ReloadParent() {
            window.onunload = window.opener.location.reload();
        }
          function SetMessageBox(msg, id) {
            alert(msg);
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="hidden">
            <asp:Button ID="clickBtnForGetCustomerDetails" runat="server" Text="click" OnClick="clickBtnForGetCustomerDetails_Click" />
            <asp:HiddenField ID="hideCustomerId" runat="server" />
            <asp:HiddenField ID="hideSearchDiv" runat="server" />
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
                            <li class="active"><a href="List.aspx?customerId=<%=hideCustomerId.Value %>&hideSearchDiv=<%=hideSearchDiv.Value %>">Beneficiary Setup </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation"><a href="List.aspx?customerId=<%=hideCustomerId.Value %>&hideSearchDiv=<%=hideSearchDiv.Value %>">Beneficiary List</a></li>
                </ul>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Beneficiary List:
                            <label runat="server" id="customerName"></label>
                                (<label runat="server" id="txtMembershipId"></label>
                                )</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="displayOnlyOnEdit" runat="server">
                                <div class="col-sm-3 col-xs-12">
                                    <label class="control-label">Search By</label>
                                    <asp:DropDownList ID="ddlSearchBy" runat="server" CssClass="form-control" Style="margin-bottom: 5px;">
                                    </asp:DropDownList>
                                </div>
                                <div class="col-sm-3 col-xs-12">
                                    <div class="form-group">
                                        <label>Choose Customer :<span class="errormsg">*</span></label>
                                        <uc1:SwiftTextBox ID="txtSearchData" runat="server" Category="remit-searchCustomer" cssclass="form-control" Param1="@GetCustomerSearchType()" title="Blank for All" />
                                    </div>
                                </div>
                                <div class="col-sm-3 col-xs-12">
                                    <div class="form-group">
                                        <label>&nbsp;</label><br />
                                        <asp:Button runat="server" class="btn btn-primary m-t-25" ID="clear" OnClientClick="ClearClicked()" Text="Clear" />
                                    </div>
                                </div>
                            </div>
                            <div id="rpt_grid" runat="server"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
