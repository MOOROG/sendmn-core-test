using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.UserManagement.AdminUserSetup.Report
{
    public partial class UserReport : System.Web.UI.Page
    {
        readonly SwiftDao sdao = new SwiftDao();
        readonly SwiftLibrary sl = new SwiftLibrary();
        private const string ViewFunctionId = "10101500";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            txtRequestedDate.Text = DateTime.Now.ToString("MM/dd/yyyy");
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            if (addList.Items.Count == 0)
            {
                err.Visible = true;
                return;
            }

            var userlist = "";
            for (var i = 0; i < addList.Items.Count; i++)
            {
                userlist += sdao.FilterString(addList.Items[i].ToString()) + ",";
            }
            var url = "Reports.aspx?reportName=userReports" +
                    "&userList=" + userlist +
                    "&agent=" + agent.Text +
                    "&requestedBy=" + txtRequestedBy.Text +
                    "&requesterEmail=" + txtReqEmail.Text +
                    "&requestedDate=" + txtRequestedDate.Text;
            Response.Redirect(url);

        }

        protected void btnAddToList_Click(object sender, EventArgs e)
        {
            if (addList.Items.Count == 0)
                err.Visible = false;
            if (!ItemsExists(addList, user.Text) && user.Text.Length > 0)
            {
                addList.Items.Add(user.Text);
            }
        }

        public bool ItemsExists(DropDownList addList, string user)
        {
            for (var i = 0; i < addList.Items.Count; i++)
            {
                if (addList.Items[i].ToString() == user)
                    return true;
            }

            return false;
        }
        protected void bttnRemoveSelected_Click(object sender, EventArgs e)
        {
            if (addList.Items.Cast<ListItem>().Any(li => addList.SelectedItem.Text == li.Text))
            {
                addList.Items.Remove(addList.Items.FindByText(addList.SelectedItem.Text));
            }
        }


    }
}