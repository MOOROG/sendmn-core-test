<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BlacklistedAccountsAdd.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.BlacklistedAccountsAdd" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta charset="utf-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="description" content="" />
  <meta name="author" content="" />
  <link href="/ui/css/style.css" rel="stylesheet" />
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script src="/ui/js/jquery.min.js"></script>
  <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
  <script src="/js/Swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js" type="text/javascript"></script>
  <script src="/ui/js/jquery-ui.min.js"></script>
  <script src="/js/swift_autocomplete.js"></script>
  <script src="/js/swift_calendar.js"></script>
  <script src="/ui/js/pickers-init.js"></script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script type="text/javascript">
		$(document).ready(function () {
			$('.collMode-chk').click(function () {
				$('.collMode-chk').not(this).propAttr('checked', false);
			});
		});
  </script>
</head>
<body>
  <form id="form1" runat="server" class="col-md-12" enctype="multipart/form-data">
    <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="up" runat="server">
      <ContentTemplate>
        <div class="page-wrapper">
          <div class="row">
            <div class="col-sm-12">
              <div class="page-title">
                <ol class="breadcrumb">
                  <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                  <li><a onclick="return LoadModule('adminstration')">Administration</a></li>
                  <li><a href="BlacklistedAccountsAdd.aspx">Branch Customer</a></li>
                  <li class="active"><a href="#">Manage Branch Customer</a></li>
                </ol>
              </div>
            </div>
          </div>
          <input type="hidden" id="hidCusid" runat="server" />
          <div class="row">
            <div class="col-md-12">
              <div class="panel panel-default recent-activites">
                <div class="panel-heading">
                  <h4 class="panel-title">Manage blacklist</h4>
                </div>
                <div class="panel-body">
                  <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                    <%--<Triggers>
                      <asp:PostBackTrigger ControlID="btnRegister" />
                    </Triggers>--%>
                    <ContentTemplate>
                      <div class="row">
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="lastname">
                            Данс:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="account_number" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="firstname">
                            Банк:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="bankname" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="regNum">
                            Дүн:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="amount" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="mobileNum">
                            Хүлээн авагч:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="receiverName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="email">
                            Дугаар:
                          </label>
                          <asp:TextBox ID="receiverPhone" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="email">
                            Тайлбар:
                          </label>
                          <asp:TextBox ID="description" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="addressDistrict">
                            Илгээгч:
                          </label>
                          <asp:TextBox ID="senderName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="address">
                            Дугаар:
                          </label>
                          <asp:TextBox ID="senderPhone" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="dateofbirth">
                            Хаалт огноо:
                          </label>
                          <asp:TextBox ID="close_date" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>

                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="address">
                            Банк:
                          </label>
                          <asp:TextBox ID="senderBankName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="address">
                            Данс:
                          </label>
                          <asp:TextBox ID="senderAccountNumber" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="address">
                            Агент:
                          </label>
                          <asp:TextBox ID="tnxAgentName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="address">
                            Өдөр:
                          </label>
                          <asp:TextBox ID="tnxDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="address">
                            Үлдсэн дүн:
                          </label>
                          <asp:TextBox ID="remainingAmount" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="address">
                            Тайлбар:
                          </label>
                          <asp:TextBox ID="remainingComment" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="address">
                            Гүйл/дугаар:
                          </label>
                          <asp:TextBox ID="tnxControlNo" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                      </div>
                    </ContentTemplate>
                  </asp:UpdatePanel>
                  <div class="row">
                    <div class="col-lg-12 form-group">
                      <asp:Button ID="btnRegister" runat="server" Text="Submit" CssClass="btn btn-primary m-t-25" OnClick="btnRegister_Click"/>
                    </div>
                    <%--<triggers>
                      <asp:PostBackTrigger ControlID="btnRegister" />
                    </triggers>--%>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        </div>
      </ContentTemplate>
    </asp:UpdatePanel>
  </form>
</body>
</html>

