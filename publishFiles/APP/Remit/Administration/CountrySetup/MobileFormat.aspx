<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MobileFormat.aspx.cs" Inherits="Swift.web.Remit.Administration.CountrySetup.MobileFormat" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>

    <!-- Bootstrap -->
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <script type="text/javascript">
        var gridName = "<% =GridName%>";

        function GridCallBack() {
            var id = GetRowId(gridName);

            if (id != "") {
                GetElement("<% =btnEdit.ClientID%>").click();
                GetElement("<% =btnSave.ClientID%>").disabled = false;
            } else {
                GetElement("<% =btnSave.ClientID%>").disabled = true;
                ResetForm();
                ClearAll(gridName);
            }
        }

        function ResetForm() {
            SetValueById("<% =mblOperator.ClientID%>", "");
            SetValueById("<% =prefix.ClientID%>", "");
        }

        function NewRecord() {
            ResetForm();
            GetElement("<% =btnSave.ClientID%>").disabled = false;
            SetValueById("<% =mobileOperatorId.ClientID%>", "0");
            ClearAll(gridName);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Sub_Administration</a></li>
                            <li class="active"><a href="MobileFormat.aspx">Country Setup</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->

            <!-- Nav tabs -->
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="deactive"><a href="List.aspx">Country List </a></li>
                    <li role="presentation" class="active"><a href="#list" aria-controls="home" role="tab" data-toggle="tab">Manage Country</a></li>
                </ul>
            </div>
            <div>
                <label><span id="spnCname" runat="server"><%=GetCountryName()%></span></label>
            </div>
            <div id="divTab" runat="server">
            </div>
            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Mobile Format Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><%--<a href="#"
                                            class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <asp:UpdatePanel ID="upnl1" runat="server">
                                        <ContentTemplate>
                                            <div class="form-group">
                                                <label><span class="errormsg">*</span> Fields are mandatory</label>
                                            </div>
                                            <div class="form-group" id="MessageDiv" runat="server" visible="false">
                                                <label>
                                                    <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label></label>
                                            </div>

                                            <div class="row form-group">
                                                <div class="col-md-4">
                                                    <label>
                                                        ISD Country Code:
                                                    <span class="errormsg">*</span>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="ISDCountryCode" ForeColor="Red"
                                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </label>
                                                    <asp:TextBox ID="ISDCountryCode" runat="server" CssClass="form-control" TabIndex="1"></asp:TextBox>
                                                </div>
                                                <div class="col-md-4">
                                                    <label>
                                                        Mobile Length:
                                                        <span class="errormsg">*</span>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="mobileLen" ForeColor="Red"
                                                            ValidationGroup="country" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </label>
                                                    <asp:TextBox ID="mobileLen" runat="server" CssClass="form-control" TabIndex="2"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="row form-group">
                                                <div class="col-md-4">
                                                    <label>
                                                        Operator:
                                                    </label>
                                                    <asp:TextBox ID="mblOperator" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="col-md-4">
                                                    <label>
                                                        Prefix:
                                                    </label>
                                                    <asp:TextBox ID="prefix" runat="server" CssClass="form-control"></asp:TextBox>
                                                </div>
                                                <div class="col-md-4">
                                                    <br />
                                                    <input type="button" value="New" onclick=" NewRecord(); " class="btn btn-primary" />
                                                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary"
                                                        OnClick="btnSave_Click" />
                                                    <asp:Button ID="btnEdit" runat="server" Text="Edit" Style="display: none;"
                                                        OnClick="btnEdit_Click" />
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div id="rpt_grid" runat="server" class="gridDiv">
                                                </div>
                                            </div>

                                            <div class="row form-group">
                                                <div class="col-md-12">
                                                    <asp:Button ID="btnSumit" runat="server" Text="Submit" CssClass="btn btn-primary"
                                                        ValidationGroup="country" Display="Dynamic" TabIndex="16"
                                                        OnClick="btnSumit_Click" />
                                                    <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                        ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSumit">
                                                    </cc1:ConfirmButtonExtender>
                                                    &nbsp;
                                                    <input id="btnBack" type="button" class="btn btn-primary" value="Back" onclick=" Javascript: history.back(); " />
                                                    <asp:HiddenField ID="mobileOperatorId" runat="server" />
                                                </div>
                                            </div>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                            </div>
                            <!-- End .panel -->
                        </div>
                        <!--end .col-->
                    </div>
                    <!--end .row-->
                </div>
            </div>
        </div>
    </form>
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../../../ui/js/metisMenu.min.js"></script>
</body>
</html>