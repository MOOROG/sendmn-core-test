<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manuals.aspx.cs" Inherits="Swift.web.OtherServices.Manuals.Manuals" %>

<!DOCTYPE html>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

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
</head>
<body>
  <form id="form1" runat="server" class="col-md-12">
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
                  <li class="active"><a href="#">Manuals</a></li>
                </ol>
              </div>
            </div>
          </div>
          <div class="row">
            <div id="rptDiv" style="margin-top: 10px;">
              <div>
                <table border="0" class="table table-condensed table-bordered table-striped" cellpadding="0" cellspacing="0" align="left">
                  <tbody>
                    <tr>
                      <td>1</td>
                      <td><a href="../../admin_files/1. SENDMN NBFI LLC 210617 - AML MANUAL ENG.pdf" target="_blank">SENDMN NBFI LLC 210617 - AML MANUAL ENG</a></td>
                    </tr>
                    <tr>
                      <td>2</td>
                      <td><a href="../../admin_files/2. СЭНД.ЭМ.ЭН ББСБ ХХК 210617 - AML MANUAL MN.pdf" target="_blank">СЭНД.ЭМ.ЭН ББСБ ХХК 210617 - AML MANUAL MN</a></td>
                    </tr>
                    <tr>
                      <td>3</td>
                      <td><a href="../../admin_files/3. Банкнаас бусад санхүүгийн байгууллагуудад зориулсан мөнгө угаах болон терроризмыг санхүүжүүлэхээс урьдчилан сэргийлэх гарын авлага.pdf" target="_blank">Банкнаас бусад санхүүгийн байгууллагуудад зориулсан мөнгө угаах болон терроризмыг санхүүжүүлэхээс урьдчилан сэргийлэх гарын авлага</a></td>
                    </tr>
                    <tr>
                      <td>4</td>
                      <td><a href="../../admin_files/4. ББСБ - Сэжигтэй гүйлгээний тайлан мэдээлэх гарын авлага.pdf" target="_blank">ББСБ - Сэжигтэй гүйлгээний тайлан мэдээлэх гарын авлага</a></td>
                    </tr>
                    <tr>
                      <td>5</td>
                      <td><a href="../../admin_files/5. ББСБ Комплаенсын ажилтнуудад зориулсан гарын авлага.pdf" target="_blank">ББСБ Комплаенсын ажилтнуудад зориулсан гарын авлага</a></td>
                    </tr>
                    <tr>
                      <td>6</td>
                      <td><a href="../../admin_files/6. Зорилтот санхүүгийн хориг арга хэмжээ хэрэгжүүлэх гарын авлага.pdf" target="_blank">Зорилтот санхүүгийн хориг арга хэмжээ хэрэгжүүлэх гарын авлага</a></td>
                    </tr>
                    <tr>
                      <td>7</td>
                      <td><a href="../../admin_files/7. ЗӨРЧЛИЙН ТУХАЙ ХУУЛЬ холбогдох заалтууд.pdf" target="_blank">ЗӨРЧЛИЙН ТУХАЙ ХУУЛЬ холбогдох заалтууд</a></td>
                    </tr>
                    <tr>
                      <td>8</td>
                      <td><a href="../../admin_files/8. Комплаенсын гарын авлага.pdf" target="_blank">Комплаенсын гарын авлага</a></td>
                    </tr>
                    <tr>
                      <td>9</td>
                      <td><a href="../../admin_files/9. Мөнгө угаах болон терроризмыг санхүүжүүлэх үй олноор хөнөөх зэвсэг дэлгэрүүлэхтэй тэмцэх нь гарын авлага.pdf" target="_blank">Мөнгө угаах болон терроризмыг санхүүжүүлэх үй олноор хөнөөх зэвсэг дэлгэрүүлэхтэй тэмцэх нь гарын авлага</a></td>
                    </tr>
                    <tr>
                      <td>10</td>
                      <td><a href="../../admin_files/10. МӨНГӨ УГААХ, ТЕРРОРИЗМЫГ САНХҮҮЖҮҮЛЭХЭЭС УРЬДЧИЛАН СЭРГИЙЛЭХ ҮЙЛ АЖИЛЛАГААНЫ ЖУРАМ.pdf" target="_blank">МӨНГӨ УГААХ, ТЕРРОРИЗМЫГ САНХҮҮЖҮҮЛЭХЭЭС УРЬДЧИЛАН СЭРГИЙЛЭХ ҮЙЛ АЖИЛЛАГААНЫ ЖУРАМ</a></td>
                    </tr>
                    <tr>
                      <td>11</td>
                      <td><a href="../../admin_files/11. Санхүүгийн мэдээллийн албанд мэдээлэх үүрэгтэй этгээдээс цахимаар мэдээлэл ирүүлэх журам.pdf" target="_blank">Санхүүгийн мэдээллийн албанд мэдээлэх үүрэгтэй этгээдээс цахимаар мэдээлэл ирүүлэх журам</a></td>
                    </tr>
                    <tr>
                      <td>12</td>
                      <td><a href="../../admin_files/12. СЭНД ЭМ ЭН ББСБ ХХК 200415-20.11 - ХӨДӨЛМӨРИЙН ДОТООД ЖУРАМ.pdf" target="_blank">СЭНД ЭМ ЭН ББСБ ХХК 200415-20.11 - ХӨДӨЛМӨРИЙН ДОТООД ЖУРАМ</a></td>
                    </tr>
                    <tr>
                      <td>13</td>
                      <td><a href="../../admin_files/13. СЭНД ЭМ ЭН ББСБ ХХК 200917-20.14 - ЦАХИМ ТӨЛБӨР ТООЦОО, МӨНГӨН ГУЙВУУЛГЫН ҮЙЛ АЖИЛЛАГААНЫ ЖУРАМ.pdf" target="_blank">СЭНД ЭМ ЭН ББСБ ХХК 200917-20.14 - ЦАХИМ ТӨЛБӨР ТООЦОО, МӨНГӨН ГУЙВУУЛГЫН ҮЙЛ АЖИЛЛАГААНЫ ЖУРАМ</a></td>
                    </tr>
                    <tr>
                      <td>14</td>
                      <td><a href="../../admin_files/14. СЭНД ЭМ ЭН ББСБ ХХК 210430-21.6 - МУТСТ ДХ, ЭУ-н хөтөлбөр.pdf" target="_blank">СЭНД ЭМ ЭН ББСБ ХХК 210430-21.6 - МУТСТ ДХ, ЭУ-н хөтөлбөр</a></td>
                    </tr>
                    <tr>
                      <td>15</td>
                      <td><a href="../../admin_files/15. Улс төрд нөлөө бүхий этгээдийг тогтоох талаар мэдээлэх үүрэгтэй этгээдэд зориулсан гарын авлага.pdf" target="_blank">Улс төрд нөлөө бүхий этгээдийг тогтоох талаар мэдээлэх үүрэгтэй этгээдэд зориулсан гарын авлага</a></td>
                    </tr>
                    <tr>
                      <td>16</td>
                      <td><a href="../../admin_files/16. ФАТФ ЗӨВЛӨМЖ.pdf" target="_blank">ФАТФ ЗӨВЛӨМЖ</a></td>
                    </tr>
                    <tr>
                      <td>17-1</td>
                      <td><a href="../../admin_files/17-1. Cash origin form-MN.pdf" target="_blank">Бэлэн мөнгөний гарал үүслийг тодорхойлох маягт(MN)</a></td>
                    </tr>
                    <tr>
                      <td>17-2</td>
                      <td><a href="../../admin_files/17-2. Cash origin form-EN.pdf" target="_blank">Бэлэн мөнгөний гарал үүслийг тодорхойлох маягт(EN)</a></td>
                    </tr>
                    <tr>
                      <td>18</td>
                      <td><a href="../../admin_files/18. Гүйлгээтэй холбоотой тохируулга.pdf" target="_blank">Гүйлгээтэй холбоотой тохируулга</a></td>
                    </tr>
                    <tr>
                      <td>19</td>
                      <td><a href="../../admin_files/19. Шинэ ажент тохируулах, ханшны тохиргоо.pdf" target="_blank">Шинэ ажент тохируулах, ханшны тохиргоо</a></td>
                    </tr>
                    <tr>
                      <td>20</td>
                      <td><a href="../../admin_files/20. SendmnAppManual.pdf" target="_blank">SendMN mobile application гарын авлага</a></td>
                    </tr>
                    <tr>
                      <td>21</td>
                      <td><a href="../../admin_files/Чөлөөний-хуудас.docx" target="_blank">Чөлөөний хуудас</a></td>
                    </tr>
                    <tr>
                      <td>22</td>
                      <td><a href="../../admin_files/Шаардах-хуудас-ПХ.xlsx" target="_blank">Шаардах хуудас</a></td>
                    </tr>
                       <tr>
                      <td>23</td>
                      <td><a href="../../admin_files/Ээлжийн-амралтын-хуудас.docx" target="_blank">Ээлжийн амралтын хуудас</a></td>
                    </tr>
                    <tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
        </div>
      </ContentTemplate>
    </asp:UpdatePanel>
  </form>
</body>
