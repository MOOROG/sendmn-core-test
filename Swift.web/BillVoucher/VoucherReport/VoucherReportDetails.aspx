<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VoucherReportDetails.aspx.cs"
    Inherits="Swift.web.BillVoucher.VoucherReport.VoucherReportDetails" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->

    <link href="../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../ui/js/metisMenu.min.js"></script>
    <script src="../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="../../ui/js/custom.js"></script>
    <!--page plugins-->
    <script src="../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <%--<link href="../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <script type="text/javascript">
        function DownloadPDF() {
            $(".noPrint").css("display", "none");
            var copy = document.getElementById("main").innerHTML;
            var encodedText = encodeURIComponent(copy);
            $("#hidden").val(encodedText);
            document.getElementById("pdf").click();
        }
        function ViewTranDetailByControlNo(controlNo) {
            var url = "/Remit/Transaction/Reports/SearchTransaction.aspx?searchBy=controlNo&controlNo=" + controlNo;
            OpenInNewWindow(url);
        }
    </script>
    <style type="text/css">
        .link {
            color: red;
            font-weight: bold;
            cursor: pointer;
            font-size: 15px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="col-md-12">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Account Report </a></li>
                            <li class="active"><a href="VoucherReportDetails.aspx?vNum=<%=VoucherNumber() %>&typeDDL=<%=TypeDDL() %>&vText=<%=VoucherText() %>">Voucher Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <asp:Button ID="pdf" runat="server" OnClick="pdf_Click" Style="display: none;" />
            <asp:HiddenField ID="hidden" runat="server" />
            <div class="row">
                <div class="form-group col-md-12 ">
                    <div class=" table-responsive">
                        <table class="table" align="center">
                            <tr>
                                <td width="95%" align="center" valign="bottom">
                                    <asp:Label ID="letterHead" runat="server" Text="letter head.." />
                                </td>
                                <td width="5%" valign="bottom" class="noPrint">
                                    <%-- <img alt="Export to PDF" title="Export to PDF" style="cursor: pointer" class="noPrint" onclick="DownloadPDF();"
                        src="../../images/pdf.png" border="0" />--%>
                                    <i class="fa fa-file-pdf-o" aria-hidden="true"></i>
                                </td>
                            </tr>
                            <tr>
                                <td align="center">
                                    <strong>
                                        <asp:Label ID="voucherType" runat="server" Text="voucher type.." /></strong>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2" align="center" valign="top">
                                    <table width="100%" border="0" cellspacing="1" cellpadding="1">
                                        <tr>
                                            <td colspan="8">
                                                <table width="100%" align="center" border="0" cellpadding="3" cellspacing="0" class="">
                                                    <tr>
                                                        <td align="left">
                                                            <strong>Voucher No:</strong>
                                                        </td>
                                                        <td width="63%" align="left">
                                                            <strong>
                                                                <asp:Label ID="transNumber" runat="server" /></strong>
                                                        </td>
                                                        <td width="26%" align="right" style="border-right: 0px none;">
                                                            <strong>Date:
                                                <asp:Label ID="tansDate" runat="server" /></strong>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <tr>
                                        <td colspan="2">
                                            <div class="table-responsive">
                                                <table class="table table-striped table-bordered" width="100%" cellspacing="0" class="TBLReport">
                                                    <thead>
                                                        <tr>
                                                            <th width="4%" nowrap="nowrap">
                                                                <strong>SN</strong>
                                                            </th>
                                                            <th align="center" width="13%" nowrap="nowrap">
                                                                <strong>AC No</strong>
                                                            </th>
                                                            <th align="left" nowrap="nowrap">
                                                                <strong>Name</strong>
                                                            </th>
                                                            <th align="right" width="13%" nowrap="nowrap">
                                                                <strong>Dr Amount&nbsp;</strong>
                                                            </th>
                                                            <th align="right" width="15%" nowrap="nowrap">
                                                                <strong>Cr Amount&nbsp;</strong>
                                                            </th>
                                                        </tr>
                                                    </thead>
                                                    <tbody id="voucherData" runat="server">
                                                    </tbody>
                                                    <tr>
                                                        <td colspan="3" align="right">
                                                            <strong>Total</strong>
                                                        </td>
                                                        <td align="right">
                                                            <strong>
                                                                <asp:Label ID="totalDRAmount" runat="server" />
                                                            </strong>
                                                        </td>
                                                        <td align="right" style="border-right: 0px none;">
                                                            <strong>

                                                                <asp:Label ID="totalCRAmount" runat="server" />
                                                            </strong>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2" align="right">
                                                            <strong>Narration:</strong>
                                                        </td>
                                                        <td colspan="3" align="left">
                                                            <asp:Label ID="transactionParticular" runat="server" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </td>
                                    </tr>
                                    <br />
                                    <tr>
                                        <td colspan="2">
                                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td width="49%">
                                                        <br />
                                                        <br />
                                                        <br />
                                                        <br />
                                                        --------------------------------<br />
                                                        Entered By: <strong>
                                                            <asp:Label ID="userName" runat="server" /></strong>
                                                    </td>
                                                    <td width="51%" align="right">
                                                        <br />
                                                        <br />
                                                        <br />
                                                        <br />
                                                        ----------------------------&nbsp;
                                        <br />
                                                        Approved By &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
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