<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Upload.aspx.cs" Inherits="Swift.web.BillVoucher.VoucherUpload.Upload" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li class="active"><a href="#">Voucher Entry</a></li>
                            <li class="active"><a href="Upload.aspx">Two Entry Batch Upload</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Two Entry Batch Upload
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><a href="#"
                                    class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row" id="divUpload" runat="server">
                                <div class="col-md-12 form-group">
                                    <label class="control-label" for="">
                                        Choose File:
                                    </label>
                                    <asp:FileUpload ID="fileUpload" runat="server" /><a href="/SampleFile/TwoEntryBatchUpload.csv">Sample File</a>
                                </div>
                               <div class="col-md-12 form-group">
                                    <asp:Button ID="btnUpload" runat="server" CssClass="btn btn-primary" Text="Upload" OnClick="btnUpload_Click" />
                                </div>
                            </div>
                            <div class="row" id="tblTempUpload" runat="server">
                                <div class="col-md-12 form-group">
                                    <table class="table table-responsive table-bordered">
                                        <thead>
                                            <tr>
                                                <th>S. No.</th>
                                                <th>AC information</th>
                                                <th><%=Swift.web.Library.GetStatic.ReadWebConfig("currencyMN","") %>  Amount</th>
                                                <th>Tran. Date</th>
                                                <th>Type</th>
                                                <th>File Name</th>
                                                <th>Narration</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tblBody" runat="server">
                                            <tr>
                                                <td colspan="7">No data to view</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="row" id="divBtn" runat="server" visible="false">
                                <div class="col-md-12 form-group">
                                    <asp:Button ID="btnSaveFinal" runat="server" CssClass="btn btn-primary" Text="Save Temp" OnClick="btnSaveFinal_Click" />
                                    <asp:Button ID="btnClearData" runat="server" CssClass="btn btn-primary" Text="Clear Data" OnClick="btnClearData_Click" />
                                </div>
                                <div class="col-md-12 form-group">
                                    <label style="color:red;">Note: In case of large number of data, it might take more time to save. So be patience untill it shows result.</label>
                                </div>
                            </div>
                            <div class="row" id="finalResult" runat="server" visible="false">
                                <div class="col-md-12 form-group">
                                    <table class="table table-responsive table-bordered">
                                        <thead>
                                            <tr>
                                                <th>S. No.</th>
                                                <th>Error Code</th>
                                                <th>Narration</th>
                                                <th>Voucher Number</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tblResult" runat="server">
                                            <tr>
                                                <td colspan="3">No data to view</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="row" id="divReUpload" runat="server" visible="false">
                                <div class="col-md-12 form-group">
                                    <asp:Button ID="btnReUpload" runat="server" CssClass="btn btn-primary" OnClick="btnReUpload_Click" Text="Re Upload" />
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
