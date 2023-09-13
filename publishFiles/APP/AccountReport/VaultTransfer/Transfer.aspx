<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Transfer.aspx.cs" Inherits="Swift.web.AccountReport.VaultTransfer.Transfer" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script type="text/javascript">
        //$(document).ready(function () {
        //    ShowCalFromToUpToToday("#transferDate");
        //});

        function Transfer_Clicked() {
            var reqField = "introducerTxt,amount,paymentModeDDL,bankOrBranchDDL";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
        };

        $(document).ready(function () {
            $('#introducerTxt').blur(function () {
                if ($(this).val() != '') {
                    ValidateReferral();
                }
            });
        });
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
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="Manage.aspx">Transit Cash Management</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <asp:UpdatePanel ID="up1" runat="server">
                            <ContentTemplate>
                                <div class="register-form">
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">Transit Cash Management</div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="form-group">
                                                    <div class="col-md-2">
                                                        <label>Referal Code:</label>
                                                    </div>
                                                    <div class="col-md-3">
                                                        <asp:TextBox ID="introducerTxt" runat="server" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">
                                                    <div class="col-md-2">
                                                        <label>Choose Payment Mode</label>
                                                    </div>
                                                    <div class="col-md-3">
                                                        <asp:DropDownList ID="paymentModeDDL" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="paymentModeDDL_SelectedIndexChanged">
                                                            <asp:ListItem Text="Select" Value=""></asp:ListItem>
                                                            <asp:ListItem Text="Bank" Value="b"></asp:ListItem>
                                                            <asp:ListItem Text="Cash Tailor" Value="ct"></asp:ListItem>
                                                            <asp:ListItem Text="Cash Vault" Value="cv"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">
                                                    <div class="col-md-2">
                                                        <label>Bank/Branch Name</label>
                                                    </div>
                                                    <div class="col-md-3">
                                                        <asp:DropDownList ID="bankOrBranchDDL" runat="server" CssClass="form-control">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">
                                                    <div class="col-md-2">
                                                        <label>Amount:<span class="errormsg">*</span></label>
                                                    </div>
                                                    <div class="col-md-3">
                                                        <asp:TextBox ID="amount" runat="server" CssClass="form-control" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">
                                                    <div class="col-md-2">
                                                        <label>Date:<span class="errormsg">*</span></label>
                                                    </div>
                                                    <div class="col-md-3">
                                                        <asp:TextBox ReadOnly="true" autocomplete="off" ID="transferDate" runat="server" onchange="return DateValidation('transferDate','t')" MaxLength="10" CssClass="form-control form-control-inline input-medium "></asp:TextBox>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">
                                                    <div class="col-md-offset-2 col-md-3">
                                                        <asp:Button ID="transferButton" Text="Transfer" runat="server" OnClientClick="return Transfer_Clicked()" OnClick="transferButton_Click" CssClass="btn btn-primary m-t-25" />
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>