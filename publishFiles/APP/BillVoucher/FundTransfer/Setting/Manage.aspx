<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.BillVoucher.FundTransfer.Setting.Manage" %>

<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <link href="/Css/swift_component.css" rel="stylesheet" type="text/css" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />

    <script src="/js/swift_autocomplete.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script type="text/javascript">
        function ManageShoHide() {
            var trasferTo = $('#TransferFund').val();
            $('#showHideRow').hide();
            if (trasferTo == 'Transfer To GME Nostro USD To Correspondents Account') {
                $('#showHideRow').show();
            }

        }
        function CheckFormValidation() {
            var reqField = "TransferFund,PartnerName,ReceiveAc_aText,";
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
        }
    </script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Fund transfer</a></li>
                            <li class="active"><a href="List.aspx">ADD NEW CORRESPONDENT FOR FUND TRANSFER</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">ADD NEW CORRESPONDENT FOR FUND TRANSFER
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="control-label col-md-3">Transfer Fund To:<span class="errormsg">*</span></label>
                                <div class="col-md-9">
                                    <asp:DropDownList ID="TransferFund" onchange="ManageShoHide();" CssClass="form-control" runat="server"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-3">Name Of Partner:<span class="errormsg">*</span></label>
                                <div class="col-md-9">
                                    <asp:TextBox ID="PartnerName" CssClass="form-control" runat="server"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-3">Receive In USD:<span class="errormsg">*</span></label>
                                <div class="col-md-9">
                                    <uc1:SwiftTextBox ID="ReceiveAc" runat="server" Category="acInfo" />
                                </div>
                            </div>
                            <div id="showHideRow" style="display: none;">
                                <label class="control-label col-md-3">Further Transfer To Correspondent Ac:<span class="errormsg">*</span></label>
                                <div class="col-md-9">
                                    <uc1:SwiftTextBox ID="CorrespondentAc" runat="server" Category="acInfo" />
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-offset-3 col-md-4">
                                    <asp:Button Text="Save" ID="btnSave" runat="server" CssClass="btn btn-primary m-t-25" OnClientClick="return CheckFormValidation()" OnClick="btnSave_Click" />
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