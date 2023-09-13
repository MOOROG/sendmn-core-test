<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="soa.aspx.cs" Inherits="Swift.web.AgentPanel.Reports.SOADomestic.soa" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta name="DownloadOptions" content="noopen" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/jQuery/jquery-1.4.1.js"></script>
    <%
        if (GetStatic.ReadQueryString("mode", "") == "")
        {
    %>
    <% }%>

    <script type="text/javascript">

        $(document).ready(function () {
        });
        function PrintReport() {
            $(".TBL").show();
            //$(".print_hide").hide();
            window.print();
        }

        function DownloadExcel(url) {
            OpenInNewWindow(url);
        }
    </script>
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="container" id="DivRptHead" runat="server">
            <div class="col-md-offset-2 col-md-8">
                <div id="head" style="width: 80%" class="reportHead">Statement Of Account</div>
                <hr style="width: 100%" runat="server" id="hr1" />
                <div id="filters" class="reportFilters">
                    Filters Applied :<br />
                    Agent=<asp:Label runat="server" ID="lblAgentName"></asp:Label>|
        From Date=<asp:Label runat="server" ID="lblFrmDate"></asp:Label>
                    &nbsp;To Date=<asp:Label runat="server" ID="lbltoDate"></asp:Label>&nbsp;|
        Generated On=
                    <asp:Label runat="server" ID="lblGeneratedDate"></asp:Label>
                </div>
                <hr style="width: 100%" runat="server" id="hr3" />
                <hr style="width: 100%" runat="server" id="hr2" />
                <div id="exportDiv" runat="server" class="noprint">
                    <div style="float: left; vertical-align: top">
                        <img alt="Print" border="0" onclick="PrintReport(); " src="../../../Images/printer.png"
                            style="cursor: pointer; width: 14px; height: 14px" title="Print" />
                    </div>
                    <div id="export" runat="server" style="float: left; margin-left: 15px; vertical-align: top">
                        <img alt="Export to Excel" border="0" onclick=" javascript:downloadInNewWindow('<% =Request.Url.AbsoluteUri + "&mode=download"%>');"
                            src="../../../Images/excel.gif" style="cursor: pointer" title="Export to Excel" />
                    </div>
                </div>
            </div>
            <div style="clear: both"></div>
            <div class="col-md-offset-2 col-md-8" style="margin-top: 10px;">
                <div id="rptDiv" runat="server"></div>
            </div>

            <div class="col-md-offset-2 col-md-8">
                <table class="TBL table table-condensed table-bordered table-striped">
                    <tr>
                        <th>
                            <div align="left">Opening Balance:</div>
                        </th>
                        <td>
                            <asp:Label runat="server" ID="lblOpSing"></asp:Label></td>
                        <td>
                            <div align="right">
                                <asp:Label runat="server" ID="lblOpAmt"></asp:Label>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th width="125">
                            <div align="left">DR Total:</div>
                        </th>
                        <td width="33">&nbsp;</td>
                        <td width="226">
                            <div align="right">
                                <asp:Label runat="server" ID="lblDrTotal"></asp:Label>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th>
                            <div align="left">CR Total:</div>
                        </th>
                        <td>&nbsp;</td>
                        <td>
                            <div align="right">
                                <asp:Label runat="server" ID="lblCrTotal"></asp:Label>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th>
                            <div align="left">Closing Balance:</div>
                        </th>
                        <td>
                            <asp:Label runat="server" ID="lblCloSign"></asp:Label>
                        </td>
                        <td>
                            <div align="right">
                                <asp:Label runat="server" ID="lblCloAmt"></asp:Label>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <div align="right">
                                <asp:Label runat="server" ID="lblAmtMsg" Style="font-weight: 700; color: Red;"></asp:Label>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </form>
</body>
</html>