<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewScDomestic.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.ServiceCharge.ViewScDomestic" %>

<%@ Import Namespace="Swift.web.Library" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../../js/jQuery/jquery-1.4.1.min.js"></script>

    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../../../js/swift_autocomplete.js" type="text/javascript"></script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../js/jQuery/jquery-ui.min.js"></script>

    <style>
        table tr td {
            background-color: #efefef;
        }
    </style>
    <script type="text/javascript">
        var urlRoot = "<%=GetStatic.GetUrlRoot() %>";

        function Loading(flag) {
            if (flag == "show")
                ShowElement("divLoading");
            else
                HideElement("divLoading");
        }

        function ShowHideServiceCharge() {
            var pos = FindPos(GetElement("btnSCDetails"));
            GetElement("newDiv").style.left = pos[0] + "px";
            GetElement("newDiv").style.top = pos[1] + "px";
            GetElement("newDiv").style.border = "1px solid black";
            if (GetElement("newDiv").style.display == "none" || GetElement("newDiv").style.display == "")
                $("#newDiv").slideToggle("fast");
            else
                $("#newDiv").slideToggle("fast");
        }
        function RemoveDiv() {
            $("#newDiv").slideToggle("fast");
        }


        // ### for bank deposit service charge calculation

        function LoadServiceCharge1() {
            if (!Page_ClientValidate('sc1'))
                return false;

            Loading('show');
            var dm = GetValue("<% =hdnBankDeposit.ClientID%>");
            var amount = GetValue("<%=sendAmount1.ClientID %>");
            var pLocation = null;
            var pBankBranch = GetValue("bankBranch");
            var sBranch = "";

            $.get(urlRoot + "/Remit/Transaction/Agent/Send/Domestic/FormLoader.aspx", { sBranch: sBranch, pBankBranch: pBankBranch, pLocation: pLocation, amount: amount, dm: dm, type: 'a' }, function (data) {
                var res = data.split('|');
                if (res[0] != "0") {
                    GetElement("<%=lblServiceCharge.ClientID %>").innerHTML = "";
                    GetElement("<%=lblCollAmt.ClientID %>").innerHTML = "";
                    window.parent.SetMessageBox(res[1], '1');
                    Loading('hide');
                    return;
                }
                document.getElementById("<%=lblServiceCharge.ClientID %>").innerHTML = res[1];
                document.getElementById("<%=lblCollAmt.ClientID %>").innerHTML = res[2];
                LoadServiceChargeTable1();
            });
            Loading('hide');
        }
        function LoadServiceChargeTable1() {

            Loading('show');
            var sBranch = "";
            var dm = GetValue("<%=hdnBankDeposit.ClientID %>");
            var amount = GetValue("<%=sendAmount1.ClientID %>");
            var pBankBranch = GetValue("bankBranch");
            var pLocation = null;
            $.get(urlRoot + "/Remit/Transaction/Agent/Send/Domestic/FormLoader.aspx", { sBranch: sBranch, pBankBranch: pBankBranch, pLocation: pLocation, dm: dm, amount: amount, type: 'sct' }, function (data) {

                GetElement("scTable").innerHTML = data;

                ShowHideServiceCharge1();
            });
            Loading('hide');
        }
        function ShowHideServiceCharge1() {
            var pos = FindPos(GetElement("btnSCDetails1"));
            GetElement("newDivBank").style.left = pos[0] + "px";
            GetElement("newDivBank").style.top = pos[1] + "px";
            GetElement("newDivBank").style.border = "1px solid black";
            if (GetElement("newDivBank").style.display == "none" || GetElement("newDivBank").style.display == "")
                $("#newDivBank").slideToggle("fast");
            else
                $("#newDivBank").slideToggle("fast");
        }
        function RemoveDiv1() {
            $("#newDivBank").slideToggle("fast");
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:ScriptManager ID="ScriptManger1" runat="server">
            </asp:ScriptManager>
            <div class="page-wrapper">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="page-title">
                            <ol class="breadcrumb">
                                <li><a href="../../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                                <li class="active"><a href="Search.aspx">Agent Locator</a></li>
                            </ol>
                        </div>
                    </div>
                </div>
                <table>
                    <asp:UpdatePanel ID="upd1" runat="server">
                        <ContentTemplate>
                            <table class="table table-condensed">
                                <tr>
                                    <td valign="top">
                                        <div class="panel panel-default  margin-b-30">
                                            <asp:HiddenField ID="hdnCashPayment" runat="server" Value="Cash Payment" />
                                            <div class="panel-heading panel-title">Agent Finder</div>
                                            <div class="panel-body">
                                                <table class="table table-condensed">
                                                    <tr>
                                                        <td>
                                                            <div align="right" class="formLabel">Location : </div>
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <div class="form-group form-inline">
                                                                <asp:DropDownList ID="location" runat="server" CssClass="form-control"
                                                                    AutoPostBack="True">
                                                                </asp:DropDownList>
                                                                <span class="errormsg">*</span>
                                                                <asp:RequiredFieldValidator ID="rv1" runat="server"
                                                                    ControlToValidate="location" Display="Dynamic" ErrorMessage="Required"
                                                                    ForeColor="Red" SetFocusOnError="True" ValidationGroup="SC">
                                                                </asp:RequiredFieldValidator>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div align="right" class="formLabel">Agent/Branch :</div>
                                                        </td>
                                                        <td>
                                                            <uc1:SwiftTextBox ID="sAgent" runat="server" style="width:40% !important" Category="remit-agent" />
                                                        </td>
                                                    </tr>
                                                    <tr style="display: none;">
                                                        <td>
                                                            <div align="right" class="formLabel">District :</div>
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <div class="form-group form-inline">
                                                                <asp:DropDownList ID="district" runat="server" CssClass="form-control" AutoPostBack="True" Width="96%"></asp:DropDownList>
                                                                <span class="errormsg">*</span>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
                                                                    ControlToValidate="district" Display="Dynamic" ErrorMessage="Required"
                                                                    ForeColor="Red" SetFocusOnError="True" ValidationGroup="SC">
                                                                </asp:RequiredFieldValidator>

                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server"
                                                                    ControlToValidate="district" Display="Dynamic" ErrorMessage="Required"
                                                                    ForeColor="Red" SetFocusOnError="True">
                                                                </asp:RequiredFieldValidator>
                                                                <br />
                                                                <br />

                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td>
                                                            <asp:Button ID="btnAgentFind" CssClass="btn btn-primary btn-sm" runat="server"
                                                                Text="Search Agent" OnClientClick="return CheckField();" OnClick="btnAgentFind_Click" ValidationGroup="sa" /></td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="display: none;">
                                        <div class="panel panel-default  margin-b-30">
                                            <asp:HiddenField ID="hdnBankDeposit" runat="server" Value="Bank Deposit" />
                                            <div class="panel-heading panel-title">Service Charge - Bank Deposit</div>
                                            <div class="panel-body">
                                                <table class="table table-condensed">
                                                    <tr>
                                                        <td>
                                                            <div align="right" class="formLabel">Bank : </div>
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <div class="form-group form-inline">
                                                                <asp:DropDownList ID="bankName" runat="server" CssClass="form-control"
                                                                    AutoPostBack="True" OnSelectedIndexChanged="bankName_SelectedIndexChanged">
                                                                </asp:DropDownList>
                                                                <span class="errormsg">*</span>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server"
                                                                    ControlToValidate="bankName" Display="Dynamic" ErrorMessage="Required"
                                                                    ForeColor="Red" SetFocusOnError="True" ValidationGroup="sc1">
                                                                </asp:RequiredFieldValidator>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div align="right" class="formLabel">Branch :</div>
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <div class="form-group form-inline">
                                                                <asp:DropDownList ID="bankBranch" Width="97%" runat="server" CssClass="form-control" AutoPostBack="True"></asp:DropDownList>
                                                                <span class="errormsg">*</span>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server"
                                                                    ControlToValidate="bankBranch" Display="Dynamic" ErrorMessage="Required"
                                                                    ForeColor="Red" SetFocusOnError="True" ValidationGroup="sc1">
                                                                </asp:RequiredFieldValidator>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div align="right" class="formLabel">Send Amount :</div>
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <div class="form-group form-inline">
                                                                <asp:TextBox ID="sendAmount1" runat="server" CssClass="form-control" Width="97%"></asp:TextBox>
                                                                <span class="errormsg">*</span>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server"
                                                                    ControlToValidate="sendAmount1" Display="Dynamic" ErrorMessage="Required"
                                                                    ForeColor="Red" SetFocusOnError="True" ValidationGroup="sc1">
                                                                </asp:RequiredFieldValidator>
                                                                <br />
                                                                <br />

                                                                <input type="button" class="btn btn-primary btn-sm" value="Calculate" onclick="LoadServiceCharge1();" />



                                                                <img class="showHand" title="View Service Charge" id="btnSCDetails1" src="../../../../images/rule.gif"
                                                                    border="0" onclick="LoadServiceChargeTable1()" />

                                                                <div id="newDivBank" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none;">
                                                                    <table cellpadding="0" cellspacing="0" style="background: white;">
                                                                        <tr>
                                                                            <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">Service Charge</td>
                                                                            <td style="background-color: #3A4F63; font: bold 11px Verdana; color: #FFFFFF;">
                                                                                <span title="Close" style="cursor: pointer; margin: 2px; float: right;"
                                                                                    onclick=" RemoveDiv1(); "><b>x</b></span>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td colspan="2">
                                                                                <div id="scTable">N/A</div>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </div>
                                                            </div>

                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div align="right" class="formLabel">Service Charge :</div>
                                                        </td>
                                                        <td>
                                                            <span style="font-size: 1.2em; color: Red; font-weight: bold;">
                                                                <asp:Label runat="server" ID="lblServiceCharge"></asp:Label></span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div align="right" class="formLabel">Collection Amount :</div>
                                                        </td>
                                                        <td>
                                                            <span style="font-size: 1.3em; font-weight: bold;">
                                                                <asp:Label runat="server" ID="lblCollAmt"></asp:Label></span>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <div id="divLoadGrid" runat="server"></div>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </table>
            </div>
        </div>
    </form>
</body>
<script type="text/javascript">

    function CheckField() {
        var location = document.getElementById("location").value;
        var agentId = GetItem("sAgent")[0];
        if (location == "" && agentId == "") {
            alert("Please Choose Atleast Country or Agent");
            return false;
        }
        return true;
    }

</script>
</html>
