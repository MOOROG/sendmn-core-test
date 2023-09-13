using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentNew.Reports.UserwiseTransactionReport
{
    public partial class View : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40121400";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private TranReportDao _rptDao = new TranReportDao();

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
                Response.AddHeader("Content-Disposition", "inline; filename=" + reportName + "." + format);
                exportDiv.Visible = false;
            }
            if (reportName == "uwdetail")
                LoadReport();
            else if (reportName == "uwsummary")
                LoadReportSummary();
            else if (reportName == "agentuserwise")
                LoadReportAgentUserWise();
            else if (reportName == "detail")
                ShowUserWiseTranDetail();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
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

        private string GetAgentId()
        {
            return GetStatic.ReadQueryString("agent", "");
        }

        private string GetBranchId()
        {
            return GetStatic.ReadQueryString("branch", "");
        }

        private string GetUserName()
        {
            return GetStatic.ReadQueryString("userName", "");
        }

        private string GetFromDate()
        {
            return GetStatic.ReadQueryString("fromDate", "");
        }

        private string GetToDate()
        {
            return GetStatic.ReadQueryString("toDate", "");
        }

        private string GetFlag()
        {
            return GetStatic.ReadQueryString("flag", "");
        }

        private string GetRecCountry()
        {
            return GetStatic.ReadQueryString("rCountry", "");
        }

        private void LoadReport()
        {
            head.InnerHtml = "";
            var ds = _rptDao.UserWiseReport("detail", GetStatic.GetCountry(), GetStatic.GetAgent(), GetBranchId(), GetUserName(), GetFromDate(), GetToDate(), GetRecCountry(), GetStatic.GetUser());

            var dtHead = ds.Tables[0];
            var dt = ds.Tables[1];
            var filter = ds.Tables[3];
            var reportHead = ds.Tables[4];

            PrintFilter(ref filter);
            PrintHead(ref reportHead);

            int cols = dt.Columns.Count;

            StringBuilder str = new StringBuilder("<table class=\"table table-responsive table-bordered table-striped\" >");
            str.Append("<tr>");
            str.AppendLine("<th>S.N.</th>");
            for (int i = 1; i < cols - 1; i++)
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
                str.Append("<td colspan = '2'><center><b>Grand Total</b></center></td>");

                for (int i = 2; i < 9; i++)
                {
                    if (i == 2 || i == 4 || i == 6 || i == 8)
                        str.Append("<td align = 'center'><b>" + total[i].ToString() + "</b></td>");
                    else if (i == 3 || i == 7)
                        str.Append("<td align = 'right'><b>" + total[i].ToString() + "</b></td>");
                    else
                        str.Append("<td align = 'right'><b>" + GetStatic.ParseMinusValue(GetStatic.ParseDouble(total[i].ToString())) + "</b></td>");
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

        private string PrintRegionBody(ref DataTable dt, string regionName, ref Double[] total)
        {
            double[] subTotal = new double[9];
            DataRow[] rows = dt.Select("HEAD='" + regionName + "'");

            var html = new StringBuilder();

            html.Append("<tr>");
            html.Append("<td></td>");
            html.Append("<td colspan='5'><b>User Name: " + regionName + "</b></td>");

            html.Append("</tr>");
            int bag_sno = 0;
            foreach (DataRow dr in rows)
            {
                for (int i = 2; i < 9; i++)
                {
                    var data = GetStatic.ParseDouble(dr[i].ToString());
                    subTotal[i] += data;
                    total[i] += data;
                }

                html.Append("<tr>");
                html.Append("<td align=\"center\" style=\"border=\"0\";\" nowrap='nowrap'>" + (++bag_sno).ToString() + "</td>");
                html.Append("<td align=\"left\" style=\"border=\"0\";\" nowrap='nowrap'>" + dr["Branch"].ToString() + "</td>");
                html.Append("<td align=\"center\" style=\"border=\"0\";\"><a href=\"../Reports.aspx?reportName=userwiserpt&rCountry=" + GetRecCountry() + "&branch=" + dr["agentId"].ToString() + "&type=Send&userName=" + regionName + "&fromDate=" + GetFromDate() + "&toDate=" + GetToDate() + "\">" + dr["#Send Trans"].ToString() + "</a></td>");
                html.Append("<td align=\"right\" style=\"border=\"0\";\">" + dr["Send Amount"].ToString() + "</td>");
                html.Append("<td align=\"center\" style=\"border=\"0\";\"><a href=\"../Reports.aspx?reportName=userwiserpt&rCountry=" + GetRecCountry() + "&branch=" + dr["agentId"].ToString() + "&type=Paid&userName=" + regionName + "&fromDate=" + GetFromDate() + "&toDate=" + GetToDate() + "\">" + dr["#Paid Trans"].ToString() + "</a></td>");
                html.Append("<td align=\"right\" style=\"border=\"0\";\">" + GetStatic.ParseMinusValue(GetStatic.ParseDouble(dr["Paid Amount"].ToString())) + "</td>");
                html.Append("<td align=\"center\" style=\"border=\"0\";\"><a href=\"../Reports.aspx?reportName=userwiserpt&rCountry=" + GetRecCountry() + "&branch=" + dr["agentId"].ToString() + "&type=Approved&userName=" + regionName + "&fromDate=" + GetFromDate() + "&toDate=" + GetToDate() + "\">" + dr["#Approved Trans"].ToString() + "</a></td>");
                html.Append("<td align=\"right\" style=\"border=\"0\";\">" + dr["Approved Amount"].ToString() + "</td>");
                html.Append("<td align=\"center\" style=\"border=\"0\";\"><a href=\"ModifyHistory.aspx?reportName=modifyHistory&rCountry=" + GetRecCountry() + "&branch=" + dr["agentId"].ToString() + "&type=all&userName=" + regionName + "&fromDate=" + GetFromDate() + "&toDate=" + GetToDate() + "\">" + dr["#Amendment Count"].ToString() + "</a></td>");
                html.Append("</tr>");
            }

            html.Append("<tr>");
            html.Append("<td colspan = '2'><center><b>Sub Total</b></center></td>");

            for (int i = 2; i < 9; i++)
            {
                if (i == 2 || i == 4 || i == 6 || i == 8)
                    html.Append("<td align = 'center'><b>" + subTotal[i].ToString() + "</b></td>");
                else if (i == 3 || i == 7)
                    html.Append("<td align = 'right'><b>" + subTotal[i].ToString() + "</b></td>");
                else
                    html.Append("<td align = 'right'><b>" + GetStatic.ParseMinusValue(GetStatic.ParseDouble(subTotal[i].ToString())) + "</b></td>");
            }

            html.Append("</tr>");
            return html.ToString();
        }

        private void LoadReportSummary()
        {
            var ds = _rptDao.UserWiseReport("summary", GetStatic.GetCountry(), GetStatic.GetAgent(), GetBranchId(), GetUserName(), GetFromDate(), GetToDate(), GetRecCountry(), GetStatic.GetUser());
            var dt = ds.Tables[0];
            var filter = ds.Tables[2];
            var reportHead = ds.Tables[3];

            PrintFilter(ref filter);
            PrintHead(ref reportHead);
            int cols = dt.Columns.Count;

            double[] sum = new double[cols];

            StringBuilder str = new StringBuilder("<table class=\"table table-responsive table-bordered table-striped \"");
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

                        if (i == 1 || i == 3 || i == 5 || i == 7)
                        {
                            str.Append("<td align = 'center'>" + row[i].ToString() + "</td>");
                        }
                        else if (i == 2 || i == 6)
                        {
                            str.Append("<td align = 'right'>" + row[i].ToString() + "</td>");
                        }
                        else if (i == 4)
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
                    if (i == 1 || i == 3 || i == 5 || i == 7)
                    {
                        str.Append("<td align=\"center\"><b>" + sum[i].ToString() + "</b></td>");
                    }
                    else if (i == 2 || i == 6)
                    {
                        str.Append("<td align = 'right'>" + sum[i].ToString() + "</td>");
                    }
                    else if (i == 4)
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

        private void LoadReportAgentUserWise()
        {
            var ds = _rptDao.GetUserWiseTransactionReport("A", GetStatic.GetUser(), GetFromDate(), GetToDate(), GetStatic.GetAgentId(), GetUserName());
            var dt = ds.Tables[0];
            var filter = ds.Tables[2];
            var reportHead = ds.Tables[3];

            PrintFilter(ref filter);
            PrintHead(ref reportHead);
            int cols = dt.Columns.Count;

            double[] sum = new double[cols];

            StringBuilder str = new StringBuilder("<table class=\"table table-responsive table-striped table-bordered \"");
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
                            str.Append("<td align=\"center\"><b><a href=\"#\" onclick=\"OpenInNewWindow('" +
                                       GetStatic.GetUrlRoot() +
                                       "/Remit/Transaction/Reports/UserWiseTran/SearchUserWise.aspx?reportName=detail&flag=s&fromDate=" +
                                       GetFromDate() + "&toDate=" + GetToDate() + "&userName=" + row["User Name"] + "&agentId=" + GetStatic.GetAgentId() + "')\">" + row[i].ToString() + "</a></b></td>");
                            //str.Append("<td align = 'center'>" + row[i].ToString() + "</td>");
                        }
                        else if (i == 3)
                        {
                            str.Append("<td align=\"center\"><b><a href=\"#\" onclick=\"OpenInNewWindow('" + GetStatic.GetUrlRoot() + "/Remit/Transaction/Reports/UserWiseTran/SearchUserWise.aspx?reportName=detail&flag=p&fromDate=" + GetFromDate() + "&toDate=" + GetToDate() + "&userName=" + row["User Name"] + "&agentId=" + GetStatic.GetAgentId() + "')\">" + row[i].ToString() + "</a></b></td>");
                            //str.Append("<td align = 'center'>" + row[i].ToString() + "</td>");
                        }
                        else if (i == 2 || i == 4)
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
                    if (i == 1 || i == 3)
                    {
                        str.Append("<td align=\"center\"><b>" + sum[i].ToString() + "</b></td>");
                    }
                    else
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

        private void ShowUserWiseTranDetail()
        {
            var ds = _rptDao.GetUserWiseTransactionReport(GetFlag(), GetStatic.GetUser(), GetFromDate(), GetToDate(), GetAgentId(), GetUserName());
            var dt = ds.Tables[0];
            var filter = ds.Tables[2];
            var reportHead = ds.Tables[3];

            PrintFilter(ref filter);
            PrintHead(ref reportHead);
            int cols = dt.Columns.Count;

            double[] sum = new double[cols];

            StringBuilder str = new StringBuilder("<table class='table table-responsive table-bordered table-striped' ");
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
                        str.Append("<td align = 'left'>" + row[i].ToString() + "</td>");
                    }
                    str.Append("</tr>");
                }
            }
            else
            {
                str.Append("<tr>");
                str.Append("<td colspan = '" + cols + "'><center><b>No Record Found!</b></center></td>");
                str.Append("</tr>");
            }
            rptDiv.InnerHtml = str.ToString();
        }
    }
}