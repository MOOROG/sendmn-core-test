<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SoaMonthlySearch.aspx.cs" Inherits="Swift.web.AgentPanel.Reports.SOADomestic.SoaMonthlySearch" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../Css/style.css" rel="Stylesheet" type="text/css" />
    <link href="../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script type="text/javascript" src="../../../js/functions.js"></script>
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <style type="text/css">
        .style1 {
            color: #CC0000;
        }

        .style2 {
            font-size: medium;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="bredCrom">Reports » Balance Confirmation Log</div>
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <div id="DivFrm" runat="server" style="margin-left: 25px;">
            <table class="formTable">
                <tr>
                    <th class="frmTitle" colspan="4">Balance Confirmation Log</th>
                </tr>
                <tr>
                    <td>
                        <div align="left" class="formLabel">
                            Agent:
                        </div>
                    </td>
                    <td nowrap="nowrap" colspan="3">
                        <asp:Label ID="agent" runat="server"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td nowrap="nowrap">
                        <div align="left" class="formLabel">
                            Year:
                        </div>
                    </td>
                    <td>
                        <asp:DropDownList Width="100px" runat="server" ID="year" CssClass="required">
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td nowrap="nowrap">
                        <div align="left" class="formLabel">
                            Months:
                        </div>
                    </td>
                    <td>
                        <asp:DropDownList Width="100px" runat="server" ID="months" CssClass="required">
                            <asp:ListItem Value="1">Baishak</asp:ListItem>
                            <asp:ListItem Value="2">Jestha</asp:ListItem>
                            <asp:ListItem Value="3">Ashar</asp:ListItem>
                            <asp:ListItem Value="4">Shrawan</asp:ListItem>
                            <asp:ListItem Value="5">Bhadra</asp:ListItem>
                            <asp:ListItem Value="6">Ashwin</asp:ListItem>
                            <asp:ListItem Value="7">Kartik</asp:ListItem>
                            <asp:ListItem Value="8">Mangsir</asp:ListItem>
                            <asp:ListItem Value="9">Poush</asp:ListItem>
                            <asp:ListItem Value="10">Magh</asp:ListItem>
                            <asp:ListItem Value="11">Falgun</asp:ListItem>
                            <asp:ListItem Value="12">Chaitra</asp:ListItem>
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td></td>
                    <td>
                        <asp:Button ID="BtnSave" runat="server" CssClass="button" Text="Search" OnClientClick="return ShowSOA();" />
                    </td>
                </tr>
            </table>
        </div>
        <div>
            <h3 style="margin-left: 25px;"><u>तपाई Account Balance Confirmation गर्ने पेजमा हुनुहुन्छ ।</u></h3>
            <ul>
                <li><strong>अब Month Select गरेर </strong><span class="style1"><strong>Search</strong></span><strong> Button थिच्नुहोस् ।
                </strong></li>
                <li><strong>तपाईको एक महिनाको कारोबारको सम्पूर्ण विवरण देख्न सक्नु हुनेछ । </strong></li>
                <li><strong>त्यस पछि तपाईको कारोबारको विवरण हेरि </strong><span class="style1"><strong>I Agree</strong></span><strong> Button थिच्नुहोस ।
                </strong></li>
                <li><strong>यदि कुनै दुविधा भएमा आवश्यक जानकारीको लागि लेखाशाखामा सम्पर्क गर्नु हुन अनुरोध छ । </li>
                </strong><br />
                <strong>(फोनं नं ४४३०६०० एक्टेन्सन नं - २४९, ११०, १०९, २०६, ११६)</strong>
            </ul>
        </div>
    </form>
</body>
</html>
<script language="javascript" type="text/javascript">
    function ShowSOA() {

        var yearFrom = GetValue("<% =year.ClientID%>");
        var monthFrom = GetValue("<% =months.ClientID%>");
        var dayFrom = '01';

        var toYear = GetValue("<% =year.ClientID%>");
        var toMonth = GetValue("<% =months.ClientID%>");
        var toDay = '00';

        var fromDate = monthFrom + "/" + dayFrom + "/" + yearFrom;
        var toDate = toMonth + "/" + toDay + "/" + toYear;
        var agent = GetElement("<% =agent.ClientID %>").innerHTML;
        var reportFor = "soa";

        if (agent == "") {
            alert("Agent is missing.");
            return false;
        }

        var url = "SoaMonthly.aspx?fromDate=" + fromDate +
            "&toDate=" + toDate +
                "&agent=" + agent +
                    "&reportFor=" + reportFor +
                        "&npYear=" + yearFrom +
                            "&npMonth=" + monthFrom;

        OpenInNewWindow(url);
        return false;

    }
</script>