<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.UserApprovalLimit.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="../AgentUserSetup/List.aspx">Agent User Setup</a></li>
                            <li class="active"><a href="manage.aspx">Approval Limit </a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="listtabs">
                <asp:Panel ID="pnl1" runat="server">
                    <ul class="nav nav-tabs">
                        <li><a href="../AgentUserSetup/List.aspx?agentId=<%=GetAgentId() %>&mode=<%=GetMode() %>" target="_self">User List </a></li>
                        <li><a href="List.aspx?agentId=<%=GetAgentId() %>&userId=<%=GetUserId() %>&userName=<%=GetUserName() %>&mode=<%=GetMode() %>" target="_self">Limit List </a></li>
                        <li class="active"><a href="#" class="selected" target="_self">Manage </a></li>
                    </ul>
                </asp:Panel>
            </div>

            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-8">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">User Limit Setup
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <asp:UpdatePanel ID="upnl1" runat="server">
                                        <ContentTemplate>
                                            <div class="form-group">
                                                <div class="col-md-offset-4">
                                                    <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                                    <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="currency"
                                                        ForeColor="Red" Display="Dynamic" ErrorMessage="Fill All the Field" ValidationGroup="currency"
                                                        SetFocusOnError="True">
                                                    </asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-4">Agent/Branch Name :</label>
                                                <div class="col-md-8">
                                                    <asp:TextBox ID="lblAgentName" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-4">User Name :</label>
                                                <div class="col-md-8">
                                                    <asp:TextBox ID="lblUserName" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-4">Currency :</label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="currency" runat="server" CssClass="form-control"
                                                        AutoPostBack="True" OnSelectedIndexChanged="currency_SelectedIndexChanged">
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-4">Send Limit : 	</label>
                                                <div class="col-md-8">
                                                    <asp:TextBox ID="sendLimit" runat="server" CssClass="form-control">
                                                    </asp:TextBox>
                                                    <div id="sendShow" runat="server"></div>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-4">Pay Limit :</label>
                                                <div class="col-md-8">
                                                    <asp:TextBox ID="payLimit" runat="server" CssClass="form-control">
                                                    </asp:TextBox>
                                                    <div id="payShow" runat="server"></div>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-4">Is Enable :</label>
                                                <div class="col-md-8">
                                                    <asp:DropDownList ID="isEnable" runat="server" CssClass="form-control">
                                                        <asp:ListItem Value="Y" Selected="true">Yes</asp:ListItem>
                                                        <asp:ListItem Value="N">No</asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="control-label col-md-4"></label>
                                                <div class="col-md-8">
                                                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary m-t-25" ValidationGroup="currency"
                                                        OnClick="btnSave_Click" />
                                                    <cc1:ConfirmButtonExtender ID="btnCBE" runat="server"
                                                        ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                    </cc1:ConfirmButtonExtender>
                                                    <input id="btnBack" type="button" class="btn btn-primary m-t-25" value="Back" onclick=" Javascript: history.back(); " />
                                                    <asp:HiddenField ID="hdnUserLimitId" runat="server" />
                                                </div>
                                            </div>
                                        </ContentTemplate>
                                        <Triggers>
                                        </Triggers>
                                    </asp:UpdatePanel>
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
