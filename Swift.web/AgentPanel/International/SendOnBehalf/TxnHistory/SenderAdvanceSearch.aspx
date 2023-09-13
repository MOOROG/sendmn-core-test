<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SenderAdvanceSearch.aspx.cs" Inherits="Swift.web.AgentPanel.International.SendOnBehalf.TxnHistory.SenderAdvanceSearch" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base id="Base1" target="_self" runat="server" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/css/style.css" rel="stylesheet" type="text/css" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />

    <script type="text/javascript">
        var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
        function CallBack(res) {
            window.returnValue = res;
            if (isChrome) {
                //alert(res);
                //window.opener.postMessage(window.returnValue);
                window.opener.PostMessageToParentNew(window.returnValue);
            }
            window.close();
        }
        function CheckTR(obj) {
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
                                <table class="table table-responsive">
                                    <tr>
                                        <td style="width: 15%;">
                                            <asp:DropDownList ID="searchType" CssClass="form-control" runat="server">
                                                <asp:ListItem Value="MembershipID" Text="Memebership ID"></asp:ListItem>
                                                <asp:ListItem Value="FirstName" Text="Customer Name" Selected="true"></asp:ListItem>
                                                <asp:ListItem Value="Passport" Text="Passport No"></asp:ListItem>
                                                <asp:ListItem Value="Mobile" Text="Mobile No"></asp:ListItem>
                                                <asp:ListItem Value="IC" Text="IC"></asp:ListItem>
                                            </asp:DropDownList>
                                        </td>
                                        <td style="width: 25%;">
                                            <asp:TextBox ID="searchValue" CssClass="form-control" runat="server"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="searchValue" ForeColor="Red" Display="Dynamic" ErrorMessage="*" SetFocusOnError="True"></asp:RequiredFieldValidator>
                                        </td>
                                        <td>
                                            <asp:Button ID="BtnSave2" runat="server" CssClass="button" Text=" Search " ValidationGroup="rpt" OnClick="BtnSave2_Click" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3">
                                            <div id="rpt_grid" runat="server"></div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3">
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
    </form>
</body>
</html>