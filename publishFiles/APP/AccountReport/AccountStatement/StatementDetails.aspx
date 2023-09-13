<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StatementDetails.aspx.cs"
    Inherits="Swift.web.AccountReport.AccountStatement.StatementDetails" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">

    <!--new css and js -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/metisMenu.min.js"></script>
    <!--page plugins-->
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <!-- end -->

    <base id="Base1" runat="server" target="_self" />
    <script src="/js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <%-- <link href="../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <script type="text/javascript">
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =startDate.ClientID %>", "#<% =endDate.ClientID %>", 1);
        }
        LoadCalendars();
        function DownloadPDF() {
            $(".noPrint").css("display", "none");
            var copy = document.getElementById("main").innerHTML;
            var encodedText = encodeURIComponent(copy);
            $("#hidden").val(encodedText);
            document.getElementById("buttonPdf").click();
        }
    </script>
</head>
<body>
    <form id="form" method="post" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Account Report </a></li>
                            <li class="active"><a href="Statementdetails.aspx?startDate=<%= StartDate() %>&endDate=<%= EndDate() %>&acNum=<%= AccountNumber() %>&acName=<%=AccountName() %>">Balance Sheet</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <asp:Button ID="buttonPdf" runat="server" OnClick="buttonPdf_Click" Style="display: none;" />
            <asp:HiddenField ID="hidden" runat="server" />
            <div class="row">
                <div class="col-md-12">
                    <div class="table-responsive">
                        <table class="table">
                            <tr>
                                <td>
                                    <%-- <table width="30%">--%>
                                    <div class="table-responsive">
                                        <table class="table" width="100%" cellspacing="0" class="TBLReport">
                                            <tr>
                                                <td width="5%" nowrap="nowrap" align="left">
                                                    <strong>AC number:</strong>
                                                </td>
                                                <td nowrap="nowrap" align="left">
                                                    <asp:Label ID="acNumber" runat="server"></asp:Label>
                                                </td>
                                                <td align="right">
                                                    <i class="fa fa-file-pdf-o" aria-hidden="true"></i>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap" align="left">
                                                    <strong>AC Name:</strong>
                                                </td>
                                                <td nowrap="nowrap" align="left">
                                                    <asp:Label ID="acName" runat="server"></asp:Label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap" align="left">
                                                    <strong>Currency:</strong>
                                                </td>
                                                <td nowrap="nowrap" align="left">
                                                    <asp:DropDownList ID="ddlCurrency" runat="server" CssClass="form-control">
                                                    </asp:DropDownList>
                                                    <asp:HiddenField ID="hdnRptType" runat="server" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap" align="left">
                                                    <strong>Start Date: </strong>
                                                </td>
                                                <td nowrap="nowrap" align="left">
                                                    <div class="input-group m-b">
                                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                        <asp:TextBox ID="startDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap" align="left">
                                                    <strong>End Date: </strong>
                                                </td>
                                                <td align="left" nowrap="nowrap">
                                                    <div class="input-group m-b">
                                                        <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                        <asp:TextBox ID="endDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td nowrap="nowrap">&nbsp;
                                                </td>
                                                <td nowrap="nowrap">
                                                    <div align="left">
                                                        <asp:Button ID="goBtn" CssClass="btn btn-primary" runat="server" Text="Go" OnClick="goBtn_Click" />
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="main">
                                        <div id="tableBody" runat="server" class="col-md-12 table-responsive">
                                            <div class="table-responsive">
                                                <table class="table table-striped table-bordered" width="100%" cellspacing="0" class="TBLReport">
                                                    <tr>
                                                        <th nowrap="nowrap">Tran Date
                                                        </th>
                                                        <th nowrap="nowrap">Description
                                                        </th>
                                                        <th nowrap="nowrap">Dr Amount
                                                        </th>
                                                        <th nowrap="nowrap">Cr Amount
                                                        </th>
                                                        <th colspan="2" nowrap="nowrap">Balance
                                                        </th>
                                                    </tr>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="6">
                                    <table width="35%" border="0" align="right" cellpadding="2" cellspacing="1">
                                        <tr>
                                            <td nowrap="nowrap">
                                                <div align="right">
                                                    <strong>Opening Balance: </strong>
                                                </div>
                                            </td>
                                            <td nowrap="nowrap" style="text-align: right;">
                                                <div align="right">
                                                    <strong>
                                                        <asp:Label ID="openingBalance" runat="server"></asp:Label>
                                                    </strong>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap">
                                                <div align="right">
                                                    <strong>Total DR:(
                                                    <asp:Label runat="server" ID="drCount1"></asp:Label>)</strong>
                                                </div>
                                            </td>
                                            <td nowrap="nowrap" style="text-align: right;">
                                                <div align="right">
                                                    <strong>
                                                        <asp:Label runat="server" ID="totalDr"></asp:Label>
                                                    </strong>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap">
                                                <div align="right">
                                                    <strong>Total CR:(
                                                    <asp:Label runat="server" ID="crCount1"></asp:Label>)</strong>
                                                </div>
                                            </td>
                                            <td nowrap="nowrap" style="text-align: right;">
                                                <div align="right">
                                                    <strong>
                                                        <asp:Label runat="server" ID="totalCr"></asp:Label>
                                                    </strong>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap">
                                                <div align="right">
                                                    <strong>Closing Balance:(
                                                <asp:Label runat="server" ID="drOrCr"></asp:Label>)</strong>
                                                </div>
                                            </td>
                                            <td nowrap="nowrap" style="text-align: right;">
                                                <div align="right">
                                                    <a href="#" id="closingBalance" title="Bill by Bill Outstanding"><strong>
                                                        <asp:Label ID="closingBalanceAmt" runat="server">0.00</asp:Label>
                                                    </strong></a>
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
    </form>
</body>
</html>