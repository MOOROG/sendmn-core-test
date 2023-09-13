<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AgentSummaryReportDetail.aspx.cs" Inherits="Swift.web.AccountReport.AgentSummary.AgentSummaryReportDetail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <base id="Base1" runat="server" target="_self" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Agent Summary</li>
                            <li>Agent Summary Report</li>
                            <li class="active">Agent Summary Report Detail</li>
                        </ol>
                    </div>
                </div>
            </div>
            <asp:Button ID="pdf" runat="server" OnClick="pdf_Click" Style="display: none;" />
            <asp:HiddenField ID="hidden" runat="server" />
            <div class="row">
                <div class="form-group col-md-8 ">
                    <div align="center">
                        <div align="right">
                            <span alt="Export to PDF" title="Export to PDF" style="cursor: pointer" class="noPrint"
                                onclick="DownloadPDF();"><i class="fa fa-file-pdf-o" aria-hidden="true"></i></span>
                        </div>
                        <div class="table-responsive" id="tblMain" runat="server">
                            <table class="table table-striped table-bordered" cellspacing="0">
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>