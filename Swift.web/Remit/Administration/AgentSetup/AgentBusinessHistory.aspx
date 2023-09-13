<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AgentBusinessHistory.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.AgentBusinessHistory" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <%--<link href="../../../css/swift_component.css" rel="stylesheet" type="text/css" />--%>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =fromDate.ClientID%>", "#<% =toDate.ClientID%>", 1);
        }
        LoadCalendars();
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <asp:UpdatePanel ID="up" runat="server">
            <ContentTemplate>
                <div class="container">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="page-title">
                                <h1>Administration<small></small>
                                </h1>
                                <ol class="breadcrumb">
                                    <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                                    <li><a href="#">Agent Setup</a></li>
                                    <li class="active"><a href="#">Business History</a></li>
                                </ol>
                            </div>
                        </div>
                    </div>
                    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <asp:Panel ID="pnl2" runat="server">
                                    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
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
                                    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td height="10">
                                                <div class="listtabs">
                                                    <ul>
                                                        <li><a href="Functions/ListAgent.aspx">Agent List </a></li>
                                                        <li><a href="#" class="selected">Edit Agent </a></li>
                                                    </ul>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                                <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0" style="clear: both">
                                    <tr>
                                        <td height="10">
                                            <div class="listtabs row">
                                                <ul class="nav nav-tabs" role="tablist">
                                                    <li><a href="../../../SwiftSystem/UserManagement/AgentSetup/Manage.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Agent Information </a></li>
                                                    <li><a href="AgentCurrency.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Allowed Currency </a></li>
                                                    <li class="active"><a href="#" class="selected">Business History </a></li>
                                                    <li><a href="OwnerInf/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Owners</a></li>
                                                    <li><a href="Document/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Required Document</a></li>
                                                    <li><a href="AgentContactPerson/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Contact Person</a></li>
                                                    <li><a href="AgentBankAccount/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Bank Account</a></li>
                                                </ul>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table width="90%" border="0" align="left" cellpadding="3" cellspacing="3">
                                    <tr>
                                        <td height="524" valign="top">
                                            <table class="table table-condensed">
                                                <tr>

                                                    <td colspan="6">
                                                        <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="frmLable">Remittance Company:</td>
                                                    <td>
                                                        <asp:TextBox ID="remitCompany" runat="server" CssClass="input form-control"></asp:TextBox>
                                                        <asp:RequiredFieldValidator ID="rfv1" runat="server" ControlToValidate="remitCompany"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </td>
                                                    <td class="frmLable" nowrap="nowrap">From(yy/mm):</td>
                                                    <td>
                                                        <asp:TextBox ID="fromDate" onchange="return DateValidation('fromDate','t')" MaxLength="10" runat="server" CssClass="input form-control"></asp:TextBox>
                                                        <asp:RequiredFieldValidator ID="rfv2" runat="server" ControlToValidate="fromDate"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="agent" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </td>
                                                    <td class="frmLable" nowrap="nowrap">To(yy/mm):</td>
                                                    <td nowrap="nowrap">
                                                        <asp:TextBox ID="toDate" runat="server" onchange="return DateValidation('toDate','t')" MaxLength="10" CssClass="input form-control"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="6">
                                                        <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="btn btn-primary" ValidationGroup="agent"
                                                            OnClick="btnAdd_Click" />
                                                    </td>
                                                </tr>
                                            </table>
                                            <table class="table table-condensed">
                                                <tr>
                                                    <td height="524" valign="top">
                                                        <table border="0" cellspacing="0" cellpadding="0" align="left">
                                                            <tr>
                                                                <td height="524" valign="top">
                                                                    <div id="rpt_grid" runat="server" class="gridDiv"></div>
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
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>