using Swift.DAL.net.inficare.kumari;
using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.BL.Helper.ThirdParty.KumariBank
{
    public class KumariBankDao : RemittanceDao
    {
        private readonly KumariBankApi kumariApi = new KumariBankApi();
        public DbResult SelectByPinNo(string user, string branchId, string refNo, string subPartnerId, string flag = "")
        {
            var dr = new DbResult();
            var drApi = kumariApi.SelectByPinNo(user, branchId, refNo, subPartnerId);
            if (!string.IsNullOrEmpty(flag))
            {
                dr.SetError(drApi.CODE, drApi.MESSAGE, null);
                dr.Extra = drApi.PAY_TOKEN_ID;
                return dr;
            }
            else if (drApi.CODE != "0")
            {
                dr.SetError(drApi.CODE, drApi.MESSAGE, "");
                dr.Extra = "0";
                return dr;
            }
            dr = Save(user, branchId, subPartnerId, drApi);
            dr.Extra = "2";

            return dr;
        }

        public Return_TXNStatus GetStatus(string user, string refNo, string status)
        {
            var _result = new Return_TXNStatus();
            var _unlock = new Return_TXNUnLock();
            DbResult _db = SelectByPinNo(user, "", refNo, status);
            string payTokenId = _db.Extra;
            if (!string.IsNullOrEmpty(payTokenId))
            {
                _result = kumariApi.GetStatus(user, refNo, payTokenId);
                //_unlock = TXNUnLock(user, refNo, payTokenId);
            }
            else
            {
                _result.CODE = _db.ErrorCode; //set the code of response as 1 to identify that there is error while getting PAY_TOKEN_ID
                _result.MESSAGE = _db.Msg;
            }
            return _result;
        }

        public Return_TXNUnLock TXNUnLock(string user, string refNo, string payTokenId, string subPartnerId)
        {
            return kumariApi.TXNUnLock(user, refNo, payTokenId, subPartnerId);
        }

        public DbResult PayConfirm(
           string user, string rowId, string refNo, string payTokenId, string sCountry, string pBranch
          , string rIdType, string rIdNumber, string rIdPlaceOfIssue, string rContactNo, string relationType,
            string relativeName, bool isCETxn, string customerId, string membershipId,
            string rBankName, string rBankBranch, string rCheque, string rAccountNo, string topupMobileNo, string dob, string relationship,
            string purposeOfRemittance, string idIssueDate, string idExpiryDate, string branchMapCode, string pAmount, string subPartnerId
      )
        {

            var sql = "EXEC proc_kumariBankPayHistory";
            sql += " @flag = 'readyToPay'";
            sql += ",@user= " + FilterString(user);
            sql += ",@rowId= " + FilterString(rowId);
            sql += ",@pBranch = " + FilterString(pBranch);
            sql += ",@rIdType = " + FilterString(rIdType);
            sql += ",@rIdNumber = " + FilterString(rIdNumber);
            sql += ",@rIdPlaceOfIssue = " + FilterString(rIdPlaceOfIssue);
            sql += ",@rContactNo = " + FilterString(rContactNo);
            sql += ",@relationType = " + FilterString(relationType);
            sql += ",@relativeName = " + FilterString(relativeName);
            sql += ",@customerId = " + FilterString(customerId);
            sql += ",@membershipId = " + FilterString(membershipId);
            sql += ",@rBankName = " + FilterString(rBankName);
            sql += ",@rBankBranch = " + FilterString(rBankBranch);
            sql += ",@rCheque = " + FilterString(rCheque);
            sql += ",@rAccountNo = " + FilterString(rAccountNo);
            sql += ",@topupMobileNo = " + FilterString(topupMobileNo);

            sql += ",@rDob = " + FilterString(dob);
            sql += ",@relationship = " + FilterString(relationship);
            sql += ",@purpose = " + FilterString(purposeOfRemittance);
            sql += ",@rIssuedDate = " + FilterString(idIssueDate);
            sql += ",@rValidDate = " + FilterString(idExpiryDate);

            var dr = ParseDbResult(sql);
            if (dr.ErrorCode != "0")
            {
                return dr;
            }
            else
            {
                dr = kumariApi.PayConfirm(pBranch, payTokenId, refNo, rIdType, rIdNumber, rContactNo, rIdPlaceOfIssue, rBankName, rBankBranch, pAmount, subPartnerId);
            }
            if (dr.ErrorCode != "0")
            {
                sql = " EXEC proc_kumariBankPayHistory";
                sql += "  @flag = 'payError'";
                sql += ", @user= " + FilterString(user);
                sql += ", @rowId= " + FilterString(rowId);
                sql += ", @payResponseCode = " + FilterString(dr.Extra);
                sql += ", @payResponseMsg = " + FilterString(dr.Msg);
                ParseDbResult(sql);
                return dr;
            }

            sql = " EXEC proc_kumariBankPayHistory";
            sql += "  @flag = 'pay'";
            sql += ", @user= " + FilterString(user);
            sql += ", @rowId= " + FilterString(rowId);
            sql += ", @sCountry= " + FilterString(sCountry);
            sql += ", @payResponseCode = " + FilterString(dr.ErrorCode);
            sql += ", @payResponseMsg = " + FilterString(dr.Msg);
            sql += ", @payConfirmationNo = " + FilterString(dr.Extra);
            sql += ", @pCommission = " + FilterString(dr.Extra2);
            sql += ", @sBranchMapCOdeInt=" + FilterString(branchMapCode);

            return ParseDbResult(sql);
        }

        private DbResult Save(string user, string branchId, string subPartnerId, Return_PAYCHECKDetail drApi)
        {
            var sql = "EXEC proc_kumariBankPayHistory";
            sql += " @flag = 'i'";
            sql += ",@user = " + FilterString(user);
            sql += ",@subPartnerId = " + FilterString(subPartnerId);
            sql += ",@pBranch = " + FilterString(branchId);
            sql += ",@payTokenId =" + FilterString(drApi.PAY_TOKEN_ID);
            sql += ",@refNo =" + FilterString(drApi.REFNO);
            sql += ",@BenefName =" + FilterString(drApi.RECEIVER_NAME);
            sql += ",@BenefMobile =" + FilterString(drApi.RECEIVER_MOBILE);
            sql += ",@BenefAddress=" + FilterString(drApi.RECEIVER_ADDRESS);
            sql += ",@benefIdType =" + FilterString(drApi.RECEIVER_ID_TYPE);
            sql += ",@benefIdNo =" + FilterString(drApi.RECEIVER_ID_NUMBER);
            sql += ",@benefCity =" + FilterString(drApi.RECEIVER_CITY);
            sql += ",@benefCountry =" + FilterString(drApi.RECEIVER_COUNTRY);
            sql += ",@senderName =" + FilterString(drApi.SENDER_NAME);
            sql += ",@SenderAddress =" + FilterString(drApi.SENDER_ADDRESS);
            sql += ",@SenderMobile =" + FilterString(drApi.SENDER_MOBILE);
            sql += ",@senderCountry =" + FilterString(drApi.SENDER_COUNTRY);
            sql += ",@senderCity =" + FilterString(drApi.SENDER_CITY);
            sql += ",@remittanceEntryDt =" + FilterString(drApi.TXN_DATE);
            sql += ",@Remarks =" + FilterString(drApi.MESSAGE);
            sql += ",@PCurrency =" + FilterString(drApi.PAYOUT_CURRENCY);
            sql += ",@payemntType=" + FilterString(drApi.PAYMENT_TYPE);
            sql += ",@tranMode=" + FilterString(drApi.TRAN_MODE);
            sql += ",@tranNo=" + FilterString(drApi.TRAN_NO);
            sql += ",@bankName=" + FilterString(drApi.BANKNAME);
            sql += ",@bankBranch=" + FilterString(drApi.BANKBRANCH);
            sql += ",@bankAccNo=" + FilterString(drApi.BANKACCOUNTNO);
            //sql += ",@RemittanceAuthorizedDt =" + FilterString(response.RemittanceAuthorizedDt);
            //sql += ",@RemitType =" + FilterString(drApi.typ);
            sql += ",@amount =" + FilterString(drApi.PAYOUT_AMT);
            //sql += ",@LocalAmount =" + FilterString("0");
            //sql += ",@DollarRate =" + FilterString("0");
            //sql += ",@TPAgentID=" + FilterString(response.TPAgentID);
            //sql += ",@TPAgentName =" + FilterString(response.TPAgentName);

            return ParseDbResult(sql);
        }


        public ReportResult GetReconcileReport(string user, string fromDate, string toDate, string reportType)
        {
            var dtBody = new DataTable();
            var dr = kumariApi.ReconcileReport(user, fromDate, toDate, reportType);
            if (dr != null)
            {
                dtBody.Columns.Add("BRN No");
                dtBody.Columns.Add("Status");
                dtBody.Columns.Add("SendOn");
                dtBody.Columns.Add("Sender");
                dtBody.Columns.Add("Receiver");
                dtBody.Columns.Add("Amount");
                dtBody.Columns.Add("PaidOn");

                
                int count = dr.Length;
                if (count > 0)
                {
                    for (int i = 0; i < count; i++)
                    {
                        var row = dtBody.NewRow();
                        row[0] = dr[i].PINNO;
                        row[1] = dr[i].STATUS;
                        row[2] = dr[i].TRANSACTION_DATE;
                        row[3] = dr[i].SENDER_NAME;
                        row[4] = dr[i].RECEIVER_NAME;
                        row[5] = dr[i].PAYOUT_AMT;
                        row[6] = dr[i].PAID_DATE;
                        dtBody.Rows.Add(row);
                    }
                }
                //int colCount = dr.GetLength(0);
                //string rowCount = (!string.IsNullOrEmpty(dr.GetLength(1).ToString())) ? dr.GetLength(1).ToString() : "0";
                
                //for (int i = 0; i < colCount; i++)
                //{
                    
                //}
            }

            var dtResult = new DataTable();
            dtResult.Columns.Add("ErrorCode");
            dtResult.Columns.Add("Msg");
            dtResult.Columns.Add("Id");
            var row1 = dtResult.NewRow();
            //row1[0] = dr[0].CODE;
            row1[0] = "0";
            row1[1] = dr[0].MESSAGE;
            row1[2] = dr[0].CODE;
            dtResult.Rows.Add(row1);



            var dtFilter = new DataTable();
            dtFilter.Columns.Add("Head");
            dtFilter.Columns.Add("Value");
            row1 = dtFilter.NewRow();
            row1[0] = "From Date";
            row1[1] = fromDate;
            dtFilter.Rows.Add(row1);
            row1 = dtFilter.NewRow();
            row1[0] = "To Date";
            row1[1] = toDate;
            dtFilter.Rows.Add(row1);
            row1 = dtFilter.NewRow();
            row1[0] = "Report Type";
            row1[1] = reportType;
            dtFilter.Rows.Add(row1);

            var dtTitle = new DataTable();
            dtTitle.Columns.Add("Title");
            row1 = dtTitle.NewRow();
            row1[0] = "Reconcile Report Kumari Bank";
            dtTitle.Rows.Add(row1);

            var ds = new DataSet();
            ds.Tables.Add(dtBody);
            ds.Tables.Add(dtResult);
            ds.Tables.Add(dtFilter);
            ds.Tables.Add(dtTitle);

            return ParseReportResult(ds);
        }
    }
}
