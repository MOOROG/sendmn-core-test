<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageEmailSeverSetup.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.MessageSetting.ManageEmailSeverSetup" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>

    <style type="text/css">
        legend {
            font-size: 1.2em;
            padding: 5px;
            margin-left: 1em;
            color: #3A4F63;
            background: #CCCCCC;
            font-weight: bold;
        }
    </style>
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
                            <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
                            <li class="active"><a href="ManageEmailServerSetup.aspx"> Email Server Setup</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Message Setting 
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Email SMTP Server :<span class="ErrMsg">*</span>
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:TextBox ID="emailSMTPServer" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="emailSMTPServer"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="email" ForeColor="Red"
                                        SetFocusOnError="True">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Email SMTP Port : <span class="ErrMsg">*</span>
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:TextBox ID="emailSMTPPort" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="emailSMTPPort"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="email" ForeColor="Red"
                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Email Send ID :<span class="ErrMsg">*</span>
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:TextBox ID="emailSendId" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="emailSendId"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="email" ForeColor="Red"
                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-4 col-md-4 control-label" for="">
                                    Email Send Password :<span class="ErrMsg">*</span>
                                </label>
                                <div class="col-lg-8 col-md-8">
                                    <asp:TextBox ID="emailSendPsw" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="emailSendPsw"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="email" ForeColor="Red"
                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-4 col-md-offset-4">
                                    <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="email" CssClass="btn btn-primary m-t-25" OnClick="btnSave_Click" />
                                </div>
                            </div>
                            <div id="rpt_div" runat="server"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<%--<table width="90%" border="0" align="left" cellpadding="0" cellspacing="0" style="margin-top:110px">
        <tr>
            <td>
                <table style="width: 100%">
                    <tr>
                        <td height="26" class="bredCrom"> <div>General Settings » Message Setting</div> </td>
                    </tr>
                    <tr>
                        <td height="10" class="shadowBG"></td>
                    </tr>
                        
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table border="0" cellspacing="0" cellpadding="0" align="left" class="formTable" style="width: 400px;">
                    <tr>
                        <th colspan="2" class="frmTitle">Email Server Setup</th>
                    </tr>
                    <tr>--%>
<%--     <td colspan="2" class="fromHeadMessage"><span class="ErrMsg">*</span> Fields are mandatory</td>
            </tr>
                    <tr>
                        <td>&nbsp;</td>
                        <td nowrap="nowrap">
                            <asp:Label runat="server" ID="lblMsg"></asp:Label>
                        </td>
                    </tr>

            <tr>
                <td valign="top" nowrap="nowrap">Email SMTP Server :
                </td>
                <td nowrap="nowrap">
                    <asp:TextBox ID="emailSMTPServer" runat="server" Width="150px"></asp:TextBox>
                    <span class="errormsg">*</span>
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="emailSMTPServer"
                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="email" ForeColor="Red"
                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                </td>
            </tr>
            <tr>--%>
<%--   <td valign="top" nowrap="nowrap">Email SMTP Port :
            </td>
            <td nowrap="nowrap">
                 <asp:TextBox ID="emailSMTPPort" runat="server" Width="50px"></asp:TextBox>
                    <span class="errormsg">*</span>
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="emailSMTPPort"
                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="email" ForeColor="Red"
                        SetFocusOnError="True"></asp:RequiredFieldValidator>
            </td>
            </tr>
            <tr>--%>
<%-- <td nowrap="nowrap">Email Send ID :
                </td>
                <td nowrap="nowrap">
                    <asp:TextBox ID="emailSendId" runat="server" Width="250px"></asp:TextBox>
                    <span class="errormsg">*</span>
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="emailSendId"
                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="email" ForeColor="Red"
                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                </td>
            </tr>
            <tr>--%>
<%--  <td nowrap="nowrap">Email Send Password
            </td>
            <td valign="top" nowrap="nowrap">
                <asp:TextBox ID="emailSendPsw" runat="server" Width="200px" TextMode="Password"></asp:TextBox>
                <span class="errormsg">*</span>
                <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="emailSendPsw"
                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="email" ForeColor="Red"
                    SetFocusOnError="True"></asp:RequiredFieldValidator>
            </td>
            </tr>--%>


<%--    <tr>
                <td>&nbsp;</td>
                <td nowrap="nowrap">
                    <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="email" CssClass="button"
                        OnClick="btnSave_Click" />
                </td>
            </tr>
            </table>
            </td>
        </tr>
        <tr>--%>
<%--      <td>
                <div id="rpt_div" runat="server"></div>
            </td>
        </tr>
        </table>--%>

