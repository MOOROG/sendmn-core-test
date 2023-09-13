<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="SMSLog.aspx.cs" Inherits="Swift.web.AgentNew.SMSLog.SMSLog" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-wrapper">
        <div class="tab-content">
            <div role="tabpanel" class="tab-pane active" id="list">
                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default ">
                            <!-- Start .panel -->
                            <div class="panel-heading">
                                <h4 class="panel-title">Send SMS Log</h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="table-responsive">
                                    <div id="rpt_grid" enableviewstate="false" runat="server" class="gridDiv"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="modal fade" id="modalSendSMS" tabindex="-1" style="margin-top: 150px;" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
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
    <script type="text/javascript">
        function SynccStatus(rowId, mtId, processId) {
            var dataToSend = { MethodName: 'SyncStatus', rowId: rowId, mtId: mtId, processId: processId };
            $.post('', dataToSend, function (erd) {
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
</asp:Content>
