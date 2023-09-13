<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="drilDownUser.aspx.cs" Inherits="Swift.web.Responsive.Reports.SOADomestic.drilDownUser" %>
<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
<meta name="DownloadOptions" content="noopen" />
     <%
        if (GetStatic.ReadQueryString("mode", "") == "")
        {
    %>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <% }%>
</head>
<body>
    <form id="form1" runat="server">
    <div id="DivRptHead" style="width: 100%">

    <div id="head" style="width: 80%" class="reportHead">Statement Of Account 
        <asp:Label runat="server" ID="rptDetail" style="font-size: medium"></asp:Label>
    </div>

    <hr style = "width: 100%" runat = "server" id = "hr1" />

    <div id="filters" class="reportFilters"> 
        Agent Name=<asp:Label runat="server" ID="lblAgentName"></asp:Label><br />
        From Date=<asp:Label runat="server" ID="lblFrmDate"></asp:Label> &nbsp;To Date=<asp:Label runat="server" ID="lbltoDate"></asp:Label>&nbsp;|
        Generated On= <asp:Label runat="server" ID="lblGeneratedDate"></asp:Label> 
    </div>

    <hr style = "width: 100%" runat = "server" id = "hr3" />
    <hr style = "width: 100%" runat = "server" id = "hr2" />

    <div id="exportDiv" runat="server" class="noprint" style="padding-top: 10px">
        <div style="float: left; margin-left: 10px; vertical-align: top">
            <img alt="Print" border="0" onclick=" javascript:PrintWindow(); " src="../../../Images/printer.png"
                style="cursor: pointer; width: 14px; height: 14px" title="Print" />
        </div>
        <div id="export" runat="server" style="float: left; margin-left: 10px; vertical-align: top">
            <img alt="Export to Excel" border="0" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');"
                src="../../../Images/excel.gif" style="cursor: pointer" title="Export to Excel" />
        </div>
    </div>
    <div style = "clear: both"></div>
    </div>
    <div id="rptDiv" runat="server"></div>
    </form>
</body>
</html>