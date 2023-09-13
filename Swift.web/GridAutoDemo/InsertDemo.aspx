<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InsertDemo.aspx.cs" Inherits="Swift.web.GridAutoDemo.InsertDemo" %>

<%@ Register Src="~/Component/AutoComplete/SwiftTextBox.ascx" TagName="SwiftTextBox" TagPrefix="uc1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../css/TranStyle.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery.validate.min.js" type="text/javascript"></script>
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../js/swift_autocomplete.js"></script>
    <script>
        $(document).ready(function () {
            $(".nepDate").attr("readonly", "readonly");
            CalTillToday(".nepDate");
        });
    </script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <div class="panel">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h1><asp:Label ID="txtPageName" runat="server" Text="Add New Employee"></asp:Label> </h1>
                            </div>
                            <div class="container">
                                <div class="">
                                    <asp:Label runat="server" ID="Msg" Visible="false"></asp:Label>
                                </div>
                                <br />
                                <br />
                                <div class="row">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <asp:TextBox ID="txtId" runat="server" Visible="false" />
                                            <asp:Label ID="Label1" runat="server" Text="Name :"></asp:Label>
                                            <asp:RequiredFieldValidator runat="server" ErrorMessage="*" ForeColor="Red" ControlToValidate="txtName"></asp:RequiredFieldValidator>
                                        </div>
                                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <asp:Label ID="Label2" runat="server" Text="Address :"></asp:Label>
                                        </div>
                                        <uc1:SwiftTextBox ID="txtAddress" Category="remit-ac_mater" Param1="NotClear" runat="server" CssClass="form-control" />
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <asp:Label ID="Label3" runat="server" Text="Email :"></asp:Label>
                                            <asp:RequiredFieldValidator runat="server" ErrorMessage="*" ForeColor="Red" ControlToValidate="txtEmail"></asp:RequiredFieldValidator>
                                        </div>
                                        <asp:TextBox ID="txtEmail" TextMode="Email" CssClass="form-control" runat="server"></asp:TextBox>
                                    </div>
                                </div>
                                <br />
                                <div class="row">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <asp:Label ID="Label5" runat="server" Text="DOB :"></asp:Label>
                                            <asp:RequiredFieldValidator runat="server" ErrorMessage="*" ForeColor="Red" ControlToValidate="txtDob"></asp:RequiredFieldValidator>
                                        </div>
                                        <asp:TextBox ID="txtDob" runat="server" placeholder="MM/DD/YYYY" CssClass="form-control nepDate"></asp:TextBox>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <asp:Label ID="Label6" runat="server" Text="Depart Name :"></asp:Label>
                                            <asp:RequiredFieldValidator runat="server" ErrorMessage="*" ForeColor="Red" ControlToValidate="txtDepName"></asp:RequiredFieldValidator>
                                        </div>
                                        <asp:TextBox ID="txtDepName" CssClass="form-control" runat="server"></asp:TextBox>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <asp:Label ID="Label7" runat="server" Text="Join Date :"></asp:Label>
                                            <asp:RequiredFieldValidator runat="server" ErrorMessage="*" ForeColor="Red" ControlToValidate="txtJoinDate"></asp:RequiredFieldValidator>
                                        </div>
                                        <asp:TextBox ID="txtJoinDate" CssClass="nepDate form-control" placeholder="MM/DD/YYYY" runat="server"></asp:TextBox>
                                    </div>
                                </div>
                                <br />
                                <div class="row">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <asp:Label ID="Label4" runat="server" Text="Mobile No :"></asp:Label>
                                            <asp:RequiredFieldValidator runat="server" ErrorMessage="*" ForeColor="Red" ControlToValidate="txtMobile"></asp:RequiredFieldValidator>
                                        </div>
                                        <asp:TextBox ID="txtMobile" CssClass="form-control" runat="server"></asp:TextBox>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <asp:Label ID="Label8" runat="server" Text="Work Day/Week :"></asp:Label>
                                            <asp:RequiredFieldValidator runat="server" ErrorMessage="*" ForeColor="Red" ControlToValidate="txtWorkDay"></asp:RequiredFieldValidator>
                                        </div>
                                        <asp:TextBox ID="txtWorkDay" CssClass="form-control" runat="server"></asp:TextBox>
                                    </div>
                                    <div class="col-md-4">
                                        <asp:Label ID="Label9" runat="server" Text="Other Detail :"></asp:Label>
                                        <asp:TextBox ID="txtDescription" runat="server"></asp:TextBox>
                                    </div>
                                </div>
                                <br />
                                <div class="col-md-4">
                                    <asp:Button ID="btnAdd" runat="server" CssClass="btn btn-block btn-info" Text="Add New" OnClick="btnAdd_Click" />
                                    <asp:Button ID="btnEdit" runat="server" CssClass="btn btn-block btn-info" Text="Update" Visible="false" OnClick="btnEdit_Click" />
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