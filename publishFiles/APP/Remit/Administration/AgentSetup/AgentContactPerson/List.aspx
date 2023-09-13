<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.AgentContactPerson.List" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <%--<link href="../../../../css/swift_component.css" rel="stylesheet" type="text/css" />--%>

    <script src="../../../../js/Swift_grid.js" type="text/javascript"> </script>
    <script type="text/javascript" src="../../../../js/functions.js"> </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <div class="page-title">
                        <h1>Administration<small></small>
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Agent Setup</a></li>
                            <li class="active"><a href="#">Contact Person</a></li>
                            <li class="active"><a href="#">List</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <table class="table table-condensed">
                <tr>
                    <td>
                        <asp:Panel ID="pnl2" runat="server">
                            <table>

                                <tr>
                                    <td height="20" class="welcome"><span id="spnCname" runat="server"><%=GetAgentName()%></span></td>
                                </tr>
                            </table>
                        </asp:Panel>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Panel ID="pnl1" runat="server">
                            <table class="table">
                                <tr>
                                    <td height="10">
                                        <div class="tabs">
                                            <ul>
                                                <li><a href="../Functions/ListAgent.aspx">Agent List </a></li>
                                                <li><a href="#" class="selected">Edit Agent </a></li>
                                            </ul>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                        <table class="table">
                            <tr>
                                <td height="10">
                                    <div class="listtabs row">
                                        <ul class="nav nav-tabs" role="tablist">
                                            <li><a href="../../../../SwiftSystem/UserManagement/AgentSetup/Manage.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Agent Information </a></li>
                                            <li><a href="../AgentCurrency.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Allowed Currency </a></li>
                                            <li><a href="../AgentBusinessHistory.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Business History </a></li>
                                            <li><a href="../OwnerInf/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Owners</a></li>
                                            <li><a href="../Document/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Required Document</a></li>
                                            <li class="active"><a href="Javascript:void(0)" class="selected">Contact Person</a></li>
                                            <li><a href="../AgentBankAccount/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Bank Account</a></li>
                                        </ul>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td height="524" valign="top">
                        <table class="table table-condensed" style="margin-left: -40px;">
                            <tr>
                                <td height="524" valign="top">

                                    <div id="rpt_grid" runat="server" class="gridDiv"></div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>