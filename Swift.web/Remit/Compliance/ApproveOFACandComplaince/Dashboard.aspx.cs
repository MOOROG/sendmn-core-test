using Swift.DAL.Remittance.Compliance;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.Compliance.ApproveOFACandComplaince
{
    public partial class List : System.Web.UI.Page
    {
        private readonly PayComplianceDao _obj = new PayComplianceDao();
        private const string ViewFunctionId = "20193001";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                LoadSummary();
            }
            GetStatic.ResizeFrame(Page);
            GetStatic.AlertMessage(this);
        }

        private void LoadSummary()
        {
            var ds = _obj.GetSummaryDashboard(GetStatic.GetUser());
            if (ds == null || ds.Tables.Count == 0)
                return;
            var dt = ds.Tables[0];
            var sbHead = new StringBuilder();
            if (dt.Rows.Count > 0)
            {
                sbHead.Append("<table class ='table table-responsive table-striped table-bordered'>");
                sbHead.Append("<tr>");
                sbHead.Append("<th colspan='3'>Hold Summary Information</th>");
                sbHead.Append("</tr>");

                sbHead.Append("<tr>");
                sbHead.Append("<th>S.N.</th>");
                sbHead.Append("<th>Head</th>");
                sbHead.Append("<th>Count</th>");
                sbHead.Append("</tr>");
                int cnt = 0;
                foreach (DataRow dr in dt.Rows)
                {
                    cnt = cnt + 1;
                    sbHead.Append("<tr>");
                    sbHead.Append("<td>" + cnt.ToString() + "</td>");
                    sbHead.Append("<td>" + dr["HEAD"] + "</td>");
                    sbHead.Append("<td align=\"center\">" + dr["COUNT"] + "</td>");
                    sbHead.Append("</tr>");
                }
                sbHead.Append("</table>");
                txnSummary.InnerHtml = sbHead.ToString();
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }
    }
}