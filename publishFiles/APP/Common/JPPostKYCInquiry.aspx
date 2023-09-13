<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JPPostKYCInquiry.aspx.cs" Inherits="Swift.web.Common.JPPostKYCInquiry" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="JPPost.css" rel="stylesheet" />
    <link href="../css/style.css" rel="stylesheet" />
    <link href="../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <%--<script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js" type="text/javascript"> </script>
    <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>
    <script src="https://html2canvas.hertzen.com/dist/html2canvas.min.js"></script>--%>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.2/jquery.min.js"></script>
    <script src="https://files.codepedia.info/files/uploads/iScripts/html2canvas.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            var element = $("#response"); // global variable
            var getCanvas; // global variable
            GetTrackkingInfo();
            //html2canvas(element, {
            //    onrendered: function (canvas) {
            //        getCanvas = canvas;
            //    }
            //});

            $("#btn-save-print").on('click', function () {
                html2canvas(document.querySelector("#response")).then(canvas => {
                    getCanvas = canvas;
                    var imgageData = getCanvas.toDataURL("image/png");
                    //var newData = imgageData.replace(/^data:image\/png/, "data:application/octet-stream");
                    document.getElementById('hddImgURL').value = imgageData.replace('data:image/png;base64,', '');
                    $("#<%=btnSaveImg.ClientID%>").click();
                });
            });
        });
        function GetTrackkingInfo() {
            var trackingNumber = '<%=GetTranckingNumber()%>';
            var dataToSend = { MethodName: 'GetTrackingInfo', TrackingNumber: trackingNumber };
            var options =
            {
                url: '/Common/JPPostKYCInquiry.aspx',
                data: dataToSend,
                dataType: 'JSON',
                type: 'POST',
                success: function (response) {
                    $('#response').html(response);
                    $('.remove-tag-p').remove();
                }
            };
            $.ajax(options);
        };
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="reference">
            Reference from: https://trackings.post.japanpost.jp
        </div>
        <div id="response" style="background-color: white">
        </div>
        <p id="other-options text-justify">
            <input type="button" id="btn-save-print" value="Save Print" />&nbsp;&nbsp;<input type="button" value="Print" />&nbsp;&nbsp;<asp:Button ID="btnReSchedule" runat="server" OnClick="btnReSchedule_Click" Text="Re-Schedule" />
        </p>
        <asp:HiddenField ID="hddImgURL" runat="server" />
        <asp:Button ID="btnSaveImg" runat="server" OnClick="btnSaveImg_Click" Style="display: none;" />
    </form>
</body>
</html>