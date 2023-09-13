<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="AgentFund.aspx.cs" Inherits="Swift.web.AgentNew.Modify.AgentFund" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
  <script src="/js/Reports/AccountStatementPortal.js" type="text/javascript"></script>
  <script type="text/javascript" language="javascript">
    $(document).ready(function () {
      function LoadCalendars() {
        ShowCalFromToUpToToday("#<% =startDate.ClientID%>", "#<% =endDate.ClientID%>", 1);
        $('#<%=startDate.ClientID%>').mask('0000-00-00');
        $('#<%=endDate.ClientID%>').mask('0000-00-00');
        ShowCalFromToUpToToday("#<% =startDate2.ClientID%>", "#<% =endDate2.ClientID%>", 1);
        $('#<%=startDate2.ClientID%>').mask('0000-00-00');
        $('#<%=endDate2.ClientID%>').mask('0000-00-00');
      }
      LoadCalendars();
    });

    function CheckFormValidation(type) {
      var startDate = GetValue("<% =startDate.ClientID%>");
      var endDate = GetValue("<% =endDate.ClientID%>");
      var acInfo = GetValue("<% =acInfo.ClientID%>");
      var acInfotxt = GetValue("<% =acInfo.ClientID%>");
      var curr = GetValue("<% =ddlCurrency.ClientID%>");
      var url;
      if (type == 'download') {
        url = "../../AccountReport/AccountStatement/StatementDetails.aspx?startDate=" + startDate + "&endDate=" + endDate + "&acNum=" + acInfo + "&acName=" + acInfotxt + "&curr=" + curr + "&type=a&isDownload=y";
        OpenInNewWindow(url);
      }
      else {
        url = "../../AccountReport/AccountStatement/StatementDetails.aspx?startDate=" + startDate + "&endDate=" + endDate + "&acNum=" + acInfo + "&acName=" + acInfotxt + "&curr=" + curr + "&type=" + type;
        window.location.href = url;
      }
    }

    function CheckFormValidation2() {
      var startDate = GetValue("<% =startDate2.ClientID%>");
      var endDate = GetValue("<% =endDate2.ClientID%>");
      var acInfo = GetValue("<% =acInfo1.ClientID%>");
      var condition = GetValue("<% =filterContion.ClientID%>");
      var having = GetValue("<% =havingValue.ClientID%>");
      var url = "FilterStatementResult.aspx?startDate=" + startDate + "&endDate=" + endDate + "&acNum=" + acInfo + "&filterContion=" + condition + "&having=" + having;
      window.location.href = url;
    }

    function ViewReportAgent(type) {
      var startDate = GetValue("<% =startDate.ClientID%>");
      var endDate = GetValue("<% =endDate.ClientID%>");
      reqField = "startDate,endDate,acInfo,";
      if (ValidRequiredField(reqField) === false) {
        return false;
      }
      $('#accDetails').text($('#<%=acInfo.ClientID%> option:selected').text());
      $('#startDateAfterSearch').val(startDate);
      $('#endDateAfterSearch').val(endDate);

      $('#Search').attr('disabled', true);
      $('#SearchAgain').attr('disabled', true);
      var dataObject = {
        MethodName: 'ViewStatement',
        FromDate: startDate,
        ToDate: endDate,
        accNum: GetValue("<% =acInfo.ClientID%>"),
        accName: GetValue("<% =acInfo.ClientID%>"),
        accCurr: GetValue("<% =ddlCurrency.ClientID%>"),
        type: 'a'
      };

      url = '';
      $.post(url, dataObject, function (data) {
        $('#statementResult').show();
        $('#searchDiv').hide();

        var sn = 1;
        var BAlance = 0, OpenBalnce = 0, fcyOpening = 0, crAmt = 0, drAmt = 0;
        var drCount = 0, crCount = 0;
        var curr = '';

        var table = $('#statementReportTbl');
        table.find("tbody tr").remove();

        $('#Search').attr('disabled', false);
        $('#SearchAgain').attr('disabled', false);
        var result = data;//jQuery.parseJSON(data);
        $.each(result, function (i, d) {
          curr = d['fcy_Curr'];
          if (d['tran_particular'] == 'Balance Brought Forward') {
            sn = 0;
            if (d['fcy_Curr'] == null || d['fcy_Curr'] == 'JPY') {
              OpenBalnce = parseFloat(d['tran_amt']);
            }
            else {
              OpenBalnce = parseFloat(d['usd_amt']);
            }
            fcyOpening = parseFloat(d['usd_amt']);
            BAlance = parseFloat(d['tran_amt']);
          }
          else {
            if (d['part_tran_type'] == 'dr') {
              if (d['fcy_Curr'] == null || d['fcy_Curr'] == 'JPY') {
                drAmt += parseFloat(d['tran_amt']);
              }
              else {
                drAmt += parseFloat(d['usd_amt']);
              }
              drCount++;
            }
            else {
              if (d['fcy_Curr'] == null || d['fcy_Curr'] == 'JPY') {
                crAmt += parseFloat(d['tran_amt']);
              }
              else {
                crAmt += parseFloat(d['usd_amt']);
              }
              crCount++;
            }
            BAlance += parseFloat(d['tran_amt']);
            fcyOpening += parseFloat(d['usd_amt']);
          }

          var row = '<tr>';
          row += '<td>' + sn + '</td>';
          row += '<td nowrap align="center">' + (d['tran_date'] == '1900.01.01' ? '&nbsp;' : d['tran_date']) + '</td>';
          row += '<td>' + d['tran_particular'] + '</td>';
          row += '<td>' + d['fcy_Curr'] + '</td>';
          row += '<td>' + CurrencyFormatted(parseFloat(d['usd_amt'])) + '</td>';
          row += '<td>' + CurrencyFormatted(parseFloat(fcyOpening)) + '</td>';
          row += '<td>' + d['part_tran_type'] + '</td>';
          row += '<td>' + CurrencyFormatted(parseFloat(d['tran_amt'])) + '</td>';
          row += '<td>' + CurrencyFormatted(parseFloat(BAlance)) + '</td>';
          row += '<td>' + (parseFloat(BAlance) > 0 ? 'CR' : 'DR') + '</td>';
          row += '</tr>';
          table.append(row);

          sn++;
        });

        $('#openingBalance').text(CurrencyFormatted(OpenBalnce));
        $('#totalCrCount').text(crCount);
        $('#totalCR').text(CurrencyFormatted(crAmt));
        $('#totalDrCount').text(drCount);
        $('#totalDR').text(CurrencyFormatted(drAmt));
        $('#DrOrCr').text((BAlance > 0 ? "CR" : "DR"));

        if (curr == null || curr == "JPY") {
          $('#closingBalance').text(CurrencyFormatted(BAlance > 0 ? BAlance * -1 : BAlance));
        }
        else {
          $('#closingBalance').text(CurrencyFormatted(fcyOpening > 0 ? fcyOpening * -1 : fcyOpening));
        }
      }).fail(function () {
        $('#Search').attr('disabled', false);
        $('#SearchAgain').attr('disabled', false);
        alert('error occured!');
      });
    };
  </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
  <div class="page-wrapper">
    <div class="page-wrapper">
      <div class="row">
        <div class="col-sm-12">
          <div class="page-title">
            <h1></h1>
            <ol class="breadcrumb">
              <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
              <li class="active"><a href="AgentFund.aspx">Account Statement</a></li>
            </ol>
          </div>
        </div>
      </div>
      <div class="row" id="searchDiv">
        <div class="col-md-6">
          <div class="panel panel-default recent-activites">
            <div class="panel-heading">
              <h4 class="panel-title">Search Account Statement
              </h4>
              <div class="panel-actions">
                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
              </div>
            </div>
            <div class="panel-body">
              <div class="form-group">
                <label class="col-lg-4 col-md-4 control-label" for="">
                  Ledger Name:<span class="errormsg">*</span></label>
                <div class="col-lg-8 col-md-8">
                  <asp:DropDownList ID="acInfo" runat="server" CssClass="form-control">
                  </asp:DropDownList>
                </div>
              </div>
              <div class="form-group">
                <label class="col-lg-4 col-md-4 control-label" for="">
                  Currency:</label>
                <div class="col-lg-8 col-md-8">
                  <asp:DropDownList ID="ddlCurrency" runat="server" CssClass="form-control">
                  </asp:DropDownList>
                </div>
              </div>
              <div class="form-group">
                <label class="col-lg-4 col-md-4 control-label" for="">
                  From Date:</label>
                <div class="col-lg-8 col-md-8">
                  <div class="input-group m-b">
                    <span class="input-group-addon">
                      <i class="fa fa-calendar" aria-hidden="true"></i>
                    </span>
                    <asp:TextBox ID="startDate" onchange="return DateValidation('startDate','t','endDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <label class="col-lg-4 col-md-4 control-label" for="">
                  To Date:</label>
                <div class="col-lg-8 col-md-8">
                  <div class="input-group m-b">
                    <span class="input-group-addon">
                      <i class="fa fa-calendar" aria-hidden="true"></i>
                    </span>
                    <asp:TextBox ID="endDate" onchange="return DateValidation('startDate','t','endDate')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-md-10 col-md-offset-4">
                  <input type="button" value="Search" id="Search" onclick="ViewReportAgent()" class="btn btn-primary m-t-25" />
                  &nbsp;
                                    <input type="button" style="display: none;" value="Date wise Search" onclick="CheckFormValidation('d');" class="btn btn-primary m-t-25" />
                  &nbsp;
                                    <input type="button" value="Export To Excel" onclick="CheckFormValidation('download');" class="btn btn-primary m-t-25" />
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-6" style="display: none">
          <div class="panel panel-default recent-activites">
            <div class="panel-heading">
              <h4 class="panel-title">Search Conditional Statement
              </h4>
              <div class="panel-actions">
                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
              </div>
            </div>
            <div class="panel-body">
              <div class="form-group">
                <label class="col-lg-4 col-md-4 control-label" for="">
                  AC information:<span class="errormsg">*</span></label>
                <div class="col-lg-8 col-md-8">
                  <asp:DropDownList ID="acInfo1" runat="server" CssClass="form-control">
                  </asp:DropDownList>
                </div>
              </div>
              <div class="form-group">
                <label class="col-lg-4 col-md-4 control-label" for="">
                  Start Date:</label>
                <div class="col-lg-8 col-md-8">
                  <div class="input-group m-b">
                    <span class="input-group-addon">
                      <i class="fa fa-calendar" aria-hidden="true"></i>
                    </span>
                    <asp:TextBox ID="startDate2" onchange="return DateValidation('startDate2','t','endDate2')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <label class="col-lg-4 col-md-4 control-label" for="">
                  End Date:</label>
                <div class="col-lg-8 col-md-8">
                  <div class="input-group m-b">
                    <span class="input-group-addon">
                      <i class="fa fa-calendar" aria-hidden="true"></i>
                    </span>
                    <asp:TextBox ID="endDate2" onchange="return DateValidation('startDate2','t','endDate2')" MaxLength="10" runat="server" CssClass="form-control form-control-inline input-medium"></asp:TextBox>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <label class="col-lg-4 col-md-4 control-label" for="">
                  <label>
                    Condition:</label>
                </label>
                <div class="col-lg-8 col-md-8">
                  <asp:DropDownList ID="filterContion" runat="server" CssClass="form-control">
                    <asp:ListItem Text="AC Number" Value="ACC_NUM"></asp:ListItem>
                    <asp:ListItem Text="Cheque No" Value="CHEQUE_NO"></asp:ListItem>
                    <asp:ListItem Text="Narrations" Value="tran_particular"></asp:ListItem>
                    <asp:ListItem Text="Amount" Value="tran_amt"></asp:ListItem>
                  </asp:DropDownList>
                </div>
              </div>
              <div class="form-group">
                <label class="col-lg-4 col-md-4 control-label" for="">
                  Having:<span class="errormsg">*</span></label>
                <div class="col-lg-8 col-md-8">
                  <asp:TextBox ID="havingValue" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
              </div>
              <div class="form-group">
                <div class="col-md-2 col-md-offset-4">
                  <input type="button" value="    Search    " onclick="CheckFormValidation2();" class="btn btn-primary m-t-25" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="row" id="statementResult" style="display: none;">
        <div class="col-md-12">
          <div class="panel panel-default recent-activites">
            <div class="panel-heading">
              <h4 class="panel-title">Statement Search Result
              </h4>
            </div>
            <div class="panel-body">
              <div class="row">
                <div class="col-md-12 col-lg-12 form-group">
                  <label id="accDetails"></label>
                </div>
              </div>
              <div class="row">
                <div class="col-md-12">
                  <div class="form-group">
                    <div class="table table-responsive" id="main">
                      <table id="statementReportTbl" class="table table-responsive table-bordered">
                        <thead>
                          <tr>
                            <th>S. No.</th>
                            <th>Tran Date</th>
                            <th>Particulars</th>
                            <th>FCY</th>
                            <th>FCY Amount</th>
                            <th>FCY Closing</th>
                            <th>DR/CR</th>
                            <th>MNT Amount</th>
                            <th>MNT Closing</th>
                            <th>DR/CR</th>
                            <%--<th>Reversal</th>--%>
                          </tr>
                        </thead>
                        <tbody>
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
                <div class="col-md-12">
                  <div class="form-group">
                    <div class="col-md-8 form-group">
                    </div>
                    <div class="col-md-4 form-group">
                      <div class="table-responsive">
                        <table class="table table-striped dt-responsive nowrap">
                          <tr>
                            <td><b>Opening Balance:</b></td>
                            <td><b>
                              <label id="openingBalance"></label>
                            </b></td>
                          </tr>
                        <%--  <tr>
                            <td><b>Total DR:(<label id="totalDrCount"></label>)</b></td>
                            <td><b>
                              <label id="totalDR"></label>
                            </b></td>
                          </tr>
                          <tr>
                            <td><b>Total CR:(<label id="totalCrCount"></label>)</b></td>
                            <td><b>
                              <label id="totalCR"></label>
                            </b></td>
                          </tr>--%>
                          <tr>
                            <td><b>Closing Balance:(<label id="DrOrCr"></label>)</b></td>
                            <td><b>
                              <label id="closingBalance"></label>
                            </b></td>
                          </tr>
                        </table>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</asp:Content>
