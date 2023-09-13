<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AgentPanel.CustomerInquery.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <!-- Bootstrap Core CSS -->
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../js/functions.js"></script>
    <script type="text/javascript" src="../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../ui/bootstrap/js/bootstrap.min.js"></script>

    <style type="text/css">
        .label {
            color: #979797 !important;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>

        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Support </a></li>
                            <li class="active"><a href="SearchTransaction.aspx">Inquiry</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li class="active"><a href="#" aria-controls="home" role="tab" data-toggle="tab">Customer Inquiry </a></li>
                    <li><a href="InquiryReport.aspx">Inquiry Report </a></li>
                </ul>
            </div>
            <div class="row">
                <div class="col-md-6" id="heading" runat="server">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search Customer Inquiry</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="divSearch" runat="server">
                                <div class="row">
                                    <div class="form-group">
                                        <label class="col-lg-2 col-md-5 control-label">
                                            <b>Mobile Number <span class="errormsg">*</span></b> :
												<asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="required" ForeColor="Red"
                                                    ValidationGroup="search" ControlToValidate="MobileNo"></asp:RequiredFieldValidator>
                                        </label>
                                        <div class="col-lg-10 col-md-7">
                                            <asp:TextBox ID="MobileNo" runat="server" placeholder="Enter customer mobile number" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-2 col-md-5 control-label">
                                        </label>
                                        <div class="col-lg-10 col-md-7">
                                            <asp:Button ID="btnSearch" runat="server" Text="Search" ValidationGroup="search" CssClass="btn btn-primary m-t-25"
                                                OnClick="btnSearch_Click" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row" id="divTranDetails" runat="server" visible="false">
                <div class="col-md-6" id="Div2" runat="server">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer Inquiry (Trouble Ticket)</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="div3" runat="server">
                                <div class="row">
                                    <div class="form-group">
                                        <div class="col-lg-12 col-md-12">
                                            <div id="rptLog" runat="server"></div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-lg-6 col-md-6">
                                            Country : 
                                        <asp:DropDownList ID="country" runat="server" class="form-control">
                                        </asp:DropDownList>
                                        </div>
                                        <div class="col-lg-6 col-md-6">
                                            Inquiry Type : 
                                        <asp:DropDownList ID="msgType" runat="server" class="form-control">
                                            <asp:ListItem Value="Inquiry"> Inquiry </asp:ListItem>
                                            <asp:ListItem Value="Complain"> Complain </asp:ListItem>
                                        </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-lg-12 col-md-12">
                                            <asp:TextBox runat="server" ID="comments" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-lg-12 col-md-12">
                                            <asp:Button ID="btnAdd" runat="server" CssClass="btn btn-primary" Text="Add New Complain" OnClick="btnAdd_Click" />
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
