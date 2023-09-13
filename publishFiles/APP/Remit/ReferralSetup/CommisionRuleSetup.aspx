<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CommisionRuleSetup.aspx.cs" Inherits="Swift.web.Remit.ReferralSetup.CommisionRuleSetup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="/js/swift_calendar.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            From(effectiveFrom);

            
            $("#partnerDDL").on("change", function () {
                var partner = $("#partnerDDL").val();
                var commPercent = $("#commPercent").val();
                var forexPercent = $("#fxPercent").val();
                if (partner == '393880') {
                    //JME NEPAL
                    $("#fxPercent").attr("placeholder", "0 % - 1 %");
                } else {
                    $("#fxPercent").attr("placeholder", "0 % - 100 %");
                }
                clearAll();
            });
            $("#commPercent").on("change", function () {
                var commPercent = $("#commPercent").val();
                if (commPercent < 0) {
                    $("#commPercent").val('');
                }
                if (commPercent > 100) {
                    $("#commPercent").val('');
                }
            })
            $("#fxPercent").on("change", function () {
                var partner = $("#partnerDDL").val();
                var fxpercent = $("#fxPercent").val();

                if (partner == '393880') {
                    //JME NEPAL
                    if (fxpercent < 0) {
                        $("#fxPercent").val('');
                    }
                    if (fxpercent > 1) {
                        $("#fxPercent").val('');
                    }

                } else {
                    if (fxpercent < 0) {
                        $("#fxPercent").val('');
                    }
                    if (fxpercent > 100) {
                        $("#fxPercent").val('');
                    }
                }

                var commPercent = $("#commPercent").val();
                if (commPercent < 0) {
                    $("#commPercent").val('');
                }
                if (commPercent > 100) {
                    $("#commPercent").val('');
                }
            })
        });
        function clearAll() {
            $("#commPercent").val('');
            $("#fxPercent").val('');
            $("#flatTxnWise").val('');
            $("#newCustomer").val('');

        }
        window.onunload = window.opener.location.reload();
        function ValidateForm() {
            var reqField = 'partnerDDL,';
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            return true;
        }
        function GoToList() {
            var a = "<%GetRefCode();%>";
            url = 'CommissionRuleList.aspx?referralCode=' + $("#hdnReferralCode").val();
            $("#anchorTag").attr('href', url);
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnReferralCode" runat="server" />
        <div class="page-wrapper">
            <div class="col-md-12">
                <div class="page-title">
                    <ol class="breadcrumb">
                        <li><a href="/Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                        <li><a href="#">Administration</a></li>
                        <li><a href="#">Referral Setup</a></li>
                        <li class="active"><a href="#">Referral Commission Setup</a></li>
                    </ol>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a onclick="GoToList()" id="anchorTag">Commission Rule List</a></li>
                    <li class="active"><a href="#">Add Comission Rule</a></li>
                </ul>
            </div>
            <div class="row">
                <div class="col-md-8">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4>Referral Commision Setup</h4>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <label class="control-label col-md-4">Partner :</label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="partnerDDL" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Commision Percent :</label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="commPercent" placeholder="0 % - 100 %" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Forex Income/Loss Percent:</label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="fxPercent" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Flat Transaction Wise :</label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="flatTxnWise" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">New Customer :</label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="newCustomer" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Effecive From :</label>
                                <div class="col-md-8">
                                    <asp:TextBox ID="effectiveFrom" autocomplete="false" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Is Active :</label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="isActive" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="1">Yes</asp:ListItem>
                                        <asp:ListItem Value="0">No</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Deduct Tax On Service Charge:</label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="deductTaxOnSc" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="1">Yes</asp:ListItem>
                                        <asp:ListItem Value="0">No</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4">Deduct Payout Comm. on SC:</label>
                                <div class="col-md-8">
                                    <asp:DropDownList ID="deductPCommOnSc" runat="server" CssClass="form-control">
                                        <asp:ListItem Value="1">Yes</asp:ListItem>
                                        <asp:ListItem Value="0">No</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="control-label col-md-4"></label>
                                <div class="col-md-8">
                                    <asp:Button ID="save" runat="server" Text="Save" CssClass="btn btn-primary" OnClientClick="return ValidateForm();" OnClick="save_Click" />
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
