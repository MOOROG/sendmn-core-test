<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UpdateKYC.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.UpdateKYC" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript" language="javascript">

        function CheckFormValidation() {
            var reqField = "ddlMethod,ddlStatus,startDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            //var startDate = GetValue("startDate");
            //var endDate = GetValue("endDate");
            //var acInfo = GetItem("acInfo")[1];
            //var acInfotxt = GetItem("acInfo")[0];
            //window.location.href = "StatementResultDollor.aspx?startDate=" + startDate + "&endDate=" + endDate + "&acNum=" + acInfotxt + "&acName=" + acInfo;

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
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                            <%--              <li class="active"><a href="UpdateKYC.aspx">Customer KYC Update </a></li>--%>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation"><a href="List.aspx">Customer List</a></li>
                        <li role="presentation" class="active"><a href="#">Customer KYC Operation</a></li>
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
                                        <div class="panel-heading">KYC - Process</div>
                                        <div class="panel-body row">
                                            <div class="col-md-6">
                                                <div class="col-md-12" id="msgDiv" runat="server" visible="false" style="background-color: red;">
                                                    <asp:Label ID="msgLabel" runat="server" ForeColor="White"></asp:Label>
                                                </div>
                                                <div class="col-sm-6">
                                                    <div class="form-group">
                                                        <label>Method <span class="errormsg">*</span></label>
                                                        <asp:DropDownList runat="server" ID="ddlMethod" CssClass="form-control"></asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-sm-6">

                                                    <div class="form-group">
                                                        <label>Customer Name </label>
                                                        <asp:TextBox runat="server" ID="customerName" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="col-sm-6">
                                                    <div class="form-group">
                                                        <label>Status <span class="errormsg">*</span></label>
                                                        <asp:DropDownList runat="server" ID="ddlStatus" Name="ddlStatus" CssClass="form-control"></asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-sm-6">

                                                    <div class="form-group">
                                                        <label>Address </label>
                                                        <asp:TextBox runat="server" ID="customerAddress" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="col-sm-6">
                                                    <div class="form-group">
                                                        <label>Date <span class="errormsg">*</span></label>
                                                        <div class="input-group m-b">
                                                            <span class="input-group-addon">
                                                                <i class="fa fa-calendar" aria-hidden="true"></i>
                                                            </span>
                                                            <asp:TextBox ID="startDate" runat="server" CssClass="form-control"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-sm-6">
                                                    <div class="form-group">
                                                        <label>Mobile no</label>
                                                        <asp:TextBox runat="server" ID="mobileNo" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="col-sm-12">
                                                    <div class="form-group">
                                                        <label>Remarks </label>
                                                        <asp:TextBox runat="server" ID="remarks" CssClass="form-control" TextMode="MultiLine"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="col-sm-3">
                                                    <div runat="server">
                                                        <div class="form-group">
                                                            <asp:Button ID="save" runat="server" CssClass="btn btn-primary m-t-25" Text="Save" OnClientClick="return CheckFormValidation()" OnClick="save_Click" />
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="panel-body row">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer KYC Details</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="rpt_grid" runat="server"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%--        <asp:HiddenField runat="server" ID="hdnVerifyDoc1" />
        <asp:HiddenField runat="server" ID="hdnVerifyDoc2" />
        <asp:HiddenField runat="server" ID="hdnVerifyDoc4" />
        <asp:HiddenField runat="server" ID="hdnVerifyDoc3" />
        <asp:HiddenField runat="server" ID="hdnCustomerId" />
        <asp:HiddenField runat="server" ID="hddIdNumber" />
        <asp:HiddenField runat="server" ID="hddOldEmailValue" />
        <asp:HiddenField runat="server" ID="hddTxnsMade" />--%>
    </form>
</body>
</html>