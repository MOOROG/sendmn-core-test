﻿<%@ Page Language="C#" ValidateRequest="false" AutoEventWireup="true" CodeBehind="ManageNewsFeeder.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.MessageSetting.ManageNewsFeeder" %>
<%@ Register Assembly="CKEditor.NET" Namespace="CKEditor.NET" TagPrefix="CKEditor" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">

    <base id="Base1" runat="server" target="_self" />
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
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>

    <script type="text/javascript">
        WYSIWYG.attach("<%=textarea1.ClientID%>", full);
    </script>

</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
                            <li class="active"><a href="ManageNewsFeeder.aspx">Message Setting</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation"><a href="ListHeadMsg.aspx" aria-controls="home" role="tab" data-toggle="tab">Head </a></li>
                    <li role="presentation"><a href="ListMessage1.aspx" aria-controls="home" role="tab" data-toggle="tab">Common  </a></li>
                    <li role="presentation"><a href="ListMessage2.aspx" aria-controls="home" role="tab" data-toggle="tab">Country</a></li>
                    <li role="presentation"><a href="ListNewsFeeder.aspx" aria-controls="home" role="tab" data-toggle="tab">News Feeder </a></li>
                    <li role="presentation"><a href="ListEmailTemplate.aspx" aria-controls="home" role="tab" data-toggle="tab">Email Template</a></li>
                    <li role="presentation"><a href="ListMessageBroadCast.aspx" aria-controls="home" role="tab" data-toggle="tab">Broadcast</a></li>
                    <li role="presentation" class="active"><a href="Javascript:void(0)" class="selected" aria-controls="home" role="tab" data-toggle="tab">Manage</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">News Feeder 
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <fieldset>
                                        <div class="form-group">
                                            <label class="col-lg-1 col-md-2 control-label" for="">
                                                Country:
                                            </label>
                                            <div class="col-lg-5 col-md-10">
                                                <asp:DropDownList ID="country" runat="server" CssClass="form-control"
                                                    OnSelectedIndexChanged="country_SelectedIndexChanged" AutoPostBack="True">
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-lg-1 col-md-2 control-label" for="">
                                                Applies For:
                                            </label>
                                            <div class="col-lg-5 col-md-10">
                                                <asp:DropDownList ID="msgType" runat="server" CssClass=" form-control">
                                                    <asp:ListItem Value="B">Both</asp:ListItem>
                                                    <asp:ListItem Value="S">Send</asp:ListItem>
                                                    <asp:ListItem Value="R">Receive</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-lg-1 col-md-2 control-label" for="">
                                                Agent:
                                            </label>
                                            <div class="col-lg-5 col-md-10">
                                                <asp:DropDownList ID="agent" runat="server" CssClass="form-control"
                                                    AutoPostBack="True" OnSelectedIndexChanged="agent_SelectedIndexChanged">
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-lg-1 col-md-2 control-label" for="">
                                                Branch:
                                            </label>
                                            <div class="col-lg-5 col-md-10">
                                                <asp:DropDownList ID="branch" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-lg-1 col-md-2 control-label" for="">
                                                User Type:
                                            </label>
                                            <div class="col-lg-5 col-md-10">
                                                <asp:DropDownList ID="userType" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="col-lg-1 col-md-2 control-label" for="">
                                                Is Active:
                                            </label>
                                            <div class="col-lg-5 col-md-10">
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
                                            <div class="col-lg-5 col-md-10">
                                                <CKEditor:CKEditorControl ID="textarea1" runat="server" BasePath="/ckeditor/"></CKEditor:CKEditorControl>
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


<%-- <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0" style="margin-top:110px">
        <tr>
            <td width="100%"> 
                <asp:Panel ID="pnl1" runat="server">
                    <table width="100%">
                        <tr>
                            <td height="26" class="bredCrom"> <div > General Settings » Message Setting » News Feeder Message » Manage </div> </td>
                        </tr>
                        <tr>
                            <td height="10" width="100%"> 
                                <div class="tabs" > 
                                    <ul>--%>
<%--                                        <li> <a href="ListHeadMsg.aspx">Head </a></li> 
                                        <li> <a href="ListMessage1.aspx">Common</a></li>
                                        <li> <a href="ListMessage2.aspx">Country</a></li>
                                        <li> <a href="ListNewsFeeder.aspx"  class="selected">News Feeder </a></li>
                                        <li> <a href="ListEmailTemplate.aspx">Email Template </a></li>
                                        <li> <a href="ListMessageBroadCast.aspx">Broadcast</a></li>
                                        <li> <a href="Javascript:void(0)" class="selected">Manage</a></li>
                                         
                                    </ul> 
                                </div>		
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td height="524" valign="top" >       
                <table border="0" cellspacing="0" cellpadding="0" class="formTable" align="left" style="width: 850px;" >
                    <tr>--%>
<%--<th colspan="2" class="frmTitle">Message Details</th>
                    </tr>
                    <tr>
                        <td colspan="2" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                    </tr>
                    <tr>
                        <td>
                            <fieldset>
                                <legend>News Feeder </legend>
                                <table>
                                    <tr>
                                        <td class="frmLable">Country:</td>
                                        <td>
                                            <asp:DropDownList ID="country" runat="server" CssClass="input" 
                                                onselectedindexchanged="country_SelectedIndexChanged" AutoPostBack="True"></asp:DropDownList> 
                                        </td>
                                    </tr>
                                    <tr>
                                         <td class="frmLable">Applies For:</td>
                                        <td>
                                            <asp:DropDownList ID="msgType" runat="server" CssClass="input">
                                                <asp:ListItem Value="B">Both</asp:ListItem>
                                                <asp:ListItem Value="S">Send</asp:ListItem>
                                                <asp:ListItem Value="R">Receive</asp:ListItem>
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Agent:</td>
                                        <td>
                                            <asp:DropDownList ID="agent" runat="server" CssClass="input" 
                                                AutoPostBack="True" onselectedindexchanged="agent_SelectedIndexChanged"></asp:DropDownList>                                                    
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Branch:</td>
                                        <td>
                                            <asp:DropDownList ID="branch" runat="server" CssClass="input"></asp:DropDownList>                                                    
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">User Type:</td>
                                        <td> <asp:DropDownList ID="userType" runat="server"> </asp:DropDownList></td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Is Active:</td>
                                        <td>
                                            <asp:DropDownList ID="ddlIsActive" runat="server" CssClass="input">
                                                <asp:ListItem Value="Active">Active</asp:ListItem>
                                                <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
                                            </asp:DropDownList>                                                    
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Message</td>
                                        <td>
                                            <asp:TextBox ID="textarea1" runat="server" Width="600px" Height="200px" TextMode="MultiLine"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>--%>
<%-- <td></td>
                                        <td><asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="static" 
                                                        CssClass="button" TabIndex="5" onclick="btnSave_Click" />
                                            <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" 
                                                                       ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                            </cc1:ConfirmButtonExtender>&nbsp;
                                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="button" 
                                                TabIndex="6" onclick="btnDelete_Click" />
                                            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" 
                                                                       ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                            </cc1:ConfirmButtonExtender> &nbsp; 
                                            <input id="btnBack" type="button" value="Back" class="button" onclick=" Javascript:history.back(); " />
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>--%>
