<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserGroupMaping.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.AdminUserSetup.UserGroupMaping" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                            <li class="active"><a href="UserGroupMaping.aspx">User Group Mapping  </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                        <li> <a href="List.aspx" target="_self">Admin User List </a></li>
                        <li class="active"> <a href="#" class="selected" target="_self"> User Group Mapping </a></li>
                        <li> <a href="UserZoneMapping.aspx?userName=<%=GetUserName() %>&userId=<%=GetUserId() %>" target="_self">User Zone Mapping</a></li>
                        <li> <a href="UserAgentMapping.aspx?userName=<%=GetUserName() %>&userId=<%=GetUserId() %>" target="_self">User Agent Mapping</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">User Group Details</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label class="control-label col-md-2">
                                            Group Category:<span class="errormsg">*</span>
                                        </label>
                                        <div class="col-md-6">
                                            <asp:DropDownList runat="server" ID="DDLGroupCat" CssClass="form-control"
                                                OnSelectedIndexChanged="DDLGroupCat_SelectedIndexChanged" AutoPostBack="true">
                                            </asp:DropDownList>
                                        </div>
                                        <div class="col-md-2">
                                            <asp:RequiredFieldValidator
                                                ID="RequiredFieldValidator14" runat="server" ControlToValidate="DDLGroupCat" ForeColor="Red"
                                                Display="Dynamic" ErrorMessage="Required!" SetFocusOnError="True" ValidationGroup="servicetype">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label col-md-2">
                                            Group Detail:<span class="errormsg">*</span>
                                        </label>
                                        <div class="col-md-6">
                                            <asp:DropDownList runat="server" ID="DDLGroupDetail" CssClass="form-control">
                                            </asp:DropDownList>
                                        </div>
                                        <div class="col-md-2">
                                            <asp:RequiredFieldValidator
                                                ID="RequiredFieldValidator2" runat="server" ControlToValidate="DDLGroupDetail" ForeColor="Red"
                                                Display="Dynamic" ErrorMessage="Required!" SetFocusOnError="True" ValidationGroup="servicetype">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label col-md-2">
                                        </label>
                                        <div class="col-md-6">
                                            <asp:Button ID="bntSubmit" runat="server" Text="Submit" CssClass="btn btn-primary m-t-25" ValidationGroup="servicetype" TabIndex="4" OnClick="bntSubmit_Click" />
                                            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender2" runat="server" ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="bntSubmit">
                                            </cc1:ConfirmButtonExtender>
                                            <asp:Button ID="btnDelete" runat="server" Text="New" CssClass="btn btn-primary m-t-25" TabIndex="5" OnClick="btnDelete_Click" />
                                            <input id="btnBack" type="button" class="btn btn-primary m-t-25" value="Back" onclick=" Javascript: history.back(); " />
                                        </div>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div id="rpt_grid" runat="server"></div>
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
