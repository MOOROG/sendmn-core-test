--INSERT remaining referrals to agent_branch_running_balance table
CREATE table #ReferralList (id int ,name varchar(50))
insert into #ReferralList
select ROW_ID,REFERRAL_NAME from REFERRAL_AGENT_WISE

DELETE FROM #ReferralList WHERE id IN
(select AB.B_ID from REFERRAL_AGENT_WISE RA (NOLOCK)
INNER JOIN AGENT_BRANCH_RUNNING_BALANCE AB (NOLOCK) ON AB.B_ID = RA.ROW_ID AND AB.B_TYPE ='R')

INSERT INTO AGENT_BRANCH_RUNNING_BALANCE
SELECT id,'R',name,0,0,0,0 FROM #ReferralList


--INSERT remaining USERS to agent_branch_running_balance table
CREATE table #UsersList (id int ,name varchar(50))
insert into #UsersList
select userId,userName from applicationUsers
where userId not in (10001,10002)

DELETE FROM #UsersList WHERE id IN
(select AB.B_ID from applicationUsers RA (NOLOCK)
INNER JOIN AGENT_BRANCH_RUNNING_BALANCE AB (NOLOCK) ON AB.B_ID = RA.userId AND AB.B_TYPE ='U')

INSERT INTO AGENT_BRANCH_RUNNING_BALANCE
SELECT id,'U',name,0,0,0,0 FROM #UsersList

--INSERT remaining Branch to agent_branch_running_balance table
CREATE table #BranchList  (id int ,name varchar(50))
insert into #BranchList
select agentId,agentName from agentMaster
where parentId = 393877 and actAsBranch = 'Y'

DELETE FROM #BranchList WHERE id IN
(select AB.B_ID from agentMaster RA (NOLOCK)
INNER JOIN AGENT_BRANCH_RUNNING_BALANCE AB (NOLOCK) ON AB.B_ID = RA.agentId  AND AB.B_TYPE ='B')

INSERT INTO AGENT_BRANCH_RUNNING_BALANCE
SELECT id,'B',name,0,0,0,0 FROM #BranchList

--INSERT remaining Agents to agent_branch_running_balance table
CREATE table #AgentList  (id int ,name varchar(50))
insert into #AgentList
select agentId,agentName from agentMaster
where parentId = 393877 and actAsBranch = 'N'

DELETE FROM #AgentList WHERE id IN
(select AB.B_ID from agentMaster RA (NOLOCK)
INNER JOIN AGENT_BRANCH_RUNNING_BALANCE AB (NOLOCK) ON AB.B_ID = RA.agentId  AND AB.B_TYPE ='A')

INSERT INTO AGENT_BRANCH_RUNNING_BALANCE
SELECT id,'A',name,0,0,0,0 FROM #AgentList




