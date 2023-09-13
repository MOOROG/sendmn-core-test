using Swift.DAL.Remittance.BonusManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.IO;
using System.Text;
using System.Web.UI;

namespace Swift.web.Remit.BonusManagement.RedeemProcess
{
	public partial class Receipt : System.Web.UI.Page
	{
		RemittanceDao sdao = new RemittanceDao();
		readonly StaticDataDdl _sdd = new StaticDataDdl();
		readonly RedeemProcessDao _objDao = new RedeemProcessDao();
		private const string ViewFunctionId = "40132700";
		protected void Page_Load(object sender, EventArgs e)
		{
			HeadMessage();
			string tokenNo = GetStatic.ReadQueryString("RefNo", "");
			string user = GetStatic.GetUser();
			GenerateBonusReceipt(tokenNo, user);
			HeadMessage();
		}

		private void HeadMessage()
		{
			var message = _objDao.PrintReceiptHead(GetStatic.GetUser(), GetStatic.GetBranch());
			if (message == null)
				return;
			var strMsg = message["headMessage"].ToString();
			divHeadMsg.InnerHtml = HeadMessageToHtml(strMsg);
			agentName.InnerHtml = GetStatic.GetAgentName();
		}

		private string HeadMessageToHtml(string headMessage)
		{
			var list = headMessage.Split('|');
			var returnMsg = "<b style=\"font-size:20px;\">" + list[0] + "</b><br />";
			for (int i = 1; i < list.Length; i++)
			{
				returnMsg += list[i] + "<br />";
			}
			return returnMsg;
		}
		protected void GenerateBonusReceipt(string tokenId, string user)
		{
			double balancePoints = 0;
			var date = DateTime.Now.ToString();
			var dt = _objDao.PrintBonushReceipt(user, tokenId, GetStatic.GetBranch());
			if (dt.Rows.Count == 0)
			{
				var dbResult = new DbResult();
				dbResult.Msg = "Token Not Found";
				GetStatic.SetMessage(dbResult);
				Response.Redirect("Manage.aspx");
			}
			else
			{
				var dr = dt.Rows[0];
				var html = new StringBuilder("<table cellpadding=\"0\" cellspacing=\"0\"  width=\"100%\">");

				html.Append("<tr>");
				html.Append("<td colspan=\"8\" height=\"20px\">");
				html.Append("</td>");
				html.Append("</tr>");

				html.Append("<tr>");
				html.Append("<td colspan=\"8\" height=\"20px\"><center><b> IME Bonus Points Receipt (<span style=\"color:red\">Re-Print</span>)</b></center>");
				html.Append("</td>");
				html.Append("</tr>");

				html.Append("<tr>");
				html.Append("<td align=\"Left\" height=\"20px\"><b>Ref No: </b>" + dr["redeemId"]);
				html.Append("</td>");
				html.Append("</tr>");

				html.Append("<tr>");
				html.Append("<td height=\"20px\"><b>Branch: </b>" + dr["agentName"]);
				html.Append("</td>");
				html.Append("</tr>");

				html.Append("<tr>");
				html.Append("<td colspan=\"8\" height=\"20px\"><b>Date/Time: </b>" + date + "<br/><b>Customer Name: </b>" + dr["customerName"] + "<br/><b>" + dr["idType"] + ": </b>" + dr["idNumber"] + "<br/><b>Membership Id: </b>" + dr["membershipId"] + "<br/>");
				html.Append("</td>");
				html.Append("</tr>");

				html.Append("<tr>");
				html.Append("<td>");

				html.Append("<table border=\"1\" bordercolor=\"#000000\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">");
				html.Append("<tr>");
				html.Append("<th style=\"text-align: right;font-weight:bold;\"><div align=\"left\"><b>Sno</b></div>");
				html.Append("</th>");
				html.Append("<th style=\"text-align: right;font-weight:bold;\"><div align=\"left\"><b>Desc</b></div>");
				html.Append("</th>");
				html.Append("<th style=\"text-align: right;font-weight:bold;\"><div align=\"left\"><b>Points</b></div>");
				html.Append("</th>");
				html.Append("</tr>");

				html.Append("<tr>");
				html.Append("<td>1");
				html.Append("</td>");
				html.Append("<td>Available Mileage");
				html.Append("</td>");
				html.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr["currentMilage"].ToString()) + "</div>");
				html.Append("</td>");
				html.Append("</tr>");

				html.Append("<tr>");
				html.Append("<td>2");
				html.Append("</td>");
				html.Append("<td>Redeem");
				html.Append("</td>");
				html.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr["DeductMilage"].ToString()) + "</div>");
				html.Append("</td>");
				html.Append("</tr>");

				balancePoints = GetStatic.ParseDouble(dr["currentMilage"].ToString()) - GetStatic.ParseDouble(dr["DeductMilage"].ToString());

				html.Append("<tr>");
				html.Append("<td colspan=2 style=\"text-align: right;font-weight:bold;\">Redeem Available");
				html.Append("</td>");
				html.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(balancePoints.ToString()) + "</div>");
				html.Append("</td>");
				html.Append("</tr>");
				html.Append("</table>");

				html.Append("</td>");
				html.Append("</tr>");
				html.Append("</table>");

				rptReport.InnerHtml = html.ToString();
				redeemed.Text = dr["detailTitle"].ToString();
				red.Visible = true;
				prepareBy.InnerHtml = GetStatic.GetUser();
				ShowReport();
			}
		}

		protected void ShowReport()
		{
			var sb = new StringBuilder();
			officeReceipt.RenderControl(new HtmlTextWriter(new StringWriter(sb)));
			customerReceipt.InnerHtml = sb.ToString();
		}
	}
}