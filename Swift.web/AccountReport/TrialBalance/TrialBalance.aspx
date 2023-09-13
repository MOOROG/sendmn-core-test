<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TrialBalance.aspx.cs" Inherits="Swift.web.AccountReport.TrialBalance.TrialBalance" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!-- <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <%--<link href="../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <link href="../../css/formStyle.css" rel="stylesheet" type="text/css" />
    <script src="../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript">
        function DownloadPDF() {
            $(".noPrint").css("display", "none");
            var copy = document.getElementById("main").innerHTML;
            var encodedText = encodeURIComponent(copy);
            $("#hidden").val(encodedText);
            document.getElementById("pdf").click();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <%-- <h1>
                                Day Book <small></small>
                            </h1>--%>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Account Report </a></li>
                            <li class="active"><a href="TrialBalance.aspx?fromDate=<%=FromDate()%>&toDate=<%=ToDate() %>&report_Type=<%=ReportType() %>">Trial Balance</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <asp:Button ID="pdf" runat="server" runat="server" OnClick="pdf_Click" Style="display: none;" />
            <asp:HiddenField ID="hidden" runat="server" />
            <div id="main">
                <%--<table width="100%">--%>
                <div class="row">
                    <div class="form-group col-md-12">

                        <div class="table-responsive">
                            <table class="table">
                                <tr>
                                    <td>
                                        <div class="table-responsive">
                                            <table class="table">
                                                <tr>
                                                    <td>
                                                        <div class="table-responsive">
                                                            <table class="table">
                                                                <tr>
                                                                    <td>
                                                                        <div class="table-responsive">
                                                                            <table class="table">
                                                                                <tr>
                                                                                    <div align="center">
                                                                                        <asp:Label runat="server" ID="header"></asp:Label><br />
                                                                                        <strong>Trial Balance Report(Group Wise)</strong>
                                                                                    </div>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td>Report Date From: &nbsp;<strong><asp:Label ID="fromDate"
                                                                                        runat="server"></asp:Label></strong>&nbsp; to <strong>
                                                                                            <asp:Label ID="toDate" runat="server"></asp:Label></strong>
                                                                                    </td>
                                                                                    <td>
                                                                                        <div align="right">
                                                                                            <span alt="Export to PDF" title="Export to PDF" style="cursor: pointer" class="noPrint"
                                                                                                onclick="DownloadPDF();"><i class="fa fa-file-pdf-o" aria-hidden="true"></i></span>
                                                                                        </div>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td colspan="2">
                                                                                        <%--  <div id="reportTable" runat="server">--%>

                                                                                        <div class="table-responsive" id="reportTable" runat="server">
                                                                                            <table class="table table-striped table-bordered" cellspacing="0" class="TBLReport">
                                                                                                <tr>
                                                                                                    <th rowspan="2">SN
                                                                                                    </th>
                                                                                                    <th rowspan="2">GL
                                                                                                    </th>
                                                                                                    <th colspan="2" align="center">Opening
                                                                                                    </th>
                                                                                                    <th colspan="2" align="center">Turnover
                                                                                                    </th>
                                                                                                    <th colspan="2" align="center">Closing
                                                                                                    </th>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <th align="right">DR
                                                                                                    </th>
                                                                                                    <th align="right">CR
                                                                                                    </th>
                                                                                                    <th align="right">DR
                                                                                                    </th>
                                                                                                    <th align="right">CR
                                                                                                    </th>
                                                                                                    <th align="right">DR
                                                                                                    </th>
                                                                                                    <th align="right">CR
                                                                                                    </th>
                                                                                                </tr>
                                                                                                <tbody id="trialSheet" runat="server">
                                                                                                </tbody>
                                                                                                <tr>
                                                                                                    <td align="right" colspan="2">
                                                                                                        <strong>TOTAL:</strong>
                                                                                                    </td>
                                                                                                    <td align="right">
                                                                                                        <asp:Label ID="drOpening" runat="server" Text="0" />
                                                                                                    </td>
                                                                                                    <td align="right">
                                                                                                        <asp:Label ID="crOpening" runat="server" Text="0" />
                                                                                                    </td>
                                                                                                    <td align="right">
                                                                                                        <asp:Label ID="drTurn" runat="server" Text="0" />
                                                                                                    </td>
                                                                                                    <td align="right">
                                                                                                        <asp:Label ID="crTurn" runat="server" Text="0" />
                                                                                                    </td>
                                                                                                    <td align="right">
                                                                                                        <asp:Label ID="drClosing" runat="server" Text="0" />
                                                                                                    </td>
                                                                                                    <td align="right">
                                                                                                        <asp:Label ID="crClosing" runat="server" Text="0" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </div>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </div>
                                                                        <p>
                                                                            &nbsp;
                                                                        </p>
                                                                        <p>
                                                                            &nbsp;
                                                                        </p>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
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