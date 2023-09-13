<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CommissionView.aspx.cs" Inherits="Swift.web.Remit.DomesticOperation.CommissionGroupMapping.CommissionView" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../css/style.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script src="../../../js/jQuery/jquery-1.4.1.min.js" type="text/javascript"></script>
</head>
<script type="text/javascript">
    function ShowHide(obj, imgId) {
        var img = GetElement(imgId);
        var me = GetElement(obj);
        if (me.style.display == "block") {
            me.style.display = "none";
            img.src = "../../../images/plus.png";
            img.title = "Show";
        }
        else {
            me.style.display = "block";
            img.src = "../../../images/minus.gif";
            img.title = "Hide";
        }
        //            $("#" + obj).slideToggle("fast");
    }
</script>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active">Commission Group Mapping</li>
                            <li class="active">Commission Rule Detail </li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title"><%=GetPackageName()%></h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                             <div class="table table-responsive">
                            <table runat="server" class="table table-responsive">
                                    <tr>
                                        <td>
                                            <div id="rpt_rule" runat="server"></div>
                                        </td>

                                    </tr>
                                
                                    <tr>
                                        <td>
                                            <div id="rpt_grid" runat="server" class="gridDiv"></div>
                                        </td>
                                    </tr>
                                
                            </table>
                                 </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
