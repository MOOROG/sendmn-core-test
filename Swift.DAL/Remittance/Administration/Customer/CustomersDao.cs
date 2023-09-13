using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration.Customer
{
    public class CustomersDao : SwiftDao
    {
        public DataSet GetSummaryDashboard(string user)
        {
            string sql = "EXEC proc_approveCustomer ";
            sql += "  @flag = 's_summary'";
            sql += ", @user = " + FilterString(user);
            return ExecuteDataset(sql);
        }
        public DataSet GetCustomerListDashboard(string user, string zone, string status)
        {
            string sql = "EXEC proc_approveCustomer @flag='s-dash'";
            sql += ", @zone = " + FilterString(zone);
            sql += ", @status = " + FilterString(status);
            sql += ", @user = " + FilterString(user);
            return ExecuteDataset(sql);
        }
        public DataTable LoadCalender(string user, string date, string type)
        {
            var sql = "EXEC proc_convertDate @flag = 'A'";
            sql += ", @user = " + FilterString(user);
            if (type == "e")
                sql += ", @engDate = " + FilterString(date);
            else
                sql += ", @nepDate = " + FilterString(date);

            return ExecuteDataTable(sql);
        }
        public DataTable LoadDistrict(string user, string zoneId)
        {
            var sql = "EXEC proc_zoneDistrictMap @flag = 'l'";
            sql += ", @user = " + FilterString(user);
            sql += ", @zone = " + FilterString(zoneId);

            return ExecuteDataTable(sql);
        }
        public DataSet GetCustomerUnReconciledList(string user, string agentId, string fromDate, string toDate,
                string memId)
        {
            var sql = "EXEC proc_reconcileCustomer @flag='s'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @memId = " + FilterString(memId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        public DbResult Reconcile(string user, string memId, string remarks)
        {
            string sql = "EXEC proc_reconcileCustomer";
            sql += " @flag = 'reconcile'";
            sql += ", @user = " + FilterString(user);
            sql += ", @memId = " + FilterString(memId);
            sql += ", @remarks = " + FilterString(remarks);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult Update(
                              string user
                            , string customerId
                            , string membershipId
                            , string firstName
                            , string middleName
                            , string lastName
                            , string maritalStatus
                            , string dboEng
                            , string dboNep
                            , string isActive

                            , string idType
                            , string idNo
                            , string placeOfIssue
                            , string issueDate
                            , string expiryDate

                            , string pTole
                            , string pHouseNo
                            , string pMunicipality
                            , string pWardNo
                            , string pCountry
                            , string pZone
                            , string pDistrict

                            , string tTole
                            , string tHouseNo
                            , string tMunicipality
                            , string tWardNo
                            , string tCountry
                            , string tZone
                            , string tDistrict

                            , string fatherName
                            , string motherName
                            , string grandFatherName
                            , string occupation
                            , string email
                            , string phone
                            , string mobile
                            , string agentId
                            , string gender
                            , string issueDateNp
                            , string expiryDateNp
                            )
        {
            string sql = "EXEC proc_customerMaster";
            sql += "  @flag = " + (customerId == "0" || customerId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @membershipId = " + FilterString(membershipId);
            sql += ", @firstName = " + FilterString(firstName);
            sql += ", @middleName = " + FilterString(middleName);
            sql += ", @lastName = " + FilterString(lastName);
            sql += ", @maritalStatus = " + FilterString(maritalStatus);
            sql += ", @dobEng = " + FilterString(dboEng);
            sql += ", @dobNep = " + FilterString(dboNep);
            sql += ", @isActive = " + FilterString(isActive);

            sql += ", @idType = " + FilterString(idType);
            sql += ", @idNo = " + FilterString(idNo);
            sql += ", @placeOfIssue = " + FilterString(placeOfIssue);
            sql += ", @issueDate = " + FilterString(issueDate);
            sql += ", @expiryDate = " + FilterString(expiryDate);

            sql += ", @pTole = " + FilterString(pTole);
            sql += ", @pHouseNo = " + FilterString(pHouseNo);
            sql += ", @pMunicipality = " + FilterString(pMunicipality);
            sql += ", @pWardNo = " + FilterString(pWardNo);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pZone = " + FilterString(pZone);
            sql += ", @pDistrict = " + FilterString(pDistrict);

            sql += ", @tTole = " + FilterString(tTole);
            sql += ", @tHouseNo = " + FilterString(tHouseNo);
            sql += ", @tMunicipality = " + FilterString(tMunicipality);
            sql += ", @tWardNo = " + FilterString(tWardNo);
            sql += ", @tCountry = " + FilterString(tCountry);
            sql += ", @tZone = " + FilterString(tZone);
            sql += ", @tDistrict = " + FilterString(tDistrict);

            sql += ", @fatherName = " + FilterString(fatherName);
            sql += ", @motherName = " + FilterString(motherName);
            sql += ", @grandFatherName = " + FilterString(grandFatherName);
            sql += ", @occupation = " + FilterString(occupation);
            sql += ", @email = " + FilterString(email);
            sql += ", @phone = " + FilterString(phone);
            sql += ", @mobile = " + FilterString(mobile);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @gender = " + FilterString(gender);
            sql += ", @issueDateNp = " + FilterString(issueDateNp);
            sql += ", @expiryDateNp = " + FilterString(expiryDateNp);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult UpdateAgent(
                              string user
                            , string customerId
                            , string membershipId
                            , string firstName
                            , string middleName
                            , string lastName
                            , string maritalStatus
                            , string dboEng
                            , string dboNep
                            , string isActive
                            , string idType
                            , string idNo
                            , string placeOfIssue
                            , string issueDate
                            , string expiryDate

                            , string pTole
                            , string pHouseNo
                            , string pMunicipality
                            , string pWardNo
                            , string pCountry
                            , string pZone
                            , string pDistrict

                            , string tTole
                            , string tHouseNo
                            , string tMunicipality
                            , string tWardNo
                            , string tCountry
                            , string tZone
                            , string tDistrict

                            , string fatherName
                            , string motherName
                            , string grandFatherName
                            , string occupation
                            , string email
                            , string phone
                            , string mobile
                            , string agentId
                            , string gender
                            , string issueDateNp
                            , string expiryDateNp
                            )
        {
            string sql = "EXEC proc_customerMasterAgent";
            sql += "  @flag = " + (customerId == "0" || customerId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @membershipId = " + FilterString(membershipId);
            sql += ", @firstName = " + FilterString(firstName);
            sql += ", @middleName = " + FilterString(middleName);
            sql += ", @lastName = " + FilterString(lastName);
            sql += ", @maritalStatus = " + FilterString(maritalStatus);
            sql += ", @dobEng = " + FilterString(dboEng);
            sql += ", @dobNep = " + FilterString(dboNep);
            sql += ", @isActive = " + FilterString(isActive);
            sql += ", @idType = " + FilterString(idType);
            sql += ", @idNo = " + FilterString(idNo);
            sql += ", @placeOfIssue = " + FilterString(placeOfIssue);
            sql += ", @issueDate = " + FilterString(issueDate);
            sql += ", @expiryDate = " + FilterString(expiryDate);

            sql += ", @pTole = " + FilterString(pTole);
            sql += ", @pHouseNo = " + FilterString(pHouseNo);
            sql += ", @pMunicipality = " + FilterString(pMunicipality);
            sql += ", @pWardNo = " + FilterString(pWardNo);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pZone = " + FilterString(pZone);
            sql += ", @pDistrict = " + FilterString(pDistrict);

            sql += ", @tTole = " + FilterString(tTole);
            sql += ", @tHouseNo = " + FilterString(tHouseNo);
            sql += ", @tMunicipality = " + FilterString(tMunicipality);
            sql += ", @tWardNo = " + FilterString(tWardNo);
            sql += ", @tCountry = " + FilterString(tCountry);
            sql += ", @tZone = " + FilterString(tZone);
            sql += ", @tDistrict = " + FilterString(tDistrict);

            sql += ", @fatherName = " + FilterString(fatherName);
            sql += ", @motherName = " + FilterString(motherName);
            sql += ", @grandFatherName = " + FilterString(grandFatherName);
            sql += ", @occupation = " + FilterString(occupation);
            sql += ", @email = " + FilterString(email);
            sql += ", @phone = " + FilterString(phone);
            sql += ", @mobile = " + FilterString(mobile);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @gender = " + FilterString(gender);
            sql += ", @issueDateNp = " + FilterString(issueDateNp);
            sql += ", @expiryDateNp = " + FilterString(expiryDateNp);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string customerId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteAgent(string user, string customerId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult Verify(string user, string customerId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = 'app'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectByIdAgent(string user, string customerId)
        {
            string sql = "EXEC proc_customerMasterAgent";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectById(string user, string customerId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectByMemId(string user, string membershipId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = 'a1'";
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(membershipId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DataSet GetDocuments(string user, string membershipId, string customerId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += "  @flag = 'image-display'";
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(membershipId);
            sql += ", @customerId = " + FilterString(customerId);

            DataSet ds = ExecuteDataset(sql);
            return ds;
        }
        public DataSet GetDocumentsByMembId(string user, string membershipId, string customerId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += "  @flag = 'image-display-mId'";
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(membershipId);
            sql += ", @customerId = " + FilterString(customerId);

            DataSet ds = ExecuteDataset(sql);
            return ds;
        }

        public DataRow SelectByMembershipId(string user, string membershipId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = 'a1'";
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(membershipId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public string GetSingleResult(string engDate, string nepDate)
        {
            string sql = "Exec proc_convertDate @flag='A',@engDate=" + FilterString(engDate) + ",@nepDate=" + FilterString(nepDate) + "";

            string ds = GetSingleResult(sql);

            return ds;
        }
        public DataRow PopulateIdNumber(string idType, string customerId)
        {
            string sql = "SELECT cIdentityId, idNumber FROM customerIdentity WITH(NOLOCK) WHERE idType = " + idType +
                         " AND customerId = " +
                         customerId;

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet GetReceiverById(string user, string id)
        {
            var sql = "EXEC proc_customerMaster @flag = 'getReceiverById'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rReceiverId = " + FilterString(id);
            var ds = ExecuteDataset(sql);
            return ds;
        }

        public DbResult RequestMemIdReIssue(
                              string user
                            , string id
                            , string customerId
                            , string newMemId
                            , string oldMemId
                            , string reqMsg
                            )
        {
            string sql = "EXEC proc_customerMemIdReIssue";
            sql += "  @flag = " + (id == "0" || id == "" ? "'i-agent'" : "'u-agent'");
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @newMemId = " + FilterString(newMemId);
            sql += ", @membershipId = " + FilterString(oldMemId);
            sql += ", @reqMsg = " + FilterString(reqMsg);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DbResult RequestMemIdReIssueHo(
                            string user
                          , string id
                          , string newMemId
                          , string oldMemId
                          , string reqMsg
                          )
        {
            string sql = "EXEC proc_customerMemIdReIssue";
            sql += "  @flag = " + (id == "0" || id == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);
            sql += ", @newMemId = " + FilterString(newMemId);
            sql += ", @membershipId = " + FilterString(oldMemId);
            sql += ", @reqMsg = " + FilterString(reqMsg);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataRow SelectMemIdReIssueByCustomerId(string user, string customerId)
        {
            string sql = "EXEC proc_customerMemIdReIssue";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectMemIdReIssueById(string user, string id)
        {
            string sql = "EXEC proc_customerMemIdReIssue";
            sql += " @flag = 'a1'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(id);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet GetCustomerUnapproveList(string user, string fromDate, string toDate, string agentId, string status, string isDocUploaded, string memId, string zone, string agentGrp, string district)
        {
            string sql = "EXEC proc_approveCustomer @flag='s'";
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @status = " + FilterString(status);
            sql += ", @isDoc = " + FilterString(isDocUploaded);
            sql += ", @user = " + FilterString(user);
            sql += ", @membershipId = " + FilterString(memId);
            sql += ", @zone = " + FilterString(zone);
            sql += ", @agentGrp = " + FilterString(agentGrp);
            sql += ", @district = " + FilterString(district);

            return ExecuteDataset(sql);
        }

        public DbResult Approve(string user, string customerId)
        {
            string sql = "EXEC proc_customerMaster";
            sql += " @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataTable LoadIdIssuedPlace(string user, string idType)
        {
            var sql = "EXEC proc_IdIssuedPlace ";
            sql += " @user = " + FilterString(user);
            sql += ", @idType = " + FilterString(idType);
            return ExecuteDataTable(sql);
        }
        public DbResult UpdateCustEnrollAgent(
                              string user
                            , string customerId
                            , string membershipId
                            , string dboEng
                            , string dboNep
                            , string idType
                            , string idNo
                            , string placeOfIssue
                            , string issueDate
                            , string expiryDate
                            , string issueDateNp
                            , string expiryDateNp
                            , string agentId
                            )
        {
            string sql = "EXEC proc_customerMasterAgent";
            sql += "  @flag ='u-docinfo' ";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @membershipId = " + FilterString(membershipId);
            sql += ", @dobEng = " + FilterString(dboEng);
            sql += ", @dobNep = " + FilterString(dboNep);
            sql += ", @idType = " + FilterString(idType);
            sql += ", @idNo = " + FilterString(idNo);
            sql += ", @placeOfIssue = " + FilterString(placeOfIssue);
            sql += ", @issueDate = " + FilterString(issueDate);
            sql += ", @expiryDate = " + FilterString(expiryDate);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @issueDateNp = " + FilterString(issueDateNp);
            sql += ", @expiryDateNp = " + FilterString(expiryDateNp);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }

}