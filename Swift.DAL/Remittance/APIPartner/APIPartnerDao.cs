using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.APIPartner
{
    public class APIPartnerDao : RemittanceDao
    {
        public DbResult EnableDisable(string rowId, string user, string isActive)
        {
            var sql = "EXEC PROC_API_ROUTE_PARTNERS @flag = 'enable-disable'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @IsActive = " + FilterString(isActive);

            return ParseDbResult(sql);
        }

        public DbResult EnableDisablePromotion(string rowId, string user, string isActive)
        {
            var sql = "EXEC PROC_PROMOTIONAL_CAMPAIGN @flag = 'enable-disable'";
            sql += ", @user = " + FilterString(user);
            sql += ", @ROW_ID = " + FilterString(rowId);
            sql += ", @IS_ACTIVE = " + FilterString(isActive);

            return ParseDbResult(sql);
        }

        public DbResult InsertUpdatePromotion(string user, string flag, string rowId, string promotionCode, string promotionMsg
                            , string promotionType, string country, string paymentMethod, string isActive, string startDt
                            , string endDt, string promotionAmount)
        {
            var sql = "EXEC PROC_PROMOTIONAL_CAMPAIGN @flag = '" + flag + "'";
            sql += ", @user = " + FilterString(user);
            sql += ", @ROW_ID = " + FilterString(rowId);
            sql += ", @PROMOTIONAL_CODE = " + FilterString(promotionCode);
            sql += ", @PROMOTIONAL_MSG = " + FilterString(promotionMsg);
            sql += ", @PROMOTION_TYPE = " + FilterString(promotionType);
            sql += ", @PROMOTION_VALUE = " + FilterString(promotionAmount);
            sql += ", @COUNTRY_ID = " + FilterString(country);
            sql += ", @PAYMENT_METHOD = " + FilterString(paymentMethod);
            sql += ", @IS_ACTIVE = " + FilterString(isActive);
            sql += ", @START_DT = " + FilterString(startDt);
            sql += ", @END_DT = " + FilterString(endDt);

            return ParseDbResult(sql);
        }

        public DbResult InsertUpdate(string flag, string partner, string country, string payoutMethod, string isActive, string user, string rowId, string isRealTime, string minTxnLimit, string maxTxnLimit, string limitCurrency, string exRateCalcByPartner, string isACValidateSupport)
        {
            var sql = "EXEC PROC_API_ROUTE_PARTNERS @flag = '" + flag + "'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @IsActive = " + FilterString(isActive);
            sql += ", @CountryId = " + FilterString(country);
            sql += ", @AgentId = " + FilterString(partner);
            sql += ", @PaymentMethod = " + FilterString(payoutMethod);
            sql += ", @isRealTime = " + FilterString(isRealTime);
            sql += ", @minTxnLimit = " + FilterString(minTxnLimit);
            sql += ", @maxTxnLimit = " + FilterString(maxTxnLimit);
            sql += ", @limitCurrency = " + FilterString(limitCurrency);
            sql += ", @exRateCalcByPartner = " + FilterString(exRateCalcByPartner);
            sql += ", @isACValidateSupport = " + FilterString(isACValidateSupport);

            return ParseDbResult(sql);
        }

        public object CancelTxn(string user, string controlNo, string cancelDate, string cancelReason)
        {
            var sql = "EXEC PROC_MANUAL_CANCEL";
            sql += " @USER = " + FilterString(user);
            sql += ", @CONTROLNO = " + FilterString(controlNo);
            sql += ", @cancelReason = " + FilterString(cancelReason);
            sql += ", @CANCELdATE = " + FilterString(cancelDate);

            return ParseDbResult(sql);
        }

        public DbResult UpdateReferral(string user, string controlNo, string referralCode)
        {
            var sql = "EXEC PROC_TXN_REFERRAL_CHANGE @flag = 'UPDATE'";
            sql += ", @USER = " + FilterString(user);
            sql += ", @CONTROLNO = " + FilterString(controlNo);
            sql += ", @REFERRAL_CODE_NEW = " + FilterString(referralCode);

            return ParseDbResult(sql);
        }

        public DataRow GetTransactionDetails(string user, string controlNo)
        {
            var sql = "EXEC PROC_TXN_REFERRAL_CHANGE @flag = 'SELECT'";
            sql += ", @USER = " + FilterString(user);
            sql += ", @CONTROLNO = " + FilterString(controlNo);

            return ExecuteDataRow(sql);
        }

        public DataRow GetData(string rowId, string user)
        {
            var sql = "EXEC PROC_API_ROUTE_PARTNERS @flag = 'select'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ExecuteDataRow(sql);
        }

        public DataRow GetDataPromotion(string rowId, string user)
        {
            var sql = "EXEC PROC_PROMOTIONAL_CAMPAIGN @flag = 'select'";
            sql += ", @user = " + FilterString(user);
            sql += ", @ROW_ID = " + FilterString(rowId);

            return ExecuteDataRow(sql);
        }
    }
}