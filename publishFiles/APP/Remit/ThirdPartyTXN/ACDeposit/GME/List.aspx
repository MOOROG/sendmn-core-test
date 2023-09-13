<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.ThirdPartyTXN.ACDeposit.GME.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="/js/functions.js"></script>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="/js/jQuery/jquery-1.4.1.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>

    <script type="text/javascript">
        function CallBackSave(errorCode, msg, url) {
            if (msg != '')
                alert(msg);
            if (errorCode == '0') {
                RedirectToIframe(url);
            }
        }
        function RedirectToIframe(url) {
            window.open(url, "_self");
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Transaction</a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Third Party TXN</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Download A/C Deposit Transactions</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab">
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation" class="active"><a href="/Remit/ThirdPartyTXN/ACDeposit/GME/List.aspx">GME Korea</a></li>
                        <li><a href="/Remit/ThirdPartyTXN/ACDeposit/Ria/List.aspx">Third Party</a></li>
                         </ul>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default recent-activites">
                            <div class="panel-heading">
                                <h4 class="panel-title">Download Transactions
                                </h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="form-group">

                                    <div class="col-md-3">
                                        <asp:Button ID="downloadTxn" runat="server" Width="200px" Height="30px" Text="Download Now" CssClass="btn btn-primary"
                                            OnClientClick="return DoSearch();" OnClick="downloadTxn_Click" />
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Button ID="btnRunPayProcess" runat="server" Width="200px" Height="30px" Text="Run Pay Process" CssClass="btn btn-primary"
                                            OnClick="btnRunPayProcess_Click" />
                                    </div>
                                    <div class="col-md-6">
                                        <label>Last download performed on:</label><asp:Label ID="lastDownloaded" runat="server" Text="Never" ForeColor="Blue" />
                                    </div>
                                    <div class="col-md-12">
                                        <div id="DivLoad" style="height: 20px; width: 220px; background-color: #333333; display: none; float: left">
                                            <img src="../../../../images/progressBar.gif" border="0" alt="Loading..." />
                                        </div>
                                    </div>
                                    <hr />
                                    <hr />
                                    <div class="col-md-12">
                                        <b>Filter Transaction By : </b>

                                        <asp:RadioButton ID="showUnpaid" GroupName="filter" Text="Only Assigned" runat="server"
                                            AutoPostBack="true" OnCheckedChanged="showUnpaid_CheckedChanged" />&nbsp;&nbsp;&nbsp;
                                        <asp:RadioButton ID="showUnassigned" GroupName="filter" Text="Only Un-Assigned" runat="server"
                                            AutoPostBack="true" OnCheckedChanged="showUnassigned_CheckedChanged" />&nbsp;&nbsp;&nbsp;
                                          <asp:RadioButton ID="showAll" Checked="true" GroupName="filter" Text="All" runat="server"
                                              OnCheckedChanged="showAll_CheckedChanged" AutoPostBack="true" />
                                        <asp:Button ID="btnDelete" runat="server" OnClick="btnDelete_Click" Style="display: none" />
                                        <asp:HiddenField ID="hddRowId" runat="server" />
                                    </div>
                                    <br />
                                    <div class="col-md-12">
                                        <div id="rpt_grid" class="table table-responsive" runat="server" enableviewstate="false">
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
</html>
<script type="text/javascript">
    function ViewDetail(rowId) {
        var url = "UnpaidTxnDetails.aspx?rowId=" + rowId + " &flag=W";
        var param = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
        var r = PopUpWindow(url, param);
        //document.forms[0].submit();
    }

    function EditDetails(rowId) {
        var url = "UnpaidTxnDetailsEdit.aspx?rowId=" + rowId + " &flag=W";
        var param = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
        var r = PopUpWindow(url, param);
        document.forms[0].submit();
    }


    function DoSearch() {
        $("#DivLoad").show();
        return true;
    }

    function DeleteTran(id) {
        if (!confirm("Are you sure to delete this transaction?"))
            return;

        GetElement("<% =hddRowId.ClientID %>").value = id;
        GetElement("<% =btnDelete.ClientID %>").click();
    }

</script>
