﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.RiskBaseAnalysis.BranchRatingNEW.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">

<base id="Base1" target = "_self" runat = "server" />
    
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
      
     <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>    
    <script src="../../../js/swift_autocomplete.js" type="text/javascript"></script>
     <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
       <script type="text/javascript" language="javascript">
           $(document).ready(function () {
               ShowCalFromToUpToToday("#gridBranchRatingNEW_fromDate", "#gridBranchRatingNEW_toDate", 1);
               ShowCalFromToUpToToday("#gridBranchRatingNEW_reviewedDate");
               ShowCalFromToUpToToday("#gridBranchRatingNEW_approvedDate");
               
           });
       
           function CallBackSave(errorCode, msg, url) {
               if (msg != '')
                   alert(msg);
               if (errorCode == '0') {
                   RedirectToIframe(url);
               }
           }


           function RedirectToIframe(url) {
               window.open(url, "_self");
           }

    </script> 

    <title></title>
</head>
<body>
    <form id="form1" runat="server">
<asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remit')">Branch Rating</a></li>
                            <li class="active"><a href="#" onclick="return LoadModule('remit_compliance')">Branch Ranking</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="#">List</a></li>
                    <li><a href="Manage.aspx">Manage </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Branch Rating
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <div id = "rpt_grid" runat = "server" class = "gridDiv" enableviewstate="false">                    
                                        </div>
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