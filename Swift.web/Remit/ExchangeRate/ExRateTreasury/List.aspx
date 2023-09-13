<%@ Page Language="C#" ValidateRequest="false" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.ExRateTreasury.List" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />

    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/columnselector.js" type="text/javascript"></script>

    <script src="js/treasurylist.js" type="text/javascript"></script>
    <script language="javascript" type="text/javascript">
        var p = 1;
        function MarginCalculator(id) {
            var cRate = GetValue("cRate_" + id) == "" ? 0 : parseFloat(GetValue("cRate_" + id));
            var cMargin = GetElement("cMargin_" + id).innerHTML == "" ? 0 : parseFloat(GetElement("cMargin_" + id).innerHTML);
            var cHoMargin = GetValue("cHoMargin_" + id) == "" ? 0 : parseFloat(GetValue("cHoMargin_" + id));
            var cAgentMargin = GetValue("cAgentMargin_" + id) == "" ? 0 : parseFloat(GetValue("cAgentMargin_" + id));
            var cOffer = cRate + cMargin + cHoMargin;
            var cCustomerOffer = cRate + cMargin + cHoMargin + cAgentMargin;

            var pRate = GetValue("pRate_" + id) == "" ? 0 : parseFloat(GetValue("pRate_" + id));
            var pMargin = GetElement("pMargin_" + id).innerHTML == "" ? 0 : parseFloat(GetElement("pMargin_" + id).innerHTML);
            var pHoMargin = GetValue("pHoMargin_" + id) == "" ? 0 : parseFloat(GetValue("pHoMargin_" + id));
            var pAgentMargin = GetValue("pAgentMargin_" + id) == "" ? 0 : parseFloat(GetValue("pAgentMargin_" + id));
            var pOffer = pRate - pMargin - pHoMargin;
            var pCustomerOffer = pRate - pMargin - pHoMargin - pAgentMargin;

            var customerRate = GetValue("customerRate_" + id) == "" ? 0 : parseFloat(GetValue("customerRate_" + id));
            var agentRate = GetValue("crossRate_" + id) == "" ? 0 : parseFloat(GetValue("crossRate_" + id));
            var toleranceOn = GetValue("toleranceOn_" + id);
            var agentCrossRateMargin = GetValue("agentCrossRateMargin_" + id) == "" ? 0 : parseFloat(GetValue("agentCrossRateMargin_" + id));

            PopUpWindow("CalculateMargin.aspx?cRate=" + cRate + "&cMargin=" + cMargin + "&cHoMargin=" + cHoMargin +
            "&cAgentMargin=" + cAgentMargin + "&cAgentOffer=" + cOffer + "&cCustomerOffer=" + cCustomerOffer +
            "&pRate=" + pRate + "&pMargin=" + pMargin + "&pHoMargin=" + pHoMargin +
            "&pAgentMargin=" + pAgentMargin + "&pAgentOffer=" + pOffer + "&pCustomerOffer=" + pCustomerOffer +
            "&customerRate=" + customerRate + "&agentRate=" + agentRate + "&toleranceOn=" + toleranceOn + "&agentCrossRateMargin=" + agentCrossRateMargin, "");
        }

        function LoadWindow() {
            var isFw = GetValue("<%=hdnIsFw.ClientID %>");
            if (isFw == "1") {
                GetElement("lnkManageWindow").innerHTML = "";
            }
            else {
                GetElement("lnkManageWindow").innerHTML = "Show In Full Window";
            }
            CheckForApplyFilter();
            EnableDisableButton();
        }

        function EnableDisableButton() {
            var cBoxes = document.getElementsByName("chkId");

            var j = 0;
            for (var i = 0; i < cBoxes.length; i++) {
                if (cBoxes[i].checked == true) {
                    j++;
                }
            }
            if (j == 0) {
                EnableButtons();
            }
            else {
                DisableButtons();
            }
        }

        function DisableButtons() {
            EnableDisableBtn("<%=btnMarkActive.ClientID %>", false);
            EnableDisableBtn("<%=btnMarkInactive.ClientID %>", false);
            EnableDisableBtn("<%=btnUpdateChanges.ClientID %>", false);
        }

        function EnableButtons() {
            EnableDisableBtn("<%=btnMarkActive.ClientID %>", true);
            EnableDisableBtn("<%=btnMarkInactive.ClientID %>", true);
            EnableDisableBtn("<%=btnUpdateChanges.ClientID %>", true);
        }

        function CheckForApplyFilter() {
            var cCountry = document.getElementById("<%=cCountry.ClientID %>").value;
            var cAgent = document.getElementById("<%=cAgent.ClientID %>").value;
            var cCurrency = document.getElementById("<%=cCurrency.ClientID %>").value;
            var pCountry = document.getElementById("<%=pCountry.ClientID %>").value;
            var pAgent = document.getElementById("<%=pAgent.ClientID %>").value;
            var pCurrency = document.getElementById("<%=pCurrency.ClientID %>").value;
            var tranType = document.getElementById("<%=tranType.ClientID %>").value;
            var isUpdated = document.getElementById("<%=isUpdated.ClientID %>").value;
            var ishaschanged = document.getElementById("<%=haschanged.ClientID %>").value;
            var showInactiveRecords = GetElement("<%=showInactive.ClientID %>").checked;
            if (cCountry != "" || cAgent != "" || cCurrency != "" || pCountry != "" || pAgent != "" || pCurrency != "" || tranType != "" || isUpdated != "" || ishaschanged != "" || showInactiveRecords == true) {
                GetElement("spnFilter").setAttribute('style', 'background-color: yellow !important;');
            }
            else {
                GetElement("spnFilter").setAttribute('style', 'background-color: none !important;');
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
                //                ShowHideUpdateCol();
                if (GetValue("<%=countryOrderBy.ClientID %>") == "sendingCountry")
                    $('#rateTable th:nth-col(2), #rateTable td:nth-col(2)').hide();
                else
                    $('#rateTable th:nth-col(4), #rateTable td:nth-col(4)').hide();
            }

            function UpdateCheckedRecords() {
                if (confirm("Are you sure to update selected records?")) {
                    GetElement("<%=btnUpdateChanges.ClientID %>").click();
                }
            }

            function UpdateRate(id, isUpdated) {
                if (confirm("Are you sure to update this record?")) {
                    SetValueById("<%=exRateTreasuryId.ClientID %>", id, "");
                    SetValueById("<%=hddCHoMargin.ClientID %>", GetValue("cHoMargin_" + id), "");
                    SetValueById("<%=hddCAgentMargin.ClientID %>", GetValue("cAgentMargin_" + id), "");
                    SetValueById("<%=hddPHoMargin.ClientID %>", GetValue("pHoMargin_" + id), "");
                    SetValueById("<%=hddPAgentMargin.ClientID %>", GetValue("pAgentMargin_" + id), "");
                    SetValueById("<%=sharingType.ClientID %>", GetValue("sharingType_" + id), "");
                    SetValueById("<%=sharingValue.ClientID %>", GetValue("sharingValue_" + id), "");
                    SetValueById("<%=toleranceOn.ClientID %>", GetValue("toleranceOn_" + id), "");
                    SetValueById("<%=agentTolMin.ClientID %>", GetValue("agentTolMin_" + id), "");
                    SetValueById("<%=agentTolMax.ClientID %>", GetValue("agentTolMax_" + id), "");
                    SetValueById("<%=customerTolMin.ClientID %>", GetValue("customerTolMin_" + id), "");
                    SetValueById("<%=customerTolMax.ClientID %>", GetValue("customerTolMax_" + id), "");
                    SetValueById("<%=crossRate.ClientID %>", GetValue("crossRate_" + id), "");
                    SetValueById("<%=agentCrossRateMargin.ClientID %>", GetValue("agentCrossRateMargin_" + id), "");
                    SetValueById("<%=customerRate.ClientID %>", GetValue("customerRate_" + id), "");
                    SetValueById("<%=isUpdated.ClientID %>", isUpdated, "");
                    GetElement("<%=btnUpdate.ClientID %>").click();
                }
            }

            function submit_form() {
                var btn = document.getElementById("<%=btnHidden.ClientID %>");
                if (btn != null)
                    btn.click();
            }
            function clearForm() {
                var btn = document.getElementById("<%=btnClearData.ClientID %>");
                document.getElementById("<%=cCountry.ClientID %>").value = "";
                document.getElementById("<%=cAgent.ClientID %>").value = "";
                document.getElementById("<%=cCurrency.ClientID %>").value = "";
                document.getElementById("<%=pCountry.ClientID %>").value = "";
                document.getElementById("<%=pAgent.ClientID %>").value = "";
                document.getElementById("<%=pCurrency.ClientID %>").value = "";
                document.getElementById("<%=tranType.ClientID %>").value = "";
                document.getElementById("<%=isUpdated.ClientID %>").value = "";
                document.getElementById("<%=haschanged.ClientID %>").value = "";
                GetElement("<%=showInactive.ClientID %>").checked = false;
                if (btn != null)
                    btn.click();
            }

            function nav(page) {
                var hdd = document.getElementById("hdd_curr_page");
                if (hdd != null)
                    hdd.value = page;

                submit_form();
            }
    </script>
    <style type="">
        .table .table {
            background-color: #f5f5f5;
        }
    </style>
</head>

<body onload="LoadWindow()">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <asp:Button ID="btnHidden" runat="server" OnClick="btnHidden_Click" Style="display: none" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">SETUP PROCESS</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Exchange Rate</a></li>
                            <li class="active"><a href="List.aspx">Exchange Rate Treasury</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <div id="divTab" class="tabs" runat="server" enableviewstate="false"></div>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">TREASURY RATE SETUP List
                                    </h4>
                                </div>

                                <div class="panel-body">
                                    <div class="form-group">
                                        <asp:UpdatePanel ID="upnl1" runat="server">
                                            <ContentTemplate>
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <td class="GridTextNormal"><span id="spnFilter"><b>Filtered results</b></span>&nbsp;&nbsp;&nbsp;
                                                                     <asp:ImageButton ID="btnFilterShowHide" runat="server" Style="border: 0;" ImageUrl="../../../images/icon_hide.gif" OnClick="btnFilterShowHide_Click" />&nbsp;&nbsp;&nbsp;
                                                                 <a href="#" id="lnkManageWindow" onclick="ManageWindow();">Show in Full Window</a>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td id="td_Search" runat="server" visible="true">
                                                            <table class="table table-responsive">
                                                                <tr>
                                                                    <td valign="top">
                                                                        <table class="table table-responsive">
                                                                            <tr>
                                                                                <th></th>
                                                                                <th align="left">
                                                                                    <label>Send</label></th>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Country</label></td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="cCountry" runat="server" CssClass="form-control" Width="180px" AutoPostBack="true"
                                                                                        OnSelectedIndexChanged="cCountry_SelectedIndexChanged">
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Agent</label></td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="cAgent" runat="server" CssClass="form-control" Width="180px"></asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Currency</label></td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="cCurrency" runat="server" CssClass="form-control" Width="180px"></asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                    <td></td>
                                                                    <td valign="top">
                                                                        <table class="table table-responsive">
                                                                            <tr>
                                                                                <th></th>
                                                                                <th align="left">
                                                                                    <label>Receive</label></th>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Country</label></td>
                                                                                <td nowrap="nowrap">
                                                                                    <asp:DropDownList ID="pCountry" runat="server" CssClass="form-control" Width="180px" AutoPostBack="true"
                                                                                        OnSelectedIndexChanged="pCountry_SelectedIndexChanged">
                                                                                    </asp:DropDownList>
                                                                                    <asp:CheckBox ID="filterbyPCountryOnly" runat="server" Text="Only"></asp:CheckBox>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Agent</label></td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="pAgent" runat="server" CssClass="form-control" Width="180px"></asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Currency</label></td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="pCurrency" runat="server" CssClass="form-control" Width="180px"></asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                    <td>
                                                                        <table class="table table-responsive">
                                                                            <tr>
                                                                                <td align="left">
                                                                                    <label>Tran Type</label>
                                                                                </td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="tranType" runat="server" CssClass="form-control" Width="135px"></asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <label>Is Updated</label></td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="ddlIsUpdated" runat="server" CssClass="form-control" Width="135px">
                                                                                        <asp:ListItem Value="">All</asp:ListItem>
                                                                                        <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                                                        <asp:ListItem Value="N">No</asp:ListItem>
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td nowrap="nowrap">
                                                                                    <label>Change Status</label>
                                                                                </td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="haschanged" runat="server" CssClass="form-control" Width="135px">
                                                                                        <asp:ListItem Value="">All</asp:ListItem>
                                                                                        <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                                                        <asp:ListItem Value="N">No</asp:ListItem>
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td nowrap="nowrap">
                                                                                    <label>Order By</label>
                                                                                </td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="countryOrderBy" runat="server" CssClass="form-control" Width="135px">
                                                                                        <asp:ListItem Value="sendingCountry">Sending Country</asp:ListItem>
                                                                                        <asp:ListItem Value="receivingCountry">Receiving Country</asp:ListItem>
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td nowrap="nowrap" colspan="2">
                                                                                    <asp:CheckBox ID="showInactive" runat="server" Text="Show Inactive records"></asp:CheckBox>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td colspan="4">
                                                                        <input type="button" value="Search" class="btn btn-primary m-t25" onclick="submit_form();">
                                                                        <input type="button" value="Clear Filter" class="btn btn-primary m-t25" onclick="clearForm();">
                                                                        <span style="font-size: 14px;" class="errormsg">* Note: Please select corridor to view rate</span>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                        <input type="button" id="btnShowAllColumns" class="btn btn-primary m-t-25" value="Show All Columns" onclick="ShowAllColumns();" /><br />
                                        <div id="paginDiv" runat="server" enableviewstate="false"></div>
                                        <div id="rpt_grid" runat="server" enableviewstate="false" style="overflow-y: scroll;">
                                        </div>
                                        <div id="divFixed" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none; border: none;">
                                            <asp:Button ID="btnUpdateChanges" runat="server" Text="Update Selected Records" Visible="false" OnClick="btnUpdateChanges_Click" />
                                            <img src="../../../Images/close-icon.png" border="0" class="showHand" onclick="RemoveDivFixed();" title="Close" />
                                            <cc1:ConfirmButtonExtender ID="btnUpdateChangescc" runat="server" ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnUpdateChanges">
                                            </cc1:ConfirmButtonExtender>
                                        </div>
                                        <asp:Button ID="btnMarkActive" runat="server" Visible="false" Style="float: right;" Text="Set Active" OnClick="btnMarkActive_Click" />&nbsp;
                                                         <asp:Button ID="btnMarkInactive" CssClass="btn btn-primary m-t-25" runat="server" Visible="false" Style="float: left;" Text="Set Inactive" OnClick="btnMarkInactive_Click" />
                                        <asp:Button ID="btnUpdate" runat="server" Text="Update" OnClick="btnUpdate_Click" Style="display: none;" />
                                        <asp:Button ID="btnClearData" runat="server" OnClick="btnClearData_Click" Style="display: none;" />
                                        <asp:HiddenField ID="exRateTreasuryId" runat="server" />
                                        <asp:HiddenField ID="tolerance" runat="server" />
                                        <asp:HiddenField ID="hddCHoMargin" runat="server" />
                                        <asp:HiddenField ID="hddCAgentMargin" runat="server" />
                                        <asp:HiddenField ID="hddPHoMargin" runat="server" />
                                        <asp:HiddenField ID="hddPAgentMargin" runat="server" />
                                        <asp:HiddenField ID="sharingType" runat="server" />
                                        <asp:HiddenField ID="sharingValue" runat="server" />
                                        <asp:HiddenField ID="toleranceOn" runat="server" />
                                        <asp:HiddenField ID="agentTolMin" runat="server" />
                                        <asp:HiddenField ID="agentTolMax" runat="server" />
                                        <asp:HiddenField ID="customerTolMin" runat="server" />
                                        <asp:HiddenField ID="customerTolMax" runat="server" />
                                        <asp:HiddenField ID="crossRate" runat="server" />
                                        <asp:HiddenField ID="agentCrossRateMargin" runat="server" />
                                        <asp:HiddenField ID="customerRate" runat="server" />
                                        <asp:HiddenField ID="isUpdated" runat="server" />
                                        <asp:HiddenField ID="hdnIsFw" runat="server" />
                                    </div>
                                    <div id="newDiv" style="position: absolute; display: none; border: none;">
                                        <table class="table table-responsive">
                                            <tr>
                                                <td colspan="2" nowrap="nowrap">
                                                    <input type="text" id="txtCopyValue" style="width: 75px; text-align: right; float: left;" />
                                                    <input type="button" id="btnCopyValue" value="Apply" class="btn btn-primary m-t-25" onclick="CopyValue();" />
                                                    <img src="../../../Images/close-icon.png" border="0" class="showHand" onclick="RemoveDiv();" title="Close" />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div id="divUpdate" style="position: absolute; margin-top: 17px; margin-left: 0px; display: none; border: none;">
                                        <img src="../../../Images/close-icon.png" border="0" class="showHand" onclick="RemoveDivUpdate();" title="Close" />
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