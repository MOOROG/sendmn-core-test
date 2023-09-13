<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Send.aspx.cs" Inherits="Swift.web.SwiftSystem.GeneralSetting.FieldSetting.Send" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../../js/functions.js" type="text/javascript"> </script>
    <link href="../../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../../ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../../ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="../../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../../ui/css/datepicker-custom.css" rel="stylesheet" />

    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="../../../ui/js/bootstrap-datepicker.js"></script>
    <script src="../../../ui/js/pickers-init.js"></script>
    <script src="../../../ui/js/jquery-ui.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                             <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
                            <li class="active"><a href="Send.aspx">Field Setting</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation"><a href="List.aspx" aria-controls="home" role="tab" data-toggle="tab" class="selected">List </a></li>
                    <li role="presentation" class="active"><a href="javascript:void(0)" aria-controls="home" role="tab" data-toggle="tab">Send  </a></li>
                    <li role="presentation"><a href="Receive.aspx" aria-controls="home" role="tab" data-toggle="tab">Receive</a></li>

                </ul>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Send</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <fieldset>
                                                <legend>Send</legend>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Sending Country:<span class="errormsg">*</span>
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="country" runat="server" AutoPostBack="True" OnSelectedIndexChanged="country_SelectedIndexChanged" CssClass="form-control">
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator26" runat="server" ControlToValidate="country"
                                                            ForeColor="Red" ValidationGroup="Save" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Sending Agent:
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="agent" runat="server" CssClass="form-control">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                            </fieldset>
                                        </div>


                                        <div class="col-md-6">
                                            <fieldset>
                                                <legend>Search & Collection </legend>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Customer Registration  :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlCustomerReg" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                            <asp:ListItem Value="S" Text="Show"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="ddlCustomerReg"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True">
                                                        </asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        New Customer :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlNewCustomer" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                            <asp:ListItem Value="S" Text="Show"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="ddlNewCustomer"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Collection :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlCollection" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                            <asp:ListItem Value="S" Text="Show"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="ddlCollection"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                            </fieldset>
                                        </div>

                                    </div>


                                    <div class="row">

                                        <div class="col-md-6">
                                            <fieldset>
                                                <legend>Sender</legend>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        ID :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlId" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="ddlId"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        ID Issue Date :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlIdIssueDate" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="ddlIdIssueDate"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        ID Valid Date :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlIdValidDate" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="ddlIdValidDate"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        DOB :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlDob" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="ddlDob"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Address :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlAddress" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ControlToValidate="ddlAddress"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        City :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlCity" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator9" runat="server" ControlToValidate="ddlCity"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Contact:
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlContact" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator10" runat="server" ControlToValidate="ddlContact"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Occupation :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlOccupation" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator11" runat="server" ControlToValidate="ddlOccupation"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Company :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlCompany" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator12" runat="server" ControlToValidate="ddlCompany"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Salary Range :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlSalRange" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator13" runat="server" ControlToValidate="ddlSalRange"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Purpose Of Remittance :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlPurpose" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator14" runat="server" ControlToValidate="ddlPurpose"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Source Of Fund :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlSource" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator15" runat="server" ControlToValidate="ddlSource"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Native Country:
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="nativeCountry" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator22" runat="server" ControlToValidate="nativeCountry"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        TXN History:
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="tXNHistory" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator23" runat="server" ControlToValidate="tXNHistory"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>

                                                
                                            </fieldset>
                                        </div>
                                        <div class="col-md-6">
                                            <fieldset>
                                                <legend>Receiver</legend>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        ID:
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlRevId" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator16" runat="server" ControlToValidate="ddlRevId"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Place Of Issue:
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlPlace" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator17" runat="server" ControlToValidate="ddlPlace"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Id Valid Date:
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="rIdValidDate" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator25" runat="server" ControlToValidate="rIdValidDate"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        DOB :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="rDOB" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator24" runat="server" ControlToValidate="rDOB"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Address :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlRevAdd" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator18" runat="server" ControlToValidate="ddlRevAdd"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        City :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlRevCity" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator19" runat="server" ControlToValidate="ddlRevCity"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Contact :
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlRevContact" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator20" runat="server" ControlToValidate="ddlRevContact"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label" for="">
                                                        Relationship:
                                                    </label>
                                                    <div class="col-lg-9 col-md-9">
                                                        <asp:DropDownList ID="ddlRelationship" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator21" runat="server" ControlToValidate="ddlRelationship"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </div>
                                                </div>
                                            </fieldset>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="row">
                                                <div id="copyPanel" runat="server" visible="false">
                                                    <fieldset>
                                                        <legend>Copy To</legend>
                                                        <div class="form-group">
                                                            <label class="col-lg-3 col-md-3 control-label" for="">
                                                                Country : <span class="errormsg">*</span>
                                                            </label>
                                                            <div class="col-lg-9 col-md-9">
                                                                <asp:DropDownList ID="copyToCountry" runat="server" AutoPostBack="True"
                                                                    OnSelectedIndexChanged="copyToCountry_SelectedIndexChanged" CssClass="form-control">
                                                                </asp:DropDownList>
                                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator27" runat="server" ControlToValidate="copyToCountry"
                                                                    ForeColor="Red" ValidationGroup="copy" Display="Dynamic" ErrorMessage="Required!">
                                                                </asp:RequiredFieldValidator>
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label class="col-lg-3 col-md-3 control-label" for="">
                                                                Agent : 
                                                            </label>
                                                            <div class="col-lg-9 col-md-9">
                                                                <asp:DropDownList ID="copyToagent" runat="server" CssClass="form-control">
                                                                </asp:DropDownList>
                                                            </div>
                                                        </div>
                                                        <div class=" form-group">
                                                            <div class="col-md-9 col-md-offset-3">
                                                                <asp:Button runat="server" ID="copySetting" ValidationGroup="copy" Text="Copy" OnClick="copySetting_Click" CssClass="btn btn-primary m-t-25" />

                                                            </div>
                                                        </div>
                                                    </fieldset>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6">
                                        <div class="form-group">
                                                    <label class="col-lg-3 col-md-3 control-label"></label>
                                                    <div class="col-lg-3 col-md-3">
                                                        <asp:Button ID="btnSave" runat="server" CssClass="btn btn-primary m-t-25" Text="Save" ValidationGroup="Save" OnClick="btnSave_Click" />

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


<%--        <fieldset>
                                            <legend>Copy To</legend>
                                            <table>
                                                <tr>
                                                    <td class="frmLable" nowrap="nowrap">Country:
                                                    </td>
                                                    <td nowrap="nowrap">
                                                        <asp:DropDownList ID="copyToCountry" runat="server" AutoPostBack="True"
                                                            OnSelectedIndexChanged="copyToCountry_SelectedIndexChanged">
                                                        </asp:DropDownList>
                                                        <span class="errormsg">*</span>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator27" runat="server" ControlToValidate="copyToCountry"
                                                            ForeColor="Red" ValidationGroup="copy" Display="Dynamic" ErrorMessage="Required!">
                                                        </asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                                <tr>--%>
<%-- <td class="frmLable" nowrap="nowrap">Agent:
                                                    </td>
                                                    <td nowrap="nowrap">
                                                        <asp:DropDownList ID="copyToagent" runat="server">
                                                        </asp:DropDownList>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>&nbsp;
                                                    </td>


                                                    <td>--%>
<%--  <asp:Button runat="server" ID="copySetting" ValidationGroup="copy" Text="Copy" OnClick="copySetting_Click" CssClass="btn btn-primary m-t-25" />--%>
<%-- </td>
                                                </tr>
                                            </table>
                                        </fieldset>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-md-6 col-md-offset-2">
                                            <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="Save" OnClick="btnSave_Click"  CssClass="btn btn-primary m-t-25" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>--%>
<%--  <div style="padding: 110px 0">
            <div class="breadCrumb">
                Field Setting » Send
            </div>
            <div>
                <table style="width: 100%">
                    <tr>
                        <td height="20" class="welcome">
                            <span id="spnCname" runat="server"></span>
                        </td>
                    </tr>
                    <tr>
                        <td height="10">
                            <div class="tabs">
                                <ul>
                                    <li><a href="List.aspx">List </a></li>
                                    <li><a href="#" class="selected">Send </a></li>
                                    <li><a href="Receive.aspx">Receive </a></li>
                                </ul>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
            <div>--%>
<%-- <table class="formTable" width="600px">
                <tr>
                    <td colspan="4" class="frmTitle">
                        Send
                    </td>
                </tr>
                <tr>
                    <td>
                        <table>
                            <tr>
                                <td>
                                    <table style="width: 300px; margin-left: 15px">
                                        <tr>
                                            <td class="frmLable" nowrap="nowrap">
                                                Sending Country:
                                            </td>
                                            <td nowrap="nowrap">--%>


<%-- <uc1:SwiftTextBox ID="sendingCountry" runat="server" category = "countrySend"/> --%>
<%--     <asp:DropDownList ID="country" runat="server" AutoPostBack="True" OnSelectedIndexChanged="country_SelectedIndexChanged">
                                                </asp:DropDownList>
                                                <span class="errormsg">*</span>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator26" runat="server" ControlToValidate="country"
                                                    ForeColor="Red" ValidationGroup="Save" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                            </td>
                                        </tr>
                                        <tr>--%>
<%--  <td class="frmLable" nowrap="nowrap">Sending Agent:
                </td>
                <td nowrap="nowrap">
                    <%--<uc1:SwiftTextBox ID="sendingAgent" runat="server" Category="s-r-agent" Param1="@GetCountryId()" />--%>
<%-- <asp:DropDownList ID="agent" runat="server">
                    </asp:DropDownList>
                </td>
                </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>--%>
<%--<fieldset>
                                        <legend>Search & Collection </legend>
                                        <table>
                                            <tr>
                                                <td class="frmLable">Customer Registration:
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlCustomerReg" runat="server" Width="160px">
                                                        <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                        <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        <asp:ListItem Value="S" Text="Show"></asp:ListItem>
                                                    </asp:DropDownList>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="ddlCustomerReg"
                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                            <tr>--%>

<%--   <td class="frmLable">New Customer:
                </td>
                <td>
                    <asp:DropDownList ID="ddlNewCustomer" runat="server" Width="160px">
                        <asp:ListItem Value="" Text="Select"></asp:ListItem>
                        <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                        <asp:ListItem Value="S" Text="Show"></asp:ListItem>
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="ddlNewCustomer"
                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                </td>
                </tr>
--%>
<%-- <tr>
                                                <td class="frmLable">Collection:
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlCollection" runat="server" Width="160px">
                                                        <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                        <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        <asp:ListItem Value="S" Text="Show"></asp:ListItem>
                                                    </asp:DropDownList>
                                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="ddlCollection"
                                                        Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                        SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                </table>
                                    </fieldset>
                </td>
                            </tr>
                <tr>
                    <td>
                        <div>
                            <table>
                                <tr>
                                    <td>--%>
<%-- <fieldset>
                    <legend>Sender</legend>
                    <table style="margin-left: 5px">
                        <tr>
                            <td class="frmLable">ID:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlId" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator4" runat="server" ControlToValidate="ddlId"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%-- <td class="frmLable">ID Issue Date:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlIdIssueDate" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator5" runat="server" ControlToValidate="ddlIdIssueDate"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%--          <td class="frmLable">ID Valid Date:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlIdValidDate" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator6" runat="server" ControlToValidate="ddlIdValidDate"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%--  <td class="frmLable">DOB:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlDob" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="ddlDob"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%--        <td class="frmLable">Address:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlAddress" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ControlToValidate="ddlAddress"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%--   <td class="frmLable">City:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlCity" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator9" runat="server" ControlToValidate="ddlCity"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%--      <td class="frmLable">Contact:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlContact" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator10" runat="server" ControlToValidate="ddlContact"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%-- <td class="frmLable">Occupation:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlOccupation" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator11" runat="server" ControlToValidate="ddlOccupation"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%-- <td class="frmLable">Company:
                            </td>
                            <td>--%>
<%-- <asp:DropDownList ID="ddlCompany" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator12" runat="server" ControlToValidate="ddlCompany"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>--%>
<%-- </td>
                        </tr>
                        <tr>
                            <td class="frmLable">Salary Range:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlSalRange" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator13" runat="server" ControlToValidate="ddlSalRange"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%-- <td class="frmLable" nowrap="nowrap">Purpose Of Remittance:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlPurpose" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator14" runat="server" ControlToValidate="ddlPurpose"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%--        <td class="frmLable">Source Of Fund:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlSource" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator15" runat="server" ControlToValidate="ddlSource"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%--     <td class="frmLable">Native Country:
                            </td>
                            <td>
                                <asp:DropDownList ID="nativeCountry" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator22" runat="server" ControlToValidate="nativeCountry"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                        <tr>--%>
<%--  <td class="frmLable">TXN History:
                            </td>
                            <td>
                                <asp:DropDownList ID="tXNHistory" runat="server" Width="160px">
                                    <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator23" runat="server" ControlToValidate="tXNHistory"
                                    Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                    SetFocusOnError="True"></asp:RequiredFieldValidator>
                            </td>
                        </tr>
                    </table>
                </fieldset>
                </td>
                                    <td style="vertical-align: top">--%>
<%--     <fieldset>
                                            <legend>Receiver</legend>
                                            <table>
                                                <tr>
                                                    <td class="frmLable">ID:
                                                    </td>
                                                    <td>
                                                        <asp:DropDownList ID="ddlRevId" runat="server" Width="160px">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator16" runat="server" ControlToValidate="ddlRevId"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                                <tr>--%>
<%-- <td class="frmLable" nowrap="nowrap">Place Of Issue:
                                                    </td>
                                                    <td>
                                                        <asp:DropDownList ID="ddlPlace" runat="server" Width="160px">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator17" runat="server" ControlToValidate="ddlPlace"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                                <tr>--%>
<%--   <td class="frmLable">Id Valid Date:
                                                    </td>
                                                    <td>
                                                        <asp:DropDownList ID="rIdValidDate" runat="server" Width="160px">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator25" runat="server" ControlToValidate="rIdValidDate"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                                <tr>--%>
<%--     <td class="frmLable">DOB:
                                                    </td>
                                                    <td>
                                                        <asp:DropDownList ID="rDOB" runat="server" Width="160px">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator24" runat="server" ControlToValidate="rDOB"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                                <tr>--%>
<%-- <td class="frmLable">Address:
                                                    </td>
                                                    <td>
                                                        <asp:DropDownList ID="ddlRevAdd" runat="server" Width="160px">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator18" runat="server" ControlToValidate="ddlRevAdd"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                                <tr>--%>
<%--  <td class="frmLable">City:
                                                    </td>
                                                    <td>
                                                        <asp:DropDownList ID="ddlRevCity" runat="server" Width="160px">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator19" runat="server" ControlToValidate="ddlRevCity"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                                <tr>--%>
<%--     <td class="frmLable">Contact:
                                                    </td>
                                                    <td>
                                                        <asp:DropDownList ID="ddlRevContact" runat="server" Width="160px">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator20" runat="server" ControlToValidate="ddlRevContact"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                                <tr>--%>
<%-- <td class="frmLable">Relationship:
                                                    </td>
                                                    <td>
                                                        <asp:DropDownList ID="ddlRelationship" runat="server" Width="160px">
                                                            <asp:ListItem Value="" Text="Select"></asp:ListItem>
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                        <asp:RequiredFieldValidator ID="RequiredFieldValidator21" runat="server" ControlToValidate="ddlRelationship"
                                                            Display="Dynamic" ErrorMessage="Required!" ValidationGroup="Save" ForeColor="Red"
                                                            SetFocusOnError="True"></asp:RequiredFieldValidator>
                                                    </td>
                                                </tr>
                                            </table>
                                        </fieldset>  --%>
<%-- <div id="copyPanel" runat="server" visible="false">
                                            <fieldset>
                                                <legend>Copy To</legend>
                                                <table>
                                                    <tr>
                                                        <td class="frmLable" nowrap="nowrap">Country:
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <asp:DropDownList ID="copyToCountry" runat="server" AutoPostBack="True"
                                                                OnSelectedIndexChanged="copyToCountry_SelectedIndexChanged">
                                                            </asp:DropDownList>
                                                            <span class="errormsg">*</span>
                                                            <asp:RequiredFieldValidator ID="RequiredFieldValidator27" runat="server" ControlToValidate="copyToCountry"
                                                                ForeColor="Red" ValidationGroup="copy" Display="Dynamic" ErrorMessage="Required!">
                                                            </asp:RequiredFieldValidator>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="frmLable" nowrap="nowrap">Agent:
                                                        </td>
                                                        <td nowrap="nowrap">
                                                            <asp:DropDownList ID="copyToagent" runat="server">
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;
                                                        </td>


                                                        <td>
                                                            <asp:Button runat="server" ID="copySetting" ValidationGroup="copy" Text="Copy" OnClick="copySetting_Click" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </div>--%>
<%--                    </td>
                </tr>
                            </table>
            </div>
            </td>
                </tr>
                </table>
         </td>
                </tr>
        <tr>
            <td>
                <asp:Button ID="btnSave" runat="server" Text="Save" ValidationGroup="Save" OnClick="btnSave_Click" />
            </td>
        </tr>
            </table>
          
        </div>
        </div>--%>
 