USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[ReportTemplate]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportTemplate](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[templateName] [varchar](200) NULL,
	[fields] [varchar](max) NULL,
	[fieldsAlias] [varchar](max) NULL,
	[isActive] [varchar](1) NULL,
	[isDeleted] [varchar](1) NULL,
	[createdBy] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL,
	[modfiedDate] [datetime] NULL,
	[temType] [char](1) NULL,
 CONSTRAINT [pk_idx_ReportTemplate_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
