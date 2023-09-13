<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Swift.Master" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.CreditSecurity.FixedDeposit.List" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainPlaceHolder" runat="server">
    <div class="page-wrapper">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <ol class="breadcrumb">
                        <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                        <li><a href="#" onclick="return LoadModule('creditrisk_management')">Credit Risk Management </a></li>
                        <li class="active"><a href="List.aspx">Credit Security</a></li>
                    </ol>
                </div>
            </div>
        </div>
        <div class="listtabs">
            <ul class="nav nav-tabs" role="tablist">
                <li role="presentation"><a href="../ListAgent.aspx" aria-controls="home" role="tab" data-toggle="tab">List Agent</a></li>
                <li role="presentation"><a href="../BankGuarantee/List.aspx?agentId=<%=GetAgentId()%>" aria-controls="home" role="tab" data-toggle="tab">Bank Guarantee</a></li>
                <li role="presentation"><a href="../Mortgage/List.aspx?agentId=<%=GetAgentId()%>" aria-controls="home" role="tab" data-toggle="tab">Mortgage</a></li>
                <li role="presentation"><a href="../CashSecurity/List.aspx?agentId=<%=GetAgentId()%>" aria-controls="home" role="tab" data-toggle="tab">Cash Security</a></li>
                <li role="presentation" class="active"><a href="Javascript:void(0)" class="selected" aria-controls="home" role="tab" data-toggle="tab">Fixed Deposit</a></li>
            </ul>
        </div>
        <div class="tab-content">
            <div role="tabpanel" class="tab-pane active" id="list">
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default ">
                            <div class="panel-heading">
                                <h4 class="panel-title"><span id="spnCname" runat="server"><%=GetAgentName()%></span></h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>

                            <div class="panel-body">
                                <div class="table-responsive">
                                    <div id="rpt_grid" runat="server" class="gridDiv"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
<%-- <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td width="100%">
                <asp:Panel ID="pnl1" runat="server">
                    <table width="100%">
                        <tr>
                            <td height="26" class="bredCrom"> <div > Credit Risk Management » Credit Security » Fixed Deposit » List </div> </td>
                        </tr>
                        <tr>
                            <td height="20" class="welcome"><span id="spnCname" runat="server"><%=GetAgentName()%></span></td>
                        </tr>
                        <tr>
                            <td height="10" width="100%">
                                <div class="tabs">
                                    <ul>
                                        <li> <a href="../ListAgent.aspx">List Agent</a></li>
                                        <li> <a href="../BankGuarantee/List.aspx?agentId=<%=GetAgentId()%>">Bank Guarantee</a></li>
                                        <li> <a href="../Mortgage/List.aspx?agentId=<%=GetAgentId()%>">Mortgage</a></li>
                                        <li> <a href="../CashSecurity/List.aspx?agentId=<%=GetAgentId()%>">Cash Security</a></li>
                                        <li> <a href="Javascript:void(0)" class="selected">Fixed Deposit</a></li>
                                    </ul>
                                </div>
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td height="524" valign="top">
                <div id = "rpt_grid" runat = "server" class = "gridDiv"></div>
            </td>
        </tr>
    </table>--%>