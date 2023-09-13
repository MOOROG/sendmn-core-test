<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerDocument.aspx.cs" Inherits="Swift.web.Responsive.CustomerSetup.CustomerDocument" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="../../../ui/js/jquery.min.js"></script>
    <script src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js"></script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../../js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="../../../js/jQuery/jquery-ui.min.js"></script>
    <script src="../../../js/swift_calendar.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script>
        $(document).ready(function () {
            $("#<% =fileDocument.ClientID %>").change(function () {
                readURL(this, "fileDisplay");
            });
        });
        function CheckFormValidation() {
            var reqField = "ddlDocumentType,fileDocument,";
            cdid = $("#<% =hdnDocumentTypeId.ClientID %>").val();
            if (cdid != null && cdid !== "") {
                var reqField = "ddlDocumentType,";
            }
            if (ValidRequiredField(reqField) === false) {
                return false;
            }
            return true;
        }
        function showImage(param) {
            var imgSrc = $(param).attr("src");
            OpenInNewWindow(imgSrc);
        };
        function readURL(input, id) {
            if (input.files && input.files[0]) {
                a = input.files.fil
                var reader = new FileReader();
                reader.onload = function (e) {
                    $('#' + id).attr('src', e.target.result);
                }
                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            CalTillToday("#grid_list_createdDate");
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('customer_management')">Customer Management</a></li>
                            <li class="active"><a href="CustomerDocument.aspx?customerId=<%=hdncustomerId.Value %>&cdId=<%=hdnDocumentTypeId.Value %>">Customer Document </a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <div class="listtabs">
                    <ul class="nav nav-tabs" role="tablist">
                        <li role="presentation"><a href="List.aspx">Customer List</a></li>
                        <li class="active"><a href="CustomerDocument.aspx?customerId=<%=hdncustomerId.Value %>&cdId=<%=hdnDocumentTypeId.Value %>">Customer Document </a></li>
                    </ul>
                </div>

                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="row">
                            <div class="col-sm-12 col-md-12">
                                <div class="register-form">
                                    <div class="panel panel-default clearfix m-b-20">
                                        <div class="panel-heading">
                                            <h4 class="panel-title">Customer Document Type :<label id="customerName" runat="server"></label>(<%=hdnMembershipId.Value %>)</h4>
                                        </div>
                                        <asp:HiddenField ID="hdnFileName" runat="server" />
                                        <asp:HiddenField ID="hdnDocumentTypeId" runat="server" />
                                        <asp:HiddenField ID="hdncustomerId" runat="server" />
                                        <asp:HiddenField ID="hdnMembershipId" runat="server" />
                                        <asp:HiddenField ID="hdnFileType" runat="server" />
                                        <div class="panel-body row">
                                            <div class="col-md-6">
                                                <div class="col-md-12" id="msgDiv" runat="server" visible="false" style="background-color: red;">
                                                    <asp:Label ID="msgLabel" runat="server" ForeColor="White"></asp:Label>
                                                </div>
                                                <div class="form-group">
                                                    <label class="form-label">Document Type:<span class="errormsg">*</span></label>
                                                    <asp:DropDownList runat="server" ID="ddlDocumentType" name="ddlDocumentType" CssClass="form-control">
                                                    </asp:DropDownList>
                                                </div>
                                                <div class="form-group">
                                                    <label class="form-label">Document:<span class="errormsg">*</span></label>
                                                    <asp:FileUpload ID="fileDocument" runat="server" onChange="readURL(this, 'fileDisplay')" CssClass="form-control-plaintext form-control" />
                                                </div>

                                                <div class="form-group">
                                                    <label class="form-label">Description</label>
                                                    <asp:TextBox CssClass="form-control-plaintext form-control" TextMode="MultiLine" runat="server" ID="txtDocumentDescription"></asp:TextBox>
                                                </div>
                                                <div class="form-group">
                                                    <asp:Button ID="saveDocument" runat="server" CssClass="btn btn-primary m-t-25" Text="Submit" OnClientClick="return CheckFormValidation()" OnClick="saveDocument_Click" />
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <asp:Image runat="server" ID="fileDisplay" Style="height: 200px; width: 300px; object-fit: contain;" onclick="showImage(this);" />

                                                <br />
                                                <asp:Button runat="server" ID="downloadFile" CssClass="btn btn-primary m-t-25" Text="Download" OnClick="downloadFile_Click"/>
                                               <%--<a href="" runat="server" id="downloadFile" visible="false" class="btn btn-primary m-t-25" >Download</a>--%>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default ">
                        <div class="panel-heading">
                            <h4 class="panel-title">Customer Document Type</h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle=""></a>
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
