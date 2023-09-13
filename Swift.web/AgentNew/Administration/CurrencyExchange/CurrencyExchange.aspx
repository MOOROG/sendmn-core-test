<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CurrencyExchange.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CurrencyExchange.CurrencyExchange" %>

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
  .content {
    align-items: center;
    color: white;
    display: flex;
    flex: 1 0 auto;
    justify-content: center;
    &:nth-of-type(1)

  {
    width: 70%;
    float: left;
    border-right: solid 1px black;
  }

  &:nth-of-type(2) {
    width: 30%;
    float: right;
  }

  }

  .parent {
    display: flex;
    flex-flow: row wrap;
    margin: 0 -0.5rem;
  }

  .child {
    flex: 1 0 25%;
    min-width: 200px;
    padding-left: 2rem;
    padding-right: 2rem;
    margin-left: 2rem;
    margin-right: 2rem;
    overflow: hidden;
  }

    .child > div {
      color: #000;
      padding: 0.5rem;
    }


  .wrapper {
    padding: 4em;
    padding-bottom: 0;
  }

  .currency-selector {
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    padding-left: .5rem;
    border: 0;
    background: transparent;
    -webkit-appearance: none;
    -moz-appearance: none;
    appearance: none;
    background: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='1024' height='640'><path d='M1017 68L541 626q-11 12-26 12t-26-12L13 68Q-3 49 6 24.5T39 0h952q24 0 33 24.5t-7 43.5z'></path></svg>") 90%/12px 6px no-repeat;
    font-family: inherit;
    color: inherit;
  }

  .currency-amount {
    text-align: right;
  }

  .currency-addon {
    width: 6em;
    text-align: left;
    position: relative;
  }

  table, th, td {
    border: solid 1px #000;
    padding-left: 20px;
    padding-right: 20px;
    color: black;
    text-align: center;
  }

  #invoice-POS {
    box-shadow: 0 0 1in -0.25in rgba(0, 0, 0, 0.5);
    padding: 2mm;
    margin: 0 auto;
    width: 80mm;
    background: #FFF;
  }

  h2 {
    font-size: 1.2em;
    font-weight: bold;
  }

  p {
    font-size: .8em;
    color: #666;
    line-height: 1em;
  }
  @media print, screen {
        #invoice-POS {
            box-shadow: 0 0 1in -0.25in rgba(0, 0, 0, 0.5);
            padding: 5mm;
            margin: 0 auto;
            width: 80mm;
            background: #FFF;
            font-family: 'Arial';
            color: black;
        }
        #invoice-POS-customer {
            box-shadow: 0 0 1in -0.25in rgba(0, 0, 0, 0.5);
            padding: 5mm;
            margin: 0 auto;
            width: 80mm;
            background: #FFF;
            font-family: 'Arial';
            color: black;
        }

        .logo {
            height: 100%;
            width: 30%;
            margin-right: 10mm;
        }

        .location {
            width: 60%;
            font-size: 2.2mm;
            text-align: right;
        }

        .name {
            font-size: 2.4mm;
            margin-bottom: 0;
        }

        .bot {
            height: 32mm;
            padding: 2mm 2.6mm 2.6mm 2.6mm;
            margin: 0 0 10mm 0;
            font-size: 2.9mm;
            background-color: #EDEDED !important;
            -webkit-print-color-adjust: exact;
        }

        .signature {
            margin-bottom: 10mm;
            font-size: 2.6mm;
        }
    }
  #barimt{
      display: flex;
    }
    .head {
        display: flex;
    }
</style>
<body>
  <form id="form1" runat="server">
    <div class="row">
      <div class="col-sm-12">
        <div class="page-title">
          <ol class="breadcrumb">
            &nbsp<li><a href="/Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
            &nbsp<li><a href="CurrencyExchange.aspx">Transaction</a></li>
          </ol>
        </div>
      </div>
      <div class="col-md-12 editBody">
        <asp:TextBox ID="cRate" runat="server" CssClass="form-control hidden"></asp:TextBox>
        <asp:TextBox ID="pRate" runat="server" CssClass="form-control hidden"></asp:TextBox>
        <asp:TextBox ID="pCurrencyHide" runat="server" CssClass="form-control hidden"></asp:TextBox>
        <asp:TextBox ID="cAmountHide" runat="server" CssClass="form-control hidden"></asp:TextBox>
        <asp:TextBox ID="pAmountHide" runat="server" CssClass="form-control hidden"></asp:TextBox>
        <asp:HiddenField ID="dob" runat="server" />

        <div class="col-md-12">
          <div class="panel panel-default recent-activites">
            <div class="panel-heading">
              <h4 class="panel-title">Transaction</h4>
              <div id="control">
                <div id="divDevStatus">
                  <input type="button" data-value="ToBeConnect" id="connection" onclick="onConnection();" />
                  <span id="deviceStatus">Not connected to WebSocket service</span>
                  <span id="deviceNameKey" class="cDevStatusKey" style="display: none">device name:</span>
                  <span id="deviceName"></span>
                  <span id="deviceSerialKey" class="cDevStatusKey" style="display: none">device serial number:</span>
                  <span id="deviceSerial"></span>
                </div>
              </div>
            </div>
            <div class="panel-body">
              <contenttemplate>

                <div class="content">
                  <div class="parent">
                    <div class="child">
                      <div class="form-group">
                        <ul>
                          <li class="form-group">
                            <input type="radio" value="Buy" id="fast" name="selector" />
                            <label for="fast">BUY/АВАХ</label>
                          </li>
                          <li class="form-group">
                            <input type="radio" value="Sale" id="medium" name="selector" />
                            <label for="medium">SALE/ЗАРАХ</label>
                          </li>
                        </ul>
                      </div>
                    </div>
                    <div class="child">
                      <div class="form-group">
                        <label class="control-label" for="dt">
                          Date/Огноо
                        </label>
                        <asp:TextBox ID="dt" runat="server" ReadOnly="true" CssClass="form-control">2023-08-01</asp:TextBox>
                      </div>
                    </div>
                    <div class="child">
                      <div class="form-group">
                        <label class="control-label" for="dt">
                          Payment mode/А.төрөл
                        </label>
                        <select class="form-control" id="paymentModeId">
                          <option value="Cash">Бэлэн</option>
                          <option value="Account">Бэлэн бус</option>
                          <option value="Mixed">Холимог</option>
                        </select>
                      </div>
                    </div>

                    <div class="child">
                      <div class="form-group">
                        <label class="control-label" for="firstname">
                          Firstname
                        </label>
                        <asp:TextBox ID="firstname" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>
                    <div class="child">
                      <div class="form-group">
                        <label class="control-label" for="lastname">
                          Middlename
                        </label>
                        <asp:TextBox ID="middleName" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>
                    <div class="child">
                      <div class="form-group">
                        <label class="control-label" for="lastname">
                          Lastname
                        </label>
                        <asp:TextBox ID="lastname" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>
                    <div class="child">
                      <div class="form-group">
                        <label class="control-label">
                          <b>Passport Number</b>
                        </label>
                        <asp:TextBox ID="rd" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>
                    <div class="child">
                      <div class="form-group">
                        <label class="control-label" for="mobileNum">
                          Telephone
                        </label>
                        <asp:TextBox ID="mobileNum" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>
                    <div class="child">
                      <div class="form-group">
                        <label class="control-label" for="accountNumber">
                          Account Number
                        </label>
                        <asp:TextBox ID="accountNumber" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>
                    <div class="child">
                      <div class="input-group">
                        <div class="input-group-addon currency-addon">
                          <select class="currency-selector" id="currency2">
                            <option data-symbol="₩" data-placeholder="Cash">KRW</option>
                            <option data-symbol="$" data-placeholder="Cash">USD</option>
                            <option data-symbol="€" data-placeholder="Cash">EUR</option>
                            <option data-symbol="₽" data-placeholder="Cash">RUB</option>
                            <option data-symbol="¥" data-placeholder="Cash">CNY</option>
                            <option data-symbol="¥" data-placeholder="Cash">JPY</option>
                            <option data-symbol="₺" data-placeholder="Cash">TRY</option>
                            <option data-symbol="$" data-placeholder="Cash">AUD</option>
                            <option data-symbol="$" data-placeholder="Cash">HKD</option>
                          </select>
                        </div>
                        <input type="text" class="form-control currency-amount cashAmount2" />
                        <div class="input-group-addon symbol2">₩</div>
                      </div>
                    </div>

                    <div class="child">
                      <div class="input-group">
                        <div class="input-group-addon currency-addon">
                          <span>Rate/Ханш:</span>
                        </div>
                        <asp:TextBox ID="customerRate" Placeholder="Rate" runat="server" disabled="disabled" CssClass="form-control hidden"></asp:TextBox>
                        <asp:TextBox ID="rateView" Placeholder="Rate" runat="server" disabled="disabled" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>

                    <div class="child amount">
                      <div class="input-group cashDiv">
                        <div class="input-group-addon currency-addon">Cash - MNT </div>
                        <input type="text" class="form-control currency-amount cashAmount1" /><div class="input-group-addon">₮</div>
                      </div>
                      <div class="input-group accDiv">
                        <div class="input-group-addon currency-addon">&nbsp; Acc - MNT </div>
                        <input type="text" class="form-control currency-amount accAmount" /><div class="input-group-addon">₮</div>
                      </div>
                    </div>

                    <div class="child">
                      <div class="acc1">
                      </div>
                      <div class="note2">
                        <%--  <div id="divBigImage" align="center">
                          <img id="imageDisplay" class="bigImage" />
                        </div>--%>
                      </div>
                    </div>
                    <div class="child">
                      <div class="form-group" style="margin: 250px 0 0 40%;">
                        <input type="button" value="Ok" id="addNew" runat="server" class="btn btn-primary"
                          onclick="CheckFormValidation();" target="_blank" />
                      </div>
                    </div>
                    <div class="child">
                      <div class="note1">
                      </div>
                    </div>
                  </div>
                </div>

                <div class="content" style="display: grid">
                  <div class="form-group stockTable table1" style="padding-left: 20px">
                  </div>
                  <div class="form-group stockTable table2" style="padding-left: 20px">
                  </div>
                </div>
              </contenttemplate>
            </div>
          </div>
        </div>
      </div>
    </div>
  </form>
  <div id="invoice-POS-customer">
  <div class='head'>
    <img class='logo' src="../../../ui/images/jme.png" />
    <p class='location'>
      203-2 c/c section, passenger terminal,1st floor, Chinggis Khaan International Airport, Sergelen soum, 41090, Tuv province, Mongolia.<br /><br />Phone : 7000-0909
    </p>
  </div>
  <p class='name'>
    Customer copy/Харилцагчийн хувь
  </p>
  <div class="bot">
    <div style="width: 70%; float: left">
      <p>Date/Огноо</p>
      <p>RecID/Гүйлгээний дугаар</p>
      <p>Received cash/Хүлээн авсан</p>
      <p>Rate/Ханш</p>
      <p><strong>Paid cash/Төлсөн дүн</strong></p>
    </div>
    <div style="width: 30%; float: right; text-align: right">
      <p class="recDate">aa</p>
      <p class="recNumber">aa</p>
      <p class="recAmnt1">aa</p>
      <p class="recRate">aa</p>
      <p style="font-weight: bold" class="recAmnt2">aa</p>
    </div>
  </div>
<%--  <div id='barimt' >
    <div>
      <img src="https://i.stack.imgur.com/fn1Hz.png" style="width:60%">
    </div>
    <div id="idk" style="width: 80%; font-size:2.6mm">
      <div style="width: 70%; float: left">
        <p>ДДТД</p>
        <p>Serial number/Сугалааны дугаар </p>
        <p>Amount/Дүн</p>
      </div>
    </div>
  </div>--%>
      <br />
      <br />
      <br />
</div>
  <div id="invoice-POS">
        <div class='head'>
            <%--EDIT HERE--%>
            <img class='logo' src="../../../ui/images/jme.png" /> 
            <p class="location">
      203-2 c/c section, passenger terminal,1st floor, Chinggis Khaan International Airport, Sergelen soum, 41090, Tuv province, Mongolia.<br/> <br/>Phone : 7000-0909
    </p>
        </div>
        <p class='name'>
            Company copy/Байгууллагын хувь
        </p>
        <div class="bot">
            <div style="width: 70%; float: left">
                <p>Date/Огноо</p>
                <p>RecID/Гүйлгээний дугаар</p>
                <p>Received cash/Хүлээн авсан</p>
                <p>Rate/Ханш</p>
                <p><strong>Paid cash/Төлсөн дүн</strong></p>
            </div>
            <div style="width: 30%; float: right; text-align: right">
                <p class="recDate">aa</p>
                <p class="recNumber">aa</p>
                <p class="recAmnt1">aa</p>
                <p class="recRate">aa</p>
                <p style="font-weight: bold" class="recAmnt2">aa</p>
            </div>
        </div>
        <div class='signature'>
            <p style="margin-top: 8mm">Customer signature................................................</p>
            <p style="font-style: italic; padding-left: 3mm">/гарын үсэг/</p>
        </div>
    </div>
</body>
<script type="text/javascript">
  let oldAmnt = 0;
  $(document).ready(function () {
    window.onload = function () {
      document.getElementById("connection").value = strConnect;
      onConnection();
    }
    $(".accDiv").hide();
    $("#invoice-POS").hide();
    $("#invoice-POS-customer").hide();
    jsDataChange(1, 'MNT');
    jsDataChange(2, $("#currency2").find(":selected").val());
    getRate(0);
    balanceTable(1, 'mntTCA', 'MNT')
    balanceTable(2, 'other', $("#currency2").find(":selected").val());
    $(".cashAmount1").keyup(function (e) {
      $(".accAmount").val('');
      calcType = "cashAmount2";
      amountKeyup(e, 'MNT');
      getRate(0);
      oldAmnt = $(".cashAmount1").val();
    })

    $(".cashAmount2").keyup(function (e) {
      $(".accAmount").val('');
      calcType = "cashAmount1";
      amountKeyup(e, $("#currency2").find(":selected").val());
      getRate(0);
    })

    $(".accAmount").keyup(function (e) {
      calcType = "cashAmount2";
      let val = e.target.value;
      if (unformatNumber($(".accMNTStock").text()) < unformatNumber(val)) {
        e.target.value = "";
      } else {
        if (val != "") {
          val = val.replace(/,/g, '');
          val = val.replace(/[^0-9]/g, '');
          val = String(val).replace(/(.)(?=(\d{3})+$)/g, '$1,');
          e.target.value = (val);
        }
      }
      if ($("#paymentModeId").val() == 'Account') {
        $(".cashAmount1").val(e.target.value)
        getRate(0);
      }
      if ($("#paymentModeId").val() == 'Mixed') {
        $(".cashAmount1").val(unformatNumber(oldAmnt) - unformatNumber(e.target.value));
        var number = {};
        let amount = unformatNumber(oldAmnt) - unformatNumber(e.target.value);
        $.each(jsonData, function (index, value) {
          if (value.id == 'MNT') {
            let entry = value.name;
            $(".MNT" + entry).val('');
            if (amount / entry >= 1) {
              number[entry] = Math.floor(amount / entry);
              if ($(".MNT" + entry + "Stock").text() < number[entry]) {
                number[entry] = $(".MNT" + entry + "Stock").text();
              }
              if (number[entry] > 0) {
                $(".MNT" + value.name).val(number[entry]);
              }
              amount = amount - (entry * number[entry]);
            }
          }
        })
      }
    })

    $('input[type=radio]').on('change', function () {
      getRate(0);
    })

    let curOldval = 0;
    $("." + $("#currency2").find(":selected").val() + "-amount").click(function (e) {
      curOldval = e.target.value;
    })
    $("." + $("#currency2").find(":selected").val() + "-amount").keyup(function (e) {
      let val = e.target.value;
      val = val.replace(/[^0-9]/g, '');
      e.target.value = val;
      let summm = 0;
      $.each(jsonData, function (index, value) {
        if (value.id == $("#currency2").find(":selected").val()) {
          summm = summm + unformatNumber($("." + value.id + value.name).val() * value.name);
          if (summm > unformatNumber($(".cashAmount2").val()) && $('input[type=radio]:checked').val() == "Sale")
            e.target.value = curOldval;
        }
      })
      if ($('input[type=radio]:checked').val() != "Sale")
        $(".cashAmount2").val(summm);
      $(".accAmount").val('');
      calcType = "cashAmount1";
      getRate(0);
    })

    let mntOldval = 0;
    $(".MNT" + "-amount").click(function (e) {
      mntOldval = e.target.value;
    })
    $(".MNT" + "-amount").keyup(function (e) {
      let val = e.target.value;
      val = val.replace(/[^0-9]/g, '');
      e.target.value = val;
      let summm = 0;
      $.each(jsonData, function (index, value) {
        if (value.id == 'MNT') {
          summm = summm + unformatNumber($("." + value.id + value.name).val() * value.name);
          if (summm > unformatNumber($(".cashAmount1").val()) && $('input[type=radio]:checked').val() == "Buy")
            e.target.value = mntOldval;
        }
      })

      if ($('input[type=radio]:checked').val() != "Buy")
        $(".cashAmount1").val(summm);
      $(".accAmount").val('');
      calcType = "cashAmount2";
      getRate(0);
      oldAmnt = $(".cashAmount1").val();
    })

  })
  var jsonData = (function () {
    var json = null;
    $.ajax({
      'async': false,
      'global': false,
      'url': "/CurrencyNote.json",
      'dataType': "json",
      'success': function (data) {
        json = data;
      }
    });
    return json;
  })();

  function jsDataChange(id, val) {
    $(".note" + id).html('');
    $.each(jsonData, function (index, value) {
      if (value.id == val) {
        $(".note" + id).append('<div class="input-group"><div class="input-group-addon currency-addon">' + value.name + '</div>' +
          '<input type="text" class="form-control ' + val + '-amount ' + val + value.name + '" style="width:100px" /></div > ');
      }
    })
  }

  function amountKeyup(e, cur) {
    let val = e.target.value;
    if (unformatNumber($(".cash" + cur + "Stock").text()) < unformatNumber(val)) {
      e.target.value = "";
    } else {
      if (val != "" && unformatNumber(val) > 0) {
        val = val.replace(/,/g, '');
        val = val.replace(/[^0-9]/g, '');
        val = String(val).replace(/(.)(?=(\d{3})+$)/g, '$1,');
        e.target.value = (val);
      }
    }
    var number = {};
    var money = unformatNumber(val);
    $.each(jsonData, function (index, value) {
      if (value.id == cur) {
        let entry = value.name;
        $("." + cur + entry).val('');
        if (money / entry >= 1) {
          number[entry] = Math.floor(money / entry);
          if ($("." + cur + entry + "Stock").text() < number[entry]) {
            number[entry] = $("." + cur + entry + "Stock").text();
          }
          if (number[entry] > 0) {
            $("." + cur + value.name).val(number[entry]);
          }
          money = money - (entry * number[entry]);
        }
      }
    })
  }

  function balanceTable(id, methodName, curr) {
    $.ajax({
      url: '<%= ResolveUrl("CurrencyExchange.aspx") %>',
      type: 'POST',
      data: { methodName: methodName, curr: curr, type: $("#paymentModeId").val() },
      success: function (result) {
        $(".table" + id).html(result);
      },
      error: function (result) {
        alert("Sorry! Due to unexpected errors operation terminates !");
      }
    });
  };

  $("#currency2").change(function () {
    var selected = $("#currency2 option:selected");
    $(".symbol2").text(selected.data("symbol"));
    $(".cashAmount1").val('');
    $(".cashAmount2").val('');
    $(".accAmount").val('');
    jsDataChange(2, this.value);
    getRate(0);
    balanceTable(2, 'other', this.value)
  });
  $("#paymentModeId").change(function () {
    $(".cashAmount1").val('');
    $(".cashAmount2").val('');
    $(".accAmount").val('');
    if (this.value == 'Mixed') {
      $(".cashDiv").show();
      $(".accDiv").show();
      jsDataChange(1, 'MNT');
    } else if (this.value == 'Cash') {
      $(".cashDiv").show();
      $(".accDiv").hide();
      jsDataChange(1, 'MNT');
    } else {
      $(".cashDiv").hide();
      $(".accDiv").show();
      jsDataChange(1, '');
    }
  });

  let calcType = "cashAmount2";
  function unformatNumber(n) {
    if (n == undefined || n == '')
      return 0;
    return parseFloat(n.toString().replace(/[^0-9\.-]+/g, ""));
  }

  function rateCalculate(id1, id2) {
    calcType = id1;
    if ($("#paymentModeId").val() == 'Account' && id1 == 'cashAmount1') {
      id1 = 'accAmount';
    }
    let rate = unformatNumber($("#customerRate").val());
    let amount = unformatNumber($("." + id2).val());
    if (calcType == "cashAmount2") {
      amount = amount * rate;
      if (!isNaN(amount) && !Number.isInteger(amount)) {
        if ($('input[type=radio]:checked').val() == "Sale") {
          amount = Math.floor(amount);
        } else {
          amount = Math.ceil(amount);
        }
      }
    } else {
      amount = (amount / rate);
      amount = amount.toFixed(2);
      if (!isNaN(amount) && !Number.isInteger(amount)) {
        if ($('input[type=radio]:checked').val() == "Buy") {
          amount = Math.floor(amount);
        } else {
          amount = Math.ceil(amount);
        }
      }
    }
    amount = Math.round(amount * Math.pow(10, 2)) / Math.pow(10, 2);
    amount = String(amount).replace(/(.)(?=(\d{3})+$)/g, '$1,');
    amount = String(amount).replace(/\d(?=(\d{3})+\.)/g, '$&,');
    $("." + id1).val(amount);
    oldAmnt = amount;

    var number = {};
    let cur = "MNT";
    amount = unformatNumber(amount);
    if (id1 == 'cashAmount2') cur = $("#currency2").find(":selected").val();
    $.each(jsonData, function (index, value) {
      if (value.id == cur) {
        let entry = value.name;
        $("." + cur + entry).val('');
        if (amount / entry >= 1) {
          number[entry] = Math.floor(amount / entry);
          if ($("." + cur + entry + "Stock").text() < number[entry]) {
            number[entry] = $("." + cur + entry + "Stock").text();
          }
          if (number[entry] > 0) {
            $("." + cur + value.name).val(number[entry]);
          }
          amount = amount - (entry * number[entry]);
        }
      }
    })
  }

  function getRate() {
    let getAmt1 = 0;
    let getAmt2 = 0;
    $.ajax({
      url: '<%= ResolveUrl("CurrencyExchange.aspx") %>',
      type: 'POST',
      data: { methodName: "currency_change", curr: $("#currency2").find(":selected").val() },
      success: function (result) {
        var strng = JSON.stringify(result);
        obj = JSON.parse(strng);
        if (obj["ErrorCode"] == 0) {
          getAmt1 = obj["Msg"];
          getAmt2 = obj["Id"];
          getAmt1 = Math.round(getAmt1 * Math.pow(10, 2)) / Math.pow(10, 2);
          getAmt2 = Math.round(getAmt2 * Math.pow(10, 2)) / Math.pow(10, 2);
          if ($('input[type=radio]:checked').val() == "Buy") {
            $("#rateView").val(getAmt1);
            $("#customerRate").val(1 / getAmt1);
          } else {
            $("#rateView").val(getAmt2);
            $("#customerRate").val(1 / getAmt2);
          }
          $("#cRate").val(obj["Msg"]);
          $("#pRate").val(obj["Id"]);
          if (calcType == "cashAmount2") {
            rateCalculate('cashAmount2', 'cashAmount1', unformatNumber($(".accAmount").val()));
          } else {
            rateCalculate('cashAmount1', 'cashAmount2', 0);
          }
        } else {
          $(".cashAmount1").val('')
          $(".cashAmount2").val('')
          $("#customerRate").val('');
          $("#cRate").val(0);
          $("#pRate").val(0);
          alert(obj["Msg"])
        }
      },
      error: function (result) {
        alert("Sorry! Due to unexpected errors operation terminates !");
      }
    });
  }

  var mntSum = 0;
  let curSum = 0;
  function CheckFormValidation() {
    if ($('input[type=radio]:checked').val() == undefined) {
      alert('Арилжааны төрлөө сонгоно уу!');
      return false;
    }
    if ($(".cashAmount1").val() == '' || $(".cashAmount2").val() == '' || $(".cashAmount1").val() == '0' || $(".cashAmount2").val() == '0') {
      alert('Арилжааны дүнгээ оруулна уу!')
      return false;
    }
    mntSum = 0;
    $.each(jsonData, function (index, value) {
      if (value.id == 'MNT') {
        mntSum = mntSum + (unformatNumber($(".MNT" + value.name).val()) * value.name);
      }
    })
    curSum = 0;
    $.each(jsonData, function (index, value) {
      if (value.id == $("#currency2").find(":selected").val()) {
        curSum = curSum + (unformatNumber($("." + $("#currency2").find(":selected").val() + value.name).val()) * value.name);
      }
    })
    if (unformatNumber($(".cashAmount1").val()) != mntSum || unformatNumber($(".cashAmount2").val()) != curSum) {
      alert('Арилжааны дүн таарахгүй байна')
      return false;
    }
    var reqField = "lastname,firstname,rd,";
    if ($("#paymentModeId").val() != 'Cash' && $("#accountNumber").val() == '') {
      reqField = "lastname,firstname,rd,accountNumber,";
    }
    if (ValidRequiredField(reqField) == false) {
      return false;
    }
    if (window.confirm("Do you really want to leave?")) {
      CheckFormSubmit();
      return true;
    }
  }

  function CheckFormSubmit() {
    let mntVal = "";
    $.each(jsonData, function (index, value) {
      if (value.id == 'MNT' && $(".MNT" + value.name).val() != '') {
        if (mntVal != "") {
          mntVal = mntVal + "," + value.name + ":" + $(".MNT" + value.name).val();
        }
        else {
          mntVal = value.name + ":" + $(".MNT" + value.name).val();
        }
      }
    })
    let curVal = "";
    $.each(jsonData, function (index, value) {
      if (value.id == $("#currency2").find(":selected").val() && $("." + $("#currency2").find(":selected").val() + value.name).val() != '') {
        if (curVal != "") {
          curVal = curVal + "," + value.name + ":" + $("." + $("#currency2").find(":selected").val() + value.name).val();
        }
        else {
          curVal = value.name + ":" + $("." + $("#currency2").find(":selected").val() + value.name).val();
        }
      }
    })
    var dt = {
      methodName: "add_Click",
      type: $('input[type=radio]:checked').val(),
      paymentMode: $("#paymentModeId").val(),
      firstName: $("#firstname").val(),
      middleName: $("#middleName").val(),
      lastName: $("#lastname").val(),
      rd: $("#rd").val(),
      mobile: $('#mobileNum').val(),
      accountNumber: $('#accountNumber').val(),
      cCur: 'MNT',
      pCur: $("#currency2").find(":selected").val(),
      cashAmount1: unformatNumber($(".cashAmount1").val()),
      cashAmount2: unformatNumber($(".cashAmount2").val()),
      accAmount: unformatNumber($(".accAmount").val()),
      cRate: unformatNumber($("#cRate").val()),
      pRate: unformatNumber($("#pRate").val()),
      customerRate: unformatNumber($("#customerRate").val()),
      mntVal: mntVal,
      curVal: curVal,
      dob: $('#dob').val()
    }
    $.ajax({
      url: '<%= ResolveUrl("CurrencyExchange.aspx") %>',
      type: 'POST',
      data: dt,
      success: function (result) {
        var strng = JSON.stringify(result);
        obj = JSON.parse(strng);
        alert(obj["Msg"]);
        $("#controlNo").text(obj["Id"]);
        $(".editBody").hide();
        $(".recDate").text($("#dt").val());
        $(".recNumber").text(obj["Id"]);
        $(".recAmnt1").text(unformatNumber(dt.cashAmount1) + unformatNumber(dt.accAmount) + " " + dt.cCur);
        if (dt.type == 'Sale')
          $(".recRate").text(dt.pRate);
        else
          $(".recRate").text(dt.cRate);
        $(".recAmnt2").text(dt.cashAmount2 + " " + dt.pCur);
        $("#invoice-POS").show();
        $("#invoice-POS-customer").show();

        window.print();
        location.reload();
      },
      error: function (result) {
        alert("Sorry! Due to unexpected errors operation terminates !");
      }
    });
    return true;
  }


  var bConnected = false;
  var bCardDetectedNotification = false;
  var websocket = null;
  var bigImageEmpty = true;

  var strConnect = "Establish connection";
  var strDisconnect = "Disconnect";
  var strDevNotConnect = "device not connected";

  var strTltle;
  var strDeviceStatus = "device status";
  var strDeviceConnected = "device connected";
  var strDeviceName = "device name"
  var strDeviceSerialno = "devise serial number";
  var strDescOfWebsocketError = "There is an error in the websocket connection, please confirm that the WebSocket service is running normally, and re-establish the connection";
  var strDescFailSetRFID = "Set whether to read the chip information error";
  var strDescFailSetVIZ = "Set whether to recognize layout information error";
  var strPlaceHolderCardTextInfo = "The text information read from the certificate is displayed here";
  var strDescFailSendWebsocket = "Error sending command to background service";
  var strDeviceOffLine = "device disconnected";
  var strDeviceReconnected = "Device has reconnected";
  var strWebDescDeviceNotFound = "WebSocket connected, no device detected";
  var strWebDescRequireRestartSvc = "WebSocket connected, no device detected";
  var strWebDescAskForSupport = "The WebSocket service encountered a problem, please contact the administrator";
  var strWebDescRequireReconnect = "The webSocket service requires the web side to re-establish the connection";

  window.onbeforeunload = function (event) {
    if (websocket !== null) {
      websocket.close();
      websocket = null;
    }
  }

  /* This function is triggered when the page clicks the establish connection button */
  function onConnection() {
    if (document.getElementById("connection").value == strConnect /*'establish connection'*/) {
      if (websocket !== null) {
        websocket.close();
        websocket = null;
      }

      connect();
    } else {
      if (websocket !== null) {
        websocket.close();
        websocket = null;
      }
    }
  }

  /* Establish a WebSocket connection and initialize websocket properties */
  function connect() {
    try {
      var host = "ws://127.0.0.1:90/echo";
      if (websocket != null) {
        websocket.close();
      }

      websocket = new WebSocket(host);

      /* Successfully established a websocket connection */
      websocket.onopen = function () {
        bConnected = true;
        setConnBtnValue();

        getWebConstants();

        setDefaultSettings();
        timerId = setInterval(getDeviceStatus(), 1000);
      }

      /* Response message or notification message in response to the background service */
      websocket.onmessage = function (event) {
        var retmsg = event.data;
        var jsonMsg;

        try {
          jsonMsg = JSON.parse(retmsg);
          if (jsonMsg.Type == 'Reply') {
            if (jsonMsg.hasOwnProperty('Commands')) {
              for (var index in jsonMsg.Commands) {
                processReply(jsonMsg.Commands[index]);
              }
            } else {
              processReply(jsonMsg);
            }
          } else if (jsonMsg.Type == 'Notify') {
            processNotify(jsonMsg);
          }
          return;
        } catch (exception) {
          // document.getElementById("msg").innerHTML = "Parse error: " + event.data;
        }
      }

      /* Triggered when the websocket connection is actively or passively closed, and the page information is cleared */
      websocket.onclose = function () {
        bConnected = false;
        setConnBtnValue();
        // document.getElementById('connection').value = strConnect; // "establish connection";
        clrDeviceStatus();
        //clrTextInfo();
        //clrImages(true);
        // websocket = null;

        if (websocket !== null) {
          if (websocket.readyState == 3) {
            document.getElementById('deviceStatus').innerHTML = strDescOfWebsocketError;
            document.getElementById('deviceStatus').style.color = '#f00';
          }

          websocket.close();
          websocket = null;
        }
      }

      /* Websocket error event, clear page information and call the police */
      websocket.onerror = function (evt) {
        bConnected = false;
        setConnBtnValue();
        // document.getElementById('connection').value = strConnect; // "establish connection";
        clrDeviceStatus();
        //clrTextInfo();
        //clrImages(true);
      }

    } catch (exception) {
      // document.getElementById("msg").innerHTML = "WebSocket  error";
    }
  }

  function setConnBtnValue() {
    if (bConnected) {
      document.getElementById("connection").value = strDisconnect;
    } else {
      document.getElementById("connection").value = strConnect;
    }
  }

  function getWebConstants() {
    var request = {
      Type: "Request",
      Commands: [
        { Command: "Get", Operand: "WebConstant", Param: "CardRecogSystem" },
        { Command: "Get", Operand: "WebConstant", Param: "Connect" },
        { Command: "Get", Operand: "WebConstant", Param: "Disconnect" },
        { Command: "Get", Operand: "WebConstant", Param: "Save" },
        { Command: "Get", Operand: "WebConstant", Param: "IDCANCEL" },
        { Command: "Get", Operand: "WebConstant", Param: "DeviceStatus" },
        { Command: "Get", Operand: "WebConstant", Param: "DeviceName" },
        { Command: "Get", Operand: "WebConstant", Param: "DeviceSerialno" },
        { Command: "Get", Operand: "WebConstant", Param: "DeviceNotConnected" },
        { Command: "Get", Operand: "WebConstant", Param: "DescOfWebsocketError" },
        { Command: "Get", Operand: "WebConstant", Param: "DescFailSetRFID" },
        { Command: "Get", Operand: "WebConstant", Param: "DescFailSetVIZ" },
        { Command: "Get", Operand: "WebConstant", Param: "PlaceHolderCardTextInfo" },
        { Command: "Get", Operand: "WebConstant", Param: "DeviceOffLine" },
        { Command: "Get", Operand: "WebConstant", Param: "DeviceReconnected" },
        { Command: "Get", Operand: "WebConstant", Param: "DescFailSendWebsocket" },
        { Command: "Get", Operand: "WebConstant", Param: "WebDescDeviceNotFound" },
        { Command: "Get", Operand: "WebConstant", Param: "WebDescRequireRestartSvc" },
        { Command: "Get", Operand: "WebConstant", Param: "WebDescAskForSupport" },
        { Command: "Get", Operand: "WebConstant", Param: "WebDescRequireReconnect" },
        { Command: "Get", Operand: "WebConstant", Param: "DeviceConnected" }
      ]
    };

    sendJson(request);
  }

  function sendJson(jsonData) {
    try {
      if (websocket !== null) {
        websocket.send(JSON.stringify(jsonData));
      }
    } catch (exception) {
      //document.getElementById("msg").innerHTML = strDescFailSendWebsocket;
    }
  }

  function setDefaultSettings() {
    var request = {
      Type: "Request",
      Commands: [
        { Command: "Set", Operand: "RFID", Param: "Y" }, /* Set identification chip information */
        { Command: "Set", Operand: "VIZ", Param: "Y" }   /* Set recognition layout information */
      ]
    };

    sendJson(request);
  }

  function clrDeviceStatus() {
    document.getElementById("deviceStatus").innerHTML = strDevNotConnect;
    document.getElementById("deviceNameKey").style.display = "none";
    document.getElementById('deviceName').innerHTML = "";
    document.getElementById("deviceSerialKey").style.display = "none";
    document.getElementById('deviceSerial').innerHTML = "";
  }

  function processReply(msgReply) {
    if (msgReply.Command == 'Get') {
      if (msgReply.Succeeded == 'Y') { /* The Get command is successfully executed, and the corresponding result is parsed from the response message */
        if (msgReply.Operand == 'DeviceName') { /* Device name in reply message */
          document.getElementById('deviceName').innerHTML = /* strDeviceName + ":" + */ msgReply.Result;
        } else if (msgReply.Operand == 'DeviceSerialNo') { /* Device serial number in reply message */
          document.getElementById('deviceSerial').innerHTML = /* strDeviceSerialno + ":" + */ msgReply.Result;
        } else if (msgReply.Operand == 'OnLineStatus') { /* Device online status in response message */
          document.getElementById('deviceStatus').innerHTML = /* strDeviceStatus + ":" + */ msgReply.Result;
          if (msgReply.Result == strDeviceConnected) {
            document.getElementById('deviceStatus').style.color = '#000';
            document.getElementById('deviceNameKey').style.display = 'inline';
            document.getElementById('deviceSerialKey').style.display = 'inline';
          }
        } else if (msgReply.Operand == 'VersionInfo') {
          document.title = strTitle + "V" + msgReply.Result;
          document.getElementsByTagName("h1")[0].innerText = strTitle + "V" + msgReply.Result;
        } else if (msgReply.Operand == 'WebConstant') {
          if (msgReply.Param == 'CardRecogSystem') {
            strTitle = msgReply.Result;
          } else if (msgReply.Param == 'Connect') {
            strConnect = msgReply.Result;
            setConnBtnValue();
            // document.getElementById("connection").value = msgReply.Result;
          } else if (msgReply.Param == 'Disconnect') {
            strDisconnect = msgReply.Result;
            setConnBtnValue();
            // document.getElementById("connection").value = msgReply.Result;
          } else if (msgReply.Param == 'Save') {
            document.getElementById("btnSaveSettings").value = msgReply.Result;
          } else if (msgReply.Param == 'IDCANCEL') {
            document.getElementById("btnCancelSave").value = msgReply.Result;
          } else if (msgReply.Param == 'DeviceStatus') {
            strDeviceStatus = msgReply.Result;
          } else if (msgReply.Param == 'DeviceName') {
            strDeviceName = msgReply.Result;
            document.getElementById('deviceNameKey').innerHTML = strDeviceName + ":";
            console.log(strDeviceName, msgReply.Result);
          } else if (msgReply.Param == 'DeviceSerialno') {
            strDeviceSerialno = msgReply.Result;
            document.getElementById('deviceSerialKey').innerHTML = strDeviceSerialno + ":";
          } else if (msgReply.Param == 'DeviceNotConnected') {
            strDevNotConnect = msgReply.Result;
          } else if (msgReply.Param == 'DescOfWebsocketError') {
            strDescOfWebsocketError = msgReply.Result;
          } else if (msgReply.Param == 'DescFailSetRFID') {
            strDescFailSetRFID = msgReply.Result;
          } else if (msgReply.Param == 'DescFailSetVIZ') {
            strDescFailSetVIZ = msgReply.Resultl;
          } else if (msgReply.Param == 'PlaceHolderCardTextInfo') {
            // strPlaceHolderCardTextInfo = msgReply.Result;
            // document.getElementById("msg").setAttribute("placeholder", strPlaceHolderCardTextInfo);
          } else if (msgReply.Param == 'DescFailSendWebsocket') {
            strDescFailSendWebsocket = msgReply.Result;
          } else if (msgReply.Param == 'DeviceOffLine') {
            strDeviceOffLine = msgReply.Result;
          } else if (msgReply.Param == 'DeviceReconnected') {
            strDeviceReconnected = msgReply.Result;
          } else if (msgReply.Param == 'WebDescDeviceNotFound') {
            strWebDescDeviceNotFound = msgReply.Result;
          } else if (msgReply.Param == 'WebDescRequireRestartSvc') {
            strWebDescRequireRestartSvc = msgReply.Result;
          } else if (msgReply.Param == 'WebDescAskForSupport') {
            strWebDescAskForSupport = msgReply.Result;
          } else if (msgReply.Param == 'WebDescRequireReconnect') {
            strWebDescRequireReconnect = msgReply.Result;
          } else if (msgReply.Param == 'DeviceConnected') {
            strDeviceConnected = msgReply.Result;
          }
        }
      }
    } else if (msgReply.Command == 'Set') {
      if (msgReply.Succeeded == 'N') { /* Set command does not take effect */
        if (msgReply.Operand == 'RFID') {
          document.getElementById("msg").innerHTML = strDescFailSetRFID;
        } else if (msgReply.Operand == 'VIZ') {
          //document.getElementById("msg").innerHTML = strDescFailSetVIZ;
        }
      }
    }
  }

  function processNotify(msgNotify) {
    if (msgNotify.Command == 'Display') {
      if (msgNotify.Param == strDeviceOffLine) {
        clrDeviceStatus();
        document.getElementById('deviceStatus').innerHTML = strWebDescDeviceNotFound; // "WebSocket connected, no device detected";
        document.getElementById('deviceStatus').style.color = '#f00';
      } else if (msgNotify.Param == strDeviceReconnected) {
        getDeviceStatus();
      }
    } else if (msgNotify.Command == 'Reconnect') {
      clrDeviceStatus();
      document.getElementById('deviceStatus').innerHTML = strWebDescRequireReconnect; // "The WebSocket service requires the web side to re-establish the connection and is reconnecting";
      document.getElementById('deviceStatus').style.color = '#f00';
      disConnect();
      connect();
    } else if (msgNotify.Command == 'AskSupport') {
      clrDeviceStatus();
      document.getElementById('deviceStatus').innerHTML = strWebDescAskForSupport; // "The WebSocket service encountered a problem: " + msgNotify.Param;
      document.getElementById('deviceStatus').style.color = '#f00';
    } else if (msgNotify.Command == 'RestartService') {
      /* disConnect(); */
      document.getElementById('deviceStatus').innerHTML = strWebDescRequireRestartSvc; // "The WebSocket service needs to be restarted, please contact the administrator";
      document.getElementById('deviceStatus').style.color = '#f00';
    } else if (msgNotify.Command == 'Save') {
      if (msgNotify.Operand == 'CardContentText') {
        //clrImages(false);
        displayCardContent(msgNotify.Param);
      } else if (msgNotify.Operand == 'Images') {
        clrImages(false);
        displayImages(msgNotify.Param);
      }
    } else if (msgNotify.Command == 'CardDetected') {
      //clrTextInfo()
      //clrImages(true);
    }
  }

  function clrImages(bForce) {
    if (bForce || !bCardDetectedNotification) {
      //document.getElementById("imageWhite").src = "png/Home_pic_bgicon.png";
      //document.getElementById("imageIR").src = "png/Home_pic_bgicon.png";
      //document.getElementById("imageUV").src = "png/Home_pic_bgicon.png";
      //document.getElementById("imageOcrHead").src = "png/Home_pic_bgicon.png";
      //document.getElementById("imageChipHead").src = "png/Home_pic_bgicon.png";
      document.getElementById("imageDisplay").src = "../../../../ui/images/loading.gif";
      bigImageEmpty = true;
    }
  }

  function getDeviceStatus() {
    var request = {
      Type: "Request",
      Commands: [
        { Command: "Get", Operand: "OnLineStatus" },  /* Get device online status */
        { Command: "Get", Operand: "DeviceName" },    /* get device name */
        { Command: "Get", Operand: "DeviceSerialNo" }, /* Get device serial number */
        { Command: "Get", Operand: "VersionInfo" } /* Get core version information */
      ]
    };

    sendJson(request);
  }

  /*  Parse the document text information (JSON format) and display it on the page */
  function displayCardContent(cardContent) {
    $('#firstname').val(cardContent["English first name"]);
    document.getElementById('middleName');
    $('#lastname').val(cardContent["English surname"]);
    $('#rd').val(cardContent["The passport number from MRZ"]);
    $('#dob').val(cardContent["Date of birth"]);
    //var domTextArea = document.getElementById('divTextArea');
    //var domTextItem;
    //var domKeySpan;
    //var domValInput;

    //domTextArea.innerHTML = "";

    //for (var key in cardContent) {
    //    domTextItem = document.createElement('div');
    //    domKeySpan = document.createElement('span');
    //    domValInput = document.createElement('input');

    //    domTextItem.className = 'cTextItem';

    //    domKeySpan.className = 'cTextKey';
    //    domKeySpan.innerText = key;

    //    domValInput.className = 'cTextValue';
    //    domValInput.setAttribute('readonly', 'readonly');
    //    domValInput.value = cardContent[key];

    //    domTextItem.appendChild(domKeySpan);
    //    domTextItem.appendChild(domValInput);
    //    domTextArea.appendChild(domTextItem);
    //}
  }

  //function clrTextInfo() {
  //  document.getElementById("divTextArea").innerHTML = "";
  //}

  function setConnBtnValue() {
    if (bConnected) {
      document.getElementById("connection").value = strDisconnect;
    } else {
      document.getElementById("connection").value = strConnect;
    }
  }

  /* Check which images are included in the image data sent by the background and display them on the page */
  function displayImages(images) {
    tryDisplayImage(images, "White", "imageDisplay");
    //tryDisplayImage(images, "IR", "imageIR");
    //tryDisplayImage(images, "UV", "imageUV");
    //tryDisplayImage(images, "OcrHead", "imageOcrHead");
    //tryDisplayImage(images, "ChipHead", "imageChipHead");
    //tryDisplayImage(images, "SidHead", "imageChipHead");
  }

  function tryDisplayImage(images, imageName, domId) {
    if (images.hasOwnProperty(imageName)) {
      document.getElementById(domId).src = images[imageName];

      if (bigImageEmpty) {
        document.getElementById("imageDisplay").src = images[imageName];
        bigImageEmpty = false;
      }
    }
  }

  /* Select an image to zoom in */
  function showImage(domId) {
    document.getElementById("imageDisplay").src = document.getElementById(domId).src;
  }
</script>
</html>
