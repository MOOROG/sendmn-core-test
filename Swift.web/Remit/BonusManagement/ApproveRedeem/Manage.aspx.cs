using Swift.DAL.Remittance;
using Swift.DAL.Remittance.BonusManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Text;

namespace Swift.web.Remit.BonusManagement.ApproveRedeem
{
	public partial class Manage : System.Web.UI.Page
	{
		private readonly SwiftLibrary _swiftLibrary = new SwiftLibrary();
		readonly RedeemProcessDao _redeemDao = new RedeemProcessDao();
		private readonly SwiftGrid _grid = new SwiftGrid();
		protected const string GridName = "grid_reedem";
		private const string ViewFunctionId = "20821300";

		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				Authenticate();
			}
			LoadGrid();
		}

		private void Authenticate()
		{
			_swiftLibrary.CheckAuthentication(ViewFunctionId);
		}

		private string GetCustomerId()
		{
			return GetStatic.ReadQueryString("customerId", "");
		}

		private void Delete()
		{
			string id = hddRedeemId.Value;
			if (string.IsNullOrWhiteSpace(id))
				return;
			var dbResult = _redeemDao.Delete(GetStatic.GetUser(), id);
			ManageMessageReject(dbResult);
		}

		private void ManageMessageApprove(DbResult dbResult)
		{
			if (dbResult.ErrorCode == "0")
			{
				var branchEmail = dbResult.Id;

				var obj = new BonusManagementDao();
				var dr = obj.SelectById(GetStatic.GetUser(), hddRedeemId.Value);
				var redeemReqTable = new StringBuilder();
				redeemReqTable.Append("<table border=\"1\">");
				redeemReqTable.Append("<tr>");
				redeemReqTable.Append("<th>Ref No.</th>");
				redeemReqTable.Append("<th>Sender Name</th>");
				redeemReqTable.Append("<th>Id Type</th>");
				redeemReqTable.Append("<th>Id Number</th>");
				redeemReqTable.Append("<th>Bonus Point</th>");
				redeemReqTable.Append("<th>Bonus Point Pending</th>");
				redeemReqTable.Append("<th>Requested Gift</th>");
				redeemReqTable.Append("<th>Requested Branch</th>");
				redeemReqTable.Append("<th>Requested User</th>");
				redeemReqTable.Append("<th>Requested Date and Time</th>");
				redeemReqTable.Append("</tr>");
				redeemReqTable.Append("<tr>");
				redeemReqTable.Append("<td>" + dr["refno"] + "</td>");
				redeemReqTable.Append("<td>" + dr["customerName"] + "</td>");
				redeemReqTable.Append("<td>" + dr["idType"] + "</td>");
				redeemReqTable.Append("<td>" + dr["idNumber"] + "</td>");
				redeemReqTable.Append("<td>" + dr["bonusPoint"] + "</td>");
				redeemReqTable.Append("<td>" + dr["bonusPointPending"] + "</td>");
				redeemReqTable.Append("<td>" + dr["bonusGiftItem"] + "</td>");
				redeemReqTable.Append("<td>" + dr["requestedBranch"] + "</td>");
				redeemReqTable.Append("<td>" + dr["requestedBy"] + "</td>");
				redeemReqTable.Append("<td>" + dr["requestedDate"] + "</td>");
				redeemReqTable.Append("</tr>");
				redeemReqTable.Append("</table>");

				var htmlAdmin = new StringBuilder();
				htmlAdmin.Append("Attn: Branch Operation Dept.<br/><br/>");
				htmlAdmin.Append("Bonus redeem request has been approved for the following.<br/><br/>");
				htmlAdmin.Append(redeemReqTable.ToString());
				htmlAdmin.Append("<br/><br/>");
				htmlAdmin.Append("Thank you");

				var msgSubjectAdmin = "Bonus Redeem Approval";
				var msgBodyAdmin = htmlAdmin.ToString();

				var htmlAgent = new StringBuilder();
				htmlAgent.Append("Dear " + dr["requestedBy"] + ",<br/><br/>");
				htmlAgent.Append("Bonus redeem request has been approved for the following.<br/><br/>");
				htmlAgent.Append(redeemReqTable.ToString());
				htmlAgent.Append("<br/><br/>");
				htmlAgent.Append("Thank you<br/>");
				htmlAgent.Append("GME Operation Department");

				var msgBodyAgent = "Bonus Redeem Approval";
				var msgSubjectAgent = htmlAgent.ToString();

			}
			LoadGrid();
			GetStatic.PrintMessage(Page, dbResult);
		}

		private void ManageMessageReject(DbResult dbResult)
		{
			if (dbResult.ErrorCode == "0")
			{
				var branchEmail = dbResult.Id;

				var obj = new BonusManagementDao();
				var dr = obj.SelectById(GetStatic.GetUser(), hddRedeemId.Value);
				var redeemReqTable = new StringBuilder();
				redeemReqTable.Append("<table border=\"1\">");
				redeemReqTable.Append("<tr>");
				redeemReqTable.Append("<th>Ref No.</th>");
				redeemReqTable.Append("<th>Sender Name</th>");
				redeemReqTable.Append("<th>Id Type</th>");
				redeemReqTable.Append("<th>Id Number</th>");
				redeemReqTable.Append("<th>Bonus Point</th>");
				redeemReqTable.Append("<th>Bonus Point Pending</th>");
				redeemReqTable.Append("<th>Requested Gift</th>");
				redeemReqTable.Append("<th>Requested Branch</th>");
				redeemReqTable.Append("<th>Requested User</th>");
				redeemReqTable.Append("<th>Requested Date and Time</th>");
				redeemReqTable.Append("</tr>");
				redeemReqTable.Append("<tr>");
				redeemReqTable.Append("<td>" + dr["refno"] + "</td>");
				redeemReqTable.Append("<td>" + dr["customerName"] + "</td>");
				redeemReqTable.Append("<td>" + dr["idType"] + "</td>");
				redeemReqTable.Append("<td>" + dr["idNumber"] + "</td>");
				redeemReqTable.Append("<td>" + dr["bonusPoint"] + "</td>");
				redeemReqTable.Append("<td>" + dr["bonusPointPending"] + "</td>");
				redeemReqTable.Append("<td>" + dr["bonusGiftItem"] + "</td>");
				redeemReqTable.Append("<td>" + dr["requestedBranch"] + "</td>");
				redeemReqTable.Append("<td>" + dr["requestedBy"] + "</td>");
				redeemReqTable.Append("<td>" + dr["requestedDate"] + "</td>");
				redeemReqTable.Append("</tr>");
				redeemReqTable.Append("</table>");

				var htmlAdmin = new StringBuilder();
				htmlAdmin.Append("Attn: Branch Operation Dept.<br/><br/>");
				htmlAdmin.Append("Bonus redeem request has been rejected for the following.<br/><br/>");
				htmlAdmin.Append(redeemReqTable.ToString());
				htmlAdmin.Append("<br/><br/>");
				htmlAdmin.Append("Thank you");

				var msgSubjectAdmin = "Bonus Redeem Rejected";
				var msgBodyAdmin = htmlAdmin.ToString();

				var htmlAgent = new StringBuilder();
				htmlAgent.Append("Dear " + dr["requestedBy"] + ",<br/><br/>");
				htmlAgent.Append("Bonus redeem request has been rejected for the following.<br/><br/>");
				htmlAgent.Append(redeemReqTable.ToString());
				htmlAgent.Append("<br/><br/>");
				htmlAgent.Append("Thank you<br/>");
				htmlAgent.Append("GME Operation Department");

				var msgBodyAgent = "Bonus Redeem Rejected";
				var msgSubjectAgent = htmlAgent.ToString();
			}
			LoadGrid();
			GetStatic.PrintMessage(Page, dbResult);
		}

		private void LoadGrid()
		{
			_grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("userName", "Customer User Name", "LT"),
                                      new GridFilter("agent", "Agent", "LT")
                                  };
			_grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("userName", "Customer User Name", "", "T"),
                                      new GridColumn("customerName", "Customer<br>Name", "", "T"),
                                      new GridColumn("redeemedDate", "Redeemed<br>Date", "", "T"),
                                      new GridColumn("agent", "Agent", "", "T"),
                                      new GridColumn("award", "Gift<br>Item", "", "T"),
									  new GridColumn("milageEarned", "Total Bonus<br>Point", "", "T"),
                                      new GridColumn("redeemed", "Redeemed", "", "T"),
                                      new GridColumn("availableBonus", "Bonus<br>Available", "", "T"),
                                  };


			_grid.GridType = 1;
			_grid.GridName = GridName;
			_grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
			_grid.ShowFilterForm = true;
			_grid.ShowPagingBar = true;
			_grid.PageSize = 100;
			_grid.GridWidth = 1000;
			_grid.GridMinWidth = 800;
			_grid.RowIdField = "refNo";
			_grid.ThisPage = "Manage";
			_grid.AllowCustomLink = true;
			_grid.AllowDelete = false;
			_grid.InputPerRow = 2;

			_grid.CustomLinkVariables = "refNo,customerId,redeemed,userName,mobile";
			_grid.CustomLinkText = "<input id='btn1' type='button' value='Approve' onclick='openApprovedRemarks(@refNo,@customerId,@redeemed,@mobile)' class='btn btn-primary'/>&nbsp;&nbsp<input id='btn2' type='button' value='Reject'  onclick='openRejectRemarks(@refNo,@customerId,@redeemed,@mobile)' class='btn btn-primary'/>&nbsp;&nbsp<input id='btn3' type='button' value='TXN History' onclick='ShowBonusPointInNewWindow(\"@userName\")' class='btn btn-primary'/>";
			_grid.SetComma();
			string sql = "EXEC [proc_bonusRedeemHistoryAdmin] @flag='p'";
			rpt_grid.InnerHtml = _grid.CreateGrid(sql);
		}
		private void Approve(string remarks)
		{
			if (string.IsNullOrWhiteSpace(hddRedeemId.Value))
				return;
			var dbResult = _redeemDao.ApproveRedeem(GetStatic.GetUser(), hddRedeemId.Value, hddCustomerId.Value, remarks, hddRedeemedBonus.Value);
			if (dbResult.ErrorCode == "2")
			{
				Response.Write("<script>alert('Redeem approval failed! This customer has negative value bonus point');</script>");

			}
			else
			{
				ManageMessage(dbResult);

			}
		}

		private void Reject(string remarks)
		{
			if (string.IsNullOrWhiteSpace(hddRedeemId.Value))
				return;
			var dbResult = _redeemDao.RejectRedeem(GetStatic.GetUser(), hddRedeemId.Value, hddCustomerId.Value, remarks, hddRedeemedBonus.Value);
			ManageMessage(dbResult);

		}
		private void ManageMessage(DbResult dbResult)
		{
			GetStatic.SetMessage(dbResult);
			if (dbResult.ErrorCode == "0")
			{

				GetStatic.PrintMessage(Page, dbResult);
				//GetStatic.SendSMS(hdnMobile.Value, dbResult.Extra);
				Response.Redirect("ApprovedList.aspx");
			}

			GetStatic.PrintMessage(Page, dbResult);

		}
		protected void btnApprove_Click(object sender, EventArgs e)
		{
			//string refNo = hddRedeemId.Value;
			//string customerId = hddCustomerId.Value;
			//if (!isRefresh)
			//{
			//    Approve();
			//}

		}

		protected void btnDelete_Click(object sender, EventArgs e)
		{
			if (!isRefresh)
			{
				if (string.IsNullOrWhiteSpace(hddRedeemId.Value))
					return;
				Delete();
			}
		}

		#region Mail Send
		private void ComposeAndSendMail(string branchEmail, string msgSubjectAdmin, string msgBodyAdmin, string msgSubjectAgent, string msgBodyAgent)
		{
			ComposeMail(branchEmail, msgSubjectAdmin, msgBodyAdmin, msgSubjectAgent, msgBodyAgent);
			SendMail();
		}

		readonly SmtpMailSetting _smtpMailSetting = new SmtpMailSetting();

		readonly SmtpMailSetting _mailToAgent = new SmtpMailSetting();

		private delegate void DoStuff(); //delegate for the action

		private void SendMail()
		{
			var myAction = new DoStuff(AsyncMailProcessing);
			//invoke it asynchrnously, control passes to next statement
			myAction.BeginInvoke(null, null);
		}

		private void AsyncMailProcessing()
		{
			var bw = new BackgroundWorker();

			// this allows our worker to report progress during work
			bw.WorkerReportsProgress = true;

			// what to do in the background thread
			bw.DoWork += new DoWorkEventHandler(
			delegate(object o, DoWorkEventArgs args)
			{
				var b = o as BackgroundWorker;
				_smtpMailSetting.SendSmtpMail(_smtpMailSetting);
				_mailToAgent.SendSmtpMail(_mailToAgent);
			});

			// what to do when progress changed (update the progress bar for example)
			bw.ProgressChanged += new ProgressChangedEventHandler(
			delegate(object o, ProgressChangedEventArgs args)
			{
				//label1.Text = string.Format("{0}% Completed", args.ProgressPercentage);
			});

			// what to do when worker completes its task (notify the user)
			bw.RunWorkerCompleted += new RunWorkerCompletedEventHandler(
			delegate(object o, RunWorkerCompletedEventArgs args)
			{
				GetStatic.PrintSuccessMessage(Page, "Mail sent successfully");
			});

			bw.RunWorkerAsync();
		}

		//Compose Email From Email Template for Admin
		private void ComposeMail(string branchEmail, string msgSubjectAdmin, string msgBodyAdmin, string msgSubjectAgent, string msgBodyAgent)
		{
			var obj = new SystemEmailSetupDao();
			var ds = obj.GetDataForEmail(GetStatic.GetUser(), "Bonus", "", "");
			if (ds == null)
				return;
			if (ds.Tables.Count == 0)
				return;
			if (ds.Tables.Count > 1)
			{
				//Email Server Settings
				if (ds.Tables[0].Rows.Count > 0)
				{
					var dr1 = ds.Tables[0].Rows[0];
					_smtpMailSetting.SmtpServer = dr1["smtpServer"].ToString();
					_smtpMailSetting.SmtpPort = Convert.ToInt32(dr1["smtpPort"]);
					_smtpMailSetting.SendEmailId = dr1["sendID"].ToString();
					_smtpMailSetting.SendEmailPwd = dr1["sendPSW"].ToString();
					_smtpMailSetting.EnableSsl = GetStatic.GetCharToBool(dr1["enableSsl"].ToString());

					_mailToAgent.SmtpServer = dr1["smtpServer"].ToString();
					_mailToAgent.SmtpPort = Convert.ToInt32(dr1["smtpPort"]);
					_mailToAgent.SendEmailId = dr1["sendID"].ToString();
					_mailToAgent.SendEmailPwd = dr1["sendPSW"].ToString();
					_mailToAgent.EnableSsl = GetStatic.GetCharToBool(dr1["enableSsl"].ToString());
				}
				if (ds.Tables[1].Rows.Count == 0)
					return;

				//Email Receiver
				if (ds.Tables[1].Rows.Count > 0)
				{
					var dt = ds.Tables[1];
					foreach (DataRow dr2 in dt.Rows)
					{
						if (!string.IsNullOrEmpty(_smtpMailSetting.ToEmails))
							_smtpMailSetting.ToEmails = _smtpMailSetting.ToEmails + ",";
						_smtpMailSetting.ToEmails = _smtpMailSetting.ToEmails + dr2["email"].ToString();
					}
				}

				_mailToAgent.ToEmails = branchEmail;

				//Email Subject and Body
				_smtpMailSetting.MsgSubject = msgSubjectAdmin;
				_smtpMailSetting.MsgBody = msgBodyAdmin;

				_mailToAgent.MsgSubject = msgSubjectAgent;
				_mailToAgent.MsgBody = msgBodyAgent;
			}
		}

		#endregion

		#region Browser Refresh
		private bool refreshState;
		private bool isRefresh;

		protected override void LoadViewState(object savedState)
		{
			object[] AllStates = (object[])savedState;
			base.LoadViewState(AllStates[0]);
			refreshState = bool.Parse(AllStates[1].ToString());
			if (Session["ISREFRESH"] != null && Session["ISREFRESH"] != "")
				isRefresh = (refreshState == (bool)Session["ISREFRESH"]);
		}

		protected override object SaveViewState()
		{
			Session["ISREFRESH"] = refreshState;
			object[] AllStates = new object[3];
			AllStates[0] = base.SaveViewState();
			AllStates[1] = !(refreshState);
			return AllStates;
		}

		#endregion

		protected void btnReject_Click(object sender, EventArgs e)
		{
			//string refNo = hddRedeemId.Value;
			//string customerId = hddCustomerId.Value;
			//if (!isRefresh)
			//{
			//    Reject();
			//}

		}

		protected void btnApproveReject_Click(object sender, EventArgs e)
		{
			if (hdnFlag.Value.ToString() == "approve")
			{
				Approve(txtremarks.Text);
			}
			else if (hdnFlag.Value.ToString() == "reject")
			{
				Reject(txtremarks.Text);
			}
			else
			{
				Response.Write("<script>alert('Something went wrong!')</script>");
			}
		}


	}
}