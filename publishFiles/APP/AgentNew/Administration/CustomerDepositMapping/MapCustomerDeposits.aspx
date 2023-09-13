<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="MapCustomerDeposits.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CustomerDepositMapping.MapCustomerDeposits" %>

<%--<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>--%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style type="text/css">
        .modal-body .table th {
            color: #888888;
        }

        .modal-body .table td {
            color: #000;
            font-weight: 600;
        }
    </style>
    <script type="text/javascript">
        function CallBackAutocomplete(id) {
            $(id + "_aValue").val($(id + '_aValue').val());
            $(id + "_aText").val($(id + '_aText').val().split('|')[0]);
        };

        function IsSkippedData(logId, type, isSkipped) {
            if (type == 'skipped') {
                if (confirm('Are you sure want to skipped?')) {
                    var dataToSend = { MethodName: 'MapCustomerSkipped', logId: logId, isSkipped: isSkipped };
                    var xhr = $.ajax({
                        type: "POST",
                        url: '/AgentNew/Administration/CustomerDepositMapping/MapCustomerDeposits.aspx',
                        dataType: "JSON",
                        data: dataToSend,
                        async: false
                    });
                    xhr.done(function (erd) {
                        if (erd.ErrorCode == '0') {
                            alert(erd.Msg);
                            window.location.reload();
                        }
                        else if (erd.ErrorCode == '1') {
                            alert(erd.Msg);
                        }
                    });
                    xhr.fail(function (erd) {
                        alert('Oops!!! something went wrong, please try again.');
                    });
                    return;
                };
            }
        };

        function ValidateData(logId, type, bankName) {

            var autoCompleteText = logId + '_aText';
            var reqField = autoCompleteText + ",";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            if (type == 'save' || type == "send") {
                $("#<%=bankName.ClientID%>").text(bankName);
                $("#<%=LogId.ClientID%>").val(logId);
                //$("#myModal1").modal('show');
                $('#<%=hdnType.ClientID%>').val(type);
                MapCustomerDeposits();
            }
            else if (type == 'view') {
                var autoCompleteValue = '#' + logId + '_aValue';
                var dataToSend = { MethodName: 'GetCustomerDetails', customerId: $(autoCompleteValue).val() };
                var xhr = $.ajax({
                    type: "POST",
                    url: '/AgentNew/Administration/CustomerDepositMapping/MapCustomerDeposits.aspx',
                    dataType: "JSON",
                    data: dataToSend,
                    async: false
                });
                xhr.done(function (erd) {
                    if (erd !== null) {
                        //$("#addModel" + logId).html(erd);
                        $("#name").text(erd.fullName);
                        $("#mobile").text(erd.mobile);
                        $("#idtype").text(erd.idType);
                        $("#idNumber").text(erd.idNumber);
                        $("#address").text(erd.state + ',' + erd.city + ',' + erd.street);
                        $("#membership").text(erd.membershipId);
                        $("#email").text(erd.email);
                        $("#dob").text(erd.dob);
                        $("#myModal").modal('show');
                        $("#modelClose").focus();
                    }
                });
                xhr.fail(function (erd) {
                    alert('Oops!!! something went wrong, please try again.');
                });
            }
        };

        $('#myModal').on('shown', function () {

            $('body').on('wheel.modal mousewheel.modal', function () { return false; });

        }).on('hidden', function () {
            $('body').off('wheel.modal mousewheel.modal');
        });

        function MapCustomerDeposits() {
            $("#btnForCallSendPage").click();
            //var reqField = "<%=bankList.ClientID%>,";
            var saveType = $('#<%=hdnType.ClientID%>').val();
            //if (ValidRequiredField(reqField) === false) {
            //    return false;
            //}

            if (confirm('Are you sure want to map?')) {
                var logId = $("#<%=LogId.ClientID%>").val();
                var autoCompleteValue = '#' + logId + '_aValue';
                var bankId = $("#<%=bankList.ClientID%>").val();
                var dataToSend = { MethodName: 'MapCustomerDeposits', logId: logId, customerId: $(autoCompleteValue).val(), bankId: bankId };
                $.ajax({
                    type: "POST",
                    url: '/AgentNew/Administration/CustomerDepositMapping/MapCustomerDeposits.aspx',
                    dataType: "JSON",
                    data: dataToSend,
                    async: false,
                    success: function (erd) {
                        if (erd.ErrorCode == '0') {
                            var res = erd;
                            if (saveType == 'send') {
                                var customerId = $(autoCompleteValue).val();
                                var url1 = "/AgentNew/SendTxn/SendV2.aspx?customerId=" + customerId;
                                $(location).attr("href", url1);
                            }
                            else {
                                window.location.reload();
                                alert(erd.Msg);
                            }
                        }
                        else if (erd.ErrorCode == '1') {
                            alert(erd.Msg);
                        }
                    },
                    err: function () {
                        alert('Oops!!! something went wrong, please try again.');
                    }
                });
            }
        };
    </script>
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
                                <h4 class="panel-title">Customer Deposit Mapping</h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
                                </div>
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label class="col-md-4">Is Skipped:</label>
                                            <div class="col-md-8">
                                                <asp:DropDownList ID="isSkipped" runat="server" CssClass="form-control" OnSelectedIndexChanged="isSkipped_SelectedIndexChanged" AutoPostBack="true">
                                                    <asp:ListItem Value="0" Text="Hide Skipped"></asp:ListItem>
                                                    <asp:ListItem Value="1" Text="Show Skipped"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-12">
                                        <div class="table-responsive">
                                            <table class="table table-responsive table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th width="2%">S.NO.</th>
                                                        <th width="23%">Particulars</th>
                                                        <th width="10%">Deposit Date</th>
                                                        <th width="10%">Deposit Amount</th>
                                                        <th width="10%">Withdraw Amount</th>
                                                        <th width="28%">Choose Customer</th>
                                                        <th width="18%">Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody id="customerDepositMapping" runat="server">
                                                    <tr>
                                                        <td colspan="7" align="center">No Data To Display </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-12">
                <div class="modal fade" id="myModal1" style="margin-top: 200px;" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-md" role="document">
                        <div class="modal-content">
                            <div class="modal-header" id="modelUserForSave">
                                <center> <h2 class="modal-title">Choose Bank<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></h2></center>
                            </div>
                            <div class="modal-body">
                                <div class="table-responsive">
                                    <asp:HiddenField ID="hdnType" runat="server" />
                                    <table class="table">
                                        <tr>
                                            <asp:HiddenField ID="LogId" runat="server" />
                                            <th width="20%">Bank Name:</th>
                                            <th width="80%">
                                                <label id="bankName" runat="server"></label>
                                            </th>
                                        </tr>
                                        <tr>
                                            <th>Bank List:</th>
                                            <td>
                                                <asp:DropDownList ID="bankList" runat="server" CssClass="form-control"></asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td></td>
                                            <td>
                                                <%--<button type="button" class="btn btn-primary" onclick="return MapCustomerDeposits()" data-toggle="tooltip" data-placement="top">Save</button>--%>
                                                <input type="button" class="btn btn-primary" onclick="return MapCustomerDeposits()" value="Save" data-toggle="tooltip" data-placement="top" />
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
    </div>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-12">
                <div class="modal fade" id="myModal" style="margin-top: 200px;" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-md" role="document">
                        <div class="modal-content">
                            <div class="modal-header">

                                <center> <h2 class="modal-title">
                                                <label id="name"></label>
                                                (<label id="membership"></label>)<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></h2></center>
                            </div>
                            <div class="modal-body">
                                <div class="table-responsive">
                                    <table class="table table-striped">

                                        <tr class="success">
                                            <th>Mobile No:</th>
                                            <td>
                                                <label id="mobile"></label>
                                            </td>
                                            <th>Id Type:</th>
                                            <td>
                                                <label id="idtype"></label>
                                            </td>
                                        </tr>
                                        <tr class="info">
                                            <th>Id No:</th>
                                            <td>
                                                <label id="idNumber"></label>
                                            </td>
                                            <th>Address:</th>
                                            <td>
                                                <label id="address"></label>
                                            </td>
                                        </tr>
                                        <tr class="warning">
                                            <th>DOB:</th>
                                            <td>
                                                <label id="dob"></label>
                                            </td>
                                            <th>Email:</th>
                                            <td>
                                                <label id="email"></label>
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
    </div>
</asp:Content>