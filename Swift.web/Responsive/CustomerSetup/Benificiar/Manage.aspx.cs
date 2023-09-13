using Swift.DAL.OnlineAgent;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL;
using Swift.DAL.Remittance.Administration.ReceiverInformation;

namespace Swift.web.Responsive.CustomerSetup.Benificiar
{

    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private readonly ReceiverInformationDAO _receiver = new ReceiverInformationDAO();
        private const string ViewFunctionId = "20111300";
        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                PopulateDDL();
                string customerId = GetStatic.ReadQueryString("customerId", "");
                var result = _cd.GetCustomerDetails(customerId, GetStatic.GetUser());
                if (result != null)
                {
                    hideCustomerId.Value = customerId;
                    hideMembershipId.Value = result["membershipId"].ToString();
                    txtCustomerName.InnerText = result["firstName"].ToString() + ' ' + result["middleName"].ToString() + ' ' + result["lastName1"].ToString();
                }

                string receiverId = GetStatic.ReadQueryString("receiverId", "");
                if (receiverId != "")
                {
                    PopulateForm(receiverId);
                }
            }
        }

        private void PopulateForm(string id)
        {
            var dr = _receiver.SelectReceiverInformationByReceiverId(GetStatic.GetUser(), id);
            if (null != dr)
            {
                string countryId = dr["countryId"].ToString();
                ddlCountry.SelectedValue = countryId;
                ddlBenificiaryType.SelectedValue = dr["receiverType"].ToString();
                txtEmail.Text = dr["email"].ToString();
                txtReceiverFName.Text = dr["firstName"].ToString();
                txtReceiverLName.Text = dr["lastName1"].ToString();
                txtReceiverMName.Text = dr["middleName"].ToString();
                txtReceiverAddress.Text = dr["address"].ToString();
                txtReceiverCity.Text = dr["city"].ToString();
                txtContactNo.Text = dr["homePhone"].ToString();
                txtSenderMobileNo.Text = dr["mobile"].ToString();
                ddlRelationship.SelectedValue = dr["relationship"].ToString();
                txtPlaceOfIssue.Text = dr["placeOfIssue"].ToString();
                ddlIdType.SelectedValue = dr["idType"].ToString();
                txtIdValue.Text = dr["idNumber"].ToString();
                ddlPurposeOfRemitance.SelectedValue = dr["purposeOfRemit"].ToString();
                ddlPayoutPatner.SelectedValue = dr["payOutPartner"].ToString();
                txtBankLocation.Text = dr["bankLocation"].ToString();
                txtBankName.Text = dr["bankName"].ToString();
                txtBenificaryAc.Text = dr["receiverAccountNo"].ToString();
                txtRemarks.Text = dr["remarks"].ToString();
                hideCustomerId.Value = dr["customerId"].ToString();
                hideBenificialId.Value = dr["receiverId"].ToString();
                hideMembershipId.Value = dr["membershipId"].ToString();
                LoadPaymentModeDDL(dr["paymentMode"].ToString());
            }
        }
        private void PopulateDDL()
        {
            _sl.SetDDL(ref ddlIdType, "EXEC proc_online_dropDownList @flag='idType',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlCountry, "EXEC proc_online_dropDownList @flag='allCountrylist',@user='" + GetStatic.GetUser() + "'", "countryId", "countryName", "", "Select..");
            _sl.SetDDL(ref ddlRelationship, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=2100", "valueId", "detailTitle", "", "Select..");
            _sl.SetDDL(ref ddlPurposeOfRemitance, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=3800", "valueId", "detailTitle", "8060", "Select..");
            _sl.SetDDL(ref ddlPayoutPatner, "EXEC proc_online_sendPageLoadData @flag='banklist'", "value", "text", "", "ENTER BANK NAME..");
            _sl.SetDDL(ref ddlBenificiaryType, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=4700", "valueId", "detailTitle", ddlBenificiaryType.SelectedValue, "");
        }

        protected void register_Click(object sender, EventArgs e)
        {
            BenificiarData benificiar = new BenificiarData()
            {
                Country = ddlCountry.SelectedItem.Text,
                BenificiaryType = ddlBenificiaryType.SelectedValue,
                Email = txtEmail.Text,
                ReceiverFName = txtReceiverFName.Text,
                ReceiverMName = txtReceiverMName.Text,
                ReceiverLName = txtReceiverLName.Text,
                ReceiverAddress = txtReceiverAddress.Text,
                ReceiverCity = txtReceiverCity.Text,
                ContactNo = txtContactNo.Text,
                SenderMobileNo = txtSenderMobileNo.Text,
                Relationship = ddlRelationship.SelectedItem.Text,
                PlaceOfIssue = txtPlaceOfIssue.Text,
                TypeId = ddlIdType.SelectedValue,
                TypeValue = txtIdValue.Text,
                PurposeOfRemitance = ddlPurposeOfRemitance.SelectedItem.Text,
                PaymentMode = ddlPaymentMode.SelectedValue,
                PayoutPatner = ddlPayoutPatner.SelectedValue,
                BankLocation = txtBankLocation.Text,
                BankName = txtBankName.Text,
                BenificaryAc = txtBenificaryAc.Text,
                Remarks = txtRemarks.Text,
                membershipId= hideMembershipId.Value,
                ReceiverId = hideBenificialId.Value,
                customerId = (hideCustomerId.Value != "" ? hideCustomerId.Value : null),
                Flag = (hideBenificialId.Value != "" ? "u" : "i")
            };
            var dbResult = _cd.UpdateBenificiarInformation(benificiar, GetStatic.GetUser());
            if (dbResult.ErrorCode == "0")
            {

                GetStatic.SetMessage(dbResult);
                Response.Redirect("List.aspx?customerId=" + benificiar.customerId);
                return;
            }
            else
            {
                GetStatic.AlertMessage(this, dbResult.Msg);
                return;
            }
        }
        private void LoadPaymentModeDDL(string paymentId)
        {
            _sl.SetDDL(ref ddlPaymentMode, "EXEC proc_online_sendPageLoadData @flag='payoutMethods',@country='" + ddlCountry.SelectedItem.Text + "'", "Key", "Value", paymentId, "");
        }

        protected void ddlCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(ddlCountry.SelectedItem.Text))
            {
                LoadPaymentModeDDL(ddlPaymentMode.SelectedValue);
            }
        }
    }
}