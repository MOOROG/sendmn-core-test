<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SubLocationList.aspx.cs" Inherits="Swift.web.Remit.TPSetup.ServiceWiseLocation.SubLocationList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../js/Swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
    <script src="../../../js/swift_autocomplete.js"></script>
    <script src="../../../ui/js/custom.js"></script>
    <script src="../../../js/swift_calendar.js"></script>
    <script type="text/javascript">
        function LockUnlock(partnerId) {
            if (partnerId == "" || partnerId == null)
                return;
            if (confirm("Are you sure to block/unblock the setting ?")) {
                SetValueById("<%=hddPartnerId.ClientID %>", partnerId, "");
                GetElement("<%=btnBlockUnblock.ClientID %>").click();
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:Button ID="btnBlockUnblock" runat="server" Style="display: none;" OnClick="btBlockUnblock_Click" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Partner Setup</a></li>
                            <li><a href="#">Service Wise Location</a></li>
                            <li class="active"><a href="#">Service Wise Sub Location</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li><a href="List.aspx">Service Wise Location List</a></li>
                    <li role="presentation" class="active"><a href="javascript:void(0);" aria-controls="home" role="tab" data-toggle="tab">Service Wise Sub Location List</a></li>
                    <li><a href="ManageSubLocation.aspx?locId=<%=GetId() %>&locName=<%=GetLocation() %>">Manage Service Wise Sub Location</a></li>
                </ul>
            </div>
            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <!--end .row-->
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <div id="rpt_grid" runat="server" class="gridDiv" enableviewstate="false"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <asp:HiddenField ID="hddPartnerId" runat="server" />
    </form>
</body>
</html>
