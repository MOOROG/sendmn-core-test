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

namespace Swift.web.AgentNew.Customer
{
    public partial class CustomerDetails : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20302100";
        private readonly SwiftLibrary _swiftLib = new SwiftLibrary();

        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            _swiftLib.CheckSession();
            if (!IsPostBack)
            {
                PopulateDDL();
                Authenticate();
                GetStatic.PrintMessage(Page);
                GetStatic.CallBackJs1(Page, "Hide Div", "HideDiv()");
            }
        }
        private void Authenticate()
        {
            _swiftLib.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDDL()
        {
            var user = GetStatic.GetUser();
            _sdd.SetDDL(ref ddlSearchBy, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
        }
        protected void clickBtnForGetCustomerDetails_Click(object sender, EventArgs e)
        {
            PopulateCustomerData();
        }

        private void PopulateCustomerData()
        {
            DataSet ds = _cd.GetCustomerInfo(GetStatic.GetUser(), GetCustomerId());
            if (ds != null)
            {
                var customerDetails = ds.Tables[0];
                var receiveDetils = ds.Tables[1];
                var documentDetails = ds.Tables[2];
                var kycDetails = ds.Tables[3];
                var tranDetails = ds.Tables[4];
                var modifyDetails = ds.Tables[5];
                if (customerDetails.Rows.Count > 0)
                {
                    PopulateCustomerInfo(customerDetails);
                }
                if (receiveDetils.Rows.Count > 0)
                {
                    PopulateRecInfo(receiveDetils);
                }
                else
                {
                    recDetails.InnerHtml = "";
                }
                if (kycDetails.Rows.Count > 0)
                {
                    PopulateKycDetails(kycDetails);
                }
                else
                {
                    kycDetail.InnerHtml = "";
                }
                if (documentDetails.Rows.Count > 0)
                {
                    PopulateDocumentDetails(documentDetails);
                }
                else
                {
                    docdetails.InnerHtml = "";
                }
                if (tranDetails.Rows.Count > 0)
                {
                    PopulateTranDetails(tranDetails);
                }
                else
                {
                    txnDetails.InnerHtml = "";
                }
                if (modifyDetails.Rows.Count > 0)
                {
                    PopulateModifyDetails(modifyDetails);
                }
                else
                {
                    modDetails.InnerHtml = "";
                }
            }
        }

        private void PopulateKycDetails(DataTable kycDetails)
        {
            var str = new StringBuilder("");
            var sn = 1;
            foreach (DataRow dr in kycDetails.Rows)
            {

                str.Append("<tr>");
                str.Append("<td>" + sn + "</td>");
                str.Append("<td>" + dr["method"].ToString() + "</td>");
                str.Append("<td>" + dr["status"].ToString() + "</td>");
                str.Append("<td>" + dr["remarks"].ToString() + "</td>");
                str.Append("</tr>");
                sn++;
            }
            kycDetail.InnerHtml = str.ToString();
        }

        private void PopulateModifyDetails(DataTable modifyDetails)
        {
            var str = new StringBuilder("");
            var sn = 1;
            foreach (DataRow dr in modifyDetails.Rows)
            {

                str.Append("<tr>");
                str.Append("<td>" + sn + "</td>");
                str.Append("<td>" + dr["columnName"].ToString() + "</td>");
                str.Append("<td>" + dr["oldValue"].ToString() + "</td>");
                str.Append("<td>" + dr["newValue"].ToString() + "</td>");
                str.Append("<td>" + dr["modifiedBy"].ToString() + "</td>");
                str.Append("<td>" + dr["modifiedDate"].ToString() + "</td>");
                str.Append("</tr>");
                sn++;
            }
            modDetails.InnerHtml = str.ToString();
        }

        private void PopulateTranDetails(DataTable tranDetails)
        {
            var str = new StringBuilder("");
            var sn = 1;
            foreach (DataRow dr in tranDetails.Rows)
            {

                str.Append("<tr>");
                str.Append("<td>" + sn + "</td>");
                str.Append("<td>" + dr["createdDate"].ToString() + "</td>");
                str.Append("<td>" + dr["receiverName"].ToString() + "</td>");
                str.Append("<td>" + dr["jmeNo"].ToString() + "</td>");
                str.Append("<td>" + dr["serviceCharge"].ToString() + "</td>");
                str.Append("<td>" + dr["pAmt"].ToString() + "</td>");
                str.Append("<td>" + dr["tranStatus"].ToString() + "</td>");
                str.Append("<td>" + dr["payStatus"].ToString() + "</td>");
                str.Append("<td>" + dr["pCountry"].ToString() + "</td>");

                str.Append("</tr>");
                sn++;
            }
            txnDetails.InnerHtml = str.ToString();
        }

        private void PopulateDocumentDetails(DataTable documentDetails)
        {
            var str = new StringBuilder("");
            var sn = 1;
            foreach (DataRow dr in documentDetails.Rows)
            {

                str.Append("<tr>");
                str.Append("<td>" + sn + "</td>");
                str.Append("<td>" + dr["documentType"].ToString() + "</td>");
                str.Append("<td>" + dr["fileType"].ToString() + "</td>");
                str.Append("<td>" + dr["fileName"].ToString() + "</td>");
                str.Append("</tr>");
                sn++;
            }
            docdetails.InnerHtml = str.ToString();
        }

        private void PopulateRecInfo(DataTable receiveDetils)
        {
            var str = new StringBuilder("");
            var sn = 1;
            foreach (DataRow dr in receiveDetils.Rows)
            {

                str.Append("<tr>");
                str.Append("<td>" + sn + "</td>");
                str.Append("<td>" + dr["fullname"].ToString() + "</td>");
                str.Append("<td>" + dr["address"].ToString() + "</td>");
                str.Append("<td>" + dr["mobile"].ToString() + "</td>");
                str.Append("<td>" + dr["country"].ToString() + "</td>");
                str.Append("</tr>");
                sn++;
            }
            recDetails.InnerHtml = str.ToString();

        }

        private void PopulateCustomerInfo(DataTable customerDetails)
        {
            custName.Text = customerDetails.Rows[0]["fullName"].ToString();
            custCountry.Text = customerDetails.Rows[0]["countryName"].ToString();
            custState.Text = customerDetails.Rows[0]["stateName"].ToString();
            custCity.Text = customerDetails.Rows[0]["city"].ToString();
            custEmail.Text = customerDetails.Rows[0]["email"].ToString();
            custMobile.Text = customerDetails.Rows[0]["mobile"].ToString();
            memId.Text = customerDetails.Rows[0]["membershipId"].ToString();
            custDob.Text = customerDetails.Rows[0]["dob"].ToString();
            custOccupation.Text = customerDetails.Rows[0]["occupation"].ToString();
            custGender.Text = customerDetails.Rows[0]["gender"].ToString();
            idType.Text = customerDetails.Rows[0]["idType"].ToString();
            idNumber.Text = customerDetails.Rows[0]["idNumber"].ToString();
            idExpiryDate.Text = customerDetails.Rows[0]["idExpiryDate"].ToString();
            placeOfIssue.Text = customerDetails.Rows[0]["placeOfIssue"].ToString();
            additionalAddress.Text = customerDetails.Rows[0]["additionalAddress"].ToString();
            walletNo.Text = customerDetails.Rows[0]["walletAccountNo"].ToString();
            zipcode.Text = customerDetails.Rows[0]["zipcode"].ToString();
            createdBy.Text = customerDetails.Rows[0]["createdBy"].ToString();
            createdDate.Text = customerDetails.Rows[0]["createdDate"].ToString();

        }

        protected string GetCustomerId()
        {
            string customerId = hdnCustomerId.Value;
            return customerId;
        }

    }
}