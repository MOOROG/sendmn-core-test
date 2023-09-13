<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Commission.CommissionAgent.Send.Manage" %>


<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>

    <link href="/css/style.css" rel="stylesheet" type="text/css" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript">
        function LoadCalendars() {
            ShowCalDefault("#<% =effectiveTo.ClientID%>");
            ShowCalDefault("#<% =effectiveFrom.ClientID%>");
        }
        LoadCalendars();

        function PopulateDataById() {
            SetValueById("fromAmt1", GetValue("<%=fromAmt.ClientID %>"), "");
            SetValueById("toAmt1", GetValue("<%=toAmt.ClientID %>"), "");
            SetValueById("pcnt1", GetValue("<%=pcnt.ClientID %>"), "");
            SetValueById("minAmt1", GetValue("<%=minAmt.ClientID %>"), "");
            SetValueById("maxAmt1", GetValue("<%=maxAmt.ClientID %>"), "");
            LoadCalendars();

        }
        PopulateDataById();
    </script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active">Send Commission Setup - Custom </li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a target="_self" href="List.aspx">Main </a></li>
                    <li class="active"><a target="_self" href="#" class="selected">Detail</a></li>
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
                                    <div class="row">
                                        <div class="table table-responisve">
                                            <div class="table table-responsive">
                                                <tr>
                                                    <td>
                                                        <asp:UpdatePanel ID="upnl1" runat="server">
                                                            <ContentTemplate>
                                                                <table class="table table-responsive">
                                                                    <tr>
                                                                        <td colspan="3">
                                                                            <table class="table table-responsive">
                                                                                <tr>
                                                                                    <td>Code :</td>
                                                                                    <td>
                                                                                        <asp:TextBox ID="code" runat="server" TabIndex="10" CssClass="form-control"></asp:TextBox>
                                                                                    </td>
                                                                                    <td>Description :</td>
                                                                                    <td>
                                                                                        <asp:TextBox ID="description" runat="server" TabIndex="20" CssClass="form-control"></asp:TextBox>
                                                                                    </td>
                                                                                    <td class="frmLable">Active :</td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="isEnable" runat="server" CssClass="form-control" TabIndex="30">
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
                                                                                    <td class="frmLable" nowrap="nowrap">Country :<span class="ErrMsg">*</span></td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="sCountry" runat="server" CssClass="form-control" AutoPostBack="true" TabIndex="40"
                                                                                            OnSelectedIndexChanged="sCountry_SelectedIndexChanged">
                                                                                        </asp:DropDownList>
                                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="sCountry"
                                                                                            Display="Dynamic" ErrorMessage="*" ValidationGroup="commission" ForeColor="Red" CssClass="ErrMsg"
                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                                    </td>
                                                                                    <td class="frmLable">State:</td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="state" runat="server" CssClass="form-control" TabIndex="80"></asp:DropDownList>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable" nowrap="nowrap">Sup Agent :</td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="ssAgent" runat="server" CssClass="form-control" AutoPostBack="true" TabIndex="50"
                                                                                            OnSelectedIndexChanged="ssAgent_SelectedIndexChanged">
                                                                                        </asp:DropDownList>
                                                                                    </td>
                                                                                    <td class="frmLable">Zip Code:</td>
                                                                                    <td>
                                                                                        <asp:TextBox ID="zipCode" runat="server" CssClass="form-control" TabIndex="90"></asp:TextBox>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable" nowrap="nowrap">Agent:</td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="sAgent" runat="server" CssClass="form-control" AutoPostBack="true" TabIndex="60"
                                                                                            OnSelectedIndexChanged="sAgent_SelectedIndexChanged">
                                                                                        </asp:DropDownList>
                                                                                    </td>
                                                                                    <td class="frmLable">Location Group:</td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="agentGroup" runat="server" CssClass="form-control" TabIndex="100"></asp:DropDownList>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable">Branch:</td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="sBranch" runat="server" CssClass="form-control" TabIndex="70"></asp:DropDownList>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td></td>
                                                                                    <td colspan="3">
                                                                                        <asp:Button ID="btnSave" runat="server" Text="Save1" CssClass="form-control"
                                                                                            ValidationGroup="commission" Display="Dynamic" TabIndex="222"
                                                                                            OnClick="btnSave_Click" />
                                                                                        <cc1:ConfirmButtonExtender ID="btnSavecc" runat="server"
                                                                                            ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
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
                                                                                    <td class="frmLable">Country :
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="rCountry" runat="server" CssClass="form-control" AutoPostBack="true" TabIndex="110"
                                                                                            OnSelectedIndexChanged="rCountry_SelectedIndexChanged">
                                                                                        </asp:DropDownList>
                                                                                    </td>
                                                                                    <td>State :</td>
                                                                                    <td nowrap="nowrap">
                                                                                        <asp:DropDownList ID="rState" CssClass="form-control" runat="server" TabIndex="150"></asp:DropDownList>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable" nowrap="nowrap">Sup Agent:
                                                                                    </td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="rsAgent" runat="server" AutoPostBack="true" TabIndex="120" CssClass="form-control"
                                                                                            OnSelectedIndexChanged="rsAgent_SelectedIndexChanged">
                                                                                        </asp:DropDownList>
                                                                                    </td>
                                                                                    <td class="frmLable">Zip Code :</td>
                                                                                    <td nowrap="nowrap">
                                                                                        <asp:TextBox ID="rZipCode" runat="server" CssClass="form-control" TabIndex="160"></asp:TextBox>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable" nowrap="nowrap">Agent:</td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="rAgent" runat="server" CssClass="form-control" AutoPostBack="true" TabIndex="130"
                                                                                            OnSelectedIndexChanged="rAgent_SelectedIndexChanged">
                                                                                        </asp:DropDownList>
                                                                                    </td>
                                                                                    <td class="frmLable">Location Group</td>
                                                                                    <td nowrap="nowrap">
                                                                                        <asp:DropDownList ID="rAgentGroup" runat="server" CssClass="form-controlFF" TabIndex="170"></asp:DropDownList>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable">Branch:</td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="rBranch" runat="server" CssClass="form-control" TabIndex="140"></asp:DropDownList>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                        <td valign="top">
                                                                            <table class="table table-responsive">
                                                                                <tr>
                                                                                    <td class="frmLable">Effective From:</td>
                                                                                    <td>
                                                                                        <asp:TextBox ID="effectiveFrom" onchange="return DateValidation('effectiveFrom')" MaxLength="10" runat="server" CssClass="form-control" TabIndex="180" autocomplete="off"></asp:TextBox>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable">Effective To:</td>
                                                                                    <td>
                                                                                        <asp:TextBox ID="effectiveTo" onchange="return DateValidation('effectiveTo')" MaxLength="10" runat="server" CssClass="form-control" TabIndex="190" autocomplete="off"></asp:TextBox>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>

                                                                                    <td class="frmLable">Base Currency :<span class="ErrMsg">*</span></td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="baseCurrency" runat="server" CssClass="form-control" TabIndex="200"></asp:DropDownList>
                                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="baseCurrency"
                                                                                            Display="Dynamic" ErrorMessage="*" ValidationGroup="commission" ForeColor="Red" CssClass="ErrMsg"
                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>

                                                                                    <td class="frmLable">Transaction Type :</td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="tranType" runat="server" CssClass="form-control" TabIndex="210"></asp:DropDownList>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="frmLable">Commission Base :<span class="ErrMsg">*</span></td>
                                                                                    <td>
                                                                                        <asp:DropDownList ID="commissionBase" runat="server" CssClass="form-control" TabIndex="211"></asp:DropDownList>
                                                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="commissionBase"
                                                                                            Display="Dynamic" ErrorMessage="*" ValidationGroup="commission" ForeColor="Red" CssClass="ErrMsg"
                                                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </ContentTemplate>
                                                            <Triggers>
                                                                <asp:AsyncPostBackTrigger ControlID="sCountry" EventName="SelectedIndexChanged" />
                                                                <asp:AsyncPostBackTrigger ControlID="rCountry" EventName="SelectedIndexChanged" />
                                                                <asp:AsyncPostBackTrigger ControlID="ssAgent" EventName="SelectedIndexChanged" />
                                                                <asp:AsyncPostBackTrigger ControlID="rsAgent" EventName="SelectedIndexChanged" />
                                                                <asp:AsyncPostBackTrigger ControlID="sAgent" EventName="SelectedIndexChanged" />
                                                                <asp:AsyncPostBackTrigger ControlID="rAgent" EventName="SelectedIndexChanged" />
                                                            </Triggers>
                                                        </asp:UpdatePanel>
                                                    </td>
                                                </tr>
                                            </div>
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td>
                                                        <table id="tblCopySlab" runat="server" visible="false" class="table table-responsive">
                                                            <tr>
                                                                <td style="width: 7%;">Copy Amount Slab From : </td>
                                                                <td style="width: 93%;">
                                                                    <asp:DropDownList ID="commissionSlab" runat="server" AutoPostBack="true" CssClass="form-control"
                                                                        OnSelectedIndexChanged="commissionSlab_SelectedIndexChanged">
                                                                    </asp:DropDownList>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <div id="divSlabgrid" runat="server" visible="false">
                                                                        <div id="rpt_slabgrid" runat="server" class="gridDiv" style="margin-left: 0px;"></div>
                                                                        <asp:Button ID="btnCopySlab" runat="server" Text="Copy Slab" CssClass="btn btn-primary m-t-25" OnClick="btnCopySlab_Click" />
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                            <table class="table table-responsive">
                                                <tr>
                                                    <td>
                                                        <table id="amountSlab" runat="server" visible="false" class="table table-responsive">
                                                            <tr>
                                                                <td>
                                                                    <asp:UpdatePanel ID="upnl2" runat="server">
                                                                        <ContentTemplate>
                                                                            <asp:HiddenField ID="hddScSendDetailId" runat="server" />
                                                                            <asp:Button ID="btnEditDetail" runat="server" OnClick="btnEditDetail_Click" Style="display: none;" />
                                                                            <asp:Button ID="btnDeleteDetail" runat="server" OnClick="btnDeleteDetail_Click" Style="display: none;" />
                                                                            <asp:HiddenField ID="fromAmt" runat="server" />
                                                                            <asp:HiddenField ID="toAmt" runat="server" />
                                                                            <asp:HiddenField ID="pcnt" runat="server" />
                                                                            <asp:HiddenField ID="minAmt" runat="server" />
                                                                            <asp:HiddenField ID="maxAmt" runat="server" />
                                                                            <asp:Button ID="btnSaveDetail" runat="server" CssClass="button" Text="Save" Style="display: none"
                                                                                OnClick="btnSaveDetail_Click" />&nbsp;&nbsp;
                                                                    <asp:Button ID="btnAddNew" runat="server" CssClass="btn btn-primary m-t-25" Text="Add new" Style="display: none"
                                                                        OnClick="btnAddNew_Click" />
                                                                        </ContentTemplate>
                                                                        <Triggers>
                                                                            <asp:AsyncPostBackTrigger ControlID="btnEditDetail" EventName="Click" />
                                                                        </Triggers>
                                                                    </asp:UpdatePanel>
                                                                </td>
                                                            </tr>
                                                            <div class="table table-responsive">
                                                                <tr>
                                                                    <td>
                                                                        <asp:UpdatePanel ID="upnl3" runat="server">
                                                                            <ContentTemplate>
                                                                                <div id="rpt_grid" runat="server" class="gridDiv"></div>
                                                                            </ContentTemplate>
                                                                            <Triggers>
                                                                                <asp:AsyncPostBackTrigger ControlID="btnSave" EventName="Click" />
                                                                                <asp:AsyncPostBackTrigger ControlID="btnCopySlab" EventName="Click" />
                                                                                <asp:AsyncPostBackTrigger ControlID="btnDeleteDetail" EventName="Click" />
                                                                            </Triggers>
                                                                        </asp:UpdatePanel>
                                                                    </td>
                                                                </tr>
                                                            </div>
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
        SetValueById("<%=hddScSendDetailId.ClientID %>", id, "");
        for (var i = 0; i < elements.length; i++) {
            elements[i].checked = false;
        }
        me.checked = true;
        GetElement("<%=btnEditDetail.ClientID %>").click();
    }
    function DeleteCommissionDetail(id) {
        if (confirm("Are you sure you want to delete this record?")) {
            SetValueById("<%=hddScSendDetailId.ClientID %>", id, "");
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
        SetValueById("<%=hddScSendDetailId.ClientID %>", "", "");
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
        SetValueById("<%=pcnt.ClientID %>", GetValue("pcnt1"), "");
        SetValueById("<%=minAmt.ClientID %>", GetValue("minAmt1"), "");
        SetValueById("<%=maxAmt.ClientID %>", GetValue("maxAmt1"), "");
        GetElement("<%=btnSaveDetail.ClientID %>").click();
    }

    function AddNew() {
        ClearSelection(gridName);
    }
</script>
</html>
