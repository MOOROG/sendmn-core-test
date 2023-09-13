<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CashPaymentCode.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.NewCashPaymentCode" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta charset="utf-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="description" content="" />
  <meta name="author" content="" />
  <!--new css and js -->
  <%--    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <script type="text/javascript" src="../../../ui/js/jquery.min.js"></script>
    <script type="text/javascript" src="../../../ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/ui/js/bootstrap-datepicker.js"></script>
    <script src="/ui/js/pickers-init.js"></script>
    <script src="/js/functions.js" type="text/javascript"> </script>
	<script src="/js/swift_calendar.js"></script>--%>

  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <link href="/ui/css/style.css" rel="stylesheet" />
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

      $('#search').click(function () {
        customer();
      });
    });
    function CallBack(mes) {
      var resultList = ParseMessageToArray(mes);
      alert(resultList[1]);

      if (resultList[0] != 0) {
        return;
      }

      window.returnValue = resultList[0];
      $('.clr').val('');
    }

    function customer() {
      var options = {
        type: "POST",
        url: '../../../Autocomplete.asmx/GetCustomer',
        data: '{ register: "' + $('#regNum').val() + '"}',
        async: false,
        cache: false,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: function (response) {
          if (response.d != null) {
            var data = response.d;
            data = $.parseJSON(data);
            if (data.register != null) {
              $('#firstname').val(data.firstName);
              $('#lastname').val(data.lastName);
              $('#mobileNum').val(data.phones);
              $('#address').val(data.aimag + ' ' + data.sum + ' ' + data.address);
              $('#firstname').attr('disabled', 'disabled');
              $('#lastname').attr('disabled', 'disabled');
              $('#mobileNum').attr('disabled', 'disabled');
              $('#address').attr('disabled', 'disabled');
              $('.p1').hide();
              var val1 = $("#RequiredFieldValidator2");
              var val2 = $("#RequiredFieldValidator3");
              ValidatorEnable(val1[0], $(this).is(":checked"));
              ValidatorEnable(val2[0], $(this).is(":checked"));
            } else {
              alert("Таны мэдээлэл бүртгэлгүй байгаа тул бүх талбарыг бөглөнө үү!")
              $('#firstname').removeAttr("disabled");
              $('#lastname').removeAttr("disabled");
              $('#mobileNum').removeAttr("disabled");
              $('#address').removeAttr("disabled");
              $('.p1').show();
              $('.p1').val("");
              $('#firstname').val("");
              $('#lastname').val("");
              $('#mobileNum').val("");
              $('#address').val("");
            }
          }
        },
        error: function (xhr, ajaxOptions, thrownError) {
          console.log("Status: " + xhr.status + " Error: " + thrownError);
        }
      };
      $.ajax(options);
    }
  </script>
  <style>
    .panel {
      width: 1000px;
      margin-left: calc(50% - 500px);
      margin-top: 100px
    }

    @media only screen and (max-width: 1200px) {
      .panel {
        width: 100%;
        margin-left: 0;
        margin-top: 100px
      }
    }
  </style>
</head>
<body>
  <form id="form1" runat="server" class="col-md-12" enctype="multipart/form-data">
    <asp:ScriptManager ID="ScriptManger1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="up" runat="server">
      <ContentTemplate>
        <div class="page-wrapper">
          <div class="row">
            <img src="../../Images/logosend.png" style="width: 200px; margin-left: calc(50% - 100px); margin-top: 20px; margin-bottom: 20px;">
            <div class="col-sm-12" style="background-color: #00D2FF; height: 30px; width: 100%">
            </div>
          </div>
          <div class="row">
            <div class="col-md-12">
              <div class="panel panel-default recent-activites" style="">
                <div class="panel-heading">
                  <h4 class="panel-title">Мөнгө хүлээж авах</h4>
                </div>
                <div class="panel-body" style="padding: 35px;">
                  <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                    <Triggers>
                      <asp:PostBackTrigger ControlID="btnRegister" />
                    </Triggers>
                    <ContentTemplate>
                      <div class="row">
                        <div class="col-lg-4 col-md-6 form-group">
                          <label class="control-label" style="width: 100%;" for="regNum">
                            Регистрийн дугаар:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="regNum" runat="server" CssClass="clr"></asp:TextBox>
                          <input type="button" id="search" class="btn m-t-25 btn-success" value="Хайх">
                          <asp:RequiredFieldValidator ID="regNumValidator" runat="server" ControlToValidate="regNum" ErrorMessage="Регистрийн дугаар оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-3 form-group" style="display: flex; flex-direction: row; justify-content: flex-end;">
                          <div>
                          </div>
                        </div>
                        <div class="col-lg-12 col-md-6 form-group">
                          <label class="control-label" for="controlNumber">
                            Гүйлгээний код:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="controlNumber" runat="server" CssClass="form-control clr"></asp:TextBox>
                          <asp:RequiredFieldValidator ID="controlNoValidator" runat="server" ControlToValidate="controlNumber" ErrorMessage="Гүйлгээний дугаар оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="lastname">
                            Овог:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="lastname" runat="server" CssClass="form-control clr"></asp:TextBox>
                          <asp:RequiredFieldValidator ID="lastnameValidator" runat="server" ControlToValidate="lastname" ErrorMessage="Овог оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="firstname">
                            Нэр:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="firstname" runat="server" CssClass="form-control clr"></asp:TextBox>
                          <asp:RequiredFieldValidator ID="firstnameValidator" runat="server" ControlToValidate="firstname" ErrorMessage="Нэр оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="mobileNum">
                            Утас:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="mobileNum" runat="server" CssClass="form-control clr"></asp:TextBox>
                          <asp:RequiredFieldValidator ID="mobileNumValidator" runat="server" ControlToValidate="mobileNum" ErrorMessage="Утасны дугаар оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-12 col-md-6 form-group">
                          <label class="control-label" for="address">
                            Гэрийн хаяг:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="address" runat="server" CssClass="form-control clr"></asp:TextBox>
                          <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="address" ErrorMessage="Гүйлгээний дугаар оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-12 col-md-6 form-group">
                          <label class="control-label" for="accountNo">
                            <span style="color: orangered;">Валютын ханшийг тухайн өдрийн Голомт банкны (бэлэн бус, авах) ханшаар тооцохыг анхаарна уу!</span>
                          </label>
                        </div>
                        <div class="col-lg-6 col-md-6 form-group">
                          <label class="control-label" for="bank">
                            Хүлээн авах банк:<span style="color: red;">*</span>
                          </label>
                          <asp:DropDownList ID="bank" runat="server" CssClass="form-control clr">
                            <asp:ListItem Text="Аймаг/Хот" Value="" Selected="True">Банк сонгох</asp:ListItem>
                            <asp:ListItem Text="Улаанбаатар">Хаан банк</asp:ListItem>
                            <asp:ListItem Text="Архангай">Голомт банк</asp:ListItem>
                            <asp:ListItem Text="Баянхонгор">Хас банк</asp:ListItem>
                            <asp:ListItem Text="Баян-Өлгий">Төрийн банк</asp:ListItem>
                            <asp:ListItem Text="Булган">Улаанбаатар хотын банк</asp:ListItem>
                            <asp:ListItem Text="Говьсүмбэр">Чингис банк</asp:ListItem>
                            <asp:ListItem Text="Говь-Алтай">Худалдаа хөгжлийн банк</asp:ListItem>
                            <asp:ListItem Text="Дархан-Уул">Капитрон банк</asp:ListItem>
                            <asp:ListItem Text="Дорноговь">Үндэсний хөрөнгө оруулалтын банк</asp:ListItem>
                            <asp:ListItem Text="Дорнод">Ариг банк</asp:ListItem>
                            <asp:ListItem Text="Дундговь">Кредит банк</asp:ListItem>
                            <asp:ListItem Text="Завхан">Богд банк</asp:ListItem>
                            <asp:ListItem Text="Орхон">Транс банк</asp:ListItem>
                            <asp:ListItem Text="Өвөрхангай">Хөгжлийн банк</asp:ListItem>
                            <asp:ListItem Text="Өмнөговь">Капитал банк</asp:ListItem>
                          </asp:DropDownList>
                          <asp:RequiredFieldValidator ID="BankValidator" runat="server" ControlToValidate="bank" ErrorMessage="Банк сонгох шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-12 col-md-6 form-group">
                          <label class="control-label" for="accountNo">
                            <span style="color: orangered;">Зөвхөн гүйлгээ хүлээн авагчийн дансны мэдээлэл оруулахыг анхаарна уу!</span>
                          </label>
                        </div>
                        <div class="col-lg-6 col-md-6 form-group">
                          <label class="control-label" for="accountNo">
                            Хүлээн авах данс:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="accountNo" runat="server" CssClass="form-control clr"></asp:TextBox>
                          <asp:RequiredFieldValidator ID="AccountNoValidator" runat="server" ControlToValidate="accountNo" ErrorMessage="Банк сонгох шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-6 col-md-6 form-group">
                          <label class="control-label" for="money">
                            Дүн:<span style="color: red;">*</span>
                          </label>
                          <asp:TextBox ID="money" runat="server" CssClass="form-control clr"></asp:TextBox>
                          <asp:RequiredFieldValidator ID="MoneyValidator" runat="server" ControlToValidate="money" ErrorMessage="Банк сонгох шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-lg-12 col-md-4 form-group p1">
                          <label class="control-label" for="accountNo">
                            <span style="color: orangered;">Та бичиг баримт хавсаргах хэсэгт иргэний үнэмлэхний 2 талын зураг эсвэл EMongolia-с авсан лавлагааг оруулна уу.<br>Хавсралт зураг нь чанартай, мэдээллүүд нь тод, гаргацтай харагдах ёстойг анхаарна уу!</span>
                          </label>
                        </div>
                        <div class="col-lg-6 col-md-4 form-group p1">
                          <label class="control-label" for="photo1">Photo 1:</label>
                          <asp:FileUpload ID="photo1" runat="server" CssClass="form-control clr" accept="image/*" />
                          <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ControlToValidate="photo1" ErrorMessage="Иргэний үнэмлэхний зураг оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                          <%= photoPreview[0] %>
                        </div>
                        <div class="col-lg-6 col-md-4 form-group p1">
                          <label class="control-label" for="photo2">Photo 2:</label>
                          <asp:FileUpload ID="photo2" runat="server" CssClass="form-control clr" accept="image/*" />
                          <asp:RequiredFieldValidator ID="RequiredFieldValidator3" runat="server" ControlToValidate="photo2" ErrorMessage="Иргэний үнэмлэхний зураг оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                          <%= photoPreview[1] %>
                        </div>
                      </div>
                    </ContentTemplate>
                  </asp:UpdatePanel>
                  <div class="row">
                    <div class="col-lg-12 form-group" style="display: flex; flex-direction: row; justify-content: flex-end;">
                      <asp:Button ID="btnRegister" runat="server" Text="Илгээх" CssClass="btn m-t-25 btn-success" OnClick="btnRegister_Click" />
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
