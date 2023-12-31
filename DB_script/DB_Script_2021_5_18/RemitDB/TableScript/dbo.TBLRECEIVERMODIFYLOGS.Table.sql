USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TBLRECEIVERMODIFYLOGS]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBLRECEIVERMODIFYLOGS](
	[RowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[customerId] [bigint] NOT NULL,
	[tranId] [bigint] NULL,
	[columnName] [varchar](20) NULL,
	[newValue] [nvarchar](100) NULL,
	[oldValue] [nvarchar](100) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](20) NULL,
	[amendmentId] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
