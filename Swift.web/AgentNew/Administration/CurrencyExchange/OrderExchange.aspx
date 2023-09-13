<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OrderExchange.aspx.cs" Inherits="Swift.web.AgentNew.Administration.CurrencyExchange.OrderExchange" %>

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

  .onlyDiv {
    pointer-events: none !important;
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
        <asp:TextBox ID="orderId" runat="server" CssClass="form-control hidden"></asp:TextBox>

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
                    <div class="child onlyDiv">
                      <div class="form-group">
                        <label class="control-label" for="firstname">
                          Firstname
                        </label>
                        <asp:TextBox ID="firstname" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>
                    <div class="child onlyDiv">
                      <div class="form-group">
                        <label class="control-label" for="lastname">
                          Middlename
                        </label>
                        <asp:TextBox ID="middleName" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>
                    <div class="child onlyDiv">
                      <div class="form-group">
                        <label class="control-label" for="lastname">
                          Lastname
                        </label>
                        <asp:TextBox ID="lastname" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>
                    <div class="child onlyDiv">
                      <div class="form-group">
                        <label class="control-label">
                          <b>Passport Number</b>
                        </label>
                        <asp:TextBox ID="rd" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>
                    <div class="child onlyDiv">
                      <div class="form-group">
                        <label class="control-label" for="mobileNum">
                          Telephone
                        </label>
                        <asp:TextBox ID="mobileNum" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>
                    <div class="child onlyDiv">
                      <div class="form-group">
                        <label class="control-label" for="accountNumber">
                          Account Number
                        </label>
                        <asp:TextBox ID="accountNumber" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>
                    <div class="child onlyDiv">
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

                    <div class="child onlyDiv">
                      <div class="input-group">
                        <div class="input-group-addon currency-addon">
                          <span>Rate/Ханш:</span>
                        </div>
                        <asp:TextBox ID="customerRate" Placeholder="Rate" runat="server" CssClass="form-control hidden"></asp:TextBox>
                        <asp:TextBox ID="rateView" Placeholder="Rate" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                    </div>

                    <div class="child amount onlyDiv">
                      <div class="input-group accDiv">
                        <div class="input-group-addon currency-addon">&nbsp; Acc - MNT </div>
                        <input type="text" class="form-control currency-amount accAmount" /><div class="input-group-addon">₮</div>
                      </div>
                    </div>

                    <div class="child onlyDiv">
                      <div class="acc1">
                      </div>
                      <div class="note2">
                      </div>
                    </div>
                    <div class="child">
                      <div class="form-group" style="margin: 250px 0 0 40%;">
                        <input type="button" value="Ok" id="addNew" runat="server" class="btn btn-primary"
                          onclick="CheckFormValidation();" target="_blank" />
                      </div>
                    </div>
                    <div class="child onlyDiv">
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

  <div id="invoice-POS">
    <center>
      <h2>SENDMN NBFI LLC</h2>
    </center>
    <p>
      203-2 c/c section, passenger terminal,<br />
      1st floor, Chinggis Khaan International Airport,<br />
      Sergelen soum, 41090, Tuv province, Mongolia.<br />
      <br />
      Phone   : 7000-0909
    </p>
    <p>_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _</p>
    <div id="bot">
      <div style="width: 50%; float: left">
        <p>Date:</p>
        <p>Rec ID:</p>
        <p>_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ </p>
        <p>Received Cash:</p>
        <p>Rate:</p>
        <p>Paid Cash:</p>
        <p>_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ </p>
      </div>

      <div style="width: 50%; float: right">
        <p class="recDate">aa</p>
        <p class="recNumber">aa</p>
        <p>_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ </p>
        <p class="recAmnt1">aa</p>
        <p class="recRate">aa</p>
        <p class="recAmnt2">aa</p>
        <p>_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ </p>
      </div>
      <center>
        <p>Customer signature ............................................. </p>
      </center>
    </div>
  </div>
</body>
<script type="text/javascript">
  let oldAmnt = 0;
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
  $(document).ready(function () {
    window.onload = function () {
      document.getElementById("connection").value = strConnect;
      onConnection();
    }
    $(".accAmount").val($("#cAmountHide").val());
    $(".cashAmount2").val($("#pAmountHide").val());
    $("#invoice-POS").hide();
    $("#currency2").val($("#pCurrencyHide").val());
    jsDataChange($("#pCurrencyHide").val());
    balanceTable(1, 'mntTCA', 'MNT')
    balanceTable(2, 'other', $("#pCurrencyHide").val());
    $("#currency2").attr('disabled', true);
    $(".symbol2").text($("#currency2 option:selected").data("symbol"));


    var number = {};
    let cur = $("#pCurrencyHide").val();
    let amount = unformatNumber($("#pAmountHide").val());
    $.each(jsonData, function (index, value) {
      if (value.id == cur) {
        let entry = value.name;
        $("." + cur + entry).val('');
        if (amount / entry >= 1) {
          number[entry] = Math.floor(amount / entry);
          if (number[entry] > 0) {
            $("." + cur + value.name).val(number[entry]);
          }
          amount = amount - (entry * number[entry]);
        }
      }
    })


  })

  function jsDataChange(val) {
    $(".note2").html('');
    $.each(jsonData, function (index, value) {
      if (value.id == val) {
        $(".note2").append('<div class="input-group"><div class="input-group-addon currency-addon">' + value.name + '</div>' +
          '<input type="text" class="form-control ' + val + '-amount ' + val + value.name + '" style="width:100px" /></div > ');
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

  function unformatNumber(n) {
    if (n == undefined || n == '')
      return 0;
    return parseFloat(n.toString().replace(/[^0-9\.-]+/g, ""));
  }

  let curSum = 0;
  function CheckFormValidation() {
    curSum = 0;
    $.each(jsonData, function (index, value) {
      if (value.id == $("#pCurrencyHide").val()) {
        curSum = curSum + (unformatNumber($("." + $("#pCurrencyHide").val() + value.name).val()) * value.name);
      }
    })
    if (unformatNumber($(".cashAmount2").val()) != curSum) {
      alert('Арилжааны дүн таарахгүй байна')
      return false;
    }
    if (window.confirm("Do you really want to leave?")) {
      CheckFormSubmit();
      return true;
    }
  }

  function CheckFormSubmit() {
    let curVal = "";
    $.each(jsonData, function (index, value) {
      if (value.id == $("#pCurrencyHide").val() && $("." + $("#pCurrencyHide").val() + value.name).val() != '') {
        if (curVal != "") {
          curVal = curVal + "," + value.name + ":" + $("." + $("#pCurrencyHide").val() + value.name).val();
        }
        else {
          curVal = value.name + ":" + $("." + $("#pCurrencyHide").val() + value.name).val();
        }
      }
    })
    var dt = {
      methodName: "add_Click",
      orderId: $("#orderId").val(),
      type: 'Sale',
      paymentMode: 'Account',
      firstName: $("#firstname").val(),
      middleName: $("#middleName").val(),
      lastName: $("#lastname").val(),
      rd: $("#rd").val(),
      mobile: $('#mobileNum').val(),
      accountNumber: $('#accountNumber').val(),
      cCur: 'MNT',
      pCur: $("#pCurrencyHide").val(),
      cashAmount1: unformatNumber($(".cashAmount1").val()),
      cashAmount2: unformatNumber($(".cashAmount2").val()),
      accAmount: unformatNumber($(".accAmount").val()),
      cRate: unformatNumber($("#cRate").val()),
      pRate: unformatNumber($("#rateView").val()),
      customerRate: unformatNumber($("#rateView").val()),
      mntVal: '',
      curVal: curVal
    }
    $.ajax({
      url: '<%= ResolveUrl("OrderExchange.aspx") %>',
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
        $(".recAmnt1").text(unformatNumber(dt.accAmount) + " " + dt.cCur);
        $(".recRate").text(dt.customerRate);
        $(".recAmnt2").text(dt.cashAmount2 + " " + dt.pCur);
        $("#invoice-POS").show();
        window.print();
        window.location.href = "/AgentNew/Administration/CurrencyExchange/ApprovedCurrencyOrderHistory.aspx";
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
            processNotify(jsonMsg); 256352672
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
        clrTextInfo();
        clrImages(true);
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
        clrTextInfo();
        clrImages(true);
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
      clrTextInfo()
      clrImages(true);
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

  function clrTextInfo() {
    document.getElementById("divTextArea").innerHTML = "";
  }

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
