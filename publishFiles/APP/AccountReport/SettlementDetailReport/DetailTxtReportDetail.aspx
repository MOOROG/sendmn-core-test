<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DetailTxtReportDetail.aspx.cs" Inherits="Swift.web.AccountReport.SettlementDetailReport.DetailTxtReportDetail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Account Report</li>
                            <li>Settlement Report</li>
                            <li class="active">Settlement Report Detail</li>
                        </ol>
                    </div>
                </div>
            </div>
            <asp:Button ID="pdf" runat="server" OnClick="pdf_Click" Style="display: none;" />
            <asp:HiddenField ID="hidden" runat="server" />
            <div class="row">
                <div class="col-md-12" align="center">
                    Letter Head
                </div>
            </div>
            <div class="row">
                <div class="form-group col-md-8">
                    <div align="center">
                        <div align="right">
                            <span alt="Export to PDF" title="Export to PDF" style="cursor: pointer" class="noPrint"
                                onclick="DownloadPDF();"><i class="fa fa-file-pdf-o" aria-hidden="true"></i></span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-striped table-bordered" cellspacing="0">
                                <thead>
                                    <tr>
                                        <td rowspan="2" nowrap="nowrap" align='center'><strong>SN</strong></td>
                                        <td rowspan="2" nowrap="nowrap" align='center'><strong>Date</strong></td>
                                        <td rowspan="2" nowrap="nowrap" align='center'><strong>Branch Name</strong></td>
                                        <td colspan="2" nowrap="nowrap" align='center'><strong>Int'l Paid </strong></td>
                                        <td colspan="2" nowrap="nowrap" align='center'><strong>D. Send </strong></td>
                                        <td colspan="2" nowrap="nowrap" align='center'><strong>D. Paid </strong></td>
                                        <td colspan="2" nowrap="nowrap" align='center'><strong>D. Cancel </strong></td>
                                        <td colspan="2" nowrap="nowrap" align='center'><strong>EP</strong></td>
                                        <td colspan="2" nowrap="nowrap" align='center'><strong>PO</strong></td>
                                        <td rowspan="2" nowrap="nowrap" align='center'><strong>Total Amount </strong></td>
                                    </tr>
                                    <tr>
                                        <td nowrap="nowrap" align="center"><strong>No. of Txn </strong></td>
                                        <td nowrap="nowrap" align="center"><strong>Amount</strong></td>
                                        <td nowrap="nowrap" align="center"><strong>No. of Txn </strong></td>
                                        <td nowrap="nowrap" align="center"><strong>Amount</strong></td>
                                        <td nowrap="nowrap" align="center"><strong>No. of Txn </strong></td>
                                        <td nowrap="nowrap" align="center"><strong>Amount</strong></td>
                                        <td nowrap="nowrap" align="center"><strong>No. of Txn </strong></td>
                                        <td nowrap="nowrap" align="center"><strong>Amount</strong></td>
                                        <td nowrap="nowrap" align="center"><strong>No. of Txn </strong></td>
                                        <td nowrap="nowrap" align="center"><strong>Amount</strong></td>
                                        <td nowrap="nowrap" align="center"><strong>No. of Txn </strong></td>
                                        <td nowrap="nowrap" align="center"><strong>Amount</strong></td>
                                    </tr>
                                </thead>
                                <tbody id="tblMain" runat="server">
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>