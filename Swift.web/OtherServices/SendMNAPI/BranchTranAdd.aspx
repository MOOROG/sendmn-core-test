<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BranchTranAdd.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.BranchTranAdd" %>

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
      $('.inOutType').change(function (e) {
        var selectedOption = $('#<%=inOut.ClientID %> option:selected').val();
        if (selectedOption == "send") {
          $(this).css("background-color", "#00FF59");
          $('#senLbl').hide();
          $('#recLbl').show();
          $('#senfLbl').hide();
          $('#recfLbl').show();
          $('#senCurLbl').hide();
          $('#recCurLbl').show();
          $('#senAmountLbl').hide();
          $('#recAmountLbl').show();
          $('#gaveAmountLbl').hide();
          $('#tookAmountLbl').show();
          $('#senderLbl').hide();
          $('#receiverLbl').show();
          $('#senderFLbl').hide();
          $('#receiverFLbl').show();
        } else {
          $(this).css("background-color", "#FF7000");
          $('#senLbl').show();
          $('#recLbl').hide();
          $('#senfLbl').show();
          $('#recfLbl').hide();
          $('#senCurLbl').show();
          $('#recCurLbl').hide();
          $('#senAmountLbl').show();
          $('#recAmountLbl').hide();
          $('#gaveAmountLbl').show();
          $('#tookAmountLbl').hide();
          $('#senderLbl').show();
          $('#receiverLbl').hide();
          $('#senderFLbl').show();
          $('#receiverFLbl').hide();
        }
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
                  <li><a href="BranchTransaction.aspx">Branch Transaction</a></li>
                  <li class="active"><a href="#">Register Branch Transaction</a></li>
                </ol>
              </div>
            </div>
          </div>
          <input type="hidden" id="hidCusid" runat="server" />
          <div class="row" id="receivedTransaction" runat="server">
            <div class="col-md-12">
              <div class="panel panel-default recent-activites">
                <div class="panel-heading">
                  <h4 class="panel-title">Register Receiving /Sending Transaction</h4>
                </div>
                <div class="panel-body">
                  <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                    <ContentTemplate>
                      <div class="row">
                        <div class="col-lg-4 col-md-6 form-group">
                          <label class="control-label" for="lastname">Төрөл:<span style="color: red;">*</span></label>
                          <asp:DropDownList ID="inOut" runat="server" CssClass="form-control inOutType">
                            <asp:ListItem Text="Receiving" Value="receive" Selected="True" style="color: blue"></asp:ListItem>
                            <asp:ListItem Text="Sending" Value="send"></asp:ListItem>
                          </asp:DropDownList>
                        </div>
                        <div class="col-lg-4 col-md-6 form-group">
                          <label class="control-label" for="lastname">Систем:<span style="color: red;">*</span></label>
                          <asp:DropDownList ID="systemName" runat="server" CssClass="form-control">
                            <asp:ListItem Text="BD2 Contact" Value="BD2" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="BD5 Ria" Value="BD5"></asp:ListItem>
                            <asp:ListItem Text="S1 Unistream" Value="S1"></asp:ListItem>
                            <asp:ListItem Text="S2 Contact" Value="S2"></asp:ListItem>
                            <asp:ListItem Text="S5" Value="S5"></asp:ListItem>
                            <asp:ListItem Text="Korona Pay" Value="KoronaPay"></asp:ListItem>
                            <asp:ListItem Text="BPremit" Value="BPremit"></asp:ListItem>
                          </asp:DropDownList>
                        </div>
                        <div class="col-lg-4 col-md-6 form-group">
                          <label class="control-label" for="firstname">Гуйвуулгын код:<span style="color: red;">*</span></label>
                          <asp:TextBox ID="controlNumber" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 form-group">
                          <label class="control-label" id="senLbl">Хүлээн авагч овог:<span style="color: red;">*</span></label>
                          <label class="control-label" id="recLbl" hidden="hidden" style="color:blue">Илгээгч овог:<span style="color: red;">*</span></label>
                          <asp:TextBox ID="recSendLastname" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 form-group">
                          <label class="control-label" id="senfLbl">Хүлээн авагч нэр:<span style="color: red;">*</span></label>
                          <label class="control-label" id="recfLbl" hidden="hidden" style="color: blue">Илгээгч нэр:<span style="color: red;">*</span></label>
                          <asp:TextBox ID="recSendName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-6 form-group">
                          <label class="control-label" id="senCurLbl">Ирсэн валют:</label>
                          <label class="control-label" id="recCurLbl" hidden="hidden" style="color: blue">Илгээх валют:</label>
                          <asp:DropDownList ID="receivedCurrency" runat="server" CssClass="form-control">
                            <asp:ListItem Text="EUR" Value="EUR" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="MNT" Value="MNT"></asp:ListItem>
                            <asp:ListItem Text="RUB" Value="RUB"></asp:ListItem>
                            <asp:ListItem Text="USD" Value="USD"></asp:ListItem>
                          </asp:DropDownList>
                        </div>
                        <div class="col-lg-2 col-md-6 form-group">
                          <label class="control-label" id="senAmountLbl">Ирсэн дүн:</label>
                          <label class="control-label" id="recAmountLbl" hidden="hidden" style="color: blue">Илгээх дүн:</label>
                          <asp:TextBox ID="receivedAmount" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-3 form-group">
                          <label class="control-label" for="address">Үйлчилгээний хураамж / Шимтгэл:</label>
                          <asp:TextBox ID="serviceFee" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-3 form-group">
                          <label class="control-label" for="addressDistrict">Ханш:</label>
                          <asp:TextBox ID="rate" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="address">Хүлээлгэн өгсөн валют:</label>
                          <asp:DropDownList ID="gaveCurrency" runat="server" CssClass="form-control">
                            <asp:ListItem Text="EUR" Value="EUR" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="MNT" Value="MNT"></asp:ListItem>
                            <asp:ListItem Text="RUB" Value="RUB"></asp:ListItem>
                            <asp:ListItem Text="USD" Value="USD"></asp:ListItem>
                          </asp:DropDownList>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="dateofbirth">Хүлээлгэн өгсөн дүн:</label>
                          <asp:TextBox ID="gaveAmount" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="address">Гүйлгээний Төрөл:</label>
                          <asp:TextBox ID="tranType" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" id="gaveAmountLbl">Олгосон төгрөг:</label>
                          <label class="control-label" id="tookAmountLbl" hidden="hidden" style="color: blue">Авсан төгрөг:</label>
                          <asp:TextBox ID="gaveTookAmount" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" id="senderLbl">Илгээгч овог:</label>
                          <label class="control-label" id="receiverLbl" hidden="hidden" style="color: blue">Хүлээн авагч овог:</label>
                          <asp:TextBox ID="sendRecLastName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" id="senderFLbl">Илгээгч нэр:</label>
                          <label class="control-label" id="receiverFLbl" hidden="hidden" style="color: blue">Хүлээн авагч нэр:</label>
                          <asp:TextBox ID="sendRecName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <label class="control-label" for="address">Илгээсэн улс:</label>
                          <asp:TextBox ID="country" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                      </div>
                    </ContentTemplate>
                  </asp:UpdatePanel>
                  <div class="row">
                    <div class="col-lg-12 form-group">
                      <asp:Button ID="btnRegister" runat="server" Text="Submit" CssClass="btn btn-primary m-t-25" OnClick="btnRegister_Click"/>
                    </div>
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

