<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.UserLockDetail.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>

    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>

    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1 class="panel-title">User Management</h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>User Management</li>
                            <li>User Setup</li>
                            <li class="active">Manage Lock</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="../ApplicationUserSetup/List.aspx?agentId=<%=GetAgentId() %>&userName=<%=GetUserName() %>&mode=<%=GetMode() %>" target="_self" target="mainFrame">User List </a></li>
                    <li><a href="List.aspx?agentId=<%=GetAgentId() %>&userId=<%=GetUserId() %>&userName=<%=GetUserName() %>&mode=<%=GetMode() %>" target="_self">Lock List </a></li>
                    <li class="active"><a href="#" class="selected" target="_self">Manage Lock</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Lock User Setup
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <asp:ScriptManager ID="ScriptManager1" runat="server">
                                    </asp:ScriptManager>
                                    <table class="table table-responsive">
                                        <tr>
                                            <td valign="top">
                                                <asp:UpdatePanel ID="upnl1" runat="server">
                                                    <ContentTemplate>
                                                        <table class="table table-responsive">
                                                            <tr>
                                                                <td style="width:15%"></td>
                                                                <td>
                                                                    <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="frmLable" nowrap="nowrap">Agent/Branch Name :
                                                                </td>
                                                                <td>
                                                                    <asp:Label ID="lblAgentName" runat="server" CssClass="control-label" Width="285px"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="frmLable" nowrap="nowrap">User Name :
                                                                </td>
                                                                <td>
                                                                    <asp:Label ID="lblUserName" runat="server" CssClass="control-label" Width="285px"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="frmLable">From Date :
                                                                </td>
                                                                <td nowrap="nowrap">
                                                                    <div class="input-group m-b">
                                                                        <span class="input-group-addon">
                                                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                                                        </span>
                                                                        <asp:TextBox ID="fromDate" ReadOnly="true" Width="250px" Placeholder="Choose From Date "  required="Required" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                            <div id="sendShow" runat="server">
                                                                <tr>
                                                                    <td class="frmLable">To Date :
                                                                    </td>
                                                                    <td>
                                                                        <div class="input-group m-b">
                                                                            <span class="input-group-addon">
                                                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                                                            </span>
                                                                            <asp:TextBox ID="toDate" required="Required" Placeholder="Choose To Date" Width="250px" ReadOnly="true" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                            </div>
                                                            <div id="payShow" runat="server">
                                                                <tr>
                                                                    <td class="frmLable" style="margin-right: 5px">Remarks :
                                                                    </td>
                                                                    <td>
                                                                        <asp:TextBox ID="remarks" required="required" runat="server" CssClass="form-control" Width="285px" TextMode="MultiLine">
                                                                        </asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                            </div>
                                                            <tr>
                                                                <td>&nbsp;
                                                                </td>
                                                                <td nowrap="nowrap" valign="bottom">
                                                                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary m-t-25" ValidationGroup="lock"
                                                                        OnClick="btnSave_Click" />
                                                                    <cc1:ConfirmButtonExtender ID="btnCBE" runat="server" ConfirmText="Confirm To Save ?"
                                                                        Enabled="True" TargetControlID="btnSave">
                                                                    </cc1:ConfirmButtonExtender>
                                                                    &nbsp;
                                                                      <input id="btnBack" type="button" class="btn btn-primary m-t-25" value="Back" onclick=" Javascript: history.back(); " />
                                                                    <asp:HiddenField ID="hdnUserLockId" runat="server" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </ContentTemplate>
                                                    <Triggers>
                                                    </Triggers>
                                                </asp:UpdatePanel>
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
