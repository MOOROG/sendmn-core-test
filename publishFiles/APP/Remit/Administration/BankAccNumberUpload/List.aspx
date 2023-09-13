<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.BankAccNumberUpload.List" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('account')">Other Services </a></li>
                            <li class="active"><a href="List.aspx">Bank and AccNumber Upload</a></li>
                        </ol>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-8">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h4 class="panel-title">Upload  Bank and Account Number
                            </h4>
                            <div class="panel-actions">
                            </div>
                        </div>

                        <div class="panel-body">

                            <div class="form-group">
                                <label class="col-md-3">Upload Data:</label>
                                <div class="col-md-4">
                                    <asp:FileUpload ID="fileUpload" runat="server" />
                                </div>
                                <div class="col-md-5">
                                    <a href="../../../SampleFile/VirtualAccountName.csv"><b>Download Sample File </b></a>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-12">
                                    <div style="color: red; font-size: 16px;" runat="server" visible="false" id="msg"></div>
                                    <div style="color: green; font-size: 16px;" runat="server" visible="false" id="msgSuccess"></div>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-md-4 col-md-offset-3">
                                    <asp:Button ID="btnFileUpload" Text="Upload File" runat="server" CssClass="btn btn-primary m-t-25" OnClick="btnFileUpload_Click" />
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