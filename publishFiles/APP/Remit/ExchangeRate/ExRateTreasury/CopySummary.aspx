<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CopySummary.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.ExRateTreasury.CopySummary" %>

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
            function LoadWindow() {
                var isFw = GetValue("<%=hdnIsFw.ClientID %>");
                if (isFw == "1") {
                    GetElement("lnkManageWindow").innerHTML = "";
                }
                else {
                    GetElement("lnkManageWindow").innerHTML = "Show In Full Window";
                }
            }
            function ManageWindow() {
                var isFw = GetValue("<%=hdnIsFw.ClientID %>");
                if (isFw == "1") {
                    window.close();
                }
                else {
                    var param = "dialogHeight:1400px;dialogWidth:1400px;dialogLeft:0;dialogTop:0;center:yes";
                    PopUpWindow("List.aspx?isFw=1", param);
                }
            }

            function ShowAgentFxCol() {
                var cookiename = "showhideagentfxcol";
                $('#rateTable th:nth-col(16),#rateTable th:nth-col(17), #rateTable td:nth-col(16), #rateTable td:nth-col(17)').show();
                GetElement("agentfxh").style.display = "block";
                GetElement("agentfxs").style.display = "none";
                setCookie(cookiename, "show", 365);
            }

            function HideAgentFxCol() {
                var cookiename = "showhideagentfxcol";
                $('#rateTable th:nth-col(16),#rateTable th:nth-col(17), #rateTable td:nth-col(16), #rateTable td:nth-col(17)').hide();
                GetElement("agentfxh").style.display = "none";
                GetElement("agentfxs").style.display = "block";
                setCookie(cookiename, "hide", 365);
            }

            function ShowToleranceCol() {
                var cookiename = "showhidetolerancecol";
                $('#rateTable th:nth-col(18),#rateTable th:nth-col(19),#rateTable th:nth-col(20), #rateTable td:nth-col(18), #rateTable td:nth-col(19), #rateTable td:nth-col(20)').show();
                GetElement("toleranceh").style.display = "block";
                GetElement("tolerances").style.display = "none";
                setCookie(cookiename, "show", 365);
            }

            function HideToleranceCol() {
                var cookiename = "showhidetolerancecol";
                $('#rateTable th:nth-col(18),#rateTable th:nth-col(19),#rateTable th:nth-col(20), #rateTable td:nth-col(18), #rateTable td:nth-col(19), #rateTable td:nth-col(20)').hide();
                GetElement("toleranceh").style.display = "none";
                GetElement("tolerances").style.display = "block";
                setCookie(cookiename, "hide", 365);
            }

            function ShowSendingAgentCol() {
                var cookiename = "showhidesendingagentcol";
                $('#rateTable th:nth-col(21),#rateTable th:nth-col(22),#rateTable th:nth-col(23),#rateTable th:nth-col(24),#rateTable th:nth-col(25),#rateTable th:nth-col(26), #rateTable td:nth-col(21), #rateTable td:nth-col(22), #rateTable td:nth-col(23), #rateTable td:nth-col(24), #rateTable td:nth-col(25), #rateTable td:nth-col(26)').show();
                GetElement("sendingagenth").style.display = "block";
                GetElement("sendingagents").style.display = "none";
                setCookie(cookiename, "show", 365);
            }

            function HideSendingAgentCol() {
                var cookiename = "showhidesendingagentcol";
                $('#rateTable th:nth-col(21),#rateTable th:nth-col(22),#rateTable th:nth-col(23),#rateTable th:nth-col(24),#rateTable th:nth-col(25),#rateTable th:nth-col(26), #rateTable td:nth-col(21), #rateTable td:nth-col(22), #rateTable td:nth-col(23), #rateTable td:nth-col(24), #rateTable td:nth-col(25), #rateTable td:nth-col(26)').hide();
                GetElement("sendingagenth").style.display = "none";
                GetElement("sendingagents").style.display = "block";
                setCookie(cookiename, "hide", 365);
            }

            function ShowCustomerTolCol() {
                var cookiename = "showhidecustomertolcol";
                $('#rateTable th:nth-col(27),#rateTable th:nth-col(28), #rateTable td:nth-col(27), #rateTable td:nth-col(28)').show();
                GetElement("customertolh").style.display = "block";
                GetElement("customertols").style.display = "none";
                setCookie(cookiename, "show", 365);
            }

            function HideCustomerTolCol() {
                var cookiename = "showhidecustomertolcol";
                $('#rateTable th:nth-col(27),#rateTable th:nth-col(28), #rateTable td:nth-col(27), #rateTable td:nth-col(28)').hide();
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

    <style type="text/css">
        .exTable tr td .inputBox {
            width: 45px;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <asp:Button ID="btnHidden" runat="server" OnClick="btnHidden_Click" Style="display: none" />
        <table width="100%">
            <tr>
                <td align="left" valign="top" class="bredCrom">Exchange Rate Treasury » Copy Summary</td>
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
                    <span style="color: green; font-size: 12px; font-weight: bold;"><b>Record(s) has been applied successfully</b></span>
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