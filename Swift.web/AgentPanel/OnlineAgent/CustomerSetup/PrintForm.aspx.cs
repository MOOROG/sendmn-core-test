using Swift.DAL.OnlineAgent;
using Swift.web.Library;
using System;

namespace Swift.web.AgentPanel.OnlineAgent.CustomerSetup
{
    public partial class PrintForm : System.Web.UI.Page
    {
        private OnlineCustomerDao ocd = new OnlineCustomerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            var customerId = GetStatic.ReadQueryString("customerId", "");
            if (!IsPostBack)
            {
                PopulateDataByCustomerId(customerId);
            }
        }

        private void PopulateDataByCustomerId(string customerId)
        {
            var dt = ocd.GetCustomerDetailsByCustomerId(customerId, GetStatic.GetUser());
            if (dt.Rows.Count == 0 || dt == null)
            {
                return;
            }
            else
            {
                var dr = dt.Rows[0];
                email.Text = dr["email"].ToString().ToUpper();
                fullName.Text = dr["firstName"].ToString();
                idNumber.Text = dr["idNumber"].ToString();
                expiryDate.Text = dr["idExpiryDate"].ToString();
                mobileNo.Text = dr["mobile"].ToString();
                if (dr["gender"].ToString() == "Male")
                {
                    male.Checked = true;
                }
                else
                {
                    feMale.Checked = true;
                }
                address.Text = dr["address"].ToString();
                bankName.Text = dr["bankName"].ToString();
                accountNo.Text = dr["bankAccountNo"].ToString();
                //string created_date = dr["createdDate"].ToString();
                //int customerYear = DateTime.ParseExact(created_date, "MM/dd/yyyy", CultureInfo.InvariantCulture).Year;
                //int customerDay = DateTime.ParseExact(created_date, "MM/dd/yyyy", CultureInfo.InvariantCulture).Day;
                //int customerMonth = DateTime.ParseExact(created_date, "MM/dd/yyyy", CultureInfo.InvariantCulture).Month;
                //year.InnerText = customerYear.ToString();
                //day.InnerText = customerDay.ToString();
                //month.InnerText = customerMonth.ToString();
            }
        }
    }
}