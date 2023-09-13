using Swift.DAL.Remittance.Partner;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.Transaction.Reports.ChashCollected
{
    public partial class CashCollectedList : System.Web.UI.Page
    {
        protected PartnerDao _dao = new PartnerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateReport();
            }
        }

        protected string GetFromDate()
        {
            return GetStatic.ReadQueryString("fromDate", "");
        }

        protected string GetToDate()
        {
            return GetStatic.ReadQueryString("toDate", "");
        }

        private void PopulateReport()
        {
            string flag = GetStatic.ReadQueryString("flag", "");
            string fromDate = GetStatic.ReadQueryString("fromDate", "");
            string toDate = GetStatic.ReadQueryString("toDate", "");
            string type = GetStatic.ReadQueryString("type", "");
            string agentId = GetStatic.ReadQueryString("agentId", "");
            string user = GetStatic.GetUser();

            DataSet ds = _dao.GetCashCollectList(user, flag, fromDate, toDate, type, agentId);
            if (flag == "drill-down")
            {
                drillDown.Visible = true;
                main1.Visible = false;
                agentName.InnerHtml = ": " + GetStatic.ReadQueryString("agentName", "") + (!string.IsNullOrEmpty(GetStatic.ReadQueryString("referralName", "")) ? " >> " + GetStatic.ReadQueryString("referralName", "") : "");
                PopulateDrillDownRpt(ds);
                return;
            }
            drillDown.Visible = false;
            main1.Visible = true;

            StringBuilder sb = new StringBuilder("");
            int sNo = 0;
            double totalAmt = 0;
            foreach (DataRow item in ds.Tables[0].Rows)
            {
                sNo++;
                agentId = item["AGENT_ID"].ToString();
                DataRow[] rows = ds.Tables[1].Select("AGENT_ID = ('" + agentId + "')");

                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + sNo.ToString() + "</td>");
                sb.AppendLine("<td><b>" + item["AGENT_NAME"].ToString() + "</b></td>");
                sb.AppendLine(GetRows(rows, ref sNo, ref totalAmt));
            }
            sb.AppendLine("<tr><td colspan='3' align='right'><b>Grand Total:</b></td><td align='right'><b>" + GetStatic.ShowDecimal(totalAmt.ToString()) + "</b></td>");
            cashCollectedList.InnerHtml = sb.ToString();
        }

        private void PopulateDrillDownRpt(DataSet ds)
        {
            StringBuilder sb = new StringBuilder("");
            int sNo = 0;
            double totalAmt = 0;
            foreach (DataRow item in ds.Tables[0].Rows)
            {
                totalAmt += GetDoubleValue(item["TRAN_AMT"].ToString());
                sNo++;
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + sNo.ToString() + "</td>");
                sb.AppendLine("<td>" + item["TRAN_PARTICULAR"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["TRAN_DATE"].ToString() + "</td>");
                sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["TRAN_AMT"].ToString()) + "</td>");
                sb.AppendLine("</tr>");
            }
            sb.AppendLine("<tr><td colspan='3' align='right'><b>Grand Total:</b></td><td align='right'><b>" + GetStatic.ShowDecimal(totalAmt.ToString()) + "</b></td></tr>");
            drillDownBody.InnerHtml = sb.ToString();
        }

        private string GetRows(DataRow[] rows, ref int sNo, ref double totalAmt)
        {
            StringBuilder sb = new StringBuilder();
            double totalAgent = 0;
            foreach (DataRow item in rows)
            {
                string agentId = string.IsNullOrEmpty(item["REFERRAL_CODE"].ToString()) ? item["AGENT_ID"].ToString() : item["REFERRAL_CODE"].ToString();
                string type = string.IsNullOrEmpty(item["REFERRAL_CODE"].ToString()) ? "A" : "R";
                sNo++;
                totalAgent += GetDoubleValue(item["CASH_COLLECTED"].ToString());
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + sNo + "</td>");
                sb.AppendLine("<td></td>");
                sb.AppendLine("<td>" + item["REFERRAL_NAME"].ToString() + "</td>");
                sb.AppendLine("<td align='right'><a href=\"CashCollectedList.aspx?flag=drill-down&type=" + type + "&fromDate=" + GetFromDate() + "&toDate=" + GetToDate() + "&agentId=" + agentId + "&agentName=" + item["AGENT_NAME"].ToString() + "&referralName=" + item["REFERRAL_NAME"].ToString() + "\">" + GetStatic.ShowDecimal(GetDoubleValue(item["CASH_COLLECTED"].ToString()).ToString()) + "</a></ td > ");
                sb.AppendLine("</tr>");
            }
            totalAmt += totalAgent;
            return "<td></td><td><b>" + GetStatic.ShowDecimal(totalAgent.ToString()) + "</b></td></tr>" + sb.ToString();
        }

        public double GetDoubleValue(string inPutVal)
        {
            double outPut = 0;
            Double.TryParse(inPutVal, out outPut);
            return outPut;
        }
    }
}