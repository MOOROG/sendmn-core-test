<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Administration.PartnerSetup.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Customer Operation</title>
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery.min.js"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../js/swift_calendar.js"></script>
    <script src="../../../js/functions.js"> </script>
    <script type="text/javascript">
        function CheckFormValidation() {
            reqField = "partnerName,partnerCountryDDL,partnerContact,partnerAddress,";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
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
                            <li><a href="#">Partner Setup</a></li>
                            <li class="active"><a href="#">Manage Partner</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li><a href="List.aspx" aria-controls="home" role="tab" data-toggle="tab">Partner List</a></li>
                        <li role="presentation" class="active"><a href="javascript:void(0);">Manage Partner</a></li>
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
                                        <div class="panel-heading">Personal Information</div>
                                        <div class="panel-body row">
                                            <div class="col-sm-6">
                                                <div class="form-group">
                                                    <label>Partner Names:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="partnerName" runat="server" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-6">
                                                <div class="form-group">
                                                    <label>Partner Country:</label>
                                                    <asp:DropDownList ID="partnerCountryDDL" runat="server" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-12">
                                                <div class="form-group">
                                                    <label>Partner Address:<span class="errormsg">*</span></label>
                                                    <asp:TextBox ID="partnerAddress" runat="server" TextMode="MultiLine" CssClass="form-control" />
                                                </div>
                                            </div>
                                            <div class="col-sm-6">
                                                <div class="form-group">
                                                    <label>Partner Contact:</label>
                                                    <asp:TextBox runat="server" ID="partnerContact" CssClass="form-control">
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
