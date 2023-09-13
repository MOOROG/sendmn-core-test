<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerSetup.AgentCustomerSetup.UploadDocuments.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">

    <link href="../../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="../../../../../js/swift_grid.js" type="text/javascript"> </script>
    <link href="../../../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../../../js/functions.js" type="text/javascript"> </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1>UPLOAD CUSTOMER DOCS
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a href="#">Utilities</a></li>
                            <li class="active"><a href="#">Upload Customer Docs</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Upload Customer Docs</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <table width="100%" border="0" align="left" cellpadding="0" cellspacing="0" class="table table-condensed">
                                        <tr>
                                            <td height="524" valign="top">
                                                <div id="rpt_grid" enableviewstate="false" runat="server" class="gridDiv"></div>
                                            </td>
                                        </tr>
                                    </table>
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