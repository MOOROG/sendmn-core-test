<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="Swift.web.BillVoucher.FundTransfer.Settings" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script type="text/javascript">
        function ManageShoHide() {
            var trasferTo = $('#ddlTransferType').val();
            if (trasferTo == '1') {
                $('#showHideRow').hide();
            }
            else if (trasferTo == '2') {
                $('#showHideRow').show();
            }
        }

        $(document).ready(function () {
            ManageShoHide();
        });

        function CheckRequired() {
            var trasferTo = $('#ddlTransferType').val();
            var requirefFields;

            if (trasferTo == '1') {
                requirefFields = 'ddlTransferType,nameOfPartner,receieveInUsd,';
            }
            else if (trasferTo == '2') {
                requirefFields = 'ddlTransferType,nameOfPartner,receieveInUsd,furtherTransferTo,';
            }

            if (ValidRequiredField(requirefFields) == false) {
                return false;
            }
        }

        function CallBack(mes) {
            alert(mes);
            window.close();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-default ">
                    <!-- Start .panel -->
                    <div class="panel-heading">
                        <h4 class="panel-title">Add New Correspondent For Fund Transfer
                        </h4>
                        <div class="panel-actions">
                            <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            <%--<a href="#" class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                        </div>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-6 form-group">
                                <table class="table table-responsive">
                                    <tr>
                                        <td>
                                            <label class="control-label">
                                                Transfer Fund To:<span class="errormsg">*</span>
                                            </label>
                                        </td>
                                        <td>
                                            <asp:DropDownList ID="ddlTransferType" CssClass="form-control" runat="server" onchange="ManageShoHide();" AutoPostBack="true" OnSelectedIndexChanged="ddlTransferType_SelectedIndexChanged">
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label class="control-label">
                                                Name Of Partner:<span class="errormsg">*</span>
                                            </label>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="nameOfPartner" CssClass="form-control" runat="server"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label class="control-label">
                                                Receive In USD:<span class="errormsg">*</span>
                                            </label>
                                        </td>
                                        <td>
                                            <uc1:SwiftTextBox ID="receieveInUsd" runat="server" Category="acInfo" CssClass="autocomplete" Title="Blank for All" />
                                        </td>
                                    </tr>
                                    <tr id="showHideRow" style="display: none;">
                                        <td>
                                            <label class="control-label">
                                                Further Transfer To Correspondent Ac:<span class="errormsg">*</span>
                                            </label>
                                        </td>
                                        <td>
                                            <uc1:SwiftTextBox ID="furtherTransferTo" runat="server" Category="acInfo" CssClass="autocomplete" Title="Blank for All" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Button ID="btnTransfer" runat="server" Text="Save" ValidationGroup="transfer" OnClientClick="return CheckRequired();"
                                                CssClass="btn btn-primary m-t-25" OnClick="btnTransfer_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>