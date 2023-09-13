using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.BL.Remit.Transaction.Domestic;
using Swift.DAL.Domain;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Agent.Send.Domestic
{
    public partial class SendV2 : System.Web.UI.Page
    {
        SendTransactionDao _obj = new SendTransactionDao();
        private readonly StaticDataDdl sl = new StaticDataDdl();
        private const string ViewFunctionId = "40101000";
        private const string ProcessFunctionId = "40101010";
        //private readonly CustomerSetupDao cd = new CustomerSetupDao();
        CustomersDao cd = new CustomersDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            sl.CheckSendTransactionAllowedTime();
            LoadAvailableAccountBalance();
            PopulateDdl();
            deliveryMethod.Focus();
            transferAmt.Attributes.Add("onchange", "LoadServiceCharge()");
            deliveryMethod.Attributes.Add("onchange", "ManageDeliveryMethod()");
            bankName.Attributes.Add("onchange", "PopulateBankBranch()");
            sl.CheckSession();
            //txtSendIdValidDate.Attributes.Add("readonly", "true");
            //txtSendDOB.Attributes.Add("readonly", "true");

            GetThresholdAmount();
            if (!IsPostBack)
            {
                //if (!sl.HasRight(EnrollCustomerFunctionId))
                //{
                // chkIssueCustCard.Style.Add("display", "none");
                // }


                #region Ajax methods
                string reqMethod = Request.Form["MethodName"];
                switch (reqMethod)
                {
                    case "sc":
                        Calculate();
                        break;
                    case "SearchCustomer":
                        CustomerSearchLoadData();
                        break;
                    case "LoadImages":
                        LoadImages();
                        break;
                    //case "validate":
                    //    ValidateTransaction();
                    //    break;
                    case "vt":
                        VerifyTransaction();
                        break;
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
                #endregion

                txtSendIdValidDate.Attributes.Add("onchange", "GetADVsBSDate('ad','txtSendIdValidDate')");
                txtSendIdValidDateBs.Attributes.Add("onchange", "GetADVsBSDate('bs','txtSendIdValidDateBs')");

                txtSenIdIssuedDate.Attributes.Add("onchange", "GetADVsBSDate('ad','txtSenIdIssuedDate')");
                txtSenIdIssuedDateBs.Attributes.Add("onchange", "GetADVsBSDate('bs','txtSenIdIssuedDateBs')");

                txtSendDOB.Attributes.Add("onchange", "GetADVsBSDate('ad','txtSendDOB')");
                txtSendDOBBs.Attributes.Add("onchange", "GetADVsBSDate('bs','txtSendDOBBs')");

                hdnTxnBatchId.Value = DateTime.Now.Ticks.ToString();
            }
        }
        protected void Calculate()
        {
            //DataRow dr = _obj.GetAcDetail(GetStatic.GetUser(), GetStatic.GetSettlingAgent());
            //if (dr == null)
            //{
            //    DataTable dt1 = new DataTable();
            //    dt1.Columns.Add("errorCode");
            //    dt1.Columns.Add("msg");
            //    dt1.Columns.Add("id");
            //    var row = dt1.NewRow();

            //    row[0] = "1";
            //    row[1] = "Credit limit not set for sending agent, please contact HO.";
            //    row[2] = "999";
            //    dt1.Rows.Add(row);

            //    Response.ContentType = "text/plain";
            //    string json1 = DataTableToJSON(dt1);
            //    Response.Write(json1);
            //    Response.End();
            //}
            var sBranch = GetStatic.GetBranch();
            var settlingAgent = GetStatic.GetSettlingAgent();
            string pBankBranch = Request.Form["pBankBranch"];
            string pLocation = Request.Form["pLocation"];
            string tAmt = Request.Form["tAmt"];
            string dm = Request.Form["dm"];
            DataTable dt = _obj.GetCalculate(GetStatic.GetUser(), pLocation, tAmt, dm, sBranch, pBankBranch, settlingAgent);
            Response.ContentType = "text/plain";
            string json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }
        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId + "," + ProcessFunctionId);
        }

        private void LoadAvailableAccountBalance()
        {
            DataRow dr = _obj.GetAcDetail(GetStatic.GetUser(), GetStatic.GetSettlingAgent());
            if (dr == null)
            {
                availableAmt.Text = "N/A";
                return;
            }
            availableAmt.Text = GetStatic.FormatData(dr["availableBal"].ToString(), "M");
        }
        private void GetThresholdAmount()
        {
            var drow = _obj.GetThresholdAmount(GetStatic.GetUser(), GetStatic.GetAgent(), "151");
            if (drow == null)
            {
                hdnThresholdAmt.Value = "50000";
                spnThresholdMessage.InnerHtml = "50,000 वा सो भन्दा माथिको कारोबारमा अनिबार्यरुपमा सरकारी मन्यता प्राप्त परिचय पत्र को प्रतिलिपी लिनुका साथै सिस्टममा पनि ID Type तथा ID Number उल्लेख गर्नु होला ।";
                return;
            }
            hdnThresholdAmt.Value = drow["Amount"].ToString().Replace(",", "");
            var thresholdMessage = drow["MessageTxt"].ToString();
            if (thresholdMessage == "")
                thresholdMessage = "50,000 वा सो भन्दा माथिको कारोबारमा अनिबार्यरुपमा सरकारी मन्यता प्राप्त परिचय पत्र को प्रतिलिपी लिनुका साथै सिस्टममा पनि ID Type तथा ID Number उल्लेख गर्नु होला ।";
            spnThresholdMessage.InnerHtml = drow["MessageTxt"].ToString();
        }
        private void PopulateDdl()
        {
            PopulateLocation();
            PopulateDistrict();
            PopulateBankName();
            PopulateSender(null);
            PopulateReceiver(null);
            RelWithSender();
            sl.SetDDL2(ref deliveryMethod, "EXEC proc_serviceTypeMaster @flag='l3'", "typeTitle", "", "");
            sl.SetStaticDdl(ref por, "3800", "", "Select");
            sl.SetStaticDdl(ref sof, "3900", "", "Select");
            sl.SetStaticDdl(ref occupation, "2000", "", "Select");
            sl.SetGenderDDL(ref ddlGender, "", "Select");
            PopulateIDIssuedPlace("");
            //sl.SetDDL3(ref sIdIssuedPlace, "EXEC proc_zoneDistrictMap @flag = 'd'", "districtName", "districtName", "", "Select");
        }
        private void PopulateIDIssuedPlace(string IdType)
        {
            if (IdType == "")
                sl.SetDDL3(ref sIdIssuedPlace, "EXEC proc_IdIssuedPlace ", "valueId", "detailTitle", "", "Select");
            else
                sl.SetDDL3(ref sIdIssuedPlace, "EXEC proc_IdIssuedPlace @idType ='" + IdType + "' ", "valueId", "detailTitle", "", "Select");
        }
        private void PopulateDistrict()
        {
            var dao = new RemittanceDao();
            var sql = "EXEC proc_zoneDistrictMap @flag = 'd'";
            var dt = dao.ExecuteDataset(sql).Tables[0];
            if (dt == null || dt.Rows.Count == 0)
            {
                Response.Write("<select id=\"district\" class=\"form-control1\" style='width:240px' onchange=\"PopulateLocation();\"></select>");
                return;
            }
            var html =
                new StringBuilder("<select id=\"district\" class=\"form-control1\" style='width:240px' onchange=\"PopulateLocation();\">");
            html.Append("<option value = \"\">Select</option>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<option value = \"" + dr["districtId"] + "\">" + dr["districtName"] + "</option>");
            }
            html.Append("</select>");
            divDistrict.InnerHtml = html.ToString();
        }

        private void PopulateLocation()
        {
            var dao = new RemittanceDao();
            var sql = "EXEC proc_zoneDistrictMap @flag = 'll'";
            var dt = dao.ExecuteDataset(sql).Tables[0];
            if (dt == null || dt.Rows.Count == 0)
            {
                Response.Write("<select id=\"location\" class=\"form-control1\" style='width:240px' onchange=\"PopulateDistrict();\"></select>");
                return;
            }
            var html =
                new StringBuilder("<select id=\"location\"  class=\"form-control1\" style='width:240px' onchange=\"PopulateDistrict();\">");
            html.Append("<option value = \"\">Select</option>");
            foreach (DataRow dr in dt.Rows)
            {
                html.Append("<option value = \"" + dr["locationId"] + "\">" + dr["locationName"] + "</option>");
            }
            html.Append("</select>");
            divLocation.InnerHtml = html.ToString();
        }

        private void PopulateSender(DataRow dr)
        {
            sl.SetDDL(ref sIdType, "EXEC proc_countryIdType @flag = 'il-with-et', @countryId='151', @spFlag = '5201'", "valueId", "detailTitle", GetStatic.GetRowData(dr, "idType"), "Select");
        }

        private void PopulateReceiver(DataRow dr)
        {
            sl.SetDDL(ref rIdType, "EXEC proc_countryIdType @flag = 'il', @countryId='151', @spFlag = '5202'", "valueId", "detailTitle", GetStatic.GetRowData(dr, "idType"), "");
        }

        private void RelWithSender()
        {
            sl.SetStaticDdl2(ref relWithSender, "2100", "", "Select");
        }

        private void PopulateBankName()
        {
            sl.SetDDL(ref bankName, "EXEC proc_agentMaster @flag = 'banklist'", "agentId", "agentName", "", "Select");
        }

        private void CustomerSearchLoadData()
        {
            string customerCardNumber = Request.Form["customerCardNumber"];
            string sAmount = Request.Form["sAmount"];
            sAmount = (sAmount == "") ? "0" : sAmount;
            DataTable dt = _obj.GetCustomer(GetStatic.GetUser(), customerCardNumber, hdnThresholdAmt.Value, sAmount);
            Response.ContentType = "text/plain";
            string json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }
        private void LoadImages()
        {
            string customerId = Request.Form["customerId"];
            DataTable dt = _obj.GetCustomerImagesAgent(GetStatic.GetUser(), customerId);
            Response.ContentType = "text/plain";
            string json = DataTableToJSON(dt);
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

        //private void ValidateTransaction()
        //{
        //    string _sBranch = Request.Form["sBranch"];
        //    string _pBankBranch = Request.Form["pBankBranch"];
        //    string _ta = Request.Form["ta"];
        //    string _dm = Request.Form["dm"];
        //    string _senderId = Request.Form["senderId"];
        //    string _sMemId = Request.Form["sMemId"];
        //    string _sFirstName = Request.Form["sFirstName"];
        //    string _sMiddleName = Request.Form["sMiddleName"];
        //    string _sLastName1 = Request.Form["sLastName1"];
        //    string _sLastName2 = Request.Form["sLastName2"];
        //    string _sAddress = Request.Form["sAddress"];
        //    string _sContactNo = Request.Form["sContactNo"];
        //    string _sIdType = Request.Form["sIdType"];
        //    string _sIdNo = Request.Form["sIdNo"];
        //    string _sEmail = Request.Form["sEmail"];
        //    string _receiverId = Request.Form["receiverId"];
        //    string _rMemId = Request.Form["rMemId"];
        //    string _rFirstName = Request.Form["rFirstName"];
        //    string _rMiddleName = Request.Form["rMiddleName"];
        //    string _rLastName1 = Request.Form["rLastName1"];
        //    string _rLastName2 = Request.Form["rLastName2"];
        //    string _rAddress = Request.Form["rAddress"];
        //    string _rContactNo = Request.Form["rContactNo"];
        //    string _rIdType = Request.Form["rIdType"];
        //    string _rIdNo = Request.Form["rIdNo"];
        //    string _rel = Request.Form["rel"];
        //    string _sof = Request.Form["sof"];
        //    string _por = Request.Form["por"];
        //    string _accountNo = Request.Form["accountNo"];
        //    string _occupation = Request.Form["occupation"];
        //    string _sDOB = Request.Form["sDOB"];
        //    string _sIdValidDate = Request.Form["sIdValidDate"];
        //    string _sIdTypeTxt = Request.Form["senIdTypeTxt"];
        //    var st = new SendTransactionDao();
        //    var tran = new TranDetail();

        //    tran.User = GetStatic.GetUser();
        //    tran.SBranch = GetStatic.GetBranch();
        //    tran.SBranchName = GetStatic.GetBranchName();
        //    tran.SAgent = GetStatic.GetAgent();
        //    tran.SAgentName = GetStatic.GetAgentName();
        //    tran.SSuperAgent = GetStatic.GetSuperAgent();
        //    tran.SSuperAgentName = GetStatic.GetSuperAgentName();
        //    tran.SettlingAgent = GetStatic.GetSettlingAgent();
        //    tran.MapCodeInt = GetStatic.GetMapCodeInt();
        //    tran.MapCodeDom = GetStatic.GetMapCodeDom();
        //    tran.PBankBranch = _pBankBranch;

        //    tran.TransferAmt = _ta;
        //    tran.DeliveryMethod = _dm;
        //    tran.SenderId = _senderId;
        //    tran.SMemId = _sMemId;
        //    tran.SFirstName = _sFirstName;
        //    tran.SMiddleName = _sMiddleName;
        //    tran.SLastName1 = _sLastName1;
        //    tran.SLastName2 = _sLastName2;
        //    tran.SAddress = _sAddress;
        //    tran.SContactNo = _sContactNo;
        //    tran.SIDType = _sIdType;
        //    tran.SIDNo = _sIdNo;
        //    tran.SEmail = _sEmail;
        //    tran.ReceiverId = _receiverId;
        //    tran.RMemId = _rMemId;
        //    tran.RFirstName = _rFirstName;
        //    tran.RMiddleName = _rMiddleName;
        //    tran.RLastName1 = _rLastName1;
        //    tran.RLastName2 = _rLastName2;
        //    tran.RAddress = _rAddress;
        //    tran.RContactNo = _rContactNo;
        //    tran.RIDType = _rIdType;
        //    tran.RIDNo = _rIdNo;
        //    tran.RelWithSender = _rel;
        //    tran.SourceOfFund = _sof;
        //    tran.PurposeOfRemit = _por;
        //    tran.Occupation = _occupation;

        //    tran.SDOB = _sDOB;
        //    tran.SIDValidDate = _sIdValidDate;

        //    var ds = st.ValidateTransaction(tran);
        //    var dt = ds.Tables[0];

        //    var errorCode = dt.Rows[0][0].ToString();

        //    if (!errorCode.Equals("0") && ds.Tables.Count > 1)
        //    {
        //        dt = ds.Tables[1];
        //        dt.Columns.Add("errorCode", typeof(string));
        //        if (dt.Rows.Count > 0)
        //        {                    
        //            dt.Rows[0]["errorCode"] = errorCode;
        //        }
        //    }

        //    Response.ContentType = "text/plain";
        //    string json = DataTableToJSON(dt);
        //    Response.Write(json);
        //    Response.End();
        //}
        private void VerifyTransaction()
        {
            string _sBranch = Request.Form["sBranch"];
            string _pDistrict = Request.Form["pDistrict"];
            string _pLocation = Request.Form["pLocation"];
            string _ta = Request.Form["ta"];
            string _tc = Request.Form["tc"];
            string _sc = Request.Form["sc"];
            string _dm = Request.Form["dm"];
            string _senderId = Request.Form["senderId"];
            string _sMemId = Request.Form["sMemId"];
            string _sFirstName = Request.Form["sFirstName"];
            string _sMiddleName = Request.Form["sMiddleName"];
            string _sLastName1 = Request.Form["sLastName1"];
            string _sLastName2 = Request.Form["sLastName2"];
            string _sAddress = Request.Form["sAddress"];
            string _sContactNo = Request.Form["sContactNo"];
            string _sEmail = Request.Form["sEmail"];
            string _receiverId = Request.Form["receiverId"];
            string _rMemId = Request.Form["rMemId"];
            string _rFirstName = Request.Form["rFirstName"];
            string _rMiddleName = Request.Form["rMiddleName"];
            string _rLastName1 = Request.Form["rLastName1"];
            string _rLastName2 = Request.Form["rLastName2"];
            string _rAddress = Request.Form["rAddress"];
            string _rContactNo = Request.Form["rContactNo"];
            string _rIdType = Request.Form["rIdType"];
            string _rIdNo = Request.Form["rIdNo"];
            string _payMsg = Request.Form["payMsg"];
            string _txtPass = Request.Form["txtPass"];
            string _amount = Request.Form["amount"];
            string _bankId = Request.Form["bankId"];
            string _pBankBranch = Request.Form["pBankBranch"];
            string _accountNo = Request.Form["accountNo"];
            string _topupMobileNo = Request.Form["topupMobileNo"];
            string _sIdTypeTxt = Request.Form["senIdTypeTxt"];

            string _sIdType = Request.Form["sIdType"];
            string _sIdNo = Request.Form["sIdNo"];
            string _sof = Request.Form["sof"];
            string _por = Request.Form["por"];
            string _occupation = Request.Form["occupation"];
            string _sDOB = Request.Form["sDOB"];
            string _sIdValidDate = Request.Form["sIdValidDate"];
            string _rel = Request.Form["rel"];
            string _sIdIssuedPlace = Request.Form["sIdIssuedPlace"];
            var st = new SendTransactionDao();
            var tran = new TranDetail();
            var randObj = new Random();
            //string txnId = randObj.Next(1000000000, 1999999999).ToString();

            var agentRefId = "";
            if (hdnAgentRefId.Value == "")
            {
                agentRefId = Guid.NewGuid().ToString();
                agentRefId = agentRefId.Substring(0, 18);
            }
            else
            {
                hdnAgentRefId.Value = agentRefId;
            }
            tran.AgentRefId = agentRefId;

            tran.User = GetStatic.GetUser();
            tran.SBranch = GetStatic.GetBranch();
            tran.SBranchName = GetStatic.GetBranchName();
            tran.SAgent = GetStatic.GetAgent();
            tran.SAgentName = GetStatic.GetAgentName();
            tran.SSuperAgent = GetStatic.GetSuperAgent();
            tran.SSuperAgentName = GetStatic.GetSuperAgentName();
            tran.SettlingAgent = GetStatic.GetSettlingAgent();
            tran.MapCodeInt = GetStatic.GetMapCodeInt();
            tran.MapCodeDom = GetStatic.GetMapCodeDom();
            tran.PBankBranch = _pBankBranch;
            tran.AccountNo = _accountNo;
            tran.PLocation = _pLocation;
            tran.TransferAmt = _ta;
            tran.ServiceCharge = _sc;
            tran.TotalCollection = _tc;
            tran.PayoutAmt = _ta;
            tran.DeliveryMethod = _dm;
            tran.SenderId = _senderId;
            tran.SMemId = _sMemId;
            tran.SFirstName = _sFirstName;
            tran.SMiddleName = _sMiddleName;
            tran.SLastName1 = _sLastName1;
            tran.SLastName2 = _sLastName2;
            tran.SAddress = _sAddress;
            tran.SContactNo = _sContactNo;
            tran.SEmail = _sEmail;
            tran.ReceiverId = _receiverId;
            tran.RMemId = _rMemId;
            tran.RFirstName = _rFirstName;
            tran.RMiddleName = _rMiddleName;
            tran.RLastName1 = _rLastName1;
            tran.RLastName2 = _rLastName2;
            tran.RAddress = _rAddress;
            tran.RContactNo = _rContactNo;
            tran.RIDType = _rIdType;
            tran.RIDNo = _rIdNo;

            tran.PayoutMsg = _payMsg;
            tran.txtPass = _txtPass;
            tran.DcInfo = GetStatic.GetDcInfo();
            tran.IpAddress = GetStatic.GetIp();
            tran.TopupMobileNo = _topupMobileNo;

            tran.SIDType = _sIdType;
            tran.SIDNo = _sIdNo;
            tran.SourceOfFund = _sof;
            tran.PurposeOfRemit = _por;
            tran.Occupation = _occupation;
            tran.SDOB = _sDOB;
            tran.SIDValidDate = _sIdValidDate;
            tran.RelWithSender = _rel;
            tran.sAmountThreshold = hdnThresholdAmt.Value;
            tran.SIDIssuedPlace = _sIdIssuedPlace;
            //var dbResult = st.SendTranV2(GetStatic.GetUser(), tran, GetStatic.GetFromSendTrnTime(), GetStatic.GetToSendTrnTime());

            var ds = st.VerifyTransaction(tran);
            var dt = ds.Tables[0];

            if (dt.Rows[0]["vtype"].ToString() != "compliance")
            {
                var errorCode = dt.Rows[0][0].ToString();
                var vtype = dt.Rows[0]["vtype"].ToString();
                if (!errorCode.Equals("0") && ds.Tables.Count > 1)
                {
                    dt = ds.Tables[1];
                    dt.Columns.Add("errorCode", typeof(string));
                    dt.Columns.Add("vtype", typeof(string));
                    if (dt.Rows.Count > 0)
                    {
                        dt.Rows[0]["errorCode"] = errorCode;
                        dt.Rows[0]["vtype"] = vtype;
                    }
                }

            }
            else
            {
                dt.Columns.Add("multipleTxn", typeof(string));

                if (dt.Rows[0]["errorCode"].ToString() == "0")
                {
                    var html = new StringBuilder();
                    var dt1 = ds.Tables[1];
                    if (dt1.Rows.Count > 0)
                    {
                        var totalAmt = 0.0;
                        html.Append("<div class='panel panel-default margin-b-30'>");
                        html.Append("<div class='panel-heading'>Warning</div>");
                        html.Append("<div class='panel-body'>");
                        html.Append("<table class='TBLData table table-condensed table-bordered'  cellspacing=0 cellpadding=\"3\">");
                        html.Append("<td colspan=\"6\" style=\"color: red; font-weight: bold; font-family: verdana;\">");
                        html.Append("WARNING!! Previous transaction found with same name");
                        html.Append("</td>");

                        html.Append("<tr>");
                        html.Append("<th>Tran No.</th>");
                        html.Append("<th>Sender Name</th>");
                        html.Append("<th>Sender Id Type</th>");
                        html.Append("<th>Sender Id No.</th>");
                        html.Append("<th>Amount</th>");
                        html.Append("</tr>");

                        foreach (DataRow dr in dt1.Rows)
                        {
                            html.Append("<tr style=\"background-color: #F9CCCC;\">");
                            html.Append("<td>" + dr["tranId"] + "</td>");
                            html.Append("<td>" + dr["senderName"] + "</td>");
                            html.Append("<td>" + dr["sIdType"] + "</td>");
                            html.Append("<td>" + dr["sIdNo"] + "</td>");
                            html.Append("<td style=\"text-align: right;\">" + GetStatic.ShowDecimal(dr["pAmt"].ToString()) + "</td>");

                            html.Append("</tr>");
                            totalAmt += Convert.ToDouble(dr["pAmt"]);
                        }
                        html.Append("<tr>");
                        html.Append("<td>Current</td>");
                        html.Append("<td>" + GetStatic.GetFullName(_sFirstName, _sMiddleName, _sLastName1, _sLastName2) + "</td>");
                        html.Append("<td>" + _sIdTypeTxt + "</td>");
                        html.Append("<td>" + _sIdNo + "</td>");
                        html.Append("<td style=\"text-align: right;\">" + GetStatic.ShowDecimal(_ta.ToString()) + "</td>");

                        html.Append("</tr>");
                        totalAmt += Convert.ToDouble(_ta);

                        html.Append("<tr>");
                        html.Append("<td colspan=\"4\" style=\"text-align: right;\"><b>Total</b></td>");
                        html.Append("<td style=\"text-align: right;\"><b>" + GetStatic.ShowDecimal(totalAmt.ToString()) + "</b></td>");
                        html.Append("</tr>");
                        html.Append("</table>");
                        html.Append("</div>");
                        html.Append("</div>");
                    }

                    var dt2 = ds.Tables[2];
                    if (dt2.Rows.Count > 0)
                    {
                        var totalAmt = 0.0;

                        html.Append("<div class='panel panel-default margin-b-30'>");
                        html.Append("<div class='panel-heading'>Warning</div>");
                        html.Append("<div class='panel-body'>");
                        html.Append("<table class='TBLData table table-condensed table-bordered' border=\"1\" cellspacing=\"0\" cellpadding=\"3\">");
                        html.Append("<td colspan=\"6\" style=\"color: red; font-weight: bold; font-family: verdana;\">WARNING!! Previous transaction found with same ID Detail</td>");

                        html.Append("<tr>");
                        html.Append("<th>Tran No.</th>");
                        html.Append("<th>Sender Name</th>");
                        html.Append("<th>Sender Id Type</th>");
                        html.Append("<th>Sender Id No.</th>");
                        html.Append("<th>Amount</th>");
                        html.Append("</tr>");

                        foreach (DataRow dr in dt2.Rows)
                        {
                            html.Append("<tr style=\"background-color: #F9CCCC;\">");
                            html.Append("<td>" + dr["tranId"] + "</td>");
                            html.Append("<td>" + dr["senderName"] + "</td>");
                            html.Append("<td>" + dr["sIdType"] + "</td>");
                            html.Append("<td>" + dr["sIdNo"] + "</td>");
                            html.Append("<td style=\"text-align: right;\">" + GetStatic.ShowDecimal(dr["pAmt"].ToString()) + "</td>");

                            html.Append("</tr>");
                            totalAmt += Convert.ToDouble(dr["pAmt"]);
                        }
                        html.Append("<tr>");
                        html.Append("<td>Current</td>");
                        html.Append("<td>" + GetStatic.GetFullName(_sFirstName, _sMiddleName, _sLastName1, _sLastName2) + "</td>");
                        html.Append("<td>" + _sIdTypeTxt + "</td>");
                        html.Append("<td>" + _sIdNo + "</td>");
                        html.Append("<td style=\"text-align: right;\">" + GetStatic.ShowDecimal(_ta.ToString()) + "</td>");

                        html.Append("</tr>");
                        totalAmt += Convert.ToDouble(_ta);

                        html.Append("<tr>");
                        html.Append("<td colspan=\"4\" style=\"text-align: right;\"><b>Total</b></td>");
                        html.Append("<td style=\"text-align: right;\"><b>" + GetStatic.ShowDecimal(totalAmt.ToString()) + "</b></td>");
                        html.Append("</tr>");
                        html.Append("</table>");
                        html.Append("</div>");
                        html.Append("</div>");
                    }

                    dt.Rows[0]["multipleTxn"] = html.ToString();
                }
                else
                {
                    dt.Rows[0]["multipleTxn"] = "";
                }
            }
            dt.Columns.Add("agentRefId", typeof(string));
            dt.Rows[0]["agentRefId"] = agentRefId;

            Response.ContentType = "text/plain";
            string json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }

        private void IssueCustCard()
        {
            string sMemId = Request.Form["sMemId"];
            string firstName = Request.Form["sFirstName"];
            string middleName = Request.Form["sMiddleName"];
            string lastName = Request.Form["sLastName1"];
            string lastName1 = Request.Form["sLastName2"];
            string idType = Request.Form["sIdType"];
            string idNo = Request.Form["sIdNo"];
            string validDate = Request.Form["sIdValidDate"];
            string dob = Request.Form["sDOB"];
            string telNo = "";
            string mobile = Request.Form["sContactNo"];
            string city = "";
            string postalCode = "";
            string companyName = "";
            string address1 = Request.Form["sAddress"];
            string address2 = "";
            string nativeCountry = "";
            string email = Request.Form["sEmail"];
            string gender = Request.Form["sGender"];
            string salary = "";
            string memberId = Request.Form["sMemId"];
            string occupation = Request.Form["occupation"];
            string id = Request.Form["custId"];
            string idIssuedDate = Request.Form["sIdIssuedDate"];
            string idIssuedPlace = Request.Form["sIdIssuedPlace"];
            string fatherMotherName = Request.Form["motherFatherName"];

            string idIssuedDateBs = Request.Form["sIdIssuedDateBs"];
            string dobBs = Request.Form["sDOBBs"];
            string validDateBs = Request.Form["sIdValidDateBs"];

            var isMemberIssue = "Y";


            DataTable dt = new DataTable();
            dt.Columns.Add("errorCode");
            dt.Columns.Add("msg");
            dt.Columns.Add("id");



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
                            fatherMotherName,
                            fatherMotherName,
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