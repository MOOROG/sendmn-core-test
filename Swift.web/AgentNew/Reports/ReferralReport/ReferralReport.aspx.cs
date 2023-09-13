using Swift.DAL.Remittance.Partner;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentNew.Reports.ReferralReport
{
    public partial class ReferralReport : System.Web.UI.Page
    {
        protected PartnerDao _dao = new PartnerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateReport();
            }
        }

        protected string GetDate()
        {
            return GetStatic.ReadQueryString("asOfDate", "");
        }

        private void PopulateReport()
        {
            string asOfDate = GetStatic.ReadQueryString("asOfDate", "");
            string flag = GetStatic.ReadQueryString("flag", "");
            string user = GetStatic.GetUser();

            DataSet ds = _dao.CashStatusReportReferral(user, asOfDate, flag, GetStatic.GetSettlingAgent());

            StringBuilder sb = new StringBuilder("");
            int sNo = 0;
            double totalOpeningAmt = 0;
            double totalInAmt = 0;
            double totalOutAmt = 0;
            double totalClosingAmt = 0;
            string agentId = "";

            foreach (DataRow item in ds.Tables[0].Rows)
            {
                agentId = item["AGENTID"].ToString();
                DataRow[] rows = ds.Tables[1].Select("BRANCH_ID = ('" + agentId + "')");

                sb.AppendLine("<tr>");
                sb.AppendLine("<td></td>");
                sb.AppendLine(GetRows(item["AGENTNAME"].ToString(), rows, ref sNo, ref totalOpeningAmt, ref totalInAmt, ref totalOutAmt, ref totalClosingAmt));
            }
            sb.AppendLine("<tr><td colspan='2' align='right'><b>Grand Total:</b></td><td align='right'><b>" + GetStatic.ShowDecimal(totalOpeningAmt.ToString()) + "</b></td>");
            sb.AppendLine("<td align='right'><b>" + GetStatic.ShowDecimal(totalInAmt.ToString()) + "</td>");
            sb.AppendLine("<td align='right'><b>" + GetStatic.ShowDecimal(totalOutAmt.ToString()) + "</td>");
            sb.AppendLine("<td align='right'><b>" + GetStatic.ShowDecimal(totalClosingAmt.ToString()) + "</t<td>");
            sb.AppendLine("</tr>");
            cashCollectedList.InnerHtml = sb.ToString();
        }

        private string GetRows(string agentName, DataRow[] rows, ref int sNo, ref double totalOpeningAmt, ref double totalInAmt, ref double totalOutAmt, ref double totalClosingAmt)
        {
            StringBuilder sb = new StringBuilder();
            double totalAgentOpening = 0;
            double totalAgentIn = 0;
            double totalAgentOut = 0;
            double totalAgentClosing = 0;
            foreach (DataRow item in rows)
            {
                sNo++;
                if (item["ADD_BRANCH"].ToString() == "Y")
                {
                    totalAgentOpening += GetDoubleValue(item["OPENING_BALANCE"].ToString());
                    totalAgentIn += GetDoubleValue(item["IN_AMOUNT"].ToString());
                    totalAgentOut += GetDoubleValue(item["OUT_AMOUNT"].ToString());
                    totalAgentClosing += GetDoubleValue(item["CLOSING_BALANCE"].ToString());
                }

                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + sNo + "</td>");
                sb.AppendLine("<td>" + item["AGENT_NAME"].ToString() + "</td>");
                sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["OPENING_BALANCE"].ToString()) + "</ td > ");
                sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["IN_AMOUNT"].ToString()) + "</ td > ");
                sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["OUT_AMOUNT"].ToString()) + "</ td > ");
                sb.AppendLine("<td align='right'>" + GetStatic.ShowDecimal(item["CLOSING_BALANCE"].ToString()) + "</ td > ");
                sb.AppendLine("</tr>");
            }
            totalOpeningAmt += totalAgentOpening;
            totalInAmt += totalAgentIn;
            totalOutAmt += totalAgentOut;
            totalClosingAmt += totalAgentClosing;

            return "<td align='right'><b>" + agentName + "</b></td><td align='left'><b>" + GetStatic.ShowDecimal(totalAgentOpening.ToString()) + "</b></td>" +
                "<td align='left'><b>" + GetStatic.ShowDecimal(totalAgentIn.ToString()) + "</b></td>" +
                "<td align='left'><b>" + GetStatic.ShowDecimal(totalAgentOut.ToString()) + "</b></td>" +
                "<td align='left'><b>" + GetStatic.ShowDecimal(totalAgentClosing.ToString()) + "</b></td>" +
                sb.ToString();
        }

        public double GetDoubleValue(string inPutVal)
        {
            double outPut = 0;
            Double.TryParse(inPutVal, out outPut);
            return outPut;
        }
    }
}