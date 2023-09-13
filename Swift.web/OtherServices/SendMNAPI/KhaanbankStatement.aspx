<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="KhaanbankStatement.aspx.cs" Inherits="Swift.web.OtherServices.SendMNAPI.KhaanbankStatement" %>

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

  <script src="/ui/js/jquery.min.js" type="text/javascript"></script>
  <script src="/ui/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
  <script src="/js/Swift_grid.js" type="text/javascript"> </script>
  <script src="/js/functions.js" type="text/javascript"></script>
  <script src="/ui/js/jquery-ui.min.js" type="text/javascript"></script>
  <script src="/js/swift_autocomplete.js" type="text/javascript"></script>
  <script src="/js/swift_calendar.js" type="text/javascript"></script>
  <script src="/ui/js/pickers-init.js" type="text/javascript"></script>

  <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
  <script type="text/javascript">
    $(document).ready(function () {
      var tabName = $("[id*=hdnCurrentTab]").val() != "" ? $("[id*=hdnCurrentTab]").val() : "menu";
      $('#MainDiv a[href="#' + tabName + '"]').tab('show');
      $('ul.mineLi li').click(function (e) {
        $("[id*=hdnCurrentTab]").val($("a", this).attr('href').replace("#", ""));
        if ($("[id*=hdnCurrentTab]").val() == 'menu') {
          $('#menu').addClass('active');
          $('#menu1').removeClass('active');
          $('#menu2').removeClass('active');
          $('#menu3').removeClass('active');
          $('#menu4').removeClass('active');
          $('#menu5').removeClass('active');

        } else if ($("[id*=hdnCurrentTab]").val() == 'menu1') {
          $('#menu').removeClass('active');
          $('#menu2').removeClass('active');
          $('#menu1').addClass('active');
          $('#menu3').removeClass('active');
          $('#menu4').removeClass('active');
          $('#menu5').removeClass('active');

        } else if ($("[id*=hdnCurrentTab]").val() == 'menu3') {
          $('#menu3').addClass('active');
          $('#menu').removeClass('active');
          $('#menu2').removeClass('active');
          $('#menu1').removeClass('active');
          $('#menu4').removeClass('active');
          $('#menu5').removeClass('active');

        } else if ($("[id*=hdnCurrentTab]").val() == 'menu4') {
          $('#menu4').addClass('active');
          $('#menu').removeClass('active');
          $('#menu2').removeClass('active');
          $('#menu1').removeClass('active');
          $('#menu3').removeClass('active');
          $('#menu5').removeClass('active');

        } else if ($("[id*=hdnCurrentTab]").val() == 'menu2') {
          $('#menu1').removeClass('active');
          $('#menu').removeClass('active');
          $('#menu2').addClass('active');
          $('#menu3').removeClass('active');
          $('#menu4').removeClass('active');
          $('#menu5').removeClass('active');

        } else if ($("[id*=hdnCurrentTab]").val() == 'menu5') {
          $('#menu1').removeClass('active');
          $('#menu').removeClass('active');
          $('#menu5').addClass('active');
          $('#menu3').removeClass('active');
          $('#menu4').removeClass('active');
          $('#menu2').removeClass('active');
        }
      });
    });
    function CheckAccount() {
      var accs = $('#<%=accounts.ClientID%>').val();
      if (accs == "-1") {
        alert("Select account");
        return false;
      }
    }
    function TableSearch() {
      let input, filter, table, tr, td, i, textValue;
      console.log("INPUT");
      if (document.getElementById('searchInput').clientHeight > 0) {
        input = document.getElementById('searchInput');
        table = "stateGrid";
      }
      else if (document.getElementById('glmtTxtbox').clientHeight > 0) {
        input = document.getElementById('glmtTxtbox');
        table = "GlmtGrid";
      }
      else if (document.getElementById('stateSearchBox').clientHeight > 0) {
        input = document.getElementById('stateSearchBox');
        table = "grdJSON2Grid";
        }
      else if (document.getElementById('xacSearch').clientHeight > 0) {
          input = document.getElementById('xacSearch');
          table = "xacGrid";
        }
      else if (document.getElementById('TDBSearch').clientHeight > 0) {
          input = document.getElementById('TDBSearch');
          table = "TDBGrid";
      }
      console.log(input.value.toUpperCase());
      filter = input.value.toUpperCase();
      console.log(input);
      tr = document.querySelectorAll(`#${table} > tbody > tr`);
      for (let i = 1; i < tr.length; i++) {
        for (let x = 0; x < tr[i].children.length; x++) {
          td = tr[i].children[x];
          if (td) {
            textValue = td.textContent || td.innerText;
            if (textValue.toUpperCase().indexOf(filter) > -1) {
              tr[i].style.display = "";
              console.log(textValue);
              break;
            } else {
              tr[i].style.display = "none";
            }
          }
        }
      }
    }
    function ResetOptions() {
      console.log("RESSETING");
    }
  </script>
</head>
<body>
  <form id="form1" runat="server" class="col-md" enctype="multipart/form-data">
    <asp:HiddenField ID="hdnCurrentTab" runat="server" Value="menu" />
    <div class="page-wrapper">

      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <ol class="breadcrumb">
              <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <li><a onclick="return LoadModule('adminstration')">Administration</a></li>
              <li class="active"><a href="#">Khaan bank to Polaris</a></li>
            </ol>
          </div>
        </div>
      </div>
      <div class="report-tab" id="MainDiv" runat="server">
        <div class="listtabs">
          <ul class="nav nav-tabs mineLi" role="tablist" id="myTab">
            <li><a data-toggle="tab" href="#menu" aria-controls="menu" role="tab" onclick="">Khaan Statement</a></li>
            <li><a data-toggle="tab" href="#menu1" aria-controls="menu1" role="tab">Golomt Statement</a></li>
            <%--<li><a data-toggle="tab" href="#menu2" aria-controls="menu2" role="tab">Remaining Statement</a></li>--%>
            <li><a data-toggle="tab" href="#menu3" aria-controls="menu3" role="tab">Statebank Statement</a></li>
            <li><a data-toggle="tab" href="#menu4" aria-controls="menu4" role="tab">Xac bank Statement</a></li>
            <li><a data-toggle="tab" href="#menu5" aria-controls="menu5" role="tab">TDB Statement</a></li>
            <li><a data-toggle="tab" href="#menu6" aria-controls="menu6" role="tab">Transaction</a></li>

          </ul>
        </div>
        <!-- Tab panes -->
        <div class="tab-content">
            
          <div role="tabpanel" class="tab-pane active" id="menu">
            <div class="row-md">
              <div class="col">
                <div class="panel panel-default recent-activites">
                  <div class="panel-heading">
                    <h4 class="panel-title">Khaan bank statement</h4>
                  </div>
                  <div class="panel-body">
                    <div class="container-md">
                    <div class="row">
                      <div class="col-md-12">
                        <div class="col-md-5">
                          <div class="row">
                            <div class="col-md-5">
                              <div class="row form-group">
                                      <label class="col-md-4 control-label">Start date: </label>
                                      <div class="col-md-8">
                                        <asp:TextBox ID="khaanStDateStart" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                                      </div>
                              </div>
                              <div class="row form-group">
                                      <label class="col-md-4 control-label">End date: </label>
                                      <div class="col-md-8">
                                        <asp:TextBox ID="khaanStDateEnd" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                                      </div>
                              </div>
                            </div>
                            <div class="col-md-2"></div>
                            <div class="col-md-5">
                                  <div class="row-md form-group">
                                    <asp:DropDownList ID="accounts" runat="server" CssClass="form-control">
                                      <asp:ListItem Text="5163260456" Value="5163260456:17400001121004"></asp:ListItem>
                                      <asp:ListItem Text="5163322299" Value="5163322299:17400001121005"></asp:ListItem>
                                      <asp:ListItem Text="5176019572" Value="5176019572"></asp:ListItem>
                                      <asp:ListItem Text="5111730446" Value="5111730446"></asp:ListItem>
                                      <asp:ListItem Text="5163358601" Value="5163358601:107411210230000001" Selected="True"></asp:ListItem>
                                    </asp:DropDownList>
                                  </div>
                                  <div class="row-md form-group">
                                    <asp:Panel runat="server" DefaultButton="Button3">
                                      <asp:TextBox ID="khanpass" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                                      <asp:Button ID="Button3" runat="server" style="display:none" OnClick="getStatement_Click" />
                                    </asp:Panel>

                                  </div>
                            </div>
                          </div>
                          <div class="row">
                            <div class="container-md m-t-5">
                               <div class="col-md-5 col-centered">
                                  <asp:Button ID="getStatement" runat="server" Text="Get" CssClass="btn btn-primary btn-block" OnClientClick="CheckAccount();" OnClick="getStatement_Click" />
                                  <asp:Button ID="syncToPolaris" runat="server" Text="Sync to Polaris" CssClass="btn btn-primary m-t-25" OnClick="syncToPolaris_Click" Visible="false" />
                               </div>
                            </div>
                          </div>
                        </div>
                        <div class="col-md-1"></div>
                      <div class="col-md-3 form-group">
                          <div class="col-md">
						          <div class="row form-group">
							          <label for="mnt" class="col-md-3 col-form-label">Үлдэгдэл:</label>
							          <div class="col-md-6">
								          <asp:TextBox CssClass="pl-5" runat="server" class="form-control amount" Enabled="false" ID="balance"></asp:TextBox>
							          </div>
							          <div class="col-md-3"></div>
						          </div>
						          <div class="row form-group">
							          <label for="usd" class="col-md-3 col-form-label">Орсон:</label>
							          <div class="col-md-6">
								          <asp:TextBox CssClass="pl-5" runat="server" class="form-control amount" Enabled="false" ID="debit"></asp:TextBox>
							          </div>
							          <div class="col-md-3"></div>
						          </div>
						          <div class="row form-group">
							          <label for="cos" class="col-md-3 col-form-label">Гарсан:</label>
							          <div class="col-md-6">
								          <asp:TextBox CssClass="pl-5" runat="server" class="form-control amount" Enabled="false" ID="credit"></asp:TextBox>
							          </div>
							          <div class="col-md-3"></div>
						          </div>
					            </div>
                    </div>
                    <div class="col-md-3 form-group">
                        <asp:Label ID="totalCnt" Text="total" runat="server"></asp:Label>
                        <asp:Label ID="gme" Text="gme" runat="server"></asp:Label>
                        <asp:Label ID="gmoney" Text="gmoney" runat="server"></asp:Label>
                        <asp:Label ID="contact" Text="contact" runat="server"></asp:Label>
                        <asp:Label ID="hanpass" Text="hanpass" runat="server"></asp:Label>
                        <asp:Label ID="wallet" Text="wallet" runat="server"></asp:Label>
                        <asp:Label ID="shimtgel" Text="shimtgel" runat="server"></asp:Label>
                        <asp:Label ID="others" Text="others" runat="server"></asp:Label>
                      </div>
                        <%--<div class="col-md-4 form-group">
                          <div class="row form-group">
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Total:</label>
                              </div>
                              <div class="col-md">
                                <asp:TextBox ID="totalCnt" runat="server" Enabled="false" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Amount:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="totalAmount" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                          </div>
                          <div class="row form-group">
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">GME:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="gme" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Amount:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="gmeAmount" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                          </div>
                          <div class="row form-group">
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Gmoney:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="gmoney" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Amount:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="gmoneyAmount" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                          </div>
                          <div class="row form-group">
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Contact:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="contact" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Amount:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="contactAmount" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                          </div>
                          <div class="row form-group">
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Hanpass:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="hanpass" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Amount:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="hanpassAmount" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                          </div>
                          <div class="row form-group">
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Wallet:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="wallet" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Amount:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="walletAmount" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                          </div>
                          <div class="row form-group">
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Shimtgel:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="shimtgel" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Amount:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="shimtgelAmount" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                          </div>
                          <div class="row form-group">
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Others:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="others" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                            <div class="col-md-6">
                              <div class="col-md-3">
                                <label class="control-label">Amount:</label>
                              </div>
                              <div class="col-md-9">
                                <asp:TextBox ID="othersAmount" runat="server" class="form-control"></asp:TextBox>
                              </div>
                            </div>
                          </div>
                        </div>--%>
                    </div>
                    </div>
                    </div>
                    <div class="row-md-5 form-group">
                        <div class="col-md-1">
                          <asp:DropDownList AutoPostBack="true" OnSelectedIndexChanged="khaanPageSize_SelectedIndexChanged" ID="khaanPageSize" runat="server" CssClass="form-control">
                            <asp:ListItem Text="15"></asp:ListItem>
                            <asp:ListItem Text="30"></asp:ListItem>
                            <asp:ListItem Text="50"></asp:ListItem>
                            <asp:ListItem Text="100"></asp:ListItem>
                            <asp:ListItem Text="All"></asp:ListItem>
                          </asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                        </div>
                        <div class="col-md-1 text-right">
                            <label>Search:</label>
                        </div>
                        <div class="col-md-2">
                            <input type="text" id ="searchInput" class="form-control" onkeyup="TableSearch()"/>
                            <%--<asp:TextBox ID="filterBx" runat="server" Width="250px" CssClass="form-control" OnClientTextChange =""></asp:TextBox>--%>
                        </div>        
                        <%--<div class="col-md">
                            <asp:Button ID="srchValue" runat="server" Visible="true" OnClick="srchValue_Click" Text="Search" />
                        </div>   --%> 
                    </div>
                    <div class="row-md-5">
                      <div class="container-md">
                        <asp:GridView ID="stateGrid" runat="server" AutoGenerateColumns="false" GridLines="None" CssClass="table table-bordered table-condensed table-hover table-responsive table-striped" ShowHeaderWhenEmpty="true" OnSorting="khaanStGrid_Sorting" OnPageIndexChanging="stateGrid_PageIndexChanging" AllowPaging="true" AllowSorting="true" PageSize="15">
                          <PagerSettings Mode="NumericFirstLast" />
                          <PagerStyle CssClass="pagination-ys" />
                          <Columns>
                            <%--<asp:TemplateField HeaderText="Select" HeaderStyle-CssClass="text-center col-md-1"  ItemStyle-HorizontalAlign="Center">
                              <ItemTemplate>
                                <asp:CheckBox ID="cbSelect" CssClass="gridCB" runat="server"></asp:CheckBox>
                              </ItemTemplate>
                            </asp:TemplateField>--%>
                            <asp:BoundField SortExpression="amountMoneyFormat" DataField="amountMoneyFormat" HeaderText="Amount" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting" DataFormatString="{0:n}"/>
                            <asp:BoundField SortExpression="balanceMoneyFormat" DataField="balanceMoneyFormat" HeaderText="Account Balance" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting" DataFormatString="{0:n}"/>
                            <asp:BoundField SortExpression="description" DataField="description" HeaderText="Transaction description" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-3 sorting"/>
                            <asp:BoundField SortExpression="tranDate" DataField="tranDate" HeaderText="Transaction Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1 sorting"/>
                            <asp:BoundField SortExpression="journal" DataField="journal" HeaderText="Journal" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1 sorting"/>
                            <asp:BoundField SortExpression="relatedAccount" DataField="relatedAccount" HeaderText="Related Account" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1 sorting"/>

                            <%--<asp:BoundField DataField="time" HeaderText="Tran Time" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1" />--%>
                            <%--<asp:BoundField DataField="branch" HeaderText="Branch" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1" />--%>
                            <%--<asp:BoundField DataField="teller" HeaderText="Teller" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1" />--%>
                            <%--<asp:BoundField DataField="journal" HeaderText="Jr. Number" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1" />--%>
                            <%--<asp:BoundField DataField="code" HeaderText="Code" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1" />--%>
                            <%--<asp:BoundField DataField="dbOrCr" HeaderText="Debit or Credit" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2"/>--%>
                          </Columns>
                        </asp:GridView>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div role="tabpanel" class="tab-pane" id="menu1">
            <div class="row-md">
              <div class="col-md">
                <div class="panel panel-default recent-activites">
                  <div class="panel-heading">
                    <h4 class="panel-title">Golomt bank statement</h4>
                  </div>
                  <div class="panel-body">
                    <div class="container-md">
                      <div class="row">
                        <div class="col-md-12">
                          <div class="col-md-5">
                            <div class="row">
                              <div class="col-md-5">
                                <div class="row form-group">
                                  <label class="col-md-4 control-label">Start date: </label>
                                  <div class="col-md-8">
                                    <asp:TextBox ID="TextBox2" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                                  </div>
                                </div>
                                <div class="row form-group">
                                  <label class="col-md-4 control-label">End date: </label>
                                  <div class="col-md-8">
                                    <asp:TextBox ID="glmtDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                                  </div>
                                </div>
                              </div>
                          <div class="col-md-2"></div>
                          <div class="col-md-5">
                            <div class="row-md form-group">
                                <asp:DropDownList ID="glmtAccount" runat="server" CssClass="form-control">
                                  <asp:ListItem Text="1605129074" Value="5163260456:17400001121004"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="row-md form-group">
                              <asp:Panel runat="server" DefaultButton="Button10">
                                <asp:TextBox ID="glmtpass" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                                <asp:Button ID="Button10" runat="server" style="display:none" OnClick="golomtStatement_Click" />
                              </asp:Panel>
                            </div>
                          </div>
                        </div>
                        <div class="row">
                            <div class="container-md m-t-5">
                              <div class="col-md-5 col-centered">
                                <asp:Button ID="golomtStatement" runat="server" Text="Get" CssClass="btn btn-primary btn-block" onClientClick="CheckAccount();" OnClick="golomtStatement_Click" />
                            </div>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-1"></div>
                        <div class="col-md-3 form-group">
                            <div class="col-md">
                                <div class="row form-group">
                                    <label for="mnt" class="col-md-3 col-form-label">Үлдэгдэл:</label>
                                    <div class="col-md-6">
                                        <asp:TextBox CssClass="pl-5" runat="server" class="form-control amount" ID="glmtBalance" Enabled="false"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3"></div>
                                </div>
                                <div class="row form-group">
                                    <label for="usd" class="col-md-3 col-form-label">Орсон:</label>
                                    <div class="col-md-6">
                                        <asp:TextBox CssClass="pl-5" runat="server" class="form-control amount" ID="glmtDebit" Enabled="false"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3"></div>
                                </div>
                                <div class="row form-group">
                                    <label for="cos" class="col-md-3 col-form-label">Гарсан:</label>
                                    <div class="col-md-6">
                                        <asp:TextBox CssClass="pl-5" runat="server" class="form-control amount" ID="glmtCredit" Enabled="false"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3"></div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <asp:Label ID="Label1" Text="total" runat="server"></asp:Label>
                          <asp:Label ID="Label2" Text="gme" runat="server"></asp:Label>
                          <asp:Label ID="Label3" Text="gmoney" runat="server"></asp:Label>
                          <asp:Label ID="Label4" Text="contact" runat="server"></asp:Label>
                          <asp:Label ID="Label5" Text="hanpass" runat="server"></asp:Label>
                          <asp:Label ID="Label6" Text="wallet" runat="server"></asp:Label>
                          <asp:Label ID="Label7" Text="shimtgel" runat="server"></asp:Label>
                          <asp:Label ID="Label8" Text="others" runat="server"></asp:Label>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="row-md-5 form-group">
                    <div class="col-md-1">
                      <asp:DropDownList AutoPostBack="True" OnSelectedIndexChanged="golomtPageSize_SelectedIndexChanged" ID="golomtPageSize" runat="server" CssClass="form-control">
                        <asp:ListItem Text="15"></asp:ListItem>
                        <asp:ListItem Text="30"></asp:ListItem>
                        <asp:ListItem Text="50"></asp:ListItem>
                        <asp:ListItem Text="100"></asp:ListItem>
                        <asp:ListItem Text="All"></asp:ListItem>
                      </asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                    </div>
                    <div class="col-md-1 text-right">
                        <label>Search: </label>
                    </div>
                    <div class="col-md-2">
                      <input type="text" id="glmtTxtbox" class="form-control" onkeyup="TableSearch()"/>
                    </div>        
                  </div>
                  <div class="row-md-5">
                      <div class="container-md">
                        <asp:GridView ID="GlmtGrid" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-condensed table-hover table-responsive table-striped" ShowHeaderWhenEmpty="true" AllowPaging="true" AllowSorting="true" PageSize="15" OnSorting="GlmtGrid_Sorting" OnPageIndexChanging="GlmtGrid_PageIndexChanging">
                          <PagerSettings Mode="NumericFirstLast" />
                          <PagerStyle CssClass="pagination-ys" />
                          <Columns>
                            <asp:BoundField SortExpression="amountMoneyFormat" DataField="amountMoneyFormat" HeaderText="Amount" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting"/>
                            <asp:BoundField SortExpression="ntrybalance" DataField="ntrybalance" HeaderText="Account Balance" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting"/>
                            <asp:BoundField SortExpression="txAddInf" DataField="txAddInf" HeaderText="Transaction Description" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-3 sorting"/>
                            <asp:BoundField SortExpression="txPostedDt" DataField="txPostedDt" HeaderText="Transaction Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting" />
                            <asp:BoundField SortExpression="ntryRef" DataField="ntryRef" HeaderText="Journal" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1 sorting"/>

                          </Columns>
                        </asp:GridView>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div role="tabpanel" class="tab-pane" id="menu2">
            <div class="row-md">
              <div class="col-md">
                <div class="panel panel-default recent-activites">
                  <div class="panel-heading">
                    <h4 class="panel-title">Remaining statement</h4>
                  </div>
                  <div class="panel-body">
                    <div class="row">
                      <div class="col-lg-3 col-md-6 form-group">
                        <label>DATE: </label>
                        <asp:TextBox ID="remDtBx" runat="server"></asp:TextBox>
                      </div>
                      <div class="col-lg-3 col-md-6 form-group">
                        <asp:DropDownList ID="AccountList" runat="server" CssClass="form-control">
                          <asp:ListItem Text="5163260456" Value="5163260456"></asp:ListItem>
                          <asp:ListItem Text="5163322299" Value="5163322299"></asp:ListItem>
                          <asp:ListItem Text="5176019572" Value="5176019572"></asp:ListItem>
                          <asp:ListItem Text="1605129074" Value="1605129074"></asp:ListItem>
                          <asp:ListItem Text="5163358601" Value="5163358601" Selected="True"></asp:ListItem>
                        </asp:DropDownList>
                      </div>
                      <div class="col-lg-3 col-md-6 form-group">
                        <asp:Button ID="remainBtn" runat="server" Text="Get" CssClass="btn btn-primary m-t-25" OnClick="remainBtn_Click" />
                      </div>
                    </div>
                    <div class="row">
                      <div class="col-md-6 form-group">
                        <label>Search Key: </label>
                        <asp:TextBox ID="remTextbx" runat="server" Width="400px"></asp:TextBox>
                        <asp:Button ID="remSearchbtn" runat="server" OnClick="srchValue_Click" Text="Search" />
                      </div>
                    </div>
                    <div class="row">
                      <asp:GridView ID="remainGrid" runat="server" AutoGenerateColumns="false" Width="100%">
                        <Columns>
                          <asp:BoundField DataField="Account" HeaderText="&nbsp;Account Number&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                          <asp:BoundField DataField="Description" HeaderText="&nbsp;&nbsp;Description&nbsp;&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                          <asp:BoundField DataField="TranDate" HeaderText="&nbsp;Tran Date&nbsp;" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                        </Columns>
                      </asp:GridView>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div role="tabpanel" class="tab-pane" id="menu3">
            <div class="row-md">
              <div class="col-md">
                <div class="panel panel-default recent-activites">
                  <div class="panel-heading">
                    <h4 class="panel-title">State bank statement</h4>
                  </div>
                  <div class="panel-body">
                    <div class="container-md">
                    <div class="row">
                      <div class="col-md-12">
                        <div class="col-md-5">
                          <div class="row">
                            <div class="col-md-5">
                              <div class="row form-group">
                                      <label class="col-md-4 control-label">Start date: </label>
                                      <div class="col-md-8">
                                        <asp:TextBox ID="stateStDateStart" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                                      </div>
                              </div>
                              <div class="row form-group">
                                      <label class="col-md-4 control-label">End date: </label>
                                      <div class="col-md-8">
                                        <asp:TextBox ID="stateStDateEnd" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                                      </div>
                              </div>
                            </div>
                            <div class="col-md-2"></div>
                            <div class="col-md-5">
                                  <div class="row-md form-group">
                                    <asp:DropDownList ID="DropDownList1" runat="server" CssClass="form-control">
                                    </asp:DropDownList>
                                  </div>
                                  <div class="row-md form-group">
                                    <asp:Panel runat="server" DefaultButton="Button2">
                                      <asp:TextBox ID="statePwd" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                                      <asp:Button ID="Button2" runat="server" style="display:none" OnClick="stateStatement_Click" />
                                    </asp:Panel>

                                  </div>
                            </div>
                          </div>
                          <div class="row">
                            <div class="container-md m-t-5">
                                <div class="col-md-5 col-centered">
                                  <asp:Button ID="stateStatement" runat="server" Text="Get" CssClass="btn btn-primary btn-block" OnClientClick="CheckAccount();" OnClick="stateStatement_Click" />
                                  <asp:Button ID="Button1" runat="server" Text="Sync to Polaris" CssClass="btn btn-primary m-t-25" OnClick="syncToPolaris_Click" Visible="false" />
                                </div>
                            </div>
                          </div>
                        </div>
                        <div class="col-md-1 m-auto"></div>
                        <div class="col-md-3 form-group">
                          <div class="col-md">
                            <div class="row form-group">
                              <label for="mnt" class="col-md-3 col-form-label"
                                >Үлдэгдэл:</label
                              >
                              <div class="col-md-6">
                                <asp:TextBox
                                  CssClass="pl-5"
                                  runat="server"
                                  class="form-control amount"
                                  ID="stateBalance"
                                  Enabled="false"
                                ></asp:TextBox>
                              </div>
                              <div class="col-md-3"></div>
                            </div>
                            <div class="row form-group">
                              <label for="usd" class="col-md-3 col-form-label"
                                >Орсон:</label
                              >
                              <div class="col-md-6">
                                <asp:TextBox
                                  CssClass="pl-5"
                                  runat="server"
                                  class="form-control amount"
                                  ID="stateDebit"
                                  Enabled="false"
                                ></asp:TextBox>
                              </div>
                              <div class="col-md-3"></div>
                            </div>
                            <div class="row form-group">
                              <label for="cos" class="col-md-3 col-form-label"
                                >Гарсан:</label
                              >
                              <div class="col-md-6">
                                <asp:TextBox
                                  CssClass="pl-5"
                                  runat="server"
                                  class="form-control amount"
                                  ID="stateCredit"
                                  Enabled="false"
                                ></asp:TextBox>
                              </div>
                              <div class="col-md-3"></div>
                            </div>
                          </div>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                            <asp:Label
                            ID="Label9"
                            Text="total"
                            runat="server"
                          ></asp:Label>
                          <asp:Label ID="Label10" Text="gme" runat="server"></asp:Label>
                          <asp:Label ID="Label11" Text="gmoney" runat="server"></asp:Label>
                          <asp:Label
                            ID="Label12"
                            Text="contact"
                            runat="server"
                          ></asp:Label>
                          <asp:Label
                            ID="Label13"
                            Text="hanpass"
                            runat="server"
                          ></asp:Label>
                          <asp:Label ID="Label14" Text="wallet" runat="server"></asp:Label>
                          <asp:Label
                            ID="Label15"
                            Text="shimtgel"
                            runat="server"
                          ></asp:Label>
                          <asp:Label ID="Label16" Text="others" runat="server"></asp:Label>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="row-md-5 form-group">
                    <div class="col-md-1">
                      <asp:DropDownList AutoPostBack="True" OnSelectedIndexChanged="statePageSize_SelectedIndexChanged" ID="statePageSize" runat="server" CssClass="form-control">
                        <asp:ListItem Text="15"></asp:ListItem>
                        <asp:ListItem Text="30"></asp:ListItem>
                        <asp:ListItem Text="50"></asp:ListItem>
                        <asp:ListItem Text="100"></asp:ListItem>
                        <asp:ListItem Text="All"></asp:ListItem>
                      </asp:DropDownList>
                    </div>
                    <div class="col-md-6"></div>
                    <div class="col-md-1 text-right">
                      <label>Search:</label>
                    </div>
                    <div class="col-md-2">
                      <input
                        type="text"
                        id="stateSearchBox"
                        class="form-control"
                        onkeyup="TableSearch()"
                      />
                      <%--<asp:TextBox
                        ID="stateSearchBox"
                        runat="server"
                        Width="250px"
                        CssClass="form-control"
                        OnClientTextChange=""
                      >
                      </asp:TextBox
                      >--%>
                    </div>
                    <%--
                    <div class="col-md">
                      <asp:Button
                        ID="srchValue"
                        runat="server"
                        Visible="true"
                        OnClick="srchValue_Click"
                        Text="Search"
                      />
                    </div>
                    --%>
                  </div>
                  <div class="row-md-5">
                    <div class="container-md">
                    <asp:GridView
                      ID="grdJSON2Grid"
                      runat="server"
                          AutoGenerateColumns="false"
                          GridLines="None"
                          CssClass="table table-bordered table-condensed table-hover table-responsive table-striped" 
                          ShowHeaderWhenEmpty="true"
                          AllowPaging="true"
                          AllowSorting="true"
                          PageSize="15" 
                          OnPageIndexChanging="stateStGrid_PageIndexChanging" OnSorting="stateStGrid_Sorting"
                        >
                        <PagerSettings Mode="NumericFirstLast" />
                        <PagerStyle CssClass="pagination-ys" />
                          <Columns>
                            <%--<asp:TemplateField HeaderText="Select" HeaderStyle-CssClass="text-center col-md-1"  ItemStyle-HorizontalAlign="Center">
                              <ItemTemplate>
                                <asp:CheckBox
                                  ID="stateCbSelect"
                                  CssClass="gridCB"
                                  runat="server"
                                ></asp:CheckBox>
                              </ItemTemplate>
                            </asp:TemplateField>--%>
                            <%--<asp:BoundField DataField="JrItemNo" HeaderText="Jr. Item No </a> <i class='fa fa-fw fa-sort'></i>" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1" HtmlEncode="false"/>--%>
                            <%--<asp:BoundField DataField="AcntNo" HeaderText="Account No </a> <i class='fa fa-fw fa-sort'></i>" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1" HtmlEncode="false"/>--%>
                            <%--<asp:BoundField DataField="CurCode" HeaderText="CurCode </a> <i class='fa fa-fw fa-sort'></i>" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1" HtmlEncode="false"/>--%>
                            <%--<asp:BoundField DataField="TxnType" HeaderText="Tran Type </a> <i class='fa fa-fw fa-sort'></i>" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1" HtmlEncode="false"/>--%>
                            <%--<asp:BoundField DataField="TxnType" HeaderText="Tran Type </a> <i class='fa fa-fw fa-sort'></i>" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1" HtmlEncode="false"/>--%>
                            <%--<asp:BoundField DataField="Id" HeaderText="#" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1" HtmlEncode="false"/>--%>
                            <%--<asp:BoundField SortExpression="Amount" DataField="Amount" HeaderText="Amount" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting" DataFormatString="{0:n}"/>--%>
                            <%--<asp:BoundField DataField="Rate" HeaderText="Rate" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1" />--%>
                            <%--<asp:BoundField SortExpression="Balance" DataField="Balance" HeaderText="Account Balance" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting" DataFormatString="{0:n}"/>--%>
                            <%--<asp:BoundField SortExpression="TxnDesc" DataField="TxnDesc" HeaderText="Transaction description" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-3 sorting"/>--%>
                            <%--<asp:BoundField SortExpression="TxnDate" DataField="TxnDate" HeaderText="Transaction Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting"/>--%>
                            <%--<asp:BoundField SortExpression="ContAcntNo" DataField="ContAcntNo" HeaderText="ContAcntNo" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1 sorting"/>--%>
                            <%--<asp:BoundField SortExpression="JrNo" DataField="JrNo" HeaderText="Journal" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1 sorting"/>--%>
                            <%--<asp:BoundField DataField="ContBankCode" HeaderText="ContBankCode </a> <i class='fa fa-fw fa-sort'></i>" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2" HtmlEncode="false"/>--%>
                            <%--<asp:BoundField DataField="Location" HeaderText="Location" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2"/>--%>
                            <%--<asp:BoundField DataField="BranchNo" HeaderText="Branch No </a> <i class='fa fa-fw fa-sort'></i>" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2" HtmlEncode="false"/>--%>
                            <%--<asp:BoundField DataField="Corr" HeaderText="Corr" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2"/>--%>

                          </Columns>
                        </asp:GridView>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div role="tabpanel" class="tab-pane active" id="menu4">
            <div class="row-md">
                <div class="col">
                  <div class="panel panel-default recent-activites">
                    <div class="panel-heading">
                      <h4 class="panel-title">Khaan bank statement</h4>
                    </div>
                    <div class="panel-body">
                      <div class="container-md">
                        <div class="row">
                          <div class="col-md-12">
                            <div class="col-md-5">
                              <div class="row">
                                <div class="col-md-5">
                                  <div class="row form-group">
                                    <label class="col-md-4 control-label">Start date: </label>
                                    <div class="col-md-8">
                                      <asp:TextBox ID="xacDateFr" runat="server" TextMode="Date" CssClass="form-control">
                                      </asp:TextBox>
                                    </div>
                                  </div>
                                  <div class="row form-group">
                                    <label class="col-md-4 control-label">End date: </label>
                                    <div class="col-md-8">
                                      <asp:TextBox ID="xacDateTo" runat="server" TextMode="Date" CssClass="form-control">
                                      </asp:TextBox>
                                    </div>
                                  </div>
                                </div>
                                <div class="col-md-2"></div>
                                <div class="col-md-5">
                                  <div class="row-md form-group">
                                    <asp:DropDownList ID="xacBankAccountList" runat="server" CssClass="form-control">
                                      <asp:ListItem Text="5163260456" Value="5163260456:17400001121004"></asp:ListItem>
                                      <asp:ListItem Text="5163322299" Value="5163322299:17400001121005"></asp:ListItem>
                                      <asp:ListItem Text="5176019572" Value="5176019572"></asp:ListItem>
                                      <asp:ListItem Text="5163358601" Value="5163358601:107411210230000001" Selected="True">
                                      </asp:ListItem>
                                    </asp:DropDownList>
                                  </div>
                                  <div class="row-md form-group">
                                    <asp:Panel runat="server" DefaultButton="xacStatement">
                                      <asp:TextBox ID="xacPassword" runat="server" TextMode="Password" CssClass="form-control">
                                      </asp:TextBox>
                                      <asp:Button ID="xacStatement" runat="server" style="display:none" OnClick="xacStatement_Click" />
                                    </asp:Panel>
                                  </div>
                                </div>
                              </div>
                              <div class="row">
                                <div class="container-md m-t-5">
                                  <div class="col-md-5 col-centered">
                                    <asp:Button ID="xacStatementButton" runat="server" Text="Get" CssClass="btn btn-primary btn-block"
                                      OnClientClick="CheckAccount();" OnClick="xacStatement_Click" />
                                    <asp:Button ID="xacStatementSyncToPolaris" runat="server" Text="Sync to Polaris"
                                      CssClass="btn btn-primary m-t-25" OnClick="syncToPolaris_Click" Visible="false" />
                                  </div>
                                </div>
                              </div>
                            </div>
                            <div class="col-md-1"></div>
                            <div class="col-md-3 form-group">
                              <div class="col-md">
                                <div class="row form-group">
                                  <label for="mnt" class="col-md-3 col-form-label">Үлдэгдэл:</label>
                                  <div class="col-md-6">
                                    <asp:TextBox CssClass="pl-5" runat="server" class="form-control amount" Enabled="false"
                                      ID="xacAmount"></asp:TextBox>
                                  </div>
                                  <div class="col-md-3"></div>
                                </div>
                                <div class="row form-group">
                                  <label for="usd" class="col-md-3 col-form-label">Орсон:</label>
                                  <div class="col-md-6">
                                    <asp:TextBox CssClass="pl-5" runat="server" class="form-control amount" Enabled="false"
                                      ID="xacDebit"></asp:TextBox>
                                  </div>
                                  <div class="col-md-3"></div>
                                </div>
                                <div class="row form-group">
                                  <label for="cos" class="col-md-3 col-form-label">Гарсан:</label>
                                  <div class="col-md-6">
                                    <asp:TextBox CssClass="pl-5" runat="server" class="form-control amount" Enabled="false"
                                      ID="xacCredit"></asp:TextBox>
                                  </div>
                                  <div class="col-md-3"></div>
                                </div>
                              </div>
                            </div>
                            <div class="col-md-3 form-group">
                              <asp:Label ID="Label17" Text="total" runat="server"></asp:Label>
                              <asp:Label ID="Label18" Text="gme" runat="server"></asp:Label>
                              <asp:Label ID="Label19" Text="gmoney" runat="server"></asp:Label>
                              <asp:Label ID="Label20" Text="contact" runat="server"></asp:Label>
                              <asp:Label ID="Label21" Text="hanpass" runat="server"></asp:Label>
                              <asp:Label ID="Label22" Text="wallet" runat="server"></asp:Label>
                              <asp:Label ID="Label23" Text="shimtgel" runat="server"></asp:Label>
                              <asp:Label ID="Label24" Text="others" runat="server"></asp:Label>
                            </div>

                          </div>
                        </div>
                      </div>
                      <div class="row-md-5 form-group">
                        <div class="col-md-1">
                          <asp:DropDownList AutoPostBack="true" OnSelectedIndexChanged="xacPageSize_SelectedIndexChanged"
                            ID="xacPageSize" runat="server" CssClass="form-control">
                            <asp:ListItem Text="15"></asp:ListItem>
                            <asp:ListItem Text="30"></asp:ListItem>
                            <asp:ListItem Text="50"></asp:ListItem>
                            <asp:ListItem Text="100"></asp:ListItem>
                            <asp:ListItem Text="All"></asp:ListItem>
                          </asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                        </div>
                        <div class="col-md-1 text-right">
                          <label>Search:</label>
                        </div>
                        <div class="col-md-2">
                          <input type="text" id="xacSearch" class="form-control" onkeyup="TableSearch()" />
                          <%--<asp:TextBox ID="filterBx" runat="server" Width="250px" CssClass="form-control" OnClientTextChange="">
                            </asp:TextBox>--%>
                        </div>
                        <%--<div class="col-md">
                          <asp:Button ID="srchValue" runat="server" Visible="true" OnClick="srchValue_Click" Text="Search" />
                      </div> --%>
                    </div>
                    <div class="row-md-5">
                      <div class="container-md">
                        <asp:GridView ID="xacGrid" runat="server" AutoGenerateColumns="false" GridLines="None" CssClass="table table-bordered table-condensed table-hover table-responsive table-striped" ShowHeaderWhenEmpty="true" OnSorting="xacGrid_Sorting" OnPageIndexChanging="xacGrid_PageIndexChanging" AllowPaging="true" AllowSorting="true" PageSize="15">
                          <PagerSettings Mode="NumericFirstLast" />
                          <PagerStyle CssClass="pagination-ys" />
                          <Columns>
                              <asp:BoundField SortExpression="CREDITAMOUNT" DataField="CREDITAMOUNT" HeaderText="Amount" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting" DataFormatString="{0:n}"/>
                              <asp:BoundField SortExpression="CLOSINGBALANCE" DataField="CLOSINGBALANCE" HeaderText="Account Balance" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting" DataFormatString="{0:n}"/>
                              <asp:BoundField SortExpression="DESCRIPTION" DataField="DESCRIPTION" HeaderText="Transaction description" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-3 sorting" />
                              <asp:BoundField SortExpression="OPENDATE" DataField="OPENDATE" HeaderText="Transaction Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1 sorting" DataFormatString="yyyy/MM/dd" />
                              <asp:BoundField SortExpression="CUSTOMERID" DataField="CUSTOMERID" HeaderText="Customer ID" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1 sorting" />
                              <asp:BoundField SortExpression="ACCOUNTID" DataField="ACCOUNTID" HeaderText="Account ID" ItemStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1 sorting" />
                          </Columns>
                        </asp:GridView>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div role="tabpanel" class="tab-pane" id="menu5">
            <div class="row-md">
              <div class="col-md">
                <div class="panel panel-default recent-activites">
                  <div class="panel-heading">
                    <h4 class="panel-title">TDB statement</h4>
                  </div>
                  <div class="panel-body">
                    <div class="container-md">
                      <div class="row">
                        <div class="col-md-12">
                          <div class="col-md-5">
                            <div class="row">
                              <div class="col-md-5">
                                <div class="row form-group">
                                  <label class="col-md-4 control-label">Start date: </label>
                                  <div class="col-md-8">
                                    <asp:TextBox ID="TDBDateFr" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                                  </div>
                                </div>
                                <div class="row form-group">
                                  <label class="col-md-4 control-label">End date: </label>
                                  <div class="col-md-8">
                                    <asp:TextBox ID="TDBDateTo" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                                  </div>
                                </div>
                              </div>
                          <div class="col-md-2"></div>
                          <div class="col-md-5">
                            <div class="row-md form-group">
                                <asp:DropDownList ID="TDBAccountList" runat="server" CssClass="form-control">
                                  <asp:ListItem Text="1605129074" Value="5163260456:17400001121004"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="row-md form-group">
                              <asp:Panel runat="server" DefaultButton="TDBStatement">
                                <asp:TextBox ID="TDBPassword" runat="server" TextMode="Password" CssClass="form-control"></asp:TextBox>
                                <asp:Button ID="TDBStatement" runat="server" style="display:none" OnClick="TDBStatement_Click" />
                              </asp:Panel>
                            </div>
                          </div>
                        </div>
                        <div class="row">
                            <div class="container-md m-t-5">
                              <div class="col-md-5 col-centered">
                                <asp:Button ID="TDBStatementButton" runat="server" Text="Get" CssClass="btn btn-primary btn-block" onClientClick="CheckAccount();" OnClick="TDBStatement_Click" />
                            </div>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-1"></div>
                        <div class="col-md-3 form-group">
                            <div class="col-md">
                                <div class="row form-group">
                                    <label for="mnt" class="col-md-3 col-form-label">Үлдэгдэл:</label>
                                    <div class="col-md-6">
                                        <asp:TextBox CssClass="pl-5" runat="server" class="form-control amount" ID="TDBAmount" Enabled="false"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3"></div>
                                </div>
                                <div class="row form-group">
                                    <label for="usd" class="col-md-3 col-form-label">Орсон:</label>
                                    <div class="col-md-6">
                                        <asp:TextBox CssClass="pl-5" runat="server" class="form-control amount" ID="TDBDebit" Enabled="false"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3"></div>
                                </div>
                                <div class="row form-group">
                                    <label for="cos" class="col-md-3 col-form-label">Гарсан:</label>
                                    <div class="col-md-6">
                                        <asp:TextBox CssClass="pl-5" runat="server" class="form-control amount" ID="TDBCredit" Enabled="false"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3"></div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-3 col-md-6 form-group">
                          <asp:Label ID="Label25" Text="total" runat="server"></asp:Label>
                          <asp:Label ID="Label26" Text="gme" runat="server"></asp:Label>
                          <asp:Label ID="Label27" Text="gmoney" runat="server"></asp:Label>
                          <asp:Label ID="Label28" Text="contact" runat="server"></asp:Label>
                          <asp:Label ID="Label29" Text="hanpass" runat="server"></asp:Label>
                          <asp:Label ID="Label30" Text="wallet" runat="server"></asp:Label>
                          <asp:Label ID="Label31" Text="shimtgel" runat="server"></asp:Label>
                          <asp:Label ID="Label32" Text="others" runat="server"></asp:Label>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="row-md-5 form-group">
                    <div class="col-md-1">
                      <asp:DropDownList AutoPostBack="true" OnSelectedIndexChanged="TDBGrid_SelectedIndexChanged" ID="TDBPageSize" runat="server" CssClass="form-control">
                        <asp:ListItem Text="15"></asp:ListItem>
                        <asp:ListItem Text="30"></asp:ListItem>
                        <asp:ListItem Text="50"></asp:ListItem>
                        <asp:ListItem Text="100"></asp:ListItem>
                        <asp:ListItem Text="All"></asp:ListItem>
                      </asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                    </div>
                    <div class="col-md-1 text-right">
                        <label>Search: </label>
                    </div>
                    <div class="col-md-2">
                      <input type="text" id="TDBSearch" class="form-control" onkeyup="TableSearch()"/>
                    </div>        
                  </div>
                  <div class="row-md-5">
                      <div class="container-md">
                        <asp:GridView ID="TDBGrid" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-condensed table-hover table-responsive table-striped" ShowHeaderWhenEmpty="true" AllowPaging="true" AllowSorting="true" PageSize="15" OnSorting="TDBGrid_Sorting" OnPageIndexChanging="TDBGrid_PageIndexChanging">
                          <PagerSettings Mode="NumericFirstLast" />
                          <PagerStyle CssClass="pagination-ys" />
                          <Columns>
                            <asp:BoundField SortExpression="amountMoneyFormat" DataField="amountMoneyFormat" HeaderText="Amount" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting"/>
                            <asp:BoundField SortExpression="ntrybalance" DataField="ntrybalance" HeaderText="Account Balance" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting"/>
                            <asp:BoundField SortExpression="txAddInf" DataField="txAddInf" HeaderText="Transaction Description" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-3 sorting"/>
                            <asp:BoundField SortExpression="txDt" DataField="txDt" HeaderText="Transaction Date" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-2 sorting"/>
                            <asp:BoundField SortExpression="ntryRef" DataField="ntryRef" HeaderText="Journal" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" HeaderStyle-CssClass="text-center col-md-1 sorting"/>
                          </Columns>
                        </asp:GridView>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div role="tabpanel" class="tab-pane" id="menu6">
            <div class="row-md">
              <div class="col-md-12">
                <div class="panel panel-default recent-activites">
                  <div class="panel-heading">
                    <h4 class="panel-title">Transaction</h4>
                  </div>
                  <div class="panel-body">
                    <div class="row">
                      <div class="col-lg-3 col-md-6 form-group">
                        <asp:DropDownList ID="fromToFrst" runat="server" CssClass="form-control">
                          <asp:ListItem Text="Khaan 8601" Value="5163358601:KHN" Selected="True"></asp:ListItem>
                          <asp:ListItem Text="Khaan 9572" Value="5176019572:KHN" ></asp:ListItem>
                          <asp:ListItem Text="Khaan 0456" Value="5163260456:KHN" ></asp:ListItem>
                          <asp:ListItem Text="Khaan 2299" Value="5163322299:KHN" ></asp:ListItem>
                          <asp:ListItem Text="Golomt 9074" Value="1605129074:GMT"></asp:ListItem>
                          <asp:ListItem Text="Khaan NUBIA 9074" Value="5111730446:KHN"></asp:ListItem>
                        </asp:DropDownList>
                      </div>
                      <div class="col-lg-2 col-md-6 form-group">
                        <asp:TextBox ID="tranAmt" runat="server" CssClass="form-control"></asp:TextBox>
                      </div>
                      <div class="col-lg-3 col-md-6 form-group">
                        <asp:DropDownList ID="fromToScnd" runat="server" CssClass="form-control">
                          <asp:ListItem Text="Khaan 8601" Value="5163358601:KHN" Selected="True"></asp:ListItem>
                          <asp:ListItem Text="Khaan 9572" Value="5176019572:KHN" ></asp:ListItem>
                          <asp:ListItem Text="Khaan 0456" Value="5163260456:KHN" ></asp:ListItem>
                          <asp:ListItem Text="Khaan 2299" Value="5163322299:KHN" ></asp:ListItem>
                          <asp:ListItem Text="Golomt 9074" Value="1605129074:GMT"></asp:ListItem>
                          <asp:ListItem Text="Khaan NUBIA 9074" Value="5111730446:KHN"></asp:ListItem>
                        </asp:DropDownList>
                      </div>
                    </div>
                    <div class="row">
                      <div class="col-lg-3 col-md-6 form-group">
                        <asp:Button ID="makeTran" runat="server" Text="Transfer" CssClass="btn btn-primary m-t-25" OnClick="makeTran_Click" />
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <%--<section ID="stateGrid1" class="content">
			          <div class="container-fluid">
				          <div class="row">
					          <div class="col-12">
						          <div class="card">
							          <div class="card-header">
				                          <h3 class="card-title text-info" id="last-refresh"></h3>
				                      </div>
							          <!-- /.card-header -->
							          <div class="card-body">
								          <table id="statementTable"
									          class="table table-hover table-head-fixed" style="width: 100%">
									          <thead>
										          <tr>
											          <th>#</th>
											          <th>Дүн</th>
											          <th>Үлдэгдэл</th>
											          <th>Тайлбар</th>
											          <th>Өдөр</th>
											          <th>Цаг</th>
											          <th>Журнал</th>
										          </tr>
									          </thead>
									          <tfoot>
										          <tr>
											          <th>#</th>
											          <th>Дүн</th>
											          <th>Үлдэгдэл</th>
											          <th>Тайлбар</th>
											          <th>Өдөр</th>
											          <th>Цаг</th>
											          <th>Журнал</th>
										          </tr>
									          </tfoot>
								          </table>
							          </div>
							          <!-- /.card-body -->
						          </div>
						          <!-- /.card -->
					          </div>
					          <!-- /.col -->
				          </div>
				          <!-- /.row -->
			        </div>
			          <!-- /.container-fluid -->
		      </section>--%>
        </div>
      </div>
    </div>
  </form>
</body>
</html>
