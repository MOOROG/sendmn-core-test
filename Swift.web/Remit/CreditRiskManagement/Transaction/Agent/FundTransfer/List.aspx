<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.FundTransfer.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script src="../../../../../js/swift_grid.js" type="text/javascript"> </script>
    <link href="../../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <script src="../../../../../ui/js/jquery.min.js"></script>
    <link href="../../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../../ui/css/datepicker-custom.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../../js/swift_calendar.js"></script>
    <script src="../../../../../js/swift_autocomplete.js"></script>
    <script src="../../../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../../../ui/js/pickers-init.js"></script>
    <script src="../../../../../ui/js/jquery-ui.min.js"></script>

    <script type="text/javascript">
        function Open(url) {
            var re = PopUpWindow(url, "dialogHeight:1000px;dialogWidth:900px;dialogLeft:150;dialogTop:50;center:yes");
            if (re === 0) {
                window.location.href = "List.aspx";
            }
        }
    </script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Fund Transfer  </li>
                            <li class="active">List</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="Javascript:void(0)" class="selected" aria-controls="home" role="tab" data-toggle="tab">Transfer List</a></li>
                    <li role="presentation"><a href="VerifyList.aspx" aria-controls="home" role="tab" data-toggle="tab">Verify List </a></li>
                    <li role="presentation"><a href="Report.aspx" aria-controls="home" role="tab" data-toggle="tab">Report </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Agent Credit Security Report </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="table-responsive">
                                        <div id='rpt_grid' runat="server" class="gridDiv" enableviewstate="false"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%-- <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
            <tr>
                <td align="left" valign="top" class="bredCrom">Fund Transfer » List
                </td>
            </tr>
            <tr>
                <td height="10" class="shadowBG"></td>
            </tr>
            <tr>
                <td height="10">
                    <div class="tabs">
                        <ul>
                            <li><a href="#" class="selected">Transfer List</a></li>
                            <li><a href="VerifyList.aspx">Verify List</a></li>
                            <li><a href="Report.aspx">Report</a></li>
                        </ul>
                    </div>
                </td>
            </tr>
            <tr>
                <td height="524" valign="top">
                    <div id='rpt_grid' runat="server" enableviewstate="false"></div>
                </td>
            </tr>
        </table>--%>
    </form>
</body>
</html>