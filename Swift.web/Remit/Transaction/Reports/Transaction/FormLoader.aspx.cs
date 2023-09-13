using System;
using System.Data;
using System.Text;
using System.Web.UI;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.Transaction
{
    public partial class FormLoader : Page
    {
        private readonly string templateId = GetStatic.ReadQueryString("templateId", "");
        protected void Page_Load(object sender, EventArgs e)
        {
            ReturnValue();
        }
        private void ReturnValue()
        {
            if (GetQueryType() == "a")
                PopulateRptTemplate();
            else if (GetQueryType() == "b")
                PopulateRptFields();
            else if (GetQueryType() == "d")
                DeleteTemplate();
        }

        private string GetQueryType()
        {
            return GetStatic.ReadQueryString("type", "");
        }

        private void PopulateRptTemplate()
        {
            var dao = new RemittanceDao();
            var sql = "EXec proc_manageTranRptTemplete @flag='a',@user="+dao.FilterString(GetStatic.GetUser())+"";
            var dt = dao.ExecuteDataset(sql).Tables[0];
            if (dt == null || dt.Rows.Count == 0)
            {
                Response.Write("<select id=\"reportTemplate\" class=\"form-control\" onchange=\"PopulateRptFields();\"></select>");
                return;
            }
            var html =
                new StringBuilder("<select id=\"reportTemplate\" class=\"form-control\" onchange=\"PopulateRptFields();\">");
            html.Append("<option value = \"\">Select</option>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<option value = \"" + dr["id"] + "\">" + dr["templateName"] + "</option>");
            }
            html.Append("</select>");
            Response.Write(html.ToString());
        }

        private void PopulateRptFields()
        {
            var dao = new RemittanceDao();
            var sql = "EXec proc_manageTranRptTemplete @flag='b',@rowId=" + dao.FilterString(templateId) + "";
            var dt = dao.ExecuteDataset(sql).Tables[0];
            if (dt == null || dt.Rows.Count == 0)
            {
                Response.Write("NO FIELDS FOUND!");
                return;
            }
            var html =new StringBuilder("<table class=\"table table-responsive\">");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<tr>");
                html.Append("<td>" + dr["value"] + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table>");
            Response.Write(html.ToString());
        }

        private void DeleteTemplate()
        {
            var dao = new TranReportDao();
            var dbResult = dao.DeleteTemplateRpt(GetStatic.GetUser(), templateId);

            Response.Write(dbResult.ErrorCode + "|" + dbResult.Msg + "|" + dbResult.Id);
            return;
        }
    }
}