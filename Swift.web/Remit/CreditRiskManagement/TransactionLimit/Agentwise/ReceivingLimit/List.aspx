<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.TransactionLimit.Agentwise.ReceivingLimit.List" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="../../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../../ui/js/jquery.min.js"></script>
    <link href="../../../../../Css/swift_component.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>CREDIT RISK MANAGEMENT
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Credit Risk Management</a></li>
                            <li class="active"><a href="#">Agent Wise</a></li>
                            <li class="active"><a href="#">Transaction Limit</a></li>
                            <li class="active"><a href="#">Receiving Limit</a></li>
                            <li class="active"><a href="#">List</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title"></h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <table class="table table-condensed">
                                        <tr>
                                            <td width="100%">
                                                <asp:Panel ID="pnl1" runat="server">
                                                    <table width="100%">
                                                        <tr>
                                                            <td height="20" class="welcome"><span id="spnCname" runat="server"><%=GetAgentName()%></span></td>
                                                        </tr>
                                                        <%--<tr>
                            <td height="10" width="100%">
                                <div class="tabs">
                                    <ul>
                                        <li> <a href="../List.aspx">Agent Wise </a></li>
                                        <li> <a href="../SendingLimit/List.aspx?agentId=<%=GetAgentId()%>">Collection Limit</a></li>
                                        <li> <a href="Javascript:void(0)" class="selected">Payment Limit</a></li>
                                    </ul>
                                </div>
                            </td>
                        </tr>--%>
                                                    </table>
                                                </asp:Panel>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="524" valign="top">
                                                <div id="rpt_grid" runat="server" class="gridDiv"></div>
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