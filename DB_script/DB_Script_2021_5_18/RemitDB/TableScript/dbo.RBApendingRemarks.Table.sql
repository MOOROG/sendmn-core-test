USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[RBApendingRemarks]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RBApendingRemarks](
	[rowId] [int] IDENTITY(1,1) NOT NULL,
	[customerId] [bigint] NULL,
	[pendingRemarks] [varchar](500) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
