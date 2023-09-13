<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DynamicPopupManage.aspx.cs"
    Inherits="Swift.web.SwiftSystem.GeneralSetting.MessageSetting.DynamicPopupManage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
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
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script type="text/javascript" language="javascript">
        $(function () {
            $(".calendar2").datepicker({
                changeMonth: true,
                changeYear: true,
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true
            });
        });

        $(function () {
            $(".calendar1").datepicker({
                changeMonth: true,
                changeYear: true,
                showOn: "button",
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true
            });
        });

        $(function () {
            $(".fromDatePicker").datepicker({
                defaultDate: "+1w",
                changeMonth: true,
                changeYear: true,
                numberOfMonths: 1,
                showOn: "button",
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true,
                onSelect: function (selectedDate) {
                    $(".toDatePicker").datepicker("option", "minDate", selectedDate);
                }
            });

            $(".toDatePicker").datepicker({
                defaultDate: "+1w",
                changeMonth: true,
                changeYear: true,
                numberOfMonths: 1,
                showOn: "button",
                buttonImage: "/images/calendar.gif",
                buttonImageOnly: true,
                onSelect: function (selectedDate) {
                    $(".fromDatePicker").datepicker("option", "maxDate", selectedDate);
                }
            });
        });
    </script>
    <script type="text/javascript">

        function Delete(rowId, tblGroup) {
            if (rowId != "") {
                if (!confirm("Are you sure to delete?"))
                    return false;
                document.getElementById("<% =tempRowId.ClientID%>").value = rowId;
                document.getElementById("<% =tblGroup.ClientID%>").value = tblGroup;
            }
        }
        function DeleteDoc(rowId) {
            if (rowId != "") {

                if (!confirm("Are you sure to delete?"))
                    return false;

                document.getElementById("<% =tempRowId.ClientID%>").value = rowId;
                document.getElementById("<% =deleteDoc.ClientID%>").click();
            }
        }

        function OpenImagess(img) {
            window.open(img, "", "width=825,height=500,resizable=1,status=1,toolbar=0,scrollbars=1,center=1");
        }
        function pageLoadonDemand() {
            var ctrl = document.getElementById("txtPageLoad");
            ctrl.value = "reload";
            __doPostBack('txtPageLoad', '');
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <%--<div runat="server" id="uploadBlock">--%>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
                            <li class="active"><a href="DynamicPopupManage.aspx">Message Setting</a></li>
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
                    <li><a href="ListMessageBroadCast.aspx" target="_self">Broadcast</a></li>
                    <li><a href="DynamicPopupList.aspx" target="_self">Dynamic Popup</a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Manage</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Dynamic Pop up Message
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label class="col-lg-5 col-md-5 control-label" for="">
                                            <asp:Label ID="lblMsg" runat="server"></asp:Label>
                                        </label>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            Scope:
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <asp:CheckBox ID="chkAdmin" runat="server" />
                                            Admin
                                            <asp:CheckBox ID="chkAgent" runat="server" />
                                            Agent
                                            <asp:CheckBox ID="chkAgentIntl" runat="server" />Agent International
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            Is Enable:
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <asp:CheckBox ID="isEnable" runat="server" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            Document :
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <input id="fileUpload" runat="server" name="docUpload" type="file" width="750px"
                                                height="350px" />
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="fileUpload"
                                                ForeColor="Red" ValidationGroup="upload" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            File Description:
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <asp:TextBox ID="fileDescription" runat="server" Width="210px" CssClass="form-control"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="fileDescription"
                                                ForeColor="Red" ValidationGroup="upload" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            Link :
                                        </label>
                                        <div class="col-lg-5 col-md-5">
                                            <asp:TextBox ID="imageLink" runat="server" Width="210px" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            Dispaly Date:
                                        </label>
                                        <div class="col-lg-3 col-md-3">
                                            From : <span class="errormsg">*</span>
                                            <div class="input-group m-b">
                                                <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                <asp:TextBox ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate"
                                                    ForeColor="Red" ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                            </div>
                                        </div>
                                        <div class="col-lg-3 col-md-3">
                                            To : <span class="errormsg">*</span>
                                            <div class="input-group m-b">
                                                <span class="input-group-addon"><i class="fa fa-calendar" aria-hidden="true"></i></span>
                                                <asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="toDate"
                                                    ForeColor="Red" ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-1 col-md-2 control-label" for="">
                                            &nbsp;
                                        </label>
                                        <div class="col-lg-3 col-md-3">
                                            <asp:Button runat="server" ValidationGroup="upload" ID="uploadFIle" Text="Upload" CssClass="btn btn-primary m-t-25"
                                                OnClick="uploadFIle_Click" />
                                            <asp:Button runat="server" ID="deleteDoc" Text="Delete Doc" OnClick="deleteDoc_Click" CssClass="btn btn-primary m-t-25"
                                                Style="display: none" />
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <asp:HiddenField ID="hdnRowId" runat="server" />
                                        <asp:HiddenField runat="server" ID="tempRowId" />
                                        <asp:HiddenField runat="server" ID="tblGroup" />
                                    </div>

                                    <div class="col-md-12">
                                        <div id="docDisplay" runat="server">
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

<%-- <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0" style="margin-top:110px">
            <tr>
                <td height="26" class="bredCrom">
                    <div>
                        Application Setting » Message Setting » Dynamic Pop up Message » Manage</div>
                </td>
            </tr>
            <tr>
                <td height="10" class="shadowBG">
                </td>
            </tr>
            <tr>
                <td height="10">
                    <div class="tabs">
                        <ul>--%>
<%--    <li><a href="ListHeadMsg.aspx">Head </a></li>
                            <li><a href="ListMessage1.aspx">Common</a></li>
                            <li><a href="ListMessage2.aspx">Country</a></li>
                            <li><a href="ListNewsFeeder.aspx">News Feeder </a></li>
                            <li><a href="ListEmailTemplate.aspx">Email Template</a></li>
                            <li><a href="ListMessageBroadCast.aspx">Broadcast</a></li>
                            <li><a href="DynamicPopupList.aspx" class="selected">Dynamic Popup</a></li>
                            <li><a href="Javascript:void(0)" class="selected">Manage</a></li>
                        </ul>
                    </div>
                </td>
            </tr>
            <tr>
                <td>--%>
<%--  <table border="0" cellspacing="0" cellpadding="0" align="left" class="formTable">
                        <tr>
                            <th class="frmTitle" colspan="3">
                                Dynamic Pop up Message
                            </th>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <asp:Label ID="lblMsg" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>--%>
<%--  <td nowrap="nowrap" class="frmLable">
                                Scope:
                            </td>
                            <td>
                                <asp:CheckBox ID="chkAdmin" runat="server" />
                                Admin
                                <asp:CheckBox ID="chkAgent" runat="server" />
                                Agent
                                <asp:CheckBox ID="chkAgentIntl" runat="server" />Agent International
                            </td>
                        </tr>
                        <tr>--%>
<%--   <td nowrap="nowrap" class="frmLable">
                                Is Enable :
                            </td>
                            <td>
                                <asp:CheckBox ID="isEnable" runat="server" />
                            </td>
                        </tr>
                        <tr>--%>
<%--<td nowrap="nowrap" class="frmLable">
                                Document:
                            </td>
                            <td nowrap="nowrap">
                                <input id="fileUpload" runat="server" name="docUpload" type="file" width="750px"
                                    height="350px" />
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="fileUpload"
                                    ForeColor="Red" ValidationGroup="upload" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%--    <td class="frmLable">
                                File Description:<br />
                            </td>
                            <td class="style1">
                                <asp:TextBox ID="fileDescription" runat="server" Width="210px" CssClass="input"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="fileDescription"
                                    ForeColor="Red" ValidationGroup="upload" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%--  <td>
                                Link:
                            </td>
                            <td>
                                <asp:TextBox ID="imageLink" runat="server" Width="210px" CssClass="input"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>--%>
<%--  <td>
                                Dispaly Date
                            </td>
                            <td>
                                From<br />
                                <asp:TextBox ID="fromDate" runat="server" class="fromDatePicker"
                                    size="12" Width="80px"></asp:TextBox>
                                <span class="errormsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="fromDate"
                                    ForeColor="Red" ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                            </td>--%>
<%--    <td>
                                To<br />
                                <asp:TextBox ID="toDate" runat="server" class="toDatePicker" size="12"
                                    Width="80px"></asp:TextBox>
                                <span class="errormsg">*</span>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="toDate"
                                    ForeColor="Red" ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%--   <td>
                            </td>
                            <td>
                                <asp:Button runat="server" ValidationGroup="upload" ID="uploadFIle" Text="Upload"
                                    OnClick="uploadFIle_Click" />
                                <asp:Button runat="server" ID="deleteDoc" Text="Delete Doc" OnClick="deleteDoc_Click"
                                    Style="display: none" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>--%>
<%--<asp:HiddenField ID="hdnRowId" runat="server" />
            <asp:HiddenField runat="server" ID="tempRowId" />
            <asp:HiddenField runat="server" ID="tblGroup" />--%>
<%-- <tr>
                <td colspan="3">
                    <div id="docDisplay" runat="server">
                    </div>
                </td>
            </tr>--%>
<%-- <tr>
                <td colspan="3">
                    <asp:TextBox ID="txtPageLoad" Style="display: none;" runat="server" AutoPostBack="true"></asp:TextBox>
                </td>
            </tr>
        </table>
--%>