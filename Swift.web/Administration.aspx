<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Administration.aspx.cs" Inherits="Swift.web.Administration" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title></title>
    <link href="ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <link href="ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="ui/css/style.css" rel="stylesheet" />
    <style type="text/css">
        .panel-success {
            min-height: 155px !important;
        }

            .panel-success .panel-heading {
                min-height: 50px !important;
            }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper container navigation">
            <div class="row">
                <div class="col-md-12">
                    <h3 class="text-center">
                        <asp:Label ID="title" runat="server"></asp:Label>
                    </h3>
                    <div class="row">
                        <div id="divTilesMain" runat="server">
                            <div class="col-md-3">
                                <a href="#" target="_blank" class="information">
                                    <div class="panel panel-success ">
                                        <div class="panel-heading">
                                            <h3 class="panel-title">Voucher Entry
                                            </h3>
                                        </div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-md-2">
                                                    <i class="fa fa-list-ul" aria-hidden="true"></i>
                                                </div>
                                                <div class="col-md-10">
                                                    <p>This is user management panel.This is user management panel.This is user management panel.</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script src="ui/js/jquery.min.js"></script>
    <script src="ui/bootstrap/js/bootstrap.min.js"></script>
</body>
</html>