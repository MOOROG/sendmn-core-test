USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[fileFormat]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fileFormat](
	[flFormatId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[formatCode] [varchar](10) NULL,
	[formatType] [varchar](50) NULL,
	[flDescription] [varchar](500) NULL,
	[fldSeperator] [varchar](20) NULL,
	[fixDataLength] [char](1) NULL,
	[dataSourceCode] [varchar](50) NULL,
	[includeColHeader] [char](1) NULL,
	[recordSeperator] [varchar](10) NULL,
	[hasHeader] [char](1) NULL,
	[hasFooter] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[filterClause] [varchar](max) NULL,
	[includeSerialNo] [char](1) NULL,
	[includeHeader] [char](1) NULL,
	[headerFormatCode] [int] NULL,
	[fdDate] [date] NULL,
	[fdCount] [int] NULL,
	[sourceType] [varchar](200) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[flFormatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[fileFormat] ADD  CONSTRAINT [MSrepl_tran_version_default_DF660EB8_7562_47CC_B00B_F6192FF381C7_2056042756]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
