using System.Data;
using log4net;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Transaction
{
    public class ModifyTransactionDao : RemittanceDao {
    public DbResult Update(string user
                              , string tranId
                              , string customerId
                              , string senderId
                              , string membershipId
                              , string firstName
                              , string middleName
                              , string lastName1
                              , string lastName2
                              , string country
                              , string address
                              , string state
                              , string zipCode
                              , string district
                              , string city
                              , string email
                              , string homePhone
                              , string workPhone
                              , string mobile
                              , string nativeCountry
                              , string dob
                              , string occupation
                              , string customerType
                              , string isBlackListed
                              , string srFlag)
        {
            string sql = "EXEC proc_modifyTran";
            sql += "  @flag = " + (customerId == "0" || customerId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @senderId = " + FilterString(senderId);
            sql += ", @membershipId = " + FilterString(membershipId);
            sql += ", @firstName = " + FilterString(firstName);
            sql += ", @middleName = " + FilterString(middleName);
            sql += ", @lastName1 = " + FilterString(lastName1);
            sql += ", @lastName2 = " + FilterString(lastName2);
            sql += ", @country = " + FilterString(country);
            sql += ", @address = " + FilterString(address);
            sql += ", @state = " + FilterString(state);
            sql += ", @zipCode = " + FilterString(zipCode);
            sql += ", @district = " + FilterString(district);
            sql += ", @city = " + FilterString(city);
            sql += ", @email = " + FilterString(email);
            sql += ", @homePhone = " + FilterString(homePhone);
            sql += ", @workPhone = " + FilterString(workPhone);
            sql += ", @mobile = " + FilterString(mobile);
            sql += ", @nativeCountry = " + FilterString(nativeCountry);
            sql += ", @dob = " + FilterString(dob);
            sql += ", @occupation = " + FilterString(occupation);
            sql += ", @customerType = " + FilterString(customerType);
            sql += ", @isBlackListed = " + FilterString(isBlackListed);
            sql += ", @srFlag = " + FilterString(srFlag);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataTable GetTranLog(string user, string tranId)
        {
            string sql = "EXEC proc_modifyTran";
            sql += "  @flag = 'log'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DbResult ChangeCustomer(string user, string customerId, string oldCustomerId, string tranId,
                                       string srFlag)
        {
            string sql = "EXEC proc_modifyTran";
            sql += "  @flag = 'cc'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @oldCustomerId = " + FilterString(oldCustomerId);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @srFlag = " + FilterString(srFlag);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult ChangePayoutLocation(string user, string tranId, string pSuperAgent, string pCountry,
                                             string pState, string pDistrict)
        {
            string sql = "EXEC proc_modifyTran";
            sql += "  @flag = 'ca'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @pSuperAgent = " + FilterString(pSuperAgent);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pState = " + FilterString(pState);
            sql += ", @pDistrict = " + FilterString(pDistrict);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult UpdateTransaction(string user, string tranId, string fieldName, string oldValue,
                                     string newTxtValue, string newDdlValue, string firstName, string middleName, string lastName1, string lastName2, string contactNo, string isApi,string sessionId)
        {
            string sql = "EXEC [proc_modifyTXN]";
            sql += "  @flag = 'u'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @fieldName = " + FilterString(fieldName);
            sql += ", @oldValue = " + FilterString(oldValue);
            sql += ", @newTxtValue = N" + FilterString(newTxtValue);
            sql += ", @newDdlValue = " + FilterString(newDdlValue);
            sql += ", @firstName = N" + FilterString(firstName);
            sql += ", @middleName = " + FilterString(middleName);
            sql += ", @lastName1 = N" + FilterString(lastName1);
            sql += ", @lastName2 = " + FilterString(lastName2);
            sql += ", @contactNo = " + FilterString(contactNo);
            sql += ", @isApi = " + FilterString(isApi);
            sql += ", @sessionId = " + FilterString(sessionId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult UpdateTransactionEduPay(string user, string tranId, string fieldName, string oldValue,
                                     string newTxtValue, string newDdlValue, string firstName, string middleName, string lastName1, string lastName2, string contactNo, string isApi)
        {
            string sql = "EXEC [proc_modifyTXNEduPay]";
            sql += "  @flag = 'u'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @fieldName = " + FilterString(fieldName);
            sql += ", @oldValue = " + FilterString(oldValue);
            sql += ", @newTxtValue = " + FilterString(newTxtValue);

            sql += ", @newDdlValue = " + FilterString(newDdlValue);
            sql += ", @firstName = " + FilterString(firstName);
            sql += ", @middleName = " + FilterString(middleName);
            sql += ", @lastName1 = " + FilterString(lastName1);
            sql += ", @lastName2 = " + FilterString(lastName2);
            sql += ", @contactNo = " + FilterString(contactNo);
            sql += ", @isApi = " + FilterString(isApi);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        //modify from agent panel (international) only hold transaction
        public DbResult UpdateHoldTransaction(string user, string tranId, string fieldName, string oldValue,
                                     string newTxtValue, string newDdlValue, string firstName, string middleName, string lastName1, string lastName2, string contactNo, string isApi)
        {
            string sql = "EXEC [proc_modifyTranInt]";
            sql += "  @flag = 'uHoldtxn'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @fieldName = " + FilterString(fieldName);
            sql += ", @oldValue = " + FilterString(oldValue);
            sql += ", @newTxtValue = " + FilterString(newTxtValue);
            sql += ", @newDdlValue = " + FilterString(newDdlValue);
            sql += ", @firstName = " + FilterString(firstName);
            sql += ", @middleName = " + FilterString(middleName);
            sql += ", @lastName1 = " + FilterString(lastName1);
            sql += ", @lastName2 = " + FilterString(lastName2);
            sql += ", @contactNo = " + FilterString(contactNo);
            sql += ", @isApi = " + FilterString(isApi);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet UpdatePayoutLocationApi(string user, string tranId, string newPLocation)
        {
            string sql = "EXEC proc_modifyTxnAPI";
            sql += " @flag = 'ml'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @newPLocation = " + FilterString(newPLocation);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        public DbResult UpdateTransactionPayoutLocation(string user, string tranId, string fieldName, string oldValue,
                                     string newDdlValue, string bankName, string branchName, string isApi,string sessionId)
        {
            string sql = "EXEC [proc_modifyTXN]";
            sql += "  @flag = 'u'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @fieldName = " + FilterString(fieldName);
            sql += ", @oldValue = " + FilterString(oldValue);
            sql += ", @newDdlValue = " + FilterString(newDdlValue);
            sql += ", @bankNewName = " + FilterString(bankName);
            sql += ", @branchNewName = " + FilterString(branchName);
            sql += ", @isAPI = " + FilterString(isApi);
            sql += ", @sessionId = " + FilterString(sessionId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public string SelectBankNameById(string user, string tranId)
        {
            string sql = "EXEC [proc_modifyTXN]";
            sql += "  @flag = 'sa'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);

            return GetSingleResult(sql);
        }

        public DbResult TranViewLog(
                         string user
                        , string tranId
                        , string controlNo
                        , string remarks
                        , string tranViewType
                    )
        {
            string sql = "EXEC proc_tranViewHistory";
            sql += "  @flag = 'i1'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @remarks = " + FilterString(remarks);
            sql += ", @tranViewType = " + FilterString(tranViewType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult VerifyAgentForTranView(string user, string controlNo, string branch)
        {
            var sql = "EXEC proc_transactionView @flag = 'va'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @branch = " + FilterString(branch);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        #region TXN modification Rquest part

        public DataTable TXNReqUpdate(string user, string controlNo, string changeType, string newValue, string fieldName, string fieldValue)
        {
            var sql = "EXEC proc_modifyTranRequest @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @changeType = " + FilterString(changeType);
            sql += ", @newValue = " + FilterString(newValue);
            sql += ", @fieldName = " + FilterString(fieldName);
            sql += ", @fieldValue = " + FilterString(fieldValue);

            return ExecuteDataset(sql).Tables[0];
        }

        public DbResult TXNSCchange(string user, string controlNo)
        {
            var sql = "EXEC proc_modifyTranRequest @flag = 'uSC'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataTable TXNDelete(string user, string rowid, string controlNo)
        {
            var sql = "EXEC proc_modifyTranRequest @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowid = " + FilterString(rowid);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable TXNSelectComment(string user, string controlNo)
        {
            var sql = "EXEC proc_modifyTranRequest @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ExecuteDataset(sql).Tables[0];
        }

        public DbResult TXNModificationApprove(string user, string controlNo)
        {
            var sql = "EXEC proc_modifyTranRequest @flag = 'refundSC'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult ApproveTxnRequest(string user, string rowId, string tranId)
        {
            var sql = "EXEC proc_modifyTXN @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @tranId = " + FilterString(tranId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Approve(string user, string tranId, string sendSmsEmail)
        {
            var sql = "EXEC proc_modifyTranInt @flag = 'approveAll'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @sendSmsEmail = " + FilterString(sendSmsEmail);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }


        public DbResult Reject(string user, string tranId)
        {
            var sql = "EXEC proc_modifyTXN @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet DisplayModification(string user, string controlNo)
        {
            var sql = "EXEC proc_modifyTranRequest @flag = 'showModifiedLog'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataTable DisplayApprovedModification(string user, string controlNo)
        {
            var sql = "EXEC proc_modifyTranRequest @flag = 'getApprovedModificationLog'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ExecuteDataTable(sql);
        }
        #endregion

        public string SelectCooperativeName(string user, string tranId)
        {
            string sql = "EXEC [proc_modifyTXN]";
            sql += "  @flag = 'copName'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);


            return GetSingleResult(sql);
        }

    public DbResult UpdateChangeStatus(string user, string tranId, string status) {
      string sql = "EXEC proc_customChangeStatus";
      sql += " @user = " + FilterString(user);
      sql += ", @tranId = " + FilterString(tranId);
      sql += ", @status = " + FilterString(status);
      return ParseDbResult(ExecuteDataset(sql).Tables[0]);
    }
  }
}