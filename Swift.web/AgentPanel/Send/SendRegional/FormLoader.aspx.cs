using Swift.DAL.BL.AgentPanel.Utilities;
using Swift.DAL.BL.Remit.Transaction.Domestic;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.IO;
using System.Text;

namespace Swift.web.AgentPanel.Send.SendRegional
{
    public partial class FormLoader : System.Web.UI.Page
    {
        private SendTransactionDao send = new SendTransactionDao();
        private const string ViewFunctionId = "40102700";
        private const string AddEditFunctionId = "40102710";
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private string _sBranch = GetStatic.ReadQueryString("sBranch", "");
        private string _pDistrict = GetStatic.ReadQueryString("pDistrict", "");
        private string _pLocation = GetStatic.ReadQueryString("pLocation", "");
        private string _ta = GetStatic.ReadQueryString("ta", "0");
        private string _tc = GetStatic.ReadQueryString("tc", "0");
        private string _sc = GetStatic.ReadQueryString("sc", "0");
        private string _dm = GetStatic.ReadQueryString("dm", "");
        private readonly string _senderId = GetStatic.ReadQueryString("senderId", "");
        private readonly string _sMemId = GetStatic.ReadQueryString("sMemId", "");
        private readonly string _sFirstName = GetStatic.ReadQueryString("sFirstName", "");
        private readonly string _sMiddleName = GetStatic.ReadQueryString("sMiddleName", "");
        private readonly string _sLastName1 = GetStatic.ReadQueryString("sLastName1", "");
        private readonly string _sLastName2 = GetStatic.ReadQueryString("sLastName2", "");
        private readonly string _sAddress = GetStatic.ReadQueryString("sAddress", "");
        private readonly string _sContactNo = GetStatic.ReadQueryString("sContactNo", "");
        private readonly string _sIdType = GetStatic.ReadQueryString("sIdType", "");
        private readonly string _sIdNo = GetStatic.ReadQueryString("sIdNo", "");
        private readonly string _sEmail = GetStatic.ReadQueryString("sEmail", "");
        private readonly string _receiverId = GetStatic.ReadQueryString("receiverId", "");
        private readonly string _rMemId = GetStatic.ReadQueryString("rMemId", "");
        private readonly string _rFirstName = GetStatic.ReadQueryString("rFirstName", "");
        private readonly string _rMiddleName = GetStatic.ReadQueryString("rMiddleName", "");
        private readonly string _rLastName1 = GetStatic.ReadQueryString("rLastName1", "");
        private readonly string _rLastName2 = GetStatic.ReadQueryString("rLastName2", "");
        private readonly string _rAddress = GetStatic.ReadQueryString("rAddress", "");
        private readonly string _rContactNo = GetStatic.ReadQueryString("rContactNo", "");
        private readonly string _rIdType = GetStatic.ReadQueryString("rIdType", "");
        private readonly string _rIdNo = GetStatic.ReadQueryString("rIdNo", "");
        private readonly string _rel = GetStatic.ReadQueryString("rel", "");
        private readonly string _payMsg = GetStatic.ReadQueryString("payMsg", "");

        private readonly string _sof = GetStatic.ReadQueryString("sof", "");
        private readonly string _por = GetStatic.ReadQueryString("por", "");
        private readonly string _occupation = GetStatic.ReadQueryString("occupation", "");

        private readonly string _agentRefId = GetStatic.ReadQueryString("agentRefId", "");
        private readonly string _complianceAction = GetStatic.ReadQueryString("complianceAction", "");
        private readonly string _compApproveRemark = GetStatic.ReadQueryString("compApproveRemark", "");
        private readonly string _txnBatchId = GetStatic.ReadQueryString("txnBatchId", "");

        private string _amount = GetStatic.ReadQueryString("amount", "0");
        private string _bankId = GetStatic.ReadQueryString("bankId", "");
        private string _pBankBranch = GetStatic.ReadQueryString("pBankBranch", "");
        private readonly string _accountNo = GetStatic.ReadQueryString("accountNo", "");

        private readonly string _sIdIssuedPlace = GetStatic.ReadQueryString("sIdIssuedPlace", "");
        private readonly string _sIdIssuedDate = GetStatic.ReadQueryString("sIdIssuedDate", "");

        private readonly string _sDOB = GetStatic.ReadQueryString("sDOB", "");
        private readonly string _sIdValidDate = GetStatic.ReadQueryString("sIdValidDate", "");

        private readonly string _sIdIssuedDateBs = GetStatic.ReadQueryString("sIdIssuedDateBs", "");
        private readonly string _sDOBBs = GetStatic.ReadQueryString("sDOBBs", "");
        private readonly string _sIdValidDateBs = GetStatic.ReadQueryString("sIdValidDateBs", "");

        private readonly string _sGender = GetStatic.ReadQueryString("gender", "");
        private readonly string _sMotherFatherName = GetStatic.ReadQueryString("motherFatherName", "");
        private readonly string _CustCardId = GetStatic.ReadQueryString("CustCardId", "");

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            ReturnValue();
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private string GetQueryType()
        {
            return GetStatic.ReadQueryString("type", "");
        }

        private string GetMemId()
        {
            return GetStatic.ReadQueryString("memId", "");
        }

        private void ReturnValue()
        {
            switch (GetQueryType())
            {
                case "s":
                    LoadSender();
                    break;

                case "r":
                    LoadReceiver();
                    break;

                case "a":
                    Calculate();
                    break;

                case "ac":
                    LoadAvailableAccountBalance();
                    break;

                case "bb":
                    PopulateBranchName();
                    break;

                case "sct":
                    LoadServiceChargeTable();
                    break;

                case "dl":
                    PopulateDistrict();
                    break;

                case "ll":
                    PopulateLocation();
                    break;

                case "st":
                    SendTran();
                    break;

                case "rPay":
                    LoadReceiverPay();
                    break;
            }
        }

        private void LoadReceiverPay()
        {
            DataSet ds = send.GetMemberFromPay(GetStatic.GetUser(), GetMemId());
            if (ds.Tables.Count > 1)
            {
                var dbResult = send.ParseDbResult(ds.Tables[0]);
                if (dbResult.ErrorCode != "0")
                {
                    Response.Write(dbResult.ErrorCode + "|" + dbResult.Msg + "|" + dbResult.Id);
                    return;
                }
                if (ds.Tables[1].Rows.Count == 0)
                    return;
                var dr = ds.Tables[1].Rows[0];

                Response.Write("0" + "|" +
                               GetMemId() + "|" +
                               dr["idType"] + "|" +
                               dr["idNumber"] + "|" +
                               dr["district"] + "|" +
                               dr["mobile"] + "|" +
                               dr["customerId"] + "|" +
                               dr["fullName"] + "|" +
                               dr["relationType"] + "|" +
                               dr["relativeName"]);
            }
        }

        private void PopulateDistrict()
        {
            var dao = new RemittanceDao();
            var sql = "EXEC proc_zoneDistrictMap @flag = 'd', @apiDistrictCode = " + dao.FilterString(_pLocation);
            var dt = dao.ExecuteDataset(sql).Tables[0];
            if (dt == null || dt.Rows.Count == 0)
            {
                Response.Write("<select id=\"district\" class=\"form-control\" onchange=\"PopulateLocation();\"></select>");
                return;
            }
            var html =
                new StringBuilder("<select id=\"district\" class=\"form-control\" onchange=\"PopulateLocation();\">");
            if (string.IsNullOrEmpty(_pLocation))
                html.Append("<option value = \"\">Select</option>");
            foreach (DataRow dr in dt.Rows)
            {
                if (!string.IsNullOrEmpty(_pLocation))
                    html.Append("<option value = \"" + dr["districtId"] + "\" selected=\"selected\">" + dr["districtName"] + "</option>");
                else
                    html.Append("<option value = \"" + dr["districtId"] + "\">" + dr["districtName"] + "</option>");
            }
            html.Append("</select>");
            Response.Write(html.ToString());
        }

        private void PopulateLocation()
        {
            var dao = new RemittanceDao();
            var sql = "EXEC proc_zoneDistrictMap @flag = 'll', @districtId = " + dao.FilterString(_pDistrict);
            var dt = dao.ExecuteDataset(sql).Tables[0];
            if (dt == null || dt.Rows.Count == 0)
            {
                Response.Write("<select id=\"location\" class=\"form-control\" onchange=\"PopulateDistrict();\"></select>");
                return;
            }
            var html =
                new StringBuilder("<select id=\"location\" class=\"form-control\" onchange=\"PopulateDistrict();\">");
            html.Append("<option value = \"\">Select</option>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<option value = \"" + dr["locationId"] + "\">" + dr["locationName"] + "</option>");
            }
            html.Append("</select>");
            Response.Write(html.ToString());
        }

        private void LoadServiceChargeTable()
        {
            DataTable dt = send.HoLoadDomesticServiceChargeTable(_pLocation, _amount, _dm, GetStatic.GetUser(), _sBranch, _pBankBranch);

            if (dt == null || dt.Rows.Count == 0)
            {
                Response.Write("Not Available");
                return;
            }

            var html = new StringBuilder();
            html.AppendLine(
                "<table width=\"100%\" class=\"table table-bordered\" border=\"0\" class=\"TBL\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\">");
            html.AppendLine("<tr>");
            html.AppendLine("<th>Amount From</th>");
            html.AppendLine("<th>Amount To</th>");
            html.AppendLine("<th>Percent</th>");
            html.AppendLine("<th>Min</th>");
            html.AppendLine("<th>Max</th>");
            html.AppendLine("</tr>");
            foreach (DataRow dr in dt.Rows)
            {
                html.AppendLine("<tr>");
                html.AppendLine("<td align=\"right\">" + GetStatic.FormatData(dr["fromAmt"].ToString(), "M") + "</td>");
                html.AppendLine("<td align=\"right\">" + GetStatic.FormatData(dr["toAmt"].ToString(), "M") + "</td>");
                html.AppendLine("<td align=\"right\">" + GetStatic.FormatData(dr["pcnt"].ToString(), "M") + "</td>");
                html.AppendLine("<td align=\"right\">" + GetStatic.FormatData(dr["minAmt"].ToString(), "M") + "</td>");
                html.AppendLine("<td align=\"right\">" + GetStatic.FormatData(dr["maxAmt"].ToString(), "M") + "</td>");
                html.AppendLine("</tr>");
            }
            html.AppendLine("</table>");
            Response.Write(html.ToString());
        }

        private void PopulateBranchName()
        {
            var dao = new RemittanceDao();
            var sql = "EXEC proc_agentMaster @flag = 'bbl', @parentId=" + dao.FilterString(_bankId);
            var dt = dao.ExecuteDataset(sql).Tables[0];
            if (dt == null || dt.Rows.Count == 0)
            {
                Response.Write("<select id=\"bankBranch\" style=\"width: 230px;\"></select>");
                return;
            }
            var html = new StringBuilder("<select id=\"bankBranch\" style=\"width: 230px;\" >");
            html.Append("<option value = \"\">Select</option>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<option value = \"" + dr["agentId"] + "\">" + dr["agentName"] + "</option>");
            }
            html.Append("</select>");
            Response.Write(html.ToString());
        }

        private void LoadAvailableAccountBalance()
        {
            DataRow dr = send.HoGetAcDetail(GetStatic.GetUser(), _sBranch);
            if (dr == null)
            {
                Response.Write("1|N/A");
                return;
            }
            Response.Write("0|" + GetStatic.FormatData(dr["availableBal"].ToString(), "M"));
        }

        private void LoadSender()
        {
            DataSet ds = send.GetMember(GetStatic.GetUser(), GetMemId());
            if (ds.Tables.Count > 1)
            {
                var dbResult = send.ParseDbResult(ds.Tables[0]);
                if (dbResult.ErrorCode != "0")
                {
                    Response.Write(dbResult.ErrorCode + "|" + dbResult.Msg + "|" + dbResult.Id);
                    return;
                }
                if (ds.Tables[1].Rows.Count == 0)
                    return;
                var dr = ds.Tables[1].Rows[0];

                Response.Write("0" + "|" +
                                GetMemId() + "|" +
                                dr["firstName"] + "|" +
                                dr["middleName"] + "|" +
                                dr["lastName1"] + "|" +
                                dr["lastName2"] + "|" +
                                dr["address"] + "|" +
                                dr["mobile"] + "|" +
                                dr["idType"] + "|" +
                                dr["idNumber"] + "|" +
                                dr["customerId"]);
            }
        }

        private void LoadReceiver()
        {
            DataSet ds = send.GetMember(GetStatic.GetUser(), GetMemId());
            if (ds.Tables.Count > 1)
            {
                var dbResult = send.ParseDbResult(ds.Tables[0]);
                if (dbResult.ErrorCode != "0")
                {
                    Response.Write(dbResult.ErrorCode + "|" + dbResult.Msg + "|" + dbResult.Id);
                    return;
                }
                if (ds.Tables[1].Rows.Count == 0)
                    return;
                var dr = ds.Tables[1].Rows[0];

                Response.Write("0" + "|" +
                                GetMemId() + "|" +
                                dr["firstName"] + "|" +
                                dr["middleName"] + "|" +
                                dr["lastName1"] + "|" +
                                dr["lastName2"] + "|" +
                                dr["address"] + "|" +
                                dr["mobile"] + "|" +
                                dr["idType"] + "|" +
                                dr["idNumber"] + "|" +
                                dr["customerId"] + "|" +
                                dr["email"]);
            }
        }

        protected void Calculate()
        {
            double _transferAmount = GetStatic.ParseDouble(_amount);
            double _serviceCharge = 0.0;
            double _totalFees = 0.0;
            if (_transferAmount > 0)
            {
                _serviceCharge = GetServiceCharge(_pLocation, _transferAmount.ToString(), "ta");
                if (_serviceCharge < 0)
                {
                    Response.Write("1" + "|" + "Service Charge not defined" + "|" + "");
                    return;
                }
                _totalFees = _transferAmount + _serviceCharge;
                Response.Write("0" + "|" + GetStatic.FormatData(_serviceCharge.ToString(), "M") + "|" + GetStatic.FormatData(_totalFees.ToString(), "M"));
            }
            else
            {
                Response.Write("0||");
            }
        }

        private Double GetServiceCharge(string pLocation, string amount, string mode)
        {
            try
            {
                double _sc = Convert.ToDouble(send.HoGetDomesticServiceCharge(pLocation, amount, _dm, GetStatic.GetUser(), _sBranch, _pBankBranch));
                return _sc;
            }
            catch
            {
                GetStatic.CallBackJs1(Page, "Error", "alert('Something went wrong');");
                return -1;
            }
        }

        protected bool VerifyCollectionAmt()
        {
            return true;
        }

        private void ManageMessage(DbResult dbResult)
        {
            Response.Write(dbResult.ErrorCode + "|" + dbResult.Msg + "|" + dbResult.Id);
        }

        private void SendTran()
        {
            SaveLocalTran();
        }

        private void SaveLocalTran()
        {
            var st = new SendTransactionDao();
            var user = GetStatic.GetUser();
            var randObj = new Random();
            string txnId = randObj.Next(1000000000, 1999999999).ToString();
            var AgentRefId = (_agentRefId == "") ? txnId : _agentRefId;
            var txnDocFolder = GetTxnDocFolder();

            try
            {
                // If exists, move txn related documents to related folder from temp folder.
                MoveTxnDocument();
            }
            catch (Exception ex)
            { }

            var dbResult = st.HoSendTransaction(user, _sBranch, _pDistrict, _pLocation, _ta, _sc, _tc, _ta,
                                                       _dm, "", _pBankBranch, _accountNo, _senderId, _sMemId, _sFirstName, _sMiddleName, _sLastName1,
                                                       _sLastName2, _sAddress, _sContactNo,
                                                       _sIdType, _sIdNo, _sEmail, _receiverId, _rMemId, _rFirstName,
                                                       _rMiddleName, _rLastName1, _rLastName2,
                                                       _rAddress, _rContactNo, _rel, _rIdType, _rIdNo, _payMsg, GetStatic.GetDcInfo(), GetStatic.GetIp(), _sof, _por, _occupation,
                                                        AgentRefId, _complianceAction, _compApproveRemark, _sDOB, _sIdIssuedPlace, _sIdValidDate, _sIdIssuedDate, _sDOBBs, _sIdValidDateBs, _sIdIssuedDateBs,
                                                       _txnBatchId, txnDocFolder, _CustCardId, _sGender, _sMotherFatherName);
            if (dbResult.ErrorCode != "0")
            {
                Response.Write(dbResult.ErrorCode + "|" + dbResult.Msg + "|" + dbResult.Id);
                return;
            }
            ManageMessage(dbResult);
        }

        private string GetTxnDocFolder()
        {
            return DateTime.Now.ToString("ddMMyyyy");
        }

        public bool MoveTxnDocument()
        {
            TxnDocUploadDao obj = new TxnDocUploadDao();

            try
            {
                var dt = obj.GetTxnTempDoc(GetStatic.GetUser(), _txnBatchId);
                if (dt.Rows.Count > 0)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        var root = GetStatic.GetFilePath();
                        string locationToMove = root + "\\TxnDocUpload\\" + GetTxnDocFolder();
                        string fileToCreate = locationToMove + "\\" + dt.Rows[i]["fileName"].ToString();

                        var tmpFileLocation = root + "\\TxnDocUploadTmp\\" + dt.Rows[i]["fileName"].ToString();

                        if (File.Exists(fileToCreate))
                            File.Delete(fileToCreate);

                        if (!Directory.Exists(locationToMove))
                            Directory.CreateDirectory(locationToMove);

                        File.Move(tmpFileLocation, fileToCreate);
                    }
                }
                return true;
            }
            catch (Exception ex)
            {
                return false;
            }
        }
    }
}