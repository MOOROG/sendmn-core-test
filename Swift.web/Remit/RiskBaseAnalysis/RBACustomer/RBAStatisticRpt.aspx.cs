using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.BL.Remit.Compliance;
using Swift.web.Library;
using System.Data;

namespace Swift.web.Remit.RiskBaseAnalysis.RBACustomer
{
    public partial class RBAStatisticRpt : System.Web.UI.Page
    {
        protected string pieValue = "";
        protected string pieValueSc = "";
        private readonly RBACustomerDao obj = new RBACustomerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            /*pieValue = @"
                          { name: 'HIGH', color: '#e32636', y: 1, url: 'RBAStatisticRpt.aspx' },
		                  { name: 'MEDIUM', color: '#ff9966', y: 31, url: 'RBAStatisticRpt.aspx' },
		                  { name: 'LOW', color: '#008000', y: 68, url: 'RBAStatisticRpt.aspx' }
                        
                        "; */

            var rptdrildown = GetStatic.ReadQueryString("q","");
            rptdrildown=rptdrildown.ToLower();

            if (rptdrildown == "high" || rptdrildown == "medium" || rptdrildown == "low")
            {
                 var ds = obj.RBAStatisticRptDl(GetStatic.GetUser(), rptdrildown);
                 var dt = ds.Tables[0];
                var dt1 = ds.Tables[1];
                pieValueSc = "";
                pieValue = "";
                if (dt.Rows.Count > 0)
                {
                    foreach (DataRow dr in dt.Rows)
                    {
                        pieValue += "{ name: '" + dr["country"].ToString() + "', y: " + dr["percent"].ToString() + " },";
                    }
                }

                if (dt1.Rows.Count > 0)
                {

                    foreach (DataRow dr in dt1.Rows)
                    {
                        pieValueSc += "{ name: '" + dr["country"].ToString() + "', y: " + dr["percent"].ToString() + " },";
                    }
                    sCountryWise.Visible = true;
                }

            }
            else
            {
                var dt = obj.RBAStatisticRpt(GetStatic.GetUser());
                if (dt.Rows.Count > 0)
                {
                    DataRow dr = dt.Rows[0];

                    pieValue = "{ name: 'HIGH', color: '#e32636', y: " + dr[0] + ", url: 'RBAStatisticRpt.aspx?q=high' },";
                    pieValue += "{ name: 'MEDIUM', color: '#ff9966', y: " + dr[1] + ", url: 'RBAStatisticRpt.aspx?q=medium' },";
                    pieValue += "{ name: 'LOW', color: '#008000', y: " + dr[2] + ", url: 'RBAStatisticRpt.aspx?q=low' }";
                }
            }
            
        }
    }
}