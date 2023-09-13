<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FundTransfer.aspx.cs" Inherits="Swift.web.BillVoucher.JMEFundTransfer.FundTransfer" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>


    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="../../../../../js/swift_calendar.js"></script>
    <script type="text/javascript" language="javascript">
        $(document).ready(function () {
            From("#date");
            $('#date').mask('0000-00-00');

            $("body").on("click", "#saveTransfer", function () {
                $("#saveTransfer").attr("disabled", true);
                var reqField = "date,description,currency,amount,";
                if (ValidRequiredField(reqField) == false) {
                    $("#saveTransfer").attr("disabled", false);
                    return false;
                }
                saveTransfer();
            });

        });
        function saveTransfer() {
            var amt = $("#amount").val();
            amt = amt.replace(/,/g, "");

            if (!$.isNumeric(amt)) {
                alert('Invalid amount Field');
                $("#amount").val('');
                $("#amount").focus();
                $("#saveTransfer").attr("disabled", false);
                return false;
            }

            var dataToSend = {
                MethodName: "SaveTransfer",
                Date: $("#date").val(),
                Description: $("#description").val(),
                Currency: $("#currency").val(),
                Amount: $("#amount").val()
            }
            $.post("FundTransfer.aspx", dataToSend, function (response) {
                $("#saveTransfer").attr("disabled", false);
                response = JSON.parse(response);
                if (response.ErrorCode == "0") {
                    $("#description").val('');
                    $("#amount").val('');
                    $('#msgSuccessError').html(response.Msg);
                }
            })
        }
        function FundTransfer(type) {
            var url = "Setting.aspx";
            OpenInNewWindow(url);
            return false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server"></asp:ScriptManager>
        <div class="page-wrapper">

            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Account</li>
                            <li>Bill & Voucher</li>
                            <li>Fund Transfer</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Fund Transfer</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="control-label col-md-4">Date :  </label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <%--<asp:TextBox ID="from" onchange="return DateValidation('from','t','to')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>--%>
                                        <asp:TextBox ID="date" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <asp:UpdatePanel ID="UPDATE_PANEL" runat="server">
                                <ContentTemplate>
                                    <div class="form-group">
                                        <label class="control-label col-md-4">Description: </label>
                                        <div class="col-md-8">
                                            <asp:DropDownList ID="description" runat="server" AutoPostBack="true" CssClass="form-control">
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </ContentTemplate>
                            </asp:UpdatePanel>

                            <div class="form-group">
                                <label class="control-label col-md-4">Currency: </label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="currency" runat="server" AutoPostBack="true" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="control-label col-md-4">Amount :  </label>
                                <div class="col-md-8">
                                    <div class="input-group m-b">
                                        <asp:TextBox ID="amount" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4"></label>
                                <div class="col-md-8">
                                    <input type="button" id="saveTransfer" value="Save" class="btn btn-primary m-t-25" />
                                    &nbsp;&nbsp
                                    <asp:Button runat="server" ID="setting" Text="Setting" class="btn btn-primary m-t-25" OnClientClick="return FundTransfer('setting');" />
                                    <asp:Label ID="msgSuccessError" runat="server"></asp:Label>
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
