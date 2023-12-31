USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vw_agentMaster]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- Select * from vw_agentMaster
CREATE VIEW [dbo].[vw_agentMaster]
AS
SELECT 
	 am.agentId as [Agent Id]
	,am.agentName [Agent Name]	 
	,am.agentCode [Agent Code]
	,am.agentAddress [Agent Address]
	,am.agentCity [Agent City]
	,am.agentCountry [Agent Country]
	,am.agentState [Agent State/Zone]
	,am.agentDistrict [Agent District]
	,am.agentZip [Zip]
	,l.districtName [Agent Location]
	,COALESCE(am.agentPhone1, am.agentPhone2) [Phone]
	,COALESCE(am.agentFax1,am.agentFax2) [Fax]
	,COALESCE(am.agentMobile1,am.agentMobile2) [Mobile]
	,COALESCE(am.agentEmail1,am.agentEmail2) [Email]
	,DBO.FNAGetDataValue(am.businessOrgType) [Organization Type]
	,DBO.FNAGetDataValue(am.businessType) [Business Type]
	,CASE WHEN ISNULL(am.agentRole,'B') = 'B' THEN 'SEND/RECEIVE' WHEN am.agentRole = 'R' THEN 'RECEIVE' WHEN am.agentRole = 'S' THEN 'SEND' END  [Agent Role]
	,DBO.FNAGetDataValue(am.agentType) [Agent Type]
	,am.allowAccountDeposit [Allow A/C Deposit]
	,am.actAsBranch [Act As Branch]
	,am.contractExpiryDate [Contact Expiry Date]
	,am.renewalFollowupDate [Renewall Follow Up]
	,am.isSettlingAgent [Is Settling Agent]
	,am.agentGrp [Agent Group]
	,am.businessLicense [Business License]	
	,am.agentCompanyName [Agent Company Name]
	,am.companyAddress [Company Address]
	,am.companyCity [Company City]
	,am.companyCountry [Company Country]
	,am.companyState [Company State]
	,am.companyDistrict [Company District]
	,am.companyZip [Company Zip]
	,COALESCE(am.companyPhone1,am.companyPhone2) [Company Phone]
	,COALESCE(am.companyFax1,am.companyFax2) [Company Fax]
	,COALESCE(am.companyEmail1,am.companyEmail2) [Company Email]
	,am.localTime [Local Time]
	,am.localCurrency [Local Currency]
	,am.agentDetails [Agent Details]
	,case when am.agentBlock='B' then 'Block' when am1.agentBlock ='B' then 'Block' else 'Unblock' end [Agent Block]
	,case when am.isActive='N' then 'Inactive' when am1.isActive = 'N' then 'Inactive' else 'Active' end [Is Active]
	,am.createdDate [Created Date]
	,am.createdBy [Created By]
	,am.modifiedDate [Modified Date]
	,am.modifiedBy [Modified By]
	,am.approvedDate [Approved Date]
	,am.approvedBy [Approved By]
	,am.mapCodeInt [Map Code International]
	,am.mapCodeDom [Map Code Domestic]
	,am.commCodeInt [Commission Code Int]
	,am.commCodeDom [Commission Code Dom]
	,am.joinedDate [Joined Date]
	,am.mapCodeIntAc [Map Code Int A/C]
	,am.mapCodeDomAc [Map Code Domestic A/C]
	,am.payOption [Pay Option]
	,am.agentApiType [Agent API Type]
	,am.isHeadOffice [Is Head Office]
	,am.agentSettCurr [Settlement Currency]
	,[Contact Person] = ISNULL(cp.name,am.contactPerson1)
	--Filter fileds
	,am.agentType
	,am.actAsBranch
	,am.isDeleted
	,am.isActive
	,am.agentBlock AS agentBlock1
	,am.parentId
	,am.agentCountry
	,am.agentId
	,AM.agentRole
	,am.agentGrp
FROM agentMaster am WITH(NOLOCK) 
inner join agentMaster am1 with(nolock) on am.parentId = am1.agentId
left JOIN api_districtList l with(nolock) on am.agentLocation = l.districtCode
left join agentContactPerson cp with(nolock) on am.agentId = cp.agentId






GO
