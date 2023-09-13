<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AgentNew.Transaction.MultipleReceipt.List" %>

<%@ Register Src="/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            ClearSearchField();

            $("#<%=ddlCustomerType.ClientID%>").change(function () {
                var d = ["", ""];
                SetItem("<% =txtSearchData.ClientID%>", d);
                <% = txtSearchData.InitFunction() %>;
            });
            //CalTillToday("#grid_list_fromDate");
            //CalTillToday("#grid_list_toDate");
            ShowCalFromToUpToToday("#<%=fromDate.ClientID%>", "#<%=toDate.ClientID%>");
            $('#<%=fromDate.ClientID%>').mask('0000-00-00');
            $('#<%=toDate.ClientID%>').mask('0000-00-00');
        });
        function ClearSearchField() {
            var d = ["", ""];
            SetItem("<% =txtSearchData.ClientID%>", d);
            <% = txtSearchData.InitFunction() %>;
        }
        //$(document).ready(function () {
        //    CalUpToToday("#RemitTransaction_fromDate");
        //    CalUpToToday("#RemitTransaction_toDate");
        //});
        function PickSenderData(obj) {
            var url = "";
            if (obj == "a") {
                url = "" + "TxnHistory/SenderAdvanceSearch.aspx";
            }
            if (obj == "s") {
                url = "" + "TxnHistory/SenderTxnHistory.aspx";
            }
            var param = "dialogHeight:470px;dialogWidth:700px;dialogLeft:200;dialogTop:100;center:yes";
            var res = PopUpWindow(url, param);

            if (res == "undefined" || res == null || res == "") {
            }
            else {

                PickDataFromSender(res);
            }
        }
        function GetCustomerSearchType() {
            return $('#<%=ddlCustomerType.ClientID%>').val();
        }
        function PostMessageToParentNew(id) {
            if (id == "undefined" || id == null || id == "") {
                alert('No customer selected!');
            }
            else {
                //ClearSearchField();
                //PopulateReceiverDDL(id);
                GetCustomerName(id);
                $("#<%=ddlCustomerType.ClientID%>").val($("#<%=ddlCustomerType.ClientID%> option:eq(0)").val());
            }
        }
        function ClearAllCustomerInfo() {
            SetValueById("<%=HiddenCustomerId.ClientID %>", "", "");
            GetElement("<%=postPage.ClientID%>").click();
        }
        function CallBackAutocomplete(id) {
            var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
            SetItem("<% =txtSearchData.ClientID%>", d);
            SetValueById("<%=HiddenCustomerId.ClientID %>", GetItem("<%=txtSearchData.ClientID %>")[0], "");

      <%--      PopulateReceiverDDL(GetItem("<%=txtSearchData.ClientID %>")[0]);--%>
           <%-- SearchCustomerDetails(GetItem("<%=txtSearchData.ClientID %>")[0]);--%>
        }
        function SearchCustomerDetails(customerId) {
            //$('HiddenCustomerId').val();
            SetValueById("<%=HiddenCustomerId.ClientID %>", customerId, "");
            GetElement("<%=postPage.ClientID%>").click();
        }
        //function CallBackAutocomplete(id) {
        //    var d = [GetItem("RemitTransaction_CustomerID")[0], GetItem("RemitTransaction_CustomerID")[1].split('|')[0]];
        //    SetItem("RemitTransaction_CustomerID", d);
        //}
        function checkCount() {
            isChecked = false;
            $('input[type=checkbox]').each(function () {
                if ($(this).is(":checked")) {
                    isChecked = true;
                }
            });
            if (!isChecked) {
                alert("At least one record must be selected");
                return false;
            }
            return true;
        }
        function GetCustomerName(id) {
            var dataToSend = {
                MethodName: 'GetCustomerName', id: id
            };

            var options =
                {
                    url: '<%=ResolveUrl("List.aspx") %>?x=' + new Date().getTime(),
                    data: dataToSend,
                    dataType: 'JSON',
                    type: 'POST',
                    success: function (response) {
                        SetValueById("<%=HiddenCustomerId.ClientID %>", id, "");
                        var test = [id, response[0].fullName];
                        SetItem("<% =txtSearchData.ClientID%>", test);

                    }
                };
            $.ajax(options);
        }
        function ClearAllCustomerInfo() {

            SetValueById("<%=fromDate.ClientID %>", "", "");
            SetValueById("<%=toDate.ClientID %>", "", "");
            SetValueById("<%=controlNumber.ClientID %>", "", "");
            SetValueById("<%=HiddenCustomerId.ClientID %>", "", "");
            GetElement("<%=postPage.ClientID%>").click();

        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="/Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#">Other Services</a></li>
                        <li class="active"><a href="List.aspx">Multiple Receipt</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="tab-content">
            <div role="tabpanel" class="tab-pane active" id="list">
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default ">
                            <!-- Start .panel -->
                            <div class="panel-heading">
                                <h4 class="panel-title">Remit Transaction</h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-2">
                                        <div class="form-group">
                                            <label class="control-label">From Date:</label>
                                            <asp:TextBox autocomplete="off" ID="fromDate" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="col-md-2">
                                        <div class="form-group">
                                            <label class="control-label">To Date:</label>
                                            <asp:TextBox autocomplete="off" ID="toDate" onchange="return DateValidation('fromDate','t','toDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="col-md-2">
                                        <div class="form-group">
                                            <label class="control-label">Search By</label>
                                            <asp:DropDownList ID="ddlCustomerType" runat="server" CssClass="form-control">
                                                <asp:ListItem Value="accountNo" Text="Account No."></asp:ListItem>
                                                <asp:ListItem Value="email" Text="Email ID" Selected="True"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label class="control-label">Search Value</label>
                                            <uc1:SwiftTextBox ID="txtSearchData" runat="server" Category="remit-searchCustomer" cssclass="form-control" Param1="@GetCustomerSearchType()" title="Blank for All" />
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="form-group">
                                            <label class="control-label"><%= Swift.web.Library.GetStatic.ReadWebConfig("tranNoName","") %>: </label>
                                            <asp:TextBox CssClass="form-control ui-autocomplete-input" ID="controlNumber" runat="server"></asp:TextBox>
                                        </div>
                                    </div>


                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="control-label">&nbsp</label>
                                            <asp:Button ID="searchButton" Text="Search" class="btn btn-primary" runat="server" OnClick="searchButton_Click" />
                                            <%--<input name="button3" type="button" id="btnAdvSearch" onclick="PickSenderData('a');" class="btn btn-primary" value="Advance Search" />--%>
                                            <input name="button4" type="button" id="btnClear" value="Clear List" class="btn btn-clear" onclick="ClearAllCustomerInfo();" />
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-2">
                                        <div class="form-group">
                                            <label class="control-label">Copy Type</label>
                                            <asp:DropDownList ID="copyType" name="copyType" runat="server" CssClass="form-control">
                                                <asp:ListItem Value="office" Text="Office Copy"></asp:ListItem>
                                                <asp:ListItem Value="customer" Text="Customer Copy"></asp:ListItem>
                                                <asp:ListItem Value="both" Text="Both Copy" Selected="True"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="table-responsive">
                                    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0" class="table table-condensed">
                                        <tr>
                                            <td height="50" valign="top">
                                                <asp:UpdatePanel ID="up1" runat="server">
                                                    <ContentTemplate>
                                                        <div id="rpt_grid" enableviewstate="false" runat="server" class="gridDiv"></div>
                                                    </ContentTemplate>
                                                    <Triggers>
                                                        <asp:AsyncPostBackTrigger ControlID="searchButton" EventName="Click" />
                                                    </Triggers>
                                                </asp:UpdatePanel>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div class="panel-body">
                                <asp:HiddenField ID="hddRowIds" runat="server" />
                                <asp:HiddenField ID="HiddenCustomerId" runat="server" />
                                <asp:Button ID="postPage" runat="server" Text="Add New Account" OnClick="postPage_Click"
                                    Style="display: none" />
                                <div class="col-sm-12" runat="server">
                                    <div class="form-group">

                                        <asp:Button ID="btnPrintReceipt" runat="server" Text="Print Receipt"
                                            OnClick="btnPrintReceipt_Click" OnClientClick="return checkCount()" CssClass="btn btn-primary" />
                                        <%-- <asp:Button ID="Print" runat="server" CssClass="btn btn-primary m-t-25" Text="Print"  OnClick="Print_Click" />--%>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
