using System;
using System.Data;
using System.Text;
using System.Web.UI;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Agent.ServiceCharge
{
    public partial class ViewSC : Page
    {
        private const string ViewFunctionId = "40131100";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceDao dao = new RemittanceDao();
        string tranType = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();

                _sdd.SetDDL(ref pCountry, "EXEC proc_rsList1 @flag = 'pcl', @agentId = '"+GetStatic.GetAgentId()+"'", "countryId", "countryName", "", "Select");
                _sdd.SetDDL(ref cCurrency, "EXEC proc_agentCurrency @flag = 'acl', @agentId ='" + GetStatic.GetAgentId() + "'", "currencyCode", "currencyCode", "", "Select");
               
            }
        }

        private void LoadAll()
        {
            StringBuilder str = new StringBuilder("<table width='500px' border=\"0\" class=\"TBL\" cellpadding=\"5\" cellspacing=\"0\">");
            DataTable dt = dao.getTable("EXEC proc_sscReportAgent @flag = 'a', @agentId = '" + GetStatic.GetAgentId() + "',@pCountry='" + pCountry.Text + "',@pCurrency='" + cCurrency.Text + "'");
            int rows = dt.Rows.Count;
            int cols = dt.Columns.Count;

            if (rows > 0)
            {
                str.Append("<tr>");
                for (int i = 1; i < cols; i++)
                {
                    str.Append("<th align=\"right\">" + dt.Columns[i].ColumnName + "</th>");
                }
                str.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    if (tranType != dr["Tran Type"].ToString())
                    {
                        tranType = dr["Tran Type"].ToString();
                        str.Append("<tr>");
                        str.Append("<td align=\"left\" colspan='5'><b>Tran Type: "+tranType+"</b></td>");
                        str.Append("</tr>");
                    }
                    str.Append("<tr>");
                    for (int i = 1; i < cols; i++)
                    {
                        str.Append("<td align=\"right\">" + dr[i].ToString() + "</td>");
                    }
                    str.Append("</tr>");
                }
                
            }
            else
            {
                str.Append("<tr>");
                str.Append("<th align=\"left\">Remarks</th>");
                str.Append("</tr>");
                str.Append("<tr>");
                str.Append("<td align=\"left\">Service Charge is not setup yet!</td>");
                str.Append("</tr>");
            }
            str.Append("</table>");
            RPTSC.InnerHtml = str.ToString();
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            showRpt.Visible = true;
            LoadAll();
        }
        
    }
}