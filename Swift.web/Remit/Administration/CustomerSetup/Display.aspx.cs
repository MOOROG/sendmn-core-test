using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.Remit.Administration.CustomerSetup
{
    public partial class Display : System.Web.UI.Page
    {
        private readonly CustomersDao obj = new CustomersDao();
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            PopulateDataById();
        }

        protected string GetMembershipId()
        {
            return GetStatic.ReadQueryString("membershipId", "");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectByMemId(GetStatic.GetUser(), GetMembershipId().ToString());
            if (dr == null)
                return;
            customerCardNo.Text = dr["membershipId"].ToString();
            firstName.Text = dr["fullName"].ToString();
            maritalStatus.Text = dr["maritalStatus"].ToString();
            dobEng.Text = dr["dobEng"].ToString();
            dobNep.Text = dr["dobNep"].ToString();
            idType.Text = dr["idType"].ToString();
            citizenShipNo.Text = dr["citizenShipNo"].ToString();
            placeOfIssue.Text = dr["placeOfIssue"].ToString();
            expiryDate.Text = dr["expiryDate"].ToString();
            pTole.Text = dr["pTole"].ToString();
            pHouseNo.Text = dr["pHouseNo"].ToString();
            pMunicipality.Text = dr["pMunicipality"].ToString();
            pWardNo.Text = dr["pWardNo"].ToString();

            tTole.Text = dr["tTole"].ToString();
            tHouseNo.Text = dr["tHouseNo"].ToString();
            tMunicipality.Text = dr["tMunicipality"].ToString();
            tWardNo.Text = dr["tWardNo"].ToString();

            fatherName.Text = dr["fatherName"].ToString();
            motherName.Text = dr["motherName"].ToString();
            grandFatherName.Text = dr["grandFatherName"].ToString();

            occupation.Text = dr["occupation"].ToString();
            emailId.Text = dr["email"].ToString();
            phoneNo.Text = dr["phone"].ToString();
            mobileNo.Text = dr["mobile"].ToString();
            pZone.Text = dr["pZone"].ToString();
            tZone.Text = dr["tZone"].ToString();
            pDistrict.Text = dr["pDistrict"].ToString();
            tDistrict.Text = dr["tDistrict"].ToString();
            gender.Text = dr["gender"].ToString();
        }

        public DataSet GetDocuments()
        {
            DataSet ds = obj.GetDocuments(GetStatic.GetUser(), GetMembershipId().ToString(), "");
            return ds;
        }
    }
}