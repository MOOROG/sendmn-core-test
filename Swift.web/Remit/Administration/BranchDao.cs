using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration
{
    public class BranchDao : SwiftDao
    {
        public DbResult Update(string user, string BRANCH_ID, string AGENT_ID, string BRANCH_NAME, string PHONE1,
                               string PHONE2, string FAX1, string FAX2, string MOBILE1, string MOBILE2, string EMAIL1,
                               string EMAIL2, string BRANCH_ADDRESS, string CITY, string COUNTRY,
                               string BRANCH_CONTACT_PERSON, string BRANCH_CONTACT_PERSON_ADDRESS,
                               string CONTACT_PERSON_CITY, string CONTACT_PERSON_COUNTRY, string CONTACT_PERSON_PHONE,
                               string CONTACT_PERSON_FAX, string CONTACT_PERSON_MOBILE, string CONTACT_PERSON_EMAIL,
                               string IS_ACTIVE)
        {
            string sql = "EXEC proc_branchMaster";
            sql += " @flag = " + (BRANCH_ID == "0" || BRANCH_ID == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @BRANCH_ID = " + FilterString(BRANCH_ID);

            sql += ", @AGENT_ID = " + FilterString(AGENT_ID);
            sql += ", @BRANCH_NAME = " + FilterString(BRANCH_NAME);
            //sql += ", @BRANCH_CODE = " + FilterString(BRANCH_CODE);
            sql += ", @BRANCH_PHONE1 = " + FilterString(PHONE1);
            sql += ", @BRANCH_PHONE2 = " + FilterString(PHONE2);
            sql += ", @BRANCH_FAX1 = " + FilterString(FAX1);
            sql += ", @BRANCH_FAX2 = " + FilterString(FAX2);
            sql += ", @BRANCH_MOBILE1 = " + FilterString(MOBILE1);
            sql += ", @BRANCH_MOBILE2 = " + FilterString(MOBILE2);
            sql += ", @BRANCH_EMAIL1 = " + FilterString(EMAIL1);
            sql += ", @BRANCH_EMAIL2 = " + FilterString(EMAIL2);
            sql += ", @BRANCH_ADDRESS = " + FilterString(BRANCH_ADDRESS);
            sql += ", @BRANCH_CITY = " + FilterString(CITY);
            sql += ", @BRANCH_COUNTRY = " + FilterString(COUNTRY);
            sql += ", @CONTACT_PERSON = " + FilterString(BRANCH_CONTACT_PERSON);
            sql += ", @CONTACT_PERSON_ADDRESS = " + FilterString(BRANCH_CONTACT_PERSON_ADDRESS);
            sql += ", @CONTACT_PERSON_CITY = " + FilterString(CONTACT_PERSON_CITY);
            sql += ", @CONTACT_PERSON_COUNTRY = " + FilterString(CONTACT_PERSON_COUNTRY);
            sql += ", @CONTACT_PERSON_PHONE = " + FilterString(CONTACT_PERSON_PHONE);
            sql += ", @CONTACT_PERSON_FAX = " + FilterString(CONTACT_PERSON_FAX);
            sql += ", @CONTACT_PERSON_MOBILE = " + FilterString(CONTACT_PERSON_MOBILE);
            sql += ", @CONTACT_PERSON_EMAIL = " + FilterString(CONTACT_PERSON_EMAIL);
            //sql += ", @PER_DAY_TRANSACTION = " + FilterString(PER_DAY_TRANSACTION);
            sql += ", @IS_ACTIVE = " + FilterString(IS_ACTIVE);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string BRANCH_ID)
        {
            string sql = "EXEC proc_branchMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @BRANCH_ID = " + FilterString(BRANCH_ID);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string BRANCH_ID)
        {
            string sql = "EXEC proc_branchMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @BRANCH_ID = " + FilterString(BRANCH_ID);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string BRANCH_ID)
        {
            string sql = "EXEC proc_branchMaster";
            sql += " @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @BRANCH_ID = " + FilterString(BRANCH_ID);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string BRANCH_ID)
        {
            string sql = "EXEC proc_branchMaster";
            sql += " @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @BRANCH_ID = " + FilterString(BRANCH_ID);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}