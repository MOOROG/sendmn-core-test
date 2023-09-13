using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentPanel.CustomerInquery
{
    public partial class List : System.Web.UI.Page
    {
        private readonly RemittanceLibrary obj = new RemittanceLibrary();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            obj.CheckSession();
            if (!IsPostBack)
            {
                divTranDetails.Visible = false;
                PopulateDdl();
            }
        }

        private void PopulateDdl()
        {
            _sl.SetDDL(ref country, "EXEC proc_online_dropDownList @flag='allCountrylist'", "countryName", "countryName", "", "Select..");
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            SearchLogs();
        }

        private void SearchLogs()
        {
            var obj = new TranViewDao();
            var dt = obj.ViewInquiry(GetStatic.GetUser(), MobileNo.Text);
            if (null == dt)
            {
                return;
            }
            var str = new StringBuilder("<table class=\"table table-responsive table-bordered table-striped\">");
            str.Append("<tr>");
            str.Append("<th>Updated By</th>");
            str.Append("<th>Updated Date</th>");
            str.Append("<th>Coutry </th>");
            str.Append("<th>Message/Complain </th>");
            str.Append("<th>Inquiry Type </th>");
            str.Append("</tr>");
            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                str.Append("<td align='left'>" + dr["createdBy"] + "</td>");
                str.Append("<td align='left'>" + dr["createdDate"] + "</td>");
                str.Append("<td align='left'>" + dr["Country"] + "</td>");
                str.Append("<td align='left'>" + dr["complian"] + "</td>");
                str.Append("<td align='left'>" + dr["msgType"] + "</td>");
                str.Append("</tr>");
            }
            str.Append("</table>");
            rptLog.InnerHtml = str.ToString();
            divTranDetails.Visible = true;
            heading.Visible = false;
            divSearch.Visible = false;
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            var obj = new TranViewDao();
            var result = obj.ManageInquiry(GetStatic.GetUser(), MobileNo.Text, msgType.Text, comments.Text, country.Text);
            SearchLogs();
        }
    }
}