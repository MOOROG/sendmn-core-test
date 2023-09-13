using System;
using System.Collections.Generic;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using Swift.DAL.SwiftDAL;
using Swift.DAL.BL.Remit.Compliance;
using System.Text;
namespace Swift.web.Remit.RiskBaseAnalysis.RBACustomer
{
    public partial class RBAExceptionRpt : System.Web.UI.Page
    {
        protected const string GridName = "gridRBACustomerRpt";
        private string ViewFunctionId = "20191500";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        private readonly RBACustomerDao obj = new RBACustomerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
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

            var sb = new StringBuilder("<table width=\"524\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\" class=\"TBL\">");

            sb.AppendLine("<tr >");
            
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap' rowspan='2'>RISK</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap' rowspan='2'>TXN</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap' colspan='3'>COMPLETED</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap' colspan='3'>PENDING</th>");
           

            sb.AppendLine("</tr>");

            sb.AppendLine("<tr >");
            
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>CDD</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>EDD</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>STR</th>");

            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>CDD</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>EDD</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>STR</th>");

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
                    GetStatic.AlertMessage(this, "Error Occurred.\\n"+ex.Message);
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