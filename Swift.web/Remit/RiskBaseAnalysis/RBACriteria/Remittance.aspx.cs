using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.RiskBaseAnalysis.RBACriteria
{
    public partial class Remittance : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadGrid();
        }

        private void LoadGrid()
        {
            /*
            var sql =
                @"
                    --TXN ASSESSMENT---
                    SELECT Criteria,remarks Description, isnull(rangefrom,1) [Range From], ISNULL(rangeto,100) [Range To], ISNULL(rating,100) Rating, ISNULL(Weight,100) Weight
                    FROM  rbacriteria WHERE assessmenttype='Transaction'

                    --PERIODIC ASSESSMENT--
                    SELECT Criteria,ISNULL(remarks,criteria) Description, isnull(rangefrom,1) [Range From], ISNULL(rangeto,100) [Range To], ISNULL(rating,100) Rating, ISNULL(Weight,100) Weight
                    FROM  rbacriteria WHERE assessmenttype='Periodic'

                     ---FINAL ASSESSMENT---
                     SELECT 20 [Txn Assessment], 80 [Periodic Assessment], 100 [Final Assessment]

                     ---RATING---
                    SELECT  rFrom [Range From],  rTo [Range To] ,TYPE Rating from RBAScoreMaster
            ";*/

            var sql = "EXEC proc_RBA @flag='criteria'";

            var obj = new RemittanceDao();
            var ds = obj.ExecuteDataset(sql);

            var html = new StringBuilder();
            var dt = ds.Tables[0];
            html.Append("<p align='left'><b>Transaction Criteria</b></p>");
            html.Append(Misc.DataTableToHtmlTable(ref dt));

            dt = ds.Tables[1];
            html.Append("<p align='left'><b>Customer Criteria</b></p>");
            html.Append(Misc.DataTableToHtmlTable(ref dt));

            dt = ds.Tables[2];
            html.Append("<p align='left'><b>Trigger Criteria</b></p>");
            html.Append(Misc.DataTableToHtmlTable(ref dt));

            dt = ds.Tables[3];
            html.Append("<p align='left'><b>Rating</b></p>");
            html.Append(Misc.DataTableToHtmlTable(ref dt));

            rpt_grid.InnerHtml = html.ToString();
        }
    }
}