<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.BillVoucher.VoucherReport.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../ui/js/metisMenu.min.js"></script>
    <script src="../../ui/js/jquery-jvectormap-1.2.2.min.js"></script>
    <script src="../../ui/js/jquery-jvectormap-world-mill-en.js"></script>
    <!--        <script src="js/jquery.nanoscroller.min.js"></script>-->
    <script type="text/javascript" src="../../ui/js/custom.js"></script>
    <!--page plugins-->
    <script src="../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">

        function CheckFormValidation(searchType) {
            var reqField = '';
            var vNum = '';
            if (searchType == 'v') {
                reqField = "vNum,typeDDL,";
                vNum = $("#vNum").val();
            }
            else if (searchType == 'c') {
                reqField = "controlNumber,";
                vNum = $("#controlNumber").val();
            }
            if (ValidRequiredField(reqField) == false) {
                return false;
            }
            var typeDDL = $("#typeDDL").val();
            var vText = $("#typeDDL option:selected").text();
            //alert(vText);
            var url = "VoucherReportDetails.aspx?searchType=" + searchType + "&vNum=" + vNum + "&typeDDL=" + typeDDL + "&vText=" + vText;
            //alert(url);
            window.location.href = url;
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
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('account_report')">Account Report </a></li>
                            <li class="active"><a href="List.aspx">Voucher Report</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="panel panel-default recent-activites">
                        <!-- Start .panel -->
                        <div class="panel-heading">
                            <h4 class="panel-title">Search Bill Voucher
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    Voucher Number:<span class="errormsg">*</span></label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:TextBox ID="vNum" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    Voucher Type:</label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:DropDownList ID="typeDDL" runat="server" Width="100%" CssClass="form-control">
                                        <asp:ListItem Text="Sales Voucher" Value="s" />
                                        <asp:ListItem Text="Purchase Voucher" Value="p" />
                                        <asp:ListItem Text="Journal Voucher" Value="j" />
                                        <asp:ListItem Text="Contra Voucher" Value="c" />
                                        <asp:ListItem Text="Payment Voucher" Value="y" />
                                        <asp:ListItem Text="Receipt Voucher" Value="r" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-4">
                                    <input type="button" id="btn" value=" Search " class="btn btn-primary m-t-25" onclick="CheckFormValidation('v');" />
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
                            <h4 class="panel-title">Search By <%= Swift.web.Library.GetStatic.ReadWebConfig("tranNoName","") %>.
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>

                        <div class="panel-body">
                            <div class="form-group">
                                <label class="col-lg-3 col-md-4 control-label" for="">
                                    <%= Swift.web.Library.GetStatic.ReadWebConfig("tranNoName","") %>:<span class="errormsg">*</span></label>
                                <div class="col-lg-9 col-md-8">
                                    <asp:TextBox ID="controlNumber" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>

                            <div class="form-group">
                                <div class="col-md-2 col-md-offset-4">
                                    <input type="button" id="btnSearchByControlNumber" value=" Search " class="btn btn-primary m-t-25" onclick="CheckFormValidation('c');" />
                                </div>
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%--<div id="main-page-wrapper">
        <div class="breadCrumb">
            Bill & Voucher » Voucher Report</div>
        <div class="col-lg-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    Search Bill Voucher
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>
                                    Voucher Number:<span class="errormsg">*</span></label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <asp:TextBox ID="vNum" runat="server" Width="100%" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>
                                    Voucher Type:</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <asp:DropDownList ID="typeDDL" runat="server" Width="100%" CssClass="form-control">
                                    <asp:ListItem Text="Sales Voucher" Value="s" />
                                    <asp:ListItem Text="Purchase Voucher" Value="p" />
                                    <asp:ListItem Text="Journal Voucher" Value="j" />
                                    <asp:ListItem Text="Contra Voucher" Value="c" />
                                    <asp:ListItem Text="Payment Voucher" Value="y" />
                                    <asp:ListItem Text="Receipt Voucher" Value="r" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <input type="button" id="btn" value=" Search " class="btn btn-primary m-t-25" onclick="CheckFormValidation();" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>--%>
    </form>
</body>
</html>