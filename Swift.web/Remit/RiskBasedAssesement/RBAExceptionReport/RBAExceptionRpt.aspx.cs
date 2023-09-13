using Swift.DAL.Remittance.RBA;
using Swift.web.Component.Grid;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.RiskBasedAssesement.RBAExceptionReport
{
    public partial class RBAExceptionRpt : System.Web.UI.Page
    {
        protected const string GridName = "gridRBACustomerRpt";
        private string ViewFunctionId = "20191500";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly RBACustomerDao obj = new RBACustomerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
              //  Authenticate();
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }

        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {

            rpt_grid.InnerHtml = "";

            var dt = obj.LoadRBAExceptionRpt(GetStatic.GetUser(), fromDate.Text, toDate.Text, country.Value, agent.Value, branch.Value, reportType.SelectedValue);

            int cnt = 0;

            var sb = new StringBuilder("<table class=\"table table-responsive table-striped table-bordered\">");

            sb.AppendLine("<tr >");

            sb.AppendLine("<th nowrap='nowrap' rowspan='2'>RISK</th>");
            sb.AppendLine("<th nowrap='nowrap' rowspan='2'>TXN</th>");
            sb.AppendLine("<th nowrap='nowrap' colspan='3'>COMPLETED</th>");
            sb.AppendLine("<th nowrap='nowrap' colspan='3'>PENDING</th>");


            sb.AppendLine("</tr>");

            sb.AppendLine("<tr >");

            sb.AppendLine("<th nowrap='nowrap'>CDD</th>");
            sb.AppendLine("<th nowrap='nowrap'>EDD</th>");
            sb.AppendLine("<th nowrap='nowrap'>STR</th>");

            sb.AppendLine("<th nowrap='nowrap'>CDD</th>");
            sb.AppendLine("<th nowrap='nowrap'>EDD</th>");
            sb.AppendLine("<th nowrap='nowrap'>STR</th>");

            sb.AppendLine("</tr>");
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                try
                {
                    ++cnt;
                    sb.AppendLine("<tr>");
                    sb.AppendLine("<td>" + dt.Rows[i]["RISK"] + "</td>");
                    sb.AppendLine("<td class=\"alignRight\">" + dt.Rows[i]["TXN"] + "</td>");
                    sb.AppendLine("<td class=\"alignRight\">" + dt.Rows[i]["CDD"] + "</td>");
                    sb.AppendLine("<td class=\"alignRight\">" + dt.Rows[i]["EDD"] + "</td>");
                    sb.AppendLine("<td class=\"alignRight\">" + dt.Rows[i]["STR"] + "</td>");
                    sb.AppendLine("<td class=\"alignRight\">" + dt.Rows[i]["P_CDD"] + "</td>");
                    sb.AppendLine("<td class=\"alignRight\">" + dt.Rows[i]["P_EDD"] + "</td>");
                    sb.AppendLine("<td class=\"alignRight\">" + dt.Rows[i]["P_STR"] + "</td>");
                    sb.AppendLine("</tr>");
                }
                catch (Exception ex)
                {
                    GetStatic.AlertMessage(this, "Error Occurred.\\n" + ex.Message);
                }
            }
            sb.AppendLine("</table>");
            rpt_grid.InnerHtml = sb.ToString();
        }

        protected void showReport_Click(object sender, EventArgs e)
        {
            if (fromDate.Text.Trim() == "" || toDate.Text.Trim() == "")
            {
                GetStatic.AlertMessage(this, "From and To date is required fields. Required field cannot be blank.");
                return;
            }
            if (reportType.SelectedValue == "")
            {
                GetStatic.AlertMessage(this, "Report type is required field. Required field cannot be blank.");
                return;
            }

            LoadGrid();
        }


    }
}