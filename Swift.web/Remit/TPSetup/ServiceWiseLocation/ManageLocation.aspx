<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageLocation.aspx.cs" Inherits="Swift.web.Remit.TPSetup.ServiceWiseLocation.ManageLocation" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Location Setup</title>
        <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script type="text/javascript">
        function CheckFormValidation() {
            reqField = "countryDDL,partnerLocation,";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Partner Setup</a></li>
                            <li class="active"><a href="#">Service Wise Location</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li><a href="List.aspx">Service Wise Location List</a></li>
                        <li role="presentation" class="active"><a href="javascript:void(0);" aria-controls="home" role="tab" data-toggle="tab">Manage Service Wise Location</a></li>
                    </ul>
                </div>
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="row">
                            <div class="col-sm-12 col-md-12">
                                <div class="register-form">
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">Service Wise Location</div>
                                        <div class="panel-body row">
                                            <asp:UpdatePanel ID="up1" runat="server">
                                                <ContentTemplate>
                                                    <div class="col-sm-6">
                                                        <div class="form-group">
                                                            <label>Country:<span class="errormsg">*</span></label>
                                                            <asp:DropDownList ID="countryDDL" runat="server" AutoPostBack="true" OnSelectedIndexChanged="countryDDL_SelectedIndexChanged" CssClass="form-control" />
                                                        </div>
                                                    </div>
                                                    <div class="col-sm-6">
                                                        <div class="form-group">
                                                            <label>Service Type:<span class="errormsg">*</span></label>
                                                            <asp:DropDownList ID="serviceTypeDDL" runat="server" CssClass="form-control" >
                                                                <asp:ListItem Text="Please select country first" Value=""></asp:ListItem>
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                            <div class="col-sm-12">
                                                <div class="form-group">
                                                    <label>Partner Location:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="partnerLocation" runat="server" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-6">
                                                <div class="form-group">
                                                    <label>Partner Location Code:</label>
                                                    <asp:TextBox runat="server" ID="partnerLocationCode" CssClass="form-control">
                                                    </asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-sm-6">
                                                <div class="form-group">
                                                    <label>Is Active:</label>
                                                    <asp:DropDownList runat="server" ID="isActive" CssClass="form-control">
                                                        <asp:ListItem Text="Active" Value="1"></asp:ListItem>
                                                        <asp:ListItem Text="In-Active" Value="0"></asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-sm-12" runat="server">
                                                <div class="form-group">
                                                    <asp:Button ID="saveData" runat="server" CssClass="btn btn-primary m-t-25" Text="Submit" OnClientClick="return CheckFormValidation()" OnClick="saveData_Click" />
                                                </div>
                                            </div>
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
