using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration
{
    public class CountryDao : RemittanceDao
    {
        public DbResult Update(string user, string countryId, string countryCode, string countryName, string isoAlpha3,
                string iocOlympic, string isoNumeric, string isOperativeCountry, string operationType,
                string fatfRating, string timeZone, string agentOperationControlType,
                string defaultRoutingAgent, string countryMobCode, string countryMobLength)
        {
            string sql = "EXEC proc_countryMaster";
            sql += " @flag = " + (countryId == "0" || countryId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @countryCode = " + FilterString(countryCode);
            sql += ", @countryName = " + FilterString(countryName);
            sql += ", @isoAlpha3 = " + FilterString(isoAlpha3);
            sql += ", @iocOlympic = " + FilterString(iocOlympic);
            sql += ", @isoNumeric = " + FilterString(isoNumeric);
            sql += ", @isOperativeCountry = " + FilterString(isOperativeCountry);
            sql += ", @operationType=" + FilterString(operationType);
            sql += ", @fatfRating=" + FilterString(fatfRating);
            sql += ", @timeZoneId=" + FilterString(timeZone);
            sql += ", @agentOperationControlType=" + FilterString(agentOperationControlType);
            sql += ", @defaultRoutingAgent=" + FilterString(defaultRoutingAgent);
            sql += ", @countryMobCode=" + FilterString(countryMobCode);
            sql += ", @countryMobLength=" + FilterString(countryMobLength);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string countryId)
        {
            string sql = "EXEC proc_countryMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryId = " + FilterString(countryId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string countryId)
        {
            string sql = "EXEC proc_countryMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryId = " + FilterString(countryId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataTable PopulateGridData(string qry)
        {
            string sql = qry;

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable getAgentMappingData(string partnerId, string user)
        {
            string sql = "EXEC Proc_AgentBankMapping  @flag ='agentmappingBank'";
            sql += " ,@superAgentId=" + FilterString(GetStatic.ReadWebConfig("IntlAPISuperAgentId"));
            sql += " ,@bankpartnerId=" + FilterString(partnerId);
            sql += " ,@user=" + FilterString(user);
            return ExecuteDataTable(sql);
        }

        internal DbResult SaveData(string checkedvalue, string user, string partnerId)
        {
            string sql = "EXEC Proc_AgentBankMapping";
            sql += " @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @functionId = '" + checkedvalue + "'";
            sql += ", @superAgentId = " + FilterString(GetStatic.ReadWebConfig("IntlAPISuperAgentId"));
            sql += ", @bankpartnerId = " + FilterString(partnerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        #region Currency Manage

        public DbResult UpdateCurrency(string user, string countryCurrencyId, string countryId, string currencyId,
                                       string spFlag, string isDefault)
        {
            string sql = "EXEC proc_countryCurrency";
            sql += " @flag = " + (countryCurrencyId == "0" || countryCurrencyId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @countryCurrencyId = " + FilterString(countryCurrencyId);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @currencyId = " + FilterString(currencyId);
            sql += ", @spFlag = " + FilterString(spFlag);
            sql += ", @isDefault = " + FilterString(isDefault);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteCurrency(string user, string countryCurrencyId)
        {
            string sql = "EXEC proc_countryCurrency";
            sql += " @flag = 'd'";
            sql += ", @countryCurrencyId = " + countryCurrencyId;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectCurrencyById(string user, string countryCurrencyId)
        {
            string sql = "EXEC proc_countryCurrency";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryCurrencyId = " + FilterString(countryCurrencyId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #endregion Currency Manage

        #region Country identity type setup

        public DbResult UpdateCurrencyIdtype(string user, string countryIdtypeId, string countryId, string Idtype,
                                       string spFlag, string expiryType)
        {
            string sql = "EXEC proc_countryIdType";
            sql += " @flag = " + (countryIdtypeId == "0" || countryIdtypeId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @countryIdtypeId = " + FilterString(countryIdtypeId);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @IdtypeId = " + FilterString(Idtype);
            sql += ", @spFlag = " + FilterString(spFlag);
            sql += ", @expiryType = " + FilterString(expiryType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectIdentypeById(string user, string countryIdtypeId)
        {
            string sql = "EXEC proc_countryIdType";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryIdtypeId = " + FilterString(countryIdtypeId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult DeleteIdentype(string user, string countryIdtypeId)
        {
            string sql = "EXEC proc_countryIdType";
            sql += " @flag = 'd'";
            sql += ", @countryIdtypeId = " + countryIdtypeId;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        #endregion Country identity type setup

        #region Currency Rule

        public DbResult UpdateRule(string user, string Rule_Id, string Rule_Name, string currCode, int countryId)
        {
            string sql = "EXEC proc_CurrencyRule";
            //sql += " @flag = " + (CURR_ID == "0" || CURR_ID == "" ? "'i'" : "'u'");
            sql += " @flag = i";
            sql += ", @user = " + FilterString(user);
            sql += ", @RULE_NAME = " + FilterString(Rule_Name);
            sql += ", @RULE_ID = " + FilterString(Rule_Id);
            sql += ", @currCode = " + FilterString(currCode);
            sql += ", @countryId = " + countryId;
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteRule(string user, int ROWID)
        {
            string sql = "EXEC proc_CurrencyRule";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @ROWID = " + ROWID;

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        #endregion Currency Rule

        #region sending country setup

        public DbResult UpdateSendingCountry(string user, string rowId, string countryId, string rsCountryId, string roleType, string listType, string tranType, string applyToAgent)
        {
            var sql = "exec proc_rsList1";
            sql += " @flag = " + (rowId == "0" || rowId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @rscountryId = " + FilterString(rsCountryId);
            sql += ", @roleType = " + FilterString(roleType);
            sql += ", @listType = " + FilterString(listType);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @applyToAgent = " + FilterString(applyToAgent);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteSendingCountry(string user, string countryId)
        {
            string sql = "EXEC proc_rsList1";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowid = " + FilterString(countryId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectSendingCountryById(string user, string rowId)
        {
            string sql = "EXEC proc_rsList1";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #endregion sending country setup

        #region Agent Sending Country inclusive/Exclusive

        public DbResult UpdateExcSendingCountry(string user, string agentId, string rsAgentId, string rsCountryId, string roleType, string listType, string tranType)
        {
            var sql = "exec proc_rsList1";
            sql += "  @flag = 'iAExC'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @rsagentId = " + FilterString(rsAgentId);
            sql += ", @rscountryId = " + FilterString(rsCountryId);
            sql += ", @roleType = " + FilterString(roleType);
            sql += ", @listType = " + FilterString(listType);
            sql += ", @tranType = " + FilterString(tranType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        #endregion Agent Sending Country inclusive/Exclusive

        #region country group mapping setup

        public DbResult UpdateGrpMapping(string user, string rowId, string countryID, string GroupCat, string GroupDetail)
        {
            string sql = "EXEC proc_countryGroupMapping ";
            sql += " @flag = " + (rowId == "0" || rowId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @countryID = " + FilterString(countryID);
            sql += ", @GroupCat = " + FilterString(GroupCat);
            sql += ", @GroupDetail = " + FilterString(GroupDetail);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectGrpMappingById(string user, string rowId)
        {
            string sql = "EXEC proc_countryGroupMapping ";
            sql += " @flag ='a'";
            sql += ", @rowId =" + FilterString(rowId);
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult DeleteGrpMapping(string user, string rowid)
        {
            string sql = "EXEC proc_countryGroupMapping";
            sql += " @flag = 'd'";
            sql += ",@user = " + FilterString(user);
            sql += ",@rowid = " + FilterString(rowid);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ParseDbResult(ds.Tables[0]);
        }

        #endregion country group mapping setup

        #region Country Holiday Event List Setup

        public DbResult UpdateCountryHoliday(string user, string rowId, string countryId, string eventDate, string eventName, string eventDesc)
        {
            string sql = "EXEC proc_countryHolidayList";
            sql += " @flag = " + (rowId == "0" || rowId == "" ? "'i'" : "'u'");
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @user = " + FilterString(user);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @eventDate = " + FilterString(eventDate);
            sql += ", @eventName = " + FilterString(eventName);
            sql += ", @eventDesc = " + FilterString(eventDesc);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteCountryHoliday(string user, string rowId)
        {
            string sql = "EXEC proc_countryHolidayList";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectCountryHolidayById(string user, string rowId)
        {
            string sql = "EXEC proc_countryHolidayList";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #endregion Country Holiday Event List Setup

        #region CountryBank

        public DbResult CBUpdate(string user, string countryBankId, string countryId, string bankName, string accountNumber, string remarks, string isActive)
        {
            var sql = "EXEC proc_countryBanks";
            sql += " @flag = " + (countryBankId == "0" || countryBankId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @countryBankId = " + FilterString(countryBankId);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @bankName = " + FilterString(bankName);
            sql += ", @accountNumber = " + FilterString(accountNumber);
            sql += ", @remarks = " + FilterString(remarks);
            sql += ", @isActive = " + FilterString(isActive);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult CBDelete(string user, string countryBankId)
        {
            var sql = "EXEC proc_countryBanks";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryBankId = " + FilterString(countryBankId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow CBSelectById(string user, string countryBankId)
        {
            var sql = "EXEC proc_countryBanks";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryBankId = " + FilterString(countryBankId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #endregion CountryBank

        #region Collection Mode

        public DbResult DeleteCcm(string user, string ccmId)
        {
            var sql = "EXEC proc_countryCollectionMode @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @ccmId = " + FilterString(ccmId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult AddCcm(string user, string countryId, string collModes)
        {
            var sql = "EXEC proc_countryCollectionMode @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @collModes = " + FilterString(collModes);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        #endregion Collection Mode

        #region Receiving Mode

        public DbResult DeleteCrm(string user, string crmId)
        {
            var sql = "EXEC proc_countryReceivingMode @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @crmId = " + FilterString(crmId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult UpdateCrm(string user, string crmId, string countryId, string receivingMode, string applicableFor, string agentSelection)
        {
            string sql = "EXEC proc_countryReceivingMode";
            sql += " @flag = " + (crmId == "0" || crmId == "" ? "'i'" : "'u'");
            sql += ", @crmId = " + FilterString(crmId);
            sql += ", @user = " + FilterString(user);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @receivingMode = " + FilterString(receivingMode);
            sql += ", @applicableFor = " + FilterString(applicableFor);
            sql += ", @agentSelection = " + FilterString(agentSelection);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectByIdCrm(string user, string crmId)
        {
            var sql = "EXEC proc_countryReceivingMode @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @crmId = " + FilterString(crmId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #endregion Receiving Mode
    }
}