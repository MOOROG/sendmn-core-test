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
    public partial class DownloadPDF : System.Web.UI.Page
    {
        private SwiftDao dao = new SwiftDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (GetStatic.ReadQueryString("mode", "") == "")
            {
                getPdfDownload();
            }
        }

        private void getPdfDownload()
        {
            var data = "";
            var mode = GetStatic.ReadQueryString("mode", "grid").ToLower();
            if (mode == "grid")
            {
                data = GeneratePDFForGrid();
            }
            content.InnerHtml = data.ToString();
            //GetStatic.CallJSFunction(Page, "GetPDF()");
            //    GetPdfDownloadDone(data);
        }

        //private void GetPdfDownloadDone(string data)
        //{
        //    // instantiate a html to pdf converter object
        //    HtmlToPdf converter = new HtmlToPdf();

        // //// set converter options converter.Options.PdfPageSize = PdfPageSize.A4;
        // converter.Options.PdfPageOrientation = PdfPageOrientation.Landscape;
        // converter.Options.WebPageWidth = 1024; converter.Options.WebPageHeight = 0;

        // //// create a new pdf document converting an url PdfDocument doc = converter.ConvertHtmlString(data);

        // //// save pdf document doc.Save(Response, true, "Sample.pdf");

        //    //// close pdf document
        //    doc.Close();
        //}

        private string GeneratePDFForGrid()
        {
            var sql = GetStatic.ReadSession("exportSource", "");

            if (string.IsNullOrEmpty(sql))
                return "";

            var ds = dao.ExecuteDataset(sql);

            var columnList = (List<GridColumn>)Session["grid_column"];
            if (ds == null || columnList == null)
                return "";
            var dt = ds.Tables[1];
            var html = new StringBuilder("<table width=\"100%\" style=\"border:1px solid #ddd; border-collapse:collapse;\" cellpadding=\"0\" cellspacing=\"1\" id=\"gridTable\" >");

            html.Append("<tr>");

            foreach (var column in columnList)
            {
                if (column.Description != "")
                    html.Append("<th style=\"border:1px solid #ddd; border-collapse:collapse;\" Class=\"HeaderStyle\" align=\"left\" nowrap " + ">" + column.Description + "</th>");
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
                            html.Append("<td  style=\"border:1px solid #ddd; border-collapse:collapse;\" align=\"right\" nowrap>" + SwiftGrid.FormatData(dr[column.Key].ToString(), "M") + "</td>");
                            break;

                        case "D":
                            html.Append("<td style=\"border:1px solid #ddd; border-collapse:collapse;\" align=\"center\" nowrap>" + SwiftGrid.FormatData(dr[column.Key].ToString(), "D") + "</td>");
                            break;

                        case "DT":
                            html.Append("<td style=\"border:1px solid #ddd; border-collapse:collapse;\" align=\"center\" nowrap>" + SwiftGrid.FormatData(dr[column.Key].ToString(), "DT") + "</td>");
                            break;

                        case "NOSORT":
                            if (column.Description.Trim() != "")
                                html.Append("<td style=\"border:1px solid #ddd; border-collapse:collapse;\" align=\"left\" nowrap>" + dr[column.Key] + "</td>");
                            break;

                        case "CHECKBOX":
                            break;

                        default:
                            html.Append("<td style=\"border:1px solid #ddd; border-collapse:collapse;\" align=\"left\" nowrap>" + dr[column.Key] + "</td>");
                            break;
                    }
                }

                html.Append("</tr>");
            }
            html.Append("</table>");

            return html.ToString();
        }
    }
}