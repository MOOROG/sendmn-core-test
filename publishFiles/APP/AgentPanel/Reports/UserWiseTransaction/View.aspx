<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="View.aspx.cs" Inherits="Swift.web.AgentPanel.Reports.UserWise.View" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <%
        if (GetStatic.ReadQueryString("mode", "") == "")
        {
    %>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../js/functions.js"></script>
    <script src="../../../js/jQuery/jquery-1.4.1.js"></script>
    <% }%>
</head>
<body>

    <form id="form1" runat="server">
        <div class="container-fluid">
            <div class="row">
                <div class="col-sm-12">
                    <%-- <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('reports')">Reports</a></li>
                            <li class="active"><a href="View.aspx">User Wise Transaction Report</a></li>
                        </ol>--%>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <div runat="server" id="head" style="width: 100%" class="reportHead"></div>
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div style="width: 100%">
                                <hr style="width: 100%" runat="server" id="hr1" />
                                <div runat="server" id="filters" class="reportFilters"></div>
                                <div runat="server" id="paging" style="width: 100%" class="reportFilters" visible="false">
                                </div>
                                <hr style="width: 100%" runat="server" id="hr3" />
                                <hr style="width: 100%" runat="server" id="hr2" />
                                <div runat="server" id="exportDiv" class="noprint" style="padding-top: 10px">
                                    <div style="float: left; margin-left: 10px; vertical-align: top">
                                        <img alt="Print" title="Print" style="cursor: pointer; width: 14px; height: 14px" onclick=" javascript:PrintWindow(); " src="../../../images/printer.png" border="0" />
                                    </div>
                                    <div style="float: left; margin-left: 10px; vertical-align: top" id="export" runat="server">
                                        <img alt="Export to Excel" title="Export to Excel" style="cursor: pointer" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');" src="../../../images/excel.gif" border="0" />
                                    </div>
                                </div>
                                <div style="clear: both"></div>
                                <div runat="server" id="rptDiv" style="width: 100%"></div>
                            </div>
                            <div runat="server" id="DivOthers" style="width: 100%"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>