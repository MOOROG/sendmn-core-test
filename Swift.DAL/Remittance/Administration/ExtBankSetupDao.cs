using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration
{
    public class ExtBankSetupDao : SwiftDao
    {
        #region External Bank setup
        public DbResult Update(
                      string user
                    ,string extBankId
                    ,string bankName						
					,string bankCode					
					,string country						
					,string address							
					,string phone							
					,string fax								
					,string email							
					,string contactPerson					
					,string swiftCode						
					,string routingCode						
					,string externalCode
			        ,string internalCode	
	                ,string domInternalCode
					,string externalBankType				
					,string isBranchSelectionRequired		
					,string receivingMode
                    ,string blocked
            )
        {
            string sql = "EXEC [proc_externalBank]";
            sql += "  @flag = " + (extBankId == "0" || extBankId == "" ? "'i'" : "'u'");
            sql += ", @extBankId =" + FilterString(extBankId);
            sql += ", @user = " + FilterString(user);
            sql += ", @bankName = " + FilterString(bankName);
            sql += ", @bankCode = " + FilterString(bankCode);
            sql += ", @country = " + FilterString(country);
            sql += ", @address = " + FilterString(address);
            sql += ", @phone = " + FilterString(phone);
            sql += ", @fax = " + FilterString(fax);
            sql += ", @email = " + FilterString(email);
            sql += ", @contactPerson = " + FilterString(contactPerson);
            sql += ", @swiftCode = " + FilterString(swiftCode);
            sql += ", @routingCode = " + FilterString(routingCode);
            sql += ", @externalCode = " + FilterString(externalCode);
            sql += ", @internalCode = " + FilterString(internalCode);
            sql += ", @domInternalCode = " + FilterString(domInternalCode);
            sql += ", @externalBankType = " + FilterString(externalBankType);
            sql += ", @IsBranchSelectionRequired = " + FilterString(isBranchSelectionRequired);
            sql += ", @receivingMode = " + FilterString(receivingMode);
            sql += ", @isBlocked = " + FilterString(blocked);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string extBankId)
        {
            string sql = "EXEC proc_externalBank";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @extBankId = " + FilterString(extBankId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string extBankId)
        {
            string sql = "EXEC proc_externalBank";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @extBankId = " + FilterString(extBankId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public string SelectAgentNameById(string user, string agentId)
        {
            string sql = "select agentName from agentMaster where agentId=" + FilterString(agentId);

            return GetSingleResult(sql);
        }

        public DataRow SelectAgentInfoById(string user, string agentId)
        {
            string sql = "select agentName,agentCountry from agentMaster where agentId=" + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        #endregion
        #region  AgentWiseBankCodeStup  PART
        public DbResult UpdateBankCode(string user
                    , string extBankCodeId
                    , string agentId
                    , string bankId
                    , string externalCode
            )
        {
            string sql = "EXEC [proc_ExternalBankCode]";
            sql += "  @flag = " + (extBankCodeId == "0" || extBankCodeId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @extBankCodeId = " + FilterString(extBankCodeId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @bankId = " + FilterString(bankId);
            sql += ", @externalCode = " + FilterString(externalCode);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult DeleteBankCode(string user, string extBankCodeId)
        {
            string sql = "EXEC proc_ExternalBankCode";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @extBankCodeId = " + FilterString(extBankCodeId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        
        public DataRow SelectBankCodeById(string user, string extBankCodeId)
        {
            string sql = "EXEC proc_ExternalBankCode";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @extBankCodeId = " + FilterString(extBankCodeId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        #endregion

        #region  Branchwise agent bank code setup

        public DbResult DeleteBankBranchCode(string user, string extBankCodeId)
        {
            string sql = "EXEC proc_ExternalBankCode";
            sql += "  @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @extBankCodeId = " + FilterString(extBankCodeId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult UpdateBranchWiseBankCode(string user
            , string extBankCodeId
            , string agentId
            , string bankId
            , string extBranchId
            , string externalCode)
        {
            string sql = "EXEC [proc_extBranchWiseBankCode]";
            sql += "  @flag = " + (extBankCodeId == "0" || extBankCodeId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @extBankCodeId = " + FilterString(extBankCodeId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @bankId = " + FilterString(bankId);
            sql += ", @extBranchId = " + FilterString(extBranchId);
            sql += ", @externalCode = " + FilterString(externalCode);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        #endregion
    }
}