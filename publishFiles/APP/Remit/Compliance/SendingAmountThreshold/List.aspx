﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Compliance.SendingAmountThreshold.List" %>

<!DOCTYPE html>
<link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
<link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
<link href="../../../ui/css/style.css" rel="stylesheet" />
<script src="../../../js/Swift_grid.js"></script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
                            <li><a href="#" onclick="return LoadModule('remit')">Remit</a></li>
                            <li><a href="#" onclick="return LoadModule('remit_compliance')">Compliance</a></li>
                            <li class="active"><a href="List.aspx">Sending Amount Threshold </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="Javascript:void(0)" class="selected" target="_self">List</a></li>
                    <li><a href="Manage.aspx" target="_self">Manage </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Sending Amount Threshold
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
                                    </div>
                                    <div class="form-group">
                                        <asp:HiddenField ID="hdnRowId" runat="server" />
                                        <asp:Button ID="btnDelete" CssClass="hide" runat="server" Text="" OnClick="btnDelete_Click" />
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