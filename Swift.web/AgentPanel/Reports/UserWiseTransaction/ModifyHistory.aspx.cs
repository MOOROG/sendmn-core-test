using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentPanel.Reports.UserWise
{
    public partial class ModifyHistory : System.Web.UI.Page
    {
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private TranReportDao _rptDao = new TranReportDao();
        protected string Url = GetStatic.GetUrlRoot();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
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
            if (reportName == "modifyhistory")
                LoadReport();
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
            return GetStatic.ReadQueryString("type", "");
        }

        private void LoadReport()
        {
            head.InnerHtml = "";
            var ds = _rptDao.UserWiseReportModifyHistory("MODIFYHISTORY", GetBranchId(), GetUserName(), GetFromDate(), GetToDate(), GetStatic.GetUser());
            var dt = ds.Tables[0];
            var filter = ds.Tables[2];
            var reportHead = ds.Tables[3];
            PrintFilter(ref filter);
            PrintHead(ref reportHead);
            int cols = dt.Columns.Count;

            StringBuilder str = new StringBuilder("<table width=\"800\" border=\"0\" class=\"TBLReport\" cellpadding=\"5\" cellspacing=\"3\" align=;\"center\">");
            str.Append("<tr>");
            str.AppendLine("<th>S.N.</th>");
            for (int i = 0; i < cols; i++)
            {
                str.AppendLine("<th align=\"left\">" + dt.Columns[i].ColumnName + "</th>");
            }
            str.AppendLine("</tr>");
            int cnt = 1;
            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                str.Append("<td>" + cnt + "</td>");
                for (int i = 0; i < cols; i++)
                {
                    str.Append("<td align = 'left'>" + dr[i].ToString() + "</td>");
                }
                str.Append("</tr>");
                cnt = cnt + 1;
            }
            rptDiv.InnerHtml = str.ToString();
        }
    }
}