<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.InternationalOperation.CreditLimit.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/Swift_grid.js"></script>

    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
          ShowCalFromToUpToToday("#<%=expiryDate.ClientID%>");
        });
        function CallBack(mes) {
            var resultList = ParseMessageToArray(mes);
            alert(resultList[1]);

            if (resultList[0] != 0) {
                return;
            }

            window.returnValue = resultList[2];
            window.close();
        }
    </script>
    <script type="text/javascript">
        function validate() {

        }
    </script>
</head>
<body>
    <form id="form2" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="container-fluid">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('international_operation')">Intl Operation</a></li>
                            <li><a href="#" onclick="return LoadModule('creditrisk')">Credit Risk Management </a></li>
                            <li class="active"><a href="Manage.aspx">Credit Limit</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Credit Limit Details
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <asp:label ID="msg" CssClass="alert alert-success col-md-offset-3" runat="server"></asp:label>
                                </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Currency:</label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="currency" runat="server" CssClass="form-control"></asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="currency" ForeColor="Red"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="country">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Base Limit:</label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="limitAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                     <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="limitAmt" ForeColor="Red"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="country">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Max Limit 	:</label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="maxLimitAmt" runat="server" CssClass="form-control"></asp:TextBox>
                                     <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="maxLimitAmt" ForeColor="Red"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="country">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Per Topup Limit :</label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="perTopUpLimit" runat="server" CssClass="form-control"></asp:TextBox>
                                     <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="perTopUpLimit" ForeColor="Red"
                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="country">
                                    </asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Expiry Date :</label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="expiryDate" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4"></label>
                                <div class="col-md-8">
                                    <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="country"
                                        CssClass="btn btn-primary m-t-25" OnClick="btnSave_Click" />
                                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server" ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSave">
                                    </cc1:ConfirmButtonExtender>
                                    <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-primary m-t-25" OnClick="btnDelete_Click" />
                                    <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                    </cc1:ConfirmButtonExtender>
                                    <input id="btnBack" type="button" value="Back" class="btn btn-primary m-t-25" onclick=" Javascript: history.back(); " />
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
