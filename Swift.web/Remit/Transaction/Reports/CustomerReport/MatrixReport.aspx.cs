using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace Swift.web.Remit.Transaction.Reports.CustomerReport
{
    public partial class MatrixReport : System.Web.UI.Page
    {
        private const string ViewFunctionId = "2021800";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly TranReportDao _rpt = new TranReportDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                PopulateReport();
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected void PopulateReport()
        {
            string startDate = GetStatic.ReadQueryString("startDate", "");
            string endDate = GetStatic.ReadQueryString("endDate", "");
            string countryF = GetStatic.ReadQueryString("country", "");
            string branchF = GetStatic.ReadQueryString("branch", "");
            string flag = GetStatic.ReadQueryString("flag", "");

            fromDate.Text = startDate;
            toDate.Text = endDate;
            country.Text = GetStatic.ReadQueryString("countryName", "All");
            branch.Text = GetStatic.ReadQueryString("branchName", "All");

            DataTable dt = _rpt.CustomerMatrixReport(GetStatic.GetUser(), startDate, endDate, countryF, branchF, flag);
            
            CreateTable(dt);
        }

        private void CreateTable(DataTable dt)
        {
            List<string> _columns = new List<string>();
            var totalColumnWise = new double[dt.Columns.Count - 1];
            var totalRowWise = new double[dt.Rows.Count];
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<table class='table table-responsive table-bordered'>");
            sb.AppendLine("<thead>");
            sb.AppendLine("<tr>");
            foreach (DataColumn item in dt.Columns)
            {
                _columns.Add(item.ColumnName);
                sb.AppendLine("<th>" + item.ColumnName + "</th>");
            }
            sb.AppendLine("<th><b>TOTAL</b></th>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</thead>");

            double value;
            int row = 0;
            sb.AppendLine("<tbody>");
            foreach (DataRow item in dt.Rows)
            {
                
                sb.AppendLine("<tr>");
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    if (i != 0)
                    {
                        sb.AppendLine("<td>" + GetRowValue(item[i].ToString(), item[0].ToString(), _columns[i]) + "</td>");

                        double.TryParse(item[i].ToString(), out value);
                        totalColumnWise[i - 1] = totalColumnWise[i - 1] + value;
                        if (dt.Rows.Count > 0)
                        {
                            totalRowWise[row] = totalRowWise[row] + value;
                        }
                    }
                    else
                    {
                        sb.AppendLine("<td>" + (string.IsNullOrEmpty(item[i].ToString()) ? "0" : item[i].ToString()) + "</td>");
                    }
                }
                sb.AppendLine("<td><b>" + totalRowWise[row].ToString() + "</b></td>");
                sb.AppendLine("</tr>");

                row++;
            }
            sb.AppendLine("<tr>");
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                if (i == 0)
                {
                    sb.AppendLine("<td align='right'><b>TOTAL</b></td>");
                }
                else
                {
                    sb.AppendLine("<td><b>" + totalColumnWise[i - 1] + "</b></td>");
                }
            }
            sb.AppendLine("<td><b>" + GetTotalFromArray(totalRowWise) + "</b></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</tbody>");

            tblMatrix.InnerHtml = sb.ToString();
        }

        private string GetTotalFromArray(double[] totalRowWise)
        {
            double totalSum = 0;
            foreach (var item in totalRowWise)
            {
                totalSum += item;
            }

            return totalSum.ToString();
        }

        private string GetRowValue(string value, string country, string branch)
        {
            string startDate = GetStatic.ReadQueryString("startDate", "");
            string endDate = GetStatic.ReadQueryString("endDate", "");
            string flag = ((GetStatic.ReadQueryString("flag", "").ToLower() == "trn-matrix") ? "matrix-trn-detail" : "matrix-detail");

            if (string.IsNullOrEmpty(value))
            {
                return "0";
            }
            else
            {
                if (value == "NO DATA FOUND FOR THIS FILTER")
                {
                    return "NO DATA FOUND FOR THIS FILTER";
                }
                else
                {
                    return "<a href='#' onclick=\"OpenInNewWindow('/RemittanceSystem/RemittanceReports/Reports.aspx?reportName=customerReport&flag=" + flag + "&startDate=" + startDate + "&endDate=" + endDate + "&country=" + country + "&branch=" + branch + "')\">" + value + "</a>";
                }
            }
        }
    }
}