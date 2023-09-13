<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.ExchangeRate.CrossRateDecimalMask.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />

    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>

    <script type="text/javascript">
        var gridName = "<% =GridName%>";

        function Update(id) {
            if (confirm("Are you sure to update this record?")) {
                SetValueById("<%=hdnCrdmId.ClientID %>", id, "");
                SetValueById("<%=hdnRateMaskAd.ClientID %>", GetValue("rateMaskAd_" + id), "");
                SetValueById("<%=hdnDisplayUnit.ClientID %>", GetValue("displayUnit_" + id), "");
                GetElement("<%=btnUpdate.ClientID %>").click();
            }
        }

        function ResetForm() {
            SetValueById("<% =cCurrency.ClientID%>", "");
            SetValueById("<% =pCurrency.ClientID%>", "");
            SetValueById("<% =rateMaskAd.ClientID %>", "");
            SetValueById("<% =displayUnit.ClientID %>", "");
        }

        function NewRecord() {
            ResetForm();
            SetValueById("<% =hdnCrdmId.ClientID%>", "0");
            ClearAll(gridName);
        }

        function submit_form() {
            var btn = document.getElementById("<%=btnHidden.ClientID %>");
            if (btn != null)
                btn.click();
        }
        function clearForm() {
            var btn = document.getElementById("<%=btnHidden.ClientID %>");
            document.getElementById("<%=cCurrencyFilter.ClientID %>").value = "";
            document.getElementById("<%=pCurrencyFilter.ClientID %>").value = "";
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
                            <li class="active"><a href="List.aspx">Cross Rate Decimal Masking</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Cross Rate Decimal Masking List
                            </h4>
                            <div class="panel-actions">
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <table class="table table-responsive">
                                    <tr>
                                        <td>
                                            <asp:HiddenField ID="hdnCrdmId" runat="server" />
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td valign="top">
                                                        <label>Send Currency</label>

                                                        <br />
                                                        <asp:DropDownList ID="cCurrency" runat="server" CssClass="form-control" Width="100px"></asp:DropDownList>
                                                    </td>
                                                    <td valign="top">
                                                        <label>Receive Currency</label>
                                                        <span class="ErrMsg">*</span>
                                                        <br />
                                                        <asp:DropDownList ID="pCurrency" runat="server" CssClass="form-control" Width="100px"></asp:DropDownList>
                                                        <br />
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="pCurrency"
                                                            ForeColor="Red" Display="Dynamic" ErrorMessage="Required" ValidationGroup="crossRateDecimalMask"
                                                            SetFocusOnError="True">
                                                        </asp:RequiredFieldValidator>
                                                    </td>
                                                    <td valign="top">
                                                        <label>After Decimal Value</label>
                                                        <span class="ErrMsg">*</span>
                                                        <br />
                                                        <asp:TextBox ID="rateMaskAd" runat="server" CssClass="form-control" Width="100px"></asp:TextBox>
                                                        <br />
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="rateMaskAd"
                                                            ForeColor="Red" Display="Dynamic" ErrorMessage="Required" ValidationGroup="crossRateDecimalMask"
                                                            SetFocusOnError="True">
                                                        </asp:RequiredFieldValidator>
                                                    </td>
                                                    <td valign="top">
                                                        <label>Display Unit</label>
                                                        <span class="ErrMsg">*</span>
                                                        <br />
                                                        <asp:TextBox ID="displayUnit" runat="server" CssClass="form-control" Width="100px"></asp:TextBox>
                                                        <br />
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="rateMaskAd"
                                                            ForeColor="Red" Display="Dynamic" ErrorMessage="Required" ValidationGroup="crossRateDecimalMask"
                                                            SetFocusOnError="True">
                                                        </asp:RequiredFieldValidator>
                                                    </td>
                                                    <td>
                                                        <asp:Button ID="btnAdd" CssClass="btn btn-primary m-t-25" runat="server" Text="Add" ValidationGroup="crossRateDecimalMask" OnClick="btnAdd_Click" Style="margin-top: 15px;" />
                                                        <input type="button" value="New" onclick="NewRecord(); " class="btn btn-primary m-t-25" style="margin-top: 15px;" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td class="GridTextNormal"><b>Filtered results</b>
                                                        <a href="javascript:newTableToggle('td_Search', 'img_Search');">
                                                            <img src="../../../images/icon_show.gif" border="0" alt="Show" id="img_Search"></a>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td id="td_Search" style="display: none">
                                                        <table class="table table-responsive">
                                                            <tr>
                                                                <td style="width: 15%" class="text_form" nowrap="nowrap">
                                                                    <label>Send Currency : </label>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="cCurrencyFilter" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td style="width: 15%" class="text_form" nowrap="nowrap">
                                                                    <label>Receive Currency :</label>
                                                                </td>
                                                                <td>
                                                                    <asp:TextBox ID="pCurrencyFilter" runat="server" CssClass="form-control"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td align="right" class="text_form">&nbsp;</td>
                                                                <td colspan="3">
                                                                    <input type="button" value="Filter" class="btn btn-primary m-t-25" onclick="submit_form();">
                                                                    <input type="button" value="Clear Filter" class="btn btn-primary m-t-25" onclick="clearForm();">
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            <asp:HiddenField ID="hdnRateMaskAd" runat="server" />
                                            <asp:HiddenField ID="hdnDisplayUnit" runat="server" />
                                            <asp:Button ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" Style="display: none;" />
                                            <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>