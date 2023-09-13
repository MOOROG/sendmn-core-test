<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VerifyList.aspx.cs" Inherits="Swift.web.Remit.Transaction.Agent.FundTransfer.VerifyList" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script src="../../../../../ui/js/jquery.min.js" type="text/javascript"></script>
    <script src="../../../../../ui/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="../../../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../../../js/swift_calendar.js"></script>
    <script src="../../../../../ui/js/metisMenu.min.js"></script>
    <script src="../../../../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../../../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <script type="text/javascript">
        function Open(url) {
            var re = showModalDialog(url);
            if (re === 0) {
                window.location.href = "VerifyList.aspx";
            }
        }
    </script>
    <script type="text/javascript">
         $(document).ready(function () {
             //  alert("hell");
             ShowCalFromTo("#grdfundtransferadmin_toDate","#grdfundtransferadmin_fromDate", 1);
         });
    </script>
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
                    <li><a href="List.aspx" target="_self">Transfer List</a></li>
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">Verify List </a></li>
                    <li><a href="Report.aspx" target="_self">Report </a></li>
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
                                        <div id='rpt_grid' runat="server" enableviewstate="false"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%--    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
            <td align="left" valign="top" class="bredCrom">
                Fund Transfer » List
            </td>
        </tr>
        <tr>
            <td height="10" class="shadowBG">
            </td>
        </tr>
        <tr>
            <td height="10">
                <div class="tabs">
                    <ul>
                        <li><a href="List.aspx">Transfer List</a></li>
                        <li><a href="#" class="selected">Verify List</a></li>
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