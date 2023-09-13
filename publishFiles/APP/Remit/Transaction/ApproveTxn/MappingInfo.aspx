<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MappingInfo.aspx.cs" Inherits="Swift.web.Remit.Transaction.ApproveTxn.MappingInfo" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <base id="Base2" runat="server" target="_self" />
    <script src="/ui/js/jquery.min.js"></script>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/Swift_grid.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
    <script src="/ui/js/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <script src="/js/swift_autocomplete.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        function Approve(customerId, tranId,remittrantempId) {
            $('#hddTranId').val(tranId);
            $('#hddremitTranTempId').val(remittrantempId);
            $('#hddCustomerId').val(customerId);
            $('#btnApprove').click();
        }

        function Reject(customerId, tranId) {
            $('#hddTranId').val(tranId);
            $('#hddCustomerId').val(customerId);
            $('#btnReject').click();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hddTranId" runat="server" />
        <asp:HiddenField ID="hddremitTranTempId" runat="server" />
        <asp:HiddenField ID="hddCustomerId" runat="server" />
        <asp:Button ID="btnReject" runat="server" style="display:none;" OnClick="btnReject_Click" />
        <asp:Button ID="btnApprove" runat="server" style="display:none;" OnClick="btnApprove_Click" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-md-12">
                    <label id="lblAvailableBalance" runat="server" style="background-color:yellow; font-size:15px;"></label><br />
                    <label style="color:red;">Note: *If there is data pending for approval in below table, then this amount is including those amounts.</label>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
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
