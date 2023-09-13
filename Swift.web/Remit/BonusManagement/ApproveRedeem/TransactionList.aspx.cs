using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.BonusManagement.ApproveRedeem
{
	public partial class TransactionList : System.Web.UI.Page
	{
		private const string GridName = "gdBonusTXNDetail";
		private readonly SwiftGrid _grid = new SwiftGrid();
		private readonly SwiftLibrary _sl = new SwiftLibrary();
		protected void Page_Load(object sender, EventArgs e)
		{
			LoadStatement();
		}

		private void LoadStatement()
		{
			var userName = GetStatic.ReadQueryString("userName", "0");
			//discount.HRef = "DiscountTXNHistory.aspx?membershipId=" + membershipId;
			var sql = "[proc_bonusRedeemHistoryAgent] @userName='" + userName + "',@flag='bonusTXNDetail'";
			var dt = new RemittanceDao().ExecuteDataTable(sql);
			var str = new StringBuilder();


			str.Append("<table class='TBLData' style=\"width:100%;\" border=\"1\">");
			if (dt.Rows.Count.Equals(0))
			{
				str.Append("<tr>");
				str.Append("<td><b>No Records Found.</b></td>");
				str.Append("</tr>");
				str.Append("</table>");
				rpt_grid.InnerHtml = str.ToString();
				return;
			}

			str.Append("<tr>");
			str.Append("<th>SN</th>");
			str.Append("<th>Date</th>");
			str.Append("<th>Particulars</th>");
			str.Append("<th>Control No</th>");
			str.Append("<th>Amount</th>");
			str.Append("<th>Bonus Point</th>");
			str.Append("<th>Balance Bonus Point</th>");
			str.Append("</tr>");

			var runningBal = 0.00;
			var rowCount = 1;
			var sn = 1;
			foreach (DataRow row in dt.Rows)
			{
				var thisBal = GetStatic.ParseDouble(row["bonusPoint"].ToString());
				var thisBalText = thisBal >= 0 ? thisBal.ToString() : "(" + Math.Abs(thisBal).ToString() + ")";
				runningBal += thisBal;
				var runningBalText = runningBal >= 0 ? runningBal.ToString() : "(" + Math.Abs(runningBal).ToString() + ")";
				str.Append(
						  ++rowCount % 2 == 1 ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
											  : "<tr class=\"evenbg\" onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">"
						);
				rowCount++;

				str.Append(string.Format("<td style=\"text-align:center;\">{0}</td>", sn.ToString()));
				str.Append(string.Format("<td style=\"text-align:left;\">{0}</td>", row["createdDate"].ToString()));
				str.Append(string.Format("<td style=\"text-align:left;\">{0}</td>", row["remarks"].ToString()));
				str.Append(string.Format("<td style=\"text-align:left;\">{0}</td>", row["controlNo"].ToString()));
				str.Append(string.Format("<td style=\"text-align:right;\">{0}</td>", GetStatic.FormatData(row["pAmt"].ToString(), "M")));
				str.Append(string.Format("<td style=\"text-align:right;\">{0}</td>", thisBalText));
				str.Append(string.Format("<td style=\"text-align:right;\">{0}</td>", runningBalText));
				str.Append("</tr>");

				sn++;
			}

			str.Append("</table>");
			rpt_grid.InnerHtml = str.ToString();

		}
	}
}