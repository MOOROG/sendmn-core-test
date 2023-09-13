<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SearchTransaction.aspx.cs" Inherits="Swift.web.AgentPanel.SearchTxnReport.SearchTransaction" %>

<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTran.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
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
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('agentPanel')">Agent Report</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction Report </a></li>
                            <li class="active"><a href="SearchTransaction.aspx">Search  Transaction </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Searched Transaction
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="divControlno" runat="server">
                                <div class="row">
                                    <div class="col-md-6 ">
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">
                                                <b>
                                                    <asp:Label ID="controlNoName" runat="server"></asp:Label></b> :
                                            </label>
                                            <div class="col-md-7    ">
                                                <asp:TextBox ID="controlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-md-3 control-label">Tran Id : </label>
                                            <div class="col-md-7">
                                                <asp:TextBox ID="txnNo" runat="server" CssClass="form-control" MaxLength="9"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div class="col-md-4 col-md-offset-3">
                                                <asp:Button ID="btnSearch" runat="server" Text="Search" ValidationGroup="search" CssClass="btn btn-primary m-t-25"
                                                    OnClick="btnSearch_Click" />
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row form-group">
                                    <div class="col-md-10">
                                        <strong><em>NOTE</em>: 90 days or Older Transactions are archived, please<em>
                                        </em></strong><a onclick="PopUpWindow('/Remit/Transaction/ArchiveReports/SearchTransaction/SearchTransaction.aspx','dialogHeight:1000px;dialogWidth:1000px;dialogLeft:300;dialogTop:100;center:yes')" href="#">
                                            <strong><em>click here </em></strong></a><strong>to search in archive!</strong>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12 form-group">
                                    <div id="divTranDetails" runat="server" visible="false">
                                        <div>
                                            <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="true" />
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