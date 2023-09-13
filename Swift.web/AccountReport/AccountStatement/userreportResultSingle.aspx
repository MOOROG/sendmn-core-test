<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="userreportResultSingle.aspx.cs"
    Inherits="Swift.web.AccountReport.AccountStatement.userreportResultSingle" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />

    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />

    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>

    <!--page plugins-->
    <script type="text/javascript">
        function DownloadPDF() {
            $(".noPrint").css("display", "none");
            var copy = document.getElementById("main").innerHTML;
            var encodedText = encodeURIComponent(copy);
            $("#hidden").val(encodedText);
            document.getElementById("pdf").click();
        }
        function ShowImage(img) {
            var url = "../../img.ashx?functionId=vdoc&id=" + $(img).attr("src");
            OpenInNewWindow(url);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Account Report </a></li>
                            <li class="active"><a href="userreportResultSingle.aspx?company_id=1&vouchertype=<%=VoucherType() %>&type=trannumber&trn_date=<%=TransactionDate() %>&tran_num=<%=TransactionNumber() %>">Balance Sheet</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <asp:Button ID="pdf" runat="server" OnClick="pdf_Click" Style="display: none;" />
            <asp:HiddenField ID="hidden" runat="server" />
            <div id="main">
                <div class="row">
                    <div class="col-md-10">
                        <div class="table-responsive">
                            <table class="table" width="100%" cellspacing="0" class="TBLReport">
                                <tr>
                                    <td width="95%" nowrap="nowrap" align="center">
                                        <div align="center" id="letterHead" runat="server">
                                        </div>
                                        <strong>
                                            <asp:Label ID="voucherType" runat="server"></asp:Label>
                                            Voucher</strong>
                                    </td>
                                    <td width="5%" nowrap="nowrap" valign="bottom">
                                        <div align="right">
                                            <asp:Image ID="voucherImg" Height="70" onclick="ShowImage(this);" Width="70" Visible="false" runat="server" />
                                            <%-- <img alt="Export to PDF" title="Export to PDF" style="cursor: pointer" class="noPrint"
                            onclick="DownloadPDF();" src="../../images/pdf.png" border="0" />--%>
                                            <span onclick="DownloadPDF();" style="cursor: pointer" class="noPrint"><i class="fa fa-file-pdf-o" aria-hidden="true"></i></span>
                                        </div>
                                    </td>
                                </tr>

                                <tr>
                                    <td nowrap="nowrap">
                                        <strong>Voucher No:
                        <asp:Label ID="tranNumber" runat="server"> </asp:Label>
                                        </strong>
                                    </td>
                                    <td width="26%" nowrap="nowrap">
                                        <div align="right">
                                            <strong>Date:<asp:Label ID="tranDate" runat="server"></asp:Label></strong>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <%-- <div id="reportTable" runat="server">
            <table width="89%" class="TBLReport">--%>
                        <div class="table-responsive" id="reportTable" runat="server">
                            <table class="table table-striped table-bordered" width="100%" cellspacing="0" class="TBLReport">
                                <tr>
                                    <th nowrap="nowrap" width="4%">SN
                                    </th>
                                    <th nowrap="nowrap" width="16%">AC No
                                    </th>
                                    <th nowrap="nowrap" width="50%">Name
                                    </th>
                                    <th nowrap="nowrap" width="15%">Dr Amount
                                    </th>
                                    <th nowrap="nowrap" width="15%">Cr Amount
                                    </th>
                                </tr>
                            </table>
                        </div>

                        <div class="table-responsive">
                            <table class="table" width="80%" cellspacing="0" class="TBLReport" align="center">
                                <%--  <table width="90%">--%>
                                <tr>
                                    <td width="49%">
                                        <br />
                                        <br />
                                        <br />
                                        <br />
                                        &nbsp;&nbsp; --------------------------------
                    <br />
                                        &nbsp;&nbsp; Entered By :<strong>
                                            <asp:Label ID="userId" runat="server"></asp:Label>
                                        </strong>
                                    </td>
                                    <td width="51%">
                                        <div align="right">
                                            <br />
                                            <br />
                                            <br />
                                            <br />
                                            ----------------------------&nbsp;
                        <br />
                                            Approved By &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row noPrint" id="divReverse" runat="server" visible="false">
                <div class="col-lg-10">
                    <asp:TextBox ID="Narration" runat="server" class="col-md-6" placeholder="Enter Reversal Narration here.." TextMode="MultiLine"></asp:TextBox>
                </div>
                <div class="col-lg-10">
                    <br />
                    <label>Choose Reversal Date : </label>
                    <asp:TextBox ID="date" runat="server" placeholder="Choose Reversal Date" CssClass="default-date-picker"></asp:TextBox>
                    <asp:Button ID="btnReversal" runat="server" Text="  Reverse Voucher  " class="btn btn-danger" OnClick="btnReversal_Click" />
                </div>
            </div>
        </div>
    </form>
</body>
</html>