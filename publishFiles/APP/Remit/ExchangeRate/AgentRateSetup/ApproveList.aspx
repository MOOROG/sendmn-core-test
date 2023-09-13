<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ApproveList.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.AgentRateSetup.ApproveList" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/rateCss.css" rel="stylesheet" type="text/css" />
    <script language="javascript" type="text/javascript">

            function CheckAll(obj) {

                var cBoxes = document.getElementsByName("chkId");

                for (var i = 0; i < cBoxes.length; i++) {
                    if (cBoxes[i].checked == true) {
                        cBoxes[i].checked = false;
                    }
                    else {
                        cBoxes[i].checked = true;
                    }

                }
            }
            function UncheckAll(obj) {
                var cBoxes = document.getElementsByName("chkId");

                for (var i = 0; i < cBoxes.length; i++) {
                    cBoxes[i].checked = false;
                }
            }
            function submit_form() {
                var btn = document.getElementById("<%=btnHidden.ClientID %>");
                if (btn != null)
                    btn.click();
            }
            function clearForm() {
                var btn = document.getElementById("<%=btnHidden.ClientID %>");
                document.getElementById("<%=currency.ClientID %>").value = "";
                document.getElementById("<%=country.ClientID %>").value = "";
                document.getElementById("<%=agent.ClientID %>").value = "";
                if (btn != null)
                    btn.click();
            }

            function nav(page) {
                var hdd = document.getElementById("hdd_curr_page");
                if (hdd != null)
                    hdd.value = page;

                submit_form();
            }

            function newTableToggle(idTD, idImg) {
                var td = document.getElementById(idTD);
                var img = document.getElementById(idImg);
                if (td != null && img != null) {
                    var isHidden = td.style.display == "none" ? true : false;
                    img.src = isHidden ? "/images/icon_hide.gif" : "/images/icon_show.gif";
                    img.alt = isHidden ? "Hide" : "Show";
                    td.style.display = isHidden ? "" : "none";
                }
            }
    </script>
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>

        <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td align="left" valign="top" class="bredCrom">Agent Rate Setup » Approve </td>
            </tr>
            <tr>
                <td height="10" class="shadowBG"></td>
            </tr>
            <tr>
                <td height="10">
                    <div class="tabs">
                        <ul>
                            <li><a href="List.aspx">Agent Rate</a></li>
                            <li><a href="Manage.aspx">Add New</a></li>
                            <li><a href="#" class="selected">Approve</a></li>
                        </ul>
                    </div>
                </td>
            </tr>
            <tr>
                <td valign="top">
                    <span class="headingRate">Base Currency = [USD]</span>

                    <asp:Button ID="btnHidden" runat="server" OnClick="btnHidden_Click" Style="display: none" />
                    <table width="700" cellspacing="2" cellpadding="2" border="0">
                        <tr>
                            <td class="GridTextNormal" align="center"><b>Filtered results</b>&nbsp;&nbsp;&nbsp;
                    <a href="javascript:newTableToggle('td_Search', 'img_Search');">
                        <img src="/images/icon_show.gif" border="0" alt="Show" id="img_Search"></a>
                            </td>
                        </tr>
                        <tr>
                            <td id="td_Search" style="display: none" align="center">
                                <table cellpadding="2" cellspacing="2" border="0" width="400">
                                    <tr>
                                        <td width="200" align="right" class="text_form" nowrap="nowrap">Currency : </td>
                                        <td width="200">
                                            <asp:TextBox ID="currency" runat="server"></asp:TextBox></td>
                                        <td width="200" align="right" class="text_form" nowrap="nowrap">Country : </td>
                                        <td width="200">
                                            <asp:TextBox ID="country" runat="server"></asp:TextBox></td>
                                    </tr>
                                    <tr>
                                        <td width="200" align="right" class="text_form" nowrap="nowrap">Agent : </td>
                                        <td width="200">
                                            <asp:TextBox ID="agent" runat="server"></asp:TextBox></td>
                                        <td>&nbsp;</td>
                                        <td>&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td width="200" align="right" class="text_form">&nbsp;</td>
                                        <td width="200">
                                            <input type="button" value="Filter" class="button" onclick="submit_form();">
                                            <input type="button" value="Clear Filter" class="button" onclick="clearForm();">
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <div id="paginDiv" runat="server"></div>
                    <div id="rpt_grid" runat="server">
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Button runat="server" ID="btnApprove" Text="Approve" CssClass="button"
                        OnClick="btnApprove_Click" />
                    &nbsp;&nbsp;
                <asp:Button runat="server" ID="btnReject" Text="Reject" CssClass="button"
                    OnClick="btnReject_Click" />
                </td>
            </tr>
        </table>
    </form>
</body>
</html>