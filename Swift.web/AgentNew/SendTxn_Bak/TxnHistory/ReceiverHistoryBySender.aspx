<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReceiverHistoryBySender.aspx.cs" Inherits="Swift.web.AgentNew.SendTxn.TxnHistory.ReceiverHistoryBySender" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base id="Base1" target="_self" runat="server" />
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <script type="text/javascript">
        var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
        function CallBack(res) {
            window.returnValue = res;
            if (isChrome) {
                //alert(res);
                //window.opener.postMessage(window.returnValue);
                window.opener.PostMessageToParentNewForReceiver(window.returnValue);
            }
            window.close();
        }
        function CheckTR(obj) {

            //            var rdo = "rdoId_" + obj;
            //            document.getElementById("rowId").value = obj;
            //            document.getElementById(rdo).checked = true;

            var radios = document.getElementsByName("rdoId");
            for (var i = 0; i < radios.length; i++) {
                radios[(obj - 1)].checked = true;
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Transaction</a></li>
                            <li class="active"><a href="#">Send Transaction Int'l</a></li>
                            <li><a href="#">Customer Search</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer Search
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <div class="table-responsive">
                                    <table class="table">
                                        <tr>
                                            <td class="frmTitle" colspan="4">Receiver Search » Sender:  
            <asp:Label runat="server" ID="sname" Text="text"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td nowrap="nowrap" colspan="2">Receiver Name:
			    <asp:TextBox ID="txtSearch" runat="server" Width="200px"></asp:TextBox>
                                                <asp:Button ID="BtnSave2" runat="server" CssClass="button"
                                                    Text=" Search " ValidationGroup="receiver" OnClick="BtnSave2_Click" />
                                            </td>
                                            <td width="51" colspan="2" nowrap="nowrap">&nbsp;</td>
                                        </tr>
                                        <tr></tr>
                                        <tr>
                                            <td colspan="4">
                                                <div id="rpt_grid" runat="server" style="height: 320px; overflow: scroll;"></div>
                                                <br />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="4">
                                                <asp:Button ID="btnOk" runat="server" Text="Select" OnClick="btnOk_Click" CssClass="btn btn-primary" />
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
    </form>
</body>
</html>
