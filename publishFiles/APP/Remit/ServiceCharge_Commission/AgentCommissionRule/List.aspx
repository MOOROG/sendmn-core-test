<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Commission.AgentCommissionRule.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" runat="server" target="_self" />
    <!-- Bootstrap -->
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />

    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>


    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                            <li><a href="#" onclick="return LoadModule('servicecharge_and_commission')">Service Charge and Comission </a></li>
                            <li class="active"><a href="List.aspx">Agent Commissin Rule</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Agent Commission Rule</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <table class="table table-responsive table-bordered table-striped">
                                <tr>
                                    <td valign="top">
                                        <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
<script type="text/javascript">
    function Autocomplete() {
        var urla = "../../../Autocomplete.asmx/GetAgentNameList";
        $("#grdAcr_agentName").autocomplete({
            source: function (request, response) {
                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: urla,
                    data: "{'keywordStartsWith':'" + request.term + "'}",
                    dataType: "json",
                    async: true,

                    success: function (data) {
                        response(data.d);
                        window.parent.resizeIframe();
                    },

                    error: function (result) {
                        alert("Due to unexpected errors we were unable to load data");
                    }

                });
            },
            minLength: 1,

            select: function (event, ui) {
                var result = ui.item.value.split("|");
                var res = ui.item.value;
                SetValueById("grdAcr_agentName", result[0], "");
            }

        });
    }
    Autocomplete();
</script>
