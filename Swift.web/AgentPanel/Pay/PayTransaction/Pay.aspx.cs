using Swift.API.Common.PayTransaction;
using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.BL.Remit.Transaction.PayTransaction;
using Swift.DAL.BL.System.Utility;
using Swift.DAL.BL.ThirdParty.GME;
using Swift.DAL.BL.ThirdParty.ThirdpartyPayTxn;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.Script.Serialization;

namespace Swift.web.AgentPanel.Pay.PayTransaction
{
    public partial class Pay : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceLibrary _rl = new RemittanceLibrary();
        private const string ViewFunctionId = "40101300";
        private const string ProcessFunctionId = "40101310";

        private CustomersDao cd = new CustomersDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sdd.CheckPayTransactionAllowedTime();
            _rl.CheckSession();
            if (!IsPostBack)
            {
                #region Ajax methods

                string reqMethod = Request.Form["MethodName"];
                if (!string.IsNullOrWhiteSpace(reqMethod))
                {
                    switch (reqMethod)
                    {
                        case "issuecard":
                            IssueCustCard();
                            break;

                        case "getdate":
                            GetDateADVsBS();
                            break;

                        case "idissuedplace":
                            GetIdIssuedPlace();
                            break;
                    }
                    return;
                }

                #endregion Ajax methods

                PopulateDdl();
                Authenticate();
                ShowTransaction();

                rIdValidDate.Attributes.Add("onchange", "GetADVsBSDate('ad','rIdValidDate')");

                rIdIssuedDate.Attributes.Add("onchange", "GetADVsBSDate('ad','rIdIssuedDate')");
                rIdIssuedDateBs.Attributes.Add("onchange", "GetADVsBSDate('bs','rIdIssuedDateBs')");

                rDOB.Attributes.Add("onchange", "GetADVsBSDate('ad','rDOB')");
                rDOBBs.Attributes.Add("onchange", "GetADVsBSDate('bs','rDOBBs')");
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + ProcessFunctionId);
            btnPay.Visible = _sdd.HasRight(ProcessFunctionId);
        }

        private void PopulateDdl()
        {
            string countryId = GetStatic.GetCountryId();
            _sdd.SetDDL3(ref rIdType, "EXEC proc_countryIdType @flag = 'il-with-et', @countryId='" + countryId + "', @spFlag = '5202'", "valueId", "detailTitle", "", "Select");
            _sdd.SetDDL3(ref relationType, "select valueId,detailTitle from staticDataValue (NOLOCK)  where valueId in (2101,2102,2105,2106) and ISNULL(IS_DELETE,'N')<>'Y'", "valueId", "detailTitle", "", "Select");
            _sdd.SetStaticDdl(ref rOccupation, "2000", "", "Select");
            _sdd.SetGenderDDL(ref rGender, "", "Select");
            _sdd.SetStaticDdl2(ref relWithSender, "2100", "", "Select");
            _sdd.SetStaticDdl(ref por, "3800", "", "Select");
            _sdd.SetDDL3(ref recNationality, "EXEC proc_dropDownLists2 @flag = 'recNationality'", "countryId", "countryName", "Mongolia", "Select");
            _sdd.SetDDL3(ref rIdPlaceOfIssue, "EXEC proc_dropDownLists2 @flag = 'idIssuedCountry'", "countryId", "countryName", "Mongolia", "Select");
        }

        public string GetPartener()
        {
            return GetStatic.ReadQueryString("partenerId", "");
        }

        private void ShowTransaction()
        {
            var pay = new PayDao();
            var tranId = GetTranId();
            DataSet ds;

            ds = pay.GetThirdParyTxnDetail(GetStatic.GetUser(), tranId, GetPartner(), GetStatic.GetBranch());

            if (ds == null)
            {
                _rl.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "N");
                divTxnPanel.Visible = false;
                return;
            }

            // if transaction not valid
            var dbResult = pay.ParseDbResult(ds.Tables[0]);
            if (dbResult.ErrorCode != "0")
            {
                divTxnPanel.Visible = false;
                GetStatic.AlertMessage(Page, dbResult.Msg);
                return;
            }

            if (ds.Tables[1].Rows.Count > 0)
            {
                _rl.ManageInvalidControlNoAttempt(Page, GetStatic.GetUser(), "Y");
                var row = ds.Tables[1].Rows[0];
                lblBranchName.Text = row["branchName"].ToString();
                //providerName.Text = row["providerName"].ToString();
                hddRowId.Value = tranId;
                hddPayAmt.Value = HideNoAfterDecimal(row["pAmount"].ToString());
                hddOriginalAmt.Value = row["pAmount"].ToString();
                hddControlNo.Value = row["securityNo"].ToString();
                hddTokenId.Value = row["tokenId"].ToString();
                hddCeTxn.Value = "";
                hddOrderNo.Value = row["orderNo"].ToString();
                hddRCurrency.Value = row["rCurrency"].ToString();
                //3 lakh validation while paying
                hddagentgroup.Value = row["agentGrp"].ToString();
                var limitAmount = GetStatic.GetPayAmountLimit(row["securityNo"].ToString());
                if (Convert.ToDouble(row["amt"]) > limitAmount && hddagentgroup.Value == "4301")
                {
                    //bankAndFinanceType.Visible = true;
                    //otherAgentType.Visible = false;
                    //RequiredFieldValidator8.Enabled = false;
                    //RequiredFieldValidator9.Enabled = false;
                    //RequiredFieldValidator7.Enabled = false;
                }
                else if (Convert.ToDouble(row["amt"]) > limitAmount && hddagentgroup.Value != "4301")
                {
                    //bankAndFinanceType.Visible = false;
                    //otherAgentType.Visible = true;
                    //_sdd.SetDDL3(ref rBankName, "EXEC proc_dropDownLists2 @flag = 'pay-bank-list'", "extBankId", "bankName", "", "Select");
                }
                else
                {
                    RequiredFieldValidator8.Enabled = false;
                    RequiredFieldValidator9.Enabled = false;
                    RequiredFieldValidator7.Enabled = false;
                }

                if (string.IsNullOrEmpty(row["sendingCountry"].ToString()))
                {
                    hddSCountry.Value = GetStatic.GetSendingCountryBySCurr(row["rCurrency"].ToString());
                    senderCountry.Text = GetStatic.GetSendingCountryBySCurr(row["rCurrency"].ToString());
                    sendingCountry.Text = GetStatic.GetSendingCountryBySCurr(row["rCurrency"].ToString());
                }
                else
                {
                    hddSCountry.Value = row["sendingCountry"].ToString();
                    senderCountry.Text = row["sendingCountry"].ToString();
                    sendingCountry.Text = row["sendingCountry"].ToString();
                }
                sendingAgent.Text = row["sendingAgent"].ToString();
                securityNo.Text = row["securityNo"].ToString();
                transactionDate.Text = row["transactionDate"].ToString();
                paymentMode.Text = row["paymentMethod"].ToString();

                senderName.Text = row["senderName"].ToString();
                senderAddress.Text = row["senderAddress"].ToString();
                senderContactNo.Text = row["senderMobile"].ToString();
                if (string.IsNullOrEmpty(row["senderCity"].ToString()))
                    trSenCity.Visible = false;
                else
                    senderCity.Text = row["senderCity"].ToString();

                if (string.IsNullOrEmpty(row["remarks"].ToString()))
                    trMsg.Visible = false;
                else
                    message.Text = row["remarks"].ToString();

                if (string.IsNullOrEmpty(row["senderIdType"].ToString()))
                    trIdType.Visible = false;
                else
                {
                    senIdType.Text = row["senderIdType"].ToString();
                    senIdNo.Text = row["senderIdNo"].ToString();
                }

                if (string.IsNullOrEmpty(row["recCountry"].ToString()))
                    trRecCountry.Visible = false;
                else
                    recCountry.Text = row["recCountry"].ToString();

                recName.Text = row["recName"].ToString();
                recAddress.Text = row["recAddress"].ToString();

                if (string.IsNullOrEmpty(row["recMobile"].ToString()))
                    trRecContactNo.Visible = false;
                else
                    recContactNo.Text = row["recMobile"].ToString();

                if (string.IsNullOrEmpty(row["recCity"].ToString()))
                    trRecCity.Visible = false;
                else
                    recCity.Text = row["recCity"].ToString();

                if (string.IsNullOrEmpty(row["recIdType"].ToString()))
                    trRecIdType.Visible = false;
                else
                {
                    recIdType.Text = row["recIdType"].ToString();
                    recIdNo.Text = row["recIdNo"].ToString();
                }
                payoutCurr.Text = row["pCurrency"].ToString();
                payoutAmount.Text = GetStatic.ShowDecimal(HideNoAfterDecimal(row["amt"].ToString()));
                amtToWords.Text = GetStatic.NumberToWord(row["amt"].ToString());
                hddAgentName.Value = row["pBranch"].ToString();
                //for kumari bank subpartner id
                hiddenSubPartnerId.Value = row["subPartnerId"].ToString();
            }
            if (ds.Tables[2].Rows.Count > 0)
            {
                var dt = ds.Tables[2];
                var str = new StringBuilder("<div class='panel panel-default'><div class='panel-heading'>Transaction Complain (Trouble Ticket)</div><div class='panel-body'><table class='table table-bordered'>");
                str.Append("<tr>");
                str.Append("<th>Updated By</th>");
                str.Append("<th width='130px'>Updated Date</th>");
                str.Append("<th>Message</th>");
                str.Append("</tr>");
                foreach (DataRow dr in dt.Rows)
                {
                    str.Append("<tr>");
                    str.Append("<td align='left'>" + dr["createdBy"] + "</td>");
                    str.Append("<td align='left'>" + dr["createdDate"] + "</td>");
                    str.Append("<td align='left'>" + dr["message"] + "</td>");
                    str.Append("</tr>");
                }
                str.Append("</table>");
                str.Append("</div>");
                str.Append("</div>");
                rptLog.InnerHtml = str.ToString();
            }
        }

        public string GetPartner()
        {
            return GetStatic.ReadQueryString("partenerId", "");
        }

        public string GetTranId()
        {
            return GetStatic.ReadQueryString("id", "");
        }

        private static string HideNoAfterDecimal(string amount)
        {
            return Math.Floor(Convert.ToDouble(amount)).ToString();
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            PayTran();
        }

        private void PayTran()
        {
            var partener = GetPartner();
            var dr = new DbResult();
            if (partener.Equals("IME-I"))
            {
                dr = PayInternational();
            }
            else if (partener.Equals(Utility.ReadWebConfig("gmepartnerid", "")))
            {
                dr = PayGMETxn(Utility.ReadWebConfig("gmepartnerid", ""));
            }
            else if (partener.Equals(Utility.ReadWebConfig("riapartnerid", "")))
            {
                dr = PayGMETxn(Utility.ReadWebConfig("riapartnerid", ""));
            }
            if (!dr.ErrorCode.Equals("0"))
            {
                if (dr.ErrorCode.Equals("101"))
                {
                    var url = "PayCompliance.aspx";
                    Response.Redirect(url);
                }
                else
                {
                    GetStatic.AlertMessage(Page, dr.Msg);
                }
                return;
            }
            else
            {
                var url = "PayReceipt.aspx?controlNo=" + dr.Id;
                Response.Redirect(url);
            }
        }

        private DbResult PayGMETxn(string providerValue)
        {
            //IGMEDao _gme = new GMEDao();
            //GMEPayConfirmDetails payConfirmDetails = new GMEPayConfirmDetails
            //{
            //    user = GetStatic.GetUser(),
            //    rowId = hddRowId.Value,
            //    refNo = hddControlNo.Value,
            //    payTokenId = hddTokenId.Value,
            //    sCountry = hddSCountry.Value,
            //    pBranch = GetStatic.GetBranch(),
            //    rIdType = rIdType.SelectedItem.Text,
            //    rIdNumber = rIdNumber.Text,
            //    rIdPlaceOfIssue = hddrIdPlaceOfIssue.Value,
            //    rContactNo = rContactNo.Text,
            //    relationType = relationType.SelectedItem.ToString(),
            //    relativeName = relativeName.Text,
            //    customerId = hddCustomerId.Value,
            //    membershipId = hddMembershipId.Value,
            //    rBankName = rBankName.Text,
            //    rBankBranch = rbankBranch.Text,
            //    rCheque = hddchequenumber.Value,
            //    rAccountNo = rAccountNo.Text,
            //    dob = rDOB.Text,
            //    relationship = relWithSender.SelectedValue,
            //    purposeOfRemittance = por.SelectedItem.Text,
            //    idIssueDate = rIdIssuedDate.Text,
            //    idExpiryDate = rIdValidDate.Text,
            //    branchMapCode = Utility.ReadWebConfig("gmepartnerid", ""),
            //    receiverAddress = recAddress.Text,
            //    receiverCity = recCity.Text,
            //    receiverCountry = recCountry.Text,
            //    txnDate = transactionDate.Text,
            //    pAmount = hddOriginalAmt.Value,
            //    benefStateId = benefStateId.Value,
            //    benefCityId = benefCityId.Value
            //};

            //return _gme.PayConfirm(payConfirmDetails);

            List<result> _list = new List<result>()
            {
                new result()
                {
                    qId="4",
                    answer=ddlPEP.SelectedValue,
                    qType = "dropdown"
                }
            };
            txnCompliance _txnCom = new txnCompliance();
            _txnCom.result = _list;

            IPayTransactionThirdpartyDao _cofirmDao = new PayTransactionThirdpartyDao();
            PayTxnConfirm _detail = new PayTxnConfirm()
            {
                SendingPartner = providerValue,
                RequestFrom = "core",
                ProviderId = providerValue,
                SessionId = GetAgentSession(),
                ProcessId = Guid.NewGuid().ToString(),
                rowId = hddRowId.Value,
                UserName = GetStatic.GetUser(),
                ControlNo = hddControlNo.Value,
                ReceivingTokenId = hddTokenId.Value,
                sCountry = hddSCountry.Value,
                PBranch = GetStatic.GetBranch(),
                rIdType = rIdType.SelectedItem.Text,
                rIdNumber = rIdNumber.Text,
                rContactNo = rContactNo.Text,
                relationType = relationType.SelectedItem.ToString(),
                relativeName = relativeName.Text,
                customerId = hddCustomerId.Value,
                rBankName = rBankName.Text,
                rBankBranch = rbankBranch.Text,
                rCheque = hddchequenumber.Value,
                rAccountNo = rAccountNo.Text,
                rDob = rDOB.Text,
                relationship = relWithSender.SelectedValue,
                purposeOfRemittance = por.SelectedItem.Text,
                rIdIssueDate = rIdIssuedDate.Text,
                rIdExpiryDate = rIdValidDate.Text,
                rIdPlaceOfIssue = rIdPlaceOfIssue.SelectedItem.Text,
                rIdPlaceOfIssueCode = rIdPlaceOfIssue.Text.Split('|')[1],
                receiverAddress = (rAdd.Text != null && rAdd.Text != "") ? rAdd.Text : recAddress.Text,
                receiverCity = (BeneCity.Text != null && BeneCity.Text != "") ? BeneCity.Text : recCity.Text,
                receiverCountry = (rIdPlaceOfIssue.SelectedItem.Text != "" && rIdPlaceOfIssue.SelectedItem.Text != null) ? rIdPlaceOfIssue.SelectedItem.Text : recCountry.Text,
                receiverCountryCode = rIdPlaceOfIssue.Text.Split('|')[1],
                txnDate = transactionDate.Text,
                pAmount = hddOriginalAmt.Value,
                benefStateId = benefStateId.Value,
                benefCityId = benefCityId.Value,
                txnCompliance = _txnCom
            };

            return _cofirmDao.ConfirmTransaction(_detail);
        }

        private string GetAgentSession()
        {
            return (DateTime.Now.Ticks + DateTime.Now.Millisecond).ToString();
        }

        private DbResult PayInternational()
        {
            var obj = new DAL.BL.Remit.Transaction.PayTransactionDao();
            var pBranch = GetStatic.GetBranch();
            var pBranchName = GetStatic.GetBranchName();
            var pAgent = GetStatic.GetAgent();
            var pAgentName = GetStatic.GetAgentName();
            var pSuperAgent = GetStatic.GetSuperAgent();
            var pSuperAgentName = GetStatic.GetSuperAgentName();
            var settlingAgent = GetStatic.GetSettlingAgent();
            var mapCodeInt = GetStatic.GetMapCodeInt();
            var mapCodeDom = GetStatic.GetMapCodeDom();

            List<result> _list = new List<result>()
            {
                new result()
                {
                    qId="4",
                    answer=ddlPEP.SelectedValue,
                    qType = "dropdown"
                }
            };

            var qsnnarie = GetComplianceQuestionXML(_list);

            DbResult dr = obj.PayInternationalTransaction(GetStatic.GetUser(), hddControlNo.Value, GetStatic.GetSessionId(), rIdType.SelectedItem.Text,
                                            rIdNumber.Text, hddrIdPlaceOfIssue.Value, rContactNo.Text, relationType.SelectedItem.Text,
                                            relativeName.Text, pBranch, pBranchName, pAgent, pAgentName, pSuperAgent, pSuperAgentName,
                                            settlingAgent, mapCodeInt, mapCodeDom, hddCustomerId.Value, hddMembershipId.Value,
                                            rBankName.Text, rbankBranch.Text, hddchequenumber.Value, rAccountNo.Text, alternateMobileNo.Text, rDOB.Text, relWithSender.SelectedValue, por.SelectedValue
                                            , rIdIssuedDate.Text, rIdValidDate.Text, qsnnarie);
            return dr;
        }

        private string GetComplianceQuestionXML(List<result> result)
        {
            StringBuilder xml = new StringBuilder();
            if (result != null)
            {
                xml.Append("<root>");
                foreach (var item in result)
                {
                    xml.AppendLine("<row answer=\"" + item.answer + "\" qId=\"" + item.qId + "\" qType=\"" + item.qType + "\" />");
                }
                xml.AppendLine("</root>");
            }
            return xml.ToString();
        }

        protected void BtnBack_Click(object sender, EventArgs e)
        {
            var lockObj = new LockUnlock();
            lockObj.UnlockTransaction(GetStatic.GetUser(), securityNo.Text);
            Response.Redirect("PaySearch.aspx");
        }

        private void IssueCustCard()
        {
            string sMemId = Request.Form["cMemId"];
            string firstName = Request.Form["cFirstName"];
            string middleName = Request.Form["cMiddleName"];
            string lastName = Request.Form["cLastName1"];
            string lastName1 = Request.Form["cLastName2"];

            string idType = Request.Form["cIdType"];
            string idNo = Request.Form["cIdNo"];
            string validDate = Request.Form["cIdValidDate"];
            string dob = Request.Form["cDOB"];
            string telNo = "";
            string mobile = Request.Form["cContactNo"];
            string city = "";
            string postalCode = "";
            string companyName = "";
            string address1 = Request.Form["cAddress"];
            string address2 = "";
            string nativeCountry = "";
            string email = Request.Form["cEmail"];
            string gender = Request.Form["cGender"];
            string salary = "";
            string occupation = Request.Form["cOccupation"];
            string id = Request.Form["custId"];
            string idIssuedDate = Request.Form["cIdIssuedDate"];
            string idIssuedPlace = Request.Form["cIdIssuedPlace"];

            string relationType = Request.Form["cRelationType"];
            string relativeName = Request.Form["cRelativeName"];

            string idIssuedDateBs = Request.Form["cIdIssuedDateBs"];
            string dobBs = Request.Form["cDOBBs"];
            string validDateBs = Request.Form["cIdValidDateBs"];

            var isMemberIssue = "Y";

            DataTable dt = new DataTable();
            dt.Columns.Add("errorCode");
            dt.Columns.Add("msg");
            dt.Columns.Add("id");

            if (string.IsNullOrWhiteSpace(dob))
            {
                DataRow row = dt.NewRow();
                row[0] = "1";
                row[1] = "D.O.B should not be blank";
                row[2] = "";
                dt.Rows.Add(row);
            }
            else
            {
                /*
                 dt = cd.Update(GetStatic.GetUser(), id, firstName, middleName, lastName, lastName1, GetStatic.GetCountryId(), idType, idNo, validDate, dob, telNo, mobile, city, postalCode,
                 companyName, address1, address2, nativeCountry, email, gender, salary, memberId, occupation, isMemberIssue, GetStatic.GetAgent(), GetStatic.GetBranch()); */

                var dr = cd.UpdateAgent(
                                GetStatic.GetUser(),
                                id,
                                sMemId,
                                firstName,
                                middleName,
                                lastName,
                                "",
                                dob,
                                dobBs,
                                "",
                                idType,
                                idNo,
                                idIssuedPlace,
                                idIssuedDate,
                                validDate,
                                address1,
                                "",
                                "",
                                "",
                                "",
                                "",
                                "",
                                "",
                                "",
                                "",
                                "",
                                "",
                                "",
                                "",
                                relativeName,
                                relativeName,
                                "",
                                occupation,
                                email,
                                "",
                                mobile,
                                GetStatic.GetBranch(),
                                gender,
                                idIssuedDateBs,
                                validDateBs);

                DataRow row = dt.NewRow();
                row[0] = dr.ErrorCode;
                row[1] = dr.Msg;
                row[2] = dr.Id;
                dt.Rows.Add(row);
            }

            Response.ContentType = "text/plain";
            var json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }

        private void GetDateADVsBS()
        {
            var date = Request.Form["date"];
            var type = Request.Form["type"];
            type = (type == "ad") ? "e" : "bs";
            var dt = cd.LoadCalender(GetStatic.GetUser(), date, type);
            Response.ContentType = "text/plain";
            var json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }

        public static string DataTableToJSON(DataTable table)
        {
            List<Dictionary<string, object>> list = new List<Dictionary<string, object>>();
            foreach (DataRow row in table.Rows)
            {
                Dictionary<string, object> dict = new Dictionary<string, object>();
                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = row[col];
                }
                list.Add(dict);
            }
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            return serializer.Serialize(list);
        }

        private void GetIdIssuedPlace()
        {
            var IdType = Request.Form["IdType"];
            var dt = cd.LoadIdIssuedPlace(GetStatic.GetUser(), IdType);
            Response.ContentType = "text/plain";
            var json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }
    }
}