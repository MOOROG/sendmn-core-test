<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.BillVoucher.TreasuryDealBooking.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />

    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="/js/swift_calendar.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>

    <script src="/js/functions.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            ShowCalDefault("#<%=maturityDate.ClientID%>");
            ShowCalDefault("#<%=date.ClientID%>");
        });

        function Calculate() {
            var FCYAmt = document.getElementById('<%=usdAmount.ClientID%>').value;
            var exRate = document.getElementById('<%=rate.ClientID%>').value;
            if (FCYAmt == "0.00" || exRate == "" || exRate == "0.00") {
                document.getElementById('<%=usdAmount.ClientID%>').focus();
               //alert('Please input valid amount and exchange rate!!');
            }
            else {
                var num1 = FCYAmt.replace(",", "");
                var num2 = exRate.replace(",", "");
                var total = num1 * num2;
                document.getElementById('<%=krwAmount.ClientID%>').value = total;
            }
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
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Fund Dealing</a></li>
                            <li><a href="#">Deal Booking</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Deal Booking
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="form-group">
                                <div class="col-md-12">
                                    <div id="divMsg" runat="server">
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="">
                                    Date:</label>
                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="date" onchange="return DateValidation('date','t')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="">
                                    Bank:<span class="errormsg">*</span>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="bankDDL" ForeColor="Red"
                                        ValidationGroup="save" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </label>
                                <div class="col-md-9">
                                    <asp:DropDownList ID="bankDDL" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="Select Bank" Value="0"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="">
                                    USD Amount:<span class="errormsg">*</span>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="usdAmount" ForeColor="Red"
                                        ValidationGroup="save" Display="Dynamic" ErrorMessage="Required!">
                                    </asp:RequiredFieldValidator>
                                </label>
                                <div class="col-md-9">
                                    <asp:TextBox ID="usdAmount" runat="server" CssClass="form-control" onchange="Calculate();"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="">
                                    Rate:<span class="errormsg">*</span></label>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="rate" ForeColor="Red"
                                    ValidationGroup="save" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                                <div class="col-md-9">
                                    <asp:TextBox ID="rate" runat="server" CssClass="form-control" onchange="Calculate();"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="">
                                    LCY Amount:<span class="errormsg">*</span></label>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="krwAmount" ForeColor="Red"
                                    ValidationGroup="save" Display="Dynamic" ErrorMessage="Required!">
                                </asp:RequiredFieldValidator>
                                <div class="col-md-9">
                                    <asp:TextBox ID="krwAmount" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="">
                                    Dealer:</label>

                                <div class="col-md-9">
                                    <asp:TextBox ID="dealer" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="">
                                    Contract No:</label>

                                <div class="col-md-9">
                                    <asp:TextBox ID="contractNo" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-md-3 control-label" for="">
                                    Maturity Date:</label>
                                <div class="col-md-9">
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="maturityDate" onchange="return DateValidation('maturityDate','t')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-9 col-md-offset-3">
                                    <asp:Button ID="BtnSave" runat="server" CssClass="btn btn-primary btn-sm"
                                        Text="Save" ValidationGroup="save" OnClick="BtnSave_Click" />
                                    <a href="DealingBank/List.aspx" class="btn btn-primary btn-sm">Add Bank </a>
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