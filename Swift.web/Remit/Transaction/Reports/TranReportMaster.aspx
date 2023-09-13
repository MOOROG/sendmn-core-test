<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="TranReportMaster.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.TranReportMaster" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/Css/swift_component.css" rel="stylesheet" type="text/css" />

    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_calendar.js"></script>
    <script type="text/javascript">
        function CheckAll(obj, ctl) {

            var cBoxes = document.getElementsByName(ctl);

            for (var i = 0; i < cBoxes.length; i++) {
                if (cBoxes[i].checked == true) {
                    cBoxes[i].checked = false;
                }
                else {
                    cBoxes[i].checked = true;
                }

            }
        }
        function UncheckAll(obj) {
            var cBoxes = document.getElementsByName(ctl);

            for (var i = 0; i < cBoxes.length; i++) {
                cBoxes[i].checked = false;
            }
        }

        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =sendDateFrom.ClientID%>", "#<% =sendDateTo.ClientID%>", 1);
            ShowCalFromToUpToToday("#<% =paidDateFrom.ClientID%>", "#<% =paidDateTo.ClientID%>", 1);
            ShowCalFromToUpToToday("#<% =cancelledDateFrom.ClientID%>", "#<% =cancelledDateTo.ClientID%>", 1);
            ShowCalFromToUpToToday("#<% =approvedDateFrom.ClientID%>", "#<% =approvedDateTo.ClientID%>", 1);
            ShowCalFromToUpToToday("#<% =approvedDateFrom.ClientID%>", "#<% =approvedDateTo.ClientID%>", 1);

        }
        LoadCalendars();
    </script>
    <style type="text/css">
        input[type='checkbox'] {
            margin-right: 10px;
        }

        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
                            <li class="active"><a href="TranReportMaster.aspx">Transaction Report Master</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Transaction Report Master</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <div class="table table-responsive">
                                    <table class="table table-responsive">
                                        <tr>
                                            <td>
                                                <asp:UpdatePanel ID="upnl1" runat="server">
                                                    <ContentTemplate>
                                                        <table class="table table-responsive">
                                                            <tr>
                                                                <th></th>
                                                                <th>Sending
                                                                </th>
                                                                <th>Receiving
                                                                </th>
                                                            </tr>
                                                            <tr>
                                                                <td>Super Agent</td>
                                                                <td>
                                                                    <asp:DropDownList ID="ssAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="rsAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Country</td>
                                                                <td>
                                                                    <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control" AutoPostBack="true"
                                                                        OnSelectedIndexChanged="sCountry_SelectedIndexChanged">
                                                                    </asp:DropDownList>
                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="rCountry" runat="server" CssClass="form-control" AutoPostBack="true"
                                                                        OnSelectedIndexChanged="rCountry_SelectedIndexChanged">
                                                                    </asp:DropDownList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Agent</td>
                                                                <td>
                                                                    <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="sAgent_SelectedIndexChanged"></asp:DropDownList>
                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="rAgent" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="rAgent_SelectedIndexChanged"></asp:DropDownList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Branch</td>
                                                                <td>
                                                                    <asp:DropDownList ID="sBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="rBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>User</td>
                                                                <td>
                                                                    <asp:TextBox ID="sUser" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rUser" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Zone</td>
                                                                <td>
                                                                    <asp:DropDownList ID="sZone" runat="server" CssClass="form-control"
                                                                        AutoPostBack="True" OnSelectedIndexChanged="sZone_SelectedIndexChanged">
                                                                    </asp:DropDownList>
                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="rZone" runat="server" CssClass="form-control"
                                                                        AutoPostBack="True" OnSelectedIndexChanged="rZone_SelectedIndexChanged">
                                                                    </asp:DropDownList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>District</td>
                                                                <td>
                                                                    <asp:DropDownList ID="sDistrict" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="rDistrict" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Location</td>
                                                                <td>
                                                                    <asp:DropDownList ID="sLocation" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="rLocation" runat="server" CssClass="form-control"></asp:DropDownList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>First Name</td>
                                                                <td>
                                                                    <asp:TextBox ID="sFirstName" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rFirstName" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Middle Name</td>
                                                                <td>
                                                                    <asp:TextBox ID="sMiddleName" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rMiddleName" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Last Name</td>
                                                                <td>
                                                                    <asp:TextBox ID="sLastName1" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rLastName1" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Second Last Name</td>
                                                                <td>
                                                                    <asp:TextBox ID="sLastName2" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rLastName2" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Mobile</td>
                                                                <td>
                                                                    <asp:TextBox ID="sMobile" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rMobile" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>Email</td>
                                                                <td>
                                                                    <asp:TextBox ID="sEmail" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rEmail" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>ID Number</td>
                                                                <td>
                                                                    <asp:TextBox ID="sIDNumber" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rIDNumber" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td><%= Swift.web.Library.GetStatic.ReadWebConfig("tranNoName","") %>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="controlNumber" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </td>
                                            <td valign="top">
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <th>Transaction Type
                                                        <br />
                                                            <asp:DropDownList ID="transactionType" runat="server" CssClass="form-control" Style="margin-top: 13px;"></asp:DropDownList>
                                                        </th>
                                                    </tr>
                                                    <tr>
                                                        <th>Order by
                                                        <br />
                                                            <asp:DropDownList ID="orderBy" runat="server" CssClass="form-control"></asp:DropDownList>
                                                        </th>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="table table-responsive">
                                    <table border="0" class="table table-responsive">
                                        <tr>
                                            <td>
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <th></th>
                                                        <th>From</th>
                                                        <th>To</th>
                                                    </tr>
                                                    <tr>
                                                        <td>Send Date</td>
                                                        <td>
                                                            <asp:TextBox ID="sendDateFrom" onchange="return DateValidation('sendDateFrom','t')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                                            <%--<cc1:CalendarExtender ID="CalendarExtender1" TargetControlID="sendDateFrom" CssClass="cal_Theme1" runat="server"></cc1:CalendarExtender>--%>
                                                            <br />
                                                            <asp:RangeValidator ID="RangeValidator1" runat="server"
                                                                ControlToValidate="sendDateFrom"
                                                                MaximumValue="12/31/2100"
                                                                MinimumValue="01/01/1900"
                                                                Type="Date"
                                                                ErrorMessage="* Invalid date"
                                                                ValidationGroup="tran"
                                                                CssClass="errormsg"
                                                                SetFocusOnError="true"
                                                                Display="Dynamic"> </asp:RangeValidator>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="sendDateTo" onchange="return DateValidation('sendDateTo','t')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                                            <%--<cc1:CalendarExtender ID="CalendarExtender2" TargetControlID="sendDateTo" CssClass="cal_Theme1" runat="server"></cc1:CalendarExtender>--%>
                                                            <br />
                                                            <asp:RangeValidator ID="RangeValidator2" runat="server"
                                                                ControlToValidate="sendDateTo"
                                                                MaximumValue="12/31/2100"
                                                                MinimumValue="01/01/1900"
                                                                Type="Date"
                                                                ErrorMessage="* Invalid date"
                                                                ValidationGroup="tran"
                                                                CssClass="errormsg"
                                                                SetFocusOnError="true"
                                                                Display="Dynamic"> </asp:RangeValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Paid Date</td>
                                                        <td>
                                                            <asp:TextBox ID="paidDateFrom" onchange="return DateValidation('paidDateFrom','t')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                                            <%--<cc1:CalendarExtender ID="CalendarExtender3" TargetControlID="paidDateFrom" CssClass="cal_Theme1" runat="server"></cc1:CalendarExtender>--%>
                                                            <br />
                                                            <asp:RangeValidator ID="RangeValidator3" runat="server"
                                                                ControlToValidate="paidDateFrom"
                                                                MaximumValue="12/31/2100"
                                                                MinimumValue="01/01/1900"
                                                                Type="Date"
                                                                ErrorMessage="* Invalid date"
                                                                ValidationGroup="tran"
                                                                CssClass="errormsg"
                                                                SetFocusOnError="true"
                                                                Display="Dynamic"> </asp:RangeValidator>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="paidDateTo" onchange="return DateValidation('paidDateTo','t')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                                            <%--<cc1:CalendarExtender ID="CalendarExtender4" TargetControlID="paidDateTo" CssClass="cal_Theme1" runat="server"></cc1:CalendarExtender>--%>
                                                            <br />
                                                            <asp:RangeValidator ID="RangeValidator4" runat="server"
                                                                ControlToValidate="paidDateTo"
                                                                MaximumValue="12/31/2100"
                                                                MinimumValue="01/01/1900"
                                                                Type="Date"
                                                                ErrorMessage="* Invalid date"
                                                                ValidationGroup="tran"
                                                                CssClass="errormsg"
                                                                SetFocusOnError="true"
                                                                Display="Dynamic"> </asp:RangeValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Cancelled Date</td>
                                                        <td>
                                                            <asp:TextBox ID="cancelledDateFrom" onchange="return DateValidation('cancelledDateFrom','t')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                                            <%--<cc1:CalendarExtender ID="CalendarExtender5" TargetControlID="cancelledDateFrom" CssClass="cal_Theme1" runat="server"></cc1:CalendarExtender>--%>
                                                            <br />
                                                            <asp:RangeValidator ID="RangeValidator5" runat="server"
                                                                ControlToValidate="cancelledDateFrom"
                                                                MaximumValue="12/31/2100"
                                                                MinimumValue="01/01/1900"
                                                                Type="Date"
                                                                ErrorMessage="* Invalid date"
                                                                ValidationGroup="tran"
                                                                CssClass="errormsg"
                                                                SetFocusOnError="true"
                                                                Display="Dynamic"> </asp:RangeValidator>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="cancelledDateTo" onchange="return DateValidation('cancelledDateTo','t')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                                            <%--<cc1:CalendarExtender ID="CalendarExtender6" TargetControlID="cancelledDateTo" CssClass="cal_Theme1" runat="server"></cc1:CalendarExtender>--%>
                                                            <br />
                                                            <asp:RangeValidator ID="RangeValidator6" runat="server"
                                                                ControlToValidate="cancelledDateTo"
                                                                MaximumValue="12/31/2100"
                                                                MinimumValue="01/01/1900"
                                                                Type="Date"
                                                                ErrorMessage="* Invalid date"
                                                                ValidationGroup="tran"
                                                                CssClass="errormsg"
                                                                SetFocusOnError="true"
                                                                Display="Dynamic"> </asp:RangeValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Approved Date</td>
                                                        <td>
                                                            <asp:TextBox ID="approvedDateFrom" onchange="return DateValidation('approvedDateFrom','t')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                                            <%--<cc1:CalendarExtender ID="CalendarExtender7" TargetControlID="approvedDateFrom" CssClass="cal_Theme1" runat="server"></cc1:CalendarExtender>--%>
                                                            <br />
                                                            <asp:RangeValidator ID="RangeValidator7" runat="server"
                                                                ControlToValidate="approvedDateFrom"
                                                                MaximumValue="12/31/2100"
                                                                MinimumValue="01/01/1900"
                                                                Type="Date"
                                                                ErrorMessage="* Invalid date"
                                                                ValidationGroup="tran"
                                                                CssClass="errormsg"
                                                                SetFocusOnError="true"
                                                                Display="Dynamic"> </asp:RangeValidator>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="approvedDateTo" onchange="return DateValidation('approvedDateTo','t')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                                            <%--<cc1:CalendarExtender ID="CalendarExtender8" TargetControlID="approvedDateTo" CssClass="cal_Theme1" runat="server"></cc1:CalendarExtender>--%>
                                                            <br />
                                                            <asp:RangeValidator ID="RangeValidator8" runat="server"
                                                                ControlToValidate="approvedDateTo"
                                                                MaximumValue="12/31/2100"
                                                                MinimumValue="01/01/1900"
                                                                Type="Date"
                                                                ErrorMessage="* Invalid date"
                                                                ValidationGroup="tran"
                                                                CssClass="errormsg"
                                                                SetFocusOnError="true"
                                                                Display="Dynamic"> </asp:RangeValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Collection Amount</td>
                                                        <td>
                                                            <asp:TextBox ID="collectionAmountFrom" runat="server" CssClass="form-control"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="collectionAmountTo" runat="server" CssClass="form-control"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>Payout Amount</td>
                                                        <td>
                                                            <asp:TextBox ID="payoutAmountFrom" runat="server" CssClass="form-control"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="payoutAmountTo" runat="server" CssClass="form-control"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td>
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <td>Status
                                                            <br />
                                                            <asp:DropDownList ID="tranStatus" runat="server" CssClass="form-control" Style="margin-top: 11px;"></asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="form-group">
                                    <table border="0" cellspacing="0" cellpadding="0" align="left" class="table table-responsive" style="clear: both; width: 900px">
                                        <tr>
                                            <th nowrap="nowrap">
                                                <div align="left" title="Check / Uncheck all"><a href="javascript:void(0);" onclick="CheckAll(this,'tranSend')">Transaction Send</a></div>
                                            </th>
                                            <th nowrap="nowrap">
                                                <div align="left" title="Check / Uncheck all"><a href="javascript:void(0);" onclick="CheckAll(this,'sender')">Sender Information</a></div>
                                            </th>
                                            <th nowrap="nowrap">
                                                <div align="left" title="Check / Uncheck all"><a href="javascript:void(0);" onclick="CheckAll(this,'tranPay')">Transaction Pay</a></div>
                                            </th>
                                            <th nowrap="nowrap">
                                                <div align="left" title="Check / Uncheck all"><a href="javascript:void(0);" onclick="CheckAll(this,'receiver')">Receiver Information</a></div>
                                            </th>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap" valign="top">
                                                <div id="divTranSend" runat="server"></div>
                                            </td>
                                            <td nowrap="nowrap" valign="top">
                                                <div id="divSender" runat="server"></div>
                                            </td>
                                            <td nowrap="nowrap" valign="top">
                                                <div id="divTranPay" runat="server"></div>
                                            </td>
                                            <td nowrap="nowrap" valign="top">
                                                <div id="divReceiver" runat="server"></div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type="button" class="button" value=" Search " onclick=" return showReport(); " />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
<script type="text/javascript">
        function showReport() {
            var ssAgent = GetValue("<% =ssAgent.ClientID%>");
            var sCountry = GetValue("<% =sCountry.ClientID%>");
            var sAgent = GetValue("<% =sAgent.ClientID%>");
            var sBranch = GetValue("<% =sBranch.ClientID%>");
            var sUser = GetValue("<% =sUser.ClientID%>");
            var sZone = GetValue("<% =sZone.ClientID%>");
            var sDistrict = GetValue("<% =sDistrict.ClientID%>");

            var sLocation = GetValue("<% =sLocation.ClientID%>");
            var sFirstName = GetValue("<% =sFirstName.ClientID%>");
            var sMiddleName = GetValue("<% =sMiddleName.ClientID%>");
            var sLastName1 = GetValue("<% =sLastName1.ClientID%>");
            var sLastName2 = GetValue("<% =sLastName2.ClientID%>");
            var sMobile = GetValue("<% =sMobile.ClientID%>");
            var sEmail = GetValue("<% =sEmail.ClientID%>");
            var sIDNumber = GetValue("<% =sIDNumber.ClientID%>");

            var rsAgent = GetValue("<% =rsAgent.ClientID%>");
            var rCountry = GetValue("<% =rCountry.ClientID%>");
            var rAgent = GetValue("<% =rAgent.ClientID%>");
            var rBranch = GetValue("<% =rBranch.ClientID%>");
            var rUser = GetValue("<% =rUser.ClientID%>");
            var rZone = GetValue("<% =rZone.ClientID%>");
            var rDistrict = GetValue("<% =rDistrict.ClientID%>");

            var rLocation = GetValue("<% =rLocation.ClientID%>");
            var rFirstName = GetValue("<% =rFirstName.ClientID%>");
            var rMiddleName = GetValue("<% =rMiddleName.ClientID%>");
            var rLastName1 = GetValue("<% =rLastName1.ClientID%>");
            var rLastName2 = GetValue("<% =rLastName2.ClientID%>");
            var rMobile = GetValue("<% =rMobile.ClientID%>");
            var rEmail = GetValue("<% =rEmail.ClientID%>");
            var rIDNumber = GetValue("<% =rIDNumber.ClientID%>");

            var controlNumber = GetValue("<% =controlNumber.ClientID%>");
            var tranType = GetValue("<% =transactionType.ClientID%>");

            var orderBy = GetValue("<% =orderBy.ClientID%>");
            var sendDateFrom = GetValue("<% =sendDateFrom.ClientID%>");
            var sendDateTo = GetValue("<% =sendDateTo.ClientID%>");
            var paidDateFrom = GetValue("<% =paidDateFrom.ClientID%>");

            var paidDateTo = GetValue("<% =paidDateTo.ClientID%>");
            var cancelledDateFrom = GetValue("<% =cancelledDateFrom.ClientID%>");
            var cancelledDateTo = GetValue("<% =cancelledDateTo.ClientID%>");
            var approvedDateFrom = GetValue("<% =approvedDateFrom.ClientID%>");
            var approvedDateTo = GetValue("<% =approvedDateTo.ClientID%>");
            var collectionAmountFrom = GetValue("<% =collectionAmountFrom.ClientID%>");
            var collectionAmountTo = GetValue("<% =collectionAmountTo.ClientID%>");
            var payoutAmountFrom = GetValue("<% =payoutAmountFrom.ClientID%>");

            var payoutAmountTo = GetValue("<% =payoutAmountTo.ClientID%>");
            var tranStatus = GetValue("<% =tranStatus.ClientID%>");

            var tranSend = GetIds("tranSend");
            var sender = GetIds("sender");
            var tranPay = GetIds("tranPay");
            var receiver = GetIds("receiver");

            var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=trnRptMaster" +
                    "&ssAgent=" + ssAgent +
                    "&sCountry=" + sCountry +
                    "&sAgent=" + sAgent +
                    "&sBranch=" + sBranch +
                    "&sUser=" + sUser +
                    "&sZone=" + sZone +
                    "&sDistrict=" + sDistrict +
                    "&sLocation=" + sLocation +
                    "&sFirstName=" + sFirstName +
                    "&sMiddleName=" + sMiddleName +
                    "&sLastName1=" + sLastName1 +
                    "&sLastName2=" + sLastName2 +
                    "&sMobile=" + sMobile +
                    "&sEmail=" + sEmail +
                    "&sIDNumber=" + sIDNumber +
                    "&rsAgent=" + rsAgent +
                    "&rCountry=" + rCountry +
                    "&rAgent=" + rAgent +
                    "&rBranch=" + rBranch +
                    "&rUser=" + rUser +
                    "&rZone=" + rZone +
                    "&rDistrict=" + rDistrict +
                    "&rLocation=" + rLocation +
                    "&rFirstName=" + rFirstName +
                    "&rMiddleName=" + rMiddleName +
                    "&rLastName1=" + rLastName1 +
                    "&rLastName2=" + rLastName2 +
                    "&rMobile=" + rMobile +
                    "&rEmail=" + rEmail +
                    "&rIDNumber=" + rIDNumber +
                    "&controlNumber=" + controlNumber +
                    "&tranType=" + tranType +

                    "&orderBy=" + orderBy +
                    "&sendDateFrom=" + sendDateFrom +
                    "&sendDateTo=" + sendDateTo +
                    "&paidDateFrom=" + paidDateFrom +
                    "&paidDateTo=" + paidDateTo +
                    "&cancelledDateFrom=" + cancelledDateFrom +
                    "&cancelledDateTo=" + cancelledDateTo +
                    "&approvedDateFrom=" + approvedDateFrom +
                    "&approvedDateTo=" + approvedDateTo +
                    "&collectionAmountFrom=" + collectionAmountFrom +
                    "&collectionAmountTo=" + collectionAmountTo +
                    "&payoutAmountFrom=" + payoutAmountFrom +
                    "&payoutAmountTo=" + payoutAmountTo +
                    "&tranStatus=" + tranStatus +
                    "&tranSend=" + tranSend +
                    "&sender=" + sender +
                    "&tranPay=" + tranPay +
                    "&receiver=" + receiver;

            OpenInNewWindow(url);
            return false;
    }
</script>
</html>