using Swift.DAL.BL.Remit.CreditRiskManagement.BalanceTopUp;
using Swift.web.Library;
using System;
using System.Text;

namespace Swift.web.Remit.CreditRiskManagement.BalanceTopUp
{
    public partial class LimitDetail : System.Web.UI.Page
    {
        private BalanceTopUpDao _obj = new BalanceTopUpDao();
        private SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            LoadLimitDetail();
        }

        private long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        private void LoadLimitDetail()
        {
            var dr = _obj.GetLimitDetail(GetStatic.GetUser(), GetAgentId().ToString());
            if (dr == null)
                return;
            var html = new StringBuilder("<table width=\"100%\" border=\"0\" class=\"TBL\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\">");
            html.Append("<tr>");
            html.Append("<th colspan = \"2\" style=\"text-align: left;\">" + dr["agentName"] + "</th>");
            html.Append("</tr>");
            html.Append("<tr><td>Max Limit:</td><td style=\"text-align: right;\">" + GetStatic.FormatData(dr["maxLimitAmt"].ToString(), "M") + "</td></tr>");
            html.Append("<tr><td>Per Top Up Limit:</td><td style=\"text-align: right;\">" + GetStatic.FormatData(dr["perTopUpAmt"].ToString(), "M") + "</td></tr>");
            html.Append("<tr><td>Yesterdays Topup:</td><td style=\"text-align: right;\">" + GetStatic.FormatData(dr["topUpTillYesterday"].ToString(), "M") + "</td></tr>");
            html.Append("<tr><td>Todays Topup:</td><td style=\"text-align: right;\">" + GetStatic.FormatData(dr["topUpToday"].ToString(), "M") + "</td></tr>");
            html.Append("<tr><td>Todays Cancelled:</td><td style=\"text-align: right;\">" + GetStatic.FormatData(dr["todaysCancel"].ToString(), "M") + "</td></tr>");
            html.Append("<tr><td>Todays EP:</td><td style=\"text-align: right;\">" + GetStatic.FormatData(dr["todaysEPI"].ToString(), "M") + "</td></tr>");
            html.Append("<tr><td>Todays PO:</td><td style=\"text-align: right;\">" + GetStatic.FormatData(dr["todaysPOI"].ToString(), "M") + "</td></tr>");
            html.Append("<tr><td>Todays Fund Deposit:</td><td style=\"text-align: right;\">" + GetStatic.FormatData(dr["todaysFundDeposit"].ToString(), "M") + "</td></tr>");
            Response.Write(html.ToString());
        }
    }
}