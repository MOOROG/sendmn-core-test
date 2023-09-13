<%@ Page Title="" Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.StaticData.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="sm" runat="server"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
                            <li class="active"><a href="StaticValueList.aspx">Static Data</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation"><a href="List.aspx" class="selected" aria-controls="home" role="tab" data-toggle="tab">Static Data Type List </a></li>
                    <li role="presentation"><a href="StaticValueList.aspx?typeId= <%=Id()%>" class="selected" aria-controls="home" role="tab" data-toggle="tab">Static Data Value List </a></li>
                    <li role="presentation" class="active"><a href="#" class="selected" aria-controls="home" role="tab" data-toggle="tab">Manage Static Data Value </a></li>
                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Static Type Details
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label class="control-label" for="">
                                            <span class="ErrMsg">*</span> Fileds are mendotory and use the own idea to input this for</label>
                                    </div>
                                    <div class="form-group">
                                        <asp:Label ID="lblMsg" Font-Bold="true" ForeColor="Red" runat="server" Text=""></asp:Label>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-3 col-md-4 control-label" for="">
                                            Static Type:
                                            <span class="errormsg">*</span>
                                        </label>
                                        <div class="col-lg-9 col-md-8">
                                            <asp:DropDownList ID="typeID" runat="server" CssClass="form-control" Enabled="false">
                                            </asp:DropDownList>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="typeID" ValidationGroup="static" ErrorMessage="Required!" Display="Dynamic" ForeColor="Red">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-3 col-md-4 control-label" for="">
                                            Title:<span class="errormsg">*</span>
                                        </label>
                                        <div class="col-lg-9 col-md-8">
                                            <asp:TextBox ID="detailTitle" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1"
                                                runat="server" ControlToValidate="detailTitle" ValidationGroup="static" ErrorMessage="Required!" Display="Dynamic" ForeColor="Red">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-3 col-md-4 control-label" for="">
                                            Description: <span class="errormsg">*</span>
                                        </label>
                                        <div class="col-lg-9 col-md-8">
                                            <asp:TextBox ID="detailDesc" CssClass="form-control" runat="server" TextMode="MultiLine"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator3"
                                                runat="server" ControlToValidate="detailDesc" ValidationGroup="static" ErrorMessage="Required!" Display="Dynamic" ForeColor="Red">
                                            </asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-lg-3 col-md-4 control-label" for="">
                                            Is Active:            
                                        </label>
                                        <div class="col-lg-9 col-md-8">
                                            <asp:DropDownList ID="ddlStatus" CssClass="form-control" runat="server" Width="100%">
                                                <asp:ListItem Value="Y">Yes</asp:ListItem>
                                                <asp:ListItem Value="N">No</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-md-8 col-md-offset-3">
                                            <asp:Button ID="btnSumit" runat="server" Text="Submit" ValidationGroup="static" OnClick="btnSumit_Click" class="btn btn-primary m-t-25" />
                                            <cc1:ConfirmButtonExtender ID="btnSumitcc" runat="server"
                                                ConfirmText="Confirm To Save ?" Enabled="True" TargetControlID="btnSumit">
                                            </cc1:ConfirmButtonExtender>
                                            &nbsp;
                            <asp:Button ID="btnDelete" runat="server" Text="Delete" class="btn btn-primary m-t-25" OnClick="btnDelete_Click" />
                                            <cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server"
                                                ConfirmText="Are you sure to delete record ?" Enabled="True" TargetControlID="btnDelete">
                                            </cc1:ConfirmButtonExtender>
                                            <input type="button" id="btnBack" value=" Back " class="btn btn-primary m-t-25" onclick="Javascript: history.back(); " />
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
