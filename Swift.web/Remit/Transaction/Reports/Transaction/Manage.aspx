<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.Transaction.Manage" %>

<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <%--  <link href="../../../../Css/style.css" rel="Stylesheet" type="text/css" />--%>
    <link href="/Css/swift_component.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/js/functions.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        var urlRoot = "<%=GetStatic.GetUrlRoot() %>";
        $(document).ready(function () {
            $.ajaxSetup({ cache: false });
        });
        $(document).ready(function () {
            PopulateRptTemplate();
        });
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>","#<% =toDate.ClientID%>");
            ShowCalFromToUpToToday("#<% =localDateFrom.ClientID%>","#<% =localDateTo.ClientID%>");
            ShowCalFromToUpToToday("#<% =paidDateFrom.ClientID%>","#<% =paidDateTo.ClientID%>");
            ShowCalFromToUpToToday("#<% =confirmDateFrom.ClientID%>","#<% =confirmDateTo.ClientID%>");
            ShowCalFromToUpToToday("#<% =cancelledDateFrom.ClientID%>","#<% =cancelledDateTo.ClientID%>");
        }
        LoadCalendars();
        function ShowAdvanceSearch(idAdvanceSrc, normalSearch, idImg) {
            var td = document.getElementById(idAdvanceSrc);
            var tr = document.getElementById(normalSearch);
            var img = document.getElementById(idImg);
            if (td != null && tr != null) {
                var isHidden = td.style.display == "none" ? true : false;
                if (isHidden == true) {
                    GetElement("hdnIsAdvaceSearch").value = "Y";
                    td.style.display = "block";
                    tr.style.display = "none";
                }
                else {
                    GetElement("hdnIsAdvaceSearch").value = "N";
                    td.style.display = "none";
                    tr.style.display = "block";
                }
                img.src = isHidden ? "../../../../images/icon_hide.gif" : "../../../../images/icon_show.gif";
                img.title = isHidden ? "Hide" : "Show";
            }
            //window.parent.resizeIframe();
        }
        function OpenLink(URL) {
            var id = PopUpWindowWithCallBackBigSize(URL, "");
            if (id == "undefined" || id == null || id == "") {
            }
            else {
                PopulateRptTemplate();
            }
            return false;
        }

        function IsDelete() {
            if (confirm("Confirm To Delete?")) {
                var tempId = GetValue("<% =hdnTempId.ClientID%>");
                $.get(urlRoot + "/Remit/Transaction/Reports/Transaction/FormLoader.aspx", { type: 'd', templateId: tempId }, function (data) {

                    var res = data.split('|');
                    if (res[0] != "0") {
                        window.parent.SetMessageBox(res[1], '1');
                        return;
                    }
                    else {
                        sFShowHide.style.display = "none";
                        PopulateRptTemplate();
                        window.parent.SetMessageBox(res[1], '0');
                    }
                });
            }
        }
        function PopulateRptTemplate() {

            $.get(urlRoot + "/Remit/Transaction/Reports/Transaction/FormLoader.aspx", { type: 'a' }, function (data) {
                GetElement("divRptTemplate").innerHTML = data;
            });

        }

        function PopulateRptFields() {
            var tempId = GetValue("reportTemplate");

            if (tempId == "")
                sFShowHide.style.display = "none";
            else
                sFShowHide.style.display = "block";

            $.get(urlRoot + "/Remit/Transaction/Reports/Transaction/FormLoader.aspx", { type: 'b', templateId: tempId }, function (data) {
                GetElement("showTemplate").innerHTML = data;
                GetElement("hdnTempId").value = tempId;
            });
            GetElement("reportTemplate").focus();
        }

    </script>
    <style type="text/css">
        input[readonly="readonly"] {
            background: #EFEFEF !important;
            color: #666666 !important;
        }

        .disabled {
            background: #EFEFEF !important;
            color: #666666 !important;
        }

        .page-title {
            border-bottom: 2px solid #f5f5f5;
            margin-bottom: 15px;
            padding-bottom: 10px;
            text-transform: capitalize;
        }

            .page-title .breadcrumb {
                background-color: transparent;
                margin: 0;
                padding: 0;
            }

        .breadcrumb > li {
            display: inline-block;
        }

            .breadcrumb > li a {
                color: #0E96EC;
            }

            .breadcrumb > li + li::before {
                color: #ccc;
                content: "/ ";
                padding: 0 5px;
            }

        .tabs > li > a {
            padding: 10px 15px;
            background-color: #444d58;
            border-radius: 5px 5px 0 0;
            color: #fff;
        }

        .table .table {
            background-color: #F5F5F5 !important;
        }

        .responsive-table {
            background-color: #F5F5F5;
            width: 1134px;
            overflow-x: scroll;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnIsAdvaceSearch" runat="server" Value="N" />
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('report')">Reports </a></li>
                            <li class="active"><a href="Manage.aspx">Transaction Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Transaction Report</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <table class=" table table-responsive">
                                <tr>
                                    <td>
                                        <tr>
                                            <td colspan="4">
                                                <asp:UpdatePanel ID="updatePanel1" runat="server">
                                                    <ContentTemplate>
                                                        <table class="table table-responsive">
                                                            <tr>
                                                                <td>&nbsp;</td>
                                                                <td>Sending</td>
                                                                <td>Receiving</td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Country:</div>
                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="sCountry" runat="server"
                                                                        CssClass="form-control" AutoPostBack="True" Style="width: 400px;"
                                                                        OnSelectedIndexChanged="sCountry_SelectedIndexChanged">
                                                                    </asp:DropDownList>

                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="rCountry" runat="server" Style="width: 400px;"
                                                                        CssClass="form-control" AutoPostBack="True"
                                                                        OnSelectedIndexChanged="rCountry_SelectedIndexChanged">
                                                                    </asp:DropDownList>

                                                                </td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Agent:</div>
                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="sAgent" runat="server"
                                                                        CssClass="form-control" AutoPostBack="True" Style="width: 400px;"
                                                                        OnSelectedIndexChanged="sAgent_SelectedIndexChanged">
                                                                    </asp:DropDownList>

                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="rAgent" runat="server" Style="width: 400px;"
                                                                        CssClass="form-control" AutoPostBack="True"
                                                                        OnSelectedIndexChanged="rAgent_SelectedIndexChanged">
                                                                    </asp:DropDownList>

                                                                </td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Branch:</div>
                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="sBranch" runat="server" Style="width: 400px;"
                                                                        CssClass="form-control">
                                                                    </asp:DropDownList>

                                                                </td>
                                                                <td>
                                                                    <asp:DropDownList ID="rBranch" runat="server" Style="width: 400px;"
                                                                        CssClass="form-control">
                                                                    </asp:DropDownList>

                                                                </td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                        </table>
                                                    </ContentTemplate>
                                                    <Triggers>
                                                        <asp:AsyncPostBackTrigger ControlID="sCountry" EventName="SelectedIndexChanged" />
                                                        <asp:AsyncPostBackTrigger ControlID="rCountry" EventName="SelectedIndexChanged" />
                                                        <asp:AsyncPostBackTrigger ControlID="sAgent" EventName="SelectedIndexChanged" />
                                                        <asp:AsyncPostBackTrigger ControlID="rAgent" EventName="SelectedIndexChanged" />
                                                    </Triggers>
                                                </asp:UpdatePanel>
                                            </td>
                                        </tr>

                                        <table class=" table table-responsive">
                                            <tr id="ShowHideAd" runat="server" visible="false">
                                                <td colspan="4"><span><b>&nbsp;<a href="#" onclick="ShowAdvanceSearch('advanceSerach','normalSearch', 'img_Search');">Advance Search
                                                     <img src="../../../../images/icon_show.gif"
                                                         border="0" title="Show" id="img_Search" /></a></b></span>
                                                    <br />
                                                    <fieldset id="advanceSerach" style="display: none">
                                                        <legend>Search By                     
                                                        </legend>
                                                        <table class="table table-responsive">
                                                            <tr>
                                                                <td>&nbsp;</td>
                                                                <td>Sender</td>
                                                                <td>Receiver</td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Full Name</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="TextBox1" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="TextBox2" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">First Name </div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="sFirstName" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rFirstName" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Middle Name</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="sMiddleName" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rMiddleName" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Last Name</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="sLastName" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rLastName" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">2nd Last Name</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="sSecondLastName" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rSecondLastName" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Mobile</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="sMobile" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rMobile" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Email</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="sEmail" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rEmail" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Id Number</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="sIdNumber" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rIdNumber" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                            </tr>

                                                            <tr>
                                                                <td>
                                                                    <div align="left" class="formLabel">State</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="sState" runat="server" Width="400px" CssClass="form-control" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rState" runat="server" Width="400px" CssClass="form-control" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">City</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="sCity" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rCity" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Zip</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="sZip" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="rZip" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">TranNo</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="tranNo" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">BRN</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="icn" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Sender Company</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="senderCompany" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td>&nbsp;</td>
                                                                <td>&nbsp;</td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td>&nbsp;</td>
                                                                <td>
                                                                    <div align="left" class="formLabel">Amount From</div>
                                                                </td>
                                                                <td>
                                                                    <div align="left" class="formLabel">Amount To</div>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Collection Amount</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="cAmtFrom" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="cAmtTo" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Payout Amount</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="pAmtFrom" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="pAmtTo" runat="server" CssClass="form-control" Style="width: 400px;" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>&nbsp;</td>
                                                                <td>&nbsp;</td>
                                                                <td>&nbsp;</td>
                                                            </tr>
                                                            <tr>
                                                                <td>&nbsp;</td>
                                                                <td>
                                                                    <div align="left" class="formLabel">Date From</div>
                                                                </td>
                                                                <td>
                                                                    <div align="left" class="formLabel">Date To</div>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">TXN Date</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="localDateFrom" runat="server" ReadOnly="true" CssClass="form-control" Width="400px" size="12" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="localDateTo" runat="server" ReadOnly="true" CssClass="form-control" Width="400px" size="12" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Confirm</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="confirmDateFrom" runat="server" ReadOnly="true" CssClass="form-control" Width="400px" size="12" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="confirmDateTo" runat="server" ReadOnly="true" CssClass="form-control" Width="400px" size="12" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Paid</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="paidDateFrom" runat="server" CssClass="form-control" ReadOnly="true" Style="width: 400px;" size="12" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="paidDateTo" runat="server" CssClass="form-control" ReadOnly="true" Style="width: 400px;" size="12" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Cancelled</div>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="cancelledDateFrom" runat="server" CssClass="form-control" ReadOnly="true" Style="width: 400px;" size="12" />
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="cancelledDateTo" runat="server" CssClass="form-control" ReadOnly="true" Style="width: 400px;" size="12" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </fieldset>
                                                </td>
                                            </tr>
                                        </table>
                                        <table class=" table table-responsive">
                                            <tr>
                                                <td colspan="4">
                                                    <table id="normalSearch" class=" table table-responsive">
                                                        <fieldset>
                                                            <legend></legend>
                                                            <tr>
                                                                <td width="130px">
                                                                    <div align="left" class="formLabel">Date:</div>
                                                                </td>
                                                                <td>From
                                                                    <br />
                                                                    <asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t')" MaxLength="10" runat="server" CssClass="form-control" Width="250px" size="12"></asp:TextBox>
                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate" ForeColor="Red"
                                                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>

                                                                </td>
                                                                <td>To
                                                                    <br />
                                                                    <asp:TextBox ID="toDate" onchange="return DateValidation('toDate','t')" MaxLength="10" runat="server" CssClass="form-control" Width="250px" size="12"></asp:TextBox>
                                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="toDate" ForeColor="Red"
                                                                        ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                                    </asp:RequiredFieldValidator>
                                                                </td>
                                                                <td>Date Type:
                                                                    <br />
                                                                    <asp:DropDownList ID="dateType" runat="server" CssClass="form-control" Width="250px">
                                                                        <asp:ListItem Value="confirmDate">Confirm Date</asp:ListItem>
                                                                        <asp:ListItem Value="localDate">TXN Date</asp:ListItem>
                                                                        <asp:ListItem Value="paidDate">Paid Date</asp:ListItem>
                                                                        <asp:ListItem Value="cancelledDate">Cancelled Date</asp:ListItem>
                                                                    </asp:DropDownList>
                                                                </td>
                                                            </tr>
                                                        </fieldset>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="130px">
                                                    <div align="left" class="formLabel">Tran Type:</div>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="tranType" runat="server" CssClass="form-control" Style="width: 400px;">
                                                        <asp:ListItem Value="">All</asp:ListItem>
                                                        <asp:ListItem Value="D">Domestic</asp:ListItem>
                                                        <asp:ListItem Value="I">International</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="130px">
                                                    <div align="left" class="formLabel">Receiving Mode:</div>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="receivingMode" runat="server" CssClass="form-control" Style="width: 400px;"></asp:DropDownList>
                                                </td>
                                                <td>&nbsp;</td>
                                                <td>&nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td width="130px">
                                                    <div align="left" class="formLabel">Status:</div>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="status" runat="server" CssClass="form-control" Style="width: 400px;"></asp:DropDownList>
                                                </td>
                                                <td>&nbsp;</td>
                                                <td>&nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td width="130px">
                                                    <div align="left" class="formLabel">Report In:</div>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="reportIn" runat="server" CssClass="form-control" Style="width: 400px;">
                                                        <asp:ListItem Value="cCurr">Collection Currency</asp:ListItem>
                                                        <asp:ListItem Value="usd" Text="<%$ AppSettings: currencyUSA %>"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td>&nbsp;</td>
                                                <td>&nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td width="130px">
                                                    <div align="left" class="formLabel">Report Template:</div>
                                                </td>
                                                <td>
                                                    <div id="divRptTemplate" runat="server" style="float: left; width: 400px;"></div>
                                                    &nbsp;&nbsp;
                                                    <a href='#' onclick="OpenLink('ManageTemplate.aspx')">Add New Template</a>
                                                </td>
                                                <td>&nbsp;</td>
                                                <td>&nbsp;</td>
                                            </tr>
                                            <tr>
                                                <td>&nbsp;</td>
                                                <td>
                                                    <asp:Button ID="BtnSave1" runat="server" CssClass="btn btn-primary"
                                                        Text=" Search " ValidationGroup="rpt"
                                                        OnClientClick="return showReport();" />
                                                    &nbsp;&nbsp;
                                                </td>
                                                <td>&nbsp;</td>
                                                <td>&nbsp;</td>
                                            </tr>
                                        </table>
                                        <table class=" table table-responsive">
                                            <tr>
                                                <td colspan="4">
                                                    <div id="sFShowHide" style="display: none;" runat="server">
                                                        <fieldset>
                                                            <legend>Selected Fields (Template Delete:  
                                                            <a href="#">
                                                                <img style="cursor: pointer;" title="Delete Template" class="showHand"
                                                                    src="../../../../Images/delete.gif" onclick="IsDelete()" /></a>) </legend>
                                                            <table class=" table table-responsive">
                                                                <tr>
                                                                    <td width="700px">
                                                                        <asp:HiddenField ID="hdnTempId" runat="server" />
                                                                        <div id="showTemplate" runat="server"></div>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </fieldset>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    function showReport() {
        if (!Page_ClientValidate('rpt'))
            return false;

        var rptTemplate = document.getElementById("reportTemplate").value;
        if (rptTemplate == "") {
            alert("Please choose report template!");
            return false;
        }
        var sCountry = GetValue("<% =sCountry.ClientID%>");
        var rCountry = GetValue("<% =rCountry.ClientID%>");
        var sAgent = GetValue("<% =sAgent.ClientID%>");
        var rAgent = GetValue("<% =rAgent.ClientID%>");
        var sBranch = GetValue("<% =sBranch.ClientID%>");
        var rBranch = GetValue("<% =rBranch.ClientID%>");
        var sFirstName = GetValue("<% =sFirstName.ClientID%>");
        var rFirstName = GetValue("<% =rFirstName.ClientID%>");
        var sMiddleName = GetValue("<% =sMiddleName.ClientID%>");
        var rMiddleName = GetValue("<% =rMiddleName.ClientID%>");
        var sLastName = GetValue("<% =sLastName.ClientID%>");
        var rLastName = GetValue("<% =rLastName.ClientID%>");
        var sSecondLastName = GetValue("<% =sSecondLastName.ClientID%>");
        var rSecondLastName = GetValue("<% =rSecondLastName.ClientID%>");
        var sMobile = GetValue("<% =sMobile.ClientID%>");
        var rMobile = GetValue("<% =rMobile.ClientID%>");
        var sEmail = GetValue("<% =sEmail.ClientID%>");
        var rEmail = GetValue("<% =rEmail.ClientID%>");
        var sIdNumber = GetValue("<% =sIdNumber.ClientID%>");
        var rIdNumber = GetValue("<% =rIdNumber.ClientID%>");
        var sState = GetValue("<% =sState.ClientID%>");
        var rState = GetValue("<% =rState.ClientID%>");
        var sCity = GetValue("<% =sCity.ClientID%>");
        var rCity = GetValue("<% =rCity.ClientID%>");
        var sZip = GetValue("<% =sZip.ClientID%>");
        var rZip = GetValue("<% =rZip.ClientID%>");
        var tranNo = GetValue("<% =tranNo.ClientID%>");
        var icn = GetValue("<% =icn.ClientID%>");
        var senderCompany = GetValue("<% =senderCompany.ClientID%>");
        var cAmtFrom = GetValue("<% =cAmtFrom.ClientID%>");
        var cAmtTo = GetValue("<% =cAmtTo.ClientID%>");
        var pAmtFrom = GetValue("<% =pAmtFrom.ClientID%>");
        var pAmtTo = GetValue("<% =pAmtTo.ClientID%>");
        var localDateFrom = GetValue("<% =localDateFrom.ClientID%>");
        var localDateTo = GetValue("<% =localDateTo.ClientID%>");
        var confirmDateFrom = GetValue("<% =confirmDateFrom.ClientID%>");
        var confirmDateTo = GetValue("<% =confirmDateTo.ClientID%>");
        var paidDateFrom = GetValue("<% =paidDateFrom.ClientID%>");
        var paidDateTo = GetValue("<% =paidDateTo.ClientID%>");
        var cancelledDateFrom = GetValue("<% =cancelledDateFrom.ClientID%>");
        var cancelledDateTo = GetValue("<% =cancelledDateTo.ClientID%>");
        var receivingMode = GetValue("<% =receivingMode.ClientID%>");
        var status = GetValue("<% =status.ClientID%>");
        var reportIn = GetValue("<% =reportIn.ClientID%>");

        var fromDate = GetValue("<% =fromDate.ClientID%>");
        var toDate = GetValue("<% =toDate.ClientID%>");
        var dateType = GetValue("<% =dateType.ClientID%>");
        var isAdvanceSearch = GetValue("<% =hdnIsAdvaceSearch.ClientID%>");
        var tranType = GetValue("<%=tranType.ClientID %>");

        var url = "../../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=transactionnewrpt" +
            "&sCountry= " + sCountry +
            "&rCountry=" + rCountry +
            "&sAgent=" + sAgent +
            "&rAgent=" + rAgent +
            "&sBranch=" + sBranch +
            "&rBranch=" + rBranch +
            "&sFirstName=" + sFirstName +
            "&rFirstName=" + rFirstName +
            "&sMiddleName=" + sMiddleName +
            "&rMiddleName=" + rMiddleName +
            "&sLastName=" + sLastName +
            "&rLastName=" + rLastName +
            "&sSecondLastName=" + sSecondLastName +
            "&rSecondLastName=" + rSecondLastName +
            "&sMobile=" + sMobile +
            "&rMobile=" + rMobile +
            "&sEmail=" + sEmail +
            "&rEmail=" + rEmail +
            "&sIdNumber=" + sIdNumber +
            "&rIdNumber=" + rIdNumber +
            "&sState=" + sState +
            "&rState=" + rState +
            "&sCity=" + sCity +
            "&rCity=" + rCity +
            "&sZip=" + sZip +
            "&rZip=" + rZip +
            "&tranNo=" + tranNo +
            "&icn=" + icn +
            "&senderCompany=" + senderCompany +
            "&cAmtFrom=" + cAmtFrom +
            "&cAmtTo=" + cAmtTo +
            "&pAmtFrom=" + pAmtFrom +
            "&pAmtTo=" + pAmtTo +
            "&localDateFrom=" + localDateFrom +
            "&localDateTo=" + localDateTo +
            "&confirmDateFrom=" + confirmDateFrom +
            "&confirmDateTo=" + confirmDateTo +
            "&paidDateFrom=" + paidDateFrom +
            "&paidDateTo=" + paidDateTo +
            "&cancelledDateFrom=" + cancelledDateFrom +
            "&cancelledDateTo=" + cancelledDateTo +
            "&receivingMode=" + receivingMode +
            "&status=" + status +
            "&reportIn=" + reportIn +
            "&rptTemplate=" + rptTemplate +
            "&fromDate=" + fromDate +
            "&toDate=" + toDate +
            "&dateType=" + dateType +
            "&isAdvanceSearch=" + isAdvanceSearch +
            "&tranType=" + tranType;

        OpenInNewWindow(url);
        return false;
    }
</script>
<script type='text/javascript' language='javascript'>
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
    function EndRequest(sender, args) {
        if (args.get_error() == undefined) {
            LoadCalendars();
        }
    }
</script>
