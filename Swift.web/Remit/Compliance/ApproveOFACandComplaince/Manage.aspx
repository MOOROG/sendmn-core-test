<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Compliance.ApproveOFACandComplaince.Manage" %>

<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransaction.ascx" %>

<!DOCTYPE html>
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

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remit')">Remit</a></li>
                            <li><a href="#" onclick="return LoadModule('remit_compliance')">Compliance </a></li>
                            <li class="active"><a href="List.aspx">Approve List</a></li>
                        </ol>
                    </div>
                    <div runat="server" id="questionaireDiv" class="row" style="text-align: right;" visible="false">
                        <div class="col-sm-12">
                            <a href="#" style="color: red; font-size=1.2em; font-weight: bold;" data-toggle="modal" data-target="#questionaireModal">Questionnaire Answer</a>
                        </div>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="Dashboard.aspx" target="_self">Dashboard </a></li>
                    <li><a href="List.aspx" target="_self">OFAC/Compliance Hold : International </a></li>
                    <li><a href="PayTranCompliance.aspx" target="_self">Compliance Hold Pay</a></li>
                    <li><a href="PayTranOfacList.aspx" target="_self">OFAC Pay</a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Approve</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Approve OFAC/Compliance List
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <div id="divTranDetails" runat="server" visible="false">
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
                        <div id="rpt_grid" runat="server"></div>
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
