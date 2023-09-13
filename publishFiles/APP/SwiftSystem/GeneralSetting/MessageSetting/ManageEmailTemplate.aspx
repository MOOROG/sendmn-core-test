<%@ Page Language="C#" ValidateRequest="false" AutoEventWireup="true" CodeBehind="ManageEmailTemplate.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.MessageSetting.ManageEmailTemplate" %>

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
                            <li class="active"><a href="ManageEmailTemplate.aspx">Message Setting</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="ListHeadMsg.aspx" target="_self">Head </a></li>
                    <li><a href="ListMessage1.aspx" target="_self">Common  </a></li>
                    <li><a href="ListMessage2.aspx" target="_self">Country</a></li>
                    <li><a href="ListNewsFeeder.aspx" target="_self">News Feeder </a></li>
                    <li><a href="ListEmailTemplate.aspx" target="_self">Email Template </a></li>
                    <li><a href="ListMessageBroadCast.aspx" target="_self">Broadcast</a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Manage</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Email Template
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <fieldset>
                                        <div class="row">
                                            <div class="col-md-8">
                                                <div class="form-group">
                                                    <label class="col-lg-1 col-md-3 control-label" for="">
                                                        Template Name:  <span class="ErrMsg">*</span>
                                                    </label>
                                                    <div class="col-lg-5 col-md-5">
                                                        <asp:TextBox ID="templateName" runat="server" CssClass="form-control"></asp:TextBox>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="templateName" ForeColor="Red"
                                                            ValidationGroup="email" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-1 col-md-3 control-label" for="">
                                                        Email Subject:   <span class="ErrMsg">*</span>
                                                    </label>
                                                    <div class="col-lg-5 col-md-5">
                                                        <asp:TextBox ID="emailSubject" runat="server" CssClass="form-control"></asp:TextBox>

                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="emailSubject" ForeColor="Red"
                                                            ValidationGroup="email" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-1 col-md-3 control-label" for="">
                                                        Template For :
                                                    </label>
                                                    <div class="col-lg-5 col-md-5">

                                                        <asp:DropDownList ID="templateFor" runat="server" CssClass="form-control">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-1 col-md-3 control-label" for="">
                                                        Reply To:
                                                    </label>
                                                    <div class="col-lg-5 col-md-5">
                                                        <asp:DropDownList ID="replyTo" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="Both">Both</asp:ListItem>
                                                            <asp:ListItem Value="Admin">Admin</asp:ListItem>
                                                            <asp:ListItem Value="Agent">Agent</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <div class="col-lg-5 col-md-5 col-md-offset-3">
                                                        <asp:CheckBox ID="chkEnabled" runat="server" Text="Enabled" />
                                                        &nbsp;&nbsp;
                                               <asp:CheckBox ID="chkResToAgent" runat="server" Text="Response To Agent" />
                                                    </div>
                                                </div>

                                                <div class="form-group">
                                                    <label class="col-lg-1 col-md-3 control-label" for="">
                                                        Email Format :   <span class="ErrMsg">*</span>
                                                    </label>
                                                    <div class="col-lg-5 col-md-5">
                                                        <asp:TextBox ID="textarea1" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="textarea1" ForeColor="Red"
                                                            ValidationGroup="email" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </div>
                                                </div>

                                                <div class="form-group">
                                                    <div class="col-md-8 col-md-offset-3">
                                                        <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="static" CssClass="btn btn-primary m-t-25" TabIndex="5" OnClick="btnSave_Click" />
                                                        <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                                        </cc1:ConfirmButtonExtender>
                                                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-primary m-t-25" OnClick="btnDelete_Click" TabIndex="6" />
                                                        <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                                        </cc1:ConfirmButtonExtender>
                                                        <input id="btnBack" type="button" value="Back" class="btn btn-primary m-t-25" onclick=" Javascript: history.back(); " />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-2 col-md-offset-1">
                                                <div id="keyword" runat="server" style="-ms-text-justify: " cssclass=" form-control col-md-3"></div>
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


<%--    <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0" style="margin-top:110px">
        <tr>
            <td width="100%"> 
                <asp:Panel ID="pnl1" runat="server">
                    <table width="100%">
                        <tr>
                            <td height="26" class="bredCrom"> <div > General Settings » Message Setting » Email Template » Manage </div> </td>
                        </tr>
                        <tr>
                            <td height="10" width="100%"> 
                                <div class="tabs" > 
                                    <ul>
                                        <li> <a href="ListHeadMsg.aspx">Head </a></li> 
                                        <li> <a href="ListMessage1.aspx">Common  </a></li>
                                        <li> <a href="ListMessage2.aspx">Country</a></li>
                                        <li> <a href="ListNewsFeeder.aspx">News Feeder</a></li>
                                        <li> <a href="ListEmailTemplate.aspx" class="selected">Email Template</a></li>
                                        <li> <a href="ListMessageBroadCast.aspx">Broadcast</a></li>
                                        <li> <a href="Javascript:void(0)" class="selected">Manage</a></li>
                                         
                                    </ul> 
                                </div>		
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>--%>
<%--    <tr>
            <td height="524" valign="top" >       
                <table border="0" cellspacing="0" cellpadding="0" class="formTable" align="left" >
                    <tr>
                        <th colspan="2" class="frmTitle">Message Details</th>
                    </tr>
                    <tr>
                        <td colspan="2" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
                    </tr>
                    <tr>
                        <td>--%>
<%-- <fieldset>
                                <legend>Email Template</legend>
                                <table>
                                    <tr>
                                        <td class="frmLable" height="40px">Template Name:</td>
                                        <td  height="50px">
                                            <asp:TextBox ID="templateName" runat="server" CssClass="input" Width="250px"></asp:TextBox> 
                                            <span class="ErrMsg">*</span>
                                             <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="templateName" ForeColor="Red" 
                                                                    ValidationGroup="email" Display="Dynamic"   ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                        <td rowspan="6" valign="top" height="40px"><div id="keyword" runat="server" style="-ms-text-justify: "></div> </td>
                                    </tr>
                                    <tr>--%>
<%-- <td class="frmLable"  height="40px">Email Subject:</td>
                                        <td height="40px">
                                            <asp:TextBox ID="emailSubject" runat="server" CssClass="input" Width="400px"></asp:TextBox> 
                                            <span class="ErrMsg">*</span>
                                             <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="emailSubject" ForeColor="Red" 
                                                                    ValidationGroup="email" Display="Dynamic"   ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable" height="40px" >Template For:</td>
                                        <td height="40px">                                   
                                                <asp:DropDownList ID="templateFor" runat="server" Width="150px">                    
                                                </asp:DropDownList>                          
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable" height="40px">Reply To:</td>
                                        <td height="40px">                                   
                                                <asp:DropDownList ID="replyTo" runat="server" Width="150px"> 
                                                 <asp:ListItem Value="Both">Both</asp:ListItem>
                                                 <asp:ListItem Value="Admin">Admin</asp:ListItem>
                                                 <asp:ListItem Value="Agent">Agent</asp:ListItem>
                                                </asp:DropDownList>                          
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable"  valign="top" >&nbsp;</td>
                                        <td nowrap="nowrap"  valign="top" >
                                            <asp:CheckBox ID="chkEnabled" runat="server" Text="Enabled"/>  &nbsp;&nbsp; &nbsp;   
                                            <asp:CheckBox ID="chkResToAgent" runat="server" Text="Response To Agent"/>                                
                                        </td>
                                    </tr>
                                    <tr>--%>
<%--  <td class="frmLable" valign="top">Email Format:</td>
                                        <td>
                                            <asp:TextBox ID="textarea1" runat="server" TextMode="MultiLine"></asp:TextBox>
                                              <span class="ErrMsg">*</span>
                                             <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="textarea1" ForeColor="Red" 
                                                                    ValidationGroup="email" Display="Dynamic"   ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td><asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="email" 
                                                        CssClass="button" TabIndex="5" onclick="btnSave_Click" />
                                            <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" 
                                                                       ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                            </cc1:ConfirmButtonExtender>&nbsp;
                                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="button" 
                                                TabIndex="6" onclick="btnDelete_Click" />
                                            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" 
                                                                       ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                            </cc1:ConfirmButtonExtender> &nbsp; 
                                            <input id="btnBack" type="button" value="Back" class="button" onClick=" Javascript:history.back(); " />
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
