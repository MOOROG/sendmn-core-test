<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.AccountSetting.CreateLedger.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
    <script type="text/javascript">
        var GB_ROOT_DIR = "../../include/greybox/";

        function ShowReportHead(obj, td) {
            var listElementStyle = document.getElementById(td);
            if (listElementStyle.style.display == "none") {
                exec_AJAX('ShowDrillDownHead.aspx?q=' + obj, td, '');
                listElementStyle.style.display = "block";
            }
            else {
                listElementStyle.style.display = "none";
            }
        }

        function ShowReportSubHead(obj, td) {
            var listElementStyle = document.getElementById(td);
            if (listElementStyle.style.display == "none") {
                exec_AJAX('CreateSubGL.aspx?q=' + obj, td, '');
                listElementStyle.style.display = "block";
            }
            else {
                listElementStyle.style.display = "none";
            }

        }

        function ShowReportGL(obj, td) {
            var listElementStyle = document.getElementById(td);

            if (listElementStyle.style.display == "none") {
                listElementStyle.style.display = "block";
                exec_AJAX('CreateGL.aspx?q=' + obj, td, '');
            }
            else {
                //alert(listElementStyle.innerHTML);
                listElementStyle.style.display = "none";
                //listElementStyle.innerHTML=""
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
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Sub_Account </a></li>
                            <li class="active"><a href="List.aspx">Create Account</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title creat-account">
                                <i class="fa fa-book"></i>
                                <span class="ledger" onclick="ShowReportHead('a','tdasset');" style="cursor: pointer;">
                                    <strong>Source Of Fund(LIABILITIES)</strong>
                                </span>
                            </h4>
                            <%-- <div class="panel-actions">
                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                    <a href="#" class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                </div>--%>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-12">
                                    <div id="tdasset" style="display: none">
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div id="tdexpense" style="display: none">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title creat-account">
                                <i class="fa fa-book"></i>
                                <strong style="cursor: pointer;" onclick="ShowReportHead('l','tdlia');">APPLICATION OF FUNDS(ASSETS) </strong>
                            </h4>
                            <%--<div class="panel-actions">
                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                    <a href="#"class="panel-action panel-action-dismiss" data-panel-dismiss></a>
                </div>--%>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-12">
                                    <div id="tdlia" style="display: none"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <a href="SearchAccount.aspx" title="Search Ledger" rel="gb_page_center[750,500]" style="text-decoration: none; font-size: 12px;">Search
                                            Ledger/Group </a>
                </div>
            </div>
        </div>
    </form>
    <script src="../../include/greybox/AJS.js" type="text/javascript"></script>
    <script src="../../include/greybox/gb_scripts.js" type="text/javascript"></script>
    <link href="../../include/greybox/gb_styles.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/ajax_func.js"> </script>
    <script type="text/javascript" id="ledger">
        function ShowMessage(ParentID, NewId) {
            GB_showCenter('Add Ledger Group', '../AddGL.aspx?ParentID=' + ParentID + '&id=' + NewId, '1000', '1000', '');
        }
        function ShowMessageSubcodeAccount(ID) {
            GB_showCenter('Add Account Ledger Group', '../AddNewAc.aspx?flag=g&ID=' + ID, '550', '650', '');
        }
        function ShowMessageAccountAdd(ID) {
            GB_showCenter('Add Account Ledger Group', '../AddGLCodeAccount.aspx?flag=s&ID=' + ID, '600', '650', '');
        }
        function ShowMessageSubcode(ID, SUBID) {
            GB_showCenter('Add Sub Ledger Group', '../AddGLSubCode.aspx?ID=' + ID + '&SUBID=' + SUBID, '310', '550', '');
        }
        function ShowMessageAccount(ParentID, NewId) {
            GB_showCenter('Add Account', '../AddNewAc.aspx?ParentID=' + ParentID + '&id=' + NewId, '550', '600', '');
        }
        function EditLedger(Rowid, ParentID) {
            GB_showCenter('Edit Sub Ledger Group', '../AddGL.aspx?Rowid=' + Rowid + '&ParentID=' + ParentID, '307', '550', '');
        }
        function EditLedgersubcode(Rowid) {
            GB_showCenter('Edit Sub Ledger Group', '../EditGLSubCode.aspx?Rowid=' + Rowid, '315', '550', '');
        }
        function EditLedgerAcccode(ID) {
            GB_showCenter('Edit Account Ledger Group', '../AddNewAc.aspx?ID=' + ID, '600', '650', '');
        }

        function DeleteLedger(str) {
            if (confirm('Are you sure to delete?')) {
                var Alurl = 'DeleteLedger.aspx?deltrn=y&delrowid=' + str
                exec_AJAX(Alurl, 'Deletespn', '');
                //alert(str);
            }
        }

        function DeleteLedgerAcccode(str) {
            if (confirm('Are you sure to delete this account?')) {
                var Alurl = 'DeleteLedger.aspx?delAcc=y&delrowid=' + str
                exec_AJAX(Alurl, 'Deletespn', '');
                //alert(str);
            }
        }
    </script>
</body>
</html>