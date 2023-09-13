using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Reports.IntlReports.PayTrnRpt
{
    public partial class ShowReport : System.Web.UI.Page
    {
        TranReportDao _rptDao = new TranReportDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20190000";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();

            string reportName = GetStatic.ReadQueryString("reportName", "").ToLower();
            string mode = GetStatic.ReadQueryString("mode", "").ToLower();
            if (mode == "download")
            {
                string format = GetStatic.ReadQueryString("format", "xls");
                Response.Clear();
                Response.ClearContent();
                Response.ClearHeaders();
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("Content-Disposition", "attachment; filename=" + reportName + "." + format);
                exportDiv.Visible = false;
            }
            if (reportName == "paidtranint")
                LoadReportDetailInt();
            if (reportName == "paidtransummaryint")
                LoadReportSummaryInt();
            if (reportName == "paidtransummary1int")
                LoadReportSummaryWithCommInt();

        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }
        private void LoadReportDetailInt()
        {
            string fromDate = GetStatic.ReadQueryString("fromDate", "");
            string toDate = GetStatic.ReadQueryString("toDate", "");

            string sCountry = GetStatic.ReadQueryString("sCountry", "");
            string sZone = GetStatic.ReadQueryString("sZone", "");
            string sDistrict = GetStatic.ReadQueryString("sDistrict", "");
            string sLocation = GetStatic.ReadQueryString("sLocation", "");
            string sAgent = GetStatic.ReadQueryString("sAgent", "");
            string sBranch = GetStatic.ReadQueryString("sBranch", "");
            string rCountry = GetStatic.ReadQueryString("rCountry", "");
            string rZone = GetStatic.ReadQueryString("rZone", "");
            string rDistrict = GetStatic.ReadQueryString("rDistrict", "");
            string rAgent = GetStatic.ReadQueryString("rAgent", "");
            string rBranch = GetStatic.ReadQueryString("rBranch", "");
            string rLocation = GetStatic.ReadQueryString("rLocation", "");


            head.InnerHtml = "";
            var ds = _rptDao.PaidTranReportInt("A", GetStatic.GetUser(), fromDate, toDate, sCountry, sZone, sDistrict, sLocation,
                                        sAgent, sBranch, rCountry, rZone, rDistrict, rLocation, rAgent, rBranch);

            var dtHead = ds.Tables[0];
            var dt = ds.Tables[1];
            var filter = ds.Tables[3];
            var reportHead = ds.Tables[4];

            PrintFilter(ref filter);
            PrintHead(ref reportHead);

            int cols = dt.Columns.Count;

            StringBuilder str = new StringBuilder("<table class=\"table table-responsive table-striped table-bordered \">");
            str.Append("<tr>");
            str.AppendLine("<th>S.N.</th>");
            for (int i = 1; i < cols; i++)
            {
                str.AppendLine("<th align=\"left\">" + dt.Columns[i].ColumnName + "</th>");
            }
            str.AppendLine("</tr>");
            if (dtHead.Rows.Count > 0)
            {
                double[] total = new double[9];

                foreach (DataRow dr in dtHead.Rows)
                {
                    str.AppendLine(PrintRegionBody(ref dt, dr[0].ToString(), ref total));
                }

                str.Append("<tr>");
                str.Append("<td colspan = '8'><center><b>Grand Total</b></center></td>");

                for (int i = 8; i < 9; i++)
                {
                    if (i == 8)
                    {
                        str.Append("<td align = 'right'><b>" + GetStatic.ParseMinusValue(GetStatic.ParseDouble(total[i].ToString())) + "</b></td>");
                    }
                }

                str.Append("</tr>");
            }
            else
            {
                str.Append("<tr>");
                str.Append("<td colspan = '" + cols + "'><center><b>No Record Found!</b></center></td>");
                str.Append("</tr>");
            }


            rptDiv.InnerHtml = str.ToString();
        }
        private void LoadReportSummaryInt()
        {
            string fromDate = GetStatic.ReadQueryString("fromDate", "");
            string toDate = GetStatic.ReadQueryString("toDate", "");

            string sCountry = GetStatic.ReadQueryString("sCountry", "");
            string sZone = GetStatic.ReadQueryString("sZone", "");
            string sDistrict = GetStatic.ReadQueryString("sDistrict", "");
            string sLocation = GetStatic.ReadQueryString("sLocation", "");
            string sAgent = GetStatic.ReadQueryString("sAgent", "");
            string sBranch = GetStatic.ReadQueryString("sBranch", "");
            string rCountry = GetStatic.ReadQueryString("rCountry", "");
            string rZone = GetStatic.ReadQueryString("rZone", "");
            string rDistrict = GetStatic.ReadQueryString("rDistrict", "");
            string rAgent = GetStatic.ReadQueryString("rAgent", "");
            string rBranch = GetStatic.ReadQueryString("rBranch", "");
            string rLocation = GetStatic.ReadQueryString("rLocation", "");

            var ds = _rptDao.PaidTranReportInt("B", GetStatic.GetUser(), fromDate, toDate, sCountry, sZone, sDistrict, sLocation,
                                        sAgent, sBranch, rCountry, rZone, rDistrict, rLocation, rAgent, rBranch);
            var dt = ds.Tables[0];
            var filter = ds.Tables[2];
            var reportHead = ds.Tables[3];

            PrintFilter(ref filter);
            PrintHead(ref reportHead);
            int cols = dt.Columns.Count;

            double[] sum = new double[cols];

            StringBuilder str = new StringBuilder("<table class=\"table table-responsive table-striped table-bordered \">");
            str.Append("<tr>");
            str.AppendLine("<th>S.N.</th>");
            for (int i = 0; i < cols; i++)
            {
                str.AppendLine("<th align=\"left\">" + dt.Columns[i].ColumnName + "</th>");
            }
            str.AppendLine("</tr>");
            if (dt.Rows.Count > 0)
            {
                int bag_sno = 0;
                foreach (DataRow row in dt.Rows)
                {
                    str.Append("<tr>");
                    str.Append("<td align=\"center\" style=\"border=\"0\";\" nowrap='nowrap'>" + (++bag_sno).ToString() + "</td>");
                    for (int i = 0; i < cols; i++)
                    {
                        if (i > 0 && i < cols)
                        {
                            double currVal;
                            double.TryParse(row[i].ToString(), out currVal);
                            sum[i] += currVal;
                        }

                        if (i == 1)
                        {
                            str.Append("<td align = 'center'>" + row[i].ToString() + "</td>");
                        }
                        else if (i == 2)
                        {
                            str.Append("<td align = 'right'>" + GetStatic.ParseMinusValue(GetStatic.ParseDouble(row[i].ToString())) + "</td>");
                        }
                        else
                        {
                            str.Append("<td align = 'left'>" + row[i].ToString() + "</td>");
                        }
                    }
                    str.Append("</tr>");
                }
                str.Append("<tr>");
                str.Append("<td align=\"center\" colspan='2'><b>Total</b></td>");
                for (int i = 1; i < cols; i++)
                {
                    if (i == 1)
                    {
                        str.Append("<td align = 'center'><b>" + sum[i].ToString() + "</b></td>");
                    }
                    else if (i == 2)
                    {
                        str.Append("<td align = 'right'><b>" + GetStatic.ParseMinusValue(GetStatic.ParseDouble(sum[i].ToString())) + "</b></td>");
                    }
                }
                str.Append("</tr>");
            }
            else
            {
                str.Append("<tr>");
                str.Append("<td colspan = '" + cols + "'><center><b>No Record Found!</b></center></td>");
                str.Append("</tr>");
            }


            rptDiv.InnerHtml = str.ToString();
        }
        private void LoadReportSummaryWithCommInt()
        {
            string fromDate = GetStatic.ReadQueryString("fromDate", "");
            string toDate = GetStatic.ReadQueryString("toDate", "");

            string sCountry = GetStatic.ReadQueryString("sCountry", "");
            string sZone = GetStatic.ReadQueryString("sZone", "");
            string sDistrict = GetStatic.ReadQueryString("sDistrict", "");
            string sLocation = GetStatic.ReadQueryString("sLocation", "");
            string sAgent = GetStatic.ReadQueryString("sAgent", "");
            string sBranch = GetStatic.ReadQueryString("sBranch", "");
            string rCountry = GetStatic.ReadQueryString("rCountry", "");
            string rZone = GetStatic.ReadQueryString("rZone", "");
            string rDistrict = GetStatic.ReadQueryString("rDistrict", "");
            string rAgent = GetStatic.ReadQueryString("rAgent", "");
            string rBranch = GetStatic.ReadQueryString("rBranch", "");
            string rLocation = GetStatic.ReadQueryString("rLocation", "");

            var ds = _rptDao.PaidTranReportInt("C", GetStatic.GetUser(), fromDate, toDate, sCountry, sZone, sDistrict, sLocation,
                                        sAgent, sBranch, rCountry, rZone, rDistrict, rLocation, rAgent, rBranch);
            var dt = ds.Tables[0];
            var filter = ds.Tables[2];
            var reportHead = ds.Tables[3];

            PrintFilter(ref filter);
            PrintHead(ref reportHead);
            int cols = dt.Columns.Count;

            double[] sum = new double[cols];

            StringBuilder str = new StringBuilder("<table class=\"table table-responsive table-striped table-bordered \">");
            str.Append("<tr>");
            str.AppendLine("<th>S.N.</th>");
            for (int i = 0; i < cols; i++)
            {
                str.AppendLine("<th align=\"left\">" + dt.Columns[i].ColumnName + "</th>");
            }
            str.AppendLine("</tr>");
            if (dt.Rows.Count > 0)
            {
                int bag_sno = 0;
                foreach (DataRow row in dt.Rows)
                {
                    str.Append("<tr>");
                    str.Append("<td align=\"center\" style=\"border=\"0\";\" nowrap='nowrap'>" + (++bag_sno).ToString() + "</td>");
                    for (int i = 0; i < cols; i++)
                    {
                        if (i > 0 && i < cols)
                        {
                            double currVal;
                            double.TryParse(row[i].ToString(), out currVal);
                            sum[i] += currVal;
                        }

                        if (i == 1 || i == 2)
                        {
                            str.Append("<td align = 'center'>" + row[i].ToString() + "</td>");
                        }
                        else if (i > 2)
                        {
                            str.Append("<td align = 'right'>" + GetStatic.ParseMinusValue(GetStatic.ParseDouble(row[i].ToString())) + "</td>");
                        }
                        else
                        {
                            str.Append("<td align = 'left'>" + row[i].ToString() + "</td>");
                        }
                    }
                    str.Append("</tr>");
                }
                str.Append("<tr>");
                str.Append("<td align=\"center\" colspan='2'><b>Total</b></td>");
                for (int i = 1; i < cols; i++)
                {
                    if (i == 1 || i == 2)
                    {
                        str.Append("<td align = 'center'><b>" + sum[i].ToString() + "</b></td>");
                    }
                    else if (i > 2)
                    {
                        str.Append("<td align = 'right'><b>" + GetStatic.ParseMinusValue(GetStatic.ParseDouble(sum[i].ToString())) + "</b></td>");
                    }
                }
                str.Append("</tr>");
            }
            else
            {
                str.Append("<tr>");
                str.Append("<td colspan = '" + cols + "'><center><b>No Record Found!</b></center></td>");
                str.Append("</tr>");
            }


            rptDiv.InnerHtml = str.ToString();
        }
        private void PrintFilter(ref DataTable filter)
        {
            var html = new StringBuilder("Filter Applied:</br>");

            foreach (DataRow dr in filter.Rows)
            {
                html.Append(dr[0] + "=" + dr[1] + " | ");
            }
            filters.InnerHtml = html.ToString();
        }
        private void PrintHead(ref DataTable reportHead)
        {
            var html = new StringBuilder("");
            foreach (DataRow dr in reportHead.Rows)
                html.Append(dr[0].ToString());
            head.InnerHtml = html.ToString();
        }

        private string PrintRegionBody(ref DataTable dt, string regionName, ref Double[] total)
        {
            double[] subTotal = new double[9];
            DataRow[] rows = dt.Select("HEAD='" + regionName + "'");

            var html = new StringBuilder();


            html.Append("<tr>");
            html.Append("<td></td>");
            html.Append("<td colspan='8'><b>Payout Agent : " + regionName + "</b></td>");

            html.Append("</tr>");
            int bag_sno = 0;
            foreach (DataRow dr in rows)
            {

                for (int i = 8; i < 9; i++)
                {
                    var data = GetStatic.ParseDouble(dr[i].ToString());
                    subTotal[i] += data;
                    total[i] += data;
                }

                html.Append("<tr>");
                html.Append("<td align=\"center\" style=\"border=\"0\";\" nowrap='nowrap'>" + (++bag_sno).ToString() + "</td>");
                html.Append("<td align=\"left\" style=\"border=\"0\";\" nowrap='nowrap'>" + dr["Sending Details"].ToString() + "</td>");
        html.Append("<td align=\"left\" style=\"border=\"0\";\" nowrap='nowrap'>" + dr["ControlNo"].ToString() + "</td>");
        html.Append("<td align=\"left\" style=\"border=\"0\";\" nowrap='nowrap'>" + dr["Sender"].ToString() + "</td>");
        html.Append("<td align=\"left\" style=\"border=\"0\";\">" + dr["Receiver Name"].ToString() + "</td>");
        html.Append("<td align=\"left\" style=\"border=\"0\";\">" + dr["Paid By"].ToString() + "</td>");
        html.Append("<td align=\"left\" style=\"border=\"0\";\">" + dr["Paid Date"].ToString() + "</td>");
                html.Append("<td align=\"left\" style=\"border=\"0\";\">" + dr["Send Amount"].ToString() + "</td>");
                html.Append("<td align=\"right\" style=\"border=\"0\";\">" + GetStatic.ParseMinusValue(GetStatic.ParseDouble(dr["Receive Amount"].ToString())) + "</td>");
                html.Append("</tr>");
            }

            html.Append("<tr>");
            html.Append("<td colspan = '8'><center><b>Sub Total</b></center></td>");

            for (int i = 8; i < 9; i++)
            {
                if (i == 8)
                {
                    html.Append("<td align = 'right'><b>" + GetStatic.ParseMinusValue(GetStatic.ParseDouble(subTotal[i].ToString())) + "</b></td>");
                }
            }

            html.Append("</tr>");
            return html.ToString();
        }
    }
}