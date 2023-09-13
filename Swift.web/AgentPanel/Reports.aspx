<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="Swift.web.AgentPanelReports.Reports" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="DownloadOptions" content="noopen" />
    <%
        if (GetStatic.ReadQueryString("mode", "") == "")
        {
    %>
    <link href="../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../ui/css/style.css" rel="stylesheet" />
    <link href="../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <%-- <link href="../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <link href="../css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../js/functions.js" type="text/javascript"> </script>
    <link rel="stylesheet" type="text/css" href="../css/popupmenu.css" />
    <script type="text/javascript" src="../js/popupmenu.js"></script>
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
</head>
<body>

    <form id="form1" runat="server">
        <div class="container-fluid">
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
                                <div runat="server" id="paging" style="width: 100%" class="reportFilters" visible="false">
                                </div>
                            </div>
                            <div class="form-group">
                                <div runat="server" id="exportDiv" class="noprint">
                                    <div style="float: left; margin-left: 10px; vertical-align: top">
                                        <img alt="Print" title="Print" style="cursor: pointer; width: 14px; height: 14px" onclick=" javascript:ReportPrint(); " src="../../images/printer.png" border="0" />
                                    </div>
                                    <div style="float: left; margin-left: 10px; vertical-align: top" id="export" runat="server">
                                        <img alt="Export to Excel" title="Export to Excel" style="cursor: pointer" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');" src="../../images/excel.gif" border="0" />
                                    </div>
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
        </div>
    </form>
</body>
</html>