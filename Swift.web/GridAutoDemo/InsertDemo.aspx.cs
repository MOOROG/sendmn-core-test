using Swift.DAL.GridAutoDemo;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.GridAutoDemo
{
    public partial class InsertDemo : System.Web.UI.Page
    {
        private readonly EmployeeDetailsDao detailsDao = new EmployeeDetailsDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            txtPageName.Text = "Add Employee";
            btnAdd.Visible = true;
            btnEdit.Visible = false;
            if (!IsPostBack)
            {
                string eId = GetStatic.ReadQueryString("Id", "");
                if (eId != "")
                {
                    EditForm(eId);
                }
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            Msg.Visible = false;
            var name = txtName.Text;
            var address = txtAddress.Text;
            var email = txtEmail.Text;
            var mobileNo = txtMobile.Text;
            var departName = txtDepName.Text;
            var dob = Convert.ToDateTime(txtDob.Text);
            var companyJoin = Convert.ToDateTime(txtJoinDate.Text);
            int workday = Convert.ToInt32(txtWorkDay.Text);
            var description = txtDescription.Text;
            var result = detailsDao.EmployeeRegister(new EmployeeModel() { Name = name, Address = address, Email = email, MobileNo = mobileNo, DepartName = departName, DOB = dob, CompanyJoinDate = companyJoin, WorkDayOnWeek = workday, Description = description, Flag = "I" });
            if (result.ErrorCode == "1")
            {
                Msg.CssClass = "alert alert-danger";
                Msg.Text = result.Msg;
                Msg.Visible = true;
                GetStatic.AlertMessage(this, result.Msg);
                return;
            }
            ClearAll();
            Msg.CssClass = "alert alert-info";
            Msg.Text = "Data Updated !!";
            Msg.Visible = true;
        }

        protected void EditForm(string Id)
        {
            ClearAll();
            var result = detailsDao.GetEmployeeDetails(Id);
            if (result != null)
            {
                txtPageName.Text = "Update Employee";
                btnAdd.Visible = false;
                btnEdit.Visible = true;
                txtId.Text = result["Id"].ToString();
                txtName.Text = result["Name"].ToString();
                txtAddress.Text = result["Address"].ToString();
                txtEmail.Text = result["Email"].ToString();
                txtMobile.Text = result["MobileNo"].ToString();
                txtDepName.Text = result["DepartName"].ToString();
                txtDob.Text = result["DOB"].ToString();
                txtJoinDate.Text = result["CompanyJoinDate"].ToString();
                txtWorkDay.Text = result["WorkDayOnWeek"].ToString();
                txtDescription.Text = result["Description"].ToString();
            }
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Msg.Visible = false;
            var id = txtId.Text.ToString();
            var name = txtName.Text;
            var address = txtAddress.Text;
            var email = txtEmail.Text;
            var mobileNo = txtMobile.Text;
            var departName = txtDepName.Text;
            var dob = Convert.ToDateTime(txtDob.Text);
            var companyJoin = Convert.ToDateTime(txtJoinDate.Text);
            int workday = Convert.ToInt32(txtWorkDay.Text);
            var description = txtDescription.Text;
            var result = detailsDao.EmployeeRegister(new EmployeeModel() { Id = Convert.ToInt32(id), Name = name, Address = address, Email = email, MobileNo = mobileNo, DepartName = departName, DOB = dob, CompanyJoinDate = companyJoin, WorkDayOnWeek = workday, Description = description, Flag = "U" });
            if (result.ErrorCode == "1")
            {
                Msg.CssClass = "alert alert-danger";
                Msg.Text = result.Msg;
                Msg.Visible = true;
                GetStatic.AlertMessage(this, result.Msg);
                return;
            }
            ClearAll();
            Msg.CssClass = "alert alert-info";
            Msg.Text = "Data Updated !!";
            Msg.Visible = true;
        }

        private void ClearAll()
        {
            txtId.Text = "";
            txtName.Text = "";
            txtAddress.Text = "";
            txtEmail.Text = "";
            txtMobile.Text = "";
            txtDepName.Text = "";
            txtDob.Text = "";
            txtJoinDate.Text = "";
            txtWorkDay.Text = "";
            txtDescription.Text = "";
        }
    }
}