using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration
{
    public class UserDao : SwiftDao
    {
        public DbResult Update(string user, string USER_ID, string BRANCH_ID, string AGENT_ID, string USER_NAME,
                               string USER_CODE, string USER_PHONE1, string USER_PHONE2, string USER_MOBILE1,
                               string USER_MOILE2, string USER_FAX1, string USER_FAX2, string USER_EMAIL1,
                               string USER_EMAIL2, string USER_ADDRESS_PERMANENT, string PERMA_CITY, string PEMA_COUNTRY,
                               string USER_ADDRESS_TEMP, string TEMP_CITY, string TEMP_COUNTRY, string CONTACT_PERSON,
                               string CONTACT_PERSON_ADDRESS, string CONTACT_PERSON_PHONE, string CONTACT_PERSON_FAX,
                               string CONTACT_PERSON_MOBILE, string CONTACT_PERSON_EMAIL, string IS_ACTIVE)
        {
            string sql = "EXEC proc_userMaster";
            sql += " @flag = " + (USER_ID == "0" || USER_ID == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @USER_ID = " + FilterString(USER_ID);

            sql += ", @BRANCH_ID = " + FilterString(BRANCH_ID);
            sql += ", @AGENT_ID = " + FilterString(AGENT_ID);
            sql += ", @USER_NAME = " + FilterString(USER_NAME);
            sql += ", @USER_CODE = " + FilterString(USER_CODE);
            sql += ", @USER_PHONE1 = " + FilterString(USER_PHONE1);
            sql += ", @USER_PHONE2 = " + FilterString(USER_PHONE2);
            sql += ", @USER_MOBILE1 = " + FilterString(USER_MOBILE1);
            sql += ", @USER_MOILE2 = " + FilterString(USER_MOILE2);
            sql += ", @USER_FAX1 = " + FilterString(USER_FAX1);
            sql += ", @USER_FAX2 = " + FilterString(USER_FAX2);
            sql += ", @USER_EMAIL1 = " + FilterString(USER_EMAIL1);
            sql += ", @USER_EMAIL2 = " + FilterString(USER_EMAIL2);
            sql += ", @USER_ADDRESS_PERMANENT = " + FilterString(USER_ADDRESS_PERMANENT);
            sql += ", @PERMA_CITY = " + FilterString(PERMA_CITY);
            sql += ", @PEMA_COUNTRY = " + FilterString(PEMA_COUNTRY);
            sql += ", @USER_ADDRESS_TEMP = " + FilterString(USER_ADDRESS_TEMP);
            sql += ", @TEMP_CITY = " + FilterString(TEMP_CITY);
            sql += ", @TEMP_COUNTRY = " + FilterString(TEMP_COUNTRY);
            sql += ", @CONTACT_PERSON = " + FilterString(CONTACT_PERSON);
            sql += ", @CONTACT_PERSON_ADDRESS = " + FilterString(CONTACT_PERSON_ADDRESS);
            sql += ", @CONTACT_PERSON_PHONE = " + FilterString(CONTACT_PERSON_PHONE);
            sql += ", @CONTACT_PERSON_FAX = " + FilterString(CONTACT_PERSON_FAX);
            sql += ", @CONTACT_PERSON_MOBILE = " + FilterString(CONTACT_PERSON_MOBILE);
            sql += ", @CONTACT_PERSON_EMAIL = " + FilterString(CONTACT_PERSON_EMAIL);
            sql += ", @IS_ACTIVE = " + FilterString(IS_ACTIVE);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string USER_ID)
        {
            string sql = "EXEC proc_userMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @USER_ID = " + FilterString(USER_ID);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string USER_ID)
        {
            string sql = "EXEC proc_userMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @USER_ID = " + FilterString(USER_ID);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string USER_ID)
        {
            string sql = "EXEC proc_userMaster";
            sql += " @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @USER_ID = " + FilterString(USER_ID);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string USER_ID)
        {
            string sql = "EXEC proc_userMaster";
            sql += " @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @USER_ID = " + FilterString(USER_ID);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}