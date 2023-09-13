<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ShowReport.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.PaidTrnReport.ShowReport" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
    <head id="Head1" runat="server">
        <%
            if (GetStatic.ReadQueryString("mode", "") == "")
            {
        %>

        <link href="../../../../ui/css/style.css" rel="stylesheet" />
        <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
        <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
        <link href="../../../../css/swift_component.css" rel="stylesheet" type="text/css" />
        <script src="../../../../js/functions.js" type="text/javascript"> </script>

        <link rel="stylesheet" type="text/css" href="../../../../css/popupmenu.css" />
        <script type="text/javascript" src="../../../../js/popupmenu.js"></script>


        <% }%>


    </head>
    <body>

        <form id="form1" runat="server">
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h2 class="panel-title"><div runat = "server" id = "head" style = "width: 100%" class="reportHead"> </div>
                                <hr style = "width: 100%" runat = "server" id = "hr1" />
                            </h2>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <div runat = "server" id = "filters" class="reportFilters"> </div>
                                <div runat = "server" id = "paging" style = "width: 100%" class="reportFilters" Visible="false"> 
                                </div>
                            </div>
                            <div class="form-group">
                                <hr style = "width: 100%" runat = "server" id = "hr3" />
                                <hr style = "width: 100%" runat = "server" id = "hr2" />
                            </div>
                            <div class="form-group">
                                <div class="form-group">
                                    <div runat="server" id="exportDiv" class="noprint">
                                        <img alt="Print" title="Print" style="cursor: pointer;" onclick=" javascript:ReportPrint(); " src="../../../../images/printer.png" border="0" />
                                        <img alt="Export to Excel" title="Export to Excel" style="cursor: pointer" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');" src="../../../../images/excel.gif" border="0" />
                                    </div>
                                </div>
                            </div>
                            <div style="clear: both"></div>
                            <div class="form-group" style="overflow: auto;">
                                <div id="rptDiv" runat="server"></div>
                            </div>
                            <div class="form-group">
                                <div runat = "server" id = "DivOthers" style = "width: 100%"> </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </body>
</html>