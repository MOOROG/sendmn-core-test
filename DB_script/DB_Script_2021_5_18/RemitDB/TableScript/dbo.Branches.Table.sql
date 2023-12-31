USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[Branches]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Branches](
	[BRANCH_ID] [int] IDENTITY(1,1) NOT NULL,
	[COMPANY_ID] [int] NULL,
	[BRANCH_NAME] [varchar](500) NULL,
	[BRANCH_SHORT_NAME] [varchar](50) NULL,
	[BRANCH_CITY] [varchar](200) NULL,
	[BRANCH_ADDRESS] [varchar](500) NULL,
	[BRANCH_PHONE] [varchar](50) NULL,
	[BRANCH_FAX] [varchar](50) NULL,
	[BRANCH_POST_BOX] [varchar](50) NULL,
	[EPS] [varchar](50) NULL,
	[BRANCH_MOBILE] [varchar](50) NULL,
	[BRANCH_EMAIL] [varchar](150) NULL,
	[BRANCH_COUNTRY] [varchar](50) NULL,
	[BRANCH_ZONE] [varchar](50) NULL,
	[BRANCH_DISTRICT] [varchar](50) NULL,
	[CONTACT_PERSON] [varchar](200) NULL,
	[CREATED_BY] [varchar](50) NULL,
	[CREATED_DATE] [datetime] NULL,
	[MODIFIED_BY] [varchar](50) NULL,
	[MODIFIED_DATE] [datetime] NULL,
	[IS_DEL] [char](1) NULL,
	[BRANCH_TYPE] [char](5) NULL,
	[tcId] [int] NULL,
	[cashId] [int] NULL,
	[receiptPrint] [char](1) NULL,
	[lineadj] [int] NULL,
	[headMsg] [varchar](max) NULL,
	[isMainBranch] [char](1) NULL,
	[mapCode] [varchar](50) NULL,
	[limitId] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
