<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.GeneralSetting.GeneralData.Manage" %>

<%@ Import Namespace="Swift.web.Library" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <!-- Bootstrap Core CSS -->
    <link href="../../../Bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- MetisMenu CSS -->
    <link href="../../../Bootstrap/css/metisMenu.min.css" rel="stylesheet" type="text/css" />
    <!-- timeline CSS -->
    <link href="../../../Bootstrap/css/timeline.css" rel="stylesheet" type="text/css" />
    <!-- Custom CSS -->
    <link href="../../../Bootstrap/css/style.css" rel="stylesheet" type="text/css" />
    <base id="Base1" target="_self" runat="server" />
    <link href="../../../css/style1.css" rel="stylesheet" type="text/css" />
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <script language="javascript" type="text/javascript">
        function goBack() {
            window.history.back();
        }
        function CheckRequired() {
            var RequiredField = "code,description,";
            if (ValidRequiredField(RequiredField) == false) {
                return false;
            }
            else {
                if (confirm("Are you sure to save a transaction?")) {
                    return true;
                }
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server" onsubmit="return CheckRequired();">
        <div id="main-page-wrapper">
            <div class="breadCrumb">
                Application Log » General Data Settings » List »
            <asp:Label ID="labelHead" runat="server" />
                » Manage
            </div>
            <div class="col-lg-12">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <asp:Label ID="header" runat="server" />
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-2">
                                <label>
                                    Code:<span class="errormsg">*</span></label>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <asp:TextBox ID="code" runat="server" Width="100%" CssClass="form-control" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-2">
                                <div class="form-group">
                                    <label>
                                        Description:<span class="errormsg">*</span></label>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <asp:TextBox ID="description" runat="server" Width="100%" CssClass="form-control" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-2">
                                <label>
                                    <asp:Label ID="createdByLabel" runat="server" Text="Created By:" Visible="false" /></label>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <asp:Label ID="createdBy" runat="server" Visible="false" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-2">
                                <label>
                                    <asp:Label ID="createdDateLabel" Text="Created Date:" runat="server" Visible="false" /></label>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <asp:Label ID="createdDate" runat="server" Visible="false" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-2">
                                <label>
                                    <asp:Label ID="modifiedByLabel" Text="Modified By:" runat="server" Visible="false" /></label>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <asp:Label ID="modifiedBy" runat="server" Visible="false" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-2">
                                <label>
                                    <asp:Label ID="modifiedDateLabel" Text="Modified Date:" runat="server" Visible="false" /></label>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <asp:Label ID="modifiedDate" runat="server" Visible="false" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12">
                                <div class="form-group">
                                    <asp:Button ID="btnSubmit" runat="server" Text="Save" CssClass="btn btn-primary m-t-25"
                                        OnClick="btnSumit_Click" />
                                    <button class="btn btn-primary m-t-25" onclick="goBack()" type="submit">
                                        Back</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <asp:HiddenField ID="idField" runat="server" />
    </form>
</body>
</html>