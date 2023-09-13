<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewTxnDetail.aspx.cs" Inherits="Swift.web.AgentNew.SearchTxnReport.ViewTxnDetail" %>

<!DOCTYPE html>
<%@ Import Namespace="Swift.web.Library" %>
<%@ Register Src="~/Remit/UserControl/UcTransaction.ascx" TagName="UcTransaction" TagPrefix="uc1" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" />
    <%--    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />--%>
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <%--<script src="../js/jQuery/jquery.min.js"></script>--%>
    <script src="/ui/bootstrap/js/bootstrap.min.js" type="text/javascript"> </script>
    <script src="/AgentNew/js/functions.js"></script>
    <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper" style="display:none;">
        <div class="row">
            <div class="col-sm-12">
                <div class="page-title">
                    <h1></h1>
                    <ol class="breadcrumb">
                        <li><a href="/Agent/AgentMain.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#" onclick="return LoadModuleAgentMenu('other_services')">Other Services</a></li>
                        <li class="active"><a href="ModifyTran.aspx">Search Transaction</a></li>
                    </ol>
                </div>
            </div>
        </div>


        <div class="row">
            <div id="divSearch" runat="server">
                <div class="panel panel-default">
                    <div class="panel-heading">Search Transaction For Modification & View</div>
                    <div class="panel-body">
                        <div class="col-md-8">
                            <div class="form-group">
                                <div class="col-md-2">
                                    <label class="control-label">
                                        <span align="right" class="formLabel"><%=GetStatic.GetTranNoName() %>.:</span>
                                    </label>
                                </div>
                                <div class="col-md-5">
                                    <asp:TextBox ID="controlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-2">
                                    <label class="control-label">
                                        Tran No:
                                    </label>
                                </div>
                                <div class="col-md-5">
                                    <asp:TextBox ID="tranId" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <asp:HiddenField ID="hdnControlNo" runat="server" />
                <asp:HiddenField ID="hdnHoldTranId" runat="server" />
                <asp:Button ID="btnClick" OnClientClick="ShowQuestionaire()" runat="server" OnClick="btnClick_Click" Style="display: none;" />
                <asp:HiddenField ID="hdnStatus" runat="server" />
            </div>

            <div class="">
                <div id="divLoadGrid" runat="server" visible="false"></div>
            </div>
        </div>
        <div runat="server" id="questionaireDiv1" class="row" style="text-align: right;" visible="false">
            <div class="col-sm-12">
                <a href="#" style="color: red; font-size=1.2em; font-weight: bold;" data-toggle="modal" data-target="#questionaireModal">Questionnaire Answer</a>
            </div>
        </div>
    </div>
    <div id="divTranDetails" runat="server" visible="false">

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

    <!-- Button trigger modal -->

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
