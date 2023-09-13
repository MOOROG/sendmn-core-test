<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Input.aspx.cs" Inherits="Swift.web.SwiftSystem.UserManagement.UserMatrix.Input" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace="Swift.web.Library" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <link href="../../../css/swift_component.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script language="javascript" type="text/javascript">
        function showReport() {
            //if (!Page_ClientValidate('rpt'))
            //    return false;
            if (document.getElementById("userName").value == "" || document.getElementById("userName").value == null) {
                alert("Username can not be empty !!");
                return false;
            }
            
            var userName = GetValue("<% = userName.ClientID %>");

            var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=usermatrix" +
                      "&userName=" + userName;
            OpenInNewWindow(url);
            return false;
        }

        function showReportRole() {

            var role = GetValue("<% = role.ClientID %>");

            var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=uRole" +
                      "&role=" + role;
            OpenInNewWindow(url);
            return false;
        }


        function showReportRole2() {

            var role = GetValue("<% = role.ClientID %>");

            var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=uRole2" +
                      "&role=" + role;
            OpenInNewWindow(url);
            return false;
        }

        function showReportFunction() {
            //if (!Page_ClientValidate('usermatrix'))
            //    return false;

            var fn = GetValue("<% = function.ClientID %>");

            var url = "../../../RemittanceSystem/RemittanceReports/Reports.aspx?reportName=uFn" +
                      "&fn=" + fn;
            OpenInNewWindow(url);
            return false;
        }


    </script>

</head>
<body>

    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration</a></li>
                            <li class="active"><a href="Input.aspx">User Matrix Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">User-Function 
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="control-label col-md-3">User Name :</label>
                                <div class="col-md-6">
                                    <asp:TextBox ID="userName" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                <div class="col-md-3">
                                    <asp:RequiredFieldValidator Display="Dynamic" ID="usernameValidator" runat="server" ControlToValidate="userName" ForeColor="Red" ErrorMessage="Required!"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-3">
                                    <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary m-t-25" Text="Show" OnClientClick="return showReport();" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Role-Function 
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="control-label col-md-2">Role :</label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="role" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-12 col-md-offset-2">
                                    <asp:Button ID="btnRole" runat="server" CssClass="btn btn-primary m-t-25" Text="Show User List" OnClientClick="return showReportRole();" />
                                    <asp:Button ID="btnRole2" runat="server" CssClass="btn btn-primary m-t-25" Text="Show Function List" OnClientClick="return showReportRole2();" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default ">
                            <div class="panel-heading">
                                <h4 class="panel-title">Function-Role/User  
                                </h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                  <div class="form-group">
                                <label class="control-label col-md-1">Function :</label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="function" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-6 col-md-offset-1">
                                    <asp:Button ID="btnFunction" runat="server" CssClass="btn btn-primary m-t-25" Text="Show"  OnClientClick="return showReportFunction();" />
                                </div>
                            </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>


       <%-- <% var sl = new SwiftLibrary(); %>
        <% sl.BeginHeaderForGrid("User Management » User Matrix Report", "left"); %>

        <br />
        <div style="padding-top: 0px; width: 700px; height: 100%;">
            <%sl.BeginForm("User-Function");%>

            <table border="0" cellspacing="5" cellpadding="2" class="container" width="300px">
                <tr>
                    <td colspan="2">
                        <asp:Label ID="lblmsg" runat="server" CssClass="Label"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td nowrap="nowrap">
                        <div align="right" class="formLabel">User Name:</div>
                    </td>
                    <td nowrap="nowrap">
                        <asp:TextBox ID="userName" runat="server" CssClass="formText"
                            Width="200px" MaxLength="10"></asp:TextBox>&nbsp;<span class="errormsg">*</span>
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="userName" ForeColor="Red"
                            ValidationGroup="rpt" Display="Dynamic" ErrorMessage="Required!">
                        </asp:RequiredFieldValidator>
                    </td>
                </tr>
                <tr>
                    <td nowrap="nowrap">
                        <div align="right" class="formLabel"></div>
                    </td>
                    <td>
                        <br />
                        <asp:Button ID="BtnSave" runat="server" CssClass="button"
                            Text="Show" ValidationGroup="rpt" OnClientClick="return showReport();" />
                    </td>
                </tr>
            </table>

            <%sl.EndForm();%>
        </div>

        <br />

        <div style="padding-top: 0px; width: 700px; height: 100%;">
            <%sl.BeginForm("Role-Function");%>

            <table border="0" cellspacing="5" cellpadding="2" class="container" width="300px">
                <tr>
                    <td colspan="2">
                        <asp:Label ID="lblMsgRole" runat="server" CssClass="Label"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td nowrap="nowrap">
                        <div align="right" class="formLabel">Role:</div>
                    </td>
                    <td nowrap="nowrap">
                        <asp:DropDownList ID="role" runat="server" CssClass="formLabel"></asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td nowrap="nowrap">
                        <div align="right" class="formLabel"></div>
                    </td>
                    <td>
                        <br />
                        <asp:Button ID="btnRole" runat="server" CssClass="button"
                            Text="Show User List" ValidationGroup="usermatrixRole" OnClientClick="return showReportRole();" />
                        <asp:Button ID="btnRole2" runat="server" CssClass="button"
                            Text="Show Function List" ValidationGroup="usermatrixRole" OnClientClick="return showReportRole2();" />
                    </td>
                </tr>
            </table>

            <%sl.EndForm();%>
        </div>

        <br />

        <div style="padding-top: 0px; width: 700px; height: 100%;">
            <%sl.BeginForm("Function-Role/User");%>

            <table border="0" cellspacing="5" cellpadding="2" class="container" width="300px">
                <tr>
                    <td colspan="2">
                        <asp:Label ID="lblMsgFunction" runat="server" CssClass="Label"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td nowrap="nowrap">
                        <div align="right" class="formLabel">Function:</div>
                    </td>
                    <td nowrap="nowrap">
                        <asp:DropDownList ID="function" runat="server" CssClass="formLabel"></asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td nowrap="nowrap">
                        <div align="right" class="formLabel"></div>
                    </td>
                    <td>
                        <br />
                        <asp:Button ID="btnFunction" runat="server" CssClass="button"
                            Text="Show" ValidationGroup="usermatrixFunction" OnClientClick="return showReportFunction();" />
                    </td>
                </tr>
            </table>

            <%sl.EndForm();%>
        </div>

        <% sl.EndHeaderForGrid(); %>--%>
    </form>
</body>
</html>
