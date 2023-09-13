<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.RateMask.List" %>

<%@ Register Assembly="AjaxControlToolKit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>

    <script type="text/javascript">

        function UpdateRate(id) {
            if (confirm("Are you sure to update this record?")) {
                var cMin = GetValue("cMin_" + id) == "" ? 0 : parseFloat(GetValue("cMin_" + id));
                var cMax = GetValue("cMax_" + id) == "" ? 0 : parseFloat(GetValue("cMax_" + id));
                var pMin = GetValue("pMin_" + id) == "" ? 0 : parseFloat(GetValue("pMin_" + id));
                var pMax = GetValue("pMax_" + id) == "" ? 0 : parseFloat(GetValue("pMax_" + id));
                if (cMin > cMax) {
                    alert('Send max rate cannot be less than min rate');
                    return;
                }
                if (pMin > pMax) {
                    alert('Receive max rate cannot be less than min rate');
                    return;
                }
                SetValueById("<%=hdnratemaskId.ClientID %>", id, "");
                SetValueById("<%=hdnmulBd.ClientID %>", GetValue("rateMaskMulBd_" + id), "");
                SetValueById("<%=hdnmulAd.ClientID %>", GetValue("rateMaskMulAd_" + id), "");
                SetValueById("<%=hdndivBd.ClientID %>", GetValue("rateMaskDivBd_" + id), "");
                SetValueById("<%=hdndivAd.ClientID %>", GetValue("rateMaskDivAd_" + id), "");
                SetValueById("<%=hdnCMin.ClientID %>", GetValue("cMin_" + id), "");
                SetValueById("<%=hdnCMax.ClientID %>", GetValue("cMax_" + id), "");
                SetValueById("<%=hdnPMin.ClientID %>", GetValue("pMin_" + id), "");
                SetValueById("<%=hdnPMax.ClientID %>", GetValue("pMax_" + id), "");
                GetElement("<%=btnUpdate.ClientID %>").click();
            }
        }
        function ManageMask(id) {
            var MaskMulBd = parseFloat(GetValue("rateMaskMulBd_" + id));
            var MaskMulAd = parseFloat(GetValue("rateMaskMulAd_" + id));
            var MaskDivBd = parseFloat(GetValue("rateMaskDivBd_" + id));
            var MaskDivAd = parseFloat(GetValue("rateMaskDivAd_" + id));

            if (MaskMulBd > 9) {
                document.getElementById("rateMaskMulBd_" + id).focus();
                alert("Rate Mask value can not be more than 9!");
                return false;

            }
            if (MaskMulAd > 9) {
                alert("Rate Mask value can not be more than 10!");
                document.getElementById("rateMaskMulAd_" + id).focus();
                return false;
            }
            if (MaskDivBd > 9) {
                alert("Rate Mask value can not be more than 10!");
                document.getElementById("rateMaskDivBd_" + id).focus();
                return false;
            }
            if (MaskDivAd > 9) {
                alert("Rate Mask value can not be more than 10!");
                document.getElementById("rateMaskDivAd_" + id).focus();
                return false;
            }
        }

        function getRadioCheckedValue(radioName) {
            var oRadio = document.forms[0].elements[radioName];

            for (var i = 0; i < oRadio.length; i++) {
                if (oRadio[i].checked) {
                    return oRadio[i].value;
                }
            }
        }
        function CallBack() {
            window.location.replace('List.aspx');
        }

        function submit_form() {
            var btn = document.getElementById("<%=btnHidden.ClientID %>");
            if (btn != null)
                btn.click();
        }
        function clearForm() {
            var btn = document.getElementById("<%=btnHidden.ClientID %>");
            document.getElementById("<%=currencyFilter.ClientID %>").value = "";
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
                img.src = isHidden ? "../../../images/icon_hide.gif" : "../../../images/icon_show.gif";
                img.alt = isHidden ? "Hide" : "Show";
                td.style.display = isHidden ? "" : "none";
            }
        }

        var oldId = 0;

        function KeepRowSelection(i, id) {
            if (oldId != 0 && oldId != id) {
                var j = GetValue(oldId);
                if (j % 2 == 1)
                    GetElement("row_" + oldId).className = "oddbg";
                else
                    GetElement("row_" + oldId).className = "evenbg";
                EnableDisableBtn("btnUpdate_" + oldId, true);
            }
            GetElement("row_" + id).className = "selectedbg";
            EnableDisableBtn("btnUpdate_" + id, false);
            oldId = id;
        }
    </script>
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">SETUP PROCESS</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Exchange Rate </a></li>
                            <li class="active"><a href="List.aspx">Rate Mask Setup Transaction</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Rate Mask Setup</a></li>
                    <li><a href="CurrencyList.aspx" target="_self">Currency Rounding Setup   </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Rate Mask List
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <table class="table table-responsive">
                                            <tr>
                                                <td>
                                                    <div id="add" runat="server" style="display: none;">
                                                        <table class="table table-responsive">
                                                            <tr>
                                                                <td valign="top">
                                                                    <asp:UpdatePanel ID="upnl1" runat="server">
                                                                        <ContentTemplate>
                                                                            <div class="cols-md-12">
                                                                                <table border="0" cellspacing="0" cellpadding="0" class="table">

                                                                                    <tr>
                                                                                        <td colspan="6">
                                                                                            <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label></td>
                                                                                    </tr>
                                                                                    <colgroup>
                                                                                        <col span="6" />
                                                                                        <tr class="hdtitle">
                                                                                            <td class="hdtitle" nowrap="nowrap" rowspan="2"><span class="errormsg">*</span>Base Currency</td>
                                                                                            <td class="hdtitle" nowrap="nowrap" rowspan="2"><span class="errormsg">*</span>Quote Currency</td>
                                                                                            <td class="hdtitle" colspan="2" nowrap="nowrap">Multiplication</td>
                                                                                            <td class="hdtitle" colspan="2">Send</td>
                                                                                            <td class="hdtitle" colspan="2">Receive</td>
                                                                                            <td class="hdtitle" nowrap="nowrap" rowspan="2"></td>
                                                                                        </tr>
                                                                                        <tr>

                                                                                            <td class="hdtitle" align="left" nowrap="nowrap"><span class="errormsg">*</span>Before Decimal
                                                                                            </td>
                                                                                            <td class="hdtitle" align="left" nowrap="nowrap"><span class="errormsg">*</span>After Decimal
                                                                                            </td>
                                                                                            <td class="hdtitle" align="left" nowrap="nowrap">Min Rate
                                                                                            </td>
                                                                                            <td class="hdtitle" align="left" nowrap="nowrap">Max Rate
                                                                                            </td>
                                                                                            <td class="hdtitle" align="left" nowrap="nowrap">Min Rate
                                                                                            </td>
                                                                                            <td class="hdtitle" align="left" nowrap="nowrap">Max Rate
                                                                                            </td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td nowrap="nowrap">
                                                                                                <asp:DropDownList ID="baseCurrency" runat="server" CssClass="form-control" MaxLength="1">
                                                                                                </asp:DropDownList>
                                                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server"
                                                                                                    ControlToValidate="baseCurrency" Display="Dynamic" ErrorMessage="Required"
                                                                                                    ForeColor="Red" SetFocusOnError="True" ValidationGroup="agent">
                                                                                                </asp:RequiredFieldValidator>
                                                                                            </td>
                                                                                            <td nowrap="nowrap">
                                                                                                <asp:DropDownList ID="currency" runat="server" CssClass="form-control" MaxLength="1">
                                                                                                </asp:DropDownList>
                                                                                                <asp:RequiredFieldValidator ID="rv1" runat="server"
                                                                                                    ControlToValidate="currency" Display="Dynamic" ErrorMessage="Required"
                                                                                                    ForeColor="Red" SetFocusOnError="True" ValidationGroup="agent">
                                                                                                </asp:RequiredFieldValidator>
                                                                                            </td>
                                                                                            <td nowrap="nowrap">
                                                                                                <asp:TextBox ID="mulBd" runat="server" CssClass="form-control" TabIndex="1"
                                                                                                    MaxLength="1"></asp:TextBox>
                                                                                                <asp:RangeValidator ID="RangeValidator2" runat="server"
                                                                                                    ErrorMessage="Value between 0 to 9!" ControlToValidate="mulBd"
                                                                                                    Display="Dynamic" MaximumValue="9" MinimumValue="0" SetFocusOnError="True"
                                                                                                    Type="Double" ValidationGroup="agent" ForeColor="Red"></asp:RangeValidator>
                                                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server"
                                                                                                    ControlToValidate="mulBd" Display="Dynamic" ErrorMessage="Required!"
                                                                                                    ForeColor="Red" ValidationGroup="agent">
                                                                                                </asp:RequiredFieldValidator>
                                                                                            </td>
                                                                                            <td nowrap="nowrap">
                                                                                                <asp:TextBox ID="mulAd" runat="server" CssClass="form-control" TabIndex="1"
                                                                                                    MaxLength="1"></asp:TextBox>
                                                                                                <asp:RangeValidator ID="RangeValidator1" runat="server"
                                                                                                    ErrorMessage="Value between 0 to 9!" ControlToValidate="mulAd"
                                                                                                    Display="Dynamic" MaximumValue="9" MinimumValue="0" SetFocusOnError="True"
                                                                                                    Type="Double" ValidationGroup="agent" ForeColor="Red"></asp:RangeValidator>
                                                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server"
                                                                                                    ControlToValidate="mulAd" Display="Dynamic" ErrorMessage="Required!"
                                                                                                    ForeColor="Red" ValidationGroup="agent">
                                                                                                </asp:RequiredFieldValidator>
                                                                                            </td>
                                                                                            <td>
                                                                                                <asp:TextBox ID="cMin" runat="server" CssClass="form-control"></asp:TextBox>
                                                                                            </td>
                                                                                            <td>
                                                                                                <asp:TextBox ID="cMax" runat="server" CssClass="form-control"></asp:TextBox>
                                                                                            </td>
                                                                                            <td>
                                                                                                <asp:TextBox ID="pMin" runat="server" CssClass="form-control"></asp:TextBox>
                                                                                            </td>
                                                                                            <td>
                                                                                                <asp:TextBox ID="pMax" runat="server" CssClass="form-control"></asp:TextBox>
                                                                                            </td>
                                                                                            <td nowrap="nowrap" valign="middle">&nbsp;<asp:Button ID="btnSave" runat="server" CssClass="btn btn-primary" Style="padding: 5px;"
                                                                                                OnClick="btnSave_Click" Text="Add" ValidationGroup="agent" />
                                                                                            </td>
                                                                                        </tr>

                                                                                        <caption>

                                                                                            <tr>
                                                                                                <td colspan="6">

                                                                                                    <asp:Button ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" Style="display: none;" />
                                                                                                    <asp:HiddenField ID="ratemaskId" runat="server" />
                                                                                                    <asp:HiddenField ID="hdnratemaskId" runat="server" />
                                                                                                    <asp:HiddenField ID="hdncurrency" runat="server" />
                                                                                                    <asp:HiddenField ID="hdnfactor" runat="server" />
                                                                                                    <asp:HiddenField ID="hdnmulBd" runat="server" />
                                                                                                    <asp:HiddenField ID="hdnmulAd" runat="server" />
                                                                                                    <asp:HiddenField ID="hdndivBd" runat="server" />
                                                                                                    <asp:HiddenField ID="hdndivAd" runat="server" />
                                                                                                    <asp:HiddenField ID="hdnCMin" runat="server" />
                                                                                                    <asp:HiddenField ID="hdnCMax" runat="server" />
                                                                                                    <asp:HiddenField ID="hdnPMin" runat="server" />
                                                                                                    <asp:HiddenField ID="hdnPMax" runat="server" />
                                                                                                </td>
                                                                                            </tr>

                                                                                            <tr>
                                                                                                <td class="style2" colspan="3"></td>
                                                                                                <td colspan="3" nowrap="nowrap">
                                                                                                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                                                                        ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                                                                    </cc1:ConfirmButtonExtender>
                                                                                                </td>
                                                                                            </tr>
                                                                                        </caption>
                                                                                    </colgroup>
                                                                                </table>
                                                                            </div>
                                                                        </ContentTemplate>
                                                                        <Triggers>
                                                                        </Triggers>
                                                                    </asp:UpdatePanel>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <table class="table table-responsive">
                                                        <tr>
                                                            <td class="GridTextNormal"><b>Filtered results</b>&nbsp;&nbsp;&nbsp;<a href="javascript:newTableToggle('td_Search', 'img_Search');">
                                                                <img src="../../../images/icon_show.gif" border="0" alt="Show" id="img_Search"></a>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td id="td_Search" style="display: none">
                                                                <table class="table table-responsive">
                                                                    <tr>
                                                                        <td align="right" class="text_form" nowrap="nowrap">
                                                                            <label>Currency :</label>
                                                                        </td>
                                                                        <td>
                                                                            <asp:TextBox ID="currencyFilter" runat="server" CssClass="form-control" Width="100px"></asp:TextBox></td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td align="right" class="text_form">&nbsp;</td>
                                                                        <td colspan="3">
                                                                            <input type="button" value="Filter" class="btn btn-primary" onclick="submit_form();">
                                                                            <input type="button" value="Clear Filter" class="btn btn-primary" onclick="clearForm();">
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div id="paginDiv" runat="server"></div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div id="rpt_grid" runat="server" enableviewstate="false"></div>
                                                </td>
                                            </tr>
                                        </table>
                                        <asp:Button ID="btnHidden" runat="server" OnClick="btnHidden_Click" Style="display: none" />
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
<script language="javascript">
    function ShowDiv() {
        var addDisplay = document.getElementById("add");
        var style = addDisplay.style.display == "none" ? "block" : "none";
        addDisplay.style.display = style;
        window.parent.resizeIframe();
    }
</script>