using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.GeneralSettings
{
    public class MessageSettingDao : SwiftDao
    {
        public DbResult UpdateHeadMsg(string user, string msgId, string countryId, string isActive, string headMsg)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = " + (msgId == "0" || msgId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);

            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @headMsg = N" + FilterString(headMsg);
            sql += ", @isActive = " + FilterString(isActive);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteHeadMsg(string user, string msgId)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectByIdHeadMsg(string user, string msgId)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult UpdateCommonMsg(string user, string msgId, string countryId, string isActive, string commonMsg)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = " + (msgId == "0" || msgId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);

            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @commonMsg = N" + FilterString(commonMsg);
            sql += ", @isActive = " + FilterString(isActive);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteMsgBlock1(string user, string msgId)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectByIdMsgBlock1(string user, string msgId)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult UpdateCountrySpecificMsg(string user, string msgId, string countryId, string isActive, string countrySpecificMsg,
                                                 string msgType, string agentId, string transactionType, string receivingCountry, string receivingAgent)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = " + (msgId == "0" || msgId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @countrySpecificMsg = N" + FilterString(countrySpecificMsg);
            sql += ", @msgType = " + FilterString(msgType);
            sql += ", @isActive = " + FilterString(isActive);
            sql += ", @transactionType=" + FilterString(transactionType);
            sql += ", @rCountry=" + FilterString(receivingCountry);
            sql += ", @rAgent=" + FilterString(receivingAgent);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteMsgBlock2(string user, string msgId)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectByIdMsgBlock2(string user, string msgId)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult UpdatePromotionalMsg(string user, string msgId, string agentId, string isActive, string promotionalMsg,
                                             string msgType, string countryId, string transactionType)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = " + (msgId == "0" || msgId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);
            sql += ", @transactionType=" + FilterString(transactionType);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @promotionalMsg = N" + FilterString(promotionalMsg);
            sql += ", @msgType = " + FilterString(msgType);
            sql += ", @isActive = " + FilterString(isActive);
            sql += ", @countryId = " + FilterString(countryId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteMsgBlock3(string user, string msgId)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectByIdMsgBlock3(string user, string msgId)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult UpdateNewsFeeder(string user, string msgId, string countryId, string msgType, string agentId, string branchId, string headMsg, string isActive, string userType)
        {
            string sql = "EXEC proc_message";
            sql += "  @flag = " + (msgId == "0" || msgId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @msgType = " + FilterString(msgType);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @newsFeederMsg = N" + FilterString(headMsg);
            sql += ", @isActive = " + FilterString(isActive);
            sql += ", @userType=" + FilterString(userType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectByIdNewsFeeder(string user, string msgId)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult DeleteNewsFeeder(string user, string msgId)
        {
            string sql = "EXEC proc_message";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @msgId = " + FilterString(msgId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult UpdateEmailServerSetup(string user, string id, string smtpServer, string smtpPort, string sendId, string sendPsw)
        {

            string sql = "EXEC proc_emailServerSetup";
            sql += "  @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
            sql += ", @rowId = " + FilterString(id);
            sql += ", @user = " + FilterString(user);
            sql += ", @smtpServer = " + FilterString(smtpServer);
            sql += ", @smtpPort = " + FilterString(smtpPort);
            sql += ", @sendID = " + FilterString(sendId);
            sql += ", @sendPSW = " + FilterString(sendPsw);

            return ParseDbResult(sql);
            //return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectByIdEmailServerSetup(string user)
        {
            string sql = "EXEC proc_emailServerSetup";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        //email template setup
        public DbResult UpdateEmailTemplate(string user, string id, string templateName, string emailSubject,
                string isEnabled, string isResToAgent, string emailFormat, string templateFor, string replyTo)
        {

            string sql = "EXEC proc_emailTemplate";
            sql += "  @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @templateName = " + FilterString(templateName);
            sql += ", @emailSubject = " + FilterString(emailSubject);
            sql += ", @templateFor = " + FilterString(templateFor);
            sql += ", @isEnabled = " + FilterString(isEnabled);
            sql += ", @isResponseToAgent = " + FilterString(isResToAgent);
            sql += ", @emailFormat = " + FilterString(emailFormat);
            sql += ", @replyTo = " + FilterString(replyTo);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteEmailTemplate(string user, string id)
        {
            string sql = "EXEC proc_emailTemplate";
            sql += " @flag = 'd'";
            sql += ", @id = " + id;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }


        public DataRow SelectEmailTemplateById(string user, string id)
        {
            string sql = "EXEC proc_emailTemplate";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataTable GetKeyword(string user)
        {
            var sql = "EXEC proc_emailTemplate @flag = 'keyword'";
            sql += ", @user = " + FilterString(user);
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable MessageList(string user, string userType, string conuntryId, string agentid)
        {
            var sql = "EXEC [proc_message] @flag = 'ml'";
            sql += ", @user = " + FilterString(user);
            sql += ", @userType = " + FilterString(userType);
            sql += ", @countryId =" + FilterString(conuntryId);
            sql += ", @agentId =" + FilterString(agentid);
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable GetNewsFeeder(string user, string userType, string conuntryId, string agentId, string branchId)
        {
            var sql = "EXEC [proc_messageDisplay] @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @userType = " + FilterString(userType);
            sql += ", @countryId =" + FilterString(conuntryId);
            sql += ", @agentId =" + FilterString(agentId);
            sql += ", @branchId =" + FilterString(branchId);
            return ExecuteDataset(sql).Tables[0];
        }
    }
}