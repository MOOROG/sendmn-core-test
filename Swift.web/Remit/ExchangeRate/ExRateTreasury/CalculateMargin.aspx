<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CalculateMargin.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.ExRateTreasury.CalculateMargin" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <link href="../../../css/rateCss.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        function getRadioCheckedValue(radioName) {
            var oRadio = document.forms[0].elements[radioName];

            for (var i = 0; i < oRadio.length; i++) {
                if (oRadio[i].checked) {
                    return oRadio[i].value;
                }
            }

            return '';
        }

        function OnSwitchCalType() {
            var calType = getRadioCheckedValue("calType");
            if(calType == "custRate") {
                SetValueById("<%=customerRate.ClientID %>", GetValue("<%=hddCustomerRate.ClientID %>"), "");
            }
            else if(calType == "agentRate") {
                SetValueById("<%=customerRate.ClientID %>", GetValue("<%=hddAgentRate.ClientID %>"), "");
            }
        }

        function CalcSendHoMargin() {
            var toleranceOn = GetElement("toleranceOn").innerHTML;
            var cRate = GetElement("cRate").innerHTML == "" ? 0 : parseFloat(GetElement("cRate").innerHTML);
            var cMargin = GetElement("cMargin").innerHTML == "" ? 0 : parseFloat(GetElement("cMargin").innerHTML);
            var cHoMargin = GetValue("<%=cHoMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cHoMargin.ClientID %>"));
            var cAgentMargin = GetValue("<%=cAgentMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cAgentMargin.ClientID %>"));
            var cOffer = cRate + cMargin + cHoMargin;
            var cCustomerOffer = cRate + cMargin + cHoMargin + cAgentMargin;

            var pRate = GetElement("pRate").innerHTML == "" ? 0 : parseFloat(GetElement("pRate").innerHTML);
            var pMargin = GetElement("pMargin").innerHTML == "" ? 0 : parseFloat(GetElement("pMargin").innerHTML);
            var pHoMargin = GetValue("<%=pHoMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pHoMargin.ClientID %>"));
            var pAgentMargin = GetValue("<%=pAgentMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pAgentMargin.ClientID %>"));
            var pOffer = pRate - pMargin - pHoMargin;
            var pCustomerOffer = pRate - pMargin - pHoMargin - pAgentMargin;

            var customerRate = GetValue("<%=customerRate.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=customerRate.ClientID %>"));

            var calType = getRadioCheckedValue("calType");
            var agentCrossRateMargin = GetValue("<%=agentCrossRateMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=agentCrossRateMargin.ClientID %>"));

            if (calType == "custRate") {
                if (toleranceOn == "C") {
                    customerRate = customerRate + agentCrossRateMargin;
                    cOffer = pOffer / customerRate;
                    cOffer = roundNumber(cOffer, 6);
                    cHoMargin = cOffer - cRate - cMargin;
                    cHoMargin = roundNumber(cHoMargin, 10);
                    cCustomerOffer = cOffer;
                }
                else {
                    cCustomerOffer = pCustomerOffer / customerRate;
                    cCustomerOffer = roundNumber(cCustomerOffer, 6);
                    cOffer = cCustomerOffer - cAgentMargin;
                    cOffer = roundNumber(cOffer, 6);
                    cHoMargin = cOffer - cRate - cMargin;
                    cHoMargin = roundNumber(cHoMargin, 10);
                }
            }
            else if(calType == "agentRate") {
                cOffer = pOffer / customerRate;
                cOffer = roundNumber(cOffer, 6);
                cHoMargin = cOffer - cRate - cMargin;
                cHoMargin = roundNumber(cHoMargin, 10);
                cCustomerOffer = cOffer;
            }
            GetElement("cCustomerOffer").innerHTML = cCustomerOffer;
            GetElement("cAgentOffer").innerHTML = cOffer;
            GetElement("<%=cHoMargin.ClientID %>").value = cHoMargin;
        }

        function CalcReceiveHoMargin() {
            var toleranceOn = GetElement("toleranceOn").innerHTML;
            var cRate = GetElement("cRate").innerHTML == "" ? 0 : parseFloat(GetElement("cRate").innerHTML);
            var cMargin = GetElement("cMargin").innerHTML == "" ? 0 : parseFloat(GetElement("cMargin").innerHTML);
            var cHoMargin = GetValue("<%=cHoMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cHoMargin.ClientID %>"));
            var cAgentMargin = GetValue("<%=cAgentMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cAgentMargin.ClientID %>"));
            var cOffer = cRate + cMargin + cHoMargin;
            var cCustomerOffer = cRate + cMargin + cHoMargin + cAgentMargin;

            var pRate = GetElement("pRate").innerHTML == "" ? 0 : parseFloat(GetElement("pRate").innerHTML);
            var pMargin = GetElement("pMargin").innerHTML == "" ? 0 : parseFloat(GetElement("pMargin").innerHTML);
            var pHoMargin = GetValue("<%=pHoMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pHoMargin.ClientID %>"));
            var pAgentMargin = GetValue("<%=pAgentMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pAgentMargin.ClientID %>"));
            var pOffer = pRate - pMargin - pHoMargin;
            var pCustomerOffer = pRate - pMargin - pHoMargin - pAgentMargin;

            var customerRate = GetValue("<%=customerRate.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=customerRate.ClientID %>"));

            var calType = getRadioCheckedValue("calType");
            var agentCrossRateMargin = GetValue("<%=agentCrossRateMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=agentCrossRateMargin.ClientID %>"));

            if (calType == "custRate") {
                if (toleranceOn == "C") {
                    customerRate = customerRate + agentCrossRateMargin;
                    pOffer = cOffer * customerRate;
                    pOffer = roundNumber(pOffer, 6);
                    pHoMargin = (pRate - pMargin) - pOffer;
                    pHoMargin = roundNumber(pHoMargin, 10);
                    pCustomerOffer = pOffer;
                }
                else {
                    pCustomerOffer = cCustomerOffer * customerRate;
                    pCustomerOffer = roundNumber(pCustomerOffer, 6);
                    pOffer = pCustomerOffer + pAgentMargin;
                    pOffer = roundNumber(pOffer, 6);
                    pHoMargin = (pRate - pMargin) - pOffer;
                    pHoMargin = roundNumber(pHoMargin, 10);
                }
            }
            else if(calType == "agentRate") {
                pOffer = cOffer * customerRate;
                pOffer = roundNumber(pOffer, 6);
                pHoMargin = (pRate - pMargin) - pOffer;
                pHoMargin = roundNumber(pHoMargin, 10);
                pCustomerOffer = pOffer;
            }

            GetElement("pCustomerOffer").innerHTML = pCustomerOffer;
            GetElement("pAgentOffer").innerHTML = pOffer;
            GetElement("<%=pHoMargin.ClientID %>").value = pHoMargin;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <table>
                <tr>
                    <td>
                        <table>
                            <tr>
                                <th colspan="2">Sending Rate</th>
                            </tr>
                            <tr>
                                <td class="tdhorate">Cost</td>
                                <td class="tdhorate" id="cRate" runat="server"></td>
                            </tr>
                            <tr>
                                <td class="tdhorate">Margin(I)</td>
                                <td class="tdhorate" id="cMargin" runat="server"></td>
                            </tr>
                            <tr>
                                <td class="tdhorate">Margin</td>
                                <td class="tdhorate">
                                    <asp:TextBox ID="cHoMargin" runat="server" Style="text-align: right;"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdsendagentrate">Agent Offer</td>
                                <td class="tdsendagentrate" id="cAgentOffer" runat="server"></td>
                            </tr>
                            <tr>
                                <td class="tdsendagentrate">Agent Margin</td>
                                <td class="tdsendagentrate">
                                    <asp:TextBox ID="cAgentMargin" runat="server" Style="text-align: right;"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdsendagentrate">Customer Offer</td>
                                <td class="tdsendagentrate" id="cCustomerOffer" runat="server"></td>
                            </tr>
                        </table>
                    </td>
                    <td>
                        <table>
                            <tr>
                                <th colspan="2">Receiving Rate</th>
                            </tr>
                            <tr>
                                <td class="tdhorate">Cost</td>
                                <td class="tdhorate" id="pRate" runat="server"></td>
                            </tr>
                            <tr>
                                <td class="tdhorate">Margin(I)</td>
                                <td class="tdhorate" id="pMargin" runat="server"></td>
                            </tr>
                            <tr>
                                <td class="tdhorate">Margin</td>
                                <td class="tdhorate">
                                    <asp:TextBox ID="pHoMargin" runat="server" Style="text-align: right;"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdsendagentrate">Agent Offer</td>
                                <td class="tdsendagentrate" id="pAgentOffer" runat="server"></td>
                            </tr>
                            <tr>
                                <td class="tdsendagentrate">Agent Margin</td>
                                <td class="tdsendagentrate">
                                    <asp:TextBox ID="pAgentMargin" runat="server" Style="text-align: right;"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdsendagentrate">Customer Offer</td>
                                <td class="tdsendagentrate" id="pCustomerOffer" runat="server"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>Tolerance On :
                    <span id="toleranceOn" runat="server"></span>
                    </td>
                    <td>Cross Rate Margin :
                    <asp:TextBox ID="agentCrossRateMargin" runat="server" Width="100px" Style="text-align: right;"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <input type="radio" id="calAgentRate" value="agentRate" name="calType" onclick="OnSwitchCalType()" />Agent Rate
                    <input type="radio" id="calCustomerRate" value="custRate" name="calType" checked="checked" onclick="OnSwitchCalType()" />Customer Rate
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:TextBox ID="customerRate" runat="server" Style="text-align: right;"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        <input type="button" value="Calculate Send HO Margin" onclick="CalcSendHoMargin()" /><br />
                        <asp:HiddenField ID="hddCustomerRate" runat="server" />
                        <asp:HiddenField ID="hddAgentRate" runat="server" />
                    </td>
                    <td valign="top">
                        <input type="button" value="Calculate Receive HO Margin" onclick="CalcReceiveHoMargin()" />
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>