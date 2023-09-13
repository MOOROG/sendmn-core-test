<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FieldSetup.aspx.cs" Inherits="Swift.web.SwiftSystem.ReceivePageFieldSetup.FieldSetup" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title></title>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <script src="../../ui/js/jquery.min.js" type="text/javascript"></script>
    <%--<script src="../../js/jQuery/jquery-1.4.1.min.js"></script>--%>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
</head>

<body>
    <form id="form1" runat="server">
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('adminstration')">Administration </a></li>
                            <li><a href="#" onclick="return LoadModule('applicationsetting')">Applications Settings </a></li>
                            <li class="active"><a href="FieldSetup.aspx">Receiver Page Field Setup</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default ">
                                <div class="panel-heading">
                                    <h4 class="panel-title">Field Setup</h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="row">
                                        <div class="form-group">
                                            <label class="col-lg-2 col-md-2 control-label" for="" id="lblCountry">
                                                Receiving Country:<span class="errormsg">*</span>
                                            </label>
                                            <div class="col-lg-4 col-md-4">
                                                <asp:DropDownList ID="country" runat="server" AutoPostBack="True" OnSelectedIndexChanged="country_SelectedIndexChanged" CssClass="form-control">
                                                </asp:DropDownList>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator26" runat="server" ControlToValidate="country" ForeColor="Red" ValidationGroup="Save" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                            </div>

                                            <label class="col-lg-2 col-md-2 control-label" for="" id="lblService">
                                                Service Type:<span class="errormsg">*</span>
                                            </label>
                                            <div class="col-lg-4 col-md-4">
                                                <asp:DropDownList ID="ddlServiceType" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ServiceType_SelectedIndexChanged" CssClass="form-control">
                                                </asp:DropDownList>
                                                <asp:RequiredFieldValidator ID="RequiredFieldValidator41" runat="server" ControlToValidate="ddlServiceType" ForeColor="Red" ValidationGroup="Save" Display="Dynamic" ErrorMessage="Required!">
                                                </asp:RequiredFieldValidator>
                                            </div>
                                        </div>
                                    </div>
                                    <div id="PageFieldSetup" runat="server" visible="true">

                                        <fieldset>

                                            <legend>Receiver Page Field Setting</legend>
                                            <div class="row">
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">Field </label>
                                                    <label class="col-lg-4 col-md-4 control-label" for="">Required </label>
                                                    <label class="col-lg-2 col-md-2 control-label" for="">Minimum Length </label>
                                                    <label class="col-lg-2 col-md-2 control-label" for="">Maximum Length </label>
                                                    <label class="col-lg-2 col-md-2 control-label" for="">KeyWord </label>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        Local Name:
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlLocalName" runat="server" CssClass="form-control" AutoPostBack="True" OnSelectedIndexChanged="Local_SelectedIndexChanged">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinLocalName" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxLocalName" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddlLocalNameKeyword" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>

                                                <div class="form-group" runat="server" id="LocalFirstName">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        First Name in Local:
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlFirstNameInlocal" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinLocalFirstName" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxLocalFirstName" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddlLocalFirstNameKeyword" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group" runat="server" id="LocalMiddleName">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        Midddle Name in Local:
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddMiddleNameInlocal" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinMiddleNameInlocal" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxMiddleNameInlocal" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddlLocalMiddleNameKeyword" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>

                                                <div class="form-group" runat="server" id="LocalLastName">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        Last Name in Local:
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlLastNameINLocal" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinLastNameINLocal" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxLastNameINLocal" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddlLastNameINLocalKeyword" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        Full Name :
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlFullName" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinFullName" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxFullName" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddlFullnameKeyword" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>

                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="" id="lblFirstName">
                                                        First Name:
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlFirstName" runat="server" CssClass="form-control">

                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinfistName" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxFirstName" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddLFirstNameKeyWord" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="" id="lblMiddleName">
                                                        Middle Name:
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="dllMiddleName" runat="server" CssClass="form-control">

                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinMiddleName" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxMiddleName" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddlMiddleNameKeyword" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="" id="lblLastName">
                                                        Last Name:
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlLastName" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinlastName" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxlastName" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddlLatNameKeyWord" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="" id="lblNativeCountry">
                                                        Native Country :
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlNativeCountry" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="" id="lblProvince">
                                                        Province :
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlProvince" runat="server" CssClass="form-control">

                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="" id="lblstate">
                                                        District :
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlState" runat="server" CssClass="form-control">

                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="" id="lblAddress">
                                                        Address :
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlAddress" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinAdress" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxAdress" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddlAddressKeyword" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="" id="lblCity">
                                                        City :
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlCity" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinCity" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxCity" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddlCityKeyword" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="" id="lblTdType">
                                                        Id Type:
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlIdType" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <%-- <asp:TextBox runat="server" ID="txtMinddlIdType" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>--%>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <%--   <asp:TextBox runat="server" ID="txtMaxnddlIdType" Text="50" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>--%>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <%-- <asp:DropDownList ID="ddlIdTypeKeyWord" runat="server" CssClass="form-control">
                                                      <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                    </asp:DropDownList>--%>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        Id Number:
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlIdNumber" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinIdnumber" Text="30" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxIdnumber" Text="30" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddlIdnumberKeyWord" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        Mobile Number:
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlMobile" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinMobile" Text="15" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxMobile" Text="15" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddlMobileKeyWord" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        Realation Group :
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlRealation" runat="server" CssClass="form-control">

                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        Transfer Reason:
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlTransferReason" runat="server" CssClass="form-control">

                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        Bank Name :
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlBank" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        Branch Name :
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlBranch" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                    </div>
                                                </div>

                                                <div class="form-group">
                                                    <label class="col-lg-2 col-md-2 control-label" for="">
                                                        Account No :
                                                    </label>
                                                    <div class="col-lg-4 col-md-4">
                                                        <asp:DropDownList ID="ddlAccount" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                            <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                            <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMinAccount" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:TextBox runat="server" ID="txtMaxAccount" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                    </div>
                                                    <div class="col-lg-2 col-md-2">
                                                        <asp:DropDownList ID="ddlAccountKeyWord" runat="server" CssClass="form-control">
                                                            <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                            <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                            <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>

                                              <%-- additional fields --%>
                                              <div class="form-group">
                                                <label class="col-lg-2 col-md-2 control-label" for="">
                                                  Bank Account Type :
                                                </label>
                                                <div class="col-lg-4 col-md-4">
                                                  <asp:DropDownList ID="ddlBankAccountType" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                  </asp:DropDownList>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                </div>
                                              </div>
                                              <div class="form-group">
                                                <label class="col-lg-2 col-md-2 control-label" for="">
                                                  Bic SWIFT Code :
                                                </label>
                                                <div class="col-lg-4 col-md-4">
                                                  <asp:DropDownList ID="ddlBicSwift" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                  </asp:DropDownList>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                  <asp:TextBox runat="server" ID="bicSwiftMin" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                  <asp:TextBox runat="server" ID="bicSwiftMax" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                  <asp:DropDownList ID="ddlBicSwiftKeyword" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                    <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                    <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                    <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                  </asp:DropDownList>
                                                </div>
                                              </div>
                                              <div class="form-group">
                                                <label class="col-lg-2 col-md-2 control-label" for="">
                                                  Bank Routing Code :
                                                </label>
                                                <div class="col-lg-4 col-md-4">
                                                  <asp:DropDownList ID="ddlBankRoutingCode" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                  </asp:DropDownList>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                  <asp:TextBox runat="server" ID="bankRoutingCodeMin" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                  <asp:TextBox runat="server" ID="bankRoutingCodeMax" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                  <asp:DropDownList ID="ddlBankRoutingCodeKeyword" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                    <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                    <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                    <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                  </asp:DropDownList>
                                                </div>
                                              </div>
                                              <div class="form-group">
                                                <label class="col-lg-2 col-md-2 control-label" for="">
                                                  Beneficiary Zipcode :
                                                </label>
                                                <div class="col-lg-4 col-md-4">
                                                  <asp:DropDownList ID="ddlBeneZipCode" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                  </asp:DropDownList>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                  <asp:TextBox runat="server" ID="beneZipCodeMin" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                  <asp:TextBox runat="server" ID="beneZipCodeMax" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                  <asp:DropDownList ID="ddlBeneZipCodeKeyword" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                    <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                    <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                    <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                  </asp:DropDownList>
                                                </div>
                                              </div>
                                              <div class="form-group" id="isOrgDIV" runat="server">
                                                <label class="col-lg-2 col-md-2 control-label" for="">
                                                  Individual or Organization:
                                                </label>
                                                <div class="col-lg-4 col-md-4">
                                                  <asp:DropDownList ID="isOrgOrIndi" runat="server" CssClass="form-control">

                                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                  </asp:DropDownList>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                </div>
                                              </div>
                                              <div class="form-group">
                                                <label class="col-lg-2 col-md-2 control-label" for="">
                                                  Invoice Image :
                                                </label>
                                                <div class="col-lg-4 col-md-4">
                                                  <asp:DropDownList ID="invoiceImageDDL" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="M" Text="Mandatory"></asp:ListItem>
                                                    <asp:ListItem Value="O" Text="Optional"></asp:ListItem>
                                                    <asp:ListItem Value="H" Text="Hide"></asp:ListItem>
                                                  </asp:DropDownList>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                  <asp:TextBox runat="server" ID="invoiceMin" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                  <asp:TextBox runat="server" ID="invoiceMax" Text="100" MaxLength="3" onkeypress="javascript:return isNumber(event)"> </asp:TextBox>
                                                </div>
                                                <div class="col-lg-2 col-md-2">
                                                  <asp:DropDownList ID="invoiceTypeDDL" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="A" Text="Alpha"></asp:ListItem>
                                                    <asp:ListItem Value="N" Text="Numeric"></asp:ListItem>
                                                    <asp:ListItem Value="AN" Text="Alpha Numeric"></asp:ListItem>
                                                    <asp:ListItem Value="ANS" Text="Alpha Numeric Special"></asp:ListItem>
                                                  </asp:DropDownList>
                                                </div>
                                              </div>
                                              <%-- additional fields --%>

                                            </div>
                                            <div class="row">
                                                <div class="form-group">
                                                    <div class="col-md-3 col-md-offset-4">
                                                        <asp:Button ID="btnSave" Text="Update" runat="server" ValidationGroup="Save" OnClick="btnSave_Click" CssClass="btn btn-primary m-t-25" OnClientClick="comparevalue();" />
                                                        <asp:Button ID="btnDelete" Text="Delete" runat="server" ValidationGroup="Save" OnClick="btnDelete_Click" CssClass="btn btn-primary m-t-25" OnClientClick="if (!UserDeleteConfirmation()) return false;" />
                                                    </div>
                                                </div>
                                            </div>
                                        </fieldset>
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
<script type="text/javascript">
    // WRITE THE VALIDATION SCRIPT.
    function isNumber(evt) {
        var iKeyCode = (evt.which) ? evt.which : evt.keyCode
        if (iKeyCode != 46 && iKeyCode > 31 && (iKeyCode < 48 || iKeyCode > 57))
            return false;
        return true;
    }

    // to compare minimum and maximum value value
    function comparevalue() {
        var i;
        var vaild = 1;
        var maxlist = ['#txtMaxLocalFirstName', '#txtMaxMiddleNameInlocal', '#txtMaxLastNameINLocal', '#txtMaxFullName', '#txtMaxFirstName', '#txtMaxMiddleName', '#txtMaxlastName', '#txtMaxAdress', '#txtMaxCity', '#txtMaxIdnumber', '#txtMaxMobile', '#txtMaxAccount'];

        var minlist = ['#txtMinLocalFirstName', '#txtMinMiddleNameInlocal', '#txtMinLastNameINLocal', '#txtMinFullName', '#txtMinfistName', '#txtMinMiddleName', '#txtMinlastName', '#txtMinAdress', '#txtMinCity', '#txtMinIdnumber', '#txtMinMobile', '#txtMinAccount'];

        for (i = 0; i < minlist.length; i++) {
            if (parseInt($(minlist[i]).val()) > parseInt($(maxlist[i]).val())) {

                $(minlist[i]).css("background-color", "#FFCCD2");
                $(maxlist[i]).css("background-color", "#FFCCD2");
                vaild = 0;
            } else {
                $(minlist[i]).css("background-color", "#FFF");
                $(maxlist[i]).css("background-color", "#FFF");
            }
        }
        if (vaild == 0) {
            alert('Minimum filed lenghth is grather maxmim filed length')
            event.preventDefault();
            return;

        }
    }
    // delete conformation
    function UserDeleteConfirmation() {
        if (confirm("Are you sure you want to delete this record?"))
            return true;
        else
            return false;
    }
</script>
</html>