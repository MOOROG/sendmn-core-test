<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RuleAdd.aspx.cs" Inherits="Swift.web.Remit.Commission.AgentCommissionRule.RuleAdd" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
     <script src="../../../js/functions.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>

    <style>
         .table .table {
    background-color: #F5F5F5 !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Service Charge & Commission </li>
                            <li><a href="List.aspx">Agent Commission Rule </a></li>
                            <li><a href="AgentCommission.aspx">Agent Commission and Service Charge Attach  </a></li>
                            <li class="active">Commission Rule Add</li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Agent Commission and Service Charge Attach</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                                <div class="form-group">
                                    <label class="control-label" ><span id="spnCname" runat="server">NAME</span></label>
                                </div>
                            <table id="Table1" runat="server" class="table table-responsive">
                                <div class="table table-responsive">
                                    <tr>
                                        <td>
                                            <div id="rpt_grid" runat="server"></div>
                                        </td>
                                    </tr>
                                </div>
                                <tr>
                                    <td>
                                        <asp:Button ID="btnAdd" runat="server" Text="Add Selected" CssClass="btn btn-primary"
                                            OnClick="btnAdd_Click" />
                                        <asp:HiddenField ID="hddFlag" runat="server" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

