<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TpApiRateSetupList.aspx.cs" Inherits="Swift.web.Remit.TPSetup.TpApiRateSetup.TpApiRateSetup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/css/rateCss.css" rel="stylesheet" type="text/css" />
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }

        .exTable tr td .inputBox {
            width: 45px;
        }

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

        .responsive-table {
            overflow: auto;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {


        });

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
        var oldId = 0;
        function KeepRowSelection(id, row_id) {
            if (oldId != 0 && oldId != id) {
                //var j = GetValue(oldId);
                //if (j % 2 == 1)
                //    GetElement("row_" + oldId).className = "oddbg";
                //else
                //    GetElement("row_" + oldId).className = "evenbg";
                EnableDisableBtn("btnUpdate_" + oldId, true);
            }
            GetElement("row_" + id).className = "selectedbg";
            EnableDisableBtn("btnUpdate_" + id, false);
            oldId = id;
        }
        function UpdateRate(id, rowId) {
            if (confirm("Are you sure you want to update this record?")) {
                SetValueById("<%=settlementRate.ClientID %>", GetValue("settlementRate_" + id), "");
                SetValueById("<%=jmeMarginRate.ClientID %>", GetValue("jmeMarginRate_" + id), "");
                SetValueById("<%=rateMarginOverPartnerRate.ClientID %>", GetValue("rateMarginOverPartnerRate_" + id), "");
                SetValueById("<%=partnerCustomerRate.ClientID %>", GetValue("partnerCustomerRate_" + id), "");
                SetValueById("<%=overrideCustomerRate.ClientID %>", GetValue("overrideCustomerRate_" + id), "");
                var isChecked = "N";
                if ($('#' + 'isActive_' + id + ':checkbox:checked').length > 0) {
                    isChecked = "Y";
                }
                SetValueById("<%=isActive.ClientID %>", isChecked, "");
                SetValueById("<%=rowId.ClientID %>", rowId, "");
                GetElement("<%=btnUpdate.ClientID %>").click();
            }
        }

        function isNumberKey(evt, marginValue) {
            var charCode = (evt.which) ? evt.which : event.keyCode
            if (charCode > 31 && (charCode != 46 && (charCode < 48 || charCode > 57)))
                return false;
            return true;
        }
        function marginChanged(marginValue, id) {
            var settlementRate = GetValue("settlementRate_" + id);
            var changedMarginValue = Math.round(marginValue * settlementRate * 10000) / 10000;
            document.getElementById("rateMarginOverPartnerRate_" + id).value = changedMarginValue;
            rateMarginOverChanged(changedMarginValue, id);

        }
        function rateMarginOverChanged(rateOverMargin, id) {
            var settlementRate = GetValue("settlementRate_" + id);
            var jmeMargin = Math.round((rateOverMargin / settlementRate) * 10000) / 10000;
            document.getElementById("jmeMarginRate_" + id).value = jmeMargin;
            document.getElementById("partnerCustomerRate_" + id).value = Math.round((settlementRate - rateOverMargin) * 10000)/10000 ;

        }
        function settlementChanged(settlementvalue, id) {
            var jmeMarginValue = GetValue("jmeMarginRate_" + id);
            var changedmarginValueOverTf = jmeMarginValue * settlementvalue;
            document.getElementById("rateMarginOverPartnerRate_" + id).value = changedmarginValueOverTf;
            var changedCustomerRate = settlementvalue - changedmarginValueOverTf;
            document.getElementById("partnerCustomerRate_" + id).value = changedCustomerRate;
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
                            <li class="active"><a href="TpApiRateSetupList.aspx">ThirdParty ExRate Setup</a></li>
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
                                    <h4 class="panel-title">Third Party Ex-Rate Setup List
                                    </h4>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <table class="table table-responsive">
                                            <tr>
                                                <td class="GridTextNormal"><b>Filtered results</b>&nbsp;&nbsp;&nbsp;
                                                               <a href="javascript:newTableToggle('td_Search', 'img_Search');">
                                                                   <img src="../../../images/icon_show.gif" border="0" alt="Show" id="img_Search"></a>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td id="td_Search" style="display: none">
                                                    <table class="table table-responsive">
                                                        <tr>
                                                            <td style="display: none" align="right" class="text_form" nowrap="nowrap">
                                                                <label>Currency : </label>
                                                            </td>
                                                            <td style="display: none">
                                                                <asp:TextBox ID="currency" runat="server" CssClass="form-control"></asp:TextBox></td>
                                                            <td align="right" class="text_form" nowrap="nowrap">
                                                                <label>Country : </label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="country" runat="server" CssClass="form-control"></asp:TextBox></td>
                                                        </tr>
                                                        <tr>
                                                            <td align="right" class="text_form" nowrap="nowrap">
                                                                <label>Partner : </label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="agent" runat="server" CssClass="form-control"></asp:TextBox></td>
                                                            <td>&nbsp;</td>
                                                            <td>&nbsp;</td>
                                                        </tr>
                                                        <tr>
                                                            <td align="right" class="text_form">&nbsp;</td>
                                                            <td colspan="3">
                                                                <input type="button" value="Filter" class="btn btn-primary m-t-25" onclick="submit_form();" />
                                                                <input type="button" value="Clear Filter" class="btn btn-primary m-t-25" onclick="clearForm();" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                        <div id="paginDiv" runat="server"></div>
                                        <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false">
                                        </div>
                                        <asp:Button ID="btnMarkInactive" runat="server" CssClass="btn btn-primary m-t-25" Text="Set Inactive" Visible="false"
                                            OnClick="btnMarkInactive_Click" />
                                        <asp:Button ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" Style="display: none;" />
                                        <asp:HiddenField ID="settlementRate" runat="server" />
                                        <asp:HiddenField ID="jmeMarginRate" runat="server" />
                                        <asp:HiddenField ID="rateMarginOverPartnerRate" runat="server" />
                                        <asp:HiddenField ID="partnerCustomerRate" runat="server" />
                                        <asp:HiddenField ID="rowId" runat="server" />
                                        <asp:HiddenField ID="overrideCustomerRate" runat="server" />
                                        <asp:HiddenField ID="isActive" runat="server" />
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
