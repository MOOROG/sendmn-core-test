<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.Transaction.PromotionalCampaign.Manage" %>

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
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.mask/1.14.15/jquery.mask.min.js" type="text/javascript"></script>

    <script type="text/javascript">
        $(document).ready(function () {
			//CalTillToday("#grid_list_fromDate");
			//CalTillToday("#grid_list_toDate");
			ShowCalFromToUpToToday("#startDate", "#endDate");
			$('#startDate').mask('0000-00-00');
			$('#endDate').mask('0000-00-00');
        });

        function CheckFormValidation() {
            var reqField = "countryDDL,ddlPromotionType,promotionCode,promotionMsg,startDate,endDate,promotionAmount,";
            if (ValidRequiredField(reqField) == false) {
                return false;
            }

        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#">Promotional Campaign</a></li>
                            <li class="active"><a href="#">Setup Promotional Campaign</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="panel panel-default recent-activites">
                <!-- Start .panel -->
                <div class="panel-heading">
                    <h4 class="panel-title">Setup Promotional Campaign
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
                                                Country:</label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:DropDownList ID="countryDDL" runat="server" CssClass="form-control" OnSelectedIndexChanged="countryDDL_SelectedIndexChanged" AutoPostBack="true">
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Payout Method:</label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:DropDownList ID="payoutMethodDDL" runat="server" CssClass="form-control">
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
                                                Promotion Type:</label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:DropDownList ID="ddlPromotionType" runat="server" CssClass="form-control"></asp:DropDownList>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Promotion Code:</label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:TextBox ID="promotionCode" runat="server" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Promotion Message:</label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:TextBox runat="server" ID="promotionMsg" class="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Promotion Amount:</label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:TextBox runat="server" ID="promotionAmount" class="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                Start Date:</label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:TextBox runat="server" ID="startDate" class="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label class="col-lg-4 col-md-8 control-label" for="">
                                            <label>
                                                End Date:</label>
                                        </label>
                                        <div class="col-lg-8 col-md-4">
                                            <asp:TextBox runat="server" ID="endDate" class="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
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
