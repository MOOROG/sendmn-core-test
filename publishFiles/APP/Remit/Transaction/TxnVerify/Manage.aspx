<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.TxnVerify.Manage" %>

<%@ Register TagPrefix="cc1" Namespace="AjaxControlToolkit" Assembly="AjaxControlToolkit, Version=3.0.20820.16598, Culture=neutral, PublicKeyToken=28f01b0e84b6d53e" %>
<%@ Register TagPrefix="uc1" TagName="UcTransaction" Src="~/Remit/UserControl/UcTransaction.ascx" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head id="Head1" runat="server">
    <base id="Base2" runat="server" target="_self" />
    <script src="/ui/js/jquery.min.js"></script>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/functions.js" type="text/javascript"> </script>

    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <style>
        legend {
            color: #FFFFFF;
            background: #FF0000;
            border-radius: 2px;
        }

        fieldset {
            border: 1px solid #000000;
        }

        td {
            color: #000000;
        }

        .watermark {
            font-size: 14px;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#btnApprove').hide();
            $('.navbar').empty();
            $('.breadcrumb').empty();
            scroll(0, 0);
        });
    </script>
</head>
<body>

    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
        <div id="divControlno" runat="server">
            <div class="page-wrapper">
                <div class="row">
                    <div class="col-sm-12">
                        <div class="page-title">
                            <h1></h1>
                            <ol class="breadcrumb">
                                <li><a href="#" onclick="return LoadModule('remittance')">Remittance</a></li>
                                <li><a href="#" onclick="return LoadModule('transaction')">Transaction </a></li>
                                <li class="active"><a href="Manage.aspx">Approve  Transaction Details </a></li>
                            </ol>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-12">
                        <div class="panel panel-default recent-activites">
                            <!-- Start .panel -->
                            <div class="panel-heading">
                                <h4 class="panel-title">Detail Of Hold Approval Waiting Transaction
                                </h4>
                                <div class="panel-actions">
                                    <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                </div>
                            </div>

                            <div class="panel-body">
                                <div class="form-group">
                                    <div id="divTranDetails" runat="server" visible="false">
                                        <uc1:UcTransaction ID="ucTran" runat="server" ShowDetailBlock="true" ShowLogBlock="false" ShowCompliance="false" ShowOfac="false" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <asp:Button ID="btnApprove" CssClass="btn btn-primary m-t-25" runat="server" Text="Approve"
                                        OnClick="btnApprove_Click" />
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