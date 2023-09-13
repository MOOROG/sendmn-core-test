﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="List.aspx.cs" Inherits="Swift.web.Remit.Administration.CountrySetup.ReceivingMode.List" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="../../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../../js/functions.js" type="text/javascript"> </script>

    <!-- Bootstrap -->
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
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
            if (id == "0") {
                alert("You can not modify this record. This is not agent specific record.");
                return;
            }
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
            SetValueById("<% =receivingMode.ClientID%>", "");
            SetValueById("<% =applicableFor.ClientID%>", "");
        }

        function NewRecord() {
            ResetForm();
            GetElement("<% =btnSave.ClientID%>").disabled = false;
            SetValueById("<% =hdnCrmId.ClientID%>", "0");
            ClearAll(gridName);
        }
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
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('sub_administration')">Sub_Administration</a></li>
                            <li class="active"><a href="List.aspx">Receiving Mode</a></li>
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
            <div id="divTab" runat="server"></div>
            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">State Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a><%--<a href="#"
                                            class="panel-action panel-action-dismiss" data-panel-dismiss></a>--%>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <table class="table table-responsive">
                                            <tr>
                                                <td>Receiving Mode
                                                    <span class="ErrMsg">*</span>
                                                    <asp:RequiredFieldValidator ID="rv1" runat="server" ControlToValidate="receivingMode"
                                                        ForeColor="Red" Display="Dynamic" ErrorMessage="Required" ValidationGroup="receivingmode"
                                                        SetFocusOnError="True">
                                                    </asp:RequiredFieldValidator>
                                                    <br />
                                                    <asp:DropDownList ID="receivingMode" runat="server" Width="150px"></asp:DropDownList>
                                                </td>
                                                <td>Applicable for
                                                    <br />
                                                    <asp:DropDownList ID="applicableFor" runat="server" Width="100px">
                                                        <asp:ListItem Value="A">All</asp:ListItem>
                                                        <asp:ListItem Value="S">Specify</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td>Agent Selection<br />
                                                    <asp:DropDownList ID="agentSelection" runat="server" Width="100px">
                                                        <asp:ListItem Value="M">Mandatory</asp:ListItem>
                                                        <asp:ListItem Value="N">No Selection</asp:ListItem>
                                                        <asp:ListItem Value="O">Optional</asp:ListItem>
                                                    </asp:DropDownList>
                                                </td>
                                                <td>
                                                    <asp:Button ID="btnSave" runat="server" CssClass="btn btn-primary" Text="Save" ValidationGroup="receivingmode" OnClick="btnSave_Click" />
                                                    <input type="button" value="New" onclick=" NewRecord(); " class="btn btn-primary" />
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                    <div class="form-group">
                                        <div id="rpt_grid" runat="server" class="gridDiv"></div>
                                    </div>
                                    <asp:HiddenField ID="hdnCrmId" runat="server" />
                                    <asp:Button ID="btnEdit" runat="server" OnClick="btnEdit_Click" Style="display: none;" />
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
    <script type="text/javascript" src="../../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="../../../../ui/js/metisMenu.min.js"></script>
</body>
</html>