USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[userMaster]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[userMaster](
	[USER_ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AGENT_ID] [int] NULL,
	[BRANCH_ID] [int] NULL,
	[USER_NAME] [varchar](100) NULL,
	[USER_CODE] [varchar](50) NULL,
	[USER_PHONE1] [varchar](20) NULL,
	[USER_PHONE2] [varchar](20) NULL,
	[USER_MOBILE1] [varchar](20) NULL,
	[USER_MOILE2] [varchar](20) NULL,
	[USER_FAX1] [varchar](20) NULL,
	[USER_FAX2] [varchar](20) NULL,
	[USER_EMAIL1] [varchar](100) NULL,
	[USER_EMAIL2] [varchar](100) NULL,
	[USER_ADDRESS_PERMANENT] [varchar](200) NULL,
	[PERMA_CITY] [varchar](100) NULL,
	[PEMA_COUNTRY] [varchar](100) NULL,
	[USER_ADDRESS_TEMP] [varchar](200) NULL,
	[TEMP_CITY] [varchar](100) NULL,
	[TEMP_COUNTRY] [varchar](100) NULL,
	[CONTACT_PERSON] [varchar](100) NULL,
	[CONTACT_PERSON_ADDRESS] [varchar](200) NULL,
	[CONTACT_PERSON_PHONE] [varchar](20) NULL,
	[CONTACT_PERSON_FAX] [varchar](20) NULL,
	[CONTACT_PERSON_MOBILE] [varchar](20) NULL,
	[CONTACT_PERSON_EMAIL] [varchar](100) NULL,
	[IS_ACTIVE] [char](1) NULL,
	[IS_DELETE] [char](1) NULL,
	[CREATE_DATE] [datetime] NULL,
	[CREATED_BY] [varchar](100) NULL,
	[MODIFY_DATE] [datetime] NULL,
	[MODIFY_BY] [varchar](100) NULL,
	[APPROVED_DATE] [datetime] NULL,
	[APPROVED_BY] [varchar](100) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_userMaster_USER_ID] PRIMARY KEY CLUSTERED 
(
	[USER_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[userMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_853BB95C_8F37_47D0_8118_CC437662A38A_1143675122]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
