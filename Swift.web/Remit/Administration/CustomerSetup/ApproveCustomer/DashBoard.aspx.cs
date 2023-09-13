using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.Administration.CustomerSetup.ApproveCustomer
{
    public partial class DashBoard : System.Web.UI.Page
    {
        private readonly CustomersDao _obj = new CustomersDao();
        private const string ViewFunctionId = "20111400";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                LoadHoldSummary();
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void LoadHoldSummary()
        {
            var ds = _obj.GetSummaryDashboard(GetStatic.GetUser());
            if (ds == null || ds.Tables.Count == 0)
                return;
            var dt = ds.Tables[0];
            var sbHead = new StringBuilder();
            int pending = 0;
            int complain = 0;
            int updated = 0;
            if (dt.Rows.Count > 0)
            {
                sbHead.Append("<table class ='table table-responsive table-bordered table-striped'>");
                sbHead.Append("<tr>");
                sbHead.Append("<th>S.N.</th>");
                sbHead.Append("<th>Zone</th>");
                sbHead.Append("<th>Pending</th>");
                sbHead.Append("<th>Complain</th>");
                sbHead.Append("<th>Updated</th>");
                sbHead.Append("</tr>");
                int cnt = 0;
                foreach (DataRow dr in dt.Rows)
                {
                    cnt = cnt + 1;
                    sbHead.Append("<tr>");
                    sbHead.Append("<td align=\"center\">" + cnt.ToString() + "</td>");
                    sbHead.Append("<td>" + dr["Zone"].ToString() + "</td>");
                    if (dr["Pending"].ToString() == "0")
                        sbHead.Append("<td align=\"center\">" + dr["Pending"].ToString() + "</td>");
                    else
                        sbHead.Append("<td align=\"center\"><a href='Pending.aspx?zone=" + dr["Zone"].ToString() + "&status=Pending'>" + dr["Pending"].ToString() + "</a></td>");
                    if (dr["Complain"].ToString() == "0")
                        sbHead.Append("<td align=\"center\">" + dr["Complain"].ToString() + "</td>");
                    else
                        sbHead.Append("<td align=\"center\"><a href='Pending.aspx?zone=" + dr["Zone"].ToString() + "&status=Complain'>" + dr["Complain"].ToString() + "</a></td>");
                    if (dr["Updated"].ToString() == "0")
                        sbHead.Append("<td align=\"center\">" + dr["Updated"].ToString() + "</td>");
                    else
                        sbHead.Append("<td align=\"center\"><a href='Pending.aspx?zone=" + dr["Zone"].ToString() + "&status=Updated'>" + dr["Updated"].ToString() + "</a></td>");
                    sbHead.Append("</tr>");
                    pending = pending + int.Parse(dr["Pending"].ToString());
                    complain = complain + int.Parse(dr["Complain"].ToString());
                    updated = updated + int.Parse(dr["Updated"].ToString());
                }
                sbHead.Append("<tr><td colspan='2' align=\"center\"><b>Total</b></td>");
                sbHead.Append("<td align=\"center\"><b>" + pending.ToString() + "</b></td>");
                sbHead.Append("<td align=\"center\"><b>" + complain.ToString() + "</b></td>");
                sbHead.Append("<td align=\"center\"><b>" + updated.ToString() + "</b></td>");
                sbHead.Append("</tr>");
                sbHead.Append("</table>");
                rptGrid.InnerHtml = sbHead.ToString();
            }
        }
    }
}