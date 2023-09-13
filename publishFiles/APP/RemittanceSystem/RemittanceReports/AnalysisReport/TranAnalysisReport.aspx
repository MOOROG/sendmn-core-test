<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TranAnalysisReport.aspx.cs" Inherits="Swift.web.SwiftSystem.Reports.AnalysisReport.TranAnalysisReport" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="DownloadOptions" content="noopen" />
    <title></title>
    <%
        if (GetStatic.ReadQueryString("mode", "") == "")
        {
    %>

    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/swift_calendar.js"></script>
    <script src="../../../js/swift_autocomplete.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <link rel="stylesheet" type="text/css" href="../../../css/popupmenu.css" />
    <script type="text/javascript" src="../../../js/popupmenu.js"></script>


    <% }%>

     </script>
    <script type="text/javascript">
        function CheckVal(obj) {
            document.getElementById("SelectedMyValue").innerHTML = obj.getAttribute('Value');
        }
        function OpenNewLink(str) {
            var currId = document.getElementById("SelectedMyValue").innerHTML;
            var url = "../../../RemittanceSystem/RemittanceReports/AnalysisReport/TranAnalysisReport.aspx?<%=GetUrl() %>" + "&" + str + "&CurrId=" + currId;
        location.href = url;
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
                            <h4 class="panel-title">Search By Date</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div  class="table table-responsive">
                                <div runat="server" id="head" style="width: 100%" class="reportHead"></div>
                                <hr style="width: 100%" runat="server" id="hr1" />

                                <div runat="server" id="filters" class="reportFilters"></div>
                                <div runat="server" id="paging" visible="false"></div>

                                <hr style="width: 100%" runat="server" id="hr3" />
                                <hr style="width: 100%" runat="server" id="hr2" />
                                <div runat="server" id="exportDiv" class="noprint" style="padding-top: 10px">
                                    <div style="float: left; margin-left: 10px; vertical-align: top">
                                        <img alt="Print" title="Print" style="cursor: pointer; width: 14px; height: 14px" onclick=" javascript:ReportPrint(); " src="../../../images/printer.png" border="0" />
                                    </div>
                                    <div style="float: left; margin-left: 10px; vertical-align: top" id="export" runat="server">
                                        <img alt="Export to Excel" title="Export to Excel" style="cursor: pointer" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');" src="../../../images/excel.gif" border="0" />
                                    </div>
                                </div>
                              
                                <div runat="server" id="rptDiv"></div>
                            </div>
                            <div id="SelectedMyValue" style="display: none;"></div>

                            <div runat="server" id="DivOthers" ></div>
                            <%--  <ul id='popmenu1' class='jqpopupmenu'>--%>
                            <%--
                <li><a href="#" onclick="OpenNewLink('Reportype=sz')">Sending Zone</a></li>
                <li><a href="#" onclick="OpenNewLink('Reportype=sd')">Sending District</a></li>
                <li><a href="#" onclick="OpenNewLink('Reportype=sl')">Sending Location</a></li>
                <li><a href="#" onclick="OpenNewLink('Reportype=sa')">Sending Agent Wise</a></li>
                <li><a href="#" onclick="OpenNewLink('Reportype=sb')">Sending Branch Wise</a></li>

                <li><a href="#" onclick="OpenNewLink('Reportype=rz')">Receiving Zone</a></li>
                <li><a href="#" onclick="OpenNewLink('Reportype=rd')">Receiving District</a></li>
                <li><a href="#" onclick="OpenNewLink('Reportype=rl')">Receiving Location</a></li>
                <li><a href="#" onclick="OpenNewLink('Reportype=ra')">Receiving Agent Wise</a></li>
                <li><a href="#" onclick="OpenNewLink('Reportype=rb')">Receiving Branch Wise</a></li>
                <li><a href="#" onclick="OpenNewLink('Reportype=detail')">Detail Report </a></li>

            </ul>--%>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

