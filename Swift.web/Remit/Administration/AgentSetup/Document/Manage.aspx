<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.Document.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <script type="text/javascript">
        function checkAll(me) {
            var checkBoxes = document.forms[0].chkTran;
            var boolChecked = me.checked;

            for (i = 0; i < checkBoxes.length; i++) {
                checkBoxes[i].checked = boolChecked;
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sc" runat="server"></asp:ScriptManager>
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <div class="page-title">
                        <h1>Administration<small></small>
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Agent Setup</a></li>
                            <li class="active"><a href="#">Document</a></li>
                            <li class="active"><a href="#">Manage</a></li>
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
                        <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0" style="clear: both">
                            <tr>
                                <td height="10">
                                    <div class="listtabs row">
                                        <ul class="nav nav-tabs" role="tablist">
                                            <li><a href="../../../../SwiftSystem/UserManagement/AgentSetup/Manage.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Agent Information </a></li>
                                            <li><a href="../AgentCurrency.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Allowed Currency </a></li>
                                            <li><a href="../AgentBusinessHistory.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Business History </a></li>
                                            <li><a href="../OwnerInf/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Owners</a></li>
                                            <li><a href="List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Required Document</a></li>
                                            <li><a href="../AgentContactPerson/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Contact Person</a></li>
                                            <li><a href="../AgentBankAccount/List.aspx?agentId=<%=GetAgentId()%>&mode=<%=GetMode()%>&parent_id=<%=GetParentId()%>&aType=<%=GetAgentType()%>&actAsBranch=<%=GetActAsBranchFlag() %>">Bank Account</a></li>
                                            <li class="active"><a href="#" class="selected">Manage</a></li>
                                        </ul>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div class="panel panel-default">
                            <div class="panel-heading">Document Upload</div>
                            <div class="panel-body">
                                <table class="table">
                                    <tr>
                                        <td height="524" valign="top">
                                            <table border="0" cellspacing="0" cellpadding="0" style="margin-left: 50px" class="formTable">

                                                <tr>
                                                    <td></td>
                                                    <td colspan="5">
                                                        <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="frmLable">Document Name:</td>
                                                    <td>
                                                        <asp:TextBox ID="fileDescription" runat="server" CssClass="input form-control"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="frmLable" nowrap="nowrap">Select File:</td>
                                                    <td>
                                                        <input id="fileUpload" runat="server" name="fileUpload" type="file" size="46"
                                                            class="input" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td></td>
                                                    <td nowrap="nowrap">
                                                        <asp:Button ID="btnUpload" runat="server" Text="Save" CssClass="bnt btn-primary btn-sm"
                                                            OnClick="btnUpload_Click" />&nbsp;
                                        <cc1:ConfirmButtonExtender ID="btnUploadcc" runat="server"
                                            ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnUpload">
                                        </cc1:ConfirmButtonExtender>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>

                        <table border="0" cellspacing="0" cellpadding="0" width="50%" align="left">
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