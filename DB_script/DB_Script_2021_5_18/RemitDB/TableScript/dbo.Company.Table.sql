USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[Company]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Company](
	[COMPANY_ID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[COMPANY_SHORTNAME] [varchar](100) NULL,
	[COMPANY_NAME] [varchar](200) NULL,
	[COMPANY_ADDRESS] [varchar](200) NULL,
	[COMPANY_ADDRESS2] [varchar](200) NULL,
	[COMPANY_CITY] [varchar](200) NULL,
	[COMPANY_PHONE] [varchar](50) NULL,
	[COMPANY_FAX] [varchar](50) NULL,
	[COMPANY_CONTACT_PERSON] [varchar](300) NULL,
	[COMPANY_CREATED_DATE] [datetime] NULL,
	[COMPANY_CREATED_BY] [varchar](50) NULL,
	[COMPANY_MODIFIED_DATE] [datetime] NULL,
	[COMPANY_MODIFIED_BY] [varchar](50) NULL,
	[COMPANY_STATUS] [varchar](1) NULL,
	[MAP_COMPANY_CODE] [varchar](50) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_Company_COMPANY_ID] PRIMARY KEY CLUSTERED 
(
	[COMPANY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Company] ADD  CONSTRAINT [MSrepl_tran_version_default_C23D65E7_C2AF_4654_B07C_D448FA299D68_1902629821]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
