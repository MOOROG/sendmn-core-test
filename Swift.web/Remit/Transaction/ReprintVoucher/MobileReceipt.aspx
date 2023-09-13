<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MobileReceipt.aspx.cs" Inherits="Swift.web.Remit.Transaction.ReprintVoucher.MobileReceipt" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
  <link href="/css/receipt.css" rel="stylesheet" />
  <base id="Base2" runat="server" target="_self" />

  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/style.css" rel="stylesheet" />
  <script src="/js/functions.js" type="text/javascript"> </script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script src="/ui/js/jquery.min.js"></script>
  <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>
  <style type="text/css">
    @import url("https://fonts.googleapis.com/css?family=Nunito+Sans:400,700&display=swap");

    body {
      width: 100% !important;
      height: 100%;
      margin: 0;
      -webkit-text-size-adjust: none;
    }

    ul {
      column-count: 2;
    }

    a {
      color: #3869D4;
    }

      a img {
        border: none;
      }

    td {
      word-break: break-word;
      width: 50%;
    }

    .preheader {
      display: none !important;
      visibility: hidden;
      /*mso-hide: all;*/
      font-size: 1px;
      line-height: 1px;
      max-height: 0;
      max-width: 0;
      opacity: 0;
      overflow: hidden;
    }
    /* Type ------------------------------ */

    body,
    td,
    th {
      font-family: "Nunito Sans", Helvetica, Arial, sans-serif;
    }

    h1 {
      margin-top: 0;
      color: #333333;
      font-size: 22px;
      font-weight: bold;
      text-align: left;
    }

    h2 {
      margin-top: 0;
      color: #333333;
      font-size: 16px;
      font-weight: bold;
      text-align: left;
    }

    h3 {
      margin-top: 0;
      color: #333333;
      font-size: 14px;
      font-weight: bold;
      text-align: left;
    }

    td,
    th {
      font-size: 16px;
    }

    p,
    ul,
    ol,
    blockquote {
      margin: .4em 0 1.1875em;
      font-size: 16px;
      line-height: 1.625;
    }

      p.sub {
        font-size: 13px;
      }
    /* Utilities ------------------------------ */

    .align-right {
      text-align: right;
    }

    .align-left {
      text-align: left;
    }

    .align-center {
      text-align: center;
    }

    .u-margin-bottom-none {
      margin-bottom: 0;
    }
    /* Buttons ------------------------------ */

    .button {
      background-color: #3869D4;
      border-top: 10px solid #3869D4;
      border-right: 18px solid #3869D4;
      border-bottom: 10px solid #3869D4;
      border-left: 18px solid #3869D4;
      display: inline-block;
      color: #FFF;
      text-decoration: none;
      border-radius: 3px;
      box-shadow: 0 2px 3px rgba(0, 0, 0, 0.16);
      -webkit-text-size-adjust: none;
      box-sizing: border-box;
    }

    .button--green {
      background-color: #22BC66;
      border-top: 10px solid #22BC66;
      border-right: 18px solid #22BC66;
      border-bottom: 10px solid #22BC66;
      border-left: 18px solid #22BC66;
    }

    .button--red {
      background-color: #FF6136;
      border-top: 10px solid #FF6136;
      border-right: 18px solid #FF6136;
      border-bottom: 10px solid #FF6136;
      border-left: 18px solid #FF6136;
    }

    @media only screen and (max-width: 500px) {
      .button {
        width: 100% !important;
        text-align: center !important;
      }
    }
    /* Attribute list ------------------------------ */

    .attributes {
      margin: 0 0 21px;
    }

    .attributes_content {
      background-color: #F4F4F7;
      padding: 16px;
    }

    .attributes_item {
      padding: 0;
    }
    /* Related Items ------------------------------ */

    .related {
      width: 100%;
      margin: 0;
      padding: 25px 0 0 0;
      -premailer-width: 100%;
      -premailer-cellpadding: 0;
      -premailer-cellspacing: 0;
    }

    .related_item {
      padding: 10px 0;
      color: #CBCCCF;
      font-size: 15px;
      line-height: 18px;
    }

    .related_item-title {
      display: block;
      margin: .5em 0 0;
    }

    .related_item-thumb {
      display: block;
      padding-bottom: 10px;
    }

    .related_heading {
      border-top: 1px solid #CBCCCF;
      text-align: center;
      padding: 25px 0 10px;
    }
    /* Discount Code ------------------------------ */

    .discount {
      width: 100%;
      margin: 0;
      padding: 24px;
      -premailer-width: 100%;
      -premailer-cellpadding: 0;
      -premailer-cellspacing: 0;
      background-color: #F4F4F7;
      border: 2px dashed #CBCCCF;
    }

    .discount_heading {
      text-align: center;
    }

    .discount_body {
      text-align: center;
      font-size: 15px;
    }
    /* Social Icons ------------------------------ */

    .social {
      width: auto;
    }

      .social td {
        padding: 0;
        width: auto;
      }

    .social_icon {
      height: 20px;
      margin: 0 8px 10px 8px;
      padding: 0;
    }
    /* Data table ------------------------------ */

    .purchase {
      width: 100%;
      margin: 0;
      padding: 35px 0;
      -premailer-width: 100%;
      -premailer-cellpadding: 0;
      -premailer-cellspacing: 0;
    }

    .purchase_content {
      width: 100%;
      margin: 0;
      padding: 25px 0 0 0;
      -premailer-width: 100%;
      -premailer-cellpadding: 0;
      -premailer-cellspacing: 0;
    }

    .purchase_item {
      padding: 10px 0;
      color: #51545E;
      font-size: 15px;
      line-height: 18px;
    }

    .purchase_heading {
      padding-bottom: 8px;
      border-bottom: 1px solid #EAEAEC;
    }

      .purchase_heading p {
        margin: 0;
        color: #85878E;
        font-size: 12px;
      }

    .purchase_footer {
      padding-top: 15px;
      border-top: 1px solid #EAEAEC;
    }

    .purchase_total {
      margin: 0;
      text-align: right;
      font-weight: bold;
      color: #333333;
    }

    .purchase_total--label {
      padding: 0 15px 0 0;
    }

    body {
      background-color: #F2F4F6;
      color: #51545E;
    }

    p {
      color: #51545E;
    }

    .email-wrapper {
      width: 100%;
      margin: 0;
      padding: 0;
      -premailer-width: 100%;
      -premailer-cellpadding: 0;
      -premailer-cellspacing: 0;
      background-color: #F2F4F6;
    }

    .email-content {
      width: 100%;
      margin: 0;
      padding: 0;
      -premailer-width: 100%;
      -premailer-cellpadding: 0;
      -premailer-cellspacing: 0;
    }
    /* Masthead ----------------------- */

    .email-masthead {
      padding: 25px 0;
      text-align: center;
    }

    .email-masthead_logo {
      width: 94px;
    }

    .email-masthead_name {
      font-size: 16px;
      font-weight: bold;
      color: #A8AAAF;
      text-decoration: none;
      text-shadow: 0 1px 0 white;
    }
    /* Body ------------------------------ */

    .email-body {
      width: 100%;
      margin: 0;
      padding: 0;
      -premailer-width: 100%;
      -premailer-cellpadding: 0;
      -premailer-cellspacing: 0;
    }

    .email-body_inner {
      width: 700px;
      margin: 0 auto;
      padding: 0;
      -premailer-width: 700px;
      -premailer-cellpadding: 0;
      -premailer-cellspacing: 0;
      background-color: #FFFFFF;
    }

    .email-footer {
      width: 700px;
      margin: 0 auto;
      padding: 0;
      -premailer-width: 700px;
      -premailer-cellpadding: 0;
      -premailer-cellspacing: 0;
      text-align: center;
    }

      .email-footer p {
        color: #A8AAAF;
      }

    .body-action {
      width: 100%;
      margin: 30px auto;
      padding: 0;
      -premailer-width: 100%;
      -premailer-cellpadding: 0;
      -premailer-cellspacing: 0;
      text-align: center;
    }

    .body-sub {
      margin-top: 25px;
      padding-top: 25px;
      border-top: 1px solid #EAEAEC;
    }

    .content-cell {
      padding: 45px;
    }
    /*Media Queries ------------------------------ */

    @media only screen and (max-width: 600px) {
      .email-body_inner,
      .email-footer {
        width: 100% !important;
      }
    }

    @media (prefers-color-scheme: dark) {
      body,
      .email-body,
      .email-body_inner,
      .email-content,
      .email-wrapper,
      .email-masthead,
      .email-footer {
        background-color: #333333 !important;
        color: #FFF !important;
      }

      p,
      ul,
      ol,
      blockquote,
      h1,
      h2,
      h3,
      span,
      .purchase_item {
        color: #FFF !important;
      }

      .attributes_content,
      .discount {
        background-color: #222 !important;
      }

      .email-masthead_name {
        text-shadow: none !important;
      }
    }

    :root {
      color-scheme: light dark;
      /*supported-color-schemes: light dark;*/
    }

    ul {
      column-count: 2 !important;
      list-style-type: none;
      columns: 2 auto;
    }

    .col td {
      width: 50%;
    }

    .attributes td {
      width: 50%;
    }
  </style>
  <script type="text/javascript">
    $(document).ready(function () {

    });
    function Print() {
      window.print();
    }

  </script>
</head>

<body>
  <span class="preheader">This email message will serve as your receipt.</span>
  <table class="email-wrapper" width="100%" cellpadding="0" cellspacing="0" role="presentation">
    <tr>
      <td align="center">
        <table class="email-content" width="100%" cellpadding="0" cellspacing="0" role="presentation">
          <!-- Email Body -->
          <tr>
            <td class="email-body" width="100%" cellpadding="0" cellspacing="0">
              <table class="email-body_inner" align="center" width="100%" cellpadding="0" cellspacing="0" role="presentation">
                <!-- Body content -->
                <tr>
                  <td class="content-cell">
                    <div class="f-fallback">
                      <table>
                        <tr>
                          <td>
                            <h1>Гүйлгээний баримт</h1>
                          </td>
                          <td style="width: 300px"></td>
                          <td>
                            <img src="/images/jme.png" style="width: 160px"></td>
                        </tr>
                      </table>
                      <table class="purchase" width="100%" cellpadding="0" cellspacing="0" role="presentation">
                        <tr>
                          <td>
                            <h3>
                              <asp:Label ID="HControlNo" runat="server"></asp:Label></h3>
                          </td>
                          <td>
                            <h3 style="width: 80px; margin-left: -80px;">
                              <asp:Label ID="curDate" runat="server"></asp:Label></h3>
                          </td>
                        </tr>
                        <tr>
                          <td>
                            <table class="attributes" width="650" cellpadding="0" cellspacing="0" role="presentation">
                              <tr>
                                <td class="attributes_content">
                                  <h2>ИЛГЭЭГЧИЙН МЭДЭЭЛЭЛ</h2>
                                  <table class="col" width="650" cellpadding="0" cellspacing="0" role="presentation">
                                    <tr>
                                      <td style="width: 50%;"><strong>Илгээгчийн нэр:</strong></td>
                                      <td><span class="sender-value">
                                        <asp:Label ID="senderName" runat="server"></asp:Label></span></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Гишүүнчлэлийн №:</strong></td>
                                      <td><span class="sender-value">
                                        <asp:Label ID="memberId" runat="server"></asp:Label></span></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Иргэншил: </strong></td>
                                      <td><span class="sender-value">
                                        <asp:Label ID="sCountry" runat="server"></asp:Label></span></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Утасны дугаар: </strong></td>
                                      <td><span class="sender-value">
                                        <asp:Label ID="sContactNo" runat="server"></asp:Label></span></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Хаяг:</strong></td>
                                      <td><span class="sender-value">
                                        <asp:Label ID="sAddress" runat="server"></asp:Label></span></td>
                                    </tr>
                                  </table>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                        <tr>
                          <td>
                            <table class="attributes" width="650" cellpadding="0" cellspacing="0" role="presentation">
                              <tr>
                                <td class="attributes_content">
                                  <h2>ХҮЛЭЭН АВАГЧИЙН МЭДЭЭЛЭЛ</h2>
                                  <table class="col" width="650" cellpadding="0" cellspacing="0" role="presentation">
                                    <tr>
                                      <td style="width: 50%;"><strong>Төлбөр хүлээн авах улс:</strong></td>
                                      <td><span class="sender-value">
                                        <asp:Label ID="pCountry" runat="server"></asp:Label></span></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Хүлээн авагчийн нэр:</strong></td>
                                      <td><span class="sender-value">
                                        <asp:Label ID="receiverName" runat="server"></asp:Label></span></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Холбогдох дугаар:</strong></td>
                                      <td><span class="sender-value">
                                        <asp:Label ID="rContactNo" runat="server"></asp:Label></span></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Хаяг:</strong></td>
                                      <td><span class="sender-value">
                                        <asp:Label ID="rAddress" runat="server"></asp:Label></span></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Харилцаа холбоо:</strong></td>
                                      <td><span class="sender-value">
                                        <asp:Label ID="relWithSender" runat="server"></asp:Label></span></td>
                                    </tr>
                                  </table>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                        <tr>
                          <td>
                            <table class="attributes" width="650" cellpadding="0" cellspacing="0" role="presentation">
                              <tr>
                                <td class="attributes_content">
                                  <h2>ГҮЙЛГЭЭНИЙ МЭДЭЭЛЭЛ</h2>
                                  <table class="col" width="650" cellpadding="0" cellspacing="0" role="presentation">
                                    <tr>
                                      <td style="width: 50%;"><strong>Гүйлгээний дугаар:</strong></td>
                                      <td>
                                        <asp:Label ID="txnNum" runat="server"></asp:Label></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Гүйлгээний дүн:</strong></td>
                                      <td>
                                        <asp:Label ID="txnAmount" runat="server"></asp:Label></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Гүйлгээний утга:</strong></td>
                                      <td>
                                        <asp:Label ID="txnNote" runat="server"></asp:Label></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Төлбөрийн төрөл:</strong></td>
                                      <td>
                                        <asp:Label ID="paymentMode" runat="server"></asp:Label></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Банкны нэр:</strong></td>
                                      <td>
                                        <asp:Label ID="bankName" runat="server"></asp:Label></td>
                                    </tr>
                                    <tr>
                                      <td><strong>Данс:</strong></td>
                                      <td>
                                        <asp:Label ID="bankAccNum" runat="server"></asp:Label></td>
                                    </tr>
                                  </table>
                                </td>
                              </tr>
                            </table>
                          </td>
                        </tr>
                        <tr>
                          <td>
                            <table>
                              <tr style="height: 30px;"></tr>
                              <tr>
                                <td style="width: 300px"></td>
                                <td style="width: 300px"><%--Нягтлан бодогч <asp:Label ID="operator1" runat="server"></asp:Label>--%></td>
                                <td>
                                  <img src="/images/SanhuuTamga.png" style="width: 100px"></td>
                                <td></td>
                              </tr>
                              <tr></tr>
                            </table>
                          </td>
                        </tr>
                      </table>
                      <table class="body-sub" role="presentation">
                        <tr>
                          <td>
                            <p>
                              Хэрэв таньд лавлах зүйл байвал лавлах утас: 7000-0909.
                                      Мөн <a href="mailto:{{support_email}}">finance@send.mn</a> хаягруу и-мэйл илгээх боломжтой.
                            </p>
                            <%--<p class="f-fallback sub"><strong>Гүйлгээний баримтын PDF хувилбарыг татаж авахыг хүсвэл </strong> <a href="{{action_url}}"> Энд дарна уу</a>.</p>--%>
                            <p>
                              Баярлалаа,
                                    <br>
                              SendMN-ийн хамт олон.
                            </p>
                          </td>
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
              <table class="email-footer" align="center" width="570" cellpadding="0" cellspacing="0" role="presentation">
                <tr>
                  <td class="content-cell">
                    <a href="https://www.facebook.com/SendMN.Nbfi/">
                      <img src="/images/facebook.png" style="width: 30px;"> </img>
                    </a>
                    <a href="https://www.instagram.com/send.mn/">
                      <img src="/images/instagram.png" style="width: 30px;"> </img>
                    </a>
                    <a href="https://www.instagram.com/send.mn/">
                      <img src="/images/youtube.png" style="width: 30px;"> </img>
                    </a>
                    <p>
                      [SendMN]
                        <br />
                      УБ хот, СБД, 1-р хороо, Чингисийн өргөн чөлөө 17, Соёл амралтын хүрээлэн гудамж, Централ Парк барилга, 7-р давхарт
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
<script type="text/javascript">
  function PrintWindow() {
    window.print();
  }
</script>
