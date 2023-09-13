<%@ Page Language="C#" ValidateRequest="false" AutoEventWireup="true" CodeBehind="ManageMessageBroadCast.aspx.cs"
    Inherits="Swift.web.SwiftSystem.GeneralSetting.MessageSetting.ManageMessageBroadCast" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox"
    TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <%-- <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../../../js/swift_autocomplete.js" type="text/javascript"></script>--%>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script language="javascript" type="text/javascript">
        OpenInEditMsgDetail();
        function GetCountryId() {
            return GetItem("<% = country.ClientID %>")[0];
        }

        function GetAgentId() {
            return GetItem("<% = agent.ClientID %>")[0];
    }

    function CallBackAutocomplete(id) {
        var d = ["", ""];
        if (id == "#<% = country.ClientID%>") {
                SetItem("<% = agent.ClientID%>", d);
                <% = agent.InitFunction() %>;
            }
            else if (id == "#<% = agent.ClientID%>") {
                SetItem("<% =branch.ClientID%>", d);
                <% = branch.InitFunction() %>;
            }
        }


    </script>
    <script language="javascript">
        function textboxMultilineMaxNumber(txt, maxLen) {
            try {
                if (txt.value.length > (maxLen - 1)) return false;
            } catch (e) {
            }
        }
    </script>
</head>
<body onload="OpenInEditMsgDetail()">
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
                            <li class="active"><a href="ManageMessageBroadCast.aspx">Message Setting</a></li>
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
                    <li><a href="ListEmailTemplate.aspx" target="_self">Email Template</a></li>
                    <li><a href="ListMessageBroadCast.aspx" target="_self">Broadcast</a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Manage</a></li>
                    <li><a href="DynamicPopupList.aspx" target="_self">Dynamic Popup</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Message BroadCast
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            Country :
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <uc1:SwiftTextBox ID="country" runat="server" Category="country" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            Agent :
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <uc1:SwiftTextBox ID="agent" runat="server" Category="s-r-agent" Param1="@GetCountryId()" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            Branch :
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <uc1:SwiftTextBox ID="branch" runat="server" Category="branch" Param1="@GetAgentId()" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            User Type :
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <asp:DropDownList ID="userType" runat="server" CssClass="form-control">
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            Active : <span class="ErrMsg">*</span>
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <asp:DropDownList ID="isActive" runat="server" CssClass="form-control">
                                                <asp:ListItem Value="">Select</asp:ListItem>
                                                <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                <asp:ListItem Value="N">No</asp:ListItem>
                                            </asp:DropDownList>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="isActive"
                                                Display="Dynamic" ErrorMessage="Required!" InitialValue="" SetFocusOnError="True"
                                                ValidationGroup="Save" ForeColor="Red">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            Message Title :  <span class="ErrMsg">*</span>
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <asp:TextBox ID="msgTitle" runat="server" CssClass="form-control"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3"
                                                runat="server" ControlToValidate="msgTitle" Display="Dynamic" ErrorMessage="Required!"
                                                InitialValue="" SetFocusOnError="True" ValidationGroup="Save" ForeColor="Red">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            Message Detail : <span class="ErrMsg">*</span>
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <asp:TextBox ID="msgDetail" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="msgDetail"
                                                Display="Dynamic" ErrorMessage="Required!" InitialValue="" SetFocusOnError="True"
                                                ValidationGroup="Save" ForeColor="Red">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <div class="col-md-8 col-md-offset-2">
                                            <asp:Button ID="btnSave" Text="Save" runat="server" OnClick="btnClick_Save" ValidationGroup="Save" CssClass="btn btn-primary m-t-25" />
                                            <asp:Button ID="btnBack" Text="Back" OnClick="btnBack_Click" runat="server" CssClass="btn btn-primary m-t-25" /><br />
                                        </div>
                                    </div>
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


<%-- <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td width="100%">
                <asp:Panel ID="pnl1" runat="server">
                    <table width="100%">
                        <tr>
                            <td height="26" class="bredCrom">
                                <div>
                                    General Settings » Message Setting » Message Broadcast » Manage
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td height="10" width="100%">
                                <div class="tabs">
                                    <ul>
                                        <li><a href="ListHeadMsg.aspx">Head </a></li>
                                        <li><a href="ListMessage1.aspx">Common</a></li>
                                        <li><a href="ListMessage2.aspx">Country</a></li>
                                        <li><a href="ListNewsFeeder.aspx">News Feeder </a></li>
                                        <li><a href="ListEmailTemplate.aspx">Email Template</a></li>
                                        <li><a href="ListMessageBroadCast.aspx" class="selected">Broadcast</a></li>
                                        <li><a href="Javascript:void(0)" class="selected">Manage</a></li>
                                        <li><a href="DynamicPopupList.aspx">Dynamic Popup</a></li>
                                    </ul>
                                </div>
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td>
                <table class="formTable">
                    <tr>
                        <td colspan="2" class="frmTitle">--%>
<%--  Message BroadCast
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table>
                                <tr>
                                    <td class="frmLable">
                                        Country
                                    </td>
                                    <td>
                                        <uc1:SwiftTextBox ID="country" runat="server" Category="country" />
                                    </td>
                                </tr>
                                <tr>
                                    <td class="frmLable">
                                        Agent
                                    </td>
                                    <td>
                                        <uc1:SwiftTextBox ID="agent" runat="server" Category="s-r-agent" Param1="@GetCountryId()" />
                                    </td>
                                </tr>
                                <tr>
                                    <td class="frmLable">
                                        Branch
                                    </td>
                                    <td>
                                        <uc1:SwiftTextBox ID="branch" runat="server" Category="branch" Param1="@GetAgentId()" />
                                    </td>
                                </tr>
                                <tr>--%>
<%-- <td class="frmLable">
                                        User Type:
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="userType" runat="server">
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="frmLable">
                                        Active
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="isActive" runat="server">
                                            <asp:ListItem Value="">Select</asp:ListItem>
                                            <asp:ListItem Value="Y">Yes</asp:ListItem>
                                            <asp:ListItem Value="N">No</asp:ListItem>
                                        </asp:DropDownList>
                                        <span class="ErrMsg">*</span>&nbsp;
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="isActive"
                                            Display="Dynamic" ErrorMessage="Required!" InitialValue="" SetFocusOnError="True"
                                            ValidationGroup="Save" ForeColor="Red">
                                        </asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td nowrap="nowrap" class="frmLable">
                                        Message Title
                                    </td>
                                    <td>
                                        <asp:TextBox ID="msgTitle" runat="server" Width="500px" MaxLength="100"></asp:TextBox>
                                        <span class="ErrMsg">*</span> &nbsp;<asp:RequiredFieldValidator ID="RequiredFieldValidator2"
                                            runat="server" ControlToValidate="msgTitle" Display="Dynamic" ErrorMessage="Required!"
                                            InitialValue="" SetFocusOnError="True" ValidationGroup="Save" ForeColor="Red">
                                        </asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="frmLable" nowrap="nowrap">
                                        Message Detail
                                    </td>
                                    <td>
                                        <asp:TextBox ID="msgDetail" runat="server" TextMode="MultiLine" Style="height: 150px;
                                            width: 320px;"></asp:TextBox><span class="ErrMsg">*</span>&nbsp;
                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="msgDetail"
                                            Display="Dynamic" ErrorMessage="Required!" InitialValue="" SetFocusOnError="True"
                                            ValidationGroup="Save" ForeColor="Red">
                                        </asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <asp:Button ID="btnSave" Text="Save" runat="server" OnClick="btnClick_Save" ValidationGroup="Save" />
                                        <asp:Button ID="btnBack" Text="Back" OnClick="btnBack_Click" runat="server" /><br />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>--%>
   