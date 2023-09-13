<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Commission.CommissionDomestic.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>

    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
</head>
<script>
    function LoadCalendars() {

        EffectiveTo("#<% =effectiveTo.ClientID%>");
             EffectiveTo("#<% =effectiveFrom.ClientID%>");
         }
         LoadCalendars();

         function EffectiveTo(cal) {
             $(function () {
                 $(cal).datepicker({
                     changeMonth: true,
                     changeYear: true,
                     showOn: "both",
                 });
             });
         }
</script>
<style>
    .table .table {
        background-color: #F5F5F5 !important;
    }

    .textbox {
        width: 55px;
        font-size: 11px;
        text-align: right;
    }

    .textboxSmall {
        width: 45px;
        font-size: 11px;
        text-align: right;
    }

    .textboxPcnt {
        width: 35px;
        font-size: 11px;
        text-align: right;
    }
</style>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('servicecharge_and_commission')">Service Charge and Comission </a></li>
                            <li class="active"><a href="Manage.aspx">Domestic Commission</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="List.aspx">Main</a></li>
                    <li class="active"><a target="_self" href="#" class="selected">Detail </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Send Commission Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <table class="table table-responsive">
                                        <tr>
                                            <td valign="top">
                                                <asp:UpdatePanel ID="upnl1" runat="server">
                                                    <ContentTemplate>
                                                        <table class="table table-responsive">
                                                            <tr>
                                                                <td colspan="3">
                                                                    <table class="table table-responsive">
                                                                        <tr>
                                                                            <td>Code :</td>
                                                                            <td>
                                                                                <asp:TextBox ID="code" runat="server" CssClass="form-control" TabIndex="1"></asp:TextBox>
                                                                            </td>
                                                                            <td>Description :</td>
                                                                            <td>
                                                                                <asp:TextBox ID="description" runat="server" CssClass="form-control" TabIndex="2"></asp:TextBox>
                                                                            </td>
                                                                            <td class="frmLable">Active :</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="isEnable" runat="server" CssClass="form-control" TabIndex="11">
                                                                                    <asp:ListItem Value="Y" Selected="True">Yes</asp:ListItem>
                                                                                    <asp:ListItem Value="N">No</asp:ListItem>
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td valign="top">
                                                                    <table class="table table-responsive">
                                                                        <tr>
                                                                            <th colspan="2" align="left">Sending</th>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable" nowrap="nowrap">Agent:</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="sAgent" runat="server" AutoPostBack="true" TabIndex="3"
                                                                                    CssClass="form-control" OnSelectedIndexChanged="sAgent_SelectedIndexChanged">
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                            <td class="frmLable">State:</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="sState" runat="server" CssClass="form-control" TabIndex="5"></asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable">Branch:</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="sBranch" runat="server" CssClass="form-control" TabIndex="4"></asp:DropDownList>
                                                                            </td>
                                                                            <td class="frmLable">Group:</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="sGroup" runat="server" CssClass="form-control" TabIndex="6"></asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td></td>
                                                                            <td colspan="3">
                                                                                <asp:Button ID="btnSubmit" runat="server" Text="Save" CssClass="button"
                                                                                    ValidationGroup="commission" Display="Dynamic" TabIndex="16"
                                                                                    OnClick="btnSubmit_Click" />
                                                                                <cc1:ConfirmButtonExtender ID="btnSavecc" runat="server"
                                                                                    ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSubmit">
                                                                                </cc1:ConfirmButtonExtender>
                                                                                &nbsp; 
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td valign="top">
                                                                    <table class="table table-responsive">
                                                                        <tr>
                                                                            <th colspan="2" align="left">Receiving</th>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable" nowrap="nowrap">Agent:</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="rAgent" runat="server" AutoPostBack="true" TabIndex="7"
                                                                                    CssClass="form-control" OnSelectedIndexChanged="rAgent_SelectedIndexChanged">
                                                                                </asp:DropDownList>
                                                                            </td>
                                                                            <td>State :</td>
                                                                            <td nowrap="nowrap">
                                                                                <asp:DropDownList ID="rState" runat="server" CssClass="form-control" TabIndex="9"></asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable">Branch:</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="rBranch" runat="server" CssClass="form-control" TabIndex="7"></asp:DropDownList>
                                                                            </td>
                                                                            <td class="frmLable">Group :</td>
                                                                            <td nowrap="nowrap">
                                                                                <asp:DropDownList ID="rGroup" runat="server" CssClass="form-control" TabIndex="10"></asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td valign="top">
                                                                    <table class="table table-responsive">
                                                                        <tr>
                                                                            <td>&nbsp;</td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable">Effective From :</td>
                                                                            <td>
                                                                                <asp:TextBox ID="effectiveFrom" runat="server" CssClass="form-control" TabIndex="12"></asp:TextBox>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable">Effective To:</td>
                                                                            <td>
                                                                                <asp:TextBox ID="effectiveTo" runat="server" CssClass="form-control" TabIndex="13"></asp:TextBox>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable">Transaction Type :</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="tranType" runat="server" CssClass="form-control" TabIndex="14"></asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td class="frmLable">Commission Base :</td>
                                                                            <td>
                                                                                <asp:DropDownList ID="commissionBase" runat="server" CssClass="form-control" TabIndex="15"></asp:DropDownList>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </ContentTemplate>
                                                    <Triggers>
                                                    </Triggers>
                                                </asp:UpdatePanel>
                                            </td>
                                        </tr>
                                    </table>
                                    <table class="table table-responsive">
                                        <tr>
                                            <td>
                                                <table id="tblCopySlab" runat="server" visible="false" class="table table-responsive">
                                                    <tr>
                                                        <td>Copy Amount Slab From :
                                                            <asp:DropDownList ID="commissionSlab" runat="server" CssClass="form-control" AutoPostBack="true"
                                                                OnSelectedIndexChanged="commissionSlab_SelectedIndexChanged">
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                </table>
                                                <table class="table table-responsive">
                                                    <tr>
                                                        <td>
                                                            <div id="divSlabgrid" runat="server" visible="false">
                                                                <div id="rpt_slabgrid" runat="server" class="gridDiv"></div>
                                                                <asp:Button ID="btnCopySlab" runat="server" Text="Copy Slab" CssClass="button" OnClick="btnCopySlab_Click" />
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                    <div style="overflow: auto;">
                                        <table class="table table-responsive">
                                            <tr>
                                                <td>
                                                    <table class="table table-responsive" id="amountSlab" runat="server" visible="false">
                                                        <tr>
                                                            <td>
                                                                <asp:UpdatePanel ID="upnl2" runat="server">
                                                                    <ContentTemplate>
                                                                        <asp:HiddenField ID="hddScDetailId" runat="server" />
                                                                        <asp:Button ID="btnEditDetail" runat="server" OnClick="btnEditDetail_Click" Style="display: none;" />
                                                                        <asp:Button ID="btnDeleteDetail" runat="server" OnClick="btnDeleteDetail_Click" Style="display: none;" />
                                                                        <asp:HiddenField ID="fromAmt" runat="server" />
                                                                        <asp:HiddenField ID="toAmt" runat="server" />
                                                                        <asp:HiddenField ID="serviceChargePcnt" runat="server" />
                                                                        <asp:HiddenField ID="serviceChargeMinAmt" runat="server" />
                                                                        <asp:HiddenField ID="serviceChargeMaxAmt" runat="server" />
                                                                        <asp:HiddenField ID="sAgentCommPcnt" runat="server" />
                                                                        <asp:HiddenField ID="sAgentCommMinAmt" runat="server" />
                                                                        <asp:HiddenField ID="sAgentCommMaxAmt" runat="server" />
                                                                        <asp:HiddenField ID="ssAgentCommPcnt" runat="server" />
                                                                        <asp:HiddenField ID="ssAgentCommMinAmt" runat="server" />
                                                                        <asp:HiddenField ID="ssAgentCommMaxAmt" runat="server" />
                                                                        <asp:HiddenField ID="pAgentCommPcnt" runat="server" />
                                                                        <asp:HiddenField ID="pAgentCommMinAmt" runat="server" />
                                                                        <asp:HiddenField ID="pAgentCommMaxAmt" runat="server" />
                                                                        <asp:HiddenField ID="psAgentCommPcnt" runat="server" />
                                                                        <asp:HiddenField ID="psAgentCommMinAmt" runat="server" />
                                                                        <asp:HiddenField ID="psAgentCommMaxAmt" runat="server" />
                                                                        <asp:HiddenField ID="bankCommPcnt" runat="server" />
                                                                        <asp:HiddenField ID="bankCommMinAmt" runat="server" />
                                                                        <asp:HiddenField ID="bankCommMaxAmt" runat="server" />
                                                                        <asp:Button ID="btnSave" runat="server" CssClass="button" Text="Save" Style="display: none"
                                                                            OnClick="btnSave_Click" />&nbsp;&nbsp;
                                                                        <asp:Button ID="btnAddNew" runat="server" CssClass="button" Text="Add new" Style="display: none"
                                                                            OnClick="btnAddNew_Click" />
                                                                    </ContentTemplate>
                                                                    <Triggers>
                                                                        <asp:AsyncPostBackTrigger ControlID="btnEditDetail" EventName="Click" />
                                                                    </Triggers>
                                                                </asp:UpdatePanel>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <table class="table table-responsive">
                                                        <tr>
                                                            <td>
                                                                <asp:UpdatePanel ID="upnl3" runat="server">
                                                                    <ContentTemplate>
                                                                        <div id="rpt_grid" runat="server" class="gridDiv" style="margin-left: 0px;"></div>
                                                                    </ContentTemplate>
                                                                    <Triggers>
                                                                        <asp:AsyncPostBackTrigger ControlID="btnSave" EventName="Click" />
                                                                        <asp:AsyncPostBackTrigger ControlID="btnCopySlab" EventName="Click" />
                                                                        <asp:AsyncPostBackTrigger ControlID="btnDeleteDetail" EventName="Click" />
                                                                    </Triggers>
                                                                </asp:UpdatePanel>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
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
<script type="text/javascript">
    var gridName = "<% =GridName%>";
    function NewRecord() {
        ClearAll(gridName);
        GetElement("toAmt1").focus();
    }
    function ShowHide(me, obj) {
        var spn = GetElement(me);
        var tbl = GetElement(obj);
        if (tbl.style.display == "block") {
            tbl.style.display = "none";
            spn.value = "+";
        }
        else {
            tbl.style.display = "block";
            spn.value = "-";
        }
    }
    function EditSelected(me, gridName, id) {
        var elements = document.getElementsByName(gridName + "_rowId");
        SetValueById("<%=hddScDetailId.ClientID %>", id, "");
        for (var i = 0; i < elements.length; i++) {
            elements[i].checked = false;
        }
        me.checked = true;
        GetElement("<%=btnEditDetail.ClientID %>").click();
    }
    function DeleteCommissionDetail(id) {
        if (confirm("Are you sure you want to delete this record?")) {
            SetValueById("<%=hddScDetailId.ClientID %>", id, "");
            GetElement("<%=btnDeleteDetail.ClientID %>").click();
        }
    }
    function ManageDetail1(pcntId, minAmtId, maxAmtId) {
        var pcnt = GetValue(pcntId);
        var minAmt = GetValue(minAmtId);
        if (parseFloat(pcnt) == 0) {
            GetElement(maxAmtId).disabled = true;
            SetValueById(maxAmtId, minAmt, "");
        }
        else
            GetElement(maxAmtId).disabled = false;
    }
    function ManageDetail2(pcntId, minAmtId, maxAmtId) {
        var minAmt = GetValue(minAmtId);
        if (GetElement(maxAmtId).disabled == true) {
            SetValueById(maxAmtId, minAmt, "");
        }
    }
    function ClearSelection(gridName) {
        var elements = document.getElementsByName(gridName + "_rowId");
        SetValueById("<%=hddScDetailId.ClientID %>", "", "");
        for (var i = 0; i < elements.length; i++) {
            elements[i].checked = false;
        }
        GetElement("<%=btnAddNew.ClientID %>").click();
    }

    function Save() {
        if (GetValue("fromAmt1") == "") {
            window.parent.SetMessageBox('Enter From Amount', '1');
            return;
        }
        if (GetValue("toAmt1") == "") {
            window.parent.SetMessageBox('Enter To Amount', '1');
            return;
        }
        SetValueById("<%=fromAmt.ClientID %>", GetValue("fromAmt1"), "");
        SetValueById("<%=toAmt.ClientID %>", GetValue("toAmt1"), "");
        SetValueById("<%=serviceChargePcnt.ClientID %>", GetValue("serviceChargePcnt1"), "");
        SetValueById("<%=serviceChargeMinAmt.ClientID %>", GetValue("serviceChargeMinAmt1"), "");
        SetValueById("<%=serviceChargeMaxAmt.ClientID %>", GetValue("serviceChargeMaxAmt1"), "");
        SetValueById("<%=sAgentCommPcnt.ClientID %>", GetValue("sAgentCommPcnt1"), "");
        SetValueById("<%=sAgentCommMinAmt.ClientID %>", GetValue("sAgentCommMinAmt1"), "");
        SetValueById("<%=sAgentCommMaxAmt.ClientID %>", GetValue("sAgentCommMaxAmt1"), "");
        SetValueById("<%=ssAgentCommPcnt.ClientID %>", GetValue("ssAgentCommPcnt1"), "");
        SetValueById("<%=ssAgentCommMinAmt.ClientID %>", GetValue("ssAgentCommMinAmt1"), "");
        SetValueById("<%=ssAgentCommMaxAmt.ClientID %>", GetValue("ssAgentCommMaxAmt1"), "");
        SetValueById("<%=pAgentCommPcnt.ClientID %>", GetValue("pAgentCommPcnt1"), "");
        SetValueById("<%=pAgentCommMinAmt.ClientID %>", GetValue("pAgentCommMinAmt1"), "");
        SetValueById("<%=pAgentCommMaxAmt.ClientID %>", GetValue("pAgentCommMaxAmt1"), "");
        SetValueById("<%=psAgentCommPcnt.ClientID %>", GetValue("psAgentCommPcnt1"), "");
        SetValueById("<%=psAgentCommMinAmt.ClientID %>", GetValue("psAgentCommMinAmt1"), "");
        SetValueById("<%=psAgentCommMaxAmt.ClientID %>", GetValue("psAgentCommMaxAmt1"), "");
        SetValueById("<%=bankCommPcnt.ClientID %>", GetValue("bankCommPcnt1"), "");
        SetValueById("<%=bankCommMinAmt.ClientID %>", GetValue("bankCommMinAmt1"), "");
        SetValueById("<%=bankCommMaxAmt.ClientID %>", GetValue("bankCommMaxAmt1"), "");
        GetElement("<%=btnSave.ClientID %>").click();
    }
    function PopulateDataById() {
        SetValueById("fromAmt1", GetValue("<%=fromAmt.ClientID %>"), "");
        SetValueById("toAmt1", GetValue("<%=toAmt.ClientID %>"), "");
        SetValueById("serviceChargePcnt1", GetValue("<%=serviceChargePcnt.ClientID %>"), "");
        SetValueById("serviceChargeMinAmt1", GetValue("<%=serviceChargeMinAmt.ClientID %>"), "");
        SetValueById("serviceChargeMaxAmt1", GetValue("<%=serviceChargeMaxAmt.ClientID %>"), "");
        SetValueById("sAgentCommPcnt1", GetValue("<%=sAgentCommPcnt.ClientID %>"), "");
        SetValueById("sAgentCommMinAmt1", GetValue("<%=sAgentCommMinAmt.ClientID %>"), "");
        SetValueById("sAgentCommMaxAmt1", GetValue("<%=sAgentCommMaxAmt.ClientID %>"), "");
        SetValueById("ssAgentCommPcnt1", GetValue("<%=ssAgentCommPcnt.ClientID %>"), "");
        SetValueById("ssAgentCommMinAmt1", GetValue("<%=ssAgentCommMinAmt.ClientID %>"), "");
        SetValueById("ssAgentCommMaxAmt1", GetValue("<%=ssAgentCommMaxAmt.ClientID %>"), "");
        SetValueById("pAgentCommPcnt1", GetValue("<%=pAgentCommPcnt.ClientID %>"), "");
        SetValueById("pAgentCommMinAmt1", GetValue("<%=pAgentCommMinAmt.ClientID %>"), "");
        SetValueById("pAgentCommMaxAmt1", GetValue("<%=pAgentCommMaxAmt.ClientID %>"), "");
        SetValueById("psAgentCommPcnt1", GetValue("<%=psAgentCommPcnt.ClientID %>"), "");
        SetValueById("psAgentCommMinAmt1", GetValue("<%=psAgentCommMinAmt.ClientID %>"), "");
        SetValueById("psAgentCommMaxAmt1", GetValue("<%=psAgentCommMaxAmt.ClientID %>"), "");
        SetValueById("bankCommPcnt1", GetValue("<%=bankCommPcnt.ClientID %>"), "");
        SetValueById("bankCommMinAmt1", GetValue("<%=bankCommMinAmt.ClientID %>"), "");
        SetValueById("bankCommMaxAmt1", GetValue("<%=bankCommMaxAmt.ClientID %>"), "");
    }
    PopulateDataById();
</script>
</html>
