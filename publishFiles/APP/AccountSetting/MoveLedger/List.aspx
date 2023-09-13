<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" EnableEventValidation="false"
    Inherits="Swift.web.AccountSetting.MoveLedger.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <!-- MetisMenu CSS -->
    <link href="../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../js/functions.js" type="text/javascript"></script>
    <script src="../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(function () {
            $("#left").bind("click", function () {
                var options = $("[id*=ledgerInfoDetail2] option:selected");
                for (var i = 0; i < options.length; i++) {
                    var opt = $(options[i]).clone();
                    $(options[i]).remove();
                    $("[id*=ledgerInfoDetail1]").append(opt);
                }
            });
            $("#right").bind("click", function () {
                var options = $("[id*=ledgerInfoDetail1] option:selected");
                for (var i = 0; i < options.length; i++) {
                    var opt = $(options[i]).clone();
                    $(options[i]).remove();
                    $("[id*=ledgerInfoDetail2]").append(opt);
                }
            });
            $("[id*=btnSave]").bind("click", function () {
                $("[id*=ledgerInfoDetail1] option").attr("selected", "selected");
                $("[id*=ledgerInfoDetail2] option").attr("selected", "selected");
            });
        });
        function listbox_selectall(listID) {
            var listbox = document.getElementById(listID);
            for (var count = 0; count < listbox.options.length; count++) {
                listbox.options[count].selected = true;
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdn1" runat="server" />
        <asp:HiddenField ID="hdn2" runat="server" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1><small></small>
                        </h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Account</a></li>
                            <li><a href="#" onclick="return LoadModule('sub_account')">Sub_Account </a></li>
                            <li class="active"><a href="List.aspx">Move Ledger</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Ledger Movement
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <asp:DropDownList ID="ledgerInfo1" runat="server" Width="100%" CssClass="form-control"
                                            OnSelectedIndexChanged="ledgerInfo1_SelectedIndexChanged" AutoPostBack="true">
                                        </asp:DropDownList>
                                        <br />
                                        <asp:ListBox ID="ledgerInfoDetail1" runat="server" CssClass="form-control" SelectionMode="Multiple"
                                            Width="100%" Style="height: 350px !important;"></asp:ListBox>
                                        <br />
                                        <input type="button" class="btn btn-primary" onclick="listbox_selectall('ledgerInfoDetail1')" value="Select All" />
                                    </div>
                                </div>
                                <div class="col-md-1">
                                    <div class="form-group" style="margin-top: 150px;">
                                        <input type="button" id="left" value="<<" class="btn btn-primary m-t-25" /><br />
                                        <br />
                                        <input type="button" id="right" value=">>" class="btn btn-primary m-t-25" />
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <asp:DropDownList ID="ledgerInfo2" runat="server" Width="100%" CssClass="form-control"
                                            OnSelectedIndexChanged="ledgerInfo2_SelectedIndexChanged">
                                        </asp:DropDownList>
                                        <br />
                                        <asp:ListBox ID="ledgerInfoDetail2" runat="server" CssClass="form-control" SelectionMode="Multiple"
                                            Width="100%" Style="height: 350px !important;"></asp:ListBox><br />
                                        <input type="button" class="btn btn-primary" onclick="listbox_selectall('ledgerInfoDetail2')" value="Select All" />
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <asp:Button ID="btnSave" runat="server" Text="Save Movement" CssClass="btn btn-primary m-t-25"
                                            OnClick="btnSave_Click" />
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