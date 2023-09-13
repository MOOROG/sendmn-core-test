using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.RemittanceSystem.RemittanceReports.MitatsuCheck
{
    public partial class ViewReport : System.Web.UI.Page
    {
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private string ViewFunctionId = "20316000";
        protected TranReportDao _dao = new TranReportDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                PopulateReport();
            }
        }

        private void PopulateReport()
        {
            string fromDate = GetStatic.ReadQueryString("from", "");
            string toDate = GetStatic.ReadQueryString("to", "");

            var dt = _dao.CheckMitatsu(GetStatic.GetUser(), fromDate, toDate);

            if (null == dt || dt.Rows.Count == 0)
            {
                rpt.InnerHtml = "<tr><td colspan='7' align='center'>No data to display!</td></tr>";
            }

            StringBuilder sb = new StringBuilder();
            int sNo = 1;
            double unpaid = 0, untransacted = 0, unreconciled = 0, wallet = 0;
            DateTime date;
            DateTime.TryParse(fromDate, out date);

            foreach (DataRow item in dt.Rows)
            {
                unpaid = (item["TEMP139286032"].ToString() == "A") ? unpaid : GetStatic.ParseDouble(item["TEMP139286032"].ToString());
                untransacted = (item["TEMP101139273793"].ToString() == "A") ? untransacted : GetStatic.ParseDouble(item["TEMP101139273793"].ToString());
                unreconciled = (item["TEMP139265123"].ToString() == "A") ? unreconciled : GetStatic.ParseDouble(item["TEMP139265123"].ToString());
                wallet = (item["WALLET"].ToString() == "A") ? wallet : GetStatic.ParseDouble(item["WALLET"].ToString());

                if (date <= Convert.ToDateTime(item["TRAN_DATE"].ToString()))
                {
                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td>" + sNo + "</td>");
                    sb.AppendLine("<td>" + item["TRAN_DATE"].ToString() + "</td>");
                    sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac(unpaid.ToString()) + "</td>");
                    sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac(unreconciled.ToString()) + "</td>");
                    sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac(untransacted.ToString()) + "</td>");
                    sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac(wallet.ToString()) + "</td>");
                    sb.AppendLine("<td align='right' style='font-weight: bold;'>" + GetStatic.GetNegativeFigureOnBrac((unpaid + unreconciled + untransacted + wallet).ToString()) + "</td>");
                    sb.AppendLine("</tr>");

                    sNo++;
                }
            }

            rpt.InnerHtml = sb.ToString();
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
    }
}