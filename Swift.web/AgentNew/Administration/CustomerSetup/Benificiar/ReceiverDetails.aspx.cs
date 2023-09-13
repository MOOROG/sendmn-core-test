using Swift.DAL.OnlineAgent;
using Swift.DAL.Remittance.Administration.ReceiverInformation;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.Administration.CustomerSetup.Benificiar
{
    public partial class ReceiverDetails : System.Web.UI.Page
    {

        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private readonly ReceiverInformationDAO _receiver = new ReceiverInformationDAO();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadReceiverDetails();
            }
        }

        private void LoadReceiverDetails()
        {
            var dr = _receiver.SelectReceiverInformationByReceiverIdForPrint(GetStatic.GetUser(), GetReceiverId());
            if (null != dr)
            {
                txtCustomerName.InnerText = dr["customerName"].ToString();
                txtMembershipId.InnerText = dr["membershipId"].ToString();
                txtCountry.InnerText = dr["country"].ToString();
                txtBeneficiaryType.InnerText = dr["receiverType"].ToString();
                txtEmail.InnerText = dr["email"].ToString();
                txtFirstName.InnerText = dr["firstName"].ToString();
                txtLastName.InnerText = dr["lastName1"].ToString();
                txtMiddleName.InnerText = dr["middleName"].ToString();
                txtContactNo.InnerText = dr["homePhone"].ToString();
                txtMobileNo.InnerText = dr["mobile"].ToString();

                txtPlaceOfIssue.InnerText = dr["placeOfIssue"].ToString();
                txtIdType.InnerText = dr["idType"].ToString();
                txtIdNumber.InnerText = dr["idNumber"].ToString();
                txtPurposeOfRemittance.InnerText = dr["purposeOfRemit"].ToString();
                txtAgentBank.InnerText = dr["payoutPartner"].ToString();
                txtAgentBankBranch.InnerText = dr["bankBranchName"].ToString();
                txtBeneficiaryAc.InnerText = dr["receiverAccountNo"].ToString();
                txtRemarks.InnerText = dr["remarks"].ToString();
                txtPaymentMode.InnerText = dr["paymentMode"].ToString();

                txtAddress.InnerText = dr["address"].ToString();
                txtRelationshipToBeneficiary.InnerText = dr["relationship"].ToString();
                txtNativeCountry.InnerText = dr["NativeCountry"].ToString();
                txtCity.InnerText = dr["city"].ToString();

            }

        }
        private string GetReceiverId()
        {
            return GetStatic.ReadQueryString("receiverId", "");
        }
    }
}