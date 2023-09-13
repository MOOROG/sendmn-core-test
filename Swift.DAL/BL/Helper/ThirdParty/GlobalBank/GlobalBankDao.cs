using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.BL.Helper.ThirdParty.GlobalBank
{
    public class GlobalBankDao : RemittanceDao
    {
        private readonly GlobalBankApi gblApi = new GlobalBankApi();

        public DbResult GetStatus(string user, string radNo)
        {
            return gblApi.GetStatus(user, radNo);
        }

        public DbResult SelectByPinNo(string user, string branchId, string radNo, out GlobalPayTransactionResponse response)
        {
            var drApi = gblApi.SelectByPinNo(user, radNo, out response);

            if (!drApi.ErrorCode.Equals("0"))
                return drApi;

            var dr = Save(user, branchId, response);
            dr.Extra = "0";

            return dr;
        }

        public DbResult SelectByPinNoCashExpress(string user, string branchId, string radNo, out GlobalPayTransactionResponse response)
        {
            var drApi = gblApi.SelectByPinNoCashExpress(user, radNo, out response);

            if (!drApi.ErrorCode.Equals("0"))
                return drApi;

            var dr = Save(user, branchId, response);
            dr.Extra = "1";
            return dr;
        }


        public DbResult PayConfirm(
           string user, string rowId, string radNo, string tokenId, string sCountry, string pBranch
          , string rIdType, string rIdNumber, string rIdPlaceOfIssue, string rContactNo, string relationType,
            string relativeName, bool isCETxn, string customerId, string membershipId,
            string rBankName, string rBankBranch, string rCheque, string rAccountNo, string topupMobileNo, string dob, string relationship,
            string purposeOfRemittance, string idIssueDate, string idExpiryDate, string branchMapCode
      )
        {

            var sql = "EXEC proc_globalBankPayHistory";
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

            if (isCETxn)
            {
                dr = gblApi.PayConfirmCashExpress(user, radNo, tokenId, dr.Extra, rIdType, rIdNumber, rContactNo, dr.Id);
            }
            else
            {
                dr = gblApi.PayConfirm(user, tokenId, radNo,rIdType,rIdNumber);
            }
            if (dr.ErrorCode != "0")
            {
                sql = " EXEC proc_globalBankPayHistory";
                sql += "  @flag = 'payError'";
                sql += ", @user= " + FilterString(user);
                sql += ", @rowId= " + FilterString(rowId);
                sql += ", @payResponseCode = " + FilterString(dr.Extra);
                sql += ", @payResponseMsg = " + FilterString(dr.Msg);
                ParseDbResult(sql);
                return dr;
            }

            sql = " EXEC proc_globalBankPayHistory";
            sql += "  @flag = 'pay'";
            sql += ", @user= " + FilterString(user);
            sql += ", @rowId= " + FilterString(rowId);
            sql += ", @sCountry= " + FilterString(sCountry);
            sql += ", @payResponseCode = " + FilterString(dr.Extra);
            sql += ", @payResponseMsg = " + FilterString(dr.Msg);
            sql += ", @payConfirmationNo = " + FilterString(dr.Extra2);
            sql += ", @sBranchMapCOdeInt=" + FilterString(branchMapCode);

            return ParseDbResult(sql);
        }

        public DbResult RestoreTransaction(string pBranch, string pBranchName, string user, string rowId, string branchMapCode)
        {
            var sql = "EXEC proc_globalBankPayHistory @flag='restore'";
            sql += ", @user=" + FilterString(user);
            sql += ", @pBranch=" + FilterString(pBranch);
            sql += ", @rowId=" + FilterString(rowId);
            sql += ", @pBranchName=" + FilterString(pBranchName);
            sql += ", @sBranchMapCOdeInt=" + FilterString(branchMapCode);

            return ParseDbResult(sql);
        }

        public DataRow GetTxnDetail(string user, string rowId)
        {
            var sql = "EXEC proc_globalBankPayHistory @flag='a'";
            sql += ",@rowId = " + FilterString(rowId);
            sql += ",@user = " + FilterString(user);
            return ExecuteDataRow(sql);
        }

        public ReportResult GetReconcileReport(string user, string date)
        {
            var dtBody = new DataTable();
            var dr = gblApi.GetReconcileReport(user, date, out dtBody);

            var dtResult = new DataTable();
            dtResult.Columns.Add("ErrorCode");
            dtResult.Columns.Add("Msg");
            dtResult.Columns.Add("Id");
            var row = dtResult.NewRow();
            row[0] = dr.ErrorCode;
            row[1] = dr.Msg;
            row[2] = dr.Id;
            dtResult.Rows.Add(row);



            var dtFilter = new DataTable();
            dtFilter.Columns.Add("Head");
            dtFilter.Columns.Add("Value");
            row = dtFilter.NewRow();
            row[0] = "Date";
            row[1] = date;
            dtFilter.Rows.Add(row);

            var dtTitle = new DataTable();
            dtTitle.Columns.Add("Title");
            row = dtTitle.NewRow();
            row[0] = "Reconcile Report Global Bank";
            dtTitle.Rows.Add(row);

            var ds = new DataSet();
            ds.Tables.Add(dtBody);
            ds.Tables.Add(dtResult);
            ds.Tables.Add(dtFilter);
            ds.Tables.Add(dtTitle);

            return ParseReportResult(ds);
        }

        #region Helper
        private DbResult Save(string user, string branchId, GlobalPayTransactionResponse response)
        {
            var sql = "EXEC proc_globalBankPayHistory";
            sql += " @flag = 'i'";
            sql += ",@user = " + FilterString(user);
            sql += ",@pBranch = " + FilterString(branchId);
            sql += ",@TokenId =" + FilterString(response.TokenId);
            sql += ",@RadNo =" + FilterString(response.RadNo);
            sql += ",@BenefName =" + FilterString(response.BenefName);
            sql += ",@BenefTel =" + FilterString(response.BenefTel);
            sql += ",@BenefMobile =" + FilterString(response.BenefMobile);
            sql += ",@BenefAddress=" + FilterString(response.BenefAddress);
            sql += ",@BenefAccIdNo=" + FilterString(response.BenefAccIdNo);
            sql += ",@BenefIdType =" + FilterString(response.BenefIdType);
            sql += ",@SenderName =" + FilterString(response.SenderName);
            sql += ",@SenderAddress =" + FilterString(response.SenderAddress);
            sql += ",@SenderTel =" + FilterString(response.SenderTel);
            sql += ",@SenderMobile =" + FilterString(response.SenderMobile);
            sql += ",@SenderIdType =" + FilterString(response.SenderIdType);
            sql += ",@SenderIdNo =" + FilterString(response.SenderIdNo);
            sql += ",@RemittanceEntryDt =" + FilterString(response.RemittanceEntryDt);
            sql += ",@RemittanceAuthorizedDt =" + FilterString(response.RemittanceAuthorizedDt);
            sql += ",@Remarks =" + FilterString(response.Remarks);
            sql += ",@RemitType =" + FilterString(response.RemitType);
            sql += ",@RCurrency =" + FilterString(response.RCurrency);
            sql += ",@PCurrency =" + FilterString(response.PCurrency);
            sql += ",@PCommission=" + FilterString(response.PCommission);
            sql += ",@Amount =" + FilterString(response.Amount);
            sql += ",@LocalAmount =" + FilterString(response.LocalAmount);
            sql += ",@ExchangeRate=" + FilterString(response.ExchangeRate);
            sql += ",@DollarRate =" + FilterString(response.DollarRate);
            sql += ",@TPAgentID=" + FilterString(response.TPAgentID);
            sql += ",@TPAgentName =" + FilterString(response.TPAgentName);
            
            return ParseDbResult(sql);
        }
        #endregion
    }
}