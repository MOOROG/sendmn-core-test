using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.Compliance
{
    public class ErroneousTrnPay : RemittanceDao
    {
        public DbResult Cancel(string user, string rowId, string remarks)
        {
            string sql = "EXEC proc_errPaidTran ";
            sql += "  @flag = 'cancel'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @narration = " + FilterString(remarks);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Update(string user, string rowId, string tranId, string pMsg, string branchId, string controlNo)
        {
            string sql = "EXEC proc_errPaidTran ";
            sql += " @flag = " + (rowId == "0" || rowId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @narration = " + FilterString(pMsg);
            sql += ", @newPBranch = " + FilterString(branchId);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string rowId)
        {
            string sql = "EXEC proc_errPaidTran";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string rowId)
        {
            string sql = "EXEC proc_errPaidTran";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string rowId)
        {
            string sql = "EXEC proc_errPaidTran";
            sql += " @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string rowId)
        {
            string sql = "EXEC proc_errPaidTran";
            sql += " @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SearchValidTran(string user, string controlNo)
        {
            string sql = "EXEC proc_errPaidTran";
            sql += " @flag = 'PAY'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SearchValidTranPay(string user, string controlNo, string agentId)
        {
            string sql = "EXEC proc_payOrderTran";
            sql += " @flag = 'payOrder'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult TransactionPay(string user
                                , string rowId
                                , string controlNo
                                , string idType
                                , string idNumber
                                , string placeOfIssue
                                , string mobileNo
                                , string relativeType
                                , string relativeName
                                , string agentId
                                , string newDeliveryMethod
                                , string remarks)
        {
            string sql = "EXEC [proc_errPaidTran]";
            sql += "  @flag = 'payUpdate'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @rIdType = " + FilterString(idType);
            sql += ", @rIdNo = " + FilterString(idNumber);
            sql += ", @placeOfIssue = " + FilterString(placeOfIssue);
            sql += ", @mobileNo = " + FilterString(mobileNo);
            sql += ", @rRelativeType = " + FilterString(relativeType);
            sql += ", @rRelativeName = " + FilterString(relativeName);
            sql += ", @newPBranch = " + FilterString(agentId);
            sql += ", @newDeliveryMethod = " + FilterString(newDeliveryMethod);
            sql += ", @payRemarks = " + FilterString(remarks);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult SearchPaidTxn(string user, string controlNo)
        {
            string sql = "EXEC [proc_errPaidTran] @flag = 'c'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow UpdatePayOrderApi(string user, string id, string newPBranch, string newDeliveryMethod)
        {
            string sql = "EXEC [proc_errPaidTranAPI] @flag = 'p'";
            sql += ",@user = " + FilterString(user);
            sql += ",@id = " + FilterString(id);
            sql += ", @newPBranch = " + FilterString(newPBranch);
            sql += ", @newDeliveryMethod = " + FilterString(newDeliveryMethod);

            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}