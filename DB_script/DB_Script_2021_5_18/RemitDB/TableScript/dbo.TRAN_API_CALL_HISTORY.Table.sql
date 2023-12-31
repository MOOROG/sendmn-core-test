USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TRAN_API_CALL_HISTORY]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TRAN_API_CALL_HISTORY](
	[ROW_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TRAN_ID] [bigint] NOT NULL,
	[RESPONSE_CODE] [varchar](8) NOT NULL,
	[RESPONSE_MSG] [varchar](250) NOT NULL,
	[REQUESTED_BY] [varchar](50) NULL,
	[RESPOSE_DATE] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ROW_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
