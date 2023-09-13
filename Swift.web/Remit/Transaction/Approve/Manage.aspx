<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.Approve.Manage" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="/ui/js/jquery.min.js"></script>
	<script src="/ui/js/jquery-ui.min.js"></script>
    <link href="/css/style.css" rel="stylesheet" type="text/css" />
    <script src="/js/swift_calendar.js" type="text/javascript"></script>

    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>


    <script language="javascript" type="text/javascript">
        function LoadCalendars() {
			ShowCalFromToUpToToday("#<% =txnDate.ClientID%>");
			$('#txnDate').mask('0000-00-00');
        }
        LoadCalendars();

        function ClearFields() {
            $('#form1').find('input:text').val('');
            $('#form1').find('input:hidden').val('');
            $('#form1').find('select').val('');
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
                        <h1>
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a>
                            </li>
                          <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="Manage.aspx">Approve Transaction </a></li>
                        </ol>
                        <li class="active">
                            <asp:Label ID="breadCrumb" runat="server"></asp:Label>
                        </li>
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
                                        <asp:Label ID="header">Search Transaction Criteria</asp:Label>
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
                                        <a href="#" class="panel-action panel-action-dismiss" data-panel-dismiss=""></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-3">
                                                <label>Sending Agent</label>
                                                <uc1:SwiftTextBox ID="agent" Category="remit-domestic-agent" runat="server" />
                                            </div>
                                            <div class="col-md-3">
                                                <b>BRN</b><br />
                                                <asp:TextBox ID="ControlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-md-3">
                                                <b>Sender</b><br />
                                                <asp:TextBox ID="sender" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-md-3">
                                                <b>Receiver</b><br />
                                                <asp:TextBox ID="receiver" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-4">
                                                <b>Amount</b><br />
                                                <asp:TextBox ID="amt" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                            <div class="col-md-4">
                                                <b>Txn Date</b><br />
                                                <asp:TextBox ID="txnDate" onchange="return DateValidation('txnDate','t')" MaxLength="10" runat="server" CssClass="form-control" autocomplete="off"></asp:TextBox>
                                            </div>
                                            <div class="col-md-4">
                                                <b>User</b><br />
                                                <uc1:SwiftTextBox ID="user" Category="remit-users" runat="server" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-4">
                                                <asp:Button ID="btnSearch" runat="server" Text="Search Approve" CssClass="btn btn-primary"
                                                    OnClick="btnSearch_Click" ValidationGroup="rpt" />
                                            </div>
                                            <div class="col-md-4">
                                                <input type="button" value="Clear Field" id="btnSclearField" class="btn btn-primary" onclick=" ClearFields(); " />
                                            </div>
                                        </div>
                                    </div>
                                    <div id="approveList" runat="server" class="col-sm-12">
                                        <div id="rptGrid" runat="server" class="col-sm-12"></div>
                                    </div>
                                    <div id="selfTxn" runat="server" class="col-sm-12"></div>
                                    <br />
                                    <asp:Button ID="btnApprove" runat="server" Text="Approve" CssClass="btn btn-primary" Style="display: none" OnClick="btnApprove_Click" />

                                    <asp:HiddenField ID="hddTranNo" runat="server" />
                                    <asp:HiddenField ID="hdntabType" runat="server" />

                                    <div>
                                        <div id="txnSummary" runat="server" class="col-sm-12"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%-- end of tab panel --%>
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
