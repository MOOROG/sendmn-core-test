<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AgentGroupMapping.aspx.cs" Inherits="Swift.web.Remit.Administration.AgentSetup.Functions.AgentGroupMapping" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />

    <!-- Bootstrap -->
    <link href="../../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <!--        <link rel="stylesheet" href="css/nanoscroller.css">-->
    <link href="../../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />

    <script src="../../../../js/functions.js" type="text/javascript"></script>
    <script src="../../../../js/Swift_grid.js" type="text/javascript"></script>
   <script src="../../../../ui/js/jquery-3.1.1.min.js" type="text/javascript"></script>
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <script type="text/javascript">
        $(document).ready(function () {
            $("#<%=RequiredFieldValidator14.ClientID%>").hide();
            $("#<%=RequiredFieldValidator2.ClientID%>").hide();
        })
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
        <div class=" container">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li>Agent Management </li>
                            <li>Agent Setup</li>
                            <li class="active">Agent Group Setup </li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li id="BusinessFunctionTab" runat="server"></li>
                    <li id="RegionalBranchAccessSetup" runat="server"></li>
                    <li class="active"><a href="#" class="selected">Agent Group</a></li>
                    <li id="SendingCountry" runat="server"></li>
                    <li id="ReceivingCountry" runat="server"></li>
                </ul>
            </div>
            <div class="clearfix">
                <br />
            </div>
            <div class="tab-content">
                <div class="tab-pane active" id="Manage">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Agent Group Details
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="form-group">
                                            <asp:Label ID="lblMsg" Font-Bold="true" runat="server" Text=""></asp:Label>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="form-group">
                                            <label class="control-label col-lg-2 col-md-3" for=""><%=GetAgentPageTab()%></label>
                                        </div>
                                        <div class="form-group">
                                            <label class="control-label col-lg-2 col-md-3" for="">
                                                Group Category:<span class="errormsg">*</span>
                                            </label>
                                            <div class="col-md-6">
                                                <asp:DropDownList runat="server" ID="DDLGroupCat" Class="form-control"
                                                    OnSelectedIndexChanged="DDLGroupCat_SelectedIndexChanged" AutoPostBack="true">
                                                </asp:DropDownList>
                                                <asp:RequiredFieldValidator
                                                    ID="RequiredFieldValidator14" runat="server" ControlToValidate="DDLGroupCat" ForeColor="Red"
                                                    Display="Dynamic" ErrorMessage="Required!" SetFocusOnError="True" ValidationGroup="servicetype">
                                                </asp:RequiredFieldValidator>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="form-group">
                                            <label class="control-label col-lg-2 col-md-3" for="">
                                                Group Detail:  <span class="errormsg">*</span>
                                            </label>
                                            <div class="col-md-6">
                                                <asp:DropDownList runat="server" ID="DDLGroupDetail" Class="form-control">
                                                </asp:DropDownList>
                                                <asp:RequiredFieldValidator
                                                    ID="RequiredFieldValidator2" runat="server" ControlToValidate="DDLGroupDetail" ForeColor="Red"
                                                    Display="Dynamic" ErrorMessage="Required!" SetFocusOnError="True" ValidationGroup="servicetype">
                                                </asp:RequiredFieldValidator>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-4 col-md-offset-2 ">
                                            <asp:Button ID="bntSubmit" runat="server" Text="Submit" CssClass="btn btn-primary m-t-25" ValidationGroup="servicetype" TabIndex="4" OnClick="bntSubmit_Click" />
                                            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender2" runat="server"
                                                ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="bntSubmit">
                                            </cc1:ConfirmButtonExtender>
                                            &nbsp;
                            <asp:Button ID="btnDelete" runat="server" Text="New" CssClass="btn btn-primary m-t-25" TabIndex="5" OnClick="btnDelete_Click" />
                                            &nbsp;
                            <input id="btnBack" type="button" class="btn btn-primary m-t-25" value="Back" onclick=" Javascript: history.back(); " />
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
                            <h4 class="panel-title">Agent group details
                            </h4>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle"></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div id="rpt_grid" runat="server" class="table"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
