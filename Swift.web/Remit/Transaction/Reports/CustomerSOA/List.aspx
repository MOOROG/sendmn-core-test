<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.CustomerSOA.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script type="text/javascript" src="../../../../ui/js/jquery.min.js"></script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="../../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../../ui/js/pickers-init.js"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>

    

</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Reports</a></li>
                            <li class="active"><a href="List.aspx">Customer SOA</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer Statement Of Account
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-md-2">From Date:</label>
                                <div class="col-md-6">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="fromDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <asp:RequiredFieldValidator ID="dateFrom" runat="server" ControlToValidate="fromDate" ErrorMessage="Required!" ForeColor="Red" ValidationGroup="soa"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-2">To Date :</label>
                                <div class="col-md-6">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="toDate" runat="server" CssClass="form-control form-control-inline input-medium default-date-picker"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <asp:RequiredFieldValidator ID="dateTo" runat="server" ControlToValidate="toDate" ErrorMessage="Required!" ForeColor="Red" ValidationGroup="soa"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-2">Customer Email :</label>
                                <div class="col-md-6">
                                    <asp:TextBox ID="email" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-md-4">
                                    <asp:RequiredFieldValidator ID="cusEmail" runat="server" ControlToValidate="email" ErrorMessage="Required!" ForeColor="Red" ValidationGroup="soa"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-2">Soa Type :</label>
                                <div class="col-md-6">
                                    <asp:DropDownList ID="soaType" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="">Select</asp:ListItem>
                                        <asp:ListItem Value="soaDetail">Soa-Detail</asp:ListItem>
                                        <asp:ListItem Value="soaSummary">Soa-Summary</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <asp:RequiredFieldValidator ID="soa" runat="server" ControlToValidate="soaType" ErrorMessage="Required!" ForeColor="Red" ValidationGroup="soa"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-2"></label>
                                <div class="col-md-3">
                                    <asp:Button Text="Search" ID="btnSearch" runat="server" CssClass="btn btn-primary m-t-25" OnClick="btnSearch_Click" ValidationGroup="soa" />
                                </div>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="SoaDetailDiv" runat="server" visible="false">
                                <table class="table table-responsive table-bordered table-striped">
                                    <thead>
                                        <tr>
                                            <th>Control No</th>
                                            <th>Collected Amount</th>
                                            <th>Transfer Amount</th>
                                            <th>Payout Amoun</th>
                                            <th>Service Charge</th>
                                            <th>Sender Name</th>
                                            <th>Reciever Name</th>
                                            <th>Creaed Date</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tblSoaDetail" runat="server">
                                    </tbody>
                                </table>
                            </div>
                            <div id="SoaSummaryDiv" runat="server" visible="false">
                                <table class="table table-responsive table-bordered table-striped">
                                    <thead>
                                        <tr>
                                            <th>Collected Amount</th>
                                            <th>Transfer Amount</th>
                                            <th>Payout Amoun</th>
                                            <th>Service Charge</th>
                                            <th>Creaed Date</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tblSoaSummary" runat="server">
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
