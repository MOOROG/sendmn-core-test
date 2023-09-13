<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.UpdateBranchCode.Manage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).ready(function () {


            $("#countryDDL").on('change', function () {
                var countryId = $("#countryDDL").val();
                dataToSend = { MethodName: 'LoadBank', countryId: countryId };

                $.post("", dataToSend, function (response) {
                    if (response == "") {
                        return;
                    }
                    ParseLoadDDl(response, GetElement('bankDDL'));
                });

            });
            $("#countryDDL1").on('change', function () {
                var countryId = $("#countryDDL1").val();
                dataToSend = { MethodName: 'LoadBank', countryId: countryId };

                $.post("", dataToSend, function (response) {
                    if (response == "") {
                        return;
                    }
                    ParseLoadDDl(response, GetElement('bankDDL1'));
                });

            });

            $("#bankDDL").on('change', function () {
                var bankId = $("#bankDDL option:selected").val();
                var countryId = $("#countryDDL").val();
                dataToSend = { MethodName: 'LoadBankBranch', bankId: bankId, countryId: countryId };

                $.post("", dataToSend, function (response) {
                    if (response == "") {
                        return;
                    }
                    ParseLoadDDl(response, GetElement('branchDDL'));
                });
            });

            $("#branchDDL").on('change', function () {

                $("#branchCode").val($("#branchDDL option:selected").val());
                $("#editedBranchName").val($("#branchDDL option:selected").text().split('||')[0].trim());

            });

            function ParseLoadDDl(response, myDDL, recall, selectField) {
                var data = JSON.parse(response);
                CheckSession(data);
                $(myDDL).empty();

                var option;
                if (selectField !== "" && selectField !== undefined) {
                    option = document.createElement("option");
                    option.text = selectField;
                    option.value = "";
                    myDDL.options.add(option);
                }

                for (var i = 0; i < data.length; i++) {
                    option = document.createElement("option");

                    option.text = data[i].AGENTNAME.toUpperCase();
                    option.value = data[i].bankId;

                    var option2 = document.createElement("option");
                    option2.value = data[i].bankId;
                    option2.text = data[i].FLAG;

                    var option3 = document.createElement("option");
                    option3.value = data[i].bankId;
                    option3.text = data[i].maxPayoutLimit;

                    try {
                        myDDL.options.add(option);
                    }
                    catch (e) {
                        alert(e);
                    }
                }
            }

        });
        function CheckSession(data) {
            if (data === undefined || data === "" || data === null)
                return;
            if (data[0].session_end === "1") {
                document.location = "../../../Logout.aspx";
            }
        }
        function CheckFormValidation(flag) {
            var reqField;
            if (flag == 'I') {
                reqField = "countryDDL1,bankDDL1,branchName,branchCodeValue,";
            }
            else {
                reqField = "countryDDL,bankDDL,branchDDL,branchCode,";
            }

            if (ValidRequiredField(reqField) == false) {
                return false;
            }

            if (flag == 'I') {
                var countryId = $("#countryDDL1").val();
                var bankId = $("#bankDDL1").val();
                var branchName = $("#branchName").val();
                var branchCode = $("#branchCodeValue").val();

                dataToSend = { MethodName: 'InsertBranch', bankId: bankId, countryId: countryId, branchName: branchName, branchCode: branchCode };

                $.post("", dataToSend, function (response) {
                    if (response == "") {
                        return;
                    }
                    var data = JSON.parse(response);
                    alert(data[0].Msg);
                    ClearAllFieldsInserted();
                });

            } else {
                var countryId = $("#countryDDL").val();
                var bankId = $("#bankDDL").val();
                var branchId = $("#branchDDL").val();
                var branchCode = $("#branchCode").val();
                var editedBranchName = $("#editedBranchName").val();


                dataToSend = { MethodName: 'UpdateBranchCode', bankId: bankId, countryId: countryId, branchId: branchId, branchCode: branchCode ,editedBranchName:editedBranchName};

                $.post("", dataToSend, function (response) {
                    if (response == "") {
                        return;
                    }
                    var data = JSON.parse(response);
                    alert(data[0].Msg);
                    ClearAllFields();
                });

            }



        }
        function ClearAllFields() {

            $("#countryDDL").val('');
            $("#bankDDL").val('');
            $("#branchDDL").val('');
            $("#branchDDL").text('');
            $("#branchCode").val('');
            $("#editedBranchName").val('');
            $("#editedBranchName").text('');
        }
        function ClearAllFieldsInserted() {

            $("#countryDDL1").val('');
            $("#bankDDL1").val('');
            $("#branchName").text('');
            $("#branchName").val('');
            $("#branchCodeValue").val('');
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Remittance </a></li>
                            <li><a href="#">Utilities </a></li>
                            <li class="active"><a href="Manage.aspx">Update Branch Code</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Update Branch Code
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    <label>
                                        Country:</label>
                                </label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:DropDownList ID="countryDDL" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    <label>
                                        Bank Name:</label>
                                </label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:DropDownList ID="bankDDL" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    <label>
                                        Branch Name:</label>
                                </label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:DropDownList ID="branchDDL" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    <label>
                                       Edited Branch Name:</label>
                                </label>
                                 <div class="col-lg-9 col-md-8">
                                    <asp:TextBox runat="server" ID="editedBranchName" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    <label>
                                        BRANCH_CODE1 :</label>
                                </label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:TextBox runat="server" ID="branchCode" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <!-- End .form-group  -->

                            <div class="form-group">
                                <div class="col-md-12 col-md-offset-3">
                                    <input type="button" value="Update" style="width: 165px;" class="btn btn-primary m-t-25" onclick="return CheckFormValidation();" />
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Insert Branch Name And Code
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    <label>
                                        Country:</label>
                                </label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:DropDownList ID="countryDDL1" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <!-- End .form-group  -->
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    <label>
                                        Bank Name:</label>
                                </label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:DropDownList ID="bankDDL1" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    <label>
                                        Branch Name:</label>
                                </label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:TextBox runat="server" ID="branchName" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    <label>
                                        BRANCH_CODE1 :</label>
                                </label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:TextBox runat="server" ID="branchCodeValue" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <!-- End .form-group  -->

                            <div class="form-group">
                                <div class="col-md-12 col-md-offset-3">
                                    <input type="button" value="Save" style="width: 165px;" class="btn btn-primary m-t-25" onclick="return CheckFormValidation('I');" />
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
