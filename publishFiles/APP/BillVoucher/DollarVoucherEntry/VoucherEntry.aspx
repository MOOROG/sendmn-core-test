<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VoucherEntry.aspx.cs" Inherits="Swift.web.BillVoucher.DollarVoucherEntry.VoucherEntry" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Register TagPrefix="uc1" TagName="SwiftTextBox" Src="~/Component/AutoComplete/SwiftTextBox.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!--new css and js -->
    <!-- Bootstrap Core CSS -->
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/ui/js/metisMenu.min.js"></script>
    <!--page plugins-->
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>

    <!--page plugins-->

    <script type="text/javascript">

        $(document).ready(function () {
            ShowCalFromToUpToToday("#transactionDate");
            var allowDate = "<%=AllowChangeDate() %>";
            if (allowDate == "True") {
                ShowCalFromTo("#<% =transactionDate.ClientID %>", 1);
            }
        });

        function deleteRecord(id) {

            if (confirm('Are you sure to delete?'))
                GetElement("hdnRowId").value = id;
            GetElement("btnDelete").click();
        }

        function CheckFormValidation() {
            var reqField = "voucherType,narrationField,transactionDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            GetElement("btnSave").click();
        }

        function CheckFormValidation3() {
            var reqField = "voucherType,narrationField,transactionDate,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            GetElement("btnUploadMultiple").click();
        }

        function CheckFormValidation2() {
            var reqField = "acInfo_aText,amt,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            GetElement("addBtn").click();
        }

        function Calculate() {
            var FCYAmt = document.getElementById('<%=FCYAmt.ClientID%>').value;
            var exRate = document.getElementById('<%=Rate.ClientID%>').value;
            if (FCYAmt == "0.00" || exRate == "" || exRate == "0.00") {
                document.getElementById('<%=FCYAmt.ClientID%>').focus();
                //alert('Please input valid amount and exchange rate!!');
            }
            else {
                var num1 = FCYAmt.replace(",", "");
                var num2 = exRate.replace(",", "");
                var total = num1 * num2;
                document.getElementById('<%=amt.ClientID%>').value = total;
            }
        }

        function GetUSDAmount() {
            var FCYAmt = document.getElementById('<%=FCYAmt.ClientID%>').value;

            if (FCYAmt == '' || FCYAmt == undefined) {
                return null;
            }
            else {
                return FCYAmt;
            }
        }
        function CallBackAutocomplete(id) {
            var curr = $(id + "_aText").val();
            curr = curr.substr(curr.length - 3, 3);
            $("#lblFcyCurr").html(curr);
        }

        function DisplayLabel(curr) {
            $("#lblRate").html("Rate (JPY/" + curr + ")");
        }
    </script>

    <style type="text/css">
        .change .col-lg-1, .change .col-lg-10, .change .col-lg-11, .change .col-lg-12, .change .col-lg-2, .change .col-lg-3, .change .col-lg-4, .change .col-lg-5, .change .col-lg-6, .change .col-lg-7, .change .col-lg-8, .change .col-lg-9, .change .col-md-1, .change .col-md-10, .change .col-md-11, .change .col-md-12, .change .col-md-2, .change .col-md-3, .change .col-md-4, .change .col-md-5, .change .col-md-6, .change.col-md-7, .change .col-md-8, .change .col-md-9 {
            position: relative;
            min-height: 1px;
            padding-right: 2px;
            padding-left: 2px;
        }

        .change .form-control {
            font-size: 12px;
            padding: 2px 2px;
            height: 25px;
        }

        .change .btn {
            padding: 4px 6px;
            font-size: 12px;
        }

        table tr td {
            padding: 2px !important;
        }
    </style>
</head>
<body>
    <form runat="server">
        <asp:ScriptManager runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li class="active"><a href="List.aspx">FCY voucher Entry</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div id="msg" visible="false" style="width: 74%;" class="alert alert-danger" runat="server">
                            <span runat="server" id="mes"></span>
                        </div>
                        <div class="form-group alert alert-danger" id="divuploadMsg" runat="server" visible="false">
                        </div>
                        <div class="panel-heading">
                            <h4 class="panel-title">FCY Voucher Entry
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><a href="#"
                                    class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <table class="table table-responsive change">
                                <tr>
                                    <td>Ledger</td>
                                    <td>FCY</td>
                                    <td>FCY Amount</td>
                                    <td>
                                        <span id="lblRate" style="font-size: 10px !important">Rate
                                        </span>
                                    </td>
                                    <td>JPY Amount</td>
                                    <td>DR/CR</td>
                                    <td>Department</td>
                                    <td>Branch</td>
                                    <td>Employee Name</td>
                                    <td>Field1</td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td style="width: 280px !important">
                                        <uc1:SwiftTextBox ID="acInfo" runat="server" Category="acInfo" CssClass="autocomplete" Title="Blank for All" autocomplete="off" />
                                    </td>
                                    <td style="width: 65px !important">
                                        <asp:DropDownList ID="FCY" runat="server" CssClass="form-control" onchange="DisplayLabel(this.value)" autocomplete="off">
                                        </asp:DropDownList>
                                    </td>
                                    <td style="width: 120px !important">
                                        <asp:TextBox ID="FCYAmt" placeholder="FCY Amount" runat="server" size="15" onchange="Calculate();" CssClass="form-control" autocomplete="off"></asp:TextBox>
                                    </td>
                                    <td style="width: 100px !important">
                                        <asp:TextBox ID="Rate" runat="server" onchange="Calculate();" placeholder="FCY Rate" size="15" CssClass="form-control" autocomplete="off"></asp:TextBox></td>
                                    <td style="width: 120px !important">
                                        <asp:TextBox ID="amt" placeholder="JPY Amount" runat="server" size="15" CssClass="form-control" autocomplete="off"></asp:TextBox></td>
                                    <td style="width: 55px !important">
                                        <asp:DropDownList ID="dropDownDrCr" runat="server" Width="100%" CssClass="form-control">
                                            <asp:ListItem Value="dr" Selected="True">DR</asp:ListItem>
                                            <asp:ListItem Value="cr">CR</asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                    <td style="width: 155px !important">
                                        <asp:DropDownList ID="Department" runat="server" CssClass="form-control">
                                        </asp:DropDownList>
                                    </td>
                                    <td style="width: 200px !important">
                                        <asp:DropDownList ID="Branch" runat="server" CssClass="form-control">
                                        </asp:DropDownList>
                                    </td>
                                    <td style="width: 140px !important">
                                        <asp:TextBox ID="EmpName" placeholder="Employee Name" runat="server" size="35" CssClass="form-control"></asp:TextBox>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="Field1" placeholder="Field" runat="server" size="25" CssClass="form-control"></asp:TextBox></td>

                                    <td style="width: 60px !important">
                                        <input type="button" value=" Add " class="btn btn-primary m-t-25" onclick="CheckFormValidation2();" />
                                        <asp:Button ID="addBtn" runat="server" Text=" Add " Style="display: none" OnClick="addBtn_Click" />
                                        <asp:HiddenField ID="hdnRowId" runat="server" />
                                        <asp:Button ID="btnDelete" runat="server" Style="display: none" OnClick="btnDelete_Click" />
                                    </td>
                                </tr>
                            </table>

                            <div class="row form-group">
                                <div class="col-md-12">
                                    <br />
                                    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                                        <ContentTemplate>
                                            <div id="rpt_tempVoucherTrans" runat="server">
                                            </div>
                                        </ContentTemplate>
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="addBtn" EventName="Click" />
                                            <asp:AsyncPostBackTrigger ControlID="btnDelete" EventName="Click" />
                                        </Triggers>
                                    </asp:UpdatePanel>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-2 col-md-2 form-group">
                                    <label class="control-label" for="">
                                        Voucher Type:
                                    </label>
                                    <asp:DropDownList ID="voucherType" runat="server" Width="100%" CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <label class="control-label" for="">
                                        Voucher Date:</label>
                                    <div class="input-group m-b">
                                        <span class="input-group-addon">
                                            <i class="fa fa-calendar" aria-hidden="true"></i>
                                        </span>
                                        <asp:TextBox ID="transactionDate" onchange="return DateValidation('transactionDate','t')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium "></asp:TextBox>
                                    </div>
                                </div>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <label class="control-label" for="">
                                        Cheque Number:
                                    </label>
                                    <asp:TextBox ID="chequeNo" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <label class="control-label" for="">
                                        Upload Image:
                                    </label>
                                    <asp:FileUpload ID="VImage" runat="server" />
                                </div>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <label class="control-label" for="">
                                        Import CSV:
                                    </label>
                                    <asp:FileUpload ID="fileUpload" runat="server" /><a href="../../SampleFile/FCYVoucherEntry.csv">SampleFile FCYVoucher</a>
                                </div>
                                <div class="col-lg-2 col-md-2 form-group">
                                    <br />
                                    <asp:Button ID="btnUpload" class="btn btn-primary" runat="server" Text="Upload File" OnClick="btnUpload_Click" />
                                </div>
                            </div>
                            <div class="row form-group">
                                <div class="col-md-12">
                                    <label class="control-label" for="">
                                        Narration:
                                    </label>
                                    <asp:TextBox ID="narrationField" runat="server" TextMode="MultiLine" MaxLength="300" Width="100%" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>

                            <div class="row">
                                <div class="form-group">
                                    <div class="col-md-12">
                                        <input type="button" value="Save voucher " class="btn btn-primary m-t-25" onclick="CheckFormValidation();" />
                                        <asp:Button ID="btnSave" runat="server" Text="Save voucher " Style="display: none"
                                            OnClick="btnSave_Click" />
                                        <asp:Button ID="btnUnSave" runat="server" Text="Unsaved voucher" CssClass="btn btn-primary m-t-25"
                                            OnClick="btnUnSave_Click" />
                                        <input type="button" value="Save voucher For Multiple Date" class="btn btn-primary m-t-25" onclick="CheckFormValidation3();" />
                                        <asp:Button ID="btnUploadMultiple" runat="server" Text="Save voucher " Style="display: none"
                                            OnClick="btnUploadMultiple_Click" />
                                    </div>
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