using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration
{
    public class ExternalBranchSetupDao : SwiftDao
    {
        public DbResult Update( string user
                                ,string extBranchId
                                ,string extBankId
                                ,string branchName
                                ,string branchCode
                                ,string country
                                ,string state
                                ,string district
                                ,string location
                                ,string address
                                ,string phone
                                ,string swiftCode
                                ,string routingCode
                                ,string externalCode
                                ,string externalBankType
                                ,string isBlocked
                              )
        {
            string sql = "EXEC [proc_externalBankBranch]";
            sql += "  @flag = " + (extBranchId == "0" || extBranchId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @extBranchId = " + FilterString(extBranchId);
            sql += ", @extBankId = " + FilterString(extBankId);
            sql += ", @branchName = " + FilterString(branchName);
            sql += ", @branchCode = " + FilterString(branchCode);
            sql += ", @country = " + FilterString(country);
            sql += ", @state = " + FilterString(state);
            sql += ", @district = " + FilterString(district);
            sql += ", @location = " + FilterString(location);
            sql += ", @address = " + FilterString(address);
            sql += ", @phone = " + FilterString(phone);
            sql += ", @swiftCode = " + FilterString(swiftCode);
            sql += ", @routingCode = " + FilterString(routingCode);
            sql += ", @externalCode = " + FilterString(externalCode);
            sql += ", @externalBankType = " + FilterString(externalBankType);
            sql += ", @isBlocked = " + FilterString(isBlocked);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string extBranchId)
        {
            string sql = "EXEC proc_externalBankBranch";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @extBranchId = " + FilterString(extBranchId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string extBranchId)
        {
            string sql = "EXEC proc_externalBankBranch";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @extBranchId = " + FilterString(extBranchId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}
