using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.RemittanceSystem.RemittanceReports.WeeklyMitasuReport
{
    public partial class WeeklyMitasuReportFormat : System.Web.UI.Page
    {
        protected TranReportDao _dao = new TranReportDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateReport();
            }
        }

        protected string GetFromDate()
        {
            return GetStatic.ReadQueryString("from", "");
        }
        protected string GetToDate()
        {
            return GetStatic.ReadQueryString("to", "");
        }

        private void PopulateReport()
        {
            string fromDate = GetStatic.ReadQueryString("from", "");
            string toDate = GetStatic.ReadQueryString("to", "");

            var dt = _dao.MitasuReportWeekly(GetStatic.GetUser(), fromDate, toDate);
            double nepalMufj = 0, nepalJPPost = 0, nepalCash = 0, IndonesiaJPPost = 0, total1 = 0, returnJPNepal = 0, returnMUFJ = 0,
                returnMUFJInd = 0, returnCash = 0, return2 = 0, dailyPayout = 0, serviceCharge = 0, totalIncoming = 0,
                totalPayout = 0, mitatsusaimu = 0, total3 = 0;

            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }

            StringBuilder sb = new StringBuilder();
            int count = 0;
            foreach (DataRow item in dt.Rows)
            {
                nepalMufj += GetDoubleValue(item["MUFJ"].ToString());
                nepalJPPost += GetDoubleValue(item["JP_POST"].ToString());
                nepalCash += GetDoubleValue(item["CASH_COLLECT"].ToString());
                IndonesiaJPPost += GetDoubleValue(item["INDONESIA_JP_POST"].ToString());
                total1 += GetDoubleValue(item["TOTAL_COLLECT"].ToString());

                returnJPNepal += GetDoubleValue(item["JP_POST_RETURN"].ToString());
                returnMUFJ += GetDoubleValue(item["MUFJ_RETURN"].ToString());
                returnMUFJInd += GetDoubleValue(item["INDONESIA_JP_POST_RETURN"].ToString());
                returnCash += GetDoubleValue(item["CASH_COLLECT_RETURN"].ToString());
                return2 += GetDoubleValue(item["TOTAL_RETURN"].ToString());

                dailyPayout += GetDoubleValue(item["DAILY_PAYOUT"].ToString());
                serviceCharge += GetDoubleValue(item["SERVICE_CHARGE"].ToString());
                totalIncoming += GetDoubleValue(item["TOTAL_INCOMING"].ToString());
                totalPayout += GetDoubleValue(item["TOTAL_PAYOUT"].ToString());
                if (count > 0)
                {
                    mitatsusaimu += GetDoubleValue(item["NEW_MITATSUSAIMU_VALUE"].ToString());
                    total3 += GetDoubleValue(item["MITATSUSAIMU_CALC"].ToString());
                }

                sb.AppendLine("<tr>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetDayJapanese(item["DAY"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + item["DATE"].ToString() + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["JP_POST"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["MUFJ"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["CASH_COLLECT"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["INDONESIA_JP_POST"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["TOTAL_COLLECT"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["JP_POST_RETURN"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["MUFJ_RETURN"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["INDONESIA_JP_POST_RETURN"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["CASH_COLLECT_RETURN"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["TOTAL_RETURN"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["DAILY_PAYOUT"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["SERVICE_CHARGE"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["TOTAL_INCOMING"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["TOTAL_PAYOUT"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["NEW_MITATSUSAIMU_VALUE"].ToString()) + "</td>");
                sb.AppendLine("<td style='vertical-align:top;'>" + GetStatic.ShowDecimal(item["MITATSUSAIMU_CALC"].ToString()) + "</td>");
                sb.AppendLine("</tr>");

                count++;
            }

            sb.AppendLine("<tr>");
            sb.AppendLine("<td style='vertical-align:top;'></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>Total</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(nepalJPPost.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(nepalMufj.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(nepalCash.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(IndonesiaJPPost.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(total1.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(returnJPNepal.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(returnMUFJ.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(returnMUFJInd.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(returnCash.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(return2.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(dailyPayout.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(serviceCharge.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(totalIncoming.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(totalPayout.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(mitatsusaimu.ToString()) + "</b></td>");
            sb.AppendLine("<td style='vertical-align:top;'><b>" + GetStatic.ShowDecimal(total3.ToString()) + "</b></td>");
            sb.AppendLine("</tr>");

            rpt.InnerHtml = sb.ToString();
        }

        public double GetDoubleValue(string inPutVal)
        {
            double outPut = 0;
            Double.TryParse(inPutVal, out outPut);
            return outPut;
        }

        private string GetDayJapanese(string day)
        {
            switch (day)
            {
                case "Sun":
                    return "日";
                case "Mon":
                    return "月";
                case "Tue":
                    return "火";
                case "Wed":
                    return "水";
                case "Thu":
                    return "木";
                case "Fri":
                    return "金";
                case "Sat":
                    return "土";
                default:
                    return "";
            }
        }
    }
}