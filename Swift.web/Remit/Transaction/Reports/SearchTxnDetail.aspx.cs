using Newtonsoft.Json;
using Org.BouncyCastle.Bcpg;
using Swift.API.Common;
using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace Swift.web.Remit.Transaction.Reports {
    public partial class SearchTxnDetail : System.Web.UI.Page {
        private TranViewDao at = new TranViewDao();
        private const string ViewFunctionId = "2020100";
        private const string ModifyFunctionId = "2020110";
        private const string ApproveSingleFunctionId = "2020120";
        private const string ApproveMultipleFunctionId = "2020130";
        private const string RejectFuntionId = "2020140";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e) {
            if (!IsPostBack) {
                Authenticate();
                LoadDdl();
            }
            GetStatic.ResizeFrame(Page);
        }

        private string GetCountry() {
            return GetStatic.ReadQueryString("country", "");
        }

        private void LoadDdl() {

            var sql = "EXEC proc_dropDownLists @flag = 'txn-detail-agent'";
            _sdd.SetDDL(ref sAgent, sql, "agentId", "agentName", "", "Select");
        }

        private void LoadDetailGrid() {
            //var ds = at.SelectTransactionDetail(GetStatic.GetUser(), sAgent.SelectedItem.Text, tranNo.Text);

            var sb = new StringBuilder();
            var sbHead = new StringBuilder();
            int rows = 0;
            sbHead.Append("<table class = 'table table-responsive table-striped table-bordered center' >");
            sb.Append("<tr>");
            sb.Append("<th>Msj</th>");
            sb.Append("<th>Super Agent</th>");
            sb.Append("<th>Control No</th>");
            sb.Append("<th>Ref No</th>");
            sb.Append("<th>Date</th>");
            sb.Append("<th>Status</th>");
            sb.Append("</tr>");

            GetTranDtl getTran = new GetTranDtl(){
                controlNo = tranNo.Text,
                superAgent = sAgent.SelectedItem.Value
             };

            using (var client = RestApiClient.CallThirdParty()) {
                JsonResponse jsonResponse = new JsonResponse();
                var obj = JsonConvert.SerializeObject(getTran);
                var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
                try {
                    var URL = "api/v1/TP/GetTranDtlCore";

                    HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
                    var resultData = resp.Content.ReadAsStringAsync().Result;
                    if (resp.IsSuccessStatusCode) {
                        rows = 1;
                        var result = JsonConvert.DeserializeObject<JsonResponse>(resultData);
                        var dt = JsonConvert.DeserializeObject<TranDtlRes>(result.Data.ToString());
                        sb.Append("<td>" + dt.msj + "</td>");
                        sb.Append("<td>" + dt.superAgent + " </td>");
                        sb.Append("<td>" + dt.controlNo  + "</td>");
                        sb.Append("<td>" + dt.refNo + "</td>");
                        sb.Append("<td>" + dt.date + "</td>");
                        sb.Append("<td>" + dt.status  + "</td>");
                        sb.Append("</td>");

                    }
                } catch (Exception ex) {
                    
                }
            }

            sbHead.Append("<tr><td colspan='3' id='appCnt' nowrap='nowrap'>");
            sbHead.Append("<b>" + rows + "  Transaction(s) found : <b>Transaction Detail List</b> </b></td>");
            sbHead.Append("</tr>");
            sbHead.Append(sb.ToString());
            sbHead.Append("</table>");
            rptGrid.InnerHtml = sbHead.ToString();


            selfTxn.Visible = false;
            GetStatic.ResizeFrame(Page);
        }

        private void Authenticate() {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSearch_Click(object sender, EventArgs e) {
            LoadDetailGrid();
        }

        protected void sAgent_Change(object sender, EventArgs e) {
            LoadBalance();
        }

        private void LoadBalance() {
            //var ds = at.SelectTransactionDetail(GetStatic.GetUser(), sAgent.SelectedItem.Text, tranNo.Text);

            var sb = new StringBuilder();
            var sbHead = new StringBuilder();

            GetTranDtl getTran = new GetTranDtl() {
                controlNo = tranNo.Text,
                superAgent = sAgent.SelectedItem.Value
            };

            using (var client = RestApiClient.CallThirdParty()) {
                JsonResponse jsonResponse = new JsonResponse();
                var obj = JsonConvert.SerializeObject(getTran);
                var jbdContent = new StringContent(obj.ToString(), Encoding.UTF8, "application/json");
                try {
                    var URL = "api/v1/TP/GetPartBalance";

                    HttpResponseMessage resp = client.PostAsync(URL, jbdContent).Result;
                    var resultData = resp.Content.ReadAsStringAsync().Result;
                    if (resp.IsSuccessStatusCode) {
                        var result = JsonConvert.DeserializeObject<JsonResponse>(resultData);
                        var dt = JsonConvert.DeserializeObject<BalanceRes>(result.Data.ToString());
                        balance.Text = dt.balance;

                    }
                } catch (Exception ex) {

                }
            }

            //sbHead.Append(sb.ToString());

            


            selfTxn.Visible = false;
            GetStatic.ResizeFrame(Page);
        }

        //protected void btnApproveAll_Click(object sender, EventArgs e)
        //{
        //    var dr = ApproveAllTxn();
        //    GetStatic.PrintMessage(Page, dr);
        //    if (dr.ErrorCode.Equals("0"))
        //    {
        //        LoadApproveGrid("");
        //        LoadHoldSummary();

        //         SendApprovalMailToCustomers();
        //    }
        //}

        //private DbResult ApproveAllTxn()
        //{
        //    var idList = GetStatic.ReadFormData("rowId", "");

        //    if (string.IsNullOrWhiteSpace(idList))
        //    {
        //        var dr = new DbResult();
        //        dr.SetError("1", "Please select one or more transaction approve", "");
        //        return dr;
        //    }
        //    return at.ApproveAllHoldedTXN(GetStatic.GetUser(), idList);
        //}

        private void ApproveTxn() {
            //DbResult dbResult = at.ApproveHoldedTXN(GetStatic.GetUser(), hddTranNo.Value);
            ////SendApprovalMailToCustomers();

            //if (dbResult.ErrorCode == "0")
            //{
            //    LoadApproveGrid("");
            //    //LoadHoldSummary();
            //    GetStatic.PrintMessage(Page, dbResult);
            //    return;
            //}
            //else if (dbResult.ErrorCode == "11")
            //{
            //    string url = "../NewReceiptIRH.aspx?printType=&controlNo=" + dbResult.Id;
            //    Response.Redirect(url);
            //}
            //else
            //{
            //    GetStatic.PrintMessage(Page, dbResult);
            //    return;
            //}
        }

        protected void btnApprove_Click(object sender, EventArgs e) {
            ApproveTxn();
        }


        protected void testBtn_Click(object sender, EventArgs e) {
            SendTransactionServices _tpSend = new SendTransactionServices();
            var result = _tpSend.SendHoldlimitTransaction(GetStatic.GetUser(), hddTranNo.Value);
            GetStatic.PrintMessage(Page, result.ResponseCode, result.Msg);
            return;
        }

        public class GetTranDtl {
            public string superAgent { get; set; }
            public string controlNo { get; set; }
            public string methodName { get; set; }
        }

        public class TranDtlRes {
            public string superAgent { get; set; }
            public string controlNo { get; set; }
            public string refNo { get; set; }
            public string status { get; set; }
            public string date { get; set; }
            public string msj { get; set; }
        }

        public class BalanceRes {
            public string superAgent { get; set; }
            public string balance { get; set; }
            public string status { get; set; }
            public string msj { get; set; }
        }

    }
}