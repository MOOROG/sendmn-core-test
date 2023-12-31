USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[suspiciousTxnRpt]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[suspiciousTxnRpt](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[controlNo] [varchar](30) NULL,
	[strId] [varchar](30) NULL,
	[status] [varchar](10) NULL,
	[reason] [varchar](200) NULL,
	[remarks] [varchar](500) NULL,
	[groundForSuspicion] [varchar](500) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[dateOfReporting] [datetime] NULL,
	[approveRemarks] [varchar](500) NULL,
	[pendingRemarks] [varchar](500) NULL,
	[rejectRemarks] [varchar](max) NULL,
	[analysingRemarks] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
