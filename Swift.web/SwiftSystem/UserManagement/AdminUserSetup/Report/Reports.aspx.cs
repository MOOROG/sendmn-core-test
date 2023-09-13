using System;
using System.Globalization;
using Swift.web.Library;
using Swift.DAL.SwiftDAL;
using System.Data;
using System.Text;

namespace Swift.web.SwiftSystem.UserManagement.AdminUserSetup.Report
{
    public partial class Reports : System.Web.UI.Page
    {
        SwiftDao sdao = new SwiftDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            string userList = GetStatic.ReadQueryString("userList", "");
            string agent = GetStatic.ReadQueryString("agent", "");
            string user = GetStatic.GetUser();
            string requestedBy = GetStatic.ReadQueryString("requestedBy", "");
            string requestedEmail = GetStatic.ReadQueryString("requesterEmail", "");
            string requestedDate = GetStatic.ReadQueryString("requestedDate", "");

            lblCreatedBy.Text = user;
            GenerateReport(userList, user, agent, requestedBy, requestedEmail, requestedDate);

        }

        protected void GenerateReport(string userList, string user, string agent, string requestedBy, string requestedEmail, string requestedDate)
        {
            var className = "";
            var i = 0;
            lblRequestedBy.Text = CultureInfo.CurrentCulture.TextInfo.ToTitleCase(requestedBy.ToLower());
            lblReqEmail.Text = requestedEmail;
            lblReqDate.Text = requestedDate;
            var dat = DateTime.Today.ToString("dd-MMM-yyyy");
            string sql = "EXEC proc_userReport @flag = 's'";
            sql += ", @user = " + sdao.FilterString(user);
            sql += ", @userList = " + sdao.FilterString(userList);
            DataTable dt = sdao.ExecuteDataset(sql).Tables[0];

            var html = new StringBuilder("<table class=\"gridTable\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">");
            html.Append("<tr>");
            html.Append("<th valign=\"top\" style=\"width:120px;\">");
            html.Append("<table class=\"gridTable\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">");
            html.Append("<tr>");
            html.Append("<th colspan=\"2\" rowspan=\"5\" class=\"hdtitle\" valign=\"top\"> E: Enrollment User <br /> C: Cancellation User<br /> D: Deactivated User<br /> P: password Reset <br /> A: Activated User </th>");
            html.Append("</tr>");
            html.Append("</table>");
            html.Append("</th>");
            html.Append("<th valign=\"top\">");
            html.Append("<table class=\"gridTable\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">");
            html.Append("<tr>");
            html.Append("<th class=\"hdtitle\">Name Of Company:</th>");
            html.Append("<th colspan=\"4\" class=\"hdtitle\"><center>" + agent + "</center></th>");
            html.Append("<th colspan=\"2\" class=\"hdtitle\"><center>" + dat + "</center></th>");
            html.Append("</tr>");
            html.Append("<tr>");
            html.Append("<th class=\"hdtitle\">Name of Designated User </th>");
            html.Append("<th class=\"hdtitle\"><center>Branch Name </center></th>");
            html.Append("<th class=\"hdtitle\"><center>User Type <br/> Head Office/Branch Office</center></th>");
            html.Append("<th class=\"hdtitle\"><center>Manager/Teller/Approver</center></th>");
            html.Append("<th class=\"hdtitle\"><center>Agent Code </center></th>");
            html.Append("<th class=\"hdtitle\"><center>User Id</center></th>");
            html.Append("<th class=\"hdtitle\"><center>Initial Password </center></th>");
            html.Append("</tr>");
            foreach (DataRow dr in dt.Rows)
            {
                i++;
                if (i % 2 == 0)
                {
                    className = "\"evenbg\"";
                }
                else
                {
                    className = "\"oddbg\"";
                }
                html.Append("<tr class=" + className + ">");
                html.Append("<td align=\"left\">" + dr["UserName"] + "</td>");
                html.Append("<td>" + dr["BranchName"] + "</td>");
                html.Append("<td>" + dr["UserType"] + "</td>");
                html.Append("<td>" + dr["Manager/Teller/Approver"] + "</td>");
                html.Append("<td>" + dr["AgentCode"] + "</td>");
                html.Append("<td>" + dr["UserId"] + "</td>");
                html.Append("<td>" + dr["InitialPassword"] + "</td>");
                html.Append("</tr>");
            }
            html.Append("</table>");
            html.Append("</th>");
            html.Append("</tr>");
            html.Append("</table>");
            rptReport.InnerHtml = html.ToString();
        }
    }
}