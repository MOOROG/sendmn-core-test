<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DownloadPDF.aspx.cs" Inherits="Swift.web.DownloadPDF" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="js/jQuery/jquery-1.4.1.js" type="text/javascript"></script>
    <script src="js/jspdf.min.js" type="text/javascript"></script>
    <script src="js/jspdf.debug.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">
        function GetPDF(){
            var pdf = new jsPDF('p', 'pt', 'letter');
            source = $('#content')[0];
            specialElementHandlers = {
                '#editor': function (element, renderer) {
                    return true
                }
            };
            margins = {
                top: 80,
                bottom: 60,
                left: 10,
                width: 1500
            };

            pdf.fromHTML(
                source,
                margins.left,
                margins.top, {
                    'width': margins.width,
                    'elementHandlers': specialElementHandlers
                },

                function (dispose) {

                        pdf.save('DownloadPDF.pdf');
                    }, margins);
                    window.close();
                    }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="content" runat="server" style="display: block;">
        </div>
        <div id="editor">
        </div>
    </form>
</body>
</html>