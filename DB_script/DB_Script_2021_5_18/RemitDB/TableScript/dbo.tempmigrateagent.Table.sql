USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tempmigrateagent]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempmigrateagent](
	[AgentName] [nvarchar](255) NULL,
	[Branch Name] [nvarchar](255) NULL,
	[BusinessType] [nvarchar](255) NULL,
	[BusinessType1] [nvarchar](255) NULL,
	[RegistrationType] [nvarchar](255) NULL,
	[AgentGroup] [nvarchar](255) NULL,
	[IsSettlingAgent] [nvarchar](255) NULL,
	[IsHeadOffice] [nvarchar](255) NULL,
	[Zone] [nvarchar](255) NULL,
	[District] [nvarchar](255) NULL,
	[PayoutLocation] [nvarchar](255) NULL,
	[FullAddress] [nvarchar](255) NULL,
	[PhoneNumber] [nvarchar](255) NULL,
	[BusinessLicense] [float] NULL,
	[Email] [nvarchar](255) NULL,
	[PrincipleAccount] [nvarchar](255) NULL,
	[FundingBank] [nvarchar](255) NULL,
	[FundingBankBranch] [nvarchar](255) NULL,
	[FundingAcName] [nvarchar](255) NULL,
	[FundingAcNum] [nvarchar](255) NULL,
	[User] [nvarchar](255) NULL,
	[agentPhone2] [varchar](50) NULL,
	[IsDeleted] [varchar](50) NULL,
	[map_code] [varchar](50) NULL
) ON [PRIMARY]
GO
