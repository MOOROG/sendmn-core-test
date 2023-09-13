<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentCustomerSetup.UploadVoucher.List" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../../js/jquery.min.js" type="text/javascript"></script>
    <script src="../../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../../js/swift_calendar.js" type="text/javascript"></script>
    <script type="text/javascript">
    function DoUpload(docDesc) {
        var user = "<%=GetStatic.GetUser() %>";
        var branch = "<%=GetStatic.GetBranch() %>";
        var txnType = document.getElementById("txnType").value;
        parent.UploadDocMain(user, txnType, branch, docDesc);
    }
    function ScanDocument(id, icn, txnType) {

         document.getElementById("hdnIcn").value=icn;
        document.getElementById("hdnTranId").value=id;
        document.getElementById("txnType").value = txnType;

        parent.ScanDocument(id, icn);
    }
    function CheckForDocument(Icn, Id) {

        var agentId = "<%=GetStatic.GetAgentId() %>";
        var vouType = document.getElementById("txnType").value;
        var icn = document.getElementById("hdnIcn").value;
        var Id = document.getElementById("hdnTranId").value;

        //alert(agentId + "," + vouType + "," + icn + ","+Id);

        var dataToSend = { MethodName: 'docCheck', agentId: agentId, icn: Icn, tranId: Id, vouType: vouType };
        var options =
                        {
                            url: '<%=ResolveUrl("List.aspx") %>',
                            data: dataToSend,
                            dataType: 'JSON',
                            type: 'POST',
                            success: function (response) {
                                var data = jQuery.parseJSON(response);
                                if (data[0].errorCode = "0") {
                                    var sum = data[0].id;
                                    if (sum == 0) {
                                        parent.Disable(0); //enable all
                                    } else if (sum == 1) {
                                        parent.Disable(1); //enable voucher only
                                    } else if (sum == 2) {
                                        parent.Disable(2); //enable id only
                                    } else if (sum >= 3) {
                                        parent.Disable(4); //enable both
                                    }
                                    return;
                                }
                            }
                        };
        $.ajax(options);
        return true;
    }
    </script>
</head>
<body onload="parent.resizeIframe();parent.LoadScanner('0');">
    <form id="form1" runat="server">
        <asp:HiddenField ID="txnType" runat="server" />
        <asp:HiddenField ID="hdnIcn" runat="server" />
        <asp:HiddenField ID="hdnscanner" runat="server" />
        <asp:HiddenField ID="hdnTranId" runat="server" />
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

            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="#" class="selected">Voucher Upload List </a></li>
                    <li><a href="Manage.aspx">Voucher Upload Report</a></li>
                </ul>
            </div>

            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Voucher Upload List</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">

                                    <table width="100%" class="table table-condensed">

                                        <tr>
                                            <td height="10" class="shadowBG"></td>
                                        </tr>

                                        <tr>
                                            <td height="524" valign="top">
                                                <span class="alert alert-danger" style="margin-left: 26px;">Note: Date Range is only valid For Max. Report days: 32 days.Please select the date range between 32 Days only.</span>
                                                <br />
                                                <br />
                                                <div id="rpt_grid" runat="server" class="gridDiv"></div>
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