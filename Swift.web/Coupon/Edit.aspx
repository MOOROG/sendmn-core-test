<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Edit.aspx.cs" Inherits="Swift.web.Coupon.Edit" %>

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
    function StartCalendars() {
      ShowCalDefault("#<% =startDate.ClientID%>");
    }
    function EndCalendars() {
      ShowCalDefault("#<% =endDate.ClientID%>");
    }
    $('#startDate').click(function () {
      StartCalendars();
    })
    $('#endDate').click(function () {
      EndCalendars();
    })
    StartCalendars();
    EndCalendars();
    function amountKeyup(id) {
      let val = $("#" + id).val();
      if (val != "") {
        val = val.replace(/,/g, '');
        val = val.replace(/[^0-9]/g, '');
        val = String(val).replace(/(.)(?=(\d{3})+$)/g, '$1,');
        $("#" + id).val(val);
      }
    }
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
                  <li><a href="List.aspx">Coupon List</a></li>
                  <li class="active"><a href="#">Add/Edit</a></li>
                </ol>
              </div>
            </div>
          </div>
          <div class="row">
            <div class="col-md-12">
              <div class="panel panel-default recent-activites">
                <div class="panel-heading">
                  <h4 class="panel-title">Coupon</h4>
                </div>
                <div class="panel-body">
                  <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                    <Triggers>
                      <asp:PostBackTrigger ControlID="btnRegister" />
                    </Triggers>
                    <ContentTemplate>
                      <div class="row">
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="functionId">
                            Coupon Code:
                          </label>
                          <asp:TextBox ID="couponCode" runat="server" CssClass="form-control" disabled="disabled"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="menuGroup">
                            Coupon Name:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="couponName" runat="server" CssClass="form-control"></asp:TextBox>
                          <asp:RequiredFieldValidator runat="server" ControlToValidate="couponName" ErrorMessage="Нэрээ оруулна уу!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="couponPrice">
                            Coupon Price:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="couponPrice" onkeyup="amountKeyup('couponPrice');" runat="server" CssClass="form-control"></asp:TextBox>
                          <asp:RequiredFieldValidator runat="server" ControlToValidate="couponPrice" ErrorMessage="Үнээ оруулна уу!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="couponQuant">
                            Coupon Quantity:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="couponQuant" onkeyup="amountKeyup('couponQuant');" runat="server" CssClass="form-control"></asp:TextBox>
                          <asp:RequiredFieldValidator runat="server" ControlToValidate="couponQuant" ErrorMessage="Тоо ширхэгээ оруулна уу!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                      </div>
                      <div class="row">
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="module">
                            Partner:
                          </label>
                          <asp:DropDownList ID="partner" runat="server" CssClass="form-control">
                          </asp:DropDownList>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="agentGroup">
                            Start Date:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="startDate" onchange="return DateValidation('startDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                          <asp:RequiredFieldValidator runat="server" ControlToValidate="startDate" ErrorMessage="Эхлэх огноо оруулна уу!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="agentGroup">
                            End Date:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="endDate" onchange="return DateValidation('startDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                          <asp:RequiredFieldValidator runat="server" ControlToValidate="endDate" ErrorMessage="Дуусах огноогоо оруулна уу!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="link">
                            Description:
                          </label>
                          <asp:TextBox ID="description" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                      </div>
                      <div class="row">
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="module">
                            Discount Type:<span style="color: red;">*</span>
                          </label>
                          <asp:DropDownList ID="discountType" runat="server" CssClass="form-control">
                            <asp:ListItem Value="Percent" Selected="true">Percent</asp:ListItem>
                            <asp:ListItem Value="Amount">Amount</asp:ListItem>
                          </asp:DropDownList>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="agentGroup">
                            Discount Amount:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="discountAmount" onkeyup="amountKeyup('discountAmount');" runat="server" CssClass="form-control"></asp:TextBox>
                          <asp:RequiredFieldValidator runat="server" ControlToValidate="discountAmount" ErrorMessage="Хөнгөлөлтийн дүнгээ оруулна уу!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="module">
                            Discount Currency:<span style="color: red;">*</span>
                          </label>
                          <asp:DropDownList ID="discountCurrency" runat="server" CssClass="form-control">
                            <asp:ListItem Value="MNT" Selected="true">MNT</asp:ListItem>
                          </asp:DropDownList>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <asp:TextBox ID="photoHide" runat="server" CssClass="form-control hidden"></asp:TextBox>
                          <label class="control-label" for="photo1">
                            Coupon Image:
                          </label>
                          <asp:FileUpload ID="photo1" runat="server" CssClass="form-control" accept="image/*" />
                          <%= photoPreview %>
                        </div>
                      </div>
                    </ContentTemplate>
                  </asp:UpdatePanel>
                  <div class="row">
                    <div class="col-lg-12 form-group">
                      <asp:Button ID="btnRegister" runat="server" Text="Register Menu" CssClass="btn btn-primary m-t-25" OnClick="btnRegister_Click" />
                    </div>
                    <triggers>
                      <asp:PostBackTrigger ControlID="btnRegister" />
                    </triggers>
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
