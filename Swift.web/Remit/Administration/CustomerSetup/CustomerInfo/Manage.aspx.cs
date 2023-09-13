using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.Administration.CustomerSetup.CustomerInfo
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20821800,20822000";
        private const string AddEditFunctionId = "20821810,20822010";
        private readonly CustomerInfoDao obj = new CustomerInfoDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //Authenticate();
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
            }
        }

        #region QueryString

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("customerInfoId");
        }

        protected long GetCustomerId()
        {
            return GetStatic.ReadNumericDataFromQueryString("customerId");
        }

        protected string GetCustomerName()
        {
            return "Customer Name : " + sl.GetCustomerName(GetCustomerId().ToString());
        }

        #endregion QueryString

        #region Method

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            date.Text = dr["date1"].ToString();
            subject.Text = dr["subject"].ToString();
            description.Text = dr["description"].ToString();
            setPrimary.SelectedValue = dr["setPrimary"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), GetId().ToString(), GetCustomerId().ToString(),
                                           date.Text, subject.Text, description.Text, setPrimary.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                GetStatic.CallBackJs1(Page, "Close Window", "CloseForm(" + dbResult.ErrorCode + ");");
            }
            else
            {
                GetStatic.AlertMessage(Page);
                return;
            }
        }

        #endregion Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }
    }
}