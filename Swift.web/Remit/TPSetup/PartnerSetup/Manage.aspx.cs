using Swift.DAL.Remittance.Partner;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.PartnerSetup
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly PartnerDao _partnerDao = new PartnerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateDDL();
                GetStatic.PrintMessage(Page);
                if (GetId() != "")
                {
                    PopulateForm();
                }
            }
        }
        
        protected void PopulateDDL()
        {
            _sl.SetDDL(ref partnerCountryDDL, "EXEC proc_online_dropDownList @flag='allCountrylist'", "countryId", "countryName", "", "Select Partner Country");
        }

        protected string GetId()
        {
            return GetStatic.ReadQueryString("id", "");
        }

        protected void PopulateForm()
        {
            var dr = _partnerDao.GetPartnerDetails(GetId(), GetStatic.GetUser());
            if (null != dr)
            {
                partnerName.Text = dr["partnerName"].ToString();
                partnerAddress.Text = dr["partnerAddress"].ToString();
                partnerCountryDDL.SelectedValue = dr["partnerCountryId"].ToString();
                partnerContact.Text = dr["partnerContact"].ToString();
                isActive.SelectedValue = dr["isActive"].ToString();
            }
        }

        protected void saveData_Click(object sender, EventArgs e)
        {
            DbResult dbResult = _partnerDao.RegisterPartner(partnerName.Text, partnerAddress.Text, partnerCountryDDL.SelectedValue, partnerContact.Text, isActive.SelectedValue, GetId(), GetStatic.GetUser());
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
    }
}