<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.ExRateTreasury.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />

    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript">
        function GetRadioCheckedValue(factorId) {
            var radioButtonlist = document.getElementsByName(factorId);
            for (var x = 0; x < radioButtonlist.length; x++) {
                if (radioButtonlist[x].checked) {
                    return radioButtonlist[x].value;
                }
            }
        }

        function CalcRate() {
            var maskColBd = GetValue("<%=maskColBD.ClientID %>") == "" ? 6 : parseInt(GetValue("<%=maskColBD.ClientID %>"));
            var maskColAd = GetValue("<%=maskColAD.ClientID %>") == "" ? 6 : parseInt(GetValue("<%=maskColAD.ClientID %>"));
            var crossRateAd = GetValue("<%=rateMaskAd.ClientID %>") == "" ? 6 : parseInt(GetValue("<%=rateMaskAd.ClientID %>"));

            var cRate = GetValue("<%=cRate.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cRate.ClientID %>"));
            var cMargin = GetValue("<%=cMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cMargin.ClientID %>"));
            var cHoMargin = GetValue("<%=cHoMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cHoMargin.ClientID %>"));
            var cAgentMargin = GetValue("<%=cAgentMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cAgentMargin.ClientID %>"));

            var pRate = GetValue("<%=pRate.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pRate.ClientID %>"));
            var pMargin = GetValue("<%=pMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pMargin.ClientID %>"));
            var pHoMargin = GetValue("<%=pHoMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pHoMargin.ClientID %>"));
            var pAgentMargin = GetValue("<%=pAgentMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pAgentMargin.ClientID %>"));

            var agentTolMax = GetValue("<%=agentTolMax.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=agentTolMax.ClientID %>"));

            var cAgentOffer = cRate + cMargin + cHoMargin;
            cAgentOffer = roundNumber(cAgentOffer, maskColAd);

            var cCustomerOffer = cAgentOffer + cAgentMargin;
            cCustomerOffer = roundNumber(cCustomerOffer, maskColAd);

            var pAgentOffer = pRate - pMargin - pHoMargin;
            pAgentOffer = roundNumber(pAgentOffer, 4);

            var pCustomerOffer = pAgentOffer - pAgentMargin;
            pCustomerOffer = roundNumber(pCustomerOffer, 4);

            var maxCrossRate = pRate / cRate;
            maxCrossRate = roundNumber(maxCrossRate, crossRateAd);

            var agentCrossRate = (pRate - pMargin - pHoMargin) / (cRate + cMargin + cHoMargin);
            agentCrossRate = roundNumber(agentCrossRate, crossRateAd);

            var customerRate = (pRate - pMargin - pHoMargin - pAgentMargin) / (cRate + cMargin + cHoMargin + cAgentMargin);
            customerRate = roundNumber(customerRate, crossRateAd);

            var cost = pRate / (agentCrossRate + agentTolMax);
            cost = roundNumber(cost, maskColAd);

            var margin = cost - cRate;
            margin = roundNumber(margin, maskColAd);

            SetValueById("<%=cAgentOffer.ClientID %>", cAgentOffer, "");
            SetValueById("<%=cCustomerOffer.ClientID %>", cCustomerOffer, "");

            SetValueById("<%=pAgentOffer.ClientID %>", pAgentOffer, "");
            SetValueById("<%=pCustomerOffer.ClientID %>", pCustomerOffer, "");

            SetValueById("<%=maxCrossRate.ClientID %>", maxCrossRate, "");
            SetValueById("<%=crossRate.ClientID %>", agentCrossRate, "");
            SetValueById("<%=customerRate.ClientID %>", customerRate, "");
            SetValueById("<%=cost.ClientID %>", cost, "");
            SetValueById("<%=margin.ClientID %>", margin, "");
        }

        function CalcCOffers() {
            var offer = GetValue("<%=cOffer.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cOffer.ClientID %>"));
            var hoMargin = GetValue("<%=cHoMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cHoMargin.ClientID %>"));
            var agentMargin = GetValue("<%=cAgentMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cAgentMargin.ClientID %>"));
            var rateMaskAd = GetValue("<%=maskColAD.ClientID %>") == "" ? 6 : parseInt(GetValue("<%=maskColAD.ClientID %>"));
            var agentOffer = offer + hoMargin;
            var agentOfferR = agentOffer.toFixed(rateMaskAd);
            var customerOffer = agentOffer + agentMargin;
            var customerOfferR = customerOffer.toFixed(rateMaskAd);
            SetValueById("<%=cAgentOffer.ClientID %>", agentOfferR, "");
            SetValueById("<%=cCustomerOffer.ClientID %>", customerOfferR, "");
        }

        function CalcPOffers() {
            var offer = GetValue("<%=pOffer.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pOffer.ClientID %>"));
            var hoMargin = GetValue("<%=pHoMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pHoMargin.ClientID %>"));
            var agentMargin = GetValue("<%=pAgentMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pAgentMargin.ClientID %>"));
            var rateMaskAd = GetValue("<%=maskColAD.ClientID %>") == "" ? 6 : parseInt(GetValue("<%=maskColAD.ClientID %>"));
            var agentOffer = offer - hoMargin;
            var agentOfferR = agentOffer.toFixed(rateMaskAd);
            var customerOffer = agentOffer - agentMargin;
            var customerOfferR = customerOffer.toFixed(rateMaskAd);
            SetValueById("<%=pAgentOffer.ClientID %>", agentOfferR, "");
            SetValueById("<%=pCustomerOffer.ClientID %>", customerOfferR, "");
        }
    </script>

    <style type="text/css">
        input[readonly="readonly"] {
            background: #EFEFEF !important;
            color: #666666 !important;
        }

        .disabled {
            background: #EFEFEF !important;
            color: #666666 !important;
        }

        .table .table {
            background-color: #F5F5F5 !important;
        }

        legend {
            background-color: rgb(3, 169, 244);
            color: white;
            margin-bottom: 0 !important;
        }

        fieldset {
            padding: 10px !important;
            margin: 5px !important;
            border: 1px solid rgba(158, 158, 158, 0.21) !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">SETUP PROCESS</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Exchange Rate</a></li>
                            <li class="active"><a href="Manage.aspx">Exchange Rate Treasury-Add</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <div id="divTab" class="tabs" runat="server"></div>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Agent Rate Setup-Add New
                                    </h4>
                                </div>

                                <div class="panel-body">
                                    <div class="form-group">
                                        <table class="table table-responsive">
                                            <tr>
                                                <td valign="top">
                                                    <asp:UpdatePanel ID="upnl1" runat="server">
                                                        <ContentTemplate>
                                                            <table class="table table-responsive">
                                                                <tr>
                                                                    <td valign="top">
                                                                        <fieldset>
                                                                            <legend>Send</legend>
                                                                            <table class="table table-responsive">
                                                                                <tr>
                                                                                    <td class="frmLable">
                                                                                        <label>Country <span class="errormsg">*</span></label></td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="cCountry" runat="server" CssClass="form-control" Width="150px" AutoPostBack="true"
                                                                                            OnSelectedIndexChanged="cCountry_SelectedIndexChanged">
                                                                                        </asp:DropDownList>

                                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="cCountry"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="cur" ForeColor="Red"
                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable">
                                                                                        <%--  <label>Agent <span class="errormsg">*</span></label></td>--%>
                                                                                        <label>Agent </label>
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="cAgent" runat="server" CssClass="form-control" Width="150px" AutoPostBack="true"
                                                                                            OnSelectedIndexChanged="cAgent_SelectedIndexChanged">
                                                                                        </asp:DropDownList>

                                                                                        <%--                                                                         <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="cAgent"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="cur" ForeColor="Red"
                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>--%>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable">
                                                                                        <label>Currency <span class="errormsg">*</span></label></td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="cCurrency" runat="server" CssClass="form-control" Width="150px" AutoPostBack="true"
                                                                                            OnSelectedIndexChanged="cCurrency_SelectedIndexChanged">
                                                                                        </asp:DropDownList>

                                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="cCurrency"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="cur" ForeColor="Red"
                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable">
                                                                                        <label>Service Type</label></td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="tranType" runat="server" CssClass="form-control" Width="150px"></asp:DropDownList>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td colspan="2">
                                                                                        <fieldset>
                                                                                            <table class="table table-responsive">
                                                                                                <tr>
                                                                                                    <td colspan="2">
                                                                                                        <b>
                                                                                                            <label>Rate Factor</label></b>
                                                                                                        <asp:Label ID="lblCRateFactor" runat="server"></asp:Label>
                                                                                                        <asp:HiddenField ID="cRateFactor" runat="server" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <th nowrap="nowrap">
                                                                                                        <label>Cost Rate</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="cRate" runat="server" Width="150px" CssClass="input disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                                    </th>
                                                                                                    <th>
                                                                                                        <label>Margin</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="cMargin" runat="server" Width="150px" CssClass="input disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                                    </th>
                                                                                                    <th>
                                                                                                        <label>Offer</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="cOffer" runat="server" Width="150px" CssClass="input disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                                    </th>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <th></th>
                                                                                                    <th>
                                                                                                        <label>HO Margin</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="cHoMargin" runat="server" CssClass="form-control" Width="150px" onblur="CalcRate()"></asp:TextBox>
                                                                                                    </th>
                                                                                                    <th>
                                                                                                        <label>Agent Offer</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="cAgentOffer" runat="server" Width="150px" CssClass="disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                                    </th>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <th></th>
                                                                                                    <th>
                                                                                                        <label>Agent Margin</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="cAgentMargin" runat="server" CssClass="form-control" Width="150px" onblur="CalcRate()"></asp:TextBox>
                                                                                                    </th>
                                                                                                    <th>
                                                                                                        <label>Customer Offer</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="cCustomerOffer" runat="server" Width="150px" CssClass="disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                                    </th>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </fieldset>
                                                                                        <asp:HiddenField runat="server" ID="maskColBD" />
                                                                                        <asp:HiddenField runat="server" ID="maskColAD" />
                                                                                        <asp:HiddenField runat="server" ID="maskPayBD" />
                                                                                        <asp:HiddenField runat="server" ID="maskPayAD" />
                                                                                        <asp:HiddenField runat="server" ID="rateMaskAd" />
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </fieldset>
                                                                    </td>
                                                                    <td valign="top">
                                                                        <fieldset>
                                                                            <legend>Receive</legend>
                                                                            <table>
                                                                                <tr>
                                                                                    <td class="frmLable">Country <span class="errormsg">*</span></td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="pCountry" runat="server" CssClass="form-control" Width="150px" AutoPostBack="true"
                                                                                            OnSelectedIndexChanged="pCountry_SelectedIndexChanged">
                                                                                        </asp:DropDownList>

                                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="pCountry"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="cur" ForeColor="Red"
                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable">Agent</td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="pAgent" runat="server" CssClass="form-control" Width="150px" AutoPostBack="true"
                                                                                            OnSelectedIndexChanged="pAgent_SelectedIndexChanged">
                                                                                            <asp:ListItem Text="All" Value=""></asp:ListItem>
                                                                                        </asp:DropDownList>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable">Currency <span class="errormsg">*</span></td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="pCurrency" runat="server" CssClass="form-control" Width="150px" AutoPostBack="true"
                                                                                            OnSelectedIndexChanged="pCurrency_SelectedIndexChanged">
                                                                                        </asp:DropDownList>

                                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ControlToValidate="pCurrency"
                                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="cur" ForeColor="Red"
                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td style="height: 24px;"></td>
                                                                                    <td></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td colspan="2">
                                                                                        <fieldset>
                                                                                            <table class="table table-responsive">
                                                                                                <tr>
                                                                                                    <td colspan="2">
                                                                                                        <b>
                                                                                                            <label>Rate Factor</label></b>
                                                                                                        <asp:Label ID="lblPRateFactor" runat="server"></asp:Label>
                                                                                                        <asp:HiddenField ID="pRateFactor" runat="server" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <th nowrap="nowrap">
                                                                                                        <label>Cost Rate</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="pRate" ReadOnly="true" runat="server" Width="150px" CssClass="input disabled form-control"></asp:TextBox>
                                                                                                    </th>
                                                                                                    <th>
                                                                                                        <label>Margin</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="pMargin" runat="server" Width="150px" CssClass="input disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                                    </th>
                                                                                                    <th>
                                                                                                        <label>Offer</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="pOffer" runat="server" Width="150px" CssClass="input disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                                    </th>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <th></th>
                                                                                                    <th>
                                                                                                        <label>HO Margin</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="pHoMargin" runat="server" CssClass="form-control" Width="150px" onblur="CalcRate()"></asp:TextBox>
                                                                                                    </th>
                                                                                                    <th>
                                                                                                        <label>Agent Offer</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="pAgentOffer" runat="server" Width="150px" CssClass="disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                                    </th>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <th></th>
                                                                                                    <th>
                                                                                                        <label>Agent Margin</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="pAgentMargin" runat="server" CssClass="form-control" Width="150px" onblur="CalcRate()"></asp:TextBox>
                                                                                                    </th>
                                                                                                    <th>
                                                                                                        <label>Customer Offer</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="pCustomerOffer" runat="server" Width="150px" CssClass="disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                                    </th>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <th>
                                                                                                        <label>Sharing Type</label>
                                                                                                        <br />
                                                                                                        <asp:DropDownList ID="sharingType" runat="server" CssClass="form-control" Width="120px">
                                                                                                            <asp:ListItem Value="">Select</asp:ListItem>
                                                                                                            <asp:ListItem Value="F" Selected="true">Flat</asp:ListItem>
                                                                                                            <asp:ListItem Value="P">Percent</asp:ListItem>
                                                                                                        </asp:DropDownList>
                                                                                                    </th>
                                                                                                    <th>
                                                                                                        <label>Sharing Value</label>
                                                                                                        <br />
                                                                                                        <asp:TextBox ID="sharingValue" runat="server" CssClass="form-control" Width="150px"></asp:TextBox>
                                                                                                    </th>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </fieldset>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </fieldset>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2">
                                                                        <fieldset>
                                                                            <legend>Tolerance</legend>
                                                                            <table class="table table-responsive">
                                                                                <tr>
                                                                                    <th>
                                                                                        <label>Tolerance On</label>
                                                                                        <br />
                                                                                        <asp:DropDownList ID="toleranceOn" runat="server" CssClass="form-control" Width="120px">
                                                                                            <asp:ListItem Value="">Select</asp:ListItem>
                                                                                            <asp:ListItem Value="S">Send Rate</asp:ListItem>
                                                                                            <asp:ListItem Value="P">Receive Rate</asp:ListItem>
                                                                                            <asp:ListItem Value="C" Selected="true">Cross Rate</asp:ListItem>
                                                                                        </asp:DropDownList>
                                                                                    </th>
                                                                                    <th>
                                                                                        <label>Agent Tol.(-)</label>
                                                                                        <br />
                                                                                        <asp:TextBox ID="agentTolMin" runat="server" CssClass="form-control" Width="150px"></asp:TextBox>
                                                                                    </th>
                                                                                    <th>
                                                                                        <label>Agent Tol.(+)</label>
                                                                                        <br />
                                                                                        <asp:TextBox ID="agentTolMax" runat="server" CssClass="form-control" Width="150px"></asp:TextBox>
                                                                                    </th>
                                                                                    <th>
                                                                                        <label>Customer Tol.(-)</label>
                                                                                        <br />
                                                                                        <asp:TextBox ID="customerTolMin" runat="server" CssClass="form-control" Width="150px"></asp:TextBox>
                                                                                    </th>
                                                                                    <th>
                                                                                        <label>Customer Tol.(+)</label>
                                                                                        <br />
                                                                                        <asp:TextBox ID="customerTolMax" runat="server" CssClass="form-control" Width="150px"></asp:TextBox>
                                                                                    </th>
                                                                                </tr>
                                                                            </table>
                                                                        </fieldset>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="2" id="pnlCrossRate" runat="server" visible="true">
                                                                        <fieldset>
                                                                            <legend>Cross Rate</legend>
                                                                            <table class="table table-responsive">
                                                                                <tr>
                                                                                    <th>
                                                                                        <label>Max Cross Rate</label>
                                                                                        <br />
                                                                                        <asp:TextBox ID="maxCrossRate" runat="server" Width="150px" CssClass="disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                    </th>
                                                                                    <th>
                                                                                        <label>Agent Rate</label>
                                                                                        <br />
                                                                                        <asp:TextBox ID="crossRate" runat="server" Width="150px" CssClass="disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                    </th>
                                                                                    <th>
                                                                                        <label>Customer Rate</label>
                                                                                        <br />
                                                                                        <asp:TextBox ID="customerRate" runat="server" Width="150px" CssClass="disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                    </th>
                                                                                    <th>
                                                                                        <label>Cost</label>
                                                                                        <br />
                                                                                        <asp:TextBox ID="cost" runat="server" Width="150px" CssClass="disabled form-control" ReadOnly="true"></asp:TextBox>
                                                                                    </th>
                                                                                    <th>
                                                                                        <label>Margin</label>
                                                                                        <br />
                                                                                        <asp:TextBox ID="margin" runat="server" CssCla100pxss="disabled form-control" ReadOnly="true" Width="150px"></asp:TextBox>
                                                                                    </th>
                                                                                </tr>
                                                                            </table>
                                                                        </fieldset>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary m-t-25"
                                                                            ValidationGroup="cur" Display="Dynamic"
                                                                            OnClick="btnSave_Click" />
                                                                        <cc1:ConfirmButtonExtender ID="btnSavecc" runat="server"
                                                                            ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                                        </cc1:ConfirmButtonExtender>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>