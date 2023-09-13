<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CancelTPTxn.aspx.cs" Inherits="Swift.web.Remit.Transaction.CancelTPTxn.CancelTPTxn" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <%-- <link href="../../../css/style.css" rel="stylesheet" type="text/css" />--%>
    <link href="../../../css/TranStyle2.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <style>
        .auto-style1 {
            position: relative;
            min-height: 1px;
            float: left;
            width: 58.33333333%;
            left: 0px;
            top: 0px;
            padding-left: 15px;
            padding-right: 15px;
        }

        .msg-div {
            font-size: 15px;
            font-weight: 550;
            border: 1.5px solid red;
            margin: 15px;
            padding: 15px;
        }
    </style>

</head>
<body>

    <form id="form1" runat="server">
        <asp:ScriptManager runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="CancelTPTxn.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">CancelTPTxn</a></li>
                        </ol>
                    </div>
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Search By GME No.</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-md-6 ">
                                    <div class="form-group">
                                        <label class="col-md-3 control-label">
                                            GME No. :
                                        </label>
                                        <div class="col-md-7    ">
                                            <asp:TextBox ID="ControlNo" runat="server" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-md-3 control-label">Provider : </label>
                                        <div class="auto-style1">
                                            <asp:DropDownList runat="server" ID="Provider" CssClass="form-control">
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-md-4 col-md-offset-3">
                                            <asp:Button ID="btnSearch" runat="server" Text="Search" ValidationGroup="search" CssClass="btn btn-primary m-t-25"
                                                OnClick="btnSearch_Click" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group msg-div" id="rptGrid" runat="server" visible="false">
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
