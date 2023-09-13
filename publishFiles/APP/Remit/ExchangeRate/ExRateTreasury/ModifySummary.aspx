<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ModifySummary.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.ExRateTreasury.ModifySummary" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/rateCss.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/columnselector.js" type="text/javascript"></script>

    <script language="javascript" type="text/javascript">
            var p = 1;
            function ShowAgentFxCol() {
                var cookiename = "showhideagentfxcol";
                $('.exTable th:nth-col(18),.exTable th:nth-col(19), .exTable td:nth-col(18), .exTable td:nth-col(19)').show();
                GetElement("agentfxh").style.display = "block";
                GetElement("agentfxs").style.display = "none";
                setCookie(cookiename, "show", 365);
            }

            function HideAgentFxCol() {
                var cookiename = "showhideagentfxcol";
                $('.exTable th:nth-col(18),.exTable th:nth-col(19), .exTable td:nth-col(18), .exTable td:nth-col(19)').hide();
                GetElement("agentfxh").style.display = "none";
                GetElement("agentfxs").style.display = "block";
                setCookie(cookiename, "hide", 365);
            }

            function ShowToleranceCol() {
                var cookiename = "showhidetolerancecol";
                $('.exTable th:nth-col(20),.exTable th:nth-col(21),.exTable th:nth-col(22), .exTable td:nth-col(20), .exTable td:nth-col(21), .exTable td:nth-col(22)').show();
                GetElement("toleranceh").style.display = "block";
                GetElement("tolerances").style.display = "none";
                setCookie(cookiename, "show", 365);
            }

            function HideToleranceCol() {
                var cookiename = "showhidetolerancecol";
                $('.exTable th:nth-col(20),.exTable th:nth-col(21),.exTable th:nth-col(22), .exTable td:nth-col(20), .exTable td:nth-col(21), .exTable td:nth-col(22)').hide();
                GetElement("toleranceh").style.display = "none";
                GetElement("tolerances").style.display = "block";
                setCookie(cookiename, "hide", 365);
            }

            function ShowSendingAgentCol() {
                var cookiename = "showhidesendingagentcol";
                $('.exTable th:nth-col(23),.exTable th:nth-col(24),.exTable th:nth-col(25),.exTable th:nth-col(26),.exTable th:nth-col(27),.exTable th:nth-col(28), .exTable td:nth-col(23), .exTable td:nth-col(24), .exTable td:nth-col(25), .exTable td:nth-col(26), .exTable td:nth-col(27), .exTable td:nth-col(28)').show();
                GetElement("sendingagenth").style.display = "block";
                GetElement("sendingagents").style.display = "none";
                setCookie(cookiename, "show", 365);
            }

            function HideSendingAgentCol() {
                var cookiename = "showhidesendingagentcol";
                $('.exTable th:nth-col(23),.exTable th:nth-col(24),.exTable th:nth-col(25),.exTable th:nth-col(26),.exTable th:nth-col(27),.exTable th:nth-col(28), .exTable td:nth-col(23), .exTable td:nth-col(24), .exTable td:nth-col(25), .exTable td:nth-col(26), .exTable td:nth-col(27), .exTable td:nth-col(28)').hide();
                GetElement("sendingagenth").style.display = "none";
                GetElement("sendingagents").style.display = "block";
                setCookie(cookiename, "hide", 365);
            }

            function ShowCustomerTolCol() {
                var cookiename = "showhidecustomertolcol";
                $('.exTable th:nth-col(29),.exTable th:nth-col(30), .exTable td:nth-col(29), .exTable td:nth-col(30)').show();
                GetElement("customertolh").style.display = "block";
                GetElement("customertols").style.display = "none";
                setCookie(cookiename, "show", 365);
            }

            function HideCustomerTolCol() {
                var cookiename = "showhidecustomertolcol";
                $('.exTable th:nth-col(29),.exTable th:nth-col(30), .exTable td:nth-col(29), .exTable td:nth-col(30)').hide();
                GetElement("customertolh").style.display = "none";
                GetElement("customertols").style.display = "block";
                setCookie(cookiename, "hide", 365);
            }

            function ShowHideDetail() {
                var cookieValue = getCookie("showhideagentfxcol");
                if (cookieValue == "show") {
                    ShowAgentFxCol();
                }
                else {
                    HideAgentFxCol();
                }
                cookieValue = getCookie("showhidetolerancecol");
                if (cookieValue == "show") {
                    ShowToleranceCol();
                }
                else {
                    HideToleranceCol();
                }
                cookieValue = getCookie("showhidesendingagentcol");
                if (cookieValue == "show") {
                    ShowSendingAgentCol();
                }
                else {
                    HideSendingAgentCol();
                }

                cookieValue = getCookie("showhidecustomertolcol");
                if (cookieValue == "show") {
                    ShowCustomerTolCol();
                }
                else {
                    HideCustomerTolCol();
                }
            }

            function ShowAllColumns() {
                ShowAgentFxCol();
                ShowToleranceCol();
                ShowSendingAgentCol();
                ShowCustomerTolCol();
            }

            function ShowOnlyForRSP() {
                HideAgentFxCol();
                HideToleranceCol();
                HideSendingAgentCol();
                HideCustomerTolCol();
            }
    </script>
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <asp:Button ID="btnHidden" runat="server" OnClick="btnHidden_Click" Style="display: none" />
        <table width="100%" style="margin-top: 150px;">
            <tr>
                <td align="left" valign="top" class="bredCrom">Exchange Rate Treasury » Modify Summary</td>
            </tr>
            <tr>
                <td height="10" class="shadowBG"></td>
            </tr>
            <tr>
                <td height="10">
                    <div id="divTab" runat="server"></div>
                </td>
            </tr>
            <tr>
                <td>
                    <span style="color: green; font-size: 12px; font-weight: bold;"><b>Record(s) has been updated successfully</b></span>
                </td>
            </tr>
            <tr>
                <td valign="top">
                    <input type="button" id="btnShowAllColumns" value="Show All Columns" onclick="ShowAllColumns();" />

                    <div id="paginDiv" runat="server"></div>
                    <div id="rpt_grid" runat="server">
                    </div>
                    <asp:HiddenField ID="hdnIsFw" runat="server" />
                </td>
            </tr>
        </table>
    </form>
</body>
</html>