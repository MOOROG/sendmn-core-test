<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MapCustomerDeposits.aspx.cs" Inherits="Swift.web.Remit.Administration.CustomerDepositMapping.MapCustomerDeposits" %>

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
    <script src="/js/swift_autocomplete.js"></script>
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
                        url: '/Remit/Administration/CustomerDepositMapping/MapCustomerDeposits.aspx',
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
        }

        function ValidateData(logId, type, bankName) {

            var autoCompleteText = logId + '_aText';
            var reqField = autoCompleteText + ",";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            if (type == 'save' || type == "send") {
                $("#<%=bankName.ClientID%>").text(bankName);
                $("#<%=LogId.ClientID%>").val(logId);
                $("#hdnType").val(type);
                //$("#myModal1").modal('show');
                MapCustomerDeposits();
            }
            else if (type == 'view') {
                var autoCompleteValue = '#' + logId + '_aValue';
                var dataToSend = { MethodName: 'GetCustomerDetails', customerId: $(autoCompleteValue).val() };
                var xhr = $.ajax({
                    type: "POST",
                    url: '/Remit/Administration/CustomerDepositMapping/MapCustomerDeposits.aspx',
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
            //$("#btnForCallSendPage").click();
            //var reqField = "bankList,";
            var saveType = $("#<%=hdnType.ClientID%>").val();
            //if (ValidRequiredField(reqField) === false) {
            //    return false;
            //}
            if (confirm('Are you sure want to map?')) {
                var logId = $("#<%=LogId.ClientID%>").val();
                var autoCompleteValue = '#' + logId + '_aValue';
                var bankId = $("#<%=bankList.ClientID%>").val();
                var dataToSend = { MethodName: 'MapCustomerDeposits', logId: logId, customerId: $(autoCompleteValue).val(), bankId: bankId };
                $.post('/Remit/Administration/CustomerDepositMapping/MapCustomerDeposits.aspx', dataToSend, function (erd) {
                    if (erd.ErrorCode == '0') {
                        if (saveType == 'send') {
                            var customerId = $(autoCompleteValue).val();
                            var url1 = "/AgentPanel/International/SendMoneyv2/SendV2.aspx?customerId=" + customerId;
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
                }).fail(function () {
                    alert('Oops!!! something went wrong, please try again.');
                });
            }
        };
    </script>
</head>
<body>
    <form id="form1" runat="server">
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
                             <%--       <div class="row form-group">
                                        <label class="col-md-2">Is Skipped:</label>
                                        <div class="col-md-4">
                                            <asp:DropDownList ID="isSkipped" runat="server" CssClass="form-control" OnSelectedIndexChanged="isSkipped_SelectedIndexChanged" AutoPostBack="true">
                                                <asp:ListItem Value="0" Text="Hide Skipped"></asp:ListItem>
                                                <asp:ListItem Value="1" Text="Show Skipped"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>--%>
                                    <div class="row form-group">
                                        <div class="col-md-12 table-responsive">
                                            <table class="table table-responsive table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th width="2%">S.NO.</th>
                                                        <th width="23%">Particulars</th>
                                                        <th width="10%">Deposit Date</th>
                                                        <th width="10%">Deposit Amount</th>
                                                        <th width="10%">Withdraw Amount</th>
                                                        <th width="35%">Choose Customer</th>
                                                        <th width="10%">Action</th>
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
                                                    <button class="btn btn-primary" onclick="return MapCustomerDeposits()" data-toggle="tooltip" data-placement="top">Save</button>
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
    </form>

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
</body>
</html>