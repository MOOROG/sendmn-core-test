<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.CustomerInfo.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../../ui/js/jquery.min.js"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <%--<script src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>--%>
    <script src="../../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../../js/swift_calendar.js"></script>

    <script language="javascript" type="text/javascript">
        function CloseForm(errorCode) {
            window.returnValue = errorCode;
            window.close();
        }
        LoadCalendars();
        function LoadCalendars() {

            ShowCalDefault("#<% =date.ClientID%>");
        }
    </script>
    <style>
        .welcome {
            font-weight: bold;
        }

        table {
            background-color: #f5f5f5 !important;
            color: #000;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper" style="margin-top: -100px;">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>Administration<small></small>
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Customer Setup</a></li>
                            <li><a href="#">Message</a></li>
                            <li class="active"><a href="#">Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="panel panel-default">
                <div class="panel-heading panel-title">
                    <h4>Message Manage</h4>
                </div>
                <div class="panel-body">
                    <table class="table table-condensed">

                        <tr>
                            <td height="20"><span class="welcome"><%=GetCustomerName()%></span></td>
                        </tr>
                        <tr>
                            <td height="524" valign="top">
                                <table class="message table table-condensed">

                                    <tr>
                                        <td></td>
                                        <td>
                                            <asp:Label ID="lblMsg" Font-Bold="true" ForeColor="Red" runat="server" Text=""></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Date:<span class="errormsg">*</span></td>
                                        <td>
                                            <asp:TextBox ID="date" runat="server" CssClass="input form-control" Width="83%"></asp:TextBox>
                                            <%--<cc1:CalendarExtender ID="ce1" runat="server" CssClass="cal_Theme1" TargetControlID="date"></cc1:CalendarExtender>--%>

                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2"
                                                runat="server" ControlToValidate="date" ValidationGroup="static" ErrorMessage="Required!" Display="Dynamic" ForeColor="Red">
                                            </asp:RequiredFieldValidator>
                                            <asp:RangeValidator ID="RangeValidator2" runat="server"
                                                ControlToValidate="date"
                                                MaximumValue="12/31/2100"
                                                MinimumValue="01/01/1900"
                                                Type="Date"
                                                ErrorMessage="* Invalid date"
                                                ValidationGroup="static"
                                                CssClass="errormsg"
                                                SetFocusOnError="true"
                                                Display="Dynamic"> </asp:RangeValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="frmLable">Subject:<span class="errormsg">*</span></td>
                                        <td>
                                            <asp:TextBox ID="subject" runat="server" Width="83%" CssClass="input form-control"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1"
                                                runat="server" ControlToValidate="subject" ValidationGroup="static" ErrorMessage="Required!" Display="Dynamic" ForeColor="Red">
                                            </asp:RequiredFieldValidator>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top" class="frmLable">Description:</td>
                                        <td valign="top">
                                            <asp:TextBox ID="description" runat="server" Width="83%" TextMode="MultiLine" Height="100px" CssClass="input form-control"></asp:TextBox>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td valign="top" class="frmLable">Set Primary:</td>
                                        <td valign="top">
                                            <asp:DropDownList ID="setPrimary" runat="server" CssClass="form-control" Width="83%">
                                                <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                <asp:ListItem Value="N">No</asp:ListItem>
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td>
                                            <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="static" OnClick="btnSave_Click" CssClass="btn btn-primary" TabIndex="5" />
                                            <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                            </cc1:ConfirmButtonExtender>
                                            &nbsp;
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </form>
</body>
</html>