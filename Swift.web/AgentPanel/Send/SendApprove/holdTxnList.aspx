<%@ Page Language="C#" EnableEventValidation="false" AutoEventWireup="true" CodeBehind="holdTxnList.aspx.cs" Inherits="Swift.web.AgentPanel.Send.SendApprove.holdTxnList" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagPrefix="uc1" TagName="SwiftTextBox" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="../../../js/functions.js"></script>
    <script src="../../../js/swift_autocomplete.js"></script>
    <script src="../../../js/swift_calendar.js"></script>
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script language="javascript" type="text/javascript">
		function LoadCalendars() {
			ShowCalDefault("#<% =txnDate.ClientID%>");
			$('#txnDate').mask('0000-00-00');
		}
		LoadCalendars();

		function ClearFields() {
			$('#tblForm').find('input:text').val('');
			$('#tblForm').find('input:hidden').val('');
			$('#tblForm').find('select').val('');
			GetElement("<% =btnSearch.ClientID %>").click();
		}

		function ViewDetails(id) {
			var url = "Manage.aspx?id=" + id;
			var ret = OpenDialog(url, 800, 900, 50, 50);
			if (ret) {
				GetElement("<% =btnSearch.ClientID %>").click();
			}
		}

		function Modify(id) {
			var url = "Modify.aspx?tranId=" + id;
			var ret = OpenDialog(url, 800, 900, 50, 50);
			if (ret) {
				GetElement("<% =btnSearch.ClientID %>").click();
			}
		}

		function CheckAmount(id, tAmt) {
			var strAmt = $("#amt_" + id).val();
			var amt = parseFloat(strAmt);

			if (isNaN(amt) || isNaN(strAmt) || amt < 0) {
				$("#amt_" + id).val("");
			}
			var boolDisabled = ((isNaN(amt) || isNaN(strAmt) || amt == 0 || tAmt != amt));
			EnableDisableBtn("btn_" + id, boolDisabled);
			EnableDisableBtn("btn_r_" + id, boolDisabled);
		}

		function Approve(id) {
			var amt = parseFloat($("#amt_" + id).val());
			if (amt <= 0) {
				window.parent.SetMessageBox("Invalid Amount", "1");
				return;
			}

			SetValueById("<% = hddTranNo.ClientID %>", id, false);
			GetElement("<% =btnApprove.ClientID %>").click();
		}

		function Reject(id) {
			var url = "Reject.aspx?id=" + id;
			var ret = OpenDialog(url, 800, 900, 50, 50);
			if (ret) {
				GetElement("<% =btnSearch.ClientID %>").click();
			}
		}

		function ToggleCheckboxes(id, isRadioMode) {
			if (isRadioMode) {
				SelectDeselect("rowId", false);
			} else {
				ToggleSelection("rowId");
			}
			CallBackGrid();
		}

		function CallBackGrid(me, isRadioMode) {
			if (isRadioMode) {
				SelectDeselect("rowId", false);
				me.checked = true;
			}

			var boolDisabled = !CanApprove("rowId");
			EnableDisableBtn("<% =btnApproveAll.ClientID %>", boolDisabled);
			ManageToggleCB("rowId");
		}

		function ToggleSelection(name) {
			var boolCheck = GetElement("tgcb").checked;
			SelectDeselect(name, boolCheck);
		}

		function SelectDeselect(name, boolCheck) {
			var elements = document.getElementsByName(name);
			for (var i = 0; i < elements.length; i++) {
				elements[i].checked = boolCheck;
			}
		}

		function CanApprove(name) {
			var elements = document.getElementsByName(name);
			for (var i = 0; i < elements.length; i++) {
				if (elements[i].checked) {
					return true;
				}
			}
			return false;
		}

		function ManageToggleCB(name) {
			var elements = document.getElementsByName(name);
			for (var i = 0; i < elements.length; i++) {
				if (!elements[i].checked) {
					GetElement("tgcb").checked = false;
					return false;
				}
			}
			GetElement("tgcb").checked = true;
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
                        <ol class="breadcrumb">
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModuleAgentMenu('send_money')">Send Money</a></li>
                            <li class="active"><a href="holdTxnList.aspx">Approve Transaction</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default margin-b-30">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search Transaction Criteria
                            </h4>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-lg-3 col-md-3 form-group">
                                    <label class="control-label" for="">
                                        Sending Branch
                                    </label>
                                    <asp:DropDownList ID="branch" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                                <div class="col-lg-3 col-md-3 form-group">

                                    <label class="control-label" for="">
                                        Tran No
                                    </label>
                                    <asp:TextBox ID="tranNo" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-lg-3 col-md-3 form-group">
                                    <label class="control-label" for="">
                                        BRN
                                    </label>
                                    <asp:TextBox ID="ControlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-lg-3 col-md-3 form-group">
                                    <label class="control-label" for="">
                                        Rec Country
                                    </label>
                                    <asp:DropDownList ID="rCountry" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-3 col-md-3 form-group">
                                    <label class="control-label" for="">
                                        Sender
                                    </label>
                                    <asp:TextBox ID="sender" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-lg-3 col-md-3 form-group">
                                    <label class="control-label" for="">
                                        Receiver
                                    </label>
                                    <asp:TextBox ID="receiver" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-lg-3 col-md-3 form-group">
                                    <label class="control-label" for="">
                                        Amount
                                    </label>
                                    <asp:TextBox ID="amt" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-lg-3 col-md-3 form-group">
                                    <label class="control-label" for="">
                                        Txn Date
                                    </label>
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="txnDate" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-3 col-md-3 form-group">
                                    <label class="control-label" for="">
                                        User
                                    </label>
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-user" aria-hidden="true"></i>
                                        </span>
                                        <uc1:SwiftTextBox ID="user" Category="users" runat="server" />
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <asp:Button ID="btnSearch" runat="server" Text="Search Approve" CssClass="btn btn-primary"
                                        OnClick="btnSearch_Click" ValidationGroup="rpt" />&nbsp;&nbsp;
                                <asp:Button ID="btnSearchHold" runat="server" Text="Search Self Txn " CssClass="btn btn-primary"
                                    OnClick="btnSearchHold_Click" ValidationGroup="rpt" />&nbsp;&nbsp;
                            <input type="button" value="Clear Field" id="btnSclearField" class="btn btn-primary" onclick=" ClearFields(); " />
                                </div>
                            </div>

                            <br />
                            <div id="approveList" runat="server">
                                <div id="rptGrid" runat="server"></div>
                                <div style="margin-left: 18px">
                                    <asp:Button ID="btnApproveAll" runat="server" Text="Approve Selected" Visible="false" Enabled="false" OnClick="btnApproveAll_Click" />
                                </div>
                            </div>
                            <div id="selfTxn" runat="server"></div>
                            <br />
                            <asp:Button ID="btnApprove" runat="server" Text="Approve" Style="display: none" OnClick="btnApprove_Click" />
                            <asp:Button ID="btnReject" runat="server" OnClick="btnReject_Click" Style="display: none" />
                            <asp:HiddenField ID="hddTranNo" runat="server" />
                            <asp:HiddenField ID="hdntabType" runat="server" />
                        </div>
                        <div class="row">
                            <div class="col-md-12">
                                <div id="txnSummary" runat="server"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

<script type="text/javascript">

	function SelectTab(obj) {
		document.getElementById('hdntabType').value = obj;
		if (obj == "a") {
			document.getElementById('appCnt').style.display = "block";
			document.getElementById('selfTxn').style.display = "none";
			document.getElementById('rptGrid').style.display = "block";
			document.getElementById("a").setAttribute("class", "selected");
			document.getElementById("s").setAttribute("class", "");
		}
		if (obj == "s") {
			document.getElementById('appCnt').style.display = "none";
			document.getElementById('selfCnt').style.display = "block";
			document.getElementById('rptGrid').style.display = "none";
			document.getElementById('selfTxn').style.display = "block";
			document.getElementById("s").setAttribute("class", "selected");
			document.getElementById("a").setAttribute("class", "");
		}

	}
</script>