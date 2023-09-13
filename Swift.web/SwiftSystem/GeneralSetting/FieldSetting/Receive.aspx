<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Receive.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.FieldSetting.Receive" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox"
    TagPrefix="uc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
   
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    </script>
</head>
<body>
    <form id="form1" runat="server">

        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
                            <li class="active"><a href="Receive.aspx">Field Setting</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation"><a href="List.aspx" aria-controls="home" role="tab" data-toggle="tab">List </a></li>
                    <li role="presentation"><a href="Send.aspx" aria-controls="home" role="tab" data-toggle="tab">Send </a></li>
                    <li role="presentation" class="active"><a href="Javascript:void(0)" class="selected" aria-controls="home" role="tab" data-toggle="tab">Receive</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                      <div class="col-md-6">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Receive</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row">
                                        
                                            <div class="form-group">
                                                <label class="col-lg-4 col-md-4 control-label" for="">
                                                    Receiving Country:<span class="errormsg">*</span>
                                                </label>
                                                <div class="col-lg-8 col-md-8">
                                                    <asp:DropDownList ID="country" runat="server" AutoPostBack="True"
                                                        OnSelectedIndexChanged="country_SelectedIndexChanged" CssClass="form-control">
                                                    </asp:DropDownList>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator26" runat="server" ControlToValidate="country" ForeColor="Red"
                                                        ValidationGroup="Save" Display="Dynamic" ErrorMessage="Required!">
                                                    </asp:RequiredFieldValidator>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-lg-4 col-md-4 control-label" for="">
                                                    Receiving Agent:
                                                </label>
                                                <div class="col-lg-8 col-md-8">
                                                    <asp:DropDownList ID="agent" runat="server" CssClass="form-control"></asp:DropDownList>
                                                </div>
                                            </div>

                                      
                                    </div>
                                    <div class="row">
                                       
                                            <fieldset>
                                                <legend>Field</legend>
                                                <div class="form-group">
                                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                                        ID :
                                                    </label>
                                                    <div class="col-lg-8 col-md-8">
                                                        <asp:DropDownList ID="ddlId" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="ddlId"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                                        DOB:
                                                    </label>
                                                    <div class="col-lg-8 col-md-8">
                                                        <asp:DropDownList ID="ddlDob" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="ddlDob"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                                        Address :
                                                    </label>
                                                    <div class="col-lg-8 col-md-8">
                                                        <asp:DropDownList ID="ddlAddress" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="ddlAddress"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                                        City :
                                                    </label>
                                                    <div class="col-lg-8 col-md-8">
                                                        <asp:DropDownList ID="ddlCity" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="ddlCity"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                                        Contact :
                                                    </label>
                                                    <div class="col-lg-8 col-md-8">
                                                        <asp:DropDownList ID="ddlContact" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="ddlContact"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                                        Native Country :
                                                    </label>
                                                    <div class="col-lg-8 col-md-8">
                                                        <asp:DropDownList ID="ddlNativeCountry" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="ddlNativeCountry"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True" ></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-4 col-md-4 control-label" for="">
                                                        TXN History:
                                                    </label>
                                                    <div class="col-lg-8 col-md-8">
                                                        <asp:DropDownList ID="ddlTxnHistory" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="ddlTxnHistory"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                            </fieldset>
                                        </div>
                             
                                    <div class="row">
                                        <div class="form-group">
                                            <div class="col-md-3 col-md-offset-4">
                                                <asp:Button ID="btnSave" Text="Save" runat="server" ValidationGroup="Save" OnClick="btnSave_Click"  CssClass="btn btn-primary m-t-25"/>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                            <div id="copyPanel" runat="server" visible="false">
                                                <fieldset>
                                                    <legend>Copy To</legend>

                                                    <div class="form-group">
                                                        <label class="col-lg-4 col-md-4 control-label" for="">
                                                            Country :<span class="errormsg">*</span>
                                                        </label>
                                                        <div class="col-lg-8 col-md-8">
                                                            <asp:DropDownList ID="copyToCountry" runat="server" AutoPostBack="True"
                                                                OnSelectedIndexChanged="copyToCountry_SelectedIndexChanged" CssClass="form-control">
                                                            </asp:DropDownList>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator27" runat="server" ControlToValidate="copyToCountry"
                                                                ForeColor="Red" ValidationGroup="copy" Display="Dynamic" ErrorMessage="Required!">
                                                            </asp:RequiredFieldValidator>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-lg-4 col-md-4 control-label" for="">
                                                            Agent:
                                                        </label>
                                                        <div class="col-lg-8 col-md-8">
                                                            <asp:DropDownList ID="copyToagent" runat="server" CssClass="form-control">
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <div class="col-md-3 col-md-offset-4">
                                                            <asp:Button runat="server" ID="copySetting" ValidationGroup="copy" Text="Copy" CssClass="btn btn-primary m-t-25"
                                                                OnClick="copySetting_Click" />
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
                </div>
            </div>
       
    </form>
</body>
</html>


<%--    <div>
      <div class="breadCrumb"> Field Setting » Receive</div>
        <div>
            <table style="width: 100%">
                <tr>
                    <td height="20" class="welcome"><span id="spnCname" runat="server"></span></td>
                </tr>
                <tr>
                    <td height="10"> 
                        <div class="tabs">
                            <ul>
                                <li> <a href="List.aspx"> List </a></li>
                                <li> <a href="Send.aspx"> Send </a></li>
                                <li> <a href="#" class="selected"> Receive </a></li>
                            </ul> 
                        </div> 
                    </td>
                 </tr>   
            </table>
        </div>
      <div>
            <table class="formTable" width="500px">--%>
<%-- <tr>
                        <td class="frmTitle" colspan="2">Receive</td>
                    </tr>
                    <tr>
                        <td>
                            <table style="margin-left:2px">
                                <tr>
                                <td class="frmLable" nowrap="nowrap">
                                    Receiving Country:
                                </td>
                                <td nowrap="nowrap">
                                    <asp:DropDownList ID="country" runat="server" AutoPostBack="True" 
                                        onselectedindexchanged="country_SelectedIndexChanged"></asp:DropDownList>
                                    <span class="errormsg">*</span>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator26" runat="server" ControlToValidate="country" ForeColor="Red" 
                                        ValidationGroup="Save" Display="Dynamic"  ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="frmLable" nowrap="nowrap">
                                    Receiving Agent:
                                </td>--%>
<%--   <td nowrap="nowrap">
                                    <asp:DropDownList ID="agent" runat="server"></asp:DropDownList>
                                </td>
                            </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
--%>
<%--  <fieldset>
                <legend>Field</legend>
                <table>
                    <tr>
                        <td class="frmLable">ID:
                        </td>
                        <td>
                            <asp:DropDownList ID="ddlId" runat="server" Width="160px">
                                <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="ddlId"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>--%>
<%--  <td class="frmLable">DOB:
                        </td>
                        <td>
                            <asp:DropDownList ID="ddlDob" runat="server" Width="160px">
                                <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="ddlDob"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>--%>
<%--  <td class="frmLable">Address:
                        </td>
                        <td>
                            <asp:DropDownList ID="ddlAddress" runat="server" Width="160px">
                                <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="ddlAddress"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>--%>
<%--  <td class="frmLable">City:
                        </td>
                        <td>
                            <asp:DropDownList ID="ddlCity" runat="server" Width="160px">
                                <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="ddlCity"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>--%>
<%--  <td class="frmLable">Contact:
                        </td>
                        <td>
                            <asp:DropDownList ID="ddlContact" runat="server" Width="160px">
                                <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="ddlContact"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>--%>
<%--  <td class="frmLable">Native Country:
                        </td>
                        <td>
                            <asp:DropDownList ID="ddlNativeCountry" runat="server" Width="160px">
                                <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="ddlNativeCountry"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>--%>
<%--    <td class="frmLable">TXN History:
                        </td>
                        <td>
                            <asp:DropDownList ID="ddlTxnHistory" runat="server" Width="160px">
                                <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="ddlTxnHistory"
                                Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                SetFocusOnError="True"></asp:RequiredFieldValidator>
                        </td>
                    </tr>
                </table>
            </fieldset>--%>


<%--  </td>
                    </tr>                    
                <tr>
                    <td>
                        <asp:Button ID="btnSave" Text="Save" runat="server" ValidationGroup="Save" OnClick="btnSave_Click" />
                    </td>
                </tr>
            <tr>
                <td>--%>
<%-- <div id="copyPanel" runat="server" visible="false">
                    <fieldset>
                        <legend>Copy To</legend>
                        <table>
                            <tr>--%>
<%--<td class="frmLable" nowrap="nowrap">Country:
                                </td>
                                <td nowrap="nowrap">
                                    <asp:DropDownList ID="copyToCountry" runat="server" AutoPostBack="True"
                                        OnSelectedIndexChanged="copyToCountry_SelectedIndexChanged">
                                    </asp:DropDownList>
                                    <span class="errormsg">*</span>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator27" runat="server" ControlToValidate="copyToCountry"
                                        ForeColor="Red" ValidationGroup="copy" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </td>
                            </tr>
                            <tr>--%>
<%--  <td class="frmLable" nowrap="nowrap">Agent:
                                </td>
                                <td nowrap="nowrap">
                                    <asp:DropDownList ID="copyToagent" runat="server">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td>&nbsp;
                                </td>


                                <td>--%>
<%--    <asp:Button runat="server" ID="copySetting" ValidationGroup="copy" Text="Copy"
                                        OnClick="copySetting_Click" />
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
                </td>
            </tr>
            </table>
            </div>
        </div>--%>
   