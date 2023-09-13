using System;
using System.Collections.Generic;
using Swift.DAL.BL.Remit.Compliance;
using Swift.web.Library;
using System.Text;
using System.Data;

namespace Swift.web.Remit.RiskBaseAnalysis
{
    public partial class RBACalculationDetails : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            ShowCalculationDetail();
        }

        private void ShowCalculationDetail()
        {
            var obj = new RBACustomerDao();
            var ds = obj.GetRBACalculationDetail(GetStatic.GetUser(), GetStatic.ReadQueryString("customerId", ""));
            if (ds == null)
                return;

            var dr = ds.Tables[0].Rows[0];
            fullName.Text = dr["fullName"].ToString();
            dob.Text = dr["dob"].ToString();
            gender.Text = dr["gender"].ToString();
            nativeCountry.Text = dr["nativeCountry"].ToString();
            country.Text = dr["country"].ToString();
            idType.Text = dr["idType"].ToString();
            idNumber.Text = dr["idNumber"].ToString();
            state.Text = dr["state"].ToString();
            city.Text = dr["city"].ToString();
            address.Text = dr["address"].ToString();
            mobileNo.Text = dr["mobile"].ToString();
            email.Text = dr["email"].ToString();
            rbaLevel.Text = dr["type"].ToString();
            rbaRating.Text = dr["rba"].ToString();


            var dr1 = ds.Tables[1].Rows[0];
            taRating.Text = dr1["taRating"].ToString();
            taWeight.Text = dr1["taWeight"].ToString();
            paRating.Text = dr1["paRating"].ToString();
            paWeight.Text = dr1["paWeight"].ToString();


            var sb = new StringBuilder();
            sb.Append("<table>");
            sb.Append("<tr class=\"header\">");
            sb.Append("<th colspan=\"4\">RBA Calculation Summary-Transaction Assesement</th>");
            sb.Append("</tr>");

            sb.Append("<tr class=\"sub-header\">");
            sb.Append("<th>Criteria</th>");
            sb.Append("<th>Description</th>");
            sb.Append("<th>Rating</th>");
            sb.Append("<th>Weight</th>");
            sb.Append("</tr>");
            
            foreach (DataRow dr2 in ds.Tables[2].Rows)
            {
                sb.Append("<tr>");
                sb.Append("<td>" + dr2["Criteria"].ToString() + "</td>");
                sb.Append("<td>" + dr2["Description"].ToString() + "</td>");
                sb.Append("<td>" + dr2["Rating"].ToString() + "</td>");
                sb.Append("<td>" + dr2["Weight"].ToString() + "</td>");
                sb.Append("</tr>");
            }
            sb.Append("</table>");
            rbaCsTa.InnerHtml = sb.ToString();

            sb.Clear();
            sb.Append("<table>");
            sb.Append("<tr class=\"header\">");
            sb.Append("<th colspan=\"4\">RBA Calculation Summary-Periodic Assesement</th>");
            sb.Append("</tr>");

            sb.Append("<tr class=\"sub-header\">");
            sb.Append("<th>Criteria</th>");
            sb.Append("<th>Description</th>");
            sb.Append("<th>Rating</th>");
            sb.Append("<th>Weight</th>");
            sb.Append("</tr>");
       
            foreach (DataRow dr3 in ds.Tables[3].Rows)
            {
                sb.Append("<tr>");
                sb.Append("<td>" + dr3["Criteria"].ToString() + "</td>");
                sb.Append("<td>" + dr3["Description"].ToString() + "</td>");
                sb.Append("<td>" + dr3["Rating"].ToString() + "</td>");
                sb.Append("<td>" + dr3["Weight"].ToString() + "</td>");
                sb.Append("</tr>");
            }
            sb.Append("</table>");
            rbaCsPa.InnerHtml = sb.ToString();
        }
    }
}