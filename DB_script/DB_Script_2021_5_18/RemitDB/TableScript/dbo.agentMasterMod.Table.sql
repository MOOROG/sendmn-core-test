USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentMasterMod]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentMasterMod](
	[rowId] [int] IDENTITY(1000,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[parentId] [int] NULL,
	[agentName] [varchar](100) NULL,
	[agentCode] [varchar](50) NULL,
	[agentAddress] [varchar](200) NULL,
	[agentCity] [varchar](100) NULL,
	[agentCountry] [varchar](100) NULL,
	[agentState] [varchar](100) NULL,
	[agentDistrict] [varchar](100) NULL,
	[agentZip] [varchar](20) NULL,
	[agentLocation] [int] NULL,
	[agentPhone1] [varchar](20) NULL,
	[agentPhone2] [varchar](20) NULL,
	[agentFax1] [varchar](20) NULL,
	[agentFax2] [varchar](20) NULL,
	[agentMobile1] [varchar](20) NULL,
	[agentMobile2] [varchar](20) NULL,
	[agentEmail1] [varchar](100) NULL,
	[agentEmail2] [varchar](100) NULL,
	[businessOrgType] [int] NULL,
	[businessType] [int] NULL,
	[agentRole] [varchar](10) NULL,
	[agentType] [int] NULL,
	[allowAccountDeposit] [char](1) NULL,
	[actAsBranch] [char](1) NULL,
	[contractExpiryDate] [datetime] NULL,
	[renewalFollowupDate] [datetime] NULL,
	[isSettlingAgent] [char](1) NULL,
	[agentGrp] [int] NULL,
	[businessLicense] [varchar](100) NULL,
	[agentBlock] [char](1) NULL,
	[agentCompanyName] [varchar](200) NULL,
	[companyAddress] [varchar](200) NULL,
	[companyCity] [varchar](100) NULL,
	[companyCountry] [varchar](100) NULL,
	[companyState] [varchar](100) NULL,
	[companyDistrict] [varchar](100) NULL,
	[companyZip] [varchar](20) NULL,
	[companyPhone1] [varchar](20) NULL,
	[companyPhone2] [varchar](20) NULL,
	[companyFax1] [varchar](20) NULL,
	[companyFax2] [varchar](20) NULL,
	[companyEmail1] [varchar](100) NULL,
	[companyEmail2] [varchar](100) NULL,
	[localTime] [varchar](100) NULL,
	[localCurrency] [varchar](20) NULL,
	[agentDetails] [varchar](max) NULL,
	[isActive] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](100) NULL,
	[modType] [char](1) NOT NULL,
	[agentCountryId] [int] NULL,
	[headMessage] [varchar](max) NULL,
	[extCode] [varchar](200) NULL,
	[swiftCode] [varchar](200) NULL,
	[routingCode] [varchar](200) NULL,
	[bankMapCode] [varchar](20) NULL,
	[mapCodeInt] [varchar](20) NULL,
	[mapCodeDom] [varchar](20) NULL,
	[commCodeInt] [varchar](20) NULL,
	[commCodeDom] [varchar](20) NULL,
	[mapCodeIntAc] [varchar](20) NULL,
	[mapCodeDomAc] [varchar](20) NULL,
	[payOption] [int] NULL,
	[agentSettCurr] [varchar](5) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[contactPerson1] [varchar](250) NULL,
	[contactPerson2] [varchar](250) NULL,
	[isHeadOffice] [char](1) NULL,
	[BANKCODE] [varchar](50) NULL,
	[BANKBRANCH] [varchar](50) NULL,
	[BANKACCOUNTNUMBER] [varchar](50) NULL,
	[ACCOUNTHOLDERNAME] [varchar](50) NULL,
	[IsIntl] [bit] NULL,
	[IsDom] [bit] NULL,
	[isApiPartner] [bit] NULL,
 CONSTRAINT [PK__agentMas__350C70C262A57E71] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentMasterMod] ADD  CONSTRAINT [MSrepl_tran_version_default_54100DED_1437_4A6A_9E3E_F792C3F7CD72_842082386]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
