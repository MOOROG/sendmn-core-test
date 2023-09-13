<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Detail.aspx.cs" Inherits="Swift.web.Remit.Compliance.RuleSetup.Detail" %>

<!DOCTYPE html>
<link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
<link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
<link href="../../../ui/css/style.css" rel="stylesheet" />
<script src="../../../js/Swift_grid.js"></script>
<script src="../../../js/functions.js"></script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="">
        .table .table {
            background-color: #f5f5f5;
        }
    </style>

    <script language="javascript">
        var gridName = "<% = GridName %>";
        var sendSelect = false;
        var benSelect = false;

        function GridCallBack() {
            var id = GetRowId(gridName);

            if (id != "") {
                GetElement("<% =btnEdit.ClientID %>").click();
                GetElement("<% =btnSave.ClientID %>").disabled = false;
            } else {
                GetElement("<% =btnSave.ClientID %>").disabled = true;
                GetElement("<% =btnDelete.ClientID %>").disabled = true;
                //SelectOrClearById("criteriaList", false);
                ResetForm();
                ClearAll(gridName);
            }
        }

        function ResetForm() {
            SetValueById("<% =condition.ClientID %>", "");
            SetValueById("<% =paymentMode.ClientID %>", "");
            SetValueById("<% =collMode.ClientID %>", "");
            SetValueById("<% =nextAction.ClientID %>", "");
            SetValueById("<% =tranCount.ClientID %>", "0");
            SetValueById("<% =amount.ClientID %>", "0");
            SetValueById("<% =period.ClientID %>", "0");
        }

        function NewRecord() {
            ResetForm();
            GetElement("<% =btnSave.ClientID %>").disabled = false;
            GetElement("<% =btnDelete.ClientID %>").visible = false;
            SetValueById("<% =csDetailId.ClientID %>", "");

            ClearAll(gridName);
            SelectOrClearById("criteriaList", false);
        }


        function UncheckAllCriteria() {
            SelectOrClearById("criteriaList", false);
        }

        function ManageCriteria() {
            var me = GetElement("<% =condition.ClientID %>");

            if (me.value == "4601" || me.value == "4602") {
                HideElement("tdBen");
                HideElement("professionRow");
                //SelectOrClearById("tdBen", false);
                ShowElement("tdSend");
            } else if (me.value == "4603") {
                ShowElement("tdBen");
                HideElement("tdSend");
                HideElement("professionRow");
                //SelectOrClearById("tdSend", false);
            }
            else if (me.value == "11201") {
                //$('professionRow').css('style', 'contents');
                ShowElementNew("professionRow");
            }
            else
            {
                //ShowElement("criteriaList");
                HideElement("professionRow");
               ShowElement("tdSend");
                ShowElement("tdBen");
            }
        }

        function ChkSelect(me, type) {
            if (type == "s") {
                if (sendSelect) {
                    SelectOrClearById("tdSend", false);
                    sendSelect = false;
                } else {
                    SelectOrClearById("tdSend", true);
                    sendSelect = true;
                }
            } else if (type == "b") {
                if (benSelect) {
                    SelectOrClearById("tdBen", false);
                    benSelect = false;
                } else {
                    SelectOrClearById("tdBen", true);
                    benSelect = true;
                }
            }
        }

        function SearchCallBack() {
            //            ResetForm();
            ClearAll(gridName);
            SelectOrClearById("criteriaList", false);
            ManageCriteria();
            GetElement("<% =btnSave.ClientID %>").disabled = true;
            GetElement("<% =btnDelete.ClientID %>").disabled = true;
        }

        function CallBack() {
            window.frames['frmame_main'].location.reload(1);
        }
    </script>
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
                            <li><a href="#" onclick="return LoadModule('remit')">Remit</a></li>
                            <li><a href="#" onclick="return LoadModule('remit_compliance')">Compliance Setup </a></li>
                            <li class="active"><a href="Detail.aspx">Compliance Details</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="List.aspx" target="_self">Main </a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Detail</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Compliance Setup - Detail 
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <asp:UpdatePanel ID="upd1" runat="server">
                                            <ContentTemplate>
                                                <table class="table table-responsive">
                                                    <table id="tbl_breadCrumb" class="table table-responsive">
                                                        <tr>
                                                            <td valign="top">
                                                                <table class="table table-responsive">
                                                                    <tr>
                                                                        <th align="left" colspan="4">Sending </th>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>Country </td>
                                                                        <td>
                                                                            <asp:Label ID="sCountry" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>Agent </td>
                                                                        <td>
                                                                            <asp:Label ID="sAgent" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                        <td align="left">State </td>
                                                                        <td>
                                                                            <asp:Label ID="sState" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td align="left">Zip </td>
                                                                        <td>
                                                                            <asp:Label ID="sZip" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                        <td align="left">Group </td>
                                                                        <td>
                                                                            <asp:Label ID="sGroup" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td align="left">Customer Type </td>
                                                                        <td>
                                                                            <asp:Label ID="sCustType" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                            <td></td>
                                                            <td valign="top">
                                                                <table class="table table-responsive">
                                                                    <tr>
                                                                        <th align="left" colspan="4">Receiving </th>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>Country </td>
                                                                        <td>
                                                                            <asp:Label ID="rCountry" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>Agent </td>
                                                                        <td>
                                                                            <asp:Label ID="rAgent" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                        <td align="left">State </td>
                                                                        <td>
                                                                            <asp:Label ID="rState" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td align="left">Zip </td>
                                                                        <td>
                                                                            <asp:Label ID="rZip" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                        <td align="left">Group </td>
                                                                        <td>
                                                                            <asp:Label ID="rGroup" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td align="left">Customer Type </td>
                                                                        <td>
                                                                            <asp:Label ID="rCustType" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                        <td align="left">Currency </td>
                                                                        <td>
                                                                            <asp:Label ID="currency" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                            <td valign="top">
                                                                <table class="table table-responsive">
                                                                    <tr>
                                                                        <th align="left" colspan="2">Scope </th>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>Rule Scope </td>
                                                                        <td>
                                                                            <asp:Label ID="ruleScope" runat="server" CssClass="bold-text"></asp:Label>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <tr>
                                                    </tr>
                                                    <hr />
                                                    <hr />
                                                    <tr>
                                                        <td>
                                                            <table class="table table-responsive">
                                                                <tr>

                                                                    <td>
                                                                        <table class="table table-responsive  table-striped table-bordered">
                                                                            <tr>
                                                                                <td>Condition
                                                                                </td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="condition" runat="server" CssClass="form-control"
                                                                                        onClientChange="return ManageCriteria()">
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr id="professionRow" hidden>
                                                                                <td>Prfession
                                                                                </td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="ddlProfession" runat="server" CssClass="form-control">
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>Payment Mode
                                                                                </td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="paymentMode" runat="server" CssClass="form-control">
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>Collection Mode
                                                                                </td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="collMode" runat="server" CssClass="form-control">
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                        </table>

                                                                    </td>
                                                                    <td>
                                                                        <table class="table table-responsive  table-striped table-bordered">
                                                                            <tr style="display:none;">
                                                                                <td>Transaction count
                                                                                </td>
                                                                                <td>
                                                                                    <asp:TextBox ID="tranCount" runat="server" CssClass="form-control"></asp:TextBox>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>Amount
                                                                                </td>
                                                                                <td>
                                                                                    <asp:TextBox ID="amount" runat="server" CssClass="form-control"></asp:TextBox>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>Period(In days)
                                                                                </td>
                                                                                <td>
                                                                                    <asp:TextBox ID="period" runat="server" CssClass="form-control"></asp:TextBox>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>Action
                                                                                </td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="nextAction" runat="server" CssClass="form-control">
                                                                                        <asp:ListItem Value="H">Hold</asp:ListItem>
                                                                                        <asp:ListItem Value="B">Block</asp:ListItem>
                                                                                        <asp:ListItem Value="Q">Hold & Questionnaire</asp:ListItem>
                                                                                    </asp:DropDownList>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>Require Document
                                                                                </td>
                                                                                <td>
                                                                                    <asp:CheckBox ID="requireDocumentCheckBox" runat="server" />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                    <td valign="top" style="display:none;">
                                                                        <table class="table table-responsive  table-striped table-bordered" id="criteriaList">
                                                                                        <tr>
                                                                                            <td valign="top" id="tdSend">
                                                                                                <legend title="Click to Select/Unselect" style="cursor: pointer" onclick="ChkSelect(this,'s')">By Sender</legend>
                                                                                                <table id="tblSend" class="table table-responsive  table-striped table-bordered">
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="chk_5000" runat="server" Text="ID" />
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="chk_5001" runat="server" Text="Name" />
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="chk_5002" runat="server" Text="Mobile" />
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </td>
                                                                                            <td valign="top" id="tdBen">
                                                                                                <legend title="Click to Select/Unselect" style="cursor: pointer" onclick="ChkSelect(this,'b')">By Beneficiary</legend>
                                                                                                <table class="table table-responsive  table-striped table-bordered" id="tblBen">
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <table class="table table-responsive  table-striped table-bordered" >
                                                                                                                <tr>
                                                                                                                    <td>
                                                                                                                        <asp:CheckBox ID="chk_5003" runat="server" Text="ID" />
                                                                                                                    </td>
                                                                                                                </tr>
                                                                                                                <tr>
                                                                                                                    <td>
                                                                                                                        <asp:CheckBox ID="chk_5004" runat="server" Text="ID(System)" />
                                                                                                                    </td>
                                                                                                                </tr>
                                                                                                                <tr>
                                                                                                                    <td>
                                                                                                                        <asp:CheckBox ID="chk_5005" runat="server" Text="Name" />
                                                                                                                    </td>
                                                                                                                </tr>
                                                                                                            </table>
                                                                                                        </td>
                                                                                                        <td valign="top">
                                                                                                            <table class="table table-responsive  table-striped table-bordered">
                                                                                                                <tr>
                                                                                                                    <td>
                                                                                                                        <asp:CheckBox ID="chk_5006" runat="server" Text="Mobile" />
                                                                                                                    </td>
                                                                                                                </tr>
                                                                                                                <tr>
                                                                                                                    <td>
                                                                                                                        <asp:CheckBox ID="chk_5007" runat="server" Text="A/C Number" />
                                                                                                                    </td>
                                                                                                                </tr>
                                                                                                            </table>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                            <asp:HiddenField ID="csDetailId" runat="server" />
                                                            <asp:Button ID="btnSearch" runat="server" Text="Search" Style="float: left" OnClick="btnSearch_Click"
                                                                CssClass="btn btn-primary m-t-25" />
                                                            <div style="height: 20px; float: left">
                                                                <asp:UpdateProgress runat="server" ID="up">
                                                                    <ProgressTemplate>
                                                                        <img style="margin-left: 10px" src="../../../Images/ajax-loader.gif" alt="Please wait..." />
                                                                    </ProgressTemplate>
                                                                </asp:UpdateProgress>
                                                            </div>
                                                            <div style="float: right">
                                                                <input type="button" value="New" onclick="NewRecord();" class="btn btn-primary m-t-25" />
                                                                <asp:Button ID="btnEdit" CssClass="btn btn-primary m-t-25" runat="server" Text="Edit" Style="display: none" OnClick="btnEdit_Click" />
                                                                <asp:Button ID="btnDelete" runat="server" Text="Disable" CssClass="btn btn-primary m-t-25" OnClick="btnDelete_Click"
                                                                    Enabled="False" />
                                                                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary m-t-25" OnClick="btnSave_Click" />
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false">
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnEdit" EventName="click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnDelete" EventName="click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnSave" EventName="click" />
                                            </Triggers>
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
