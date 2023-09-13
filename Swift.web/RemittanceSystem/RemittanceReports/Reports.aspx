<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="Swift.web.RemittanceSystem.RemittanceReports.Reports" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="DownloadOptions" content="noopen" />

    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/functions.js"></script>
    <%
        if (GetStatic.ReadQueryString("mode", "") == "")
        {
    %>

    <% }%>
    <script type="text/javascript">
        function ViewCancelTxnByControlNo(controlNo) {
            var url = "<%=Url %>";
            url += "/Remit/Transaction/Reports/TranCancle/View.aspx?controlNo=" + controlNo;
            OpenInNewWindow(url);
        }
        function ViewTranDetail(tranId) {
            var url = "<%=Url %>";
            url += "/Remit/Transaction/Reports/SearchTransaction.aspx?searchBy=tranId&tranId=" + tranId;
            OpenInNewWindow(url);
        }
        function ViewAMLDDLReport(url) {
            OpenInNewWindow(url);
        }
        function ViewTranDetailByControlNo(controlNo) {
            var url = "<%=Url %>";
            url += "/Remit/Transaction/Reports/SearchTransaction.aspx?searchBy=controlNo&controlNo=" + controlNo;
            OpenInNewWindow(url);
        }
        function GotoPage(pageNumber) {
            window.location.href = "<%=GetURL() %>&pageNumber=" + pageNumber;
            }
    </script>
    <style>
        .link{
            color:red;
        }
    </style>

</head>
<body>

    <form id="form1" runat="server">
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h2 class="panel-title">
                                <div runat="server" id="head"></div>
                            </h2>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <div runat="server" id="filters" class="reportFilters"></div>
                                <div runat="server" id="paging" class="reportFilters" visible="false">
                                </div>

                            </div>
                            <div class="form-group">
                                <hr id="hr2" runat="server" />
                                <hr id="h3" runat="server" />
                                <div runat="server" id="exportDiv" class="noprint">
                                    <img alt="Print" title="Print" style="cursor: pointer;" onclick=" javascript:ReportPrint(); " src="../../images/printer.png" border="0"/ >&nbsp;&nbsp;&nbsp;
                                    <img alt="Export to Excel" title="Export to Excel" style="cursor: pointer" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');" src="../../images/excel.gif" border="0" />
                                </div>
                            </div>
                            <div class="form-group" style="overflow: auto;">
                                <div runat="server" id="rptDiv"></div>
                            </div>
                            <div class="form-group" style="overflow: auto;">
                                <div runat="server" id="DivOthers"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
    </form>
</body>
</html>
