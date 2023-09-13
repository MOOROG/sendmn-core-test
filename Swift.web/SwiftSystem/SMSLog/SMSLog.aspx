<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SMSLog.aspx.cs" Inherits="Swift.web.SwiftSystem.SMSLog.SMSLog" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Application Log</a></li>
                            <li class="active"><a href="#">SMS Log</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">SMS Log</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><%--<a href="#"
                                            class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div id="rpt_grid" runat="server" class="gridDiv">
                                    </div>
                                </div>
                            </div>
                            <!-- End .panel -->
                        </div>
                        <!--end .col-->
                    </div>
                    <!--end .row-->
                </div>
            </div>
        </div>
        <div class="modal fade" id="modalSendSMS" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" style="font-size: 18px; font-weight: 600;">Resend SMS (Mobile Number Edit)</h5>
                        <%--<button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>--%>
                    </div>
                    <div class="modal-body">
                        <label>Mobile No:</label>
                        <input type="text" class="form-control" id="mobileNumber" />
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" id="btnHaveDocumentNo" onclick="SendSMS()">Send</button>
                        <button type="button" class="btn btn-primary" id="btnHaveDocumentYes" data-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>
        <asp:HiddenField ID="hddControlno" runat="server" />
        <asp:HiddenField ID="hddRowId" runat="server" />
    </form>
    <script type="text/javascript">
        function SynccStatus(rowId, mtId, processId) {
            var dataToSend = { MethodName: 'SyncStatus', rowId: rowId, mtId: mtId, processId: processId };
            $.post('', dataToSend, function (erd) {
                alert(erd.Msg);
                location.reload();
            }).fail(function () {
                alert('Oops!!! something went wrong, please try again.');
            });
        }

        function ResendSMS(rowId, mobileNumber, controlNo) {
            $("#mobileNumber").val(mobileNumber);
            $("#<%=hddRowId.ClientID%>").val(rowId);
            $("#<%=hddControlno.ClientID%>").val(controlNo);
            $("#modalSendSMS").modal('show');
        }

        function SendSMS() {
            $("#btnHaveDocumentNo").attr("disabled", true);
            var rowId = $("#<%=hddRowId.ClientID%>").val();
            var controlno = $("#<%=hddControlno.ClientID%>").val();
            var mobileNumber = $("#mobileNumber").val();
            var dataToSend = { MethodName: 'SendSMS', rowId: rowId, mobileNumber: mobileNumber, controlno: controlno };
            $.post('', dataToSend, function (erd) {
                $("#btnHaveDocumentNo").attr("disabled", false);
                location.reload();
            }).fail(function () {
                $("#btnHaveDocumentNo").attr("disabled", false);
                alert('Oops!!! something went wrong, please try again.');
            });
        }
    </script>
</body>
</html>
