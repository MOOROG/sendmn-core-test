using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

namespace Swift.web
{
    public partial class Download : System.Web.UI.Page
    {
        private SwiftDao dao = new SwiftDao();
        private RemittanceDao remit = new RemittanceDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                DownloadCsv();
            }
        }

        private void DownloadCsv()
        {
            var data = "";
            var mode = GetStatic.ReadQueryString("mode", "grid").ToLower();
            if (mode == "grid")
            {
                data = GenerateCsvForGrid();
            }
            else if (mode == "report")
            {
                data = GenerateCsvForReport();
            }

            Response.Clear();
            Response.ClearContent();
            Response.ClearHeaders();
            Response.Buffer = true;
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", "inline; filename=download.xls");
            Response.Charset = "";
            Response.Write(data);
            Response.End();
        }

        private string GenerateCsvForGrid()
        {
            var sql = GetStatic.ReadSession("exportSource", "");

            if (string.IsNullOrEmpty(sql))
                return "";

            var type = GetStatic.ReadQueryString("type", "").ToLower();

            var ds = new DataSet();

            if (type == "remit")
            {
                ds = remit.ExecuteDataset(sql);
            }
            else
            {
                ds = dao.ExecuteDataset(sql);
            }

            var columnList = (List<GridColumn>)Session["grid_column"];
            if (ds == null || columnList == null)
                return "";
            var dt = ds.Tables[1];
            var html = new StringBuilder("<table width=\"700\" border=\"0\" cellpadding=\"0\" cellspacing=\"1\" >");

            html.Append("<tr>");

            foreach (var column in columnList)
            {
                if (column.Description != "")
                    html.Append("<th Class=\"HeaderStyle\" align=\"left\" nowrap " + ">" + column.Description + "</th>");
            }
            html.Append("</tr>");

            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<tr>");

                foreach (var column in columnList)
                {
                    switch (column.Type.ToUpper())
                    {
                        case "M":
                            html.Append("<td align=\"right\">" + SwiftGrid.FormatData(dr[column.Key].ToString(), "M") + "</td>");
                            break;

                        case "D":
                            html.Append("<td align=\"center\">" + SwiftGrid.FormatData(dr[column.Key].ToString(), "D") + "</td>");
                            break;

                        case "DT":
                            html.Append("<td align=\"center\">" + SwiftGrid.FormatData(dr[column.Key].ToString(), "DT") + "</td>");
                            break;

                        case "NOSORT":
                            if (column.Description.Trim() != "")
                                html.Append("<td align=\"left\" nowrap>" + dr[column.Key] + "</td>");
                            break;

                        case "CHECKBOX":
                            break;

                        default:
                            html.Append("<td align=\"left\">" + dr[column.Key] + "</td>");
                            break;
                    }
                }

                html.Append("</tr>");
            }
            html.Append("</table>");

            return html.ToString();
        }

        private string GenerateCsvForReport()
        {
            var sql = GetStatic.ReadSession("sql", "");
            if (sql == "")
                return "error";

            var db = new SwiftDao();
            var ds = db.ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0)
                return "error";

            var dt = ds.Tables[0];
            var html = new StringBuilder("<table  width=\"700\" border=\"1\" cellpadding=\"0\" cellspacing=\"1\" >");

            html.Append("<tr>");

            for (var i = 0; i < dt.Columns.Count; i++)
            {
                html.Append("<th Class=\"HeaderStyle\" align=\"left\" nowrap " + ">" + dt.Columns[i].ColumnName + "</th>");
            }
            html.Append("</tr>");

            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<tr>");

                for (var i = 0; i < dt.Columns.Count; i++)
                {
                    html.Append("<td align=\"left\">" + dr[i] + "</td>");
                }

                html.Append("</tr>");
            }
            html.Append("</table>");

            return html.ToString();
        }
    }
}