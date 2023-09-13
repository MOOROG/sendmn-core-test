<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DocumentView.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CustomerSetup.DocumentView" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/functions.js"></script>
    <script type="text/javascript">
        //function showImage(param) {
        //    var imgSrc = $(param).attr("src");
        //    OpenInNewWindow(imgSrc);
        //};
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnFileName" runat="server" />
        <asp:HiddenField ID="hdnDocumentTypeId" runat="server" />
        <asp:HiddenField ID="hdncustomerId" runat="server" />
        <asp:HiddenField ID="hdnMembershipId" runat="server" />
        <asp:HiddenField ID="hdnFileType" runat="server" />
        <div class="page-wrapper">
            <div class="report-tab" runat="server" id="regUp">
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="row">
                            <div class="col-sm-12 col-md-6">
                                <div class="register-form">
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Customer Document View</h4>
                                        </div>
                                        <div class="panel-body">
                                            <div class="row">
                                                <div class="col-md-12" id="msgDiv" runat="server" visible="false" style="background-color: red;">
                                                    <div class="form-group">
                                                        <asp:Label ID="msgLabel" runat="server" ForeColor="White"></asp:Label>
                                                    </div>
                                                </div>

                                                <%--body part--%>
                                                <div class="form-group">
                                                    <div id="msg" runat="server" class="alert alert-info"></div>
                                                </div>
                                                <%--End body part--%>
                                            </div>
                                            <div class="col-md-12">
                                                <div class="form-group">
                                                    <asp:Image runat="server" ID="fileDisplay" Style="height: 200px; width: 300px; object-fit: contain;" onclick="showImage(this);" />
                                                </div>

                                                <div class="form-group">
                                                    <asp:Button runat="server" ID="downloadFile" CssClass="btn btn-primary m-t-25" Text="Download" OnClick="downloadFile_Click" />
                                                </div>
                                            </div>
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
