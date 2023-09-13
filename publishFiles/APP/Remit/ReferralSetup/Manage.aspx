<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.ReferralSetup.Manage" %>

<!DOCTYPE html>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <base id="Base1" target="_self" runat="server" />
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js" type="text/javascript"> </script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="/js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="/js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        function CheckFormValidation() {
            var reqField = "referralName,ddlReferraltype,ddlBranchList,cashHoldLimit,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }

        }
    </script>
</head>
<body>
    <form id="form1" runat="server" class="col-md-12">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Adminstration</a></li>
                            <li class="active"><a href="#">Referral List</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <!-- end .page title-->
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="List.aspx">Referral List</a></li>
                    <li class="active"><a href="Manage.aspx">Referral Setup </a></li>
                </ul>
            </div>
            <div class="panel panel-default recent-activites">
                <!-- Start .panel -->
                <div class="panel-heading">
                    <h4 class="panel-title">Referral List
                    </h4>
                    <div class="panel-actions">
                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                    </div>
                </div>
                <div class="panel-body">
                    <!-- End .form-group  -->
                    <asp:UpdatePanel ID="UpdatePanel1"
                        runat="server">
                        <ContentTemplate>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Referral Name : <span class="errormsg">*</span></label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:TextBox runat="server" ID="referralName" class="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Referral Mobile :</label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:TextBox runat="server" ID="referralMobile" class="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Referral Address</label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:TextBox runat="server" ID="referralAddress" class="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Is Active:</label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:DropDownList ID="isActiveDDL" runat="server" CssClass="form-control">
                                                <asp:ListItem Text="Yes" Value="1"></asp:ListItem>
                                                <asp:ListItem Text="No" Value="0"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">

                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Referral Email</label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:TextBox runat="server" ID="referralEmail" class="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Branch Id <span class="errormsg">*</span></label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:DropDownList runat="server" ID="ddlBranchList" class="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Referral Type:<span class="errormsg">*</span></label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:DropDownList ID="ddlReferraltype" runat="server" CssClass="form-control">
                                                <asp:ListItem Text="Select" Value=""></asp:ListItem>
                                                <asp:ListItem Text="JME Referral Branches" Value="RB"></asp:ListItem>
                                                <asp:ListItem Text="Referral'S with no comm" Value="RC"></asp:ListItem>
                                                <asp:ListItem Text="Regular Referral Agent's" Value="RR"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Cash Hold Limit:<span class="errormsg">*</span></label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:TextBox runat="server" ID="cashHoldLimit" class="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Rule Type:<span class="errormsg">*</span></label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:DropDownList runat="server" ID="ddlruleType" name="ruleType" CssClass="form-control">
                                                <asp:ListItem Text="Hold" Value="H"></asp:ListItem>
                                                <asp:ListItem Text="Block" Value="B"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6" style="display:none;">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Deduct Tax On Service Charge:<span class="errormsg">*</span></label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:DropDownList runat="server" ID="deductTaxOnSc" name="ruleType" CssClass="form-control">
                                                <asp:ListItem Text="Yes" Value="1"></asp:ListItem>
                                                <asp:ListItem Text="No" Value="0"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <div class="row">
                        <div class="col-md-12">
                            <!-- End .form-group  -->
                            <div class="form-group">
                                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary m-t-25" OnClientClick="return CheckFormValidation();" OnClick="btnSave_Click" />
                            </div>
                            <!-- End .form-group  -->
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
