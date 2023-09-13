<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ShowReport.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.IntlReports.PayTrnRpt.ShowReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../../js/functions.js" type="text/javascript"></script>
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
                         <hr style="width: 100%" runat="server" id="hr1" />
                        <div class="form-group">
                            <div runat="server" id="filters" class="reportFilters"></div>
                            <div runat="server" id="paging" style="width: 100%" class="reportFilters" visible="false">
                            </div>
                        </div>
                        <div class="form-group">
                            <hr style="width: 100%" runat="server" id="hr3" />
                            <hr style="width: 100%" runat="server" id="hr2" />
                            <div runat="server" id="exportDiv" class="noprint" style="padding-top: 10px">
                                <div style="float: left; margin-left: 10px; vertical-align: top">
                                    <img alt="Print" title="Print" style="cursor: pointer; width: 14px; height: 14px" onclick=" javascript:ReportPrint(); " src="../../../../../images/printer.png" border="0" />
                                </div>
                                <div style="float: left; margin-left: 10px; vertical-align: top" id="export" runat="server">
                                    <img alt="Export to Excel" title="Export to Excel" style="cursor: pointer" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');" src="../../../../../images/excel.gif" border="0" />
                                </div>
                            </div>
                        </div>
                        <div style="clear: both"></div>
                        <div class="form-group">
                            <div runat="server" id="rptDiv" style="width: 100%"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
