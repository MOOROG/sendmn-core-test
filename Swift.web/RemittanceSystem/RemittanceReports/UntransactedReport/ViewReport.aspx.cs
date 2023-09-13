using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.RemittanceSystem.RemittanceReports.UntransactedReport
{
    public partial class ViewReport : System.Web.UI.Page
    {
        protected TranReportDao _dao = new TranReportDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadData();
            }
        }

        private void LoadData()
        {
            string fromDate = GetStatic.ReadQueryString("from", "");
            string toDate = GetStatic.ReadQueryString("to", "");
            string dataFor = GetStatic.ReadQueryString("dataFor", "");

            var dt = _dao.UntransactedReportNew(GetStatic.GetUser(), fromDate, toDate, dataFor);
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }

            //string customerId = "";
            int sNo = 1;
            StringBuilder sb = new StringBuilder();
            double total = 0, totalResolved = 0;
            foreach (DataRow item in dt.Rows)
            {
                //if (item["RESOLVED TYPE"].ToString()  == "送金済")
                //{
                //    if (customerId == item["CUSTOMERID"].ToString())
                //    {
                //        sb.AppendLine("<tr>");
                //    }
                //    else
                //    {
                //        sb.AppendLine("<tr style=\"border-top: 2px solid red;\">");
                //    }
                //    customerId = item["CUSTOMERID"].ToString();                    
                //}
                //else
                //{
                //    sb.AppendLine("<tr>");
                //}
                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + sNo.ToString() + "</td>");
                sb.AppendLine("<td>" + item["DATE"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["CUSTOMER NAME"].ToString().Replace("送金　", "").Trim() + " </td>");
                sb.AppendLine("<td>" + item["COLLECT AMT"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["RESOLVED DATE"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["RESOLVED AMT"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["RESOLVED TYPE"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["PIN NO"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["PENDING REF NO"].ToString() + "</td>");
                sb.AppendLine("</tr>");


                total += GetStatic.ParseDouble(item["COLLECT AMT"].ToString());
                totalResolved += GetStatic.ParseDouble(item["RESOLVED AMT"].ToString());
                sNo++;
            }
            sb.AppendLine("<tr><td colspan='3' style='font-weight: bold;' align='right'>Total:</td>");
            sb.AppendLine("<td style='font-weight: bold;'>" + GetStatic.ShowDecimal(total.ToString()) + "</td>");
            sb.AppendLine("<td>&nbsp;</td>");
            sb.AppendLine("<td style='font-weight: bold;'>" + GetStatic.ShowDecimal(totalResolved.ToString()) + "</td>");
            sb.AppendLine("<td></td>");
            sb.AppendLine("<td></td>");
            sb.AppendLine("<td></td>");
            sb.AppendLine("</tr>");
            rpt.InnerHtml = sb.ToString();
        }
    }
}