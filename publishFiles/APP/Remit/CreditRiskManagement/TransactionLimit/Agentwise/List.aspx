<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.CreditRiskManagement.TransactionLimit.Agentwise.List" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../../js/swift_autocomplete.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Credit Risk Management </li>
                            <li>Transaction Limit  </li>
                            <li>Agent Wise</li>
                            <li class="active">List  </li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="Javascript:void(0)" class="selected" aria-controls="home" role="tab" data-toggle="tab">Agent Wise</a></li>
                </ul>
            </div>

            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title"></h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>

                                <div class="panel-body">
                                    <div class="table-responsive">
                                        <div id="rpt_grid" runat="server" class="gridDiv"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%-- <table width="90%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td width="100%">
                <asp:Panel ID="pnl1" runat="server">
                    <table width="100%">
                        <tr>
                            <td height="26" class="bredCrom"> <div > Credit Risk Management » Transaction Limit » Agent Wise » List </div> </td>
                        </tr>
                        <tr>
                            <td height="10" width="100%">
                                <div class="tabs">
                                    <ul>
                                        <li> <a href="Javascript:void(0)" class="selected">Agent Wise </a></li>
                                    </ul>
                                </div>
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td height="524" valign="top">
                <div id = "rpt_grid" runat = "server" class = "gridDiv"></div>
            </td>
        </tr>
    </table>--%>
    </form>
</body>
<script type="text/javascript">
    function Autocomplete() {
        var url = "../../../../Autocomplete.asmx/GetDomesticAgentNameOnly";

        $("#gridAgentWise_agentName").autocomplete({

            source: function (request, response) {
                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: url,
                    data: "{'keywordStartsWith':'" + request.term + "'}",
                    dataType: "json",
                    async: true,

                    success: function (data) {
                        response(
                            $.map(data.d, function (item) {
                                return {
                                    value: item.Value,
                                    key: item.Key
                                };
                            }));
                    },

                    error: function (result) {
                        alert("Due to unexpected errors we were unable to load data");
                    }

                });
            },

            minLength: 2,

            select: function (event, ui) {
                var value = ui.item.value;
                var key = ui.item.key;
                //                SetValueById("agentUserList_agentName", value, "");
            }
        });
    }

    Autocomplete();
</script>
</html>