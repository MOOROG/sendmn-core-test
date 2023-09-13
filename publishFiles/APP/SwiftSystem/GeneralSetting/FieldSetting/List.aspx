<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.FieldSetting.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script type="text/javascript" language="javascript">
        function OpenInEditMode(id, type) {
            if (id != "") {
                SetValueById("<% =hddDetailId.ClientID%>", id);
                SetValueById("<% =hdDetailType.ClientID%>", type);
                GetElement("<% =btnRedirectPage.ClientID%>").click();
            }
        }

        function DeleteRow(id) {
            if (id != "") {
                if (confirm("Are you sure to delete selected record?")) {
                    SetValueById("<% = hddDetailId.ClientID %>", id);
                    GetElement("<% = btnDelete.ClientID %>").click();
                }
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
                            <li class="active"><a href="List.aspx">Field Setting</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="Javascript:void(0)" class="selected" aria-controls="home" role="tab" data-toggle="tab">List </a></li>
                    <li role="presentation"><a href="Send.aspx" aria-controls="home" role="tab" data-toggle="tab">Send </a></li>
                    <li role="presentation"><a href="Receive.aspx" aria-controls="home" role="tab" data-toggle="tab">Receive</a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">List</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>

                                <div class="panel-body">
                                    <div class="form-group">
                                        <asp:HiddenField ID="hddDetailId" runat="server" />
                                        <asp:HiddenField ID="hdDetailType" runat="server" />
                                        <asp:Button runat="server" ID="btnRedirectPage" Style="display: none" OnClick="btnRedirectPage_Click" />
                                        <asp:Button runat="server" ID="btnDelete" Text="Delete" Style="display: none" OnClick="btnDelete_Click" />

                                    </div>
                                    <div class="table-responsive">
                                        <div id="rpt_grid" runat="server" class="gridDiv"></div>
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

<%--  <div style="margin-top:110px">
        <div class="breadCrumb"> Field Setting » List</div>
        <div>
            <table style="width: 100%" >
                <tr>
                    <td height="20" class="welcome"><span id="spnCname" runat="server"></span></td>
                </tr>
                <tr>
                    <td height="10"> 
                        <div class="tabs">
                            <ul>
                                <li> <a href="#" class="selected"> List </a></li>
                                <li> <a href="Send.aspx"> Send </a></li>
                                <li> <a href="Receive.aspx" > Receive </a></li>
                            </ul> 
                        </div> 
                    </td>
                 </tr>--%>
<%-- <tr>
                    <td>
                        <asp:HiddenField ID="hddDetailId" runat="server" />
                        <asp:HiddenField ID="hdDetailType" runat="server" />
                        <asp:Button runat="server" ID="btnRedirectPage"  style="display:none" onclick="btnRedirectPage_Click" />
                        <asp:Button runat="server" ID="btnDelete" Text="Delete" style="display:none" onclick="btnDelete_Click" />
                    </td>
                 </tr>   
            </table>
        </div>
      <div id="rpt_grid" runat="server" class="gridDiv"></div> 
    </div>--%>
   