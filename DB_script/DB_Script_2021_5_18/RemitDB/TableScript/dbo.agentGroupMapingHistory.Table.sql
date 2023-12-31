USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentGroupMapingHistory]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentGroupMapingHistory](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rowId] [int] NULL,
	[agentId] [int] NULL,
	[groupCat] [int] NULL,
	[groupDetail] [int] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NULL,
	[status] [varchar](50) NULL,
	[modType] [varchar](6) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
