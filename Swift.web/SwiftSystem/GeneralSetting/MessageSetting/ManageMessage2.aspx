<%@ Page Language="C#" ValidateRequest="false" AutoEventWireup="true" CodeBehind="ManageMessage2.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.MessageSetting.ManageMessage2" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="scripts/wysiwyg.js" type="text/javascript"> </script>
    <script src="scripts/wysiwyg-settings.js" type="text/javascript"> </script>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript">
        WYSIWYG.attach("<%=textarea1.ClientID%>", full);
    </script>
</head>

<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
                            <li class="active"><a href="ManageMessage2.aspx">Message Setting</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="ListHeadMsg.aspx" target="_self">Head </a></li>
                    <li><a href="ListMessage1.aspx" target="_self">Common</a></li>
                    <li><a href="ListMessage2.aspx" target="_self">Country</a></li>
                    <li><a href="ListNewsFeeder.aspx" target="_self">News Feeder </a></li>
                    <li><a href="ListEmailTemplate.aspx" target="_self">Email Template</a></li>
                    <li><a href="ListMessageBroadCast.aspx " target="_self">Broadcast</a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Manage</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Head Message[Country Wise]
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <fieldset>
                                        <div class="form-group">
                                            <label class="col-lg-2 col-md-2 control-label" for="">
                                                Message Type:
                                            </label>
                                            <div class="col-lg-5 col-md-5">
                                                <asp:DropDownList ID="msgType" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="S">Send</asp:ListItem>
                                                    <asp:ListItem Value="R">Receive</asp:ListItem>
                                                    <asp:ListItem Value="B">Both</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-lg-2 col-md-2 control-label" for="">
                                                Sending Country:<span class="ErrMsg">*</span>
                                            </label>
                                            <div class="col-lg-5 col-md-5">
                                                <asp:DropDownList ID="country" runat="server" CssClass="form-control" AutoPostBack="true"
                                                    OnSelectedIndexChanged="country_SelectedIndexChanged">
                                                </asp:DropDownList>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="country" ForeColor="Red"
                                                    ValidationGroup="count" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="col-lg-1 col-md-2 control-label" for="">
                                                Sending Agent:
                                            </label>
                                            <div class="col-lg-5 col-md-5">
                                                <asp:DropDownList ID="agent" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-lg-1 col-md-2 control-label" for="">
                                                Reciving Country:<span class="ErrMsg">*</span>
                                            </label>
                                            <div class="col-lg-5 col-md-5">
                                                <asp:DropDownList runat="server" ID="receiveCountry" AutoPostBack="true" CssClass="form-control"
                                                    OnSelectedIndexChanged="receiveCountry_SelectedIndexChanged">
                                                </asp:DropDownList>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="receiveCountry" ForeColor="Red"
                                                    ValidationGroup="count" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="col-lg-1 col-md-2 control-label" for="">
                                                Reciving Agent:
                                            </label>
                                            <div class="col-lg-5 col-md-5">
                                                <asp:DropDownList ID="recivingAgent" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </div>
                                        </div>


                                        <div class="form-group">
                                            <label class="col-lg-1 col-md-2 control-label" for="">
                                                Transaction:
                                            </label>
                                            <div class="col-lg-5 col-md-5">
                                                <asp:DropDownList ID="trasactionType" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-lg-1 col-md-2 control-label" for="">
                                                Is Active:
                                            </label>
                                            <div class="col-lg-5 col-md-5">
                                                <asp:DropDownList ID="ddlIsActive" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="Active">Active</asp:ListItem>
                                                    <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-lg-1 col-md-2 control-label" for="">
                                                Message:
                                            </label>
                                            <div class="col-lg-5 col-md-5">
                                                <asp:TextBox ID="textarea1" runat="server" Width="600px" Height="200px" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div class="col-md-8 col-md-offset-2">
                                                <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="static" CssClass="btn btn-primary m-t-25" TabIndex="5" OnClick="btnSave_Click" />
                                                <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                </cc1:ConfirmButtonExtender>
                                                <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-primary m-t-25" TabIndex="6" />
                                                <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                                </cc1:ConfirmButtonExtender>
                                                <input id="btnBack" type="button" value="Back" class="btn btn-primary m-t-25" onclick=" Javascript: history.back(); " />
                                            </div>
                                        </div>
                                    </fieldset>

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
