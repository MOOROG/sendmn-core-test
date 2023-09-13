<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeBehind="ManageBranchWiseLimit.aspx.cs" Inherits="Swift.web.Remit.CashAndVault.ManageBranchWise" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="/ui/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
    <link href="/ui/css/style.css" rel="stylesheet" />
    <link href="/ui/font-awesome/css/font-awesome.css" rel="stylesheet" />
    <script src="/ui/js/jquery.min.js"></script>
    <script src="/ui/bootstrap/js/bootstrap.min.js"></script>
    <script src="/js/swift_grid.js" type="text/javascript"> </script>
    <script src="/js/functions.js"></script>
    <link href="/js/jQuery/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="/js/jQuery/jquery.min.js"></script>
    <script type="text/javascript" src="/js/jQuery/jquery-ui.min.js"></script>
    <script src="/js/swift_calendar.js" type="text/javascript"></script>
    <style>
        .table .table {
            background-color: #F5F5F5 !important;
        }
    </style>
    <script type="text/javascript">
	    $(document).ready(function () {
			$('.agent-type').click(function () {
				if ($(this).val() == 'JME Branch') {
					PopulateAgent('Y');
				}
				else if ($(this).val() == 'External Agent') {
					PopulateAgent('N');
				}
				$('.agent-type').not(this).propAttr('checked', false);
			});

			PopulateRuleDetails();
		});

		function PopulateRuleDetails() {
			var ruleId = '<%=GetRuleId()%>';
			var agentId = '<%=GetAgentId()%>';
		    var dataToSend = { MethodName: 'PopulateForm', RuleId: ruleId, AgentId: agentId };

				var options =
					{
						url: '<%=ResolveUrl("ManageBranchWiseLimit.aspx") %>?x=' + new Date().getTime(),
						data: dataToSend,
						dataType: 'JSON',
						type: 'POST',
						success: function (response) {
							var data = jQuery.parseJSON(response);
							$('#cashHoldLimit').val(data[0].cashHoldLimit);
							$('#perTopUpLimit').val(data[0].perTopUpLimit);
							$('#ddlruleType').val(data[0].ruleType);
							if (data[0].isJMEBranch == 'Y') {
								$('#jmeBranchCheckBox').propAttr('checked', true);
								$('#externalAgentCheckBox').propAttr('checked', false);
							}
							else {
								$('#jmeBranchCheckBox').propAttr('checked', false);
								$('#externalAgentCheckBox').propAttr('checked', true);
							}
							PopulateAgent(data[0].isJMEBranch, data[0].agentId);
						}
					};
				$.ajax(options);
				return true;
		};
		function Save_Clicked() {
			var reqField = "ddlAgentBranch,cashHoldLimit,";
			if (ValidRequiredField(reqField) == false) {
				return false;
			}

			var RuleId = '<%=GetRuleId()%>';
			var DdlAgentBranch = $("#ddlAgentBranch option:selected").val();
			var CashHoldLimit = $("#cashHoldLimit").val();
			var PerTopUpLimit = $("#perTopUpLimit").val();
			var Ruletype = $("#ddlruleType option:selected").val();
			var dataToSend = {
				MethodName: 'SaveCashAndVault', ddlAgentBranch: DdlAgentBranch,
				cashHoldLimit: CashHoldLimit, perTopUpLimit: PerTopUpLimit,
				ddlruleType: Ruletype, ruleId: RuleId
			};

			var options =
				{
					url: '<%=ResolveUrl("ManageBranchWiseLimit.aspx") %>?x=' + new Date().getTime(),
					data: dataToSend,
					dataType: 'JSON',
					type: 'POST',
					success: function (response) {
						var data = jQuery.parseJSON(response);
						alert(data[0].msg);
						window.location.href = "List.aspx";
					}
				};
			$.ajax(options);
			return true;
		};

		function PopulateAgent(flag, selectedValue) {
			var dataToSend = { MethodName: 'PopulateBranchAndAgents', Flag: flag };

			var options =
				{
					url: '<%=ResolveUrl("ManageBranchWiseLimit.aspx") %>?x=' + new Date().getTime(),
					data: dataToSend,
					dataType: 'JSON',
					type: 'POST',
					success: function (response) {
						ParseResponseDdlList(response, selectedValue);
					}
				};
			$.ajax(options);
			return true;
		};

		function ParseResponseDdlList(response, selectedValue) {
			var data = jQuery.parseJSON(response);
			var ddl = GetElement("ddlAgentBranch");
			$(ddl).empty();

			var option = document.createElement("option");
			option.text = 'Select Agent/Branch';
			option.value = '';

			ddl.options.add(option);

			for (var i = 0; i < data.length; i++) {
				option = document.createElement("option");
				option.text = data[i].agentName.toUpperCase();
				option.value = data[i].agentId;
				if (selectedValue == data[i].agentId) {
					option.setAttribute('selected', 'selected');
				}

				try {
					ddl.options.add(option);
				}
				catch (e) {
					alert(e);
				}
			}
		};
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" ID="sm1"></asp:ScriptManager>
        <div class="page-wrapper">
            <div class="row">
                <div class="col-sm-12">
                    <div class="page-title">
                        <h1></h1>
                        <ol class="breadcrumb">
                            <li><a href="../../Front.aspx" target="mainFrame"><i class="fa fa-home"></i></a></li>
                            <li class="active"><a>Cash And Vault</a></li>
                            <li class="active"><a href="List.aspx">BranchWise Cash And Vault Setup</a></li>
                        </ol>
                    </div>
                </div>
            </div>
            <div class="report-tab" runat="server" id="regUp">
                <!-- Nav tabs -->
                <%--	<ul class="nav nav-tabs" role="tablist">
					<li role="presentation" class="active"><a href="ManageBranchWiseLimit.aspx">Assign Limit</a></li>
				</ul>--%>
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane" id="List">
                    </div>
                    <div role="tabpanel" id="Manage">
                        <div class="">
                            <div class="register-form">
                                <div class="panel panel-default clearfix m-b-20">
                                    <div class="panel-heading" runat="server">
                                        <h4 class="panel-title" runat="server">Assign Limit Details</h4>
                                    </div>
                                    <div class="panel-body">
                                        <div class="col-md-12" style="display: none;">
                                            <div class="form-group">
                                                <input type="checkbox" value="JME Branch" id="jmeBranchCheckBox" class="agent-type" />&nbsp;<label for="jmeBranchCheckBox">JME Branch</label>
                                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" value="External Agent" id="externalAgentCheckBox" class="agent-type" />&nbsp;<label for="externalAgentCheckBox">External Agent</label>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Agent/Branch :<span class="errormsg">*</span></label>
                                                <asp:DropDownList runat="server" ID="ddlAgentBranch" name="branchList" CssClass="form-control" disabled="true">
                                                    <asp:ListItem Text="Select Agent/Branch Type" Value=""></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Cash Hold Limit:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="cashHoldLimit" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                        <div class="col-md-6" style="display: none">
                                            <div class="form-group">
                                                <label>Per Top Up Limit:<span class="errormsg">*</span></label>
                                                <asp:TextBox ID="perTopUpLimit" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Rule Type<span class="errormsg">*</span></label>
                                                <asp:DropDownList runat="server" ID="ddlruleType" name="ruleType" CssClass="form-control">
                                                    <asp:ListItem Text="Hold" Value="H"></asp:ListItem>
                                                    <asp:ListItem Text="Block" Value="B"></asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <div class="col-md-6">
                                            <asp:Button ID="Save" Text="Save" runat="server" OnClientClick="return Save_Clicked()" CssClass="btn btn-primary m-t-25" />
                                        </div>
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
</html>