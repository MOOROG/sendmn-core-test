using Swift.DAL.Model;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.Remittance.ReferralSetup
{
    public class ReferralSetupDao : RemittanceDao
    {
        public DbResult InsertReferral(string flag, string user, string referralName,
                                    string referralAddress, string referralEmail,
                                    string isActive, string referralMobile, string branchId,
                                     string rowId, string referralTypecode, string referralType,
                                     string ruleType, string cashHoldLimitAmount)
        {
            var sql = "EXEC PROC_REFERALSETUP @flag = '" + flag + "'";
            sql += ", @user = " + FilterString(user);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @referralName = " + FilterString(referralName);
            sql += ", @referralAddress = " + FilterString(referralAddress);
            sql += ", @referralMobile = " + FilterString(referralMobile);
            sql += ", @referralEmail = " + FilterString(referralEmail);
            sql += ", @isActive = " + FilterString(isActive);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @referralTypecode = " + FilterString(referralTypecode);
            sql += ", @referralType = " + FilterString(referralType);
            sql += ", @ruleType = " + FilterString(ruleType);
            sql += ", @cashHoldLimitAmount = " + FilterString(cashHoldLimitAmount);
            //sql += ", @DEDUCT_TAX_ON_SC = " + FilterString(deductTaxOnSC);

            return ParseDbResult(sql);
        }

        public DataRow GetData(string rowId, string user)
        {
            var sql = "EXEC PROC_REFERALSETUP @flag = 'getData'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            return ExecuteDataRow(sql);
        }

        public DbResult Delete(string user, string rowId)
        {
            var sql = "EXEC PROC_REFERALSETUP @flag = 'delete'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            return ParseDbResult(sql);
        }

        public DataRow GetCommissionData(string user,string referralId,string partnerId, string row_id)
        {
            var sql = "EXEC PROC_REFERALSETUP @flag = 'getCommissionRule'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(referralId);
            sql += ", @partnerId = " + FilterString(partnerId);
            sql += ", @ROW_ID = " + FilterString(row_id);
            return ExecuteDataRow(sql);
        }

        public DbResult SaveCommissionData(string user, CommissionModel cm,string editOrNot)
        {
            var flag = (editOrNot == "true") ? "updateCommission" : "saveCommission";
            var sql = "EXEC PROC_REFERALSETUP @flag = '"+ flag + "'";
            sql += ", @user = " + FilterString(user);
            sql += ", @referralId = " + FilterString(cm.ReferralId.ToString());
            sql += ", @ROW_ID = " + FilterString(cm.ROW_ID.ToString());
            sql += ", @partnerId = " + FilterString(cm.PartnerId.ToString());
            sql += ", @commissionPercent = " + FilterString(cm.CommissionPercent.ToString());
            sql += ", @forexPercent = " + FilterString(cm.ForexPercent.ToString());
            sql += ", @flatTxnWise = " + FilterString(cm.FlatTxnWise.ToString());
            sql += ", @NewCustomer = " + FilterString(cm.NewCustomer.ToString());
            sql += ", @effectiveFrom = " + FilterString(cm.EffectiveFrom.ToString());
            sql += ", @isActive = " + FilterString(cm.isActive == true ?"1":"0");
            sql += ", @referralCode = " + FilterString(cm.ReferralCode);
            sql += ", @DEDUCT_TAX_ON_SC = " + FilterString(cm.deductTaxOnSC);
            sql += ", @DEDUCT_P_COMM_ON_SC = " + FilterString(cm.deductPCommOnSC);
            return ParseDbResult(sql);
        }
    }
}