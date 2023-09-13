
namespace Swift.DAL.SwiftDAL
{

    public class UserDetails
    {
        public string logId { get; set; }
        public string UserUniqueKey { get; set; }
        public string ErrorCode { get; set; }
        public string Msg { get; set; }
        public string UserId { get; set; }
        public string FullName { get; set; }
        public string Address { get; set; }
        public int AttemptCount { get; set; }
        public string LastLoginTs { get; set; }
        public string UserAccessLevel { get; set; }
        public string Branch { get; set; }
        public string BranchName { get; set; }
        public string UserType { get; set; }
        public string isForcePwdChanged { get; set; }
        public string sessionTimeOut { get; set; }
        public string Agent { get; set; }
        public string AgentName { get; set; }
        public string SuperAgent { get; set; }
        public string SuperAgentName { get; set; }
        public string SettlingAgent { get; set; }
        public string MapCodeInt { get; set; }
        public string ParentMapCodeInt { get; set; }
        public string MapCodeDom { get; set; }

        public string AgentType { get; set; }
        public string Id { get; set; }
        public string Country { get; set; }
        public string CountryId { get; set; }
        public string IsActAsBranch { get; set; }
        public string FromSendTrnTime { get; set; }
        public string ToSendTrnTime { get; set; }
        public string FromPayTrnTime { get; set; }
        public string ToPayTrnTime { get; set; }
        public string ParentId { get; set; }
        public string IsHeadOffice { get; set; }
        public string newBranchId { get; set; }
        public string AgentLocation { get; set; }
        public string AgentGrp { get; set; }
        public string AgentEmail { get; set; }
        public string AgentPhone { get; set; }
        public string LoggedInCountry { get; set; }
        public string LoginAddress { get; set; }
    }
}
