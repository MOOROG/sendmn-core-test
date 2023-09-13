<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DocumentUpload.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.CustomerInfo.DocumentUpload" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <script type="text/javascript" language="javascript">
        function Delete(rowId) {
            if (confirm("Are you sure to delete?")) {
                if (rowId == "undefined" || rowId == null)
                    return false;
            }
            GetElement("<%=hdnRowId.ClientID %>").value = rowId;
            GetElement("<% =btnDelete.ClientID %>").click();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnRowId" runat="server" />
        <asp:Button runat="server" ID="btnDelete" OnClick="btnDelete_Click" Style="display: none" />
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper" style="margin-top: -100px;">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                            <li class="active"><a href="Manage.aspx">Customer Setup </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
                <%--     <tr>
                    <td width="100%">
                        <asp:Panel ID="pnl1" runat="server" Visible="false">
                            <table width="100%">
                                <tr>
                                    <td height="20"><span style="font-weight: bold;"></span></td>
                                </tr>
                            </table>
                        </asp:Panel>
                    </td>
                </tr>
                --%>
                <tr>
                    <td>
                        <div class="listtabs">
                            <ul class="nav nav-tabs" role="tablist">
                                <li><a href="../Manage.aspx?customerId=<%=GetCustomerId()%>&mode=1">Customer </a></li>
                                <li class="active"><a href="#" class="selected">Documents </a></li>
                                <li><a href="List.aspx?customerId=<%=GetCustomerId()%>&section=<%=GetSection()%>">Message </a></li>
                            </ul>
                        </div>
                    </td>
                </tr>
                <tr>
                    <asp:Panel ID="pnl1" runat="server" Visible="false">
                        <td>
                            <div class="panel panel-default">

                                <div class="panel-heading">
                                    Document (<%=GetCustomerName()%>)
                                </div>

                                <div class="panel-body">
                                    <table class="table table-condensed">
                                        <tr>
                                            <td>Document:<br />
                                                <input id="fileUpload" runat="server" name="fileUpload" type="file" width="300px" class="input" />
                                            </td>
                                            <td>File Description:<br />
                                                <asp:DropDownList runat="server" ID="fileDescription">
                                                    <asp:ListItem Value="Enrollform">Enrollment Form</asp:ListItem>
                                                    <asp:ListItem Value="IdCard">Citizenship-1</asp:ListItem>
                                                    <asp:ListItem Value="IdCard_2">Citizenship-2</asp:ListItem>
                                                    <asp:ListItem Value="Photo">Photo</asp:ListItem>
                                                </asp:DropDownList>
                                                &nbsp;<asp:Button ID="btnUpload" runat="server" Text="Upload" CssClass="btn btn-primary"
                                                    OnClick="btnUpload_Click" />
                                            </td>
                                        </tr>

                                        <tr>
                                            <td>
                                                <asp:Label ID="lblMsg" Font-Bold="true" ForeColor="Red" runat="server" Text=""></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Table ID="tblResult" runat="server" Width="100%"></asp:Table>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </td>
                    </asp:Panel>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>