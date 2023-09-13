using Newtonsoft.Json;
using Swift.DAL.BL.AgentPanel.Send;
using Swift.DAL.Domain;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.AgentSend
{
    public partial class SendV2 : System.Web.UI.Page
    {
        private SendTranIRHDao st = new SendTranIRHDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "40101600";
        private const string EnableCustomerSignature = "40101610";

        protected void Page_Load(object sender, EventArgs e)
        {
            EnableDigitalSignature.Visible = _sdd.HasRight(EnableCustomerSignature);
            isDisplaySignature.Value = Convert.ToString(_sdd.HasRight(EnableCustomerSignature));
            lblServiceChargeCurr.Attributes.Add("readonly", "readonly");
            lblServiceChargeAmt.Attributes.Add("readonly", "readonly");
            _sdd.CheckSession();
            GetStatic.PrintMessage(Page);
            txtCollAmt.Attributes.Add("onkeyup", "return CalcOnEnter((event?event:evt));");
            string reqMethod = Request.Form["MethodName"];
            if (!string.IsNullOrEmpty(reqMethod))
            {
                if (GetStatic.GetUser() == "")
                {
                    Response.ContentType = "text/plain";
                    Response.Write("[{\"session_end\":\"1\"}]");
                    Response.End();
                    return;
                }
            }
            Authenticate();
            if (String.IsNullOrEmpty(reqMethod))
            {
                GetCurrentBalance();
                Misc.MakeNumericTextbox(ref txtPayAmt);
            }

            if (!Page.IsPostBack)
            {
                #region Ajax methods

                switch (reqMethod)
                {
                    case "SearchCustomer":
                        CustomerSearchLoadData();
                        break;

                    case "getPayoutPartner":
                        GetPayoutPartner();
                        break;

                    case "SearchReceiver":
                        SearchReceiverDetails();
                        break;

                    case "PopulateReceiverDDL":
                        PopulateReceiverDDL();
                        break;

                    case "getLocation":
                        GetLocationData();
                        break;

                    case "getSubLocation":
                        GetSubLocationData();
                        break;

                    case "getTownLocation":
                        GetTownLocation();
                        break;

                    case "SearchRateScData":
                        SearchRateScData();
                        break;

                    case "PaymentModePcountry":
                        LoadDataFromDdl("pMode");
                        break;

                    case "PCurrPcountry":
                        PCurrPcountry();
                        break;

                    case "CalculateTxn":
                        Calculate();
                        break;

                    case "ReceiverDetailBySender":
                        PopulateReceiverBySender();
                        break;

                    case "loadAgentBank":
                        LoadDataFromDdl("agentByPmode");
                        break;

                    case "PAgentChange":
                        GetAgentSetting();
                        break;

                    case "PBranchChange":
                        LoadAgentByExtBranch();
                        break;

                    case "LoadAgentByExtAgent":
                        LoadAgentByExtAgent();
                        break;

                    case "LoadSchemeByRcountry":
                        LoadSchemeByRCountry();
                        break;

                    case "LoadCustomerRate":
                        LoadCustomerRate();
                        break;

                    case "CheckSenderIdNumber":
                        CheckSenderIdNumber();
                        break;

                    case "CheckAvialableBalance":
                        CheckAvialableBalance();
                        break;

                    case "getPayerDataByBankId":
                        GetPayerDataByBankId();
                        break;

                    case "getAvailableBalance":
                        GetCurrentBalance();
                        break;

                    case "getPayerBranchDataByPayerAndCityId":
                        GetPayerDataByPayerAndCityId();
                        break;

                    case "Verifytxn":
                        VerifyTransaction();
                        break;
                }

                #endregion Ajax methods

                PopulateDdl();
                ManageCollMode();
                DisplayAvailableBalance();
            }
        }

        private void VerifyTransaction()
        {
            List<string> stringList = new List<string>();
            var type = Request.Form["type"];
            var trn = GetDataForValidation();
            if (type == "V")
            {
                var ds = st.ValidateTransaction(trn);
                if (ds == null)
                {
                    Response.Write("");
                    Response.End();
                    return;
                }
                Response.ContentType = "text/plain";
                var tableList = ds.Tables;
                var resultTable = tableList[0];
                var ErrorCode = resultTable.Columns.Contains("ErrCode") ? resultTable.Rows[0]["ErrCode"].ToString() : resultTable.Rows[0]["ErrorCode"].ToString();
                stringList.Add(ErrorCode + "," + resultTable.Rows[0]["msg"] + "," + resultTable.Rows[0]["id"]);
                if (ErrorCode != "0")
                {
                    string ofacError = "";
                    string complainError = "";
                    if (ErrorCode == "1")
                    {
                        string result = resultTable.Rows[0]["ErrCode"] + "," + resultTable.Rows[0]["msg"] + "," + resultTable.Rows[0]["id"];
                        stringList.Add(result);
                    }
                    if (ErrorCode == "100")
                    {
                        if (ds.Tables[1].Rows.Count > 0)
                        {
                            ofacError = LoadOfacList(ds.Tables[1], trn);
                        }
                        if (tableList.Count > 2)
                            if (tableList[2].Rows.Count > 0)
                                complainError = LoadComplianceListNew(tableList[2]);
                    }
                    if (ErrorCode == "101")
                    {
                        if (ds.Tables[1].Rows.Count > 0)
                        {
                            complainError = LoadComplianceListNew(tableList[1]);
                        }
                    }
                    if (ErrorCode == "102")
                    {
                        if (ds.Tables[1].Rows.Count > 0)
                        {
                            complainError = LoadComplianceListNew(tableList[1]);
                        }
                    }
                    stringList.Add(ofacError);
                    stringList.Add(complainError);
                }
                var json = JsonConvert.SerializeObject(stringList);
                Response.Write(json);
                Response.End();
            }
            else
            {
                trn.IsFromTabPage = "1";
                var db = st.SendTransactionIRH(trn);
                string customerSignature = Request.Form["customerSignature"];
                if (!string.IsNullOrEmpty(customerSignature) && (db.ErrorCode == "0" || db.ErrorCode == "100" || db.ErrorCode == "101"))
                {
                    UploadImage(customerSignature, db.Id);
                }
                string result = db.ErrorCode + "," + db.Msg + "," + db.Id + "," + db.Extra + "," + db.Extra2;
                stringList.Add(result);
                var json = JsonConvert.SerializeObject(stringList);
                Response.ContentType = "text/plain";
                Response.Write(json);
                Response.End();
            }
        }

        private string LoadOfacList(DataTable dt, IRHTranDetail trn)
        {
            var confirmText = "Confirmation:\n_____________________________________";
            confirmText += "\n\nYou are confirming to send this OFAC suspicious transaction!!!";
            confirmText += "\n\nPlease note if this customer is found to be valid person from OFAC List then Teller will be charged fine from management";
            confirmText += "\n\n\nPlease make sure you have proper evidence that show this customer is not from OFAC List";
            //btnProceedCc.ConfirmText = confirmText;
            int cols = dt.Columns.Count;
            var str = new StringBuilder("<table class='TBLData' border=\"1\" cellspacing=0 cellpadding=\"3\">");
            str.Append("<tr>");
            for (int i = 0; i < cols; i++)
            {
                str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
            }
            str.Append("</tr>");
            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                str.Append("<td align=\"left\">" + dr[0] + "</td>");

                string[] strArr = {
                                        trn.SenFirstName.ToUpper(), trn.SenMiddleName.ToUpper(), trn.SenLastName.ToUpper(),
                                        trn.RecFirstName.ToUpper(), trn.RecMiddleName.ToUpper(),trn.RecLastName.ToUpper(),
                                    };
                var arrlen = strArr.Length;
                string value = dr[1].ToString();
                for (int j = 0; j < arrlen; j++)
                {
                    if (!string.IsNullOrWhiteSpace(strArr[j]))
                    {
                        value = value.ToUpper().Replace(strArr[j],
                                                        GetStatic.PutRedBackGround(strArr[j]));
                    }
                }
                str.Append("<td align=\"left\">" + value + "</td>");
                str.Append("</tr>");
            }
            str.Append("<tr>");
            str.Append("<td colspan=\"2\">OFAC Listed Customer are BLACK Listed customer or Suspicious for terrorist or Money Loundery Customer" +
                        ", please ask for valid documentation from customer</td>");
            str.Append("</tr>");
            str.Append("</table>");
            return str.ToString();
        }

        private string LoadComplianceListNew(DataTable dt)
        {
            int cols = dt.Columns.Count;
            var str =
                new StringBuilder("<table class='table table-responsive table-striped table-bordered'>");
            str.Append("<tr>");
            for (int i = 2; i < cols; i++)
            {
                str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
            }
            str.Append("</tr>");
            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                str.Append("<td>" + dr["S.N."].ToString() + "</td>");
                str.Append("<td align=\"left\"><a href=\"#\" onclick=\"OpenInNewWindow('/Remit/OFACManagement/ComplianceDetail.aspx?id=" +
                            dr["Id"].ToString() + "&type=compNew')\">" + dr["Remarks"].ToString() + "</a></td>");
                str.Append("<td align='center' class='bg-danger'></strong>" + dr["Action"].ToString() + "</strong></td>");
                str.Append("</tr>");
            }
            str.Append("</table>");
            return str.ToString();
        }

        private IRHTranDetail GetDataForValidation()
        {
            #region Get Sender Details

            string _senderId = Request.Form["senderId"];
            string _senfName = Request.Form["sfName"];
            string _senmName = Request.Form["smName"];
            string _senlName = Request.Form["slName"];
            //string _senlName2       = Request.Form["sIdType"];
            string _senIdType = Request.Form["sIdType"];
            string _senIdNo = Request.Form["sIdNo"];
            string _senIdValid = Request.Form["sIdValid"];
            string _senGender = Request.Form["sGender"];
            string _sendob = Request.Form["sdob"];
            string _senTel = Request.Form["sTel"];
            string _senMobile = Request.Form["sMobile"];
            string _senNaCountry = Request.Form["sNaCountry"];
            string _sencity = Request.Form["sCity"];
            string _senPostCode = Request.Form["sPostCode"];
            string _senAdd1 = Request.Form["sAdd1"];
            string _senAdd2 = Request.Form["sAdd2"];
            string _senEmail = Request.Form["sEmail"];
            string _smsSend = Request.Form["smsSend"];
            string _memberCode = Request.Form["memberCode"];
            string _senCompany = Request.Form["sCompany"];

            #endregion Get Sender Details

            #region Get RECEIVER Details

            string _benId = Request.Form["benId"];
            string _recfName = Request.Form["rfName"];
            string _recmName = Request.Form["rmName"];
            string _reclName = Request.Form["rlName"];
            //string _reclName2       = Request.Form["senderId"];
            string _recIdType = Request.Form["rIdType"];
            string _recIdNo = Request.Form["rIdNo"];
            string _recIdValid = Request.Form["rIdValid"];
            string _recGender = Request.Form["rGender"];
            string _recdob = Request.Form["rdob"];
            string _recTel = Request.Form["rTel"];
            string _recMobile = Request.Form["rMobile"];

            string _reccity = Request.Form["rCity"];

            string _recPostCode = Request.Form["rPostCode"];
            string _recAdd1 = Request.Form["rAdd1"];
            string _recAdd2 = Request.Form["rAdd2"];
            string _recEmail = Request.Form["rEmail"];
            string _recaccountNo = Request.Form["accountNo"];

            #endregion Get RECEIVER Details

            #region Get Transaction Details

            string _pCountryName = Request.Form["pCountry"];
            string _pCountryId = Request.Form["payCountryId"];
            string _dm = Request.Form["collMode"];
            string _dmId = Request.Form["collModeId"];
            string _pBank = Request.Form["pBank"];
            string _pBankName = Request.Form["pBankText"];
            string _pBankBranch = Request.Form["pBankBranch"];
            string _pBankBranchName = Request.Form["pBankBranchText"];
            string _pBankType = Request.Form["pBankType"];
            string _pAgent = Request.Form["pAgent"];
            string _pAgentName = Request.Form["pAgentName"];
            string _pCurr = Request.Form["pCurr"];
            string _collCurr = Request.Form["collCurr"];
            decimal _cAmt = Request.Form["collAmt"].ToDecimal();
            decimal _pAmt = Request.Form["payAmt"].ToDecimal();
            decimal _tAmt = Request.Form["sendAmt"].ToDecimal();
            decimal _customerTotalAmt = Request.Form["customerTotalAmt"].ToDecimal();
            decimal _serviceCharge = Request.Form["scharge"].ToDecimal();
            decimal _discount = Request.Form["discount"].ToDecimal();
            decimal _customerRate = Request.Form["exRate"].ToDecimal();
            string _schemeType = Request.Form["accountNo"];
            string schemeName = Request.Form["accountNo"];
            string scDiscount = Request.Form["scDiscount"];
            string exRateOffer = Request.Form["exRateOffer"];
            //string  _couponId         = Request.Form["accountNo"];

            string _pLocation = Request.Form["pLocation"];
            string _pLocationText = Request.Form["pLocationText"];
            string _pSubLocation = Request.Form["pSubLocation"];
            string _pSubLocationText = Request.Form["pSubLocationText"];
            string _payerId = Request.Form["payerId"];
            string _payerBranchId = Request.Form["payerBranchId"];
            //tpExRate

            #endregion Get Transaction Details

            string _por = Request.Form["por"];
            string _sof = Request.Form["sof"];
            string _rel = Request.Form["rel"];
            string _occupation = Request.Form["occupation"];
            string _payMsg = Request.Form["payMsg"];
            string _company = Request.Form["company"];
            string _nCust = Request.Form["newCustomer"];
            string _eCust = Request.Form["EnrollCustomer"];
            string _cancelrequestId = Request.Form["cancelrequestId"];
            string _pSuperAgent = Request.Form["accountNo"];
            string _salary = Request.Form["salary"];
            // _hdnreqAgent
            string _hdnreqBranch = Request.Form["hdnreqBranch"];

            string _isManualSC = Request.Form["isManualSC"];

            string _manualSC = Request.Form["manualSC"];
            string _sCustStreet = Request.Form["sCustStreet"];
            string _sCustLocation = Request.Form["sCustLocation"];
            string _sCustomerType = Request.Form["sCustomerType"];
            string _sCustBusinessType = Request.Form["sCustBusinessType"];
            string _sCustIdIssuedCountry = Request.Form["sCustIdIssuedCountry"];
            string _sCustIdIssuedDate = Request.Form["sCustIdIssuedDate"];
            string _receiverId = Request.Form["receiverId"];
            string _payoutPartnerId = Request.Form["payoutPartnerId"];
            string _cashCollMode = Request.Form["cashCollMode"];
            string _customerDepositedBank = Request.Form["customerDepositedBank"];
            string _introducerTxt = Request.Form["introducerTxt"];

            #region additional information for branch

            string _branchId = GetStatic.ReadQueryString("branchId", "");
            string _branchName = GetStatic.ReadQueryString("branchName", "");

            #endregion additional information for branch

            #region Confirm txn Details

            string _txnPwd = Request.Form["txnPwd"];

            #endregion Confirm txn Details

            var trn = new IRHTranDetail();
            var randObj = new Random();

            var agentRefId = randObj.Next(1000000000, 1999999999).ToString();
            hdnAgentRefId.Value = agentRefId;
            trn.AgentRefId = agentRefId;
            trn.User = GetStatic.GetUser();
            trn.SessionId = GetStatic.GetSessionId();
            trn.SenderId = _senderId.ToString();
            trn.SenFirstName = _senfName;
            trn.SenMiddleName = _senmName;
            trn.SenLastName = _senlName;
            //trn.SenLastName2 = _senlName2;
            trn.SenGender = _senGender;
            trn.SenIdType = _senIdType;
            trn.SenIdNo = _senIdNo;
            trn.SenIdValid = _senIdValid;
            trn.SenDob = _sendob;
            trn.SenEmail = _senEmail;
            trn.SenTel = _senTel;
            trn.SenMobile = _senMobile;
            trn.SenNaCountry = _senNaCountry;
            trn.SenCity = _sencity;
            trn.SenPostCode = _senPostCode;
            trn.SenAdd1 = _senAdd1;
            trn.SenAdd2 = _senAdd2;
            trn.SenEmail = _senEmail;
            trn.SmsSend = _smsSend;
            trn.ReceiverId = _benId.ToString();
            trn.RecFirstName = _recfName;
            trn.RecMiddleName = _recmName;
            trn.RecLastName = _reclName;
            //trn.RecLastName2 = _reclName2;
            trn.RecGender = _recGender;
            trn.RecIdType = _recIdType;
            trn.RecIdNo = _recIdNo;
            trn.RecIdValid = _recIdValid;
            trn.RecDob = _recdob;
            trn.RecTel = _recTel;
            trn.RecMobile = _recMobile;
            trn.RecNaCountry = "";
            trn.RecCity = _reccity;
            trn.RecPostCode = _recPostCode;
            trn.RecAdd1 = _recAdd1;
            trn.RecAdd2 = _recAdd2;
            trn.RecEmail = _recEmail;
            trn.RecAccountNo = _recaccountNo;
            trn.RecCountryId = _pCountryId.ToString();
            trn.RecCountry = _pCountryName;
            trn.DeliveryMethod = _dm;
            trn.DeliveryMethodId = _dmId.ToString();
            trn.PBank = _pBank;
            trn.PBankName = _pBankName;
            trn.PBankBranch = _pBankBranch;
            trn.PBankBranchName = _pBankBranchName;
            trn.PBankType = _pBankType;
            trn.PAgent = _pAgent;
            trn.PAgentName = _pAgentName;
            trn.PBankType = _pBankType;

            trn.PCurr = _pCurr;
            trn.CollCurr = _collCurr;
            trn.CollAmt = _cAmt.ToString();
            trn.PayoutAmt = _pAmt.ToString();
            trn.TransferAmt = _tAmt.ToString();
            trn.ServiceCharge = _serviceCharge.ToString();
            trn.Discount = _discount.ToString();
            trn.ExRate = _customerRate.ToString();
            trn.SchemeCode = _schemeType;
            //trn.CouponTranNo = _couponId;
            trn.PurposeOfRemittance = _por;
            trn.SourceOfFund = _sof;
            trn.RelWithSender = _rel;
            trn.Occupation = _occupation;
            trn.PayoutMsg = _payMsg;
            trn.Company = _company;
            trn.NCustomer = _nCust;
            trn.ECustomer = _eCust;
            trn.MemberCode = _memberCode;

            trn.SBranch = GetStatic.GetBranch();
            trn.SBranchName = GetStatic.GetBranchName();
            trn.SAgent = GetStatic.GetAgent();
            trn.SAgentName = GetStatic.GetAgentName();
            trn.SSuperAgent = GetStatic.GetSuperAgent();
            trn.SSuperAgentName = GetStatic.GetSuperAgentName();
            trn.SettlingAgent = GetStatic.GetSettlingAgent();
            trn.SCountry = GetStatic.GetCountry();
            trn.SCountryId = GetStatic.GetCountryId();
            trn.pStateId = _pLocation;
            trn.pStateName = _pLocationText;
            trn.pCityId = _pSubLocation;
            trn.pCityName = _pSubLocationText;
            //trn.CwPwd = cwPwd.Text;
            //trn.TtName = ttName.Text;

            trn.isManualSC = _isManualSC;
            trn.manualSC = _manualSC;
            trn.sCustStreet = _sCustStreet;
            trn.sCustLocation = _sCustLocation;
            trn.sCustomerType = _sCustomerType;
            trn.sCustBusinessType = _sCustBusinessType;
            trn.sCustIdIssuedCountry = _sCustIdIssuedCountry;
            trn.sCustIdIssuedDate = _sCustIdIssuedDate;
            trn.receiverId = _receiverId;
            trn.payoutPartner = _payoutPartnerId;
            trn.cashCollMode = _cashCollMode;
            trn.customerDepositedBank = _customerDepositedBank;
            trn.introducer = _introducerTxt;

            //trn.tpExRate = _tpExRate;
            trn.PayerId = _payerId;
            trn.PayerBranchId = _payerBranchId;
            trn.CustomerPassword = Request.Form["customerPassword"];
            //Confirm Details

            trn.TxnPassword = _txnPwd;
            //trn.CustomerPassword = Request.Form["customerPassword"];
            return trn;
        }

        protected string GetCustomerId()
        {
            return GetStatic.ReadQueryString("customerId", "");
        }

        private void GetPayoutPartner()
        {
            string pCountry = Request.Form["pCountry"];
            string pMode = Request.Form["pMode"];

            var dt = st.GetPayoutPartner(GetStatic.GetUser(), pCountry, pMode);
            if (dt == null)
            {
                Response.Write("");
                Response.End();
                return;
            }
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void SearchReceiverDetails()
        {
            string customerId = Request.Form["customerId"];

            var dt = st.LoadReceiverData(GetStatic.GetUser(), customerId);
            if (dt == null)
            {
                Response.Write("");
                Response.End();
                return;
            }
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void PopulateReceiverDDL()
        {
            string customerId = Request.Form["customerId"];

            var dt = st.PopulateReceiverDDL(GetStatic.GetUser(), customerId);
            if (dt == null)
            {
                Response.Write("");
                Response.End();
                return;
            }
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void GetSubLocationData()
        {
            string pLocation = Request.Form["PLocation"];
            DataTable dt = st.GetPayoutSubLocation(pLocation);

            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void GetTownLocation()
        {
            string subLocation = Request.Form["subLocation"];
            DataTable dt = st.GetPayoutTownLocation(subLocation);

            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void GetLocationData()
        {
            string pCountry = Request.Form["PCountry"];
            string pMode = Request.Form["PMode"];
            string partnerId = Request.Form["PartnerId"];
            DataTable dt = st.GetPayoutLocation(pCountry, pMode, partnerId);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        protected string sb = "";

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void ManageCollMode()
        {
            var dt = st.GetCollModeData(GetStatic.GetCountryId(), GetStatic.GetAgent());
            StringBuilder sb = new StringBuilder();
            foreach (DataRow item in dt.Rows)
            {
                string checkedOrNot = item["ISDEFAULT"].ToString() == "1" ? "checked=\"checked\"" : "";
                sb.AppendLine("<input " + checkedOrNot + " type=\"checkbox\" id=\"" + item["COLLMODE"] + "\" name=\"chkCollMode\" value=\"" + item["detailTitle"] + "\" class=\"collMode-chk\">&nbsp;<label for=\"" + item["COLLMODE"] + "\">" + item["detailTitle"] + "</label>&nbsp;&nbsp;");
            }
            sb.AppendLine("<span style='background-color: yellow; font-weight: 600;padding: 4px; display:none;' id='availableBalSpan'> Available Bal: <label id=\"availableBal\" style=\"font-size: 14px;font-weight: 800;\"></label>&nbsp;"+GetStatic.ReadWebConfig("currencyJP", "") +"</span>");
            collModeTd.InnerHtml = sb.ToString();
        }

        private void DisplayAvailableBalance()
        {
            var dr = st.GetAcDetailByBranchIdNew(GetStatic.GetUser(), GetStatic.GetAgent());
            string amountDetails = "";
            if (dr == null || dr.Rows.Count == 0)
            {
                amountDetails = "N/A";
            }
            else
            {
                amountDetails = GetStatic.FormatData(dr.Rows[0]["availableBal"].ToString(), "M") + " " + dr.Rows[0]["balCurrency"];
            }
            availableAmountDetails.InnerText = amountDetails;
        }

        private void LoadSchemeByRCountry()
        {
            string pCountryFv = Request.Form["pCountry"];
            string pAgentFv = Request.Form["pAgent"];
            string sCustomerId = Request.Form["sCustomerId"];

            var dt = st.LoadSchemeByRCountry(GetStatic.GetCountryId(), GetStatic.GetAgent(), GetStatic.GetBranch(), pCountryFv, pAgentFv, sCustomerId);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void GetCurrentBalance()
        {
            var result = st.GetAcDetailByBranchIdNew(GetStatic.GetUser(), GetStatic.GetAgent());
            if (result == null)
            {
                availableAmt.Text = "N/A";
                return;
            }
            DataRow dr = result.Rows[0];
            availableAmt.Text = GetStatic.FormatData(dr["availableBal"].ToString(), "M");
            //lblPerDayLimit.Text = GetStatic.FormatData(dr["txnPerDayCustomerLimit"].ToString(), "M");
            //lblPerDayCustomerCurr.Text = dr["sCurr"].ToString();
            lblCollCurr.Text = dr["balCurrency"].ToString();
            lblSendCurr.Text = dr["sCurr"].ToString();
            lblServiceChargeCurr.Text = dr["sCurr"].ToString();
            txnPerDayCustomerLimit.Value = dr["txnPerDayCustomerLimit"].ToString();
            balCurrency.Text = dr["balCurrency"].ToString();
            hdnLimitAmount.Value = dr["sCountryLimit"].ToString();
        }

        protected long GetResendId()
        {
            return GetStatic.ReadNumericDataFromQueryString("resendId");
        }

        private void LoadAgentByExtAgent()
        {
            var pAgentFv = Request.Form["pAgent"];
            var dt = st.LoadAgentByExtAgent(GetStatic.GetUser(), pAgentFv);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void LoadAgentByExtBranch()
        {
            var pBranchFv = Request.Form["pBranch"];
            var dt = st.LoadAgentByExtBranch(GetStatic.GetUser(), pBranchFv);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void GetAgentSetting()
        {
            var pAgentFv = Request.Form["pAgent"];
            var pModeFv = Request.Form["pMode"];
            var pCountryFv = GetStatic.ReadFormData("pCountry", "");
            var pBankType = GetStatic.ReadFormData("pBankType", "");
            var dt = st.GetAgentSetting(GetStatic.GetUser(), pCountryFv, pAgentFv, pModeFv, pBankType);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void LoadDataFromDdl(string type)
        {
            var pAgentFv = Request.Form["pAgent"];
            var pModeFv = Request.Form["pmode"];
            var pCountryFv = Request.Form["pCountry"];

            DataTable dt = null;
            switch (type)
            {
                case "pMode":
                    dt = st.LoadDataFromDdl(GetStatic.GetCountryId(), pCountryFv, pModeFv, GetStatic.GetAgent(), "recModeByCountry", GetStatic.GetUser());
                    break;

                case "agentByPmode":
                    if (string.IsNullOrWhiteSpace(pModeFv) || string.IsNullOrWhiteSpace(pCountryFv))
                    {
                        Response.Write(null);
                        Response.End();
                        return;
                    }
                    dt = st.LoadDataFromDdl(GetStatic.GetCountryId(), pCountryFv, pModeFv, GetStatic.GetAgent(), "recAgentByRecModeAjaxagent", GetStatic.GetUser());
                    break;

                case "LoadScheme":
                    dt = st.LoadDataFromDdl(GetStatic.GetCountryId(), pCountryFv, pModeFv, pAgentFv, "schemeBysCountryrAgent", GetStatic.GetUser());
                    break;
            }

            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void PopulateReceiverBySender()
        {
            string recId = Request.Form["id"];
            string senderId = Request.Form["senderId"];

            DataTable dt = st.PopulateReceiverBySender(senderId, "", recId);
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void PCurrPcountry()
        {
            string pCountry = Request.Form["pCountry"];
            string pMode = Request.Form["pMode"];
            string pAgent = Request.Form["pAgent"];

            DataTable Dt = st.LoadPayCurr(pCountry, pMode, pAgent);
            Response.ContentType = "text/plain";
            string json = DataTableToJson(Dt);
            Response.Write(json);
            Response.End();
        }

        private void PopulateDdl()
        {
            var natCountry = GetStatic.ReadWebConfig("localCountry", "");
            LoadSenderCountry(ref txtSendNativeCountry, natCountry, "SELECT COUNTRY");
            LoadReceiverCountry(ref pCountry, "", "SELECT");
            _sdd.SetDDL(ref ddSenIdType, "exec proc_sendPageLoadData @flag='idTypeBySCountry',@countryId='" + GetStatic.GetCountryId() + "'", "valueId", "detailTitle", "", "SELECT");
            _sdd.SetDDL(ref ddlCustomerType, "exec proc_sendPageLoadData @flag='search-cust-by'", "VALUE", "TEXT", "", "");
            _sdd.SetDDL(ref ddlSendCustomerType, "EXEC proc_online_dropDownList @flag='dropdownList',@parentId=4700", "valueId", "detailTitle", "", "SELECT CUSTOMER TYPE");
            _sdd.SetDDL(ref ddlIdIssuedCountry, "EXEC proc_sendPageLoadData @flag='idIssuedCountry'", "countryId", "countryName", "", "SELECT COUNTRY");
            _sdd.SetDDL(ref ddlEmpBusinessType, "EXEC proc_online_dropDownList @flag='dropdownList',@parentId=7002", "valueId", "detailTitle", "11007", "");
            _sdd.SetDDL(ref custLocationDDL, "EXEC proc_online_dropDownList @flag='state',@countryId='113'", "stateId", "stateName", "", "SELECT");
            _sdd.SetDDL(ref ddlRecIdType, "EXEC proc_online_dropDownList @flag='idType',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
            _sdd.SetDDL(ref sourceOfFund, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=3900", "valueId", "detailTitle", "", "Select..");
            _sdd.SetDDL(ref purpose, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=3800", "valueId", "detailTitle", "8060", "Select..");
            _sdd.SetDDL(ref relationship, "EXEC proc_online_dropDownList @flag='dropdownList',@user='" + GetStatic.GetUser() + "',@parentId=2100", "valueId", "detailTitle", "", "Select..");
            _sdd.SetDDL(ref occupation, "EXEC proc_online_dropDownList @flag='occupationList',@user='" + GetStatic.GetUser() + "'", "valueId", "detailTitle", "", "Select..");
        }

        private void LoadSenderCountry(ref DropDownList ddl, string defaultValue, string label)
        {
            var sql = "EXEC proc_dropDownLists @flag='country'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, label);
        }

        private void LoadReceiverCountry(ref DropDownList ddl, string defaultValue, string label)
        {
            var sql = "EXEC proc_sendPageLoadData @flag='pCountry',@countryId='" + GetStatic.GetCountryId() + "',@agentid='" + GetStatic.GetAgentId() + "'";
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", defaultValue, label);
        }

        private void CustomerSearchLoadData()
        {
            string customerId = Request.Form["customerId"];
            var dt = st.LoadCustomerDataNew(GetStatic.GetUser(), customerId, "s-new", GetStatic.GetCountryId(), GetStatic.GetSettlingAgent());
            if (dt == null)
            {
                Response.Write("");
                Response.End();
                return;
            }
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void SearchRateScData()
        {
            string serchType = Request.Form["serchType"];
            string serchValue = Request.Form["serchValue"];

            DataTable dt = st.LoadCustomerData(serchType, serchValue, "s", GetStatic.GetCountryId(), GetStatic.GetSettlingAgent());
            if (dt == null)
            {
                Response.Write("");
                Response.End();
                return;
            }
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        public static string DataSetToJSON(DataSet ds)
        {
            if (ds == null)
                return "";
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            ArrayList root = new ArrayList();
            List<Dictionary<string, object>> table;
            Dictionary<string, object> data;

            foreach (DataTable dt in ds.Tables)
            {
                table = new List<Dictionary<string, object>>();
                foreach (DataRow dr in dt.Rows)
                {
                    data = new Dictionary<string, object>();
                    foreach (DataColumn col in dt.Columns)
                    {
                        data.Add(col.ColumnName, dr[col]);
                    }
                    table.Add(data);
                }
                root.Add(table);
            }

            return serializer.Serialize(root);
        }

        public static string DataTableToJson(DataTable table)
        {
            if (table == null)
                return "";
            var list = new List<Dictionary<string, object>>();

            foreach (DataRow row in table.Rows)
            {
                var dict = new Dictionary<string, object>();

                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = string.IsNullOrEmpty(row[col].ToString()) ? "" : row[col];
                }
                list.Add(dict);
            }
            var serializer = new JavaScriptSerializer();
            string json = serializer.Serialize(list);
            return json;
        }

        public static string GetJsonString(DataTable dt)
        {
            var strDc = new string[dt.Columns.Count];

            var headStr = string.Empty;
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                strDc[i] = dt.Columns[i].Caption;
                headStr += "\"" + strDc[i] + "\" : \"" + strDc[i] + i.ToString() + " " + "\",";
            }

            headStr = headStr.Substring(0, headStr.Length - 1);
            var sb = new StringBuilder();

            sb.Append("{\"" + dt.TableName + "\" : [");
            for (var i = 0; i < dt.Rows.Count; i++)
            {
                var tempStr = headStr;

                sb.Append("{");
                for (var j = 0; j < dt.Columns.Count; j++)
                {
                    tempStr = tempStr.Replace(dt.Columns[j] + j.ToString() + "¾", dt.Rows[i][j].ToString());
                }
                sb.Append(tempStr + "},");
            }
            sb = new StringBuilder(sb.ToString().Substring(0, sb.ToString().Length - 1));

            sb.Append("]}");
            return sb.ToString();
        }

        protected void Calculate()
        {
            DataTable dt = new DataTable();
            var pCountryFv = Request.Form["pCountry"];
            var pcountrytxt = Request.Form["pCountrytxt"];
            var pModeFv = Request.Form["pMode"];
            var pModetxt = Request.Form["pModetxt"];
            var pAgentFv = Request.Form["pAgent"];
            var pAgentBranch = Request.Form["pAgentBranch"];
            var collAmt = Request.Form["collAmt"];
            var payAmt = Request.Form["payAmt"];
            var collCurr = Request.Form["collCurr"];
            var payCurr = Request.Form["payCurr"];
            var senderId = Request.Form["senderId"];
            var schemeCode = Request.Form["schemeCode"];
            var couponId = Request.Form["couponId"];
            var isManualSc = Request.Form["isManualSc"];
            var sc = Request.Form["sc"];

            dt = st.GetExRate(GetStatic.GetUser()
                     , GetStatic.GetCountryId()
                     , GetStatic.GetSuperAgent()
                     , GetStatic.GetAgent()
                     , GetStatic.GetBranch()
                     , collCurr
                     , pCountryFv
                     , pAgentFv
                     , payCurr
                     , pModeFv
                     , collAmt
                     , payAmt
                     , schemeCode
                     , senderId
                     , GetStatic.GetSessionId()
                     , couponId
                     , isManualSc
                     , sc);

            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void LoadCustomerRate()
        {
            var pCountryFv = GetStatic.ReadFormData("pCountry", "");
            var pAgentFv = GetStatic.ReadFormData("pAgent", "");
            var pModeFv = GetStatic.ReadFormData("pMode", "");
            var collCurr = GetStatic.ReadFormData("collCurr", "");

            var dt = st.LoadCustomerRate(GetStatic.GetUser()
                , GetStatic.GetCountryId()
                , GetStatic.GetSuperAgent()
                , GetStatic.GetAgent()
                , GetStatic.GetBranch()
                , collCurr
                , pCountryFv
                , pAgentFv
                , ""
                , pModeFv
                );

            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void CheckSenderIdNumber()
        {
            var sIdType = GetStatic.ReadQueryString("sIdType", "");
            var sIdNo = GetStatic.ReadFormData("sIdNo", "");

            var dt = st.CheckSenderIdNumber(GetStatic.GetUser(), sIdType, sIdNo);
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void CheckAvialableBalance()
        {
            string collectionMode = Request.Form["collectionMode"];
            string customerId = Request.Form["customerId"];
            StringBuilder sb = new StringBuilder();
            var result = st.CheckAvailableBanalce(GetStatic.GetUser(), customerId, collectionMode, "");
            if (result != null)
            {
                if (collectionMode == "Bank Deposit")
                    sb.AppendLine("<span style='background-color: yellow; font-weight: 600;padding: 4px;' id='availableBalSpan'> Available Bal: <label id=\"availableBal\" style=\"font-size: 14px;font-weight: 800;\">" + GetStatic.ShowDecimal(result.Rows[0]["avilableBalance"].ToString()) + " </label>&nbsp;"+ GetStatic.ReadWebConfig("currencyJP", "") + "</span>");
                else
                    sb.AppendLine("<span style='background-color: yellow; font-weight: 600;padding: 4px;' id='availableBalSpan'> Available Limit: <label id=\"availableBal\" style=\"font-size: 14px;font-weight: 800;\">" + GetStatic.ShowDecimal(result.Rows[0]["avilableBalance"].ToString()) + " </label>&nbsp;"+ GetStatic.ReadWebConfig("currencyJP", "") + " " + " (" + result.Rows[0]["holdType"].ToString() + ")</span>");
            }
            else
            {
                sb.AppendLine("<span style='background-color: yellow; font-weight: 600;padding: 4px;' id='availableBalSpan'> Available Bal: <label id=\"availableBal\" style=\"font-size: 14px;font-weight: 800;\">Balance Not Available</label>&nbsp;"+ GetStatic.ReadWebConfig("currencyJP", "") + "</span>");
            }
            Response.Write(sb);
            Response.End();
        }

        private void GetPayerDataByBankId()
        {
            string bankId = Request.Form["bankId"];
            string partnerId = Request.Form["partnerId"];
            DataTable dt = st.GetPayersByAgent(bankId, partnerId);
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        private void GetPayerDataByPayerAndCityId()
        {
            string bankId = Request.Form["payerId"];
            string partnerId = Request.Form["partnerId"];
            string cityId = Request.Form["CityId"];
            DataTable dt = st.GetPayerBranchDataByPayerAndCityId(bankId, cityId, partnerId);
            Response.ContentType = "text/plain";
            string json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        protected void register_Click(object sender, EventArgs e)
        {
            //ucTranDetails.tD = SetTxnData();
            //complete.Attributes.Add("Class", "active");

            //divTranDetails.Visible = true;
            //txtSenderName.InnerText = txtRecFName.Text;
        }

        private IRHTranDetail SetTxnData()
        {
            var trn = new IRHTranDetail();
            var randObj = new Random();
            var agentRefId = randObj.Next(1000000000, 1999999999).ToString();
            trn.AgentRefId = agentRefId;
            trn.User = GetStatic.GetUser();
            trn.SessionId = GetStatic.GetSessionId();
            //trn.SenderId = finalSenderId.InnerText;
            trn.SenFirstName = txtSendFirstName.Text;
            trn.SenMiddleName = txtSendMidName.Text;
            trn.SenLastName = txtSendLastName.Text;
            trn.SenGender = ddlSenGender.SelectedValue;
            trn.SenIdType = ddSenIdType.SelectedValue;
            trn.SenIdNo = txtSendIdNo.Text;
            trn.SenIdValid = txtSendIdValidDate.Text;
            trn.SenDob = txtSendDOB.Text;
            trn.SenEmail = txtSendEmail.Text;
            trn.SenTel = txtSendTel.Text;
            trn.SenMobile = txtSendMobile.Text;
            trn.SenNaCountry = txtSendNativeCountry.Text;
            trn.SenCity = txtSendCity.Text;
            trn.SenPostCode = txtSendPostal.Text;
            trn.ReceiverId = ddlReceiver.SelectedValue;
            trn.RecFirstName = txtRecFName.Text;
            trn.RecMiddleName = txtRecMName.Text;
            trn.RecLastName = txtRecLName.Text;
            trn.RecGender = ddlRecGender.SelectedValue;
            trn.RecIdType = ddlRecIdType.SelectedItem.Text;
            trn.RecIdNo = txtRecIdNo.Text;
            trn.RecTel = txtRecTel.Text;
            trn.RecMobile = txtRecMobile.Text;
            trn.RecNaCountry = "";
            trn.RecCity = txtRecCity.Text;
            trn.RecAdd1 = txtRecAdd1.Text;
            trn.RecEmail = txtRecEmail.Text;
            trn.RecAccountNo = txtRecDepAcNo.Text;
            trn.RecCountryId = pCountry.SelectedValue;
            trn.RecCountry = pCountry.SelectedItem.Text;
            trn.DeliveryMethodId = Request.Form[pMode.UniqueID];
            trn.PBank = Request.Form[pAgent.UniqueID];
            trn.PBankBranch = Request.Form[branch.UniqueID];
            trn.PBankType = Request.Form[pAgentDetail.UniqueID];
            trn.PAgent = Request.Form[pAgent.UniqueID];

            trn.PCurr = lblPayCurr.Text;
            trn.CollCurr = lblCollCurr.Text;
            trn.CollAmt = txtCollAmt.Text;
            trn.CustomerLimit = txtCustomerLimit.Value;
            trn.PayoutAmt = txtPayAmt.Text;
            trn.TransferAmt = lblSendAmt.Text;
            trn.ServiceCharge = lblServiceChargeAmt.Text;
            trn.ExRate = lblExRate.Text;
            trn.PurposeOfRemittance = purpose.SelectedItem.Text;
            trn.SourceOfFund = sourceOfFund.SelectedItem.Text;
            trn.RelWithSender = relationship.SelectedItem.Text;
            trn.Occupation = occupation.SelectedValue;
            trn.PayoutMsg = txtPayMsg.Text;
            trn.Company = companyName.Text;
            trn.NCustomer = "N";
            trn.ECustomer = "Y";

            trn.SBranch = GetStatic.GetBranch();
            trn.SBranchName = GetStatic.GetBranchName();
            trn.SAgent = GetStatic.GetAgent();
            trn.SAgentName = GetStatic.GetAgentName();
            trn.SSuperAgent = GetStatic.GetSuperAgent();
            trn.SSuperAgentName = GetStatic.GetSuperAgentName();
            trn.SettlingAgent = GetStatic.GetSettlingAgent();
            trn.SCountry = GetStatic.GetCountry();
            trn.SCountryId = GetStatic.GetCountryId();

            trn.manualSC = lblServiceChargeAmt.Text;
            trn.sCustStreet = sCustStreet.Text;
            trn.sCustLocation = custLocationDDL.SelectedValue;
            trn.sCustomerType = ddlSendCustomerType.SelectedValue;
            trn.sCustBusinessType = ddlEmpBusinessType.SelectedValue;
            trn.sCustIdIssuedCountry = ddlIdIssuedCountry.SelectedValue;
            trn.sCustIdIssuedDate = txtSendIdExpireDate.Text;
            trn.receiverId = Request.Form[ddlReceiver.UniqueID];
            trn.payoutPartner = hddPayoutPartner.Value;
            trn.introducer = introducerTxt.Text;
            trn.tpExRate = hddTPExRate.Value;
            return trn;
        }

        private void Proceed()
        {
            var dbResult = Save();

            if (!string.IsNullOrEmpty(hddImgURL.Value) && (dbResult.ErrorCode == "0" || dbResult.ErrorCode == "100" || dbResult.ErrorCode == "101"))
            {
                UploadImage(hddImgURL.Value, dbResult.Id);
            }

            if (dbResult.ErrorCode == "0" || dbResult.ErrorCode == "100" || dbResult.ErrorCode == "101")
            {
                GetStatic.SetMessage(dbResult);
                ManageMessage1(dbResult);
            }
            else
            {
                GetStatic.SetMessage(dbResult);
                ManageMessage1(dbResult);
            }
        }

        private DbResult Save()
        {
            var trn = GetDataForValidation();
            return st.SendTransactionIRH(trn);
        }

        private void ManageMessage1(DbResult dbResult)
        {
            var mes = GetStatic.ParseResultJsPrint(dbResult);
            mes = mes.Replace("'", "");
            mes = mes.Replace("<center>", "");
            mes = mes.Replace("</center>", "");

            var invPrintMode = invoicePrintMode.Text;
            var scriptName = "ManageMessage";
            var functionName = "ManageMessage('" + mes + "','" + invPrintMode + "');";
            GetStatic.CallBackJs1(Page, scriptName, functionName);
        }

        public void UploadImage(string imageData, string controlNo)
        {
            string path = GetStatic.GetCustomerFilePath() + "Transaction\\CustomerSignature\\" + DateTime.Now.Year.ToString() + "\\" + DateTime.Now.Month.ToString() + "\\" + DateTime.Now.Day.ToString();
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);

            string fileName = path + "\\" + controlNo + ".png";
            using (FileStream fs = new FileStream(fileName, FileMode.Create))
            {
                using (BinaryWriter bw = new BinaryWriter(fs))
                {
                    byte[] data = Convert.FromBase64String(imageData);
                    bw.Write(data);
                    bw.Close();
                }
            }
        }

        protected void chkMultipleTxn_CheckedChanged(object sender, EventArgs e)
        {
            if (!chkCdd.Visible)
                if (!chkMultipleTxn.Checked)
                    sendTran.Attributes.Add("disabled", (true).ToString());
                else
                    sendTran.Attributes.Remove("disabled");
            else
            {
                if (chkMultipleTxn.Checked && chkCdd.Checked)
                    sendTran.Attributes.Add("disabled", (true).ToString());
                else
                    sendTran.Attributes.Remove("disabled");
            }
        }

        protected void chkCdd_CheckedChanged(object sender, EventArgs e)
        {
            if (!chkMultipleTxn.Visible)
                sendTran.Attributes.Add("disabled", (!chkCdd.Checked).ToString());
            else
            {
                if (chkMultipleTxn.Checked && chkCdd.Checked)
                    sendTran.Attributes.Add("disabled", (true).ToString());
                else
                    sendTran.Attributes.Remove("disabled");
            }
        }
    }
}