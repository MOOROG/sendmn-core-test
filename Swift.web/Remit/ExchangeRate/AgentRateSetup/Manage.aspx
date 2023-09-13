<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.AgentRateSetup.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />

    <script src="../../../js/functions.js" type="text/javascript"></script>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript">

        function CalcCollectionOffer() {
            var factor = GetValue("<%=factor.ClientID %>");
            var cost = GetValue("<%=cRate.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cRate.ClientID %>"));
            var margin = GetValue("<%=cMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cMargin.ClientID %>"));
            var offer;
            if (factor == "D")
                offer = cost - margin;
            else
                offer = cost + margin;
            GetElement("<%=cOffer.ClientID %>").value = offer;
        }
        function CalcPaymentOffer() {
            var factor = GetValue("<%=factor.ClientID %>");
            var cost = GetValue("<%=pRate.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pRate.ClientID %>"));
            var margin = GetValue("<%=pMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pMargin.ClientID %>"));
            var offer;
            if (factor == "D")
                offer = cost + margin;
            else
                offer = cost - margin;
            GetElement("<%=pOffer.ClientID %>").value = offer;
        }

        function CalcCollectionOfferMask(obj, beforeLength, afterLength) {
            var errorCode = checkRateMasking(obj, beforeLength, afterLength);
            if (errorCode == 1) {
                setTimeout(function () { obj.focus(); }, 1);
                return;
            }
            var factor = GetValue("<%=factor.ClientID %>");
            var cost = GetValue("<%=cRate.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cRate.ClientID %>"));
            var margin = GetValue("<%=cMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=cMargin.ClientID %>"));
            var cMin = GetValue("<%=hddTolCMin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=hddTolCMin.ClientID %>"));
            var cMax = GetValue("<%=hddTolCMax.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=hddTolCMax.ClientID %>"));
            var offer = 0;
            if (factor == "D") {
                offer = cost - margin;
            }
            else
                offer = cost + margin;
            offer = roundNumber(offer, afterLength);
            //            if (offer > cMax) {
            //                alert("Send offer rate calculated : " + offer + " exceeded max cost rate. Rate must lie between " + cMin + " and " + cMax);
            //                setTimeout(function () { obj.focus(); }, 1);
            //                return;
            //            }
            //            if (offer < cMin) {
            //                alert("Send offer rate calculated : " + offer + " deceeded max cost rate. Rate must lie between " + cMin + " and " + cMax);
            //                setTimeout(function () { obj.focus(); }, 1);
            //                return;
            //            }

            GetElement("<%=cOffer.ClientID %>").value = offer;
        }

        function CalcPaymentOfferMask(obj, beforeLength, afterLength) {
            var errorCode = checkRateMasking(obj, beforeLength, afterLength);
            if (errorCode == 1) {
                setTimeout(function () { obj.focus(); }, 1);
                return;
            }
            var factor = GetValue("<%=factor.ClientID %>");
            var cost = GetValue("<%=pRate.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pRate.ClientID %>"));
            var margin = GetValue("<%=pMargin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=pMargin.ClientID %>"));
            var pMin = GetValue("<%=hddTolPMin.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=hddTolPMin.ClientID %>"));
            var pMax = GetValue("<%=hddTolPMax.ClientID %>") == "" ? 0 : parseFloat(GetValue("<%=hddTolPMax.ClientID %>"));

            var offer;
            if (factor == "D")
                offer = cost + margin;
            else
                offer = cost - margin;
            offer = roundNumber(offer, afterLength);
            /*
            if (offer > pMax) {
                alert("Receive offer rate calculated : " + offer + " exceeded max cost rate. Rate must lie between " + pMin + " and " + pMax);
                setTimeout(function () { obj.focus(); }, 1);
                return;
            }
            if (offer < pMin) {
                alert("Receive offer rate calculated : " + offer + " deceeded min cost rate. Rate must lie between " + pMin + " and " + pMax);
                setTimeout(function () { obj.focus(); }, 1);
                return;
            }
            */
            GetElement("<%=pOffer.ClientID %>").value = offer;
        }
    </script>
    <style>
        .page-title {
            border-bottom: 2px solid #f5f5f5;
            margin-bottom: 15px;
            padding-bottom: 10px;
            text-transform: capitalize;
        }

            .page-title h1 {
                color: #656565;
                font-size: 20px;
                text-transform: uppercase;
                font-weight: 400;
            }

            .page-title .breadcrumb {
                background-color: transparent;
                margin: 0;
                padding: 0;
            }

        .breadcrumb > li {
            display: inline-block;
        }

            .breadcrumb > li a {
                color: #0E96EC;
            }

            .breadcrumb > li + li::before {
                color: #ccc;
                content: "/ ";
                padding: 0 5px;
            }

        .tabs > li > a {
            padding: 10px 15px;
            background-color: #444d58;
            border-radius: 5px 5px 0 0;
            color: #fff;
        }

        .exTable tr td .inputBox {
            background-color: #fff;
            background-image: none;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) inset;
            color: #555;
            display: block;
            font-size: 14px;
            height: 25px;
            line-height: 1.42857;
            transition: border-color 0.15s ease-in-out 0s, box-shadow 0.15s ease-in-out 0s;
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

        .table .table {
            background-color: #F5F5F5 !important;
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
                            <li class="active"><a href="Manage.aspx">Cost Rate Setup- Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="List.aspx" target="_self">Agent Rate </a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Add New</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Cost Rate Setup Add New
                                    </h4>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <asp:UpdatePanel ID="upnl1" runat="server">
                                            <ContentTemplate>
                                                <asp:HiddenField runat="server" ID="maskBD" />
                                                <asp:HiddenField runat="server" ID="maskAD" />
                                                <asp:HiddenField runat="server" ID="hddTolCMin" />
                                                <asp:HiddenField runat="server" ID="hddTolCMax" />
                                                <asp:HiddenField runat="server" ID="hddTolPMin" />
                                                <asp:HiddenField runat="server" ID="hddTolPMax" />
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <td valign="top">
                                                            <table class="table table-responsive">
                                                                <tr>
                                                                    <td>
                                                                        <label>Base Currency:<span class="errormsg">*</span></label></td>
                                                                    <td>
                                                                        <asp:DropDownList ID="baseCurrency" runat="server" CssClass="form-control" Width="100%" Style="height: 35px;"></asp:DropDownList>
                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="baseCurrency"
                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <label>Country:</label><span class="errormsg">*</span></td>
                                                                    <td>
                                                                        <asp:DropDownList ID="country" runat="server" CssClass="form-control" Width="100%" Style="height: 35px;" AutoPostBack="true"
                                                                            OnSelectedIndexChanged="country_SelectedIndexChanged">
                                                                        </asp:DropDownList>
                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="country"
                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <label>Agent:<span class="errormsg">*</span></label></td>
                                                                    <td>
                                                                        <asp:DropDownList ID="agent" runat="server" CssClass="form-control" Width="100%" Style="height: 35px;"></asp:DropDownList>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <label>Quote Currency:<span class="errormsg">*</span></label></td>
                                                                    <td>
                                                                        <asp:DropDownList ID="currency" runat="server" CssClass="form-control" Width="100%" Style="height: 35px;" AutoPostBack="true"
                                                                            OnSelectedIndexChanged="currency_SelectedIndexChanged">
                                                                        </asp:DropDownList>
                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="currency"
                                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <label>Factor:</label></td>
                                                                    <td nowrap="nowrap">
                                                                        <asp:RadioButtonList ID="factor" runat="server" RepeatDirection="Horizontal" Enabled="false">
                                                                            <asp:ListItem Value="M" Selected="true">Multiplication</asp:ListItem>
                                                                            <asp:ListItem Value="D">Division</asp:ListItem>
                                                                        </asp:RadioButtonList>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td id="panelCollectionRate" runat="server" visible="false">
                                                            <fieldset>
                                                                <legend>Send</legend>
                                                                <table class="table table-responsive">
                                                                    <tr>
                                                                        <th class="">Cost Rate<span class="errormsg">*</span>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="cRate"
                                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        </th>
                                                                        <th class="">Margin<span class="errormsg">*</span>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="cMargin"
                                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        </th>
                                                                        <th class="">Offer Rate</th>
                                                                    </tr>
                                                                    <tr>
                                                                        <th nowrap="nowrap">
                                                                            <asp:TextBox ID="cRate" runat="server" Width="90%" Style="height: 35px;" CssClass="form-control"></asp:TextBox>
                                                                        </th>
                                                                        <th>
                                                                            <asp:TextBox ID="cMargin" runat="server" Style="height: 35px;" Width="90%" CssClass="form-control"></asp:TextBox>
                                                                        </th>
                                                                        <th>
                                                                            <asp:TextBox ID="cOffer" runat="server" Width="90%" Style="height: 35px;" ReadOnly="true" CssClass="form-control" BackColor="#FFA822"></asp:TextBox>
                                                                        </th>
                                                                    </tr>
                                                                </table>
                                                            </fieldset>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td id="panelPaymentRate" runat="server" visible="false">
                                                            <fieldset>
                                                                <legend>Receive</legend>
                                                                <table class="table table-responsive">
                                                                    <tr>
                                                                        <th class="">Cost Rate<span class="errormsg">*</span>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="pRate"
                                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        </th>
                                                                        <th class="">Margin<span class="errormsg">*</span>
                                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="pMargin"
                                                                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                        </th>
                                                                        <th class="">Offer Rate</th>
                                                                    </tr>
                                                                    <tr>
                                                                        <th nowrap="nowrap">
                                                                            <asp:TextBox ID="pRate" runat="server" Width="100%" Style="height: 35px;" CssClass="form-control"></asp:TextBox>
                                                                        </th>
                                                                        <th>
                                                                            <asp:TextBox ID="pMargin" runat="server" Width="100%" Style="height: 35px;" CssClass="form-control"></asp:TextBox>
                                                                        </th>
                                                                        <th>
                                                                            <asp:TextBox ID="pOffer" runat="server" Width="100%" Style="height: 35px;" ReadOnly="true" CssClass="form-control" BackColor="#FFA822"></asp:TextBox>
                                                                        </th>
                                                                    </tr>
                                                                </table>
                                                            </fieldset>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary m-t25" Style="padding: 5px; height: 35px;"
                                                                ValidationGroup="agent" Display="Dynamic"
                                                                OnClick="btnSave_Click" />
                                                            <cc1:ConfirmButtonExtender ID="btnSavecc" runat="server"
                                                                ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                            </cc1:ConfirmButtonExtender>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
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