using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web;

namespace Swift.web.Remit.Customer_Refund
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "CustomerRefund";
        private const string ViewFunctionId = "20195000";
        private const string AddEditFunctionId = "20195020";
        private const string DeleteFunctionId = "20195030";
        private const string ApproveFunctionId = "20195040";
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();
        private string customerId = "";
        private bool flagClearList = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                MakeNumericTextbox();
                customerDetailDiv.Visible = false;
                GetRequiredField();
                PopulateDdl();
            }
            sl.CheckSession();
        }

        public void PopulateDdl()
        {
            _sdd.SetDDL(ref ddlCustomerType, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
            _sdd.SetDDL(ref depositedBankDDL, "exec proc_sendPageLoadData @flag='paymentBy'", "VALUE", "TEXT", "", "");
        }

        protected void searchButton_Click(object sender, EventArgs e)
        {
            SetCustomerID();
            SetCustomerDetail();
        }

        private void SetCustomerID()
        {
            customerId = HiddenCustomerId.Value.ToString();
        }

        private void SetCustomerDetail()
        {
            if (flagClearList == false)
            {
                if (customerId == "")
                {
                    GetStatic.AlertMessage(this, "Please select customer first");
                    return;
                }
            }
            var dr = _cd.GetCustomerDataForRefund(GetStatic.GetUser(), customerId);
            if (dr == null)
            {
                GetStatic.AlertMessage(this, "Data Not Found!");
                return;
            }
            else
            {
                lblName.InnerText = dr["fullName"].ToString();
                lblAddress.InnerText = dr["address"].ToString();
                lblNativeCountry.InnerText = dr["nativeCountry"].ToString();
                lblMobile.InnerText = dr["mobile"].ToString();
                availableBalance.InnerText = GetStatic.ShowDecimal(dr["AvailableBalance"].ToString());
                //var a = dr["idTypeName"].ToString();
                //var b = dr["idTypeName"].ToString();
                lblIdType.InnerText = dr["idType"].ToString();
                lblIdNo.InnerText = dr["idNumber"].ToString();
                customerDetailDiv.Visible = true;
            }
        }

        private void MakeNumericTextbox()
        {
            Misc.MakeNumericTextbox(ref refundAmount);
            Misc.MakeNumericTextbox(ref additionalCharge);
        }

        protected void Refund_Click(object sender, EventArgs e)
        {
            var collMode = Request.Form["chkCollMode"];
            var selectedBankId = depositedBankDDL.SelectedValue;
            if (refundAmount.Text == "")
            {
                GetStatic.AlertMessage(this, "Please enter refund amount");
                return;
            }
            else if (additionalCharge.Text == "")
            {
                GetStatic.AlertMessage(this, "Please enter additional charge amount");
                return;
            }

            customerId = HiddenCustomerId.Value.ToString();
            var refAmount = refundAmount.Text;
            var refundRemarks = refunRemarks.Text;
            var addCharge = additionalCharge.Text;
            var addRearks = additionalChargeRemarks.Text;
            DbResult res = _cd.SaveCustomerRefundData(GetStatic.GetUser(), customerId, refAmount, refundRemarks, addCharge, addRearks, collMode, selectedBankId);
            if (res.ErrorCode == "0")
            {
                HttpContext.Current.Session["message"] = res;
                Response.Redirect("/Remit/CustomerRefund/List.aspx");
                //GetStatic.AlertMessage(this, res.Msg);
            }
            else
            {
                HttpContext.Current.Session["message"] = res;
                GetStatic.AlertMessage(this, res.Msg);
            }
        }

        private void ManageCollMode(DataTable dt)
        {
            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dt.Rows)
            {
                string checkedOrNot = item["ISDEFAULT"].ToString() == "1" ? "checked=\"checked\"" : "";
                sb.AppendLine("<input " + checkedOrNot + " type=\"checkbox\" id=\"" + item["COLLMODE"] + "\" name=\"chkCollMode\" value=\"" + item["detailTitle"] + "\" class=\"collMode-chk\">&nbsp;<label for=\"" + item["COLLMODE"] + "\">" + item["detailTitle"] + "</label>&nbsp;&nbsp;&nbsp;");
            }
            sb.AppendLine("<span style='background-color: yellow; font-weight: 600;padding: 5px; display:none;' id='availableBalSpan'> Available Balance: <label id=\"availableBal\" style=\"font-size: 14px;font-weight: 800;\"></label>&nbsp;JPY</span>");
            collModeTd.InnerHtml = sb.ToString();
        }

        private void GetRequiredField()
        {
            var ds = _cd.GetRequiredField(GetStatic.GetCountryId(), GetStatic.GetAgent(), GetStatic.GetUser());
            if (ds == null)
                return;
            ManageCollMode(ds.Tables[0]);
        }
    }
}