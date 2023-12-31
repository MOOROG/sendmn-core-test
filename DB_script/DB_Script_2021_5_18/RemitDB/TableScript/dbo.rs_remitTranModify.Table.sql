USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[rs_remitTranModify]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rs_remitTranModify](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[controlNo] [varchar](50) NULL,
	[oldValue] [varchar](200) NULL,
	[newValue] [varchar](200) NULL,
	[modifyField] [varchar](30) NULL,
	[msg] [varchar](200) NULL,
	[updatedBy] [varchar](50) NULL,
	[updatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
