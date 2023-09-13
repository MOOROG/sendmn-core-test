using Newtonsoft.Json;
using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.Script.Serialization;

namespace Swift.web.KJBank.CustomerNameChecking
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20134200";
        private RemittanceLibrary _rl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _dao = new OnlineCustomerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
        }

        private void Authenticate()
        {
            _rl.CheckSession();

            if (!IsPostBack)
            {
                PopulateDDL();
            }
        }

        public void PopulateDDL()
        {
            _rl.SetDDL(ref ddlGender, "EXEC proc_online_dropDownList @flag='GenderList'", "valueId", "detailTitle", "", "Select..");  //Gender
            _rl.SetDDL(ref ddlIdType, "EXEC proc_online_dropDownList  @flag='idType'", "valueId", "detailTitle", "", "Select.."); //Id Type
            _rl.SetDDL(ref ddlBankName, "EXEC proc_dropDownList @flag='banklist'", "bankCode", "text", "", "Select.."); // Bank Name
            _rl.SetDDL(ref ddlCountry, "EXEC proc_online_dropDownList @flag='allCountrylist'", "countryId", "countryName", "", "Select.."); ; //Country Name
        }

        protected void btnViewDetail_Click(object sender, EventArgs e)
        {
            DataRow dr = null;
            string sBy = searchBy.Text;
            string sValue = searchValue.Text;
            try
            {
                if (!string.IsNullOrWhiteSpace(sValue))
                {
                    dr = _dao.GetCustomerDetailForVerification(sBy, GetStatic.GetUser(), sValue);
                }
                else
                {
                    hiddenSearch.Visible = false;
                    hiddenError.Visible = true;
                    errorMsg.InnerText = "Searchvalue field can not be empty!!";
                    return;
                }

                if (dr != null)
                {
                    if (dr["code"].ToString() == "0")
                    {
                        hiddenSearch.Visible = true;
                        hiddenError.Visible = false;

                        customerName.Text = dr["name"].ToString();
                        mobile.Text = dr["mobile"].ToString();
                        ddlGender.SelectedValue = dr["gender"].ToString();
                        ddlIdType.SelectedValue = dr["idType"].ToString();
                        idNumber.Text = dr["idNumber"].ToString();
                        dob.Text = dr["dob"].ToString();

                        ddlBankName.SelectedValue = dr["bankCode"].ToString();
                        accountNumber.Text = dr["accountNo"].ToString();
                        ddlCountry.SelectedValue = dr["country"].ToString();

                        hddbankCode.Value = dr["bankCode"].ToString();
                        hddobpId.Value = dr["obpId"].ToString();
                        hddwallletNo.Value = dr["wallletNo"].ToString();
                    }
                    else
                    {
                        hiddenSearch.Visible = false;
                        hiddenError.Visible = true;
                        errorMsg.InnerText = "Sorry No Record Found!!";
                    }
                }
                else
                {
                    hiddenSearch.Visible = false;
                    hiddenError.Visible = true;
                    errorMsg.InnerText = "No record found from database for searched value!!";
                }
            }
            catch (Exception ex)
            {
                hiddenSearch.Visible = false;
                hiddenError.Visible = true;
                errorMsg.InnerText = ex.Message.ToString();
            }
        }

        protected void btnVerification_Click(object sender, EventArgs e)
        {
            try
            {
                var request = new RealNameRequest();
                request.institution = ddlBankName.Text;
                request.no = accountNumber.Text;

                var IdNo = idNumber.Text.Replace("-", "");

                //주민번호
                if (ddlIdType.Text == "8008")
                {
                    request.realNameDivision = "01";
                    request.realNameNo = IdNo;
                }
                //외국인등록번호
                else if (ddlIdType.Text == "1302")
                {
                    request.realNameDivision = "02";
                    request.realNameNo = IdNo;
                }
                //여권번호는 조합주민번호로 변경
                else if (ddlIdType.Text == "10997")
                {
                    var gender = (ddlGender.Text == "97" ? "7" : "8");
                    var country = "";
                    switch (ddlCountry.Text)
                    {
                        case "238":
                            country = "1";
                            break;

                        case "113":
                            country = "2";
                            break;

                        case "45":
                            country = "3";
                            break;

                        default:
                            country = "4";
                            break;
                    }
                    request.realNameDivision = "04";
                    var DateB = dob.Text.Split('/');
                    request.realNameNo = String.Format("{0}{1}{2}{3}",
                                                        DateB[2].Substring(2) + DateB[0] + DateB[1],
                                                        gender,
                                                        country,
                                                        IdNo.Substring(IdNo.Length - 5));
                }

                string requestBody = JsonConvert.SerializeObject(request);
                var response = KJBankAPIConnection.GetRealNameCheck(requestBody);
                if (response.ErrorCode == "0")
                {
                    response.Msg = response.Msg.Split(':')[1];
                    response.Msg = response.Msg.Replace("}", "");
                    response.Msg = response.Msg.Trim();

                    if (!string.IsNullOrWhiteSpace(response.Msg))
                    {
                        GetStatic.AlertMessage(Page, "Success - Customer Account Name: " + response.Msg);
                    }
                }
                else
                {
                    GetStatic.AlertMessage(Page, "Fail - Validation failed");
                }
            }
            catch (Exception ex)
            {
                GetStatic.AlertMessage(Page, "Fail - Validation failed");
            }
        }

        //private void ManageSaved() {
        //    try
        //    {
        //        var requestObj = new PartnerServiceAccountRequest()
        //        {
        //            processDivision = "02",
        //            institution = hddbankCode.Value,
        //            depositor = ddlBankName.SelectedItem.Text,
        //            no = accountNumber.Text,
        //            virtualAccountNo = hddwallletNo.Value,
        //            obpId = hddobpId.Value
        //        };

        // /*
        // * @Max 추가
        // * */ var idNum = idNumber.Text.Replace("-", "");

        // //주민번호 if (ddlIdType.SelectedValue == "8008") { requestObj.realNameDivision = "01";
        // requestObj.realNameNo = idNum; } //외국인등록번호 else if (ddlIdType.SelectedValue == "1302") {
        // requestObj.realNameDivision = "02"; requestObj.realNameNo = idNum; } //여권번호는 조합주민번호로 변경
        // else if (ddlIdType.SelectedValue == "10997") { requestObj.realNameDivision = "04";

        // //조합주민번호(생년월일-성별-국적-여권번호(마지막5자리)) requestObj.realNameNo = String.Format("{0}{1}{2}{3}",
        // dob.Text, ddlGender.SelectedValue, ddlCountry.SelectedValue, idNum.Substring(idNum.Length
        // - 5)); }

        // requestObj.depositor = acNameInBank.Text;

        // DbResult dbResult = SendNotificationToKjBank(requestObj); if (dbResult == null) {
        // GetStatic.AlertMessage(Page, "Internal Error : Database result is null");

        //        }
        //        else if (!string.IsNullOrWhiteSpace(dbResult.Id))
        //        {
        //            ManageSaved();
        //            GetStatic.AlertMessage(Page, "Customer Detail updated");
        //        }
        //        else
        //        {
        //            GetStatic.AlertMessage(Page, "Customer detail not pushed to KJ Bank, please contact HO!");
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        GetStatic.AlertMessage(Page, ex.Message);
        //    }
        //}
        private DbResult SendNotificationToKjBank(PartnerServiceAccountRequest obj)
        {
            string body = new JavaScriptSerializer().Serialize((obj));
            var resp = KJBankAPIConnection.CustomerRegistration(body);

            return resp;
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            Hide();
        }

        public void Hide()
        {
            hiddenSearch.Visible = false;
            hiddenError.Visible = false;
        }
    }
}