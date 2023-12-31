USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TBLCUSTOMERMODIFYLOGS]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBLCUSTOMERMODIFYLOGS](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[customerId] [bigint] NOT NULL,
	[columnName] [varchar](30) NOT NULL,
	[newValue] [nvarchar](300) NULL,
	[modifiedBy] [varchar](100) NOT NULL,
	[modifiedDate] [datetime] NOT NULL,
	[oldValue] [nvarchar](300) NULL,
	[amendmentId] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[TBLCUSTOMERMODIFYLOGS] ADD  DEFAULT (getdate()) FOR [modifiedDate]
GO
