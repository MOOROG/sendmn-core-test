using Swift.DAL.Remittance.TPSetup;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.TPSetup.ServiceWiseLocation
{
    public partial class ManageLocation : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly TPSetupDao _settingDao = new TPSetupDao();
        private const string ViewFunctionId = "20174000";
        private const string AddEditFunctionId = "20174010";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                PopulateDDL();
                saveData.Visible = _sl.HasRight(AddEditFunctionId);
                if (GetId() != "")
                {
                    PopulateForm();
                }
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void PopulateForm()
        {
            var dr = _settingDao.GetPartnerDetails(GetId(), GetStatic.GetUser());
            if (null != dr)
            {
                countryDDL.SelectedValue = dr["countryId"].ToString();
                PopulateServiceType(dr["countryId"].ToString(), dr["serviceTypeId"].ToString());
                partnerLocation.Text = dr["location"].ToString();
                partnerLocationCode.Text = dr["partnerLocationId"].ToString();
                isActive.SelectedValue = dr["isActive"].ToString();
            }
        }

        protected void PopulateDDL()
        {
            _sl.SetDDL(ref countryDDL, "EXEC proc_online_dropDownList @flag='allCountrylist'", "countryId", "countryName", "", "Select Partner Country");
        }

        protected void countryDDL_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateServiceType(countryDDL.SelectedValue);
        }

        private void PopulateServiceType(string countryId, string serviceTypeId = "")
        {
            if (string.IsNullOrEmpty(countryId))
            {
                serviceTypeDDL.Items.Add("Not defined");
                return;
            }
            serviceTypeDDL.Items.Clear();
            _sl.SetDDL(ref serviceTypeDDL, "EXEC proc_tpLocationSetup @flag='serviceType', @countryId = " + countryId, "serviceTypeId", "serviceTypeName", serviceTypeId, "All");
        }

        protected void saveData_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void Update()
        {
            DbResult dbResult = _settingDao.InsertUpdateSetup(GetId(), GetStatic.GetUser(), countryDDL.SelectedValue, serviceTypeDDL.SelectedValue, partnerLocation.Text, partnerLocationCode.Text, isActive.SelectedValue);
            
            if (dbResult.ErrorCode == "0")
            {
                GetStatic.SetMessage(dbResult);
                Response.Redirect("List.aspx");
                return;
            }
            else
            {
                GetStatic.AlertMessage(this, dbResult.Msg);
                return;
            }
        }

        private string GetId()
        {
            return GetStatic.ReadQueryString("rowId", "");
        }
    }
}