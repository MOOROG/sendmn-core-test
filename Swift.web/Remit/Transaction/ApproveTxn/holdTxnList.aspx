<%@ Page Language="C#" EnableEventValidation="false" AutoEventWireup="true" CodeBehind="holdTxnList.aspx.cs" Inherits="Swift.web.Remit.Transaction.ApproveTxn.holdTxnList" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="/ui/js/jquery.min.js"></script>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>

    <script language="javascript" type="text/javascript">
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =txnDate.ClientID%>");
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

        function ViewMapping(id) {
            var url = "MappingInfo.aspx?id=" + id;
            var ret = OpenDialog(url, 800, 900, 50, 50);
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

      function testApprove(id) {
        SetValueById("<% = hddTranNo.ClientID %>", id, false);
        GetElement("<% =testBtn.ClientID %>").click();
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
            if (boolDisabled === true) {
                $("#<% =btnApproveAll.ClientID %>").addClass("hidden");
            } else {
                $("#<% =btnApproveAll.ClientID %>").removeClass("hidden");
            }
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
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a>
                            </li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="holdTxnList.aspx">Approve Transaction </a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="Manage">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">
                                        <label>Approve Transaction</label>
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
                                        <a href="#" class="panel-action panel-action-dismiss" data-panel-dismiss=""></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="form-group">
                                            <label>&nbsp;&nbsp;&nbsp;Search Transaction Criteria</label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-3">
                                                <label>Sending Country</label>
                                                <asp:DropDownList ID="country" runat="server" AutoPostBack="true" CssClass="form-control"
                                                    OnSelectedIndexChanged="country_SelectedIndexChanged">
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-md-3">
                                                <label>Sending Agent</label>
                                                <asp:DropDownList CssClass="form-control" ID="agent" runat="server" AutoPostBack="true"
                                                    OnSelectedIndexChanged="agent_SelectedIndexChanged">
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-md-3">
                                                <label>Sending Branch</label>
                                                <asp:DropDownList CssClass="form-control" ID="branch" runat="server"></asp:DropDownList>
                                            </div>
                                            <div class="col-md-3">
                                                <label>Tran No</label>
                                                <asp:TextBox ID="tranNo" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-md-3">
                                                <label>PIN No.</label>
                                                <asp:TextBox ID="ControlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-md-3">
                                                <label>Receiving Country</label>
                                                <asp:DropDownList CssClass="form-control" ID="rCountry" runat="server"></asp:DropDownList>
                                            </div>
                                            <div class="col-md-3">
                                                <label>Sender Name</label>
                                                <asp:TextBox ID="sender" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-md-3">
                                                <label>Receiver Name</label>
                                                <asp:TextBox ID="receiver" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-md-3">
                                                <label>Amount</label>
                                                <asp:TextBox ID="amt" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-md-3">
                                                <label>Txn Date</label><br />
                                                <asp:TextBox ID="txnDate" onchange="return DateValidation('txnDate','t')" MaxLength="10" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-md-3" style="display: none;">
                                                <label>User</label><br />
                                                <uc1:SwiftTextBox ID="user" Category="remit-users" runat="server" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-4">
                                                <asp:Button ID="btnSearch" runat="server" Text="Search Approve" CssClass="btn btn-primary"
                                                    OnClick="btnSearch_Click" ValidationGroup="rpt" />
                                                <input type="button" value="Clear Field" id="btnSclearField" class="btn btn-primary" onclick=" ClearFields(); " />
                                            </div>
                                        </div>
                                    </div>
                                    <div id="approveList" runat="server">
                                        <div id="rptGrid" runat="server" enableviewstate="false"></div>
                                        <br />
                                        <asp:Button ID="btnApproveAll" runat="server" CssClass='btn btn-primary m-t-25 hidden' Text="Approve Selected" Enabled="false" OnClick="btnApproveAll_Click" />
                                    </div>
                                    <div id="selfTxn" runat="server" class="col-sm-12"></div>
                                    <br />
                                    <asp:Button ID="btnApprove" runat="server" Text="Approve" CssClass="btn btn-primary" Style="display: none" OnClick="btnApprove_Click" />
                                    <asp:Button ID="btnReject" runat="server" CssClass='btn btn-primary m-t-25' OnClick="btnReject_Click" Style="display: none" />
                                  <asp:Button ID="testBtn" runat="server" Text="testButton" CssClass="btn btn-primary" Style="display: none" OnClick="testBtn_Click" />
                                    <asp:HiddenField ID="hddTranNo" runat="server" />
                                    <asp:HiddenField ID="hdntabType" runat="server" />

                                    <div>
                                        <div id="txnSummary" runat="server" class="col-sm-12" enableviewstate="false"></div>
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
