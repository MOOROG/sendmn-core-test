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
    public partial class ManageSubLocation : System.Web.UI.Page
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
                saveData.Visible = _sl.HasRight(AddEditFunctionId);
                locName.Text = GetLocName();
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

        public string GetLocName()
        {
            return GetStatic.ReadQueryString("locName", "");
        }

        protected void PopulateForm()
        {
            var dr = _settingDao.GetSubLocationDetails(GetId(), GetStatic.GetUser());
            if (null != dr)
            {
                partnerSubLocation.Text = dr["subLocation"].ToString();
                partnerLocationCode.Text = dr["partnerSubLocationId"].ToString();
                isActive.SelectedValue = dr["isActive"].ToString();
            }
        }

        protected void saveData_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void Update()
        {
            DbResult dbResult = new DbResult();
            if (string.IsNullOrEmpty(GetLocationId()))
            {
                dbResult.ErrorCode = "1";
                dbResult.Msg = "No location found, please try again!";
                GetStatic.SetMessage(dbResult);
                Response.Redirect("List.aspx");
            }
            dbResult = _settingDao.InsertUpdateSubLocation(GetId(), GetStatic.GetUser(), partnerSubLocation.Text, partnerLocationCode.Text, isActive.SelectedValue, GetLocationId());

            if (dbResult.ErrorCode == "0")
            {
                GetStatic.SetMessage(dbResult);
                Response.Redirect("SubLocationList.aspx?locId=" + GetLocationId() + "&locName=" + GetStatic.ReadQueryString("locName", ""));
                return;
            }
            else
            {
                GetStatic.AlertMessage(this, dbResult.Msg);
                return;
            }
        }

        public string GetLocationId()
        {
            return GetStatic.ReadQueryString("locId", "");
        }

        public string GetId()
        {
            return GetStatic.ReadQueryString("rowId", "");
        }
    }
}