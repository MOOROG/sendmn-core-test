<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="Swift.web.SwiftSystem.Reports.Reports" EnableViewState="False" EnableTheming="False" MaintainScrollPositionOnPostback="False" Title="Reports" ViewStateMode="Disabled" ViewStateEncryptionMode="Never" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="DownloadOptions" content="noopen" />
    <%
        if (GetStatic.ReadQueryString("mode", "") == "")
        {
    %>
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <script src="../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <%-- <link href="../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <link href="../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <link rel="stylesheet" type="text/css" href="../../css/popupmenu.css" />
    <script type="text/javascript" src="../../js/popupmenu.js"></script>
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
        <div class="container">
            <div class="row">
                <div class="col-md-offset-2 col-md-8">
                    <div style="width: 100% ">

                        <div runat="server" id="head" style="width: 100%" class="reportHead"></div>
                        <hr style="width: 100%" runat="server" id="hr1" />
                        <div runat="server" id="filters" class="reportFilters"></div>
                        <div runat="server" id="paging" style="width: 100%" class="reportFilters" visible="false">
                        </div>
                        <hr style="width: 100%" runat="server" id="hr3" />
                        <hr style="width: 100%" runat="server" id="hr2" />
                        <div runat="server" id="exportDiv" class="noprint" style="padding-top: 10px">
                            <div style="float: left; margin-left: 10px; vertical-align: top">
                                <img alt="Print" title="Print" style="cursor: pointer; width: 14px; height: 14px" onclick=" javascript:ReportPrint(); " src="../../images/printer.png" border="0" />
                            </div>
                            <div style="float: left; margin-left: 10px; vertical-align: top" id="export" runat="server">
                                <img alt="Export to Excel" title="Export to Excel" style="cursor: pointer" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');" src="../../images/excel.gif" border="0" />
                            </div>
                        </div>
                        <div style="clear: both"></div>
                        <div runat="server" id="rptDiv" style="margin-top: 10px;"></div>
                    </div>
                    <div runat="server" id="DivOthers" style="width: 100%"></div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
