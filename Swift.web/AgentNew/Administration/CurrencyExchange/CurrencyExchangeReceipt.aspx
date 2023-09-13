<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CurrencyExchangeReceipt.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CurrencyExchange.CurrencyExchangeReceipt" %>

<!DOCTYPE html>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
  <title></title>
  <script src="/js/swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js" type="text/javascript"> </script>
  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <link href="/ui/css/menu.css" type="text/css" rel="stylesheet" />
  <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <link href="/ui/css/waves.min.css" type="text/css" rel="stylesheet" />
  <link href="/ui/css/style.css" type="text/css" rel="stylesheet" />
  <link href="/ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <link href="/ui/css/datepicker-custom.css" rel="stylesheet" />
  <script type="text/javascript" src="/ui/js/jquery.min.js"></script>
  <script type="text/javascript" src="/ui/bootstrap/js/bootstrap.min.js"></script>
  <script src="/ui/js/bootstrap-datepicker.js" type="text/javascript"></script>
  <script src="/ui/js/pickers-init.js" type="text/javascript"></script>
  <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>
  <link href="/css/TranStyle2.css" rel="stylesheet" type="text/css" />
</head>
<style>
  .headerTable {
    font-size: 11px;
  }

  .image {
    width: 200px;
    height: 250px
  }

  #form1 {
    margin: 20px;
  }

  div.Section1 {
    page: Section1;
  }
</style>
<body>
  <form id="form1" runat="server">
    <div class="row">
      <div class="col-sm-12 checkBody" runat="server">
        <table border="0" width="100%" id="divInvoiceSecond1" runat="server">
          <!--Header-->
          <tr>
            <td>
              <table width="100%;" border="0" class="headerTable">
                <tr>
                  <td width="20%;">
                    <div class="logo">
                      <img src="/images/jme.png" />
                    </div>
                    <p><%= Swift.web.Library.GetStatic.ReadWebConfig("licenseName","") %></p>
                    <p>
                      Number:<span><%= Swift.web.Library.GetStatic.ReadWebConfig("licenseNo","") %>
                      </span>
                    </p>
                  </td>
                  <td width="80%;" style="padding: 0 10px;">
                    <h4><%= Swift.web.Library.GetStatic.ReadWebConfig("headName","") %></h4>
                    <p>
                      <%= Swift.web.Library.GetStatic.ReadWebConfig("headFirst","") %>
                    </p>
                    <p>
                      Tel : <%= Swift.web.Library.GetStatic.ReadWebConfig("headTel","") %>
                      <span>Fax : <%= Swift.web.Library.GetStatic.ReadWebConfig("headFax","") %> </span>
                    </p>
                    <p>
                      <%= Swift.web.Library.GetStatic.ReadWebConfig("headEmail","") %>
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <tr style="float: right">
            <td>
              <h4>Control No :
                <asp:Label ID="controlNo" runat="server"></asp:Label></h4>
            </td>
          </tr>
          <!--body-->
          <tr valign="top">
            <td colspan="2">
              <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                <!--sender information-->
                <tr>
                  <td>
                    <table width="100%;" style="border-bottom: 1px solid #ccc; padding: 5px;">
                      <tr>
                        <td width="25% " valign="top" style="padding: 0 5px;">
                          <label>Харилцагчийн овог:</label>
                        </td>
                        <td width="25% " valign="top">
                          <asp:Label ID="lastnameVal" runat="server"></asp:Label>
                        </td>
                        <td width="25% " valign="top">
                          <label>Харилцагчийн нэр:</label>
                        </td>
                        <td width="25% ">
                          <asp:Label ID="firstnameVal" runat="server"></asp:Label>
                        </td>
                      </tr>
                      <tr>
                        <td style="padding: 0 5px;">
                          <label>Регистрийн дугаар:</label>
                        </td>
                        <td>
                          <asp:Label ID="regVal" runat="server"></asp:Label>
                        </td>
                        <td width="25% " valign="top">
                          <label>Утасны дугаар:</label>
                        </td>
                        <td width="25%">
                          <asp:Label ID="mobileVal" runat="server"></asp:Label>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>

                <tr>
                  <td>
                    <table width="100%;" style="border-bottom: 1px solid #ccc; padding: 5px;">
                      <tr>
                        <td style="width: 40%; padding: 0 5px;">
                          <label>Валют арилжааны нөхцөл:</label>
                        </td>
                        <td style="width: 15%">
                          <label>Валют</label>
                        </td>
                        <td style="width: 15%">
                          <label>Хэлбэр</label>
                        </td>
                        <td style="width: 15%">
                          <label>Ханш</label>
                        </td>
                        <td style="width: 15%">
                          <label>Дүн</label>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
                <!--Receiver information-->
                <tr>
                  <td>
                    <table width="100%;" style="border-bottom: 1px solid #ccc; padding: 5px;">
                      <tr>
                        <td style="width: 40%; padding: 0 5px;">
                          <span>Харилцагч зарах</span>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="cCurVal" runat="server"></asp:Label>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="cTypeVal" runat="server"></asp:Label>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="cRateVal" runat="server"></asp:Label>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="cAmountVal" runat="server"></asp:Label>
                        </td>
                      </tr>
                      <tr>
                        <td style="width: 40%; padding: 0 5px;">
                          <span>Харилцагч авах</span>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="pCurVal" runat="server"></asp:Label>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="pTypeVal" runat="server"></asp:Label>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="pRateVal" runat="server"></asp:Label>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="pAmountVal" runat="server"></asp:Label>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <!--information section-->
          <tr valign="top">
            <td colspan="2">
              <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                <tr valign="top">
                  <td colspan="4" style="padding: 5px;">
                    <p>THE ABOVE INFORMATION IS CORRECT AND I DECLARE THAT I READ TERMS AND CONDITIONS</p>
                  </td>
                </tr>

                <tr>
                  <td style="padding: 5px;">
                    <label>Customer's Signature</label>
                  </td>
                  <td>..................................................
                  </td>
                  <td colspan="2">
                    <label>Chief Accountant:</label>
                    <img src="/images/SanhuuTamga.png" style="width: 200px">
                    /Б. Оюун-Эрдэнэ/
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>

        <table width="100%;" style="margin: 50px 0;" id="divInvoiceSecond" runat="server">
          <tr>
            <td>
              <center>-----------------------------------------------------------------Cut From Here-----------------------------------------------------------------</center>
            </td>
          </tr>
        </table>

        <table width="100%" id="divInvoiceSecond2" runat="server">
          <!--Header-->
          <tr>
            <td>
              <table width="100%;" class="headerTable">
                <tr>
                  <td width="20%;">
                    <div class="logo">
                      <img src="/images/jme.png" />
                    </div>
                    <p><%= Swift.web.Library.GetStatic.ReadWebConfig("licenseName","") %></p>
                    <p>
                      Number:<span><%= Swift.web.Library.GetStatic.ReadWebConfig("licenseNo","") %>
                      </span>
                    </p>
                  </td>
                  <td width="80%;" style="padding: 0 10px;">
                    <h4><%= Swift.web.Library.GetStatic.ReadWebConfig("headName","") %></h4>
                    <p>
                      <%= Swift.web.Library.GetStatic.ReadWebConfig("headFirst","") %>
                    </p>
                    <p>
                      Tel : <%= Swift.web.Library.GetStatic.ReadWebConfig("headTel","") %>
                      <span>Fax : <%= Swift.web.Library.GetStatic.ReadWebConfig("headFax","") %> </span>
                    </p>
                    <p>
                      <%= Swift.web.Library.GetStatic.ReadWebConfig("headEmail","") %>
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <tr style="float: right">
            <td>
              <h4>Control No :
                <asp:Label ID="controlNo2" runat="server"></asp:Label></h4>
            </td>
          </tr>
          <!--body-->
          <tr valign="top">
            <td colspan="2">
              <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                <!--sender information-->
                <tr>
                  <td>
                    <table width="100%;" style="border-bottom: 1px solid #ccc; padding: 5px;">
                      <tr>
                        <td width="25% " valign="top" style="padding: 0 5px;">
                          <label>Харилцагчийн овог:</label>
                        </td>
                        <td width="25% " valign="top">
                          <asp:Label ID="lastnameVal2" runat="server"></asp:Label>
                        </td>
                        <td width="25% " valign="top">
                          <label>Харилцагчийн нэр:</label>
                        </td>
                        <td width="25% ">
                          <asp:Label ID="firstnameVal2" runat="server"></asp:Label>
                        </td>
                      </tr>
                      <tr>
                        <td style="padding: 0 5px;">
                          <label>Регистрийн дугаар:</label>
                        </td>
                        <td>
                          <asp:Label ID="regVal2" runat="server"></asp:Label>
                        </td>
                        <td width="25% " valign="top">
                          <label>Утасны дугаар:</label>
                        </td>
                        <td width="25%">
                          <asp:Label ID="mobileVal2" runat="server"></asp:Label>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>

                <tr>
                  <td>
                    <table width="100%;" style="border-bottom: 1px solid #ccc; padding: 5px;">
                      <tr>
                        <td style="width: 40%; padding: 0 5px;">
                          <label>Валют арилжааны нөхцөл:</label>
                        </td>
                        <td style="width: 15%">
                          <label>Валют</label>
                        </td>
                        <td style="width: 15%">
                          <label>Хэлбэр</label>
                        </td>
                        <td style="width: 15%">
                          <label>Ханш</label>
                        </td>
                        <td style="width: 15%">
                          <label>Дүн</label>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
                <!--Receiver information-->
                <tr>
                  <td>
                    <table width="100%;" style="border-bottom: 1px solid #ccc; padding: 5px;">
                      <tr>
                        <td style="width: 40%; padding: 0 5px;">
                          <span>Харилцагч зарах</span>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="cCurVal2" runat="server"></asp:Label>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="cTypeVal2" runat="server"></asp:Label>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="cRateVal2" runat="server"></asp:Label>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="cAmountVal2" runat="server"></asp:Label>
                        </td>
                      </tr>
                      <tr>
                        <td style="width: 40%; padding: 0 5px;">
                          <span>Харилцагч авах</span>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="pCurVal2" runat="server"></asp:Label>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="pTypeVal2" runat="server"></asp:Label>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="pRateVal2" runat="server"></asp:Label>
                        </td>
                        <td style="width: 15%">
                          <asp:Label ID="pAmountVal2" runat="server"></asp:Label>
                        </td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <!--information section-->
          <tr valign="top">
            <td colspan="2">
              <table width="100%;" style="border: 1px solid #ccc; padding: 5px;">
                <tr valign="top">
                  <td colspan="4" style="padding: 5px;">
                    <p>THE ABOVE INFORMATION IS CORRECT AND I DECLARE THAT I READ TERMS AND CONDITIONS</p>
                  </td>
                </tr>

                <tr>
                  <td style="padding: 5px;">
                    <label>Customer's Signature</label>
                  </td>
                  <td>..................................................
                  </td>
                  <td colspan="2">
                    <label>Chief Accountant:</label>
                    <img src="/images/SanhuuTamga.png" style="width: 200px">
                    /Б. Оюун-Эрдэнэ/
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>

        <div class="col-md-12" style="margin-top: 20px">
          <div class="form-group col-md-2">
            <input type="button" value="Print" id="printId" runat="server" class="btn btn-primary"
              onclick="javascript:ReportPrintLocal();" />
          </div>
          <div class="form-group col-md-2">
            <input type="button" value="New transaction" id="tranId" runat="server" class="btn btn-primary"
              onclick="javascript:tran();" />
          </div>
        </div>
      </div>
    </div>
  </form>
</body>

<script type="text/javascript">
  function ReportPrintLocal() {
   $("#printId").hide();
   $("#newTran").hide();
   window.print();
   $("#newTran").show();
 }
 function tran() {
  window.location.href = "/AgentNew/Administration/CurrencyExchange/CurrencyExchange.aspx";
 }
</script>
</html>
