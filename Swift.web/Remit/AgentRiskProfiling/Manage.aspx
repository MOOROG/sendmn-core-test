<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Manage.aspx.cs" Inherits="Swift.web.Remit.AgentRiskProfiling.Manage" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <base id="Base1" target="_self" runat="server" />
    <link href="../../ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../../ui/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
    <link href="../../ui/css/style.css" rel="stylesheet" />
    <script src="../../js/swift_grid.js" type="text/javascript"> </script>
    <script src="../../js/functions.js" type="text/javascript"> </script>
    <script src="../../js/swift_calendar.js" type="text/javascript"></script>
    <link href="../../js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../js/jQuery/jquery.min.js" type="text/javascript"></script>
    <script src="../../js/jQuery/jquery-ui.min.js" type="text/javascript"></script>
    <script src="../../js/swift_autocomplete.js" type="text/javascript"></script>

    <script type="text/javascript" language="javascript">
        function LoadCalendars() {
            ShowCalFromToUpToToday("#<% =assessementdate.ClientID%>");
        }
        LoadCalendars();

        function CallBackSave(errorCode, msg, url) {
            if (msg != '')
                alert(msg);
            if (errorCode == '0') {
                RedirectToIframe(url);
            }
        }

        function RedirectToIframe(url) {
            window.open(url, "_self");
        }
        function validateDataGrid() {

            try {
                var i = 0;
                var totalScore = 0;

                var execute = true;
                while (execute) {

                    var txtScore = 'riskProfiling_txtScore_' + i.toString();
                    //var txtMin = 'riskProfiling_txtMinScore_' + i.toString();
                    //var txtMax = 'riskProfiling_txtMaxScore_' + i.toString();

                    if (document.getElementById(txtScore)) {

                        var score = document.getElementById(txtScore).value;
                        if (score == "")
                            score = "0";

                        //                        if (Math.abs(score) <= 0) {
                        //                            alert('Score value is required field and must be greater than zero.');
                        //                            return false;
                        //                        }

                        i++;
                    }
                    else
                        execute = false;

                }

            }
            catch (e) {
                alert('Error: -' + e.message);
            }

        }

        function CalculateScore() {

            var scoringCriteria = document.getElementById('hdnscoringCriteria').value.split(':');

            try {
                var i = 0;
                var totalScore = 0;

                var execute = true;
                while (execute) {

                    var txtScore = 'riskProfiling_txtScore_' + i.toString();

                    var txtMin = 'riskProfiling_txtMinScore_' + i.toString();
                    var txtMax = 'riskProfiling_txtMaxScore_' + i.toString();

                    if (document.getElementById(txtScore) && document.getElementById(txtMin) && document.getElementById(txtMax)) {

                        var score = document.getElementById(txtScore).value;

                        var minScore = document.getElementById(txtMin).value;
                        var maxScore = document.getElementById(txtMax).value;

                        if (score == "")
                            score = "0";

                        if (minScore == "")
                            minScore = "0";

                        if (maxScore == "")
                            maxScore = "0";

                        //alert('Score:' + score.toString() + 'Min:' + minScore.toString() + 'Max:' + maxScore.toString());

                        if ((Math.abs(score) >= Math.abs(minScore) && Math.abs(maxScore) >= Math.abs(score)) || Math.abs(score) == 0) {
                            totalScore = Math.abs(totalScore) + Math.abs(score);

                        }
                        else {
                            alert('Score value must not be less than ' + minScore + ' and greater than ' + maxScore + '');
                            document.getElementById(txtScore).value = '';
                            document.getElementById(txtScore).focus();
                        }
                        i++;
                    }
                    else
                        execute = false;

                }
                document.getElementById('riskProfiling_txtScoreTotal').value = Math.abs(totalScore);

                try {
                    // scoringCriteria[0]='4'
                    // scoringCriteria[1]='Low'

                    // scoringCriteria[2]='10'
                    // scoringCriteria[3]='Medium'

                    // scoringCriteria[4]='11'
                    // scoringCriteria[5]='High'

                    var scCriteria = "";
                    var scColor = "";

                    if (Math.abs(totalScore <= Math.abs(scoringCriteria[0]))) {
                        scCriteria = scoringCriteria[1];
                        scColor = "#87a96b";
                    }
                    else if (Math.abs(totalScore <= Math.abs(scoringCriteria[2]))) {
                        scCriteria = scoringCriteria[3];
                        scColor = "#a1caf1";
                    }
                    else if (Math.abs(totalScore > Math.abs(scoringCriteria[2]))) {
                        scCriteria = scoringCriteria[5];
                        scColor = "#fd5e53";
                    }

                    document.getElementById('riskProfiling_txtRiskCategory').value = scCriteria;
                    document.getElementById('riskProfiling_txtRiskCategory').style.backgroundColor = scColor;

                }
                catch (e) {
                    document.getElementById('riskProfiling_txtRiskCategory').value = "";
                    document.getElementById('riskProfiling_txtRiskCategory').style.backgroundColor = "";
                }

            }
            catch (e) {
                alert('Error: -' + e.message);
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li><a href="#" onclick="return LoadModule('remit')">Agent Risk Profiling</a></li>
                            <li class="active"><a href="#" onclick="return LoadModule('remit_compliance')">Manage</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="listtabs">
                <ul class="nav nav-tabs">
                    <li><a href="List.aspx">List</a></li>
                    <li class="active"><a href="#">Manage </a></li>
                </ul>
            </div>
            <div class="tab-content" id="trNew" runat="server">
                <div role="tabpanel" class="tab-pane active" id="list">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Add New Agent Risk Profiling
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <asp:Label ID="lblMsg" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label" for="">
                                            Agent:<span class="errormsg">*</span>
                                        </label>
                                        <asp:TextBox ID="agent" runat="server" CssClass="form-control" Width="30%"></asp:TextBox>
                                        <asp:HiddenField ID="hddAgentId" runat="server" />
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label" for="">
                                            Assessement Date:<span class="errormsg">*</span>
                                            <asp:RequiredFieldValidator ID="rqassessementDate" runat="server" ControlToValidate="assessementdate"
                                                ForeColor="Red" ValidationGroup="agent" Display="Dynamic" ErrorMessage="Required!">
                                            </asp:RequiredFieldValidator>
                                        </label>
                                        <asp:TextBox ID="assessementdate" runat="server" class="dateField form-control" Width="30%"
                                            size="12"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <asp:Button ID="btnSaveAgent" runat="server" Text="Save" CssClass="btn btn-primary" ValidationGroup="agent" Width="100px"
                                            OnClick="btnSaveAgent_Click" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="tab-content" id="trRiskProfiling" runat="server">
                <div role="tabpanel" class="tab-pane active">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="panel panel-default recent-activites">
                                <!-- Start .panel -->
                                <div class="panel-heading">
                                    <h4 class="panel-title">Score Agent Risk Profiling
                                    </h4>
                                    <div class="panel-actions">
                                        <a href="#" class="panel-action panel-action-toggle" data-panel-toggle></a>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="Red" Text=""></asp:Label>
                                    </div>
                                    <div class="form-group">
                                        <label class="control-label" for="">
                                            AGENT RISK PROFILING
                                        </label>
                                    </div>
                                    <div class="form-group">
                                        <asp:HiddenField ID="hdnscoringCriteria" runat="server" />
                                        <asp:DataGrid ID="riskProfiling" CssClass="table table-responsive" runat="server" AutoGenerateColumns="False"
                                            AllowSorting="false" CellPadding="3" BackColor="White" ShowFooter="true" OnItemDataBound="riskProfiling_ItemDataBound"
                                            DataKeyField="criteriaId" ItemStyle-BorderStyle="None" ItemStyle-BorderWidth="0">
                                            <SelectedItemStyle Font-Bold="True" ForeColor="White"></SelectedItemStyle>
                                            <AlternatingItemStyle></AlternatingItemStyle>
                                            <ItemStyle Font-Size="Smaller"></ItemStyle>
                                            <HeaderStyle Font-Bold="True" ForeColor="White" BackColor="Silver"></HeaderStyle>
                                            <Columns>
                                                <asp:TemplateColumn HeaderText="&nbsp;&nbsp;&nbsp;Criteria" HeaderStyle-Width="200px">
                                                    <HeaderStyle ForeColor="White"></HeaderStyle>
                                                    <ItemTemplate>
                                                        &nbsp;&nbsp;<asp:Label ID="lblCriteria" runat="server"></asp:Label>
                                                    </ItemTemplate>
                                                    <FooterTemplate>
                                                        &nbsp;&nbsp;<asp:Label ID="lblTotalScore" runat="server" Text="Total Score"></asp:Label>
                                                    </FooterTemplate>
                                                </asp:TemplateColumn>
                                                <%--<asp:TemplateColumn HeaderText="Minimum" HeaderStyle-Width="0px">
                                                <HeaderStyle ForeColor="White"></HeaderStyle>
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtMinScore" runat="server"></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>

                                                <asp:TemplateColumn HeaderText="Maximum" HeaderStyle-Width="0px">
                                                <HeaderStyle ForeColor="White"></HeaderStyle>
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtMaxScore" runat="server"></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateColumn>--%>
                                                <asp:TemplateColumn HeaderText="&nbsp;&nbsp;&nbsp;Score" HeaderStyle-Width="90px">
                                                    <HeaderStyle ForeColor="White"></HeaderStyle>
                                                    <ItemTemplate>
                                                        &nbsp;&nbsp;<asp:TextBox ID="txtScore" runat="server" MaxLength="10"
                                                            Style='text-align: right;'> 0.00</asp:TextBox>
                                                        <asp:TextBox ID="txtMinScore" Style="display: none;" runat="server"></asp:TextBox>
                                                        <asp:TextBox ID="txtMaxScore" Style="display: none;" runat="server"></asp:TextBox>
                                                    </ItemTemplate>
                                                    <FooterTemplate>
                                                        &nbsp;&nbsp;<asp:TextBox ID="txtScoreTotal" CssClass="form-control" TabIndex="1000" Style="text-align: right"
                                                            runat="server">0.00</asp:TextBox>
                                                    </FooterTemplate>
                                                </asp:TemplateColumn>
                                                <asp:TemplateColumn HeaderText="&nbsp;&nbsp;&nbsp;Remarks" HeaderStyle-Width="380px">
                                                    <HeaderStyle ForeColor="White"></HeaderStyle>
                                                    <ItemTemplate>
                                                        &nbsp;&nbsp;<asp:TextBox ID="txtRemarks" TextMode="MultiLine" MaxLength="51" runat="server"
                                                            Style='text-align: left;'> </asp:TextBox>
                                                    </ItemTemplate>
                                                    <FooterTemplate>
                                                        &nbsp;&nbsp;<asp:Label ID="lblRiskCategory" runat="server" Style="text-align: center; vertical-align: middle;"
                                                            Text="Risk Category"></asp:Label>
                                                        &nbsp;&nbsp;
                                                    <asp:TextBox ID="txtRiskCategory" TabIndex="1000" Style="text-align: center; vertical-align: middle;"
                                                        Width="60px" BorderStyle="None" runat="server"></asp:TextBox>
                                                    </FooterTemplate>
                                                </asp:TemplateColumn>
                                            </Columns>
                                            <PagerStyle Font-Size="Smaller" HorizontalAlign="Right" CssClass="GridPager" Mode="NumericPages"></PagerStyle>
                                        </asp:DataGrid>
                                    </div>
                                    <div class="form-group" id="trReviewercomment" runat="server">
                                        <label class="control-label" for="">
                                            Reviewer's Comment:
                                        </label>
                                        <asp:TextBox ID="reviewersComment" runat="server" TextMode="MultiLine" Width="515px"
                                            CssClass="required form-control"></asp:TextBox>
                                    </div>
                                    <div class="form-group" id="trReviewerdetails" runat="server">
                                        <div id="reviewDetails" runat="server">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <asp:Button ID="btnSaveRiskProfiling" runat="server" Text="Save" CssClass="btn btn-primary" OnClientClick="return validateDataGrid();"
                                            OnClick="btnSaveRiskProfiling_Click" />
                                        <asp:Button ID="btnSaveReview" runat="server" Text="Save Review" CssClass="btn btn-primary"
                                            OnClick="btnSaveReview_Click" />
                                        <%--<cc1:ConfirmButtonExtender ID="ConfirmButtonExtender1" runat="server" ConfirmText="Confirm To Save ?"
                                                        Enabled="True" TargetControlID="bntSubmit">
                                                    </cc1:ConfirmButtonExtender>--%>
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
<script type="text/javascript">
    function Autocomplete() {
        var urla = "../../Autocomplete.asmx/GetAgentListForRiskProfiling";

        $("#agent").autocomplete({

            source: function (request, response) {
                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: urla,
                    data: "{'keywordStartsWith':'" + request.term + "'}",
                    dataType: "json",
                    async: true,

                    success: function (data) {
                        response(
                            $.map(data.d, function (item) {
                                return {
                                    value: item.Value,
                                    key: item.Key
                                };
                            }));
                        window.parent.resizeIframe();
                    },

                    error: function (result) {
                        alert("Due to unexpected errors we were unable to load data");
                    }

                });
            },

            minLength: 1,

            select: function (event, ui) {
                var value = ui.item.value;
                var key = ui.item.key;
                //                SetValueById("agentUserList_agentName", value, "");
                var result = ui.item.value.split("|");
                var res = ui.item.value;
                SetValueById("<%=hddAgentId.ClientID %>", key, "");
            }

        });
    }

    Autocomplete();
</script>
</html>