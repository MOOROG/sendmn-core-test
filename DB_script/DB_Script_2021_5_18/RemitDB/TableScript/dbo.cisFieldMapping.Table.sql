USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[cisFieldMapping]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisFieldMapping](
	[cisFieldMapId] [int] IDENTITY(1,1) NOT NULL,
	[criteriaId] [int] NULL,
	[criteriaDesc] [varchar](100) NULL,
	[scope] [char](1) NULL,
	[controlId] [varchar](100) NULL,
	[errorMsg] [varchar](250) NULL,
	[isActive] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[controlRankID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[cisFieldMapId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
