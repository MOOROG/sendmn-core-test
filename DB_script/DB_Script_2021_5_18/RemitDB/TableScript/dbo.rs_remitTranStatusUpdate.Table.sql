USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[rs_remitTranStatusUpdate]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rs_remitTranStatusUpdate](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[controlNo] [varchar](30) NULL,
	[tranStatus] [varchar](20) NULL,
	[updatedBy] [varchar](50) NULL,
	[updatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
