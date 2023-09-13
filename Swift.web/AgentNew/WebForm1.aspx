<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="Swift.web.AgentNew.WebForm1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="css/ie9.css" rel="stylesheet" />
    <link href="css/signature-pad.css" rel="stylesheet" />
    <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', 'UA-39365077-1']);
        _gaq.push(['_trackPageview']);

        (function () {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div id="signature-pad" class="signature-pad" style="margin-top: 0px;">
        <div class="signature-pad--body">
            <canvas></canvas>
        </div>
        <div class="signature-pad--footer">
            <div class="description">Sign above</div>

            <div class="signature-pad--actions">
                <div>
                    <button type="button" class="button clear" data-action="clear">Clear</button>
                    <%--  <button type="button" class="button" data-action="change-color">Change color</button>--%>
                    <button type="button" class="button" data-action="undo">Undo</button>

                </div>
                <%--<div>
          <button type="button" class="button save" data-action="save-png">Save as PNG</button>
          <button type="button" class="button save" data-action="save-jpg">Save as JPG</button>
          <button type="button" class="button save" data-action="save-svg">Save as SVG</button>
        </div>--%>
            </div>
        </div>
        <%-- <asp:Button ID="uploadImage" runat="server" Text="Upload" OnClick="uploadImage_Click" OnClientClick="return SaveImage();" />--%>
    </div>
    <asp:HiddenField ID="hddImgURL" runat="server" />
    <script src="js/signature_pad.umd.js"></script>
    <script src="js/app.js"></script>
    <script type="text/javascript">
</script>
</asp:Content>
