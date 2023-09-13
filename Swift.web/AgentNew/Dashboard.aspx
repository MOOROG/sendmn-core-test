<%@ Page Title="" Language="C#" MasterPageFile="~/AgentNew/AgentMain.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Swift.web.AgentNew.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
  <style type="text/css">
    .holder {
      /*background-color: #ccc;*/
      /*width: 300px;*/
      height: 250px;
      overflow: hidden;
      padding: 10px;
      /*font-family: Helvetica;*/
    }

      .holder .mask {
        position: relative;
        left: 0px;
        /*top: 10px;*/
        /*width: 300px;*/
        height: 240px;
        overflow: hidden;
      }

      .holder ul {
        list-style: none;
        margin: 0;
        padding: 0;
        position: relative;
      }

        .holder ul li {
          padding: 10px 0px;
        }

          .holder ul li a {
            /*color: darkred;*/
            text-decoration: none;
          }
  </style>
  <script type="text/javascript">
    function GetTxnDetail(tranType) {
      var url;
      switch (tranType) {
        case "iSend":
          url = "../AgentPanel/Reports.aspx?reportName=40111600&sBranch=<%=Swift.web.Library.GetStatic.GetBranch() %>&orderBy=dot&dateField=confirmDate&from=<%=DateTime.Now.ToString("yyyy-MM-dd")%>&to=<%=DateTime.Now.ToString("yyyy-MM-dd")%>&rptType=s&displayTranNo=N";
                break;

              case "iCancel":
                url = "../AgentPanel/Reports.aspx?reportName=40111600&sBranch=<%=Swift.web.Library.GetStatic.GetBranch() %>&orderBy=dot&fromDate=<%=DateTime.Now.ToString("d")%>&toDate=<%=DateTime.Now.ToString("d")%>&dateField=paidDate&from=<%=DateTime.Now.ToString("yyyy-MM-dd")%>&to=<%=DateTime.Now.ToString("yyyy-MM-dd")%>&transType=Cancel&rptType=s&displayTranNo=N";
                break;
              case "iPaid":
                url = "../AgentPanel/Reports.aspx?reportName=40111600&pCountry=NEPAL&pAgent=&sBranch=<%=Swift.web.Library.GetStatic.GetBranch() %>&dateField=paidDate&from=<%=DateTime.Now.ToString("yyyy-MM-dd")%>&to=<%=DateTime.Now.ToString("yyyy-MM-dd")%>&rptType=p";
          break;
        case "iUnpaid":
          url = "";
          break;
      }
      OpenInNewWindow(url);
    }

    function getFundDetail() {
      //window.location.href = "/AgentNew/Administration/AgentCharging/AgentList.aspx";
      window.location.href = "/AgentNew/Modify/AgentFund.aspx";
    }

    jQuery.fn.liScroll = function (settings) {
      settings = jQuery.extend({
        travelocity: 0.03
      }, settings);
      return this.each(function () {
        var $strip = jQuery(this);
        $strip.addClass("newsticker")
        var stripHeight = 1;
        $strip.find("li").each(function (i) {
          stripHeight += jQuery(this, i).outerHeight(true); // thanks to Michael Haszprunar and Fabien Volpi
        });
        var $mask = $strip.wrap("<div class='mask'></div>");
        var $tickercontainer = $strip.parent().wrap("<div class='tickercontainer'></div>");
        var containerHeight = $strip.parent().parent().height();	//a.k.a. 'mask' width
        $strip.height(stripHeight);
        var totalTravel = stripHeight;
        var defTiming = totalTravel / settings.travelocity;	// thanks to Scott Waye
        function scrollnews(spazio, tempo) {
          $strip.animate({ top: '-=' + spazio }, tempo, "linear", function () { $strip.css("top", containerHeight); scrollnews(totalTravel, defTiming); });
        }
        scrollnews(totalTravel, defTiming);
        $strip.hover(function () {
          jQuery(this).stop();
        },
          function () {
            var offset = jQuery(this).offset();
            var residualSpace = offset.top + stripHeight;
            var residualTime = residualSpace / settings.travelocity;
            scrollnews(residualSpace, residualTime);
          });
      });
    };

    $(function () {
      $("ul#messages").liScroll();
    });
  </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
  <div class="page-wrapper">
    <div class="row">
      <div class="col-sm-6 col-md-3 margin-b-30" id="sendingAgent" runat="server" visible="true">
        <div class="tile blue">
          <div class="tile-title clearfix">
            Today's  Send
          </div>
          <div class="tile-body clearfix">
            <i class="fa fa-credit-card"></i>
            <h4 class="pull-right"><a href="#" onclick="GetTxnDetail('iSend')" style="color: white;">
              <asp:Label runat="server" ID="iSend"></asp:Label></a></h4>
          </div>
          <div class="tile-footer">
            <a href="#" onclick="GetTxnDetail('iSend')">View Details...</a>
          </div>
        </div>
      </div>
      <div class="col-sm-6 col-md-3 margin-b-30" id="sendingAgent1" runat="server" visible="true">
        <div class="tile purple">
          <div class="tile-title clearfix">
            Today's  Cancel
          </div>
          <div class="tile-body clearfix">
            <i class="fa fa-credit-card"></i>
            <h4 class="pull-right"><a href="#" style="color: white;" onclick="GetTxnDetail('iCancel')">
              <asp:Label runat="server" ID="iCancel"></asp:Label></a></h4>
          </div>
          <div class="tile-footer">
            <a href="#" onclick="GetTxnDetail('iCancel')">View Details...</a>
          </div>
        </div>
      </div>
      <div class="col-sm-6 col-md-3 margin-b-30" id="payAgent" runat="server" visible="true">
        <div class="tile red">
          <div class="tile-title clearfix">
            Today's  Paid
          </div>
          <div class="tile-body clearfix">
            <i class="fa fa-credit-card"></i>
            <h4 class="pull-right"><a href="#" onclick="GetTxnDetail('iPaid')" style="color: white;">
              <asp:Label runat="server" ID="iPaid"></asp:Label></a></h4>
          </div>
          <div class="tile-footer">
            <a href="#" onclick="GetTxnDetail('iPaid')">View Details...</a>
          </div>
        </div>
      </div>
      <div class="col-sm-6 col-md-3 margin-b-30" id="Div1" runat="server" visible="true">
        <div class="tile green">
          <div class="tile-title clearfix">
            Agent Fund
          </div>
          <div class="tile-body clearfix">
            <i class="fa fa-credit-card"></i>
            <h2 class="pull-right"><a href="#" style="color: white;">
              <asp:Label runat="server" ID="agentFundID"></asp:Label></a></h2>
          </div>
          <div class="tile-footer">
            <a href="#" onclick="getFundDetail()">View Details...</a>
          </div>
        </div>
      </div>
      <div class="col-sm-6 col-md-3 margin-b-30" id="payAgent1" runat="server" visible="false">
        <div class="tile green">
          <div class="tile-title clearfix">
            Today's  Unpaid
          </div>
          <div class="tile-body clearfix">
            <i class="fa fa-credit-card"></i>
            <h4 class="pull-right"><a href="#" onclick="GetTxnDetail('iUnpaid')" style="color: white;">
              <asp:Label runat="server" ID="iUnpaid"></asp:Label></a></h4>
          </div>
          <div class="tile-footer">
            <a href="#" onclick="GetTxnDetail('iUnpaid')">View Details...</a>
          </div>
        </div>
      </div>
    </div>
    <div class="row" style="display: none">
      <div class="col-md-6">
        <div class="panel panel-default recent-activites">
          <!-- Start .panel -->
          <div class="panel-heading">
            <h4 class="panel-title">Notification And Messages</h4>
            <div class="panel-actions">
            </div>
          </div>
          <div class="panel-body pad-0 holder">
            <ul class="list-group" id="messages" runat="server">
              <li class="list-group-item">
                <a href="#">Remittance Rules 1 from NRB</a>
                <small><i class="fa fa-clock-o"></i>13/08/2015 04:51:21</small>
              </li>
              <li class="list-group-item">
                <a href="#">Remittance Rules 1 from NRB</a>
                <small><i class="fa fa-clock-o"></i>13/08/2015 04:51:21</small>
              </li>
              <li class="list-group-item">
                <a href="#">Compliance Rules 1 from NRB</a>
                <small><i class="fa fa-clock-o"></i>13/08/2015 04:51:21</small>
              </li>
              <li class="list-group-item">
                <a href="#">Deposit Rules 1 from NRB</a>
                <small><i class="fa fa-clock-o"></i>13/08/2015 04:51:21</small>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
    <%-- <div class="row">
                <div class="col-md-12">
                    <div class="panel panel-default recent-activites">
                        <div class="panel-heading">
                            <h3 class="panel-title">Notification  List
                            </h3>
                            <div class="panel-actions">
                                <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                            </div>
                        </div>
                        <div class="panel-body">
                            <div class="col-md-4">
                                <fieldset>
                                    <legend>Notification Panel</legend>
                                    <table class="table table-responsive table-bordered table-striped">
                                        <thead>
                                            <tr>
                                                <th>Sno.</th>
                                                <th>Message</th>
                                                <th>Date</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <div id="divMsg" runat="server"></div>
                                        </tbody>
                                    </table>
                                </fieldset>
                            </div>
                            <div class="col-md-8">
                                <fieldset>
                                    <legend>Full Notification Notification Panel</legend>
                                    <div id="viewMessage">Area to show current message</div>
                                </fieldset>
                            </div>
                        </div>
                    </div>
                </div>
            </div>--%>
  </div>
  <div class="modal fade " id="myModal" role="dialog" style="top: 150px;">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal">&times;</button>
          <h4 class="modal-title">
            <label id="createdBy" style="text-transform: uppercase;"></label>
            &nbsp;&nbsp;<small style="font-size: 10px;"><i class="fa fa-clock-o"></i>&nbsp;<label id="createdDate"></small></h4>
        </div>
        <div class="modal-body">
          <label id="message"></label>
        </div>
      </div>
    </div>
  </div>
  <script type="text/javascript">
    function ShowMessage(msgId) {
      $.ajax({
        type: "POST",
        url: "/AgentMain.aspx",
        data: { MethodName: "Messages", MessageId: msgId },
        success: function (result) {
          PopulateData(result);
        }
      });
    };
    function PopulateData(data) {
      $('#myModal').modal('show');

      var obj = jQuery.parseJSON(data);
      $('#message').html(obj.Message);
      $('#createdBy').html(obj.CreatedBy);
      $('#createdDate').html(obj.CreatedDate);
      //$('#questionDesc').html(obj.Description);
      //$('#forumTitle').html(obj.ForumTitle);
    };
  </script>
</asp:Content>
