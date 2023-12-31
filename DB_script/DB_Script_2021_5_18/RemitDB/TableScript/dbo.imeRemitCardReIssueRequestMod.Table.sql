USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[imeRemitCardReIssueRequestMod]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[imeRemitCardReIssueRequestMod](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[reqId] [bigint] NULL,
	[oldRemitCardNo] [varchar](16) NULL,
	[newRemitCardNo] [varchar](16) NULL,
	[oldCardPinNo] [varchar](16) NULL,
	[newCardPinNo] [varchar](16) NULL,
	[requestRemarks] [varchar](200) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[requestFor] [varchar](10) NULL,
	[modType] [varchar](2) NULL,
	[rejectedBy] [varchar](40) NULL,
	[rejectedDate] [datetime] NULL,
	[status] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
