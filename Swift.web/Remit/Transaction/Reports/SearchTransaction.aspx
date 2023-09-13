<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SearchTransaction.aspx.cs" Inherits="Swift.web.Remit.Transaction.Reports.SearchTransaction" %>

<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransaction.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js" type="text/javascript"></script>
    <script src="../../../ui/js/pickers-init.js" type="text/javascript"></script>
    <script src="../../../ui/js/jquery-ui.min.js" type="text/javascript"></script>

    <link href="../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
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
        <asp:HiddenField ID="hdnTranId" runat="server" />

        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                            <li class="active"><a href="SearchTransaction.aspx">Search  Transaction </a></li>
                            <li><a href="SearchPartnerPin.aspx">Search Partner pin  Transaction </a></li>
                        </ol>
                    </div>
                    <div runat="server" id="questionaireDiv1" class="row" style="text-align: right;" visible="false">
                        <div class="col-sm-12">
                            <a href="#" style="color: red; font-size=1.2em; font-weight: bold;" data-toggle="modal" data-target="#questionaireModal">Questiaonaire Answer</a>
                        </div>
                    </div>
                    <div class="panel panel-default" runat="server" id="searchTxnDiv">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search Transaction By</h4>
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
                                        </em></strong><a onclick="PopUpWindow('../ArchiveReports/SearchTransaction/SearchTransaction.aspx','dialogHeight:1000px;dialogWidth:1000px;dialogLeft:300;dialogTop:100;center:yes')" href="#">
                                            <strong><em>click here </em></strong></a><strong>to search in archive!</strong>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 form-group">
                            <div id="divTranDetails" runat="server" visible="false">
                                <div>
                                    <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="true" ShowCommentBlock="true" />

                                    <%--question section begin--%>
                                    <div id="questionaireDiv" runat="server" class="row">
                                        <div class="col-md-12">
                                            <div class="panel panel-default ">
                                                <div class="panel-heading">
                                                    <h4 class="panel-title">Transaction Details
                                                    </h4>
                                                    <div class="panel-actions">
                                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
                                                    </div>
                                                </div>
                                                <div class="panel-body">
                                                    <div id="rpt_grid" runat="server"></div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <%--question section end--%>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal -->
        <div class="modal fade" id="questionaireModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 style="text-align: center" class="modal-title" id="exampleModalLabel">Questionnaire Answer</h1>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div id="rpt_grid1" runat="server"></div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>