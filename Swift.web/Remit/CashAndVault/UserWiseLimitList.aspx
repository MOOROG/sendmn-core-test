<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserWiseLimitList.aspx.cs" Inherits="Swift.web.Remit.CashAndVault.ManageUserWiseLimit" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
		function ActiveInActive(cashHoldLimitId,status){
			if (cashHoldLimitId == "" || cashHoldLimitId == null)
					return;
			if (status == 0) {
					if (confirm("Are you sure to InActive the user?")) {
						GetElement("hddcashHoldLimitId").value = cashHoldLimitId;
						GetElement("hddisActive").value = status;
						GetElement("btnUpdate").click();
					}
				}
			else if (status == 1) {
					if (confirm("Are you sure to Active the user?")) {
						GetElement("hddcashHoldLimitId").value = cashHoldLimitId;
						GetElement("hddisActive").value = status;
						GetElement("btnUpdate").click();
					}
			}
		}
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hddisActive" runat="server" />
        <asp:HiddenField ID="hddcashHoldLimitId" runat="server" />
        <asp:Button ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" Style="display: none;" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a>Exchange Setup</a></li>
                            <li class="active"><a>Cash And Vault</a></li>
                            <li class="active"><a href="List.aspx">BranchWise Cash And Vault Setup</a></li>
                            <li class="active"><a>UserWise Cash And Vault Setup</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title" id="H4" runat="server"></h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="rpt_grid" runat="server"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>