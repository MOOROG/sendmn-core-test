<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SendmnB2B.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.SendmnB2B" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <meta charset="utf-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="description" content="" />
  <meta name="author" content="" />

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

  <script type="text/javascript">
    $(document).ready(function () {

      var tabName = $("[id*=hdnCurrentTab]").val() != "" ? $("[id*=hdnCurrentTab]").val() : "menu";
      $('#MainDiv a[href="#' + tabName + '"]').tab('show');
      $('ul.mineLi li').click(function (e) {
        $("[id*=hdnCurrentTab]").val($("a", this).attr('href').replace("#", ""));
        if ($("[id*=hdnCurrentTab]").val() == 'menu') {
          $('#menu').addClass('active');
          $('#menu1').removeClass('active');
        } else {
          $('#menu1').removeClass('active');
          $('#menu').removeClass('active');
        }
      });
    });
  </script>

</head>
<body>
  <form id="form1" runat="server" class="col-md-12" enctype="multipart/form-data">
    <asp:HiddenField ID="hdnCurrentTab" runat="server" Value="menu" />
    <div class="page-wrapper">
      <div class="row">
        <img src="../../Images/logosend.png" style="width: 200px; margin-left: calc(50% - 100px); margin-top: 20px; margin-bottom: 20px;" />
        <div class="col-sm-12" style="background-color: #00D2FF; height: 30px; width: 100%">
        </div>
      </div>
      <div class="report-tab" id="MainDiv" runat="server">
        <div class="listtabs">
          <ul class="nav nav-tabs mineLi" role="tablist" id="myTab">
            <li><a data-toggle="tab" href="#menu" aria-controls="menu" role="tab">Хувь хүн</a></li>
            <li><a data-toggle="tab" href="#menu1" aria-controls="menu1" role="tab">Байгууллага</a></li>
          </ul>
        </div>

        <fieldset>
          <div class="col-lg-4 col-md-6 form-group">
            <label class="control-label" style="width: 100%;" for="regNum">
              Регистрийн дугаар:<span style="color: red;">*</span>
            </label>
            <asp:TextBox ID="regNum" runat="server" CssClass="clr"></asp:TextBox>
            <input type="button" id="search" class="btn m-t-25 btn-success" value="Хайх" />
            <asp:RequiredFieldValidator ID="regNumValidator" runat="server" ControlToValidate="regNum" ErrorMessage="Регистрийн дугаар оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
          </div>
        </fieldset>

        <div class="tab-content">
          <div role="tabpanel" class="tab-pane active" id="menu">
            <div class="row">
              <div class="col-md-12">
                <div class="panel-default recent-activites">
                  <div class="panel-body">
                    <%-- Илгээгчийн мэдээлэл/Хувь хүн --%>
                    <fieldset>
                      <legend>Хувь хүн</legend>
                      <div class="col-lg-2 col-md-6 form-group">
                        <label class="control-label" for="lastname">
                          Овог:<span style="color: red;">*</span>
                        </label>
                        <asp:TextBox ID="lastname" runat="server" CssClass="form-control clr"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="lastnameValidator" runat="server" ControlToValidate="lastname" ErrorMessage="Овог оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>

                      <div class="col-lg-2 col-md-6 form-group">
                        <label class="control-label" for="firstname">
                          Нэр:<span style="color: red;">*</span>
                        </label>
                        <asp:TextBox ID="firstname" runat="server" CssClass="form-control clr"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="firstnameValidator" runat="server" ControlToValidate="firstname" ErrorMessage="Нэр оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>

                      <div class="col-lg-2 col-md-6 form-group">
                        <label class="control-label" for="rd">
                          Регистрийн дугаар:<span style="color: red;">*</span>
                        </label>
                        <asp:TextBox ID="rd" runat="server" CssClass="form-control clr"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rdValidator" runat="server" ControlToValidate="rd" ErrorMessage="РД оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-6 col-md-6 form-group">
                        <label class="control-label" for="address">
                          Гэрийн хаяг:<span style="color: red;">*</span>
                        </label>
                        <asp:TextBox ID="address" runat="server" CssClass="form-control clr"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="addressValidator" runat="server" ControlToValidate="address" ErrorMessage="Гэрийн хаяг оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-2 col-md-6 form-group">
                        <label class="control-label" for="mobileNum">
                          Утас:<span style="color: red;">*</span>
                        </label>
                        <asp:TextBox ID="mobileNum" runat="server" CssClass="form-control clr"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="mobileNumValidator" runat="server" ControlToValidate="mobileNum" ErrorMessage="Утасны дугаар оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-2 col-md-6 form-group">
                        <label class="control-label" for="occupType">
                          Ажлын газар албан тушаал/Сонгох/:<span style="color: red;">*</span>
                        </label>
                        <asp:DropDownList ID="occupType" runat="server" CssClass="form-control clr">
                          <asp:ListItem></asp:ListItem>
                          <asp:ListItem></asp:ListItem>
                          <asp:ListItem></asp:ListItem>
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="occupTypeValidator" runat="server" ControlToValidate="occupType" ErrorMessage="Албан тушаал сонгох шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-4 col-md-4 form-group p1">
                        <label class="control-label" for="photo1">Иргэний үнэмлэхний урд талын зураг:</label>
                        <asp:FileUpload ID="photo1" runat="server" CssClass="form-control clr" accept="image/*" />
                        <asp:RequiredFieldValidator ID="frontPicValidator" runat="server" ControlToValidate="photo1" ErrorMessage="Иргэний үнэмлэхний зураг оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-4 col-md-4 form-group p1">
                        <label class="control-label" for="photo2">Иргэний үнэмлэхний ар талын зураг:</label>
                        <asp:FileUpload ID="photo2" runat="server" CssClass="form-control clr" accept="image/*" />
                        <asp:RequiredFieldValidator ID="backPicValidator3" runat="server" ControlToValidate="photo2" ErrorMessage="Иргэний үнэмлэхний зураг оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                    </fieldset>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div role="tabpanel" class="tab-pane" id="menu1">
            <div class="row">
              <div class="col-md-12">
                <div class="panel-default recent-activites">
                  <div class="panel-body">
                    <%-- Илгээгчийн мэдээлэл/Байгууллага --%>
                    <fieldset>
                      <legend>Байгууллага</legend>
                      <div class="col-lg-2 col-md-6 form-group">
                        <label class="control-label" for="companyName">
                          Компаны нэр:<span style="color: red;">*</span>
                        </label>
                        <asp:TextBox ID="companyName" runat="server" CssClass="form-control clr"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="companyNameValidator" runat="server" ControlToValidate="companyName" ErrorMessage="Компаны нэр оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-2 col-md-6 form-group">
                        <label class="control-label" for="companyRd">
                          Регистрийн дугаар:<span style="color: red;">*</span>
                        </label>
                        <asp:TextBox ID="companyRd" runat="server" CssClass="form-control clr"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="companyRdValidator" runat="server" ControlToValidate="companyRd" ErrorMessage="Регистрийн дугаар оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-2 col-md-6 form-group">
                        <label class="control-label" for="companyNum">
                          Утас:<span style="color: red;">*</span>
                        </label>
                        <asp:TextBox ID="companyNum" runat="server" CssClass="form-control clr"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="companyNumValidator" runat="server" ControlToValidate="companyNum" ErrorMessage="Утас оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-6 col-md-6 form-group">
                        <label class="control-label" for="companyAddress">
                          Хаяг:<span style="color: red;">*</span>
                        </label>
                        <asp:TextBox ID="companyAddress" runat="server" CssClass="form-control clr"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="companyAddressValidator" runat="server" ControlToValidate="companyAddress" ErrorMessage="Хаяг оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-3 col-md-4 form-group">
                        <label class="control-label" for="photo3">Компаны гэрчилгээ:</label>
                        <asp:FileUpload ID="photo3" runat="server" CssClass="form-control clr" accept="image/*" />
                        <asp:RequiredFieldValidator ID="companyCertificateValidator" runat="server" ControlToValidate="photo1" ErrorMessage="Компаны гэрчилгээ оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-3 col-md-4 form-group">
                        <label class="control-label" for="photo3">Компанийн дүрэм:</label>
                        <asp:FileUpload ID="companyRule" runat="server" CssClass="form-control clr" accept="image/*" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="companyRule" ErrorMessage="Компаны дүрэм оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-3 col-md-4 form-group">
                        <label class="control-label" for="photo4">Хувьцаа эзэмшигчийн жагсаалт/Компаны тамгатай/:</label>
                        <asp:FileUpload ID="photo4" runat="server" CssClass="form-control clr" accept="image/*" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator10" runat="server" ControlToValidate="photo2" ErrorMessage="Хувьцаа эзэмшигчийн жагсаалт оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-3 col-md-4 form-group">
                        <label class="control-label" for="photo5">Гүйцэтгэх удирдлагын иргэний үнэмлэхний 2 талын зураг:</label>
                        <asp:FileUpload ID="photo5" runat="server" CssClass="form-control clr" accept="image/*" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator7" runat="server" ControlToValidate="photo1" ErrorMessage="Гүйцэтгэх удирдлагын иргэний үнэмлэхний зураг оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                      <div class="col-lg-6 col-md-4 form-group">
                        <label class="control-label" for="photo6">Эцсийн өмчлөгчийн иргэний үнэмлэхний 2 талын зураг:</label>
                        <asp:FileUpload ID="photo6" runat="server" CssClass="form-control clr" accept="image/*" />
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator8" runat="server" ControlToValidate="photo2" ErrorMessage="Эцсийн өмчлөгчийн иргэний үнэмлэхний зураг оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                      </div>
                    </fieldset>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="row" style="margin-top:40px">
          <div class="col-md-12">
            <div class="panel-default recent-activites" style="">
              <div class="panel-body" style="padding: 35px;">
                <div class="row">
                  <%-- Хүлээн авагчийн мэдээлэл --%>
                  <fieldset>
                    <legend>Хүлээн авагчийн мэдээлэл</legend>
                    <div class="col-lg-2 col-md-6 form-group">
                      <label class="control-label" for="receiverCompanyName">
                        Хүлээн авагч компаны нэр:<span style="color: red;">*</span>
                      </label>
                      <asp:TextBox ID="receiverCompanyName" runat="server" CssClass="form-control clr"></asp:TextBox>
                      <asp:RequiredFieldValidator ID="receiverCompanyNameValidator" runat="server" ControlToValidate="receiverCompanyName" ErrorMessage="Компаны нэр оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                    </div>
                    <div class="col-lg-2 col-md-6 form-group">
                      <label class="control-label" for="receiverCompanyRd">
                        Компаны регистр:<span style="color: red;">*</span>
                      </label>
                      <asp:TextBox ID="receiverCompanyRd" runat="server" CssClass="form-control clr"></asp:TextBox>
                      <asp:RequiredFieldValidator ID="receiverCompanyRdValidator" runat="server" ControlToValidate="receiverCompanyRd" ErrorMessage="Регистрийн дугаар оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                    </div>
                    <div class="col-lg-2 col-md-6 form-group">
                      <label class="control-label" for="receiverCompanyNum">
                        Утасны дугаар:<span style="color: red;">*</span>
                      </label>
                      <asp:TextBox ID="receiverCompanyNum" runat="server" CssClass="form-control clr"></asp:TextBox>
                      <asp:RequiredFieldValidator ID="receiverCompanyNumValidator" runat="server" ControlToValidate="receiverCompanyNum" ErrorMessage="Утас оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                    </div>
                    <div class="col-lg-6 col-md-6 form-group">
                      <label class="control-label" for="receiverCompanyAddress">
                        Хаяг:<span style="color: red;">*</span>
                      </label>
                      <asp:TextBox ID="receiverCompanyAddress" runat="server" CssClass="form-control clr"></asp:TextBox>
                      <asp:RequiredFieldValidator ID="receiverCompanyAddressValidator" runat="server" ControlToValidate="receiverCompanyAddress" ErrorMessage="Хаяг оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                    </div>
                    <div class="col-lg-2 col-md-6 form-group">
                      <label class="control-label" for="receiverAmount">
                        Илгээх дүн:<span style="color: red;">*</span>
                      </label>
                      <asp:TextBox ID="receiverAmount" runat="server" CssClass="form-control clr"></asp:TextBox>
                      <asp:RequiredFieldValidator ID="receiverAmountValidator" runat="server" ControlToValidate="receiverAmount" ErrorMessage="Дүн оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                    </div>
                    <div class="col-lg-2 col-md-6 form-group">
                      <label class="control-label" for="bank">
                        Банк сонгох:<span style="color: red;">*</span>
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
                    <div class="col-lg-2 col-md-6 form-group">
                      <label class="control-label" for="receiverAccNumber">
                        Хүлээн авагчийн дансны дугаар:<span style="color: red;">*</span>
                      </label>
                      <asp:TextBox ID="receiverAccNumber" runat="server" CssClass="form-control clr"></asp:TextBox>
                      <asp:RequiredFieldValidator ID="receiverAccNumberValidator" runat="server" ControlToValidate="receiverAccNumber" ErrorMessage="Дансны дугаар оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                    </div>
                    <div class="col-lg-6 col-md-6 form-group">
                      <label class="control-label" for="receiverMsg">
                        Гүйлгээний утга:<span style="color: red;">*</span>
                      </label>
                      <asp:TextBox ID="receiverMsg" runat="server" CssClass="form-control clr"></asp:TextBox>
                      <asp:RequiredFieldValidator ID="receiverMsgValidator" runat="server" ControlToValidate="receiverMsg" ErrorMessage="Гүйлгээний утга оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                    </div>
                    <div class="col-lg-12 col-md-4 form-group p1">
                      <label class="control-label" for="photo7">Нэхэмжлэлийн зураг:</label>
                      <asp:FileUpload ID="photo7" runat="server" CssClass="form-control clr" accept="image/*" />
                      <asp:RequiredFieldValidator ID="receiverBillingValidator" runat="server" ControlToValidate="photo4" ErrorMessage="Нэхэмжлэлийн зураг оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                    </div>
                  </fieldset>

                  <%-- Бүртгэлтэй хэрэглэгч шинэ хүлээн авагч бүртгэх үед --%>
                  <fieldset>
                    <legend>Илгээгчийн мэдээлэл / Хувь хүн</legend>
                    <div class="col-lg-4 col-md-6 form-group">
                      <label class="control-label" for="senderName">
                        Илгээгчийн нэр:<span style="color: red;">*</span>
                      </label>
                      <asp:TextBox ID="senderName" runat="server" CssClass="form-control clr"></asp:TextBox>
                      <asp:RequiredFieldValidator ID="senderNameValidator" runat="server" ControlToValidate="senderName" ErrorMessage="Нэр оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                    </div>
                    <div class="col-lg-4 col-md-6 form-group">
                      <label class="control-label" for="senderAddress">
                        Хаяг:<span style="color: red;">*</span>
                      </label>
                      <asp:TextBox ID="senderAddress" runat="server" CssClass="form-control clr"></asp:TextBox>
                      <asp:RequiredFieldValidator ID="senderAddressValidator" runat="server" ControlToValidate="senderAddress" ErrorMessage="Хаяг оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                    </div>
                    <div class="col-lg-4 col-md-6 form-group">
                      <label class="control-label" for="senderNum">
                        Утас:<span style="color: red;">*</span>
                      </label>
                      <asp:TextBox ID="senderNum" runat="server" CssClass="form-control clr"></asp:TextBox>
                      <asp:RequiredFieldValidator ID="senderNumValidator" runat="server" ControlToValidate="senderNum" ErrorMessage="Утасны дугаар оруулах шаардлагатай!" ForeColor="Red"></asp:RequiredFieldValidator>
                    </div>
                  </fieldset>
                </div>
                <div class="row">
                  <div class="col-lg-12 form-group" style="display: flex; flex-direction: row; justify-content: flex-end;">
                    <asp:Button ID="btnRegister" runat="server" Text="Илгээх" CssClass="btn m-t-25 btn-success" />
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
