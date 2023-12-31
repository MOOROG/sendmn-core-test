USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[branchMaster]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[branchMaster](
	[BRANCH_ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AGENT_ID] [int] NULL,
	[BRANCH_NAME] [varchar](100) NULL,
	[BRANCH_CODE] [varchar](50) NULL,
	[BRANCH_PHONE1] [varchar](20) NULL,
	[BRANCH_PHONE2] [varchar](20) NULL,
	[BRANCH_FAX1] [varchar](20) NULL,
	[BRANCH_FAX2] [varchar](20) NULL,
	[BRANCH_MOBILE1] [varchar](20) NULL,
	[BRANCH_MOBILE2] [varchar](20) NULL,
	[BRANCH_EMAIL1] [varchar](100) NULL,
	[BRANCH_EMAIL2] [varchar](100) NULL,
	[BRANCH_ADDRESS] [varchar](200) NULL,
	[BRANCH_CITY] [varchar](100) NULL,
	[BRANCH_COUNTRY] [varchar](100) NULL,
	[CONTACT_PERSON] [varchar](100) NULL,
	[CONTACT_PERSON_ADDRESS] [varchar](200) NULL,
	[CONTACT_PERSON_CITY] [varchar](100) NULL,
	[CONTACT_PERSON_COUNTRY] [varchar](100) NULL,
	[CONTACT_PERSON_PHONE] [varchar](20) NULL,
	[CONTACT_PERSON_FAX] [varchar](20) NULL,
	[CONTACT_PERSON_MOBILE] [varchar](20) NULL,
	[CONTACT_PERSON_EMAIL] [varchar](100) NULL,
	[PER_DAY_TRANSACTION] [int] NULL,
	[IS_ACTIVE] [char](10) NULL,
	[IS_DELETE] [char](1) NULL,
	[CREATED_DATE] [datetime] NULL,
	[CREATED_BY] [varchar](100) NULL,
	[MODIFY_DATE] [datetime] NULL,
	[MODIFY_BY] [varchar](100) NULL,
	[APPROVED_DATE] [datetime] NULL,
	[APPROVED_BY] [varchar](100) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_branchMaster_BRANCH_ID] PRIMARY KEY CLUSTERED 
(
	[BRANCH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[branchMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_1A8FF7FD_2E41_4F52_A905_80951D24B38E_875150163]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
