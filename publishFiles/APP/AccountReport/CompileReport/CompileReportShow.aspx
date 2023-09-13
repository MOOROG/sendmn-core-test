<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CompileReportShow.aspx.cs" Inherits="Swift.web.AccountReport.CompileReport.CompileReportShow" %>

<!DOCTYPE html>
<%@ Import Namespace="Swift.web.Library" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="DownloadOptions" content="noopen" />
    <%
        if (GetStatic.ReadQueryString("mode", "") == "")
        {
    %>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <script src="../../js/jQuery/jquery.min.js"></script>
    <script src="../../js/popupmenu.js"></script>
    <script src="../../js/functions.js"></script>
    <% }%>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12" id="hide" runat="server">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('remittance_report')">RemittanceReports </a></li>
                            <li class="active"><a href="CompileReportShow.aspx">Compile Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <asp:HiddenField ID="hidden" runat="server" />
            <div class="row">
                <div class="form-group col-md-8 ">
                    <div align="center">
                        <div class="form-group" runat="server" id="exportDiv">
                            <hr style="width: 100%" runat="server" id="hr1" />
                            <hr style="width: 100%" runat="server" id="hr3" />
                            <hr style="width: 100%" runat="server" id="hr2" />
                            <div class="noprint">
                                <div style="float: left; margin-left: 10px; vertical-align: top">
                                    <img alt="Print" title="Print" style="cursor: pointer; width: 14px; height: 14px" onclick=" javascript:ReportPrintLocal(); " src="../../images/printer.png" border="0" />
                                </div>
                                <div style="float: left; margin-left: 10px; vertical-align: top" id="export" runat="server">
                                    <img alt="Export to Excel" title="Export to Excel" style="cursor: pointer" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');" src="../../images/excel.gif" border="0" />
                                </div>
                            </div>
                        </div>
                        <div class="table-responsive" id="tblRpt" runat="server">
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
<script>
    function ReportPrintLocal() {
        document.getElementsByClassName('noprint')[0].style.visibility = 'hidden';
        window.print();
        return false;
    }
</script>