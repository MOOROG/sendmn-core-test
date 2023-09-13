using Swift.DAL.OnlineAgent;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.CustomerRegistration
{
    public partial class PrintDetails : System.Web.UI.Page
    {

        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCustomerDetails();
            }
        }

        protected void approve_Click(object sender, EventArgs e)
        {

        }
        private void LoadCustomerDetails()
        {
            var membershipId = GetMembershipId();
            var dataSet = _cd.GetCustomerInfoFromMembershiId(GetStatic.GetUser(), membershipId);
            var dr = dataSet.Tables[1].Rows[0];
            var registerDate = dr["createdDate"].ToString();
            hdnCustomerId.Value = dr["customerId"].ToString();
            TxtMembershipId.InnerText = dr["membershipId"].ToString();
            txtCustomerType.InnerText = dr["customerType"].ToString();
            txtFullName.InnerText = dr["fullName"].ToString();
            hdnAccountName.Value = txtFullName.InnerText;
            txtGender.InnerText = dr["gender"].ToString();
            txtCountry.InnerText = dr["country"].ToString();
            txtAddress.InnerText = dr["address"].ToString();
            txtZipcCode.InnerText = dr["zipcode"].ToString();
            txtCity.InnerText = dr["city"].ToString();
            txtEmailId.InnerText = dr["email"].ToString();
            txtTelephoneNo.InnerText = dr["telNo"].ToString();
            txtMobileNo.InnerText = dr["mobile"].ToString();
            txtNativeCountry.InnerText = dr["nativeCountry"].ToString();
            txtDateOfBirth.InnerText = dr["dob"].ToString();
            txtOccupation.InnerText = dr["occupation"].ToString();
            txtIssueDate.InnerText = dr["idIssueDate"].ToString();
            txtExpireDate.InnerText = dr["idExpiryDate"].ToString();
            txtIdType.InnerText = dr["idType"].ToString();
            txtIdNumber.InnerText = dr["idNumber"].ToString();
            txtVisaStatus.InnerText = dr["visaStatus"].ToString();
            txtEmployeeBusinessType.InnerText = dr["employeeBusinessType"].ToString();
            txtNameOfEmployer.InnerText = dr["nameOfEmployeer"].ToString();
            txtSSnNo.InnerText = dr["SSNNO"].ToString();
            txtMonthlyIncome.InnerText = dr["monthlyIncome"].ToString();
            txtRemittanceAllowed.InnerText = dr["remittanceAllowed"].ToString();
            txtOnlineLoginAllowed.InnerText = dr["onlineUser"].ToString();
            txtRemarks.InnerText = dr["remarks"].ToString();
            txtSourceOfFund.InnerText = dr["sourceOfFund"].ToString();


            var documentDetails = _cd.GetDocumentByCustomerId(dr["customerId"].ToString());
            StringBuilder imageHtml = new StringBuilder();
            if (documentDetails != null)
            {
                foreach (DataRow item in documentDetails.Rows)
                {
                    string imageUrl = "";
                    string docName = "";

                    if (item["documentType"].ToString() == "0")
                    {
                        docName = "Signature";
                        imageUrl = "/Handler/CustomerSignature.ashx?registerDate=" + Convert.ToDateTime(registerDate).ToString("yyyy-MM-dd") + "&customerId=" + hdnCustomerId.Value + "&membershipNo=" + TxtMembershipId.InnerText;
                    }
                    else
                    {
                        docName = item["documentName"].ToString();
                        imageUrl = "/AgentNew/GetFileView.ashx?imageName=" + item["fileName"] + "&customerId=" + TxtMembershipId.InnerText + "&fileType=" + item["fileType"];
                    }

                    imageHtml.Append("<div class=\"col-md-3\"><div class=\"form-group\"><div class=\"col-md-12\">");
                    imageHtml.Append("<label>" + docName + "</label>");
                    imageHtml.Append("</div>");
                    imageHtml.Append("<div class=\"col-md-12\">");
                    imageHtml.Append("<img src=\"" + imageUrl + "\" height=\"150\" width=\"200\"  onclick=\'showImage(this);\'/>");
                    imageHtml.Append("</div>");
                    imageHtml.Append("</div>");
                    imageHtml.Append("</div>");
                }
                docDiv.InnerHtml = imageHtml.ToString();

            }
        }
        private string GetMembershipId()
        {
            return GetStatic.ReadQueryString("membershipId", "");
        }
    }
}