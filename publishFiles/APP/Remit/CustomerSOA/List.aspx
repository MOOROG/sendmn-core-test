﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.CustomerSOA.List" %>

<%@ Register Src="/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            ClearSearchField();
            $("#ddlCustomerType").change(function () {
                var d = ["", ""];
                SetItem("<% =txtSearchData.ClientID%>", d);
                <% = txtSearchData.InitFunction() %>;
            });
            ShowCalFromToUpToToday("#fromDate", "#toDate");
            //ShowCalFromToUpToToday("#CustomerSoa_fromDate", "#CustomerSoa_toDate");
            //CalUpToToday("#CustomerSoa_fromDate");
            //CalUpToToday("#CustomerSoa_toDate");
            $('#fromDate').mask('0000-00-00');
            $('#toDate').mask('0000-00-00');
        });
        function ClearSearchField() {
            var d = ["", ""];
            SetItem("<% =txtSearchData.ClientID%>", d);
            <% = txtSearchData.InitFunction() %>;
        }
        function GetCustomerSearchType() {
            var searchType = $('#<%=ddlCustomerType.ClientID%>').val();
            $("#<%=HiddenSearchType.ClientID%>").val(searchType);
            return $('#ddlCustomerType').val();
        }
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
        function PostMessageToParentNew(id) {
            if (id == "undefined" || id == null || id == "") {
                alert('No customer selected!');
            }
            else {

                GetCustomerName(id);
                $("#ddlCustomerType").val($("#ddlCustomerType option:eq(0)").val());
            }
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
            SetValueById("<%=HiddenCustomerId.ClientID %>", "", "");
            GetElement("postPage").click();
        }
        function CallBackAutocomplete(id) {
            var d = [GetItem("<%=txtSearchData.ClientID %>")[0], GetItem("<%=txtSearchData.ClientID %>")[1].split('|')[0]];
            SetItem("<% =txtSearchData.ClientID%>", d);
            SetValueById("<%=HiddenCustomerId.ClientID %>", GetItem("<%=txtSearchData.ClientID %>")[0], "");
        }
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
            $("#<%=HiddenCustomerId.ClientID%>").val('');
            return true;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Customer SOA</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="col-md-2">
                                            <div class="form-group">
                                                <label class="control-label">
                                                    From Date:</label>
                                                <asp:TextBox autocomplete="off" ID="fromDate" runat="server" onchange="return DateValidation('fromDate','t')" MaxLength="10" CssClass="form-control form-control-inline input-medium "></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="col-md-2">
                                            <label class="control-label">
                                                To Date:</label>
                                            <asp:TextBox autocomplete="off" ID="toDate" runat="server" onchange="return DateValidation('toDate','t')" MaxLength="10" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                        </div>
                                        <div class="col-md-2">
                                            <label class="control-label">
                                                &nbsp;</label>
                                            <asp:DropDownList ID="ddlCustomerType" runat="server" CssClass="form-control">
                                                <asp:ListItem Value="accountNo" Text="Account No."></asp:ListItem>
                                                <asp:ListItem Value="email" Text="Email ID" Selected="True"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="control-label">
                                                &nbsp;</label>
                                            <uc1:SwiftTextBox ID="txtSearchData" runat="server" Category="remit-searchCustomer" cssclass="form-control" Param1="@GetCustomerSearchType()" title="Blank for All" />
                                        </div>
                                        <div class="col-md-12">
                                            <label class="control-label">
                                                &nbsp;</label><br />
                                            <asp:Button ID="searchButton" Text="Search" class="btn btn-primary" runat="server" OnClick="searchButton_Click" />
                                            <input style="display:none" name="button3" type="button" id="btnAdvSearch" onclick="PickSenderData('a');" class="btn btn-primary" value="Advance Search" />
                                            <input name="button4" type="button" id="btnClear" value="Clear List" class="btn btn-primary" onclick="ClearAllCustomerInfo();" />
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
                                    <asp:HiddenField ID="HiddenSearchType" runat="server" />
                                    <asp:Button ID="postPage" runat="server" Text="Add New Account" OnClick="postPage_Click"
                                        Style="display: none" />

                                    <div class="col-sm-12" runat="server">
                                        <div class="form-group">

                                            <asp:Button ID="btnPrintReceipt" runat="server" Text="Show Customer SOA"
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
    </form>
</body>
</html>
