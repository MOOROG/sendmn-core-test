using Swift.DAL.OnlineAgent;
using Swift.web.Library;
using System;

namespace Swift.web.AgentPanel.OnlineAgent.CustomerSetup
{
    public partial class VerifyUser : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private const string ViewFunctionId = "40120000";

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                string id = GetStatic.ReadQueryString("customerId", "");
                if (id != "")
                    PopulateCustomerDetails(id);
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateCustomerDetails(string id)
        {
            var dr = _cd.GetVerifyCustomerDetails(id, GetStatic.GetUser());
            hdnCustomerId.Value = dr["customerId"].ToString();
            fullName.Text = dr["fullName"].ToString();
            genderList.Text = dr["gender"].ToString();
            countryList.Text = dr["country"].ToString();
            addressLine1.Text = dr["address"].ToString();
            postalCode.Text = dr["postalCode"].ToString();
            city.Text = dr["city"].ToString();
            email.Text = dr["email"].ToString();
            phoneNumber.Text = dr["homePhone"].ToString();
            mobile.Text = dr["mobile"].ToString();
            nativeCountry.Text = dr["nativeCountry"].ToString();
            dob.Text = dr["dob"].ToString();
            occupation.Text = dr["occupation"].ToString();
            IssueDate.Text = dr["idIssueDate"].ToString();
            ExpireDate.Text = dr["idExpiryDate"].ToString();
            idType.Text = dr["idType"].ToString();
            verificationTypeNo.Text = dr["idNumber"].ToString();

            if (dr["verifyDoc1"].ToString() != "")
                verfDoc1.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc1"] + "&idNumber=" + dr["homePhone"];
            if (dr["verifyDoc2"].ToString() != "")
                verfDoc2.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc2"] + "&idNumber=" + dr["homePhone"];
            if (dr["verifyDoc3"].ToString() != "")
                verfDoc3.ImageUrl = "GetDocumentView.ashx?imageName=" + dr["verifyDoc3"] + "&idNumber=" + dr["homePhone"];
        }

        protected void verify_Click(object sender, EventArgs e)
        {
            var res = _cd.VerifyCustomer(hdnCustomerId.Value, GetStatic.GetUser());
            if (res.ErrorCode == "0")
            {
                GetStatic.SetMessage(res);
                Response.Redirect("List.aspx");
            }
        }
    }
}